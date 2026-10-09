import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/common_widgets.dart';

class ExamPassingCalculatorScreen extends StatefulWidget {
  final bool isPro;
  const ExamPassingCalculatorScreen({super.key, required this.isPro});

  @override
  State<ExamPassingCalculatorScreen> createState() => _ExamPassingCalculatorScreenState();
}

class _ExamPassingCalculatorScreenState extends State<ExamPassingCalculatorScreen> {
  final _internalScoredCtrl = TextEditingController(text: '22');
  final _internalMaxCtrl = TextEditingController(text: '30');
  final _externalMaxCtrl = TextEditingController(text: '70');
  final _overallPassingPctCtrl = TextEditingController(text: '40');
  final _externalPassingPctCtrl = TextEditingController(text: '35');

  @override
  void dispose() {
    _internalScoredCtrl.dispose();
    _internalMaxCtrl.dispose();
    _externalMaxCtrl.dispose();
    _overallPassingPctCtrl.dispose();
    _externalPassingPctCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final internalScored = double.tryParse(_internalScoredCtrl.text) ?? 0.0;
    final internalMax = double.tryParse(_internalMaxCtrl.text) ?? 30.0;
    final externalMax = double.tryParse(_externalMaxCtrl.text) ?? 70.0;
    final overallPassPct = double.tryParse(_overallPassingPctCtrl.text) ?? 40.0;
    final extPassPct = double.tryParse(_externalPassingPctCtrl.text) ?? 35.0;

    final totalMarks = internalMax + externalMax;
    final totalMarksNeededOverall = (overallPassPct / 100.0) * totalMarks;
    final marksNeededForOverall = totalMarksNeededOverall - internalScored;
    final marksNeededForExternalRule = (extPassPct / 100.0) * externalMax;

    // Must satisfy BOTH conditions:
    // 1. External exam score >= marksNeededForExternalRule
    // 2. Internal + External >= totalMarksNeededOverall
    double finalRequiredExternal = marksNeededForOverall > marksNeededForExternalRule
        ? marksNeededForOverall
        : marksNeededForExternalRule;

    if (finalRequiredExternal < 0) finalRequiredExternal = 0;

    final isPossible = finalRequiredExternal <= externalMax;
    final requiredPercentageInExternal = externalMax > 0 ? (finalRequiredExternal / externalMax) * 100 : 0.0;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Passing Marks Solver 🎯'),
        actions: [
          IconButton(
            icon: const Icon(Icons.share_outlined),
            tooltip: 'Share Calculation',
            onPressed: () {
              final shareText = '''
🎯 Exam Passing Marks Calculation:
• Internal Scored: $internalScored / $internalMax
• External Exam: Out of $externalMax
• Minimum Marks Needed to Pass: ${finalRequiredExternal.toStringAsFixed(1)} / $externalMax (${requiredPercentageInExternal.toStringAsFixed(1)}%)
• Status: ${isPossible ? "Achievable ✅" : "Critical Warning ⚠️"}

Calculated with Student Utility Hub 🎓
''';
              Share.share(shareText);
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Result Highlight Card
            CustomCard(
              color: isPossible ? AppColors.success.withValues(alpha: 0.12) : AppColors.error.withValues(alpha: 0.12),
              border: Border.all(color: isPossible ? AppColors.success : AppColors.error, width: 2),
              child: Column(
                children: [
                  const Text('MINIMUM EXTERNAL MARKS NEEDED', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, letterSpacing: 1.1)),
                  const SizedBox(height: 6),
                  Text(
                    finalRequiredExternal.toStringAsFixed(1),
                    style: TextStyle(
                      fontSize: 52,
                      fontWeight: FontWeight.w900,
                      color: isPossible ? AppColors.success : AppColors.error,
                    ),
                  ),
                  Text(
                    'Out of $externalMax marks (${requiredPercentageInExternal.toStringAsFixed(1)}%)',
                    style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                  ),
                  const Divider(height: 24),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    decoration: BoxDecoration(
                      color: isPossible
                          ? AppColors.success.withValues(alpha: isDark ? 0.2 : 0.08)
                          : AppColors.error.withValues(alpha: isDark ? 0.2 : 0.08),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: isPossible
                            ? AppColors.success.withValues(alpha: 0.3)
                            : AppColors.error.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Text(
                      isPossible
                          ? '✅ You need at least ${finalRequiredExternal.toStringAsFixed(1)} marks in your semester external exam to clear this course without backlogs.'
                          : '⚠️ Math Alert: Your internals ($internalScored/$internalMax) are too low to clear the $overallPassPct% overall threshold even with 100% in externals.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        height: 1.4,
                        color: isPossible
                            ? (isDark ? const Color(0xFF6EE7B7) : const Color(0xFF065F46))
                            : (isDark ? const Color(0xFFFCA5A5) : const Color(0xFF991B1B)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Form Inputs
            CustomCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Enter Internal & Exam Pattern', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _internalScoredCtrl,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          decoration: const InputDecoration(labelText: 'Internals Scored'),
                          onChanged: (_) => setState(() {}),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextField(
                          controller: _internalMaxCtrl,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          decoration: const InputDecoration(labelText: 'Max Internals'),
                          onChanged: (_) => setState(() {}),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _externalMaxCtrl,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: const InputDecoration(labelText: 'External Semester Exam Max Marks (e.g. 70, 60, 100)'),
                    onChanged: (_) => setState(() {}),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _overallPassingPctCtrl,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          decoration: const InputDecoration(labelText: 'Overall Pass % (e.g. 40%)'),
                          onChanged: (_) => setState(() {}),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextField(
                          controller: _externalPassingPctCtrl,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          decoration: const InputDecoration(labelText: 'Min External % (e.g. 35%)'),
                          onChanged: (_) => setState(() {}),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // University Standard Presets
            CustomCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Standard University Presets', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      ActionChip(
                        label: const Text('30 Internals + 70 Externals (40% pass)'),
                        onPressed: () {
                          HapticFeedback.lightImpact();
                          setState(() {
                            _internalMaxCtrl.text = '30';
                            _externalMaxCtrl.text = '70';
                            _overallPassingPctCtrl.text = '40';
                            _externalPassingPctCtrl.text = '35';
                          });
                        },
                      ),
                      ActionChip(
                        label: const Text('40 Internals + 60 Externals (40% pass)'),
                        onPressed: () {
                          HapticFeedback.lightImpact();
                          setState(() {
                            _internalMaxCtrl.text = '40';
                            _externalMaxCtrl.text = '60';
                            _overallPassingPctCtrl.text = '40';
                            _externalPassingPctCtrl.text = '35';
                          });
                        },
                      ),
                      ActionChip(
                        label: const Text('20 Internals + 80 Externals (50% pass)'),
                        onPressed: () {
                          HapticFeedback.lightImpact();
                          setState(() {
                            _internalMaxCtrl.text = '20';
                            _externalMaxCtrl.text = '80';
                            _overallPassingPctCtrl.text = '50';
                            _externalPassingPctCtrl.text = '40';
                          });
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 18),
            GooglePlayCompliantAdBanner(
              isPro: widget.isPro,
              format: GooglePlayAdFormat.nativeCard,
            ),
          ],
        ),
      ),
    );
  }
}
