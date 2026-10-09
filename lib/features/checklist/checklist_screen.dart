import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/common_widgets.dart';
import '../../core/services/storage_service.dart';
import '../../shared/models/app_models.dart';
import 'package:uuid/uuid.dart';

class ChecklistScreen extends StatefulWidget {
  final StorageService storage;
  const ChecklistScreen({super.key, required this.storage});

  @override
  State<ChecklistScreen> createState() => _ChecklistScreenState();
}

class _ChecklistScreenState extends State<ChecklistScreen> {
  String _selectedCategory = 'All';
  final _quickTaskController = TextEditingController();

  final List<String> _categories = ['All', 'Study', 'College', 'Exams', 'Personal'];

  @override
  void dispose() {
    _quickTaskController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final allItems = widget.storage.checklist;
    final filtered = _selectedCategory == 'All'
        ? allItems
        : allItems.where((i) => i.category == _selectedCategory).toList();

    final completedCount = allItems.where((i) => i.isCompleted).length;
    final progressPct = allItems.isEmpty ? 0.0 : completedCount / allItems.length;

    return Scaffold(
      appBar: AppBar(title: const Text('To-Do Checklist ✅')),
      body: Column(
        children: [
          // Progress Summary Banner
          Container(
            padding: const EdgeInsets.all(16),
            color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Completed: $completedCount / ${allItems.length}',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                    Text(
                      '${(progressPct * 100).toInt()}%',
                      style: TextStyle(fontWeight: FontWeight.w900, color: AppColors.primary),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: LinearProgressIndicator(
                    value: progressPct,
                    minHeight: 8,
                    backgroundColor: isDark ? Colors.white10 : Colors.black12,
                    valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                  ),
                ),
              ],
            ),
          ),

          // Categories Filter
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: _categories.map((c) {
                final isSelected = _selectedCategory == c;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(c),
                    selected: isSelected,
                    selectedColor: AppColors.primary,
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.white : (isDark ? AppColors.darkText : AppColors.lightText),
                      fontWeight: FontWeight.w600,
                    ),
                    onSelected: (val) {
                      if (val) setState(() => _selectedCategory = c);
                    },
                  ),
                );
              }).toList(),
            ),
          ),

          // Task List
          Expanded(
            child: filtered.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(Icons.checklist, size: 48, color: Colors.grey),
                        SizedBox(height: 12),
                        Text('No tasks in this category!', style: TextStyle(fontWeight: FontWeight.bold)),
                        SizedBox(height: 4),
                        Text('Type below to add a quick to-do.', style: TextStyle(color: Colors.grey)),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    itemCount: filtered.length,
                    itemBuilder: (context, idx) {
                      final item = filtered[idx];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: CustomCard(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          child: ListTile(
                            contentPadding: EdgeInsets.zero,
                            leading: Checkbox(
                              value: item.isCompleted,
                              activeColor: AppColors.success,
                              onChanged: (_) {
                                HapticFeedback.lightImpact();
                                widget.storage.toggleChecklistItem(item.id);
                                widget.storage.recordStudyActivity();
                              },
                            ),
                            title: Text(
                              item.title,
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w500,
                                decoration: item.isCompleted ? TextDecoration.lineThrough : null,
                                color: item.isCompleted
                                    ? Colors.grey
                                    : (isDark ? AppColors.darkText : AppColors.lightText),
                              ),
                            ),
                            subtitle: Text(
                              item.category,
                              style: TextStyle(fontSize: 11, color: isDark ? AppColors.darkSubtext : AppColors.lightSubtext),
                            ),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete_outline, size: 20, color: Colors.grey),
                              onPressed: () async {
                                final confirmed = await showConfirmDeleteDialog(
                                  context,
                                  title: 'Delete Task?',
                                  message: 'Are you sure you want to delete "${item.title}"? This cannot be undone.',
                                );
                                if (confirmed) {
                                  widget.storage.deleteChecklistItem(item.id);
                                }
                              },
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),

          // Quick Add Input Box
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
              boxShadow: [
                BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, -2)),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _quickTaskController,
                    decoration: InputDecoration(
                      hintText: 'Add a task (e.g. Revise Chapter 4)...',
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      suffixIcon: IconButton(
                        icon: Icon(Icons.add_circle, color: AppColors.primary),
                        onPressed: _addQuickTask,
                      ),
                    ),
                    onSubmitted: (_) => _addQuickTask(),
                  ),
                ),
              ],
            ),
          ),
          GooglePlayCompliantAdBanner(isPro: widget.storage.isProUser),
        ],
      ),
    );
  }

  void _addQuickTask() {
    final text = _quickTaskController.text.trim();
    if (text.isNotEmpty) {
      final item = ChecklistItem(
        id: const Uuid().v4(),
        title: text,
        category: _selectedCategory == 'All' ? 'General' : _selectedCategory,
        isCompleted: false,
      );
      widget.storage.addChecklistItem(item);
      _quickTaskController.clear();
    }
  }
}
