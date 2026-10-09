import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/common_widgets.dart';
import '../../core/services/storage_service.dart';
import '../../shared/models/app_models.dart';
import '../premium/premium_screen.dart';
import 'package:uuid/uuid.dart';

class AttendanceCalculatorScreen extends StatefulWidget {
  final StorageService storage;
  const AttendanceCalculatorScreen({super.key, required this.storage});

  @override
  State<AttendanceCalculatorScreen> createState() => _AttendanceCalculatorScreenState();
}

class _AttendanceCalculatorScreenState extends State<AttendanceCalculatorScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Quick Calculator state
  final _totalController = TextEditingController(text: '50');
  final _attendedController = TextEditingController(text: '42');
  double _requiredPercentage = 75.0;

  // Vacation / Bunk Planner state
  final _bunkAttendedController = TextEditingController(text: '42');
  final _bunkTotalController = TextEditingController(text: '50');
  final _bunkCountController = TextEditingController(text: '4');

  // New Subject Dialog controllers
  final _subNameController = TextEditingController();
  final _subTotalController = TextEditingController(text: '40');
  final _subAttendedController = TextEditingController(text: '32');

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _totalController.dispose();
    _attendedController.dispose();
    _bunkAttendedController.dispose();
    _bunkTotalController.dispose();
    _bunkCountController.dispose();
    _subNameController.dispose();
    _subTotalController.dispose();
    _subAttendedController.dispose();
    super.dispose();
  }

  void _shareAttendanceSummary() {
    HapticFeedback.lightImpact();
    final subjects = widget.storage.attendanceSubjects;
    if (subjects.isEmpty) {
      Share.share('Student Utility Hub Attendance Tracker — Keep track of attendance and skip safely! 🎓');
      return;
    }

    int totalAttended = 0;
    int totalClasses = 0;
    final buffer = StringBuffer();
    buffer.writeln('📊 Student Attendance Summary');
    buffer.writeln('--------------------------------');

    for (var s in subjects) {
      totalAttended += s.attended;
      totalClasses += s.total;
      final status = s.percentage >= s.requiredPercentage
          ? '✅ ${s.percentage.toStringAsFixed(1)}% (Can skip ${s.skippableClasses})'
          : '⚠️ ${s.percentage.toStringAsFixed(1)}% (Need ${s.classesNeeded} classes)';
      buffer.writeln('• ${s.name}: ${s.attended}/${s.total} → $status');
    }

    final overall = totalClasses == 0 ? 0.0 : (totalAttended / totalClasses) * 100.0;
    buffer.writeln('--------------------------------');
    buffer.writeln('Overall Attendance: ${overall.toStringAsFixed(1)}%');
    buffer.writeln('Generated via Student Utility Hub 🎓');

    Share.share(buffer.toString());
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Attendance Suite 📊'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: 'Add Subject',
            onPressed: () => _showAddSubjectDialog(context),
          ),
          IconButton(
            icon: const Icon(Icons.share_outlined),
            tooltip: 'Share Attendance Summary',
            onPressed: _shareAttendanceSummary,
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primary,
          unselectedLabelColor: isDark ? AppColors.darkSubtext : AppColors.lightSubtext,
          indicatorColor: AppColors.primary,
          tabs: [
            const Tab(text: 'Quick Calc'),
            Tab(text: widget.storage.isProStudent ? 'Bunk Planner 🏖️' : 'Bunk Planner 🔒'),
            const Tab(text: 'My Subjects'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildQuickCalculator(isDark),
          _buildBunkPlanner(isDark),
          _buildSubjectTracker(isDark),
        ],
      ),
    );
  }

  Widget _buildQuickCalculator(bool isDark) {
    final total = int.tryParse(_totalController.text) ?? 0;
    final attended = int.tryParse(_attendedController.text) ?? 0;
    final currentPct = total > 0 ? (attended / total) * 100 : 0.0;
    final reqRatio = _requiredPercentage / 100.0;

    int skippable = 0;
    int needed = 0;

    if (total > 0 && reqRatio > 0 && reqRatio < 1) {
      if (currentPct >= _requiredPercentage) {
        skippable = ((attended - reqRatio * total) / reqRatio).floor();
        if (skippable < 0) skippable = 0;
      } else {
        needed = ((reqRatio * total - attended) / (1 - reqRatio)).ceil();
        if (needed < 0) needed = 0;
      }
    }

    final isSafe = currentPct >= _requiredPercentage;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          CustomCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Enter Class Numbers', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _attendedController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Attended Classes',
                          prefixIcon: Icon(Icons.check_circle_outline, color: AppColors.success),
                        ),
                        onChanged: (_) => setState(() {}),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        controller: _totalController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Total Classes',
                          prefixIcon: Icon(Icons.calendar_today_outlined),
                        ),
                        onChanged: (_) => setState(() {}),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Target Minimum: ${_requiredPercentage.toInt()}%', style: const TextStyle(fontWeight: FontWeight.w600)),
                    Row(
                      children: [75.0, 80.0, 85.0].map((pct) {
                        final selected = _requiredPercentage == pct;
                        return Padding(
                          padding: const EdgeInsets.only(left: 6),
                          child: ChoiceChip(
                            label: Text('${pct.toInt()}%'),
                            selected: selected,
                            onSelected: (val) {
                              if (val) {
                                HapticFeedback.lightImpact();
                                setState(() => _requiredPercentage = pct);
                              }
                            },
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Result Card
          CustomCard(
            color: isSafe ? AppColors.success.withValues(alpha: 0.12) : AppColors.error.withValues(alpha: 0.12),
            border: Border.all(color: isSafe ? AppColors.success : AppColors.error, width: 1.5),
            child: Column(
              children: [
                Text(
                  '${currentPct.toStringAsFixed(1)}%',
                  style: TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.w900,
                    color: isSafe ? AppColors.success : AppColors.error,
                  ),
                ),
                Text(
                  isSafe ? 'You are in the Safe Zone! 🎉' : 'Attendance Shortage Alert! ⚠️',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: isSafe ? AppColors.success : AppColors.error),
                ),
                const Divider(height: 24),
                if (isSafe)
                  Column(
                    children: [
                      const Text('Can I Skip Next Classes?', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                      const SizedBox(height: 4),
                      Text(
                        'You can miss $skippable class${skippable == 1 ? '' : 'es'} without falling below ${_requiredPercentage.toInt()}%.',
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
                      ),
                    ],
                  )
                else
                  Column(
                    children: [
                      const Text('Classes Needed to Recover', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                      const SizedBox(height: 4),
                      Text(
                        'You need to attend $needed consecutive class${needed == 1 ? '' : 'es'} to reach ${_requiredPercentage.toInt()}%.',
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
              ],
            ),
          ),
          const SizedBox(height: 18),

          GooglePlayCompliantAdBanner(
            isPro: widget.storage.isProUser,
            format: GooglePlayAdFormat.nativeCard,
          ),
        ],
      ),
    );
  }

  Widget _buildBunkPlanner(bool isDark) {
    if (!widget.storage.isProStudent) {
      return SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            CustomCard(
              gradient: LinearGradient(
                colors: isDark
                    ? [const Color(0xFF1E1B4B), const Color(0xFF311042)]
                    : [const Color(0xFFEEF2FF), const Color(0xFFFCE7F3)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              border: Border.all(color: AppColors.primary.withValues(alpha: 0.4), width: 1.5),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.lock_clock, size: 48, color: AppColors.primary),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Advanced Bunk Predictions 🏖️',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Simulate upcoming bunks, calculate precise recovery counts, and defend your attendance before skipping lectures.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 13,
                      color: isDark ? AppColors.darkSubtext : AppColors.lightSubtext,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 18),
                  _buildLockedBullet(Icons.check_circle_outline, 'Simulate "Can I bunk next 3 classes?" safely'),
                  _buildLockedBullet(Icons.check_circle_outline, 'Threshold defense calculations for college minimums (75%, 80%)'),
                  _buildLockedBullet(Icons.check_circle_outline, 'Consecutive recovery lecture projections'),
                  const SizedBox(height: 16),
                  if (widget.storage.currentPlan == UserPlan.removeAds)
                    Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.success.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppColors.success.withValues(alpha: 0.3)),
                      ),
                      child: Row(
                        children: const [
                          Icon(Icons.check_circle_outline, size: 16, color: AppColors.success),
                          SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              '₹39 Already Credited! Pay only +₹50 difference to unlock.',
                              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.success),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => PremiumScreen(storage: widget.storage)),
                      );
                    },
                    icon: const Icon(Icons.workspace_premium, size: 18),
                    label: Text(widget.storage.currentPlan == UserPlan.removeAds
                        ? 'Extend with Pro Student (+₹50)'
                        : 'Unlock with Pro Student (₹89)'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            GooglePlayCompliantAdBanner(isPro: widget.storage.isProUser),
          ],
        ),
      );
    }

    final curAttended = int.tryParse(_bunkAttendedController.text) ?? 0;
    final curTotal = int.tryParse(_bunkTotalController.text) ?? 1;
    final plannedBunk = int.tryParse(_bunkCountController.text) ?? 0;

    // Projected calculation:
    // If user skips plannedBunk classes, Attended stays same, Total increases by plannedBunk
    final newTotal = curTotal + plannedBunk;
    final newPct = newTotal > 0 ? (curAttended / newTotal) * 100 : 0.0;
    final isSafeAfterBunk = newPct >= _requiredPercentage;

    // Max safe bunks before dropping below required:
    final reqRatio = _requiredPercentage / 100.0;
    int maxSafeBunks = 0;
    if (reqRatio > 0) {
      maxSafeBunks = ((curAttended - reqRatio * curTotal) / reqRatio).floor();
      if (maxSafeBunks < 0) maxSafeBunks = 0;
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          CustomCard(
            color: isSafeAfterBunk ? AppColors.secondary.withValues(alpha: 0.12) : AppColors.error.withValues(alpha: 0.12),
            border: Border.all(color: isSafeAfterBunk ? AppColors.secondary : AppColors.error, width: 2),
            child: Column(
              children: [
                const Text('PROJECTED ATTENDANCE AFTER BUNK', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, letterSpacing: 1.1)),
                const SizedBox(height: 6),
                Text(
                  '${newPct.toStringAsFixed(1)}%',
                  style: TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.w900,
                    color: isSafeAfterBunk ? AppColors.secondary : AppColors.error,
                  ),
                ),
                Text(
                  isSafeAfterBunk ? 'Safe to Bunk! 🏖️' : 'Dangerous: Dropping Below ${_requiredPercentage.toInt()}%! ⚠️',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: isSafeAfterBunk ? AppColors.secondary : AppColors.error),
                ),
                const Divider(height: 20),
                Text(
                  'If you miss $plannedBunk classes, your attendance drops from ${((curAttended / curTotal) * 100).toStringAsFixed(1)}% down to ${newPct.toStringAsFixed(1)}%.',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 6),
                Text(
                  'Maximum classes you can safely bunk right now: $maxSafeBunks classes.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: isSafeAfterBunk ? AppColors.success : AppColors.error),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          CustomCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Plan Your Leave / Fest Absence', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _bunkAttendedController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(labelText: 'Attended Classes'),
                        onChanged: (_) => setState(() {}),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        controller: _bunkTotalController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(labelText: 'Total Classes'),
                        onChanged: (_) => setState(() {}),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _bunkCountController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Number of Classes Planned to Miss (Bunk / Sick Leave)',
                    prefixIcon: Icon(Icons.beach_access, color: AppColors.secondary),
                  ),
                  onChanged: (_) => setState(() {}),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          GooglePlayCompliantAdBanner(
            isPro: widget.storage.isProUser,
            format: GooglePlayAdFormat.nativeCard,
          ),
        ],
      ),
    );
  }

  Widget _buildSubjectTracker(bool isDark) {
    final subjects = widget.storage.attendanceSubjects;

    return Column(
      children: [
        Expanded(
          child: subjects.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.co_present, size: 48, color: Colors.grey),
                      const SizedBox(height: 12),
                      const Text('No subjects tracked yet', style: TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      const Text('Tap + at top or below to track daily attendance.', style: TextStyle(color: Colors.grey)),
                      const SizedBox(height: 14),
                      ElevatedButton.icon(
                        onPressed: () => _showAddSubjectDialog(context),
                        icon: const Icon(Icons.add),
                        label: const Text('Add Subject'),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
                  itemCount: subjects.length,
                  itemBuilder: (context, idx) {
                    final sub = subjects[idx];
                    final isSafe = sub.percentage >= sub.requiredPercentage;

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: CustomCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    sub.name,
                                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: (isSafe ? AppColors.success : AppColors.error).withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    '${sub.effectivePercentage.toStringAsFixed(1)}%',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: isSafe ? AppColors.success : AppColors.error,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '${sub.attended} attended / ${sub.total} total classes (Target: ${sub.requiredPercentage.toInt()}%)',
                              style: TextStyle(
                                fontSize: 13,
                                color: isDark ? AppColors.darkSubtext : AppColors.lightSubtext,
                              ),
                            ),
                            if (sub.medicalLeaves > 0) ...[
                              const SizedBox(height: 4),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: Colors.blue.withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  '🎖️ +${sub.medicalLeaves} Approved OD/Medical leaves (Raw: ${sub.percentage.toStringAsFixed(1)}%)',
                                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.blue),
                                ),
                              ),
                            ],
                        const SizedBox(height: 8),
                        Text(
                          isSafe
                              ? 'Can skip: ${sub.skippableClasses} classes'
                              : 'Need: ${sub.classesNeeded} more classes',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: isSafe ? AppColors.success : AppColors.error,
                          ),
                        ),
                        const Divider(height: 18),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Wrap(
                              spacing: 6,
                              children: [
                                OutlinedButton.icon(
                                  onPressed: () {
                                    HapticFeedback.lightImpact();
                                    widget.storage.updateAttendance(sub.id, sub.attended + 1, sub.total + 1);
                                  },
                                  icon: const Icon(Icons.check, size: 14, color: AppColors.success),
                                  label: const Text('+ Attended'),
                                  style: OutlinedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(horizontal: 8),
                                  ),
                                ),
                                OutlinedButton.icon(
                                  onPressed: () {
                                    HapticFeedback.lightImpact();
                                    widget.storage.updateAttendance(sub.id, sub.attended, sub.total + 1);
                                  },
                                  icon: const Icon(Icons.close, size: 14, color: AppColors.error),
                                  label: const Text('+ Missed'),
                                  style: OutlinedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(horizontal: 8),
                                  ),
                                ),
                                OutlinedButton.icon(
                                  onPressed: () {
                                    HapticFeedback.lightImpact();
                                    widget.storage.updateAttendance(
                                      sub.id,
                                      sub.attended,
                                      sub.total + 1,
                                      medicalLeaves: sub.medicalLeaves + 1,
                                    );
                                  },
                                  icon: const Icon(Icons.verified_outlined, size: 14, color: Colors.blue),
                                  label: const Text('+ OD/Med'),
                                  style: OutlinedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(horizontal: 8),
                                  ),
                                ),
                              ],
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete_outline, color: Colors.grey, size: 20),
                              onPressed: () async {
                                HapticFeedback.lightImpact();
                                final confirmed = await showConfirmDeleteDialog(
                                  context,
                                  title: 'Delete Subject?',
                                  message: 'Are you sure you want to delete "${sub.name}" attendance records? This cannot be undone.',
                                );
                                if (confirmed) {
                                  widget.storage.deleteAttendanceSubject(sub.id);
                                }
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
        ),
        GooglePlayCompliantAdBanner(isPro: widget.storage.isProUser),
      ],
    );
  }

  void _showAddSubjectDialog(BuildContext context) {
    _subNameController.clear();
    _subAttendedController.text = '25';
    _subTotalController.text = '30';
    final subOdController = TextEditingController(text: '0');

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Track New Subject'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _subNameController,
              decoration: const InputDecoration(labelText: 'Subject Name (e.g., Mathematics)'),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _subAttendedController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Attended'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: _subTotalController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Total'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: subOdController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'OD/Med'),
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              if (_subNameController.text.trim().isNotEmpty) {
                final newSub = AttendanceSubject(
                  id: const Uuid().v4(),
                  name: _subNameController.text.trim(),
                  attended: int.tryParse(_subAttendedController.text) ?? 0,
                  total: int.tryParse(_subTotalController.text) ?? 0,
                  medicalLeaves: int.tryParse(subOdController.text) ?? 0,
                  requiredPercentage: _requiredPercentage,
                );
                widget.storage.addAttendanceSubject(newSub);
                Navigator.pop(ctx);
              }
            },
            child: const Text('Add Subject'),
          ),
        ],
      ),
    );
  }

  Widget _buildLockedBullet(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, color: AppColors.success, size: 18),
          const SizedBox(width: 8),
          Expanded(child: Text(text, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500))),
        ],
      ),
    );
  }
}
