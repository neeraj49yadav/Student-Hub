import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/common_widgets.dart';

class PercentageCalculatorScreen extends StatefulWidget {
  final bool isPro;
  const PercentageCalculatorScreen({super.key, required this.isPro});

  @override
  State<PercentageCalculatorScreen> createState() => _PercentageCalculatorScreenState();
}

class _PercentageCalculatorScreenState extends State<PercentageCalculatorScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Tab 1: Basic
  final _obtainedController = TextEditingController(text: '425');
  final _totalMarksController = TextEditingController(text: '500');

  // Tab 2: Required Marks Target
  final _curMarksController = TextEditingController(text: '280');
  final _curMaxController = TextEditingController(text: '400');
  final _finalMaxController = TextEditingController(text: '100');
  final _targetPctController = TextEditingController(text: '75');

  // Tab 3: CGPA <-> Percentage
  final _cgpaController = TextEditingController(text: '8.4');
  final _pctFromCgpaController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _obtainedController.dispose();
    _totalMarksController.dispose();
    _curMarksController.dispose();
    _curMaxController.dispose();
    _finalMaxController.dispose();
    _targetPctController.dispose();
    _cgpaController.dispose();
    _pctFromCgpaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Percentage Calculator 🔢'),
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primary,
          unselectedLabelColor: isDark ? AppColors.darkSubtext : AppColors.lightSubtext,
          indicatorColor: AppColors.primary,
          tabs: const [
            Tab(text: 'Basic %'),
            Tab(text: 'Target Solver'),
            Tab(text: 'CGPA ↔ %'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildBasicTab(isDark),
          _buildTargetSolverTab(isDark),
          _buildCgpaConverterTab(isDark),
        ],
      ),
    );
  }

  Widget _buildBasicTab(bool isDark) {
    final obtained = double.tryParse(_obtainedController.text) ?? 0;
    final total = double.tryParse(_totalMarksController.text) ?? 1;
    final pct = total > 0 ? (obtained / total) * 100 : 0.0;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          CustomCard(
            color: AppColors.primary.withValues(alpha: isDark ? 0.2 : 0.1),
            child: Column(
              children: [
                const Text('PERCENTAGE', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, letterSpacing: 1.2)),
                const SizedBox(height: 6),
                Text(
                  '${pct.toStringAsFixed(2)}%',
                  style: TextStyle(fontSize: 48, fontWeight: FontWeight.w900, color: AppColors.primary),
                ),
                Text('$obtained out of $total marks', style: TextStyle(color: isDark ? AppColors.darkSubtext : AppColors.lightSubtext)),
              ],
            ),
          ),
          const SizedBox(height: 16),
          CustomCard(
            child: Column(
              children: [
                TextField(
                  controller: _obtainedController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(labelText: 'Obtained Marks', prefixIcon: Icon(Icons.check)),
                  onChanged: (_) => setState(() {}),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _totalMarksController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(labelText: 'Total Maximum Marks', prefixIcon: Icon(Icons.format_list_numbered)),
                  onChanged: (_) => setState(() {}),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          GooglePlayCompliantAdBanner(isPro: widget.isPro),
        ],
      ),
    );
  }

  Widget _buildTargetSolverTab(bool isDark) {
    final curMarks = double.tryParse(_curMarksController.text) ?? 0;
    final curMax = double.tryParse(_curMaxController.text) ?? 0;
    final finalMax = double.tryParse(_finalMaxController.text) ?? 0;
    final targetPct = double.tryParse(_targetPctController.text) ?? 75;

    // Target marks formula:
    // Total future max = curMax + finalMax
    // Required overall marks = (targetPct / 100) * totalFutureMax
    // Marks needed in final = Required overall marks - curMarks
    final totalFutureMax = curMax + finalMax;
    final neededOverall = (targetPct / 100.0) * totalFutureMax;
    final neededInFinal = neededOverall - curMarks;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          CustomCard(
            color: (neededInFinal <= finalMax && neededInFinal >= 0)
                ? AppColors.success.withValues(alpha: isDark ? 0.2 : 0.1)
                : AppColors.error.withValues(alpha: isDark ? 0.2 : 0.1),
            child: Column(
              children: [
                const Text('REQUIRED MARKS IN UPCOMING EXAM', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, letterSpacing: 1.1)),
                const SizedBox(height: 6),
                Text(
                  neededInFinal > 0 ? neededInFinal.toStringAsFixed(1) : '0',
                  style: TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.w900,
                    color: (neededInFinal <= finalMax && neededInFinal >= 0) ? AppColors.success : AppColors.error,
                  ),
                ),
                Text(
                  neededInFinal > finalMax
                      ? '⚠️ Impossible: You need ${neededInFinal.toStringAsFixed(1)} out of $finalMax marks.'
                      : 'You need ${neededInFinal.toStringAsFixed(1)} / $finalMax marks to reach $targetPct%.',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          CustomCard(
            child: Column(
              children: [
                TextField(
                  controller: _curMarksController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(labelText: 'Current Marks Scored So Far'),
                  onChanged: (_) => setState(() {}),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _curMaxController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(labelText: 'Current Total Max Marks'),
                  onChanged: (_) => setState(() {}),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _finalMaxController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(labelText: 'Upcoming Exam Max Marks'),
                  onChanged: (_) => setState(() {}),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _targetPctController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(labelText: 'Target Overall Percentage (%)'),
                  onChanged: (_) => setState(() {}),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          GooglePlayCompliantAdBanner(isPro: widget.isPro),
        ],
      ),
    );
  }

  Widget _buildCgpaConverterTab(bool isDark) {
    final cgpaVal = double.tryParse(_cgpaController.text) ?? 0;
    // Standard CBSE / AICTE formula: % = CGPA * 9.5
    final calculatedPct = cgpaVal * 9.5;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          CustomCard(
            color: AppColors.secondary.withValues(alpha: isDark ? 0.2 : 0.1),
            child: Column(
              children: [
                const Text('ESTIMATED PERCENTAGE', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, letterSpacing: 1.2)),
                const SizedBox(height: 6),
                Text(
                  '${calculatedPct.toStringAsFixed(2)}%',
                  style: const TextStyle(fontSize: 48, fontWeight: FontWeight.w900, color: AppColors.secondary),
                ),
                const Text('Based on Standard AICTE/CBSE Formula (CGPA × 9.5)', style: TextStyle(fontSize: 12)),
              ],
            ),
          ),
          const SizedBox(height: 16),
          CustomCard(
            child: TextField(
              controller: _cgpaController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                labelText: 'Enter CGPA (e.g., 8.4)',
                prefixIcon: Icon(Icons.school_outlined),
              ),
              onChanged: (_) => setState(() {}),
            ),
          ),
          const SizedBox(height: 16),
          GooglePlayCompliantAdBanner(isPro: widget.isPro),
        ],
      ),
    );
  }
}
