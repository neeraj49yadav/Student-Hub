import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';
import '../core/widgets/common_widgets.dart';
import '../core/services/storage_service.dart';
import 'timetable/timetable_screen.dart';
import 'pomodoro/pomodoro_screen.dart';
import 'exam/exam_countdown_screen.dart';
import 'progress/progress_screen.dart';
import 'premium/premium_screen.dart';

class StudyHubScreen extends StatelessWidget {
  final StorageService storage;
  const StudyHubScreen({super.key, required this.storage});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final totalFocus = storage.getTodayFocusMinutes();
    final exams = storage.exams;
    final timetableCount = storage.timetableSlots.length;

    return Scaffold(
      appBar: AppBar(title: const Text('Study Suite & Routines 📚')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Humanized Motivational Pulse
          MotivationalPulseBadge(
            emoji: '🎯',
            title: 'Study Flow & Consistency',
            subtitle: 'Short daily focus blocks beat intense all-nighters every time.',
            accentColor: AppColors.primary,
          ),
          const SizedBox(height: 14),

          // Pomodoro Feature Banner
          CustomCard(
            gradient: LinearGradient(
              colors: [AppColors.primary, AppColors.primaryDark],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => PomodoroScreen(storage: storage))),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('FOCUS TIMER', style: TextStyle(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
                      const SizedBox(height: 4),
                      const Text('Pomodoro Study Timer', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 6),
                      Text("Today's focus: ${totalFocus ~/ 60}h ${totalFocus % 60}m", style: const TextStyle(color: Colors.white70, fontSize: 13)),
                      const SizedBox(height: 12),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.white, foregroundColor: AppColors.primary),
                        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => PomodoroScreen(storage: storage))),
                        child: const Text('Start Focus Session ▶'),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.timer_outlined, size: 80, color: Colors.white24),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // Timetable Card
          _buildHubCard(
            context,
            title: 'Class Timetable',
            subtitle: '$timetableCount periods scheduled across the week',
            badge: 'Weekly Mon-Sun',
            icon: Icons.calendar_month,
            color: const Color(0xFF10B981),
            isDark: isDark,
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => TimetableScreen(storage: storage))),
          ),
          const SizedBox(height: 12),

          // Exam Countdown Card
          _buildHubCard(
            context,
            title: 'Exam Countdown',
            subtitle: '${exams.length} upcoming exams tracked with syllabus units',
            badge: exams.isNotEmpty ? 'Next: ${exams.first.subject}' : 'No Exams',
            icon: Icons.local_fire_department,
            color: const Color(0xFFEF4444),
            isDark: isDark,
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ExamCountdownScreen(storage: storage))),
          ),
          const SizedBox(height: 12),

          // Academic Progress & Statistics Card
          _buildHubCard(
            context,
            title: 'Progress & Statistics',
            subtitle: 'Interactive weekly bar graph, Pomodoro counts & attendance',
            badge: 'Analytics',
            icon: Icons.bar_chart,
            color: const Color(0xFF8B5CF6),
            isDark: isDark,
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ProgressScreen(storage: storage))),
          ),
          const SizedBox(height: 12),

          // AI Study Assistant Card (Lifetime Ultimate Feature - Coming Soon)
          _buildHubCard(
            context,
            title: 'AI Study Assistant',
            subtitle: 'Offline AI tutor, doubt solver & exam paper generator',
            badge: 'COMING SOON (₹149)',
            icon: Icons.auto_awesome,
            color: const Color(0xFFF59E0B),
            isDark: isDark,
            onTap: () => _showAiAssistantInfo(context),
          ),

          const SizedBox(height: 18),
          // Google Play Console Compliant Ad Placement
          GooglePlayCompliantAdBanner(
            isPro: storage.isProUser,
            format: GooglePlayAdFormat.nativeCard,
          ),
        ],
      ),
    );
  }

  Widget _buildHubCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required String badge,
    required IconData icon,
    required Color color,
    required bool isDark,
    required VoidCallback onTap,
  }) {
    return CustomCard(
      onTap: onTap,
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(color: color.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(14)),
            child: Icon(icon, color: color, size: 26),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(color: color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(6)),
                      child: Text(badge, style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: color)),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(subtitle, style: TextStyle(fontSize: 12, color: isDark ? AppColors.darkSubtext : AppColors.lightSubtext)),
              ],
            ),
          ),
          const SizedBox(width: 8),
          const Icon(Icons.chevron_right, color: Colors.grey),
        ],
      ),
    );
  }

  void _showAiAssistantInfo(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: const [
            Icon(Icons.auto_awesome, color: Color(0xFFF59E0B), size: 24),
            SizedBox(width: 8),
            Text('AI Study Assistant 🤖'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [Color(0xFFF59E0B), Color(0xFFD97706)]),
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Text('LIFETIME ULTIMATE (₹149)', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 12),
            const Text(
              'Our on-device AI Study Assistant is launching in the upcoming Lifetime Ultimate Plan.\n\nKey features in development:\n• Smart doubt clearing for engineering & college courses\n• Instant lecture note summarization\n• Practice exam question generator\n\nStay tuned for the V2 release!',
              style: TextStyle(fontSize: 14, height: 1.4),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Got It')),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.push(context, MaterialPageRoute(builder: (_) => PremiumScreen(storage: storage)));
            },
            child: const Text('View Plans'),
          ),
        ],
      ),
    );
  }
}
