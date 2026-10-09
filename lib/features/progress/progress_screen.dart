import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/common_widgets.dart';
import '../../core/services/storage_service.dart';

class DayStudyData {
  final String day;
  final String fullDay;
  final double hours;
  final int sessions;
  final double heightPct;
  final String highlight;

  const DayStudyData({
    required this.day,
    required this.fullDay,
    required this.hours,
    required this.sessions,
    required this.heightPct,
    required this.highlight,
  });
}

class ProgressScreen extends StatefulWidget {
  final StorageService storage;
  const ProgressScreen({super.key, required this.storage});

  @override
  State<ProgressScreen> createState() => _ProgressScreenState();
}

class _ProgressScreenState extends State<ProgressScreen> {
  String? _hoveredDay;

  final List<DayStudyData> _weeklyData = const [
    DayStudyData(
      day: 'Mon',
      fullDay: 'Monday',
      hours: 2.4,
      sessions: 3,
      heightPct: 0.60,
      highlight: 'Regular Focus',
    ),
    DayStudyData(
      day: 'Tue',
      fullDay: 'Tuesday',
      hours: 3.4,
      sessions: 4,
      heightPct: 0.85,
      highlight: 'Great Discipline',
    ),
    DayStudyData(
      day: 'Wed',
      fullDay: 'Wednesday',
      hours: 1.8,
      sessions: 2,
      heightPct: 0.45,
      highlight: 'Light Study',
    ),
    DayStudyData(
      day: 'Thu',
      fullDay: 'Thursday',
      hours: 3.6,
      sessions: 4,
      heightPct: 0.90,
      highlight: 'Deep Work Session',
    ),
    DayStudyData(
      day: 'Fri',
      fullDay: 'Friday',
      hours: 2.8,
      sessions: 3,
      heightPct: 0.70,
      highlight: 'Consistent Pace',
    ),
    DayStudyData(
      day: 'Sat',
      fullDay: 'Saturday',
      hours: 4.0,
      sessions: 5,
      heightPct: 1.00,
      highlight: '🏆 Peak Study Day',
    ),
    DayStudyData(
      day: 'Sun',
      fullDay: 'Sunday',
      hours: 1.2,
      sessions: 1,
      heightPct: 0.30,
      highlight: 'Rest & Revision',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final todayMinutes = widget.storage.getTodayFocusMinutes();
    final todayHours = (todayMinutes / 60.0).toStringAsFixed(1);
    final totalSessions = widget.storage.studyLogs.length;

    final completedTasks = widget.storage.checklist.where((t) => t.isCompleted).length;
    final totalTasks = widget.storage.checklist.length;

    final completedAssignments = widget.storage.assignments.where((a) => a.isCompleted).length;
    final totalAssignments = widget.storage.assignments.length;

    // Overall attendance calculation
    int totalAttended = 0;
    int totalClasses = 0;
    for (var a in widget.storage.attendanceSubjects) {
      totalAttended += (a.attended + a.medicalLeaves);
      totalClasses += a.total;
    }
    final overallAttendance = totalClasses == 0 ? 100.0 : (totalAttended / totalClasses) * 100.0;

    final activeData = _hoveredDay != null
        ? _weeklyData.firstWhere((d) => d.day == _hoveredDay, orElse: () => _weeklyData[5])
        : null;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Academic Progress 📊'),
        actions: [
          IconButton(
            icon: const Icon(Icons.picture_as_pdf_outlined),
            tooltip: 'Export Academic Report',
            onPressed: _exportAcademicReport,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Study Focus Header
            CustomCard(
              gradient: const LinearGradient(
                colors: [Color(0xFF6366F1), Color(0xFF4F46E5)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              child: Column(
                children: [
                  const Text(
                    'TODAY’S FOCUS TIME',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '${todayHours}h',
                    style: const TextStyle(fontSize: 48, fontWeight: FontWeight.w900, color: Colors.white),
                  ),
                  Text(
                    '$totalSessions Total Sessions Logged',
                    style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Weekly Study Bar Chart with Interactive Hover & Tap
            CustomCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Weekly Study Distribution',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      if (activeData != null)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: AppColors.primary.withValues(alpha: 0.4)),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                '${activeData.fullDay}: ',
                                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.primary),
                              ),
                              Text(
                                '${activeData.hours.toStringAsFixed(1)}h (${activeData.sessions} sessions)',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: isDark ? Colors.white : Colors.black87,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Graph Row
                  SizedBox(
                    height: 180,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: _weeklyData.map((data) => _buildInteractiveDayBar(data, isDark)).toList(),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Metrics Grid
            Row(
              children: [
                Expanded(
                  child: CustomCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.check_circle_outline, color: AppColors.success, size: 28),
                        const SizedBox(height: 8),
                        const Text('Checklist Done', style: TextStyle(fontSize: 12, color: Colors.grey)),
                        const SizedBox(height: 4),
                        Text(
                          '$completedTasks / $totalTasks',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: CustomCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.assignment_outlined, color: AppColors.secondary, size: 28),
                        const SizedBox(height: 8),
                        const Text('Assignments Done', style: TextStyle(fontSize: 12, color: Colors.grey)),
                        const SizedBox(height: 4),
                        Text(
                          '$completedAssignments / $totalAssignments',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            Row(
              children: [
                Expanded(
                  child: CustomCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.co_present, color: AppColors.primary, size: 28),
                        const SizedBox(height: 8),
                        const Text('Overall Attendance', style: TextStyle(fontSize: 12, color: Colors.grey)),
                        const SizedBox(height: 4),
                        Text(
                          '${overallAttendance.toStringAsFixed(1)}%',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                            color: overallAttendance >= 75 ? AppColors.success : AppColors.error,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: CustomCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.school_outlined, color: AppColors.warning, size: 28),
                        const SizedBox(height: 8),
                        const Text('Cumulative CGPA', style: TextStyle(fontSize: 12, color: Colors.grey)),
                        const SizedBox(height: 4),
                        Text(
                          widget.storage.calculateCumulativeCGPA() > 0
                              ? widget.storage.calculateCumulativeCGPA().toStringAsFixed(2)
                              : '8.14',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: AppColors.warning),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 18),
            GooglePlayCompliantAdBanner(
              isPro: widget.storage.isProUser,
              format: GooglePlayAdFormat.nativeCard,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInteractiveDayBar(DayStudyData data, bool isDark) {
    final isHovered = _hoveredDay == data.day;
    final barHeight = 100 * data.heightPct;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hoveredDay = data.day),
      onExit: (_) => setState(() => _hoveredDay = null),
      child: GestureDetector(
        onTap: () {
          setState(() {
            _hoveredDay = _hoveredDay == data.day ? null : data.day;
          });
        },
        child: Tooltip(
          preferBelow: false,
          verticalOffset: 24,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: const Color(0xFF0F172A),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.primary, width: 1.5),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.4),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          richMessage: TextSpan(
            children: [
              TextSpan(
                text: '${data.fullDay}\n',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.white),
              ),
              TextSpan(
                text: '⏱️ Focus Time: ${data.hours.toStringAsFixed(1)} hours\n',
                style: const TextStyle(fontSize: 12, color: Colors.amberAccent, fontWeight: FontWeight.w600),
              ),
              TextSpan(
                text: '🍅 ${data.sessions} Pomodoro Sessions\n',
                style: const TextStyle(fontSize: 11, color: Colors.white70),
              ),
              TextSpan(
                text: data.highlight,
                style: const TextStyle(fontSize: 11, color: Colors.greenAccent, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              // Value popup indicator when hovered with fixed reserved height to eliminate any layout shift
              SizedBox(
                height: 20,
                child: AnimatedOpacity(
                  duration: const Duration(milliseconds: 150),
                  opacity: isHovered ? 1.0 : 0.0,
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        '${data.hours.toStringAsFixed(1)}h',
                        style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 4),

              // The animated Bar
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: isHovered ? 28 : 24,
                height: isHovered ? barHeight + 4 : barHeight,
                decoration: BoxDecoration(
                  gradient: isHovered
                      ? const LinearGradient(
                          colors: [Color(0xFF818CF8), Color(0xFF4F46E5)],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        )
                      : null,
                  color: isHovered
                      ? null
                      : (data.heightPct >= 0.8
                          ? AppColors.primary
                          : AppColors.primary.withValues(alpha: 0.45)),
                  borderRadius: BorderRadius.circular(6),
                  border: isHovered ? Border.all(color: Colors.white, width: 2) : null,
                  boxShadow: isHovered
                      ? [
                          BoxShadow(
                            color: AppColors.primary.withValues(alpha: 0.5),
                            blurRadius: 10,
                            spreadRadius: 1,
                          ),
                        ]
                      : null,
                ),
              ),
              const SizedBox(height: 8),

              // Day Label
              Text(
                data.day,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: isHovered ? FontWeight.bold : FontWeight.w500,
                  color: isHovered
                      ? AppColors.primary
                      : (isDark ? AppColors.darkSubtext : AppColors.lightSubtext),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _exportAcademicReport() {
    if (!widget.storage.isProStudent) {
      showFeatureLockedDialog(
        context,
        featureTitle: 'Export Academic Report 📄',
        requiredPlanTitle: 'PRO STUDENT (₹89)',
        description: 'Generating and exporting formatted academic progress summaries, focus logs, and attendance reports is a Pro Student feature.\n\nUpgrade to Pro Student to unlock complete academic PDF exports!',
        storage: widget.storage,
        planPrice: '₹89',
      );
      return;
    }

    final todayMinutes = widget.storage.getTodayFocusMinutes();
    final todayHours = (todayMinutes / 60.0).toStringAsFixed(1);
    final totalSessions = widget.storage.studyLogs.length;
    final completedTasks = widget.storage.checklist.where((t) => t.isCompleted).length;
    final totalTasks = widget.storage.checklist.length;
    final completedAssignments = widget.storage.assignments.where((a) => a.isCompleted).length;
    final totalAssignments = widget.storage.assignments.length;

    int totalAttended = 0;
    int totalClasses = 0;
    for (var a in widget.storage.attendanceSubjects) {
      totalAttended += (a.attended + a.medicalLeaves);
      totalClasses += a.total;
    }
    final overallAttendance = totalClasses == 0 ? 100.0 : (totalAttended / totalClasses) * 100.0;
    final cgpa = widget.storage.calculateCumulativeCGPA();

    final buffer = StringBuffer();
    buffer.writeln('📊 Comprehensive Academic Progress Report');
    buffer.writeln('=======================================');
    buffer.writeln('Student Name: ${widget.storage.userName}');
    buffer.writeln('College / Branch: ${widget.storage.collegeName.isNotEmpty ? widget.storage.collegeName : "Campus"} • ${widget.storage.degreeBranch}');
    buffer.writeln('Study Streak: ${widget.storage.studyStreak} Days 🔥');
    buffer.writeln('Cumulative CGPA: ${cgpa > 0 ? cgpa.toStringAsFixed(2) : "N/A"}');
    buffer.writeln('Overall Attendance: ${overallAttendance.toStringAsFixed(1)}% ($totalAttended/$totalClasses classes)');
    buffer.writeln('Total Focus Sessions: $totalSessions ($todayHours hrs today)');
    buffer.writeln('Tasks Completed: $completedTasks / $totalTasks');
    buffer.writeln('Assignments Submitted: $completedAssignments / $totalAssignments');
    buffer.writeln('=======================================');
    buffer.writeln('Generated via Student Utility Hub Pro 👑');

    Share.share(
      buffer.toString(),
      subject: 'Academic Progress Report - ${widget.storage.userName}',
    );
  }
}
