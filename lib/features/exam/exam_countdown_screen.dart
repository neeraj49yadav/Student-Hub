import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/common_widgets.dart';
import '../../core/services/storage_service.dart';
import '../../shared/models/app_models.dart';
import 'package:uuid/uuid.dart';

class ExamCountdownScreen extends StatefulWidget {
  final StorageService storage;
  const ExamCountdownScreen({super.key, required this.storage});

  @override
  State<ExamCountdownScreen> createState() => _ExamCountdownScreenState();
}

class _ExamCountdownScreenState extends State<ExamCountdownScreen> {
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final exams = List<ExamEntry>.from(widget.storage.exams);
    exams.sort((a, b) => a.examDate.compareTo(b.examDate));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Exam Countdown 🔥'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: 'Add Exam',
            onPressed: () => _showAddExamDialog(context),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: exams.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(Icons.assignment_turned_in_outlined, size: 48, color: Colors.grey),
                        SizedBox(height: 12),
                        Text('No upcoming exams scheduled!', style: TextStyle(fontWeight: FontWeight.bold)),
                        SizedBox(height: 4),
                        Text('Add your semester exams to track countdowns.', style: TextStyle(color: Colors.grey)),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: exams.length,
                    itemBuilder: (context, idx) {
                      final exam = exams[idx];
                      final daysLeft = exam.daysRemaining;

                      final isUrgent = daysLeft <= 7;
                      final badgeColor = isUrgent
                          ? AppColors.error
                          : daysLeft <= 20
                              ? AppColors.warning
                              : AppColors.primary;

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: CustomCard(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Row(
                                children: [
                                  // Big Countdown Badge
                                  Container(
                                    width: 75,
                                    padding: const EdgeInsets.symmetric(vertical: 12),
                                    decoration: BoxDecoration(
                                      color: badgeColor.withValues(alpha: 0.12),
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(color: badgeColor.withValues(alpha: 0.4)),
                                    ),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          daysLeft <= 0 ? 'TODAY' : '$daysLeft',
                                          style: TextStyle(
                                            fontSize: daysLeft <= 0 ? 14 : 26,
                                            fontWeight: FontWeight.w900,
                                            color: badgeColor,
                                          ),
                                        ),
                                        if (daysLeft > 0)
                                          Text(
                                            'DAYS',
                                            style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: badgeColor),
                                          ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 14),

                                  // Info Details
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Expanded(
                                              child: Text(
                                                exam.subject,
                                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                              ),
                                            ),
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                              decoration: BoxDecoration(
                                                color: (exam.priority == 'HIGH' ? AppColors.error : AppColors.secondary).withValues(alpha: 0.12),
                                                borderRadius: BorderRadius.circular(4),
                                              ),
                                              child: Text(
                                                exam.priority,
                                                style: TextStyle(
                                                  fontSize: 10,
                                                  fontWeight: FontWeight.bold,
                                                  color: exam.priority == 'HIGH' ? AppColors.error : AppColors.secondary,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 6),
                                        Row(
                                          children: [
                                            const Icon(Icons.event_outlined, size: 14, color: Colors.grey),
                                            const SizedBox(width: 4),
                                            Text(
                                              DateFormat('EEE, dd MMM yyyy').format(exam.examDate),
                                              style: TextStyle(fontSize: 12, color: isDark ? AppColors.darkSubtext : AppColors.lightSubtext),
                                            ),
                                            const SizedBox(width: 10),
                                            const Icon(Icons.access_time, size: 14, color: Colors.grey),
                                            const SizedBox(width: 4),
                                            Text(exam.examTime, style: TextStyle(fontSize: 12, color: isDark ? AppColors.darkSubtext : AppColors.lightSubtext)),
                                          ],
                                        ),
                                        if (exam.location.isNotEmpty) ...[
                                          const SizedBox(height: 4),
                                          Row(
                                            children: [
                                              const Icon(Icons.location_on_outlined, size: 14, color: Colors.grey),
                                              const SizedBox(width: 4),
                                              Text(exam.location, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                                            ],
                                          ),
                                        ],
                                        if (exam.notes.isNotEmpty) ...[
                                          const SizedBox(height: 6),
                                          Text(
                                            exam.notes,
                                            style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic, color: isDark ? Colors.white70 : Colors.black87),
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ],
                                      ],
                                    ),
                                  ),

                                  IconButton(
                                    icon: const Icon(Icons.delete_outline, size: 20, color: Colors.grey),
                                    onPressed: () async {
                                      final confirmed = await showConfirmDeleteDialog(
                                        context,
                                        title: 'Delete Exam?',
                                        message: 'Are you sure you want to delete "${exam.subject}" exam entry? This cannot be undone.',
                                      );
                                      if (confirmed) {
                                        widget.storage.deleteExam(exam.id);
                                      }
                                    },
                                  ),
                                ],
                              ),

