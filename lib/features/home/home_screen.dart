import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/common_widgets.dart';
import '../../core/services/storage_service.dart';
import '../calculator/cgpa_calculator_screen.dart';
import '../calculator/attendance_calculator_screen.dart';
import '../pomodoro/pomodoro_screen.dart';
import '../exam/exam_countdown_screen.dart';
import '../assignments/assignments_screen.dart';
import '../calculator/exam_passing_calculator_screen.dart';
import '../timetable/timetable_screen.dart';
import '../notes/notes_screen.dart';
import '../tools_hub_screen.dart';
import '../expenses/campus_expense_screen.dart';

class HomeScreen extends StatelessWidget {
  final StorageService storage;
  final VoidCallback onNavigateToTools;
  final VoidCallback onNavigateToStudy;
  final VoidCallback onNavigateToTasks;

  const HomeScreen({
    super.key,
    required this.storage,
    required this.onNavigateToTools,
    required this.onNavigateToStudy,
    required this.onNavigateToTasks,
  });

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour >= 5 && hour < 12) return 'Good Morning';
    if (hour >= 12 && hour < 17) return 'Good Afternoon';
    if (hour >= 17 && hour < 22) return 'Good Evening';
    return 'Night Owl Hours';
  }

  String _getStudentWisdom() {
    final hour = DateTime.now().hour;
    if (hour >= 5 && hour < 12) {
      return '☀️ Fresh start! What are we conquering today?';
    } else if (hour >= 12 && hour < 17) {
      return '⚡ Stay energized through labs & lectures!';
    } else if (hour >= 17 && hour < 22) {
      return '☕ Wrap up today’s tasks & celebrate your wins!';
    } else {
      return '🌙 Late night revision? Remember sleep is key!';
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final todayMinutes = storage.getTodayFocusMinutes();
    final todayStudyHours = (todayMinutes / 60.0).toStringAsFixed(1);
    final pendingTasks = storage.checklist.where((t) => !t.isCompleted).length;

    // Upcoming assignments (earliest incomplete)
    final upcomingAssignments = storage.assignments.where((a) => !a.isCompleted).toList()
      ..sort((a, b) => a.dueDate.compareTo(b.dueDate));
    final nextAssignment = upcomingAssignments.isNotEmpty ? upcomingAssignments.first : null;

    // Upcoming exams
    final upcomingExams = List.from(storage.exams)..sort((a, b) => a.examDate.compareTo(b.examDate));
    final nextExam = upcomingExams.isNotEmpty ? upcomingExams.first : null;

    // Today's classes
    final todayWeekday = DateFormat('EEEE').format(DateTime.now());
    final todayClasses = storage.timetableSlots.where((s) => s.dayOfWeek == todayWeekday).toList()
      ..sort((a, b) => a.startTime.compareTo(b.startTime));
    final nextClass = todayClasses.isNotEmpty ? todayClasses.first : null;

    final cgpa = storage.calculateCumulativeCGPA();
    final attSubs = storage.attendanceSubjects;
    final totalAtt = attSubs.fold(0, (sum, s) => sum + s.attended + s.medicalLeaves);
    final totalClasses = attSubs.fold(0, (sum, s) => sum + s.total);
    final overallAttendance = totalClasses == 0 ? 0.0 : (totalAtt / totalClasses) * 100.0;

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  '${_getGreeting()}, ${storage.userName} 👋',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
              ],
            ),
            Text(
              DateFormat('EEEE, dd MMMM yyyy').format(DateTime.now()),
              style: TextStyle(fontSize: 12, color: isDark ? AppColors.darkSubtext : AppColors.lightSubtext),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search_rounded),
            tooltip: 'Search All Utilities',
            onPressed: () => _showSearchModal(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Humanized Daily Affirmation Banner
            Container(
              margin: const EdgeInsets.only(bottom: 14),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E293B) : const Color(0xFFEEF2F6),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: isDark ? Colors.white.withValues(alpha: 0.08) : Colors.black.withValues(alpha: 0.06),
                ),
              ),
              child: Row(
                children: [
                  const Text('🎓', style: TextStyle(fontSize: 18)),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      _getStudentWisdom(),
                      style: TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w600,
                        color: isDark ? const Color(0xFFE2E8F0) : const Color(0xFF334155),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Realistic Interactive Digital Student ID Card
            CustomCard(
              gradient: LinearGradient(
                colors: isDark
                    ? [
                        AppColors.darkSurfaceCard,
                        AppColors.darkBackground,
                      ]
                    : [
                        AppColors.primary.withValues(alpha: 0.12),
                        AppColors.lightSurfaceCard,
                      ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(7),
                              decoration: BoxDecoration(
                                color: AppColors.primary.withValues(alpha: 0.25),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(Icons.account_balance, color: AppColors.primaryLight, size: 20),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    storage.collegeName.toUpperCase(),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 11.5,
                                      fontWeight: FontWeight.w900,
                                      letterSpacing: 0.8,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const Text(
                                    'OFFICIAL STUDENT DIGITAL BADGE',
                                    style: TextStyle(
                                      color: Colors.white38,
                                      fontSize: 8.5,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 1.1,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.edit_note, color: Colors.white70, size: 22),
                        tooltip: 'Edit Student ID Card',
                        onPressed: () => _showEditProfileDialog(context),
                      ),
                    ],
                  ),
                  const Divider(color: Colors.white12, height: 20),
                  Row(
                    children: [
                      // Student Avatar Badge with Verified Status
                      Stack(
                        children: [
                          CircleAvatar(
                            radius: 28,
                            backgroundColor: AppColors.primary,
                            child: Text(
                              storage.userName.isNotEmpty ? storage.userName[0].toUpperCase() : 'S',
                              style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.white),
                            ),
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: Container(
                              padding: const EdgeInsets.all(2),
                              decoration: const BoxDecoration(
                                color: Colors.green,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.check, size: 12, color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              storage.userName,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Roll: ${storage.rollNumber} • ${storage.semesterName}',
                              style: const TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.w500),
                            ),
                            Text(
                              storage.degreeBranch,
                              style: const TextStyle(color: Colors.white54, fontSize: 11),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // Integrated Interactive Quick Stats (Tap to jump directly to tool)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.07),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.white12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        // CGPA Chip
                        InkWell(
                          borderRadius: BorderRadius.circular(8),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => CgpaCalculatorScreen(storage: storage)),
                            );
                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            child: Column(
                              children: [
                                const Text('CGPA ↗', style: TextStyle(color: Colors.white54, fontSize: 10, fontWeight: FontWeight.bold)),
                                const SizedBox(height: 2),
                                Text(
                                  cgpa > 0 ? cgpa.toStringAsFixed(2) : '--',
                                  style: const TextStyle(color: Colors.amberAccent, fontWeight: FontWeight.bold, fontSize: 14),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Container(width: 1, height: 26, color: Colors.white12),
                        // Attendance Chip
                        InkWell(
                          borderRadius: BorderRadius.circular(8),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => AttendanceCalculatorScreen(storage: storage)),
                            );
                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            child: Column(
                              children: [
                                const Text('ATTENDANCE ↗', style: TextStyle(color: Colors.white54, fontSize: 10, fontWeight: FontWeight.bold)),
                                const SizedBox(height: 2),
                                Text(
                                  '${overallAttendance.toStringAsFixed(1)}%',
                                  style: TextStyle(
                                    color: totalClasses == 0
                                        ? Colors.white70
                                        : (overallAttendance >= 75 ? Colors.greenAccent : Colors.redAccent),
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Container(width: 1, height: 26, color: Colors.white12),
                        // Streak Chip
                        InkWell(
                          borderRadius: BorderRadius.circular(8),
                          onTap: () => _showStreakDialog(context),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            child: Column(
                              children: [
                                const Text('STREAK 🔥', style: TextStyle(color: Colors.white54, fontSize: 10, fontWeight: FontWeight.bold)),
                                const SizedBox(height: 2),
                                Text(
                                  '${storage.studyStreak}d Active',
                                  style: const TextStyle(color: Colors.orangeAccent, fontWeight: FontWeight.bold, fontSize: 14),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Today's Productivity Card
            CustomCard(
              gradient: LinearGradient(
                colors: [AppColors.primary, AppColors.primaryDark],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: const [
                      Text(
                        "TODAY'S PRODUCTIVITY",
                        style: TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.1),
                      ),
                      Icon(Icons.insights, color: Colors.white70, size: 18),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      // Study Hours Mini Box
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('📚 Study Focus', style: TextStyle(color: Colors.white70, fontSize: 12)),
                              const SizedBox(height: 4),
                              Text('${todayStudyHours}h', style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Tasks Mini Box
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('📝 Tasks Remaining', style: TextStyle(color: Colors.white70, fontSize: 12)),
                              const SizedBox(height: 4),
                              Text('$pendingTasks Left', style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: AppColors.primary,
                      minimumSize: const Size(double.infinity, 44),
                      elevation: 0,
                    ),
                    onPressed: () {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => PomodoroScreen(storage: storage)));
                    },
                    icon: const Icon(Icons.play_arrow_rounded, size: 22),
                    label: const Text('Start Focus Session', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),

            // Smart Next Class Indicator
            if (nextClass != null) ...[
              CustomCard(
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => TimetableScreen(storage: storage))),
                border: Border(left: BorderSide(color: nextClass.isLunch ? Colors.amber.shade600 : AppColors.secondary, width: 5)),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: (nextClass.isLunch ? Colors.amber : AppColors.secondary).withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(nextClass.isLunch ? Icons.lunch_dining : Icons.school, color: nextClass.isLunch ? Colors.amber.shade700 : AppColors.secondary, size: 24),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                nextClass.isLunch ? 'LUNCH BREAK 🍱' : 'UPCOMING LECTURE',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: nextClass.isLunch ? Colors.amber.shade800 : AppColors.secondary,
                                  letterSpacing: 1.1,
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: AppColors.secondary.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  nextClass.startTime,
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: AppColors.secondary),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 3),
                          Text(nextClass.subject, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                          if (nextClass.room.isNotEmpty)
                            Text(
                              'Room ${nextClass.room}${nextClass.professorName.isNotEmpty ? " • Prof. ${nextClass.professorName}" : ""}',
                              style: const TextStyle(fontSize: 11.5, color: Colors.grey),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
            ],

            // Smart Next Exam Countdown
            if (nextExam != null) ...[
              CustomCard(
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ExamCountdownScreen(storage: storage))),
                border: const Border(left: BorderSide(color: AppColors.error, width: 5)),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.error.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.local_fire_department, color: AppColors.error, size: 24),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('🔥 NEXT EXAM', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.error, letterSpacing: 1.1)),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: AppColors.error.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  '${nextExam.daysRemaining}d REMAINING',
                                  style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.error),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 3),
                          Text(nextExam.subject, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                          Text(
                            DateFormat('dd MMMM yyyy').format(nextExam.examDate),
                            style: TextStyle(fontSize: 11.5, color: isDark ? AppColors.darkSubtext : AppColors.lightSubtext),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
            ],

            // Smart Next Assignment
            if (nextAssignment != null) ...[
              CustomCard(
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => AssignmentsScreen(storage: storage))),
                border: const Border(left: BorderSide(color: AppColors.warning, width: 5)),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.warning.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.assignment_outlined, color: AppColors.warning, size: 24),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('UPCOMING SUBMISSION', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.warning, letterSpacing: 1.1)),
                              Text(
                                DateFormat('dd MMM').format(nextAssignment.dueDate),
                                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.warning),
                              ),
                            ],
                          ),
                          const SizedBox(height: 3),
                          Text(nextAssignment.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                          Text(nextAssignment.subject, style: TextStyle(fontSize: 11.5, color: isDark ? AppColors.darkSubtext : AppColors.lightSubtext)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
            ],

            // Quick Tools Bar
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Quick Campus Tools ⚡', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                TextButton(
                  onPressed: onNavigateToTools,
                  child: const Text('View All'),
                ),
              ],
            ),
            const SizedBox(height: 8),

            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildQuickActionItem(
                    context,
                    title: 'CGPA',
                    icon: Icons.school,
                    color: const Color(0xFF4F46E5),
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => CgpaCalculatorScreen(storage: storage))),
                  ),
                  const SizedBox(width: 8),
                  _buildQuickActionItem(
                    context,
                    title: 'Attendance',
                    icon: Icons.co_present,
                    color: const Color(0xFF10B981),
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => AttendanceCalculatorScreen(storage: storage))),
                  ),
                  const SizedBox(width: 8),
                  _buildQuickActionItem(
                    context,
                    title: 'Pomodoro',
                    icon: Icons.timer,
                    color: const Color(0xFFF43F5E),
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => PomodoroScreen(storage: storage))),
                  ),
                  const SizedBox(width: 8),
                  _buildQuickActionItem(
                    context,
                    title: 'Passing',
                    icon: Icons.track_changes,
                    color: const Color(0xFF0EA5E9),
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ExamPassingCalculatorScreen(isPro: storage.isProUser))),
                  ),
                  const SizedBox(width: 8),
                  _buildQuickActionItem(
                    context,
                    title: 'Exams',
                    icon: Icons.local_fire_department,
                    color: const Color(0xFFF59E0B),
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ExamCountdownScreen(storage: storage))),
                  ),
                  const SizedBox(width: 8),
                  _buildQuickActionItem(
                    context,
                    title: 'Expenses',
                    icon: Icons.account_balance_wallet,
                    color: const Color(0xFF0D9488),
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => CampusExpenseScreen(storage: storage))),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Google Play Console Compliant Ad Section (Separated, clearly labeled)
            GooglePlayCompliantAdBanner(
              isPro: storage.isProUser,
              format: GooglePlayAdFormat.nativeCard,
            ),
          ],
        ),
      ),
    );
  }

  void _showStreakDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('🔥 Study Streak'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${storage.studyStreak} Day Habit Active!',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            const SizedBox(height: 8),
            const Text(
              'Complete at least one 25m Pomodoro study session or check off a task each day to maintain your streak.',
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.amber.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Row(
                children: [
                  Icon(Icons.emoji_events, color: Colors.amber),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Consistency is what differentiates top scholars from the rest!',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Keep Grinding!'),
          ),
        ],
      ),
    );
  }

  void _showEditProfileDialog(BuildContext context) {
    final nameCtrl = TextEditingController(text: storage.userName);
    final collegeCtrl = TextEditingController(text: storage.collegeName);
    final rollCtrl = TextEditingController(text: storage.rollNumber);
    final branchCtrl = TextEditingController(text: storage.degreeBranch);
    final semCtrl = TextEditingController(text: storage.semesterName);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Edit Student Identity Card 🪪'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameCtrl,
                decoration: const InputDecoration(labelText: 'Student Full Name'),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: collegeCtrl,
                decoration: const InputDecoration(labelText: 'College / University Name'),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: rollCtrl,
                      decoration: const InputDecoration(labelText: 'Roll / Registration No.'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      controller: semCtrl,
                      decoration: const InputDecoration(labelText: 'Semester (e.g. Sem 5)'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              TextField(
                controller: branchCtrl,
                decoration: const InputDecoration(labelText: 'Degree & Department (e.g. B.Tech CSE)'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              storage.updateCollegeProfile(
                name: nameCtrl.text.trim().isNotEmpty ? nameCtrl.text.trim() : null,
                college: collegeCtrl.text.trim().isNotEmpty ? collegeCtrl.text.trim() : null,
                rollNumber: rollCtrl.text.trim().isNotEmpty ? rollCtrl.text.trim() : null,
                degreeBranch: branchCtrl.text.trim().isNotEmpty ? branchCtrl.text.trim() : null,
                semesterName: semCtrl.text.trim().isNotEmpty ? semCtrl.text.trim() : null,
              );
              Navigator.pop(ctx);
            },
            child: const Text('Update Card'),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionItem(
    BuildContext context, {
    required String title,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return SizedBox(
      width: 86,
      child: CustomCard(
        onTap: onTap,
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 6),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(9),
              decoration: BoxDecoration(color: color.withValues(alpha: 0.15), shape: BoxShape.circle),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(height: 6),
            Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11.5),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  void _showSearchModal(BuildContext context) {
    showSearch(
      context: context,
      delegate: HubSearchDelegate(storage: storage),
    );
  }
}

class HubSearchDelegate extends SearchDelegate {
  final StorageService storage;
  HubSearchDelegate({required this.storage});

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      if (query.isNotEmpty)
        IconButton(
          icon: const Icon(Icons.clear),
          onPressed: () => query = '',
        ),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () => close(context, null),
    );
  }

  @override
  Widget buildResults(BuildContext context) => _buildSearchResults(context);

  @override
  Widget buildSuggestions(BuildContext context) => _buildSearchResults(context);

  Widget _buildSearchResults(BuildContext context) {
    final q = query.toLowerCase().trim();
    if (q.isEmpty) {
      return const Center(child: Text('Search calculators, timetable, notes, assignments...'));
    }

    // Match tools
    final matchedTools = ToolsHubScreen.allTools.where((t) {
      return t.title.toLowerCase().contains(q) || t.subtitle.toLowerCase().contains(q);
    }).toList();

    // Match notes
    final matchedNotes = storage.notes.where((n) {
      return n.title.toLowerCase().contains(q) || n.subject.toLowerCase().contains(q) || n.content.toLowerCase().contains(q);
    }).toList();

    // Match assignments
    final matchedAssignments = storage.assignments.where((a) {
      return a.title.toLowerCase().contains(q) || a.subject.toLowerCase().contains(q);
    }).toList();

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        if (matchedTools.isNotEmpty) ...[
          const Text('TOOLS & CALCULATORS', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, letterSpacing: 1.1)),
          const SizedBox(height: 8),
          ...matchedTools.map((t) => ListTile(
                leading: Icon(t.icon, color: t.color),
                title: Text(t.title),
                subtitle: Text(t.subtitle),
                onTap: () {
                  close(context, null);
                  Navigator.push(context, MaterialPageRoute(builder: (_) => t.screenBuilder(storage)));
                },
              )),
          const SizedBox(height: 16),
        ],
        if (matchedAssignments.isNotEmpty) ...[
          const Text('ASSIGNMENTS', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, letterSpacing: 1.1)),
          const SizedBox(height: 8),
          ...matchedAssignments.map((a) => ListTile(
                leading: Icon(Icons.assignment, color: AppColors.primary),
                title: Text(a.title),
                subtitle: Text('${a.subject} • Due ${DateFormat('dd MMM').format(a.dueDate)}'),
                onTap: () {
                  close(context, null);
                  Navigator.push(context, MaterialPageRoute(builder: (_) => AssignmentsScreen(storage: storage)));
                },
              )),
          const SizedBox(height: 16),
        ],
        if (matchedNotes.isNotEmpty) ...[
          const Text('NOTES', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, letterSpacing: 1.1)),
          const SizedBox(height: 8),
          ...matchedNotes.map((n) => ListTile(
                leading: const Icon(Icons.note, color: AppColors.secondary),
                title: Text(n.title),
                subtitle: Text(n.subject),
                onTap: () {
                  close(context, null);
                  Navigator.push(context, MaterialPageRoute(builder: (_) => NotesScreen(storage: storage)));
                },
              )),
        ],
        if (matchedTools.isEmpty && matchedAssignments.isEmpty && matchedNotes.isEmpty)
          const Padding(
            padding: EdgeInsets.all(32.0),
            child: Center(child: Text('No results matching query.')),
          ),
      ],
    );
  }
}
