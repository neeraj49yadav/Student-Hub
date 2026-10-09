import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/common_widgets.dart';
import '../../core/services/storage_service.dart';
import '../../shared/models/app_models.dart';
import 'sgpa_calculator_screen.dart';
import 'package:uuid/uuid.dart';

class CgpaCalculatorScreen extends StatefulWidget {
  final StorageService storage;
  const CgpaCalculatorScreen({super.key, required this.storage});

  @override
  State<CgpaCalculatorScreen> createState() => _CgpaCalculatorScreenState();
}

class _CgpaCalculatorScreenState extends State<CgpaCalculatorScreen> {
  // Target CGPA estimation fields
  final _targetCgpaController = TextEditingController(text: '8.5');
  final _nextCreditsController = TextEditingController(text: '22');

  @override
  void dispose() {
    _targetCgpaController.dispose();
    _nextCreditsController.dispose();
    super.dispose();
  }

  void _shareAcademicReport(double cgpa, double totalCredits, List<Semester> semesters) {
    if (!widget.storage.isProStudent) {
      showFeatureLockedDialog(
        context,
        featureTitle: 'Export Academic Report 📄',
        requiredPlanTitle: 'PRO STUDENT (₹89)',
        description: 'Generating and exporting formatted academic performance transcripts is a Pro Student feature.\n\nUpgrade to Pro Student to export and share official academic summaries!',
        storage: widget.storage,
        planPrice: '₹89',
      );
      return;
    }
    HapticFeedback.lightImpact();
    final buffer = StringBuffer();
    buffer.writeln('🎓 Student Academic Performance Report');
    buffer.writeln('---------------------------------------');
    buffer.writeln('Student: ${widget.storage.userName}');
    buffer.writeln('Cumulative CGPA: ${cgpa > 0 ? cgpa.toStringAsFixed(2) : "N/A"}');
    buffer.writeln('Total Credits Earned: ${totalCredits.toStringAsFixed(1)}');
    buffer.writeln('Semesters Recorded: ${semesters.length}');
    buffer.writeln('');
    for (var s in semesters) {
      buffer.writeln('• ${s.name}: ${s.sgpa.toStringAsFixed(2)} SGPA (${s.totalCredits} credits)');
    }
    buffer.writeln('---------------------------------------');
    buffer.writeln('Generated via Student Utility Hub 🚀');

    Share.share(buffer.toString());
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final semesters = widget.storage.semesters;
    final cgpa = widget.storage.calculateCumulativeCGPA();

    double totalCredits = 0;
    for (var s in semesters) {
      totalCredits += s.totalCredits;
    }

    // Target SGPA calculation:
    // Target CGPA = (CurrentTotalPoints + NextSGPA * NextCredits) / (TotalCredits + NextCredits)
    // NextSGPA = (TargetCGPA * (TotalCredits + NextCredits) - CurrentTotalPoints) / NextCredits
    final targetCgpa = double.tryParse(_targetCgpaController.text) ?? 8.5;
    final nextCredits = double.tryParse(_nextCreditsController.text) ?? 20.0;
    final currentPoints = cgpa * totalCredits;
    double? requiredNextSgpa;
    if (nextCredits > 0) {
      requiredNextSgpa = (targetCgpa * (totalCredits + nextCredits) - currentPoints) / nextCredits;
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('CGPA Calculator 🎓'),
        actions: [
          IconButton(
            icon: const Icon(Icons.share_outlined),
            tooltip: 'Share Academic Report',
            onPressed: () => _shareAcademicReport(cgpa, totalCredits, semesters),
          ),
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: 'Add Quick Semester',
            onPressed: () => _showQuickAddSemesterDialog(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Cumulative CGPA Card
            CustomCard(
              gradient: const LinearGradient(
                colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              child: Column(
                children: [
                  const Text(
                    'CUMULATIVE CGPA',
                    style: TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.bold, letterSpacing: 1.2),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    cgpa > 0 ? cgpa.toStringAsFixed(2) : '--',
                    style: const TextStyle(fontSize: 52, fontWeight: FontWeight.w900, color: Colors.white),
                  ),
                  Text(
                    '${semesters.length} Semesters Recorded • Total Credits: ${totalCredits.toStringAsFixed(1)}',
                    style: const TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: AppColors.primary,
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => SgpaCalculatorScreen(storage: widget.storage)),
                      );
                    },
                    icon: const Icon(Icons.calculate, size: 18),
                    label: const Text('Calculate New SGPA'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Target CGPA Planner Card
            CustomCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.flag_outlined, color: AppColors.primary, size: 20),
                      const SizedBox(width: 8),
                      const Text('Target CGPA Planner', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _targetCgpaController,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          decoration: const InputDecoration(labelText: 'Target CGPA'),
                          onChanged: (_) => setState(() {}),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextField(
                          controller: _nextCreditsController,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          decoration: const InputDecoration(labelText: 'Next Sem Credits'),
                          onChanged: (_) => setState(() {}),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  if (requiredNextSgpa != null)
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: (requiredNextSgpa > 10.0 || requiredNextSgpa < 0)
                            ? AppColors.error.withValues(alpha: 0.1)
                            : AppColors.success.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        requiredNextSgpa > 10.0
                            ? '⚠️ Target $targetCgpa requires ${requiredNextSgpa.toStringAsFixed(2)} SGPA (exceeds max 10.0 scale).'
                            : '🎯 You need an SGPA of ${requiredNextSgpa.toStringAsFixed(2)} in your next semester with $nextCredits credits to reach $targetCgpa CGPA.',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                          color: (requiredNextSgpa > 10.0 || requiredNextSgpa < 0) ? AppColors.error : AppColors.success,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Semesters List
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Saved Semesters', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                Text('${semesters.length} total', style: TextStyle(color: isDark ? AppColors.darkSubtext : AppColors.lightSubtext)),
              ],
            ),
            const SizedBox(height: 8),

            if (semesters.isEmpty)
              CustomCard(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Center(
                    child: Text(
                      'No semesters saved yet.\nTap "Calculate New SGPA" or "+" to record your first semester.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: isDark ? AppColors.darkSubtext : AppColors.lightSubtext),
                    ),
                  ),
                ),
              )
            else
              ...semesters.map((s) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: CustomCard(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(s.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                            const SizedBox(height: 4),
                            Text(
                              '${s.subjects.length} subjects • ${s.totalCredits} credits',
                              style: TextStyle(fontSize: 12, color: isDark ? AppColors.darkSubtext : AppColors.lightSubtext),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: AppColors.primary.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                '${s.sgpa.toStringAsFixed(2)} SGPA',
                                style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete_outline, size: 20, color: Colors.grey),
                              onPressed: () async {
                                final confirmed = await showConfirmDeleteDialog(
                                  context,
                                  title: 'Delete Semester?',
                                  message: 'Are you sure you want to delete "${s.name}"? This cannot be undone.',
                                );
                                if (confirmed) {
                                  widget.storage.deleteSemester(s.id);
                                }
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              }),

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

  void _showQuickAddSemesterDialog(BuildContext context) {
    if (!widget.storage.isProStudent && widget.storage.semesters.length >= widget.storage.maxSavedSemesters) {
      final isRemoveAds = widget.storage.currentPlan == UserPlan.removeAds;
      showFeatureLockedDialog(
        context,
        featureTitle: 'Unlimited Saved Semesters 📚',
        requiredPlanTitle: 'GOLD PLAN (₹89)',
        description: isRemoveAds
            ? 'You have reached the 4 saved semesters cap on your Silver Plan (₹39).\n\nUpgrade to Gold Plan (+₹50) to unlock unlimited semesters and multi-year CGPA calculations!'
            : 'You have reached the 2 saved semesters limit on the Free tier.\n\nUpgrade to Gold Plan (₹89) or Silver Plan (₹39 - capped at 4 semesters) to save more semesters!',
        storage: widget.storage,
        planPrice: '₹89',
      );
      return;
    }

    final nameCtrl = TextEditingController(text: 'Semester ${widget.storage.semesters.length + 1}');
    final sgpaCtrl = TextEditingController(text: '8.2');
    final creditsCtrl = TextEditingController(text: '22');

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Add Semester Entry'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Semester Name')),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(child: TextField(controller: sgpaCtrl, decoration: const InputDecoration(labelText: 'SGPA (e.g. 8.2)'), keyboardType: const TextInputType.numberWithOptions(decimal: true))),
                const SizedBox(width: 10),
                Expanded(child: TextField(controller: creditsCtrl, decoration: const InputDecoration(labelText: 'Credits (e.g. 22)'), keyboardType: const TextInputType.numberWithOptions(decimal: true))),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              final s = Semester(
                id: const Uuid().v4(),
                name: nameCtrl.text.trim(),
                subjects: [],
                sgpa: double.tryParse(sgpaCtrl.text) ?? 8.0,
                totalCredits: double.tryParse(creditsCtrl.text) ?? 20.0,
              );
              widget.storage.saveSemester(s);
              Navigator.pop(ctx);
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }
}