                              // 5-Unit Syllabus Checklist & Preparation Tracker
                              if (exam.syllabusUnits.isNotEmpty) ...[
                                const Divider(height: 20),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          '📚 5-Unit Syllabus Preparation (${exam.preparationPercentage.toInt()}%)',
                                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                                        ),
                                        Text(
                                          '${exam.completedUnits.length}/${exam.syllabusUnits.length} Units Done',
                                          style: TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.w600,
                                            color: exam.completedUnits.length == exam.syllabusUnits.length ? AppColors.success : AppColors.primary,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 6),
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(4),
                                      child: LinearProgressIndicator(
                                        value: exam.preparationPercentage / 100.0,
                                        backgroundColor: Colors.grey.withValues(alpha: 0.2),
                                        valueColor: AlwaysStoppedAnimation<Color>(
                                          exam.completedUnits.length == exam.syllabusUnits.length ? AppColors.success : AppColors.primary,
                                        ),
                                        minHeight: 6,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    ...List.generate(exam.syllabusUnits.length, (uIdx) {
                                      final isDone = exam.completedUnits.contains(uIdx);
                                      return InkWell(
                                        onTap: () {
                                          HapticFeedback.lightImpact();
                                          widget.storage.toggleExamUnitCompleted(exam.id, uIdx);
                                        },
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(vertical: 3),
                                          child: Row(
                                            children: [
                                              Icon(
                                                isDone ? Icons.check_box : Icons.check_box_outline_blank,
                                                size: 18,
                                                color: isDone ? AppColors.success : Colors.grey,
                                              ),
                                              const SizedBox(width: 8),
                                              Expanded(
                                                child: Text(
                                                  exam.syllabusUnits[uIdx],
                                                  style: TextStyle(
                                                    fontSize: 12,
                                                    decoration: isDone ? TextDecoration.lineThrough : null,
                                                    color: isDone
                                                        ? Colors.grey
                                                        : (isDark ? AppColors.darkText : AppColors.lightText),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      );
                                    }),
                                  ],
                                ),
                              ],
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
          GooglePlayCompliantAdBanner(isPro: widget.storage.isProUser),
        ],
      ),
    );
  }

  void _showAddExamDialog(BuildContext context) {
    final subCtrl = TextEditingController();
    final locCtrl = TextEditingController();
    final notesCtrl = TextEditingController();
    DateTime examDate = DateTime.now().add(const Duration(days: 30));
    String examTime = '10:00 AM';
    String priority = 'HIGH';

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Add Upcoming Exam'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(controller: subCtrl, decoration: const InputDecoration(labelText: 'Course / Subject')),
                const SizedBox(height: 10),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Exam Date'),
                  subtitle: Text(DateFormat('dd MMMM yyyy').format(examDate)),
                  trailing: Icon(Icons.calendar_month, color: AppColors.primary),
                  onTap: () async {
                    final d = await showDatePicker(
                      context: context,
                      initialDate: examDate,
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 730)),
                    );
                    if (d != null) setDialogState(() => examDate = d);
                  },
                ),
                TextField(controller: locCtrl, decoration: const InputDecoration(labelText: 'Exam Hall / Location (optional)')),
                const SizedBox(height: 10),
                TextField(controller: notesCtrl, decoration: const InputDecoration(labelText: 'Syllabus / Notes (optional)')),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () {
                if (subCtrl.text.trim().isNotEmpty) {
                  final e = ExamEntry(
                    id: const Uuid().v4(),
                    subject: subCtrl.text.trim(),
                    examDate: examDate,
                    examTime: examTime,
                    location: locCtrl.text.trim(),
                    notes: notesCtrl.text.trim(),
                    priority: priority,
                    syllabusUnits: [
                      'Unit 1: Fundamentals & Core Principles',
                      'Unit 2: Architecture & Main Frameworks',
                      'Unit 3: Implementation & Methodologies',
                      'Unit 4: Advanced Concepts & Optimization',
                      'Unit 5: Applications & Real-World Projects',
                    ],
                    completedUnits: [],
                  );
                  widget.storage.addExam(e);
                  Navigator.pop(ctx);
                }
              },
              child: const Text('Add Exam'),
            ),
          ],
        ),
      ),
    );
  }
}
