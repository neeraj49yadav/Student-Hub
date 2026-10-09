import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';
import '../core/widgets/common_widgets.dart';
import '../core/services/storage_service.dart';
import 'assignments/assignments_screen.dart';
import 'checklist/checklist_screen.dart';
import 'notes/notes_screen.dart';

class TasksHubScreen extends StatelessWidget {
  final StorageService storage;
  const TasksHubScreen({super.key, required this.storage});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final pendingAssignments = storage.assignments.where((a) => !a.isCompleted).length;
    final pendingTasks = storage.checklist.where((t) => !t.isCompleted).length;
    final totalNotes = storage.notes.length;

    return Scaffold(
      appBar: AppBar(title: const Text('Tasks, To-Dos & Notes 📝')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Humanized Motivational Pulse
          const MotivationalPulseBadge(
            emoji: '✅',
            title: 'Clear Mind, High Focus',
            subtitle: 'Unload deadlines and assignments from your head into your hub.',
            accentColor: AppColors.secondary,
          ),
          const SizedBox(height: 14),

          // Assignments Card
          CustomCard(
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => AssignmentsScreen(storage: storage))),
            child: Row(
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(color: AppColors.error.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(14)),
                  child: const Icon(Icons.assignment_late_outlined, color: AppColors.error, size: 28),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Assignments Tracker', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(color: AppColors.error.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(6)),
                            child: Text(
                              '$pendingAssignments Pending',
                              style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.error),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Track college assignments, submission deadlines & priorities',
                        style: TextStyle(fontSize: 12, color: isDark ? AppColors.darkSubtext : AppColors.lightSubtext),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(Icons.chevron_right, color: Colors.grey),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Checklist Card
          CustomCard(
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ChecklistScreen(storage: storage))),
            child: Row(
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(color: AppColors.success.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(14)),
                  child: const Icon(Icons.checklist_rtl_outlined, color: AppColors.success, size: 28),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('To-Do Checklist', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(color: AppColors.success.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(6)),
                            child: Text(
                              '$pendingTasks Left',
                              style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.success),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Daily action items categorized into Study, College & Exams',
                        style: TextStyle(fontSize: 12, color: isDark ? AppColors.darkSubtext : AppColors.lightSubtext),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(Icons.chevron_right, color: Colors.grey),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Notes Card
          CustomCard(
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => NotesScreen(storage: storage))),
            child: Row(
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(color: AppColors.secondary.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(14)),
                  child: const Icon(Icons.menu_book_outlined, color: AppColors.secondary, size: 28),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Quick Notes & Tags', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(color: AppColors.secondary.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(6)),
                            child: Text(
                              '$totalNotes Saved',
                              style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.secondary),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Jot formulas, revision pointers, pin notes & search tags',
                        style: TextStyle(fontSize: 12, color: isDark ? AppColors.darkSubtext : AppColors.lightSubtext),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(Icons.chevron_right, color: Colors.grey),
              ],
            ),
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
}
