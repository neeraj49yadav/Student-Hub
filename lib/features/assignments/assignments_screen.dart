import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/common_widgets.dart';
import '../../core/services/storage_service.dart';
import '../../shared/models/app_models.dart';
import 'package:uuid/uuid.dart';

class AssignmentsScreen extends StatefulWidget {
  final StorageService storage;
  const AssignmentsScreen({super.key, required this.storage});

  @override
  State<AssignmentsScreen> createState() => _AssignmentsScreenState();
}

class _AssignmentsScreenState extends State<AssignmentsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final all = widget.storage.assignments;
    final inProgress = all.where((a) => a.status != 'Completed').toList();
    final completed = all.where((a) => a.status == 'Completed').toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Assignment Tracker 📝'),
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primary,
          unselectedLabelColor: isDark ? AppColors.darkSubtext : AppColors.lightSubtext,
          indicatorColor: AppColors.primary,
          tabs: [
            Tab(text: 'All (${all.length})'),
            Tab(text: 'Pending (${inProgress.length})'),
            Tab(text: 'Done (${completed.length})'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: 'Add Assignment',
            onPressed: () => _showAddAssignmentDialog(context),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildList(all, isDark),
                _buildList(inProgress, isDark),
                _buildList(completed, isDark),
              ],
            ),
          ),
          GooglePlayCompliantAdBanner(isPro: widget.storage.isProUser),
        ],
      ),
    );
  }

  Widget _buildList(List<Assignment> items, bool isDark) {
    if (items.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.assignment_turned_in, size: 48, color: Colors.grey),
            SizedBox(height: 12),
            Text('No assignments here!', style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(height: 4),
            Text('Stay ahead of college submission deadlines.', style: TextStyle(color: Colors.grey)),
          ],
        ),
      );
    }

    final sorted = List<Assignment>.from(items)..sort((a, b) => a.dueDate.compareTo(b.dueDate));

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
      itemCount: sorted.length,
      itemBuilder: (context, idx) {
        final item = sorted[idx];
        final now = DateTime.now();
        final days = item.dueDate.difference(DateTime(now.year, now.month, now.day)).inDays;

        String deadlineText;
        Color deadlineColor;

        if (item.isCompleted) {
          deadlineText = 'Completed';
          deadlineColor = AppColors.success;
        } else if (days < 0) {
          deadlineText = 'Overdue by ${-days}d';
          deadlineColor = AppColors.error;
        } else if (days == 0) {
          deadlineText = 'Due Today';
          deadlineColor = AppColors.error;
        } else if (days == 1) {
          deadlineText = 'Due Tomorrow';
          deadlineColor = AppColors.error;
        } else if (days <= 4) {
          deadlineText = 'Due in $days days';
          deadlineColor = AppColors.warning;
        } else {
          deadlineText = 'Due in $days days';
          deadlineColor = AppColors.success;
        }

        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: CustomCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: AppColors.primary.withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  item.subject,
                                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.primary),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: (item.priority == 'HIGH' ? AppColors.error : AppColors.secondary).withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  item.priority,
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: item.priority == 'HIGH' ? AppColors.error : AppColors.secondary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            item.title,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              decoration: item.isCompleted ? TextDecoration.lineThrough : null,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline, size: 20, color: Colors.grey),
                      onPressed: () async {
                        final confirmed = await showConfirmDeleteDialog(
                          context,
                          title: 'Delete Assignment?',
                          message: 'Are you sure you want to delete "${item.title}"? This cannot be undone.',
                        );
                        if (confirmed) {
                          widget.storage.deleteAssignment(item.id);
                        }
                      },
                    ),
                  ],
                ),
                if (item.description.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Text(
                    item.description,
                    style: TextStyle(fontSize: 13, color: isDark ? AppColors.darkSubtext : AppColors.lightSubtext),
                  ),
                ],
                const Divider(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.alarm, size: 16, color: deadlineColor),
                        const SizedBox(width: 4),
                        Text(
                          '$deadlineText (${DateFormat('dd MMM').format(item.dueDate)})',
                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: deadlineColor),
                        ),
                      ],
                    ),
                    TextButton.icon(
                      style: TextButton.styleFrom(
                        foregroundColor: item.isCompleted ? Colors.grey : AppColors.success,
                      ),
                      onPressed: () {
                        final updated = Assignment(
                          id: item.id,
                          title: item.title,
                          subject: item.subject,
                          description: item.description,
                          dueDate: item.dueDate,
                          priority: item.priority,
                          status: item.isCompleted ? 'In Progress' : 'Completed',
                        );
                        widget.storage.updateAssignment(updated);
                      },
                      icon: Icon(item.isCompleted ? Icons.undo : Icons.check_circle, size: 18),
                      label: Text(item.isCompleted ? 'Reopen' : 'Mark Done'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showAddAssignmentDialog(BuildContext context) {
    final titleCtrl = TextEditingController();
    final subCtrl = TextEditingController(text: 'DBMS');
    final descCtrl = TextEditingController();
    DateTime dueDate = DateTime.now().add(const Duration(days: 3));
    String priority = 'HIGH';

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Add Assignment'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(controller: titleCtrl, decoration: const InputDecoration(labelText: 'Assignment Title')),
                const SizedBox(height: 10),
                TextField(controller: subCtrl, decoration: const InputDecoration(labelText: 'Course / Subject')),
                const SizedBox(height: 10),
                TextField(controller: descCtrl, decoration: const InputDecoration(labelText: 'Description / Instructions')),
                const SizedBox(height: 12),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Deadline Date'),
                  subtitle: Text(DateFormat('dd MMMM yyyy').format(dueDate)),
                  trailing: Icon(Icons.calendar_month, color: AppColors.primary),
                  onTap: () async {
                    final d = await showDatePicker(
                      context: context,
                      initialDate: dueDate,
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 365)),
                    );
                    if (d != null) setDialogState(() => dueDate = d);
                  },
                ),
                Row(
                  children: ['HIGH', 'MEDIUM', 'LOW'].map((p) {
                    return Padding(
                      padding: const EdgeInsets.only(right: 6),
                      child: ChoiceChip(
                        label: Text(p),
                        selected: priority == p,
                        onSelected: (val) {
                          if (val) setDialogState(() => priority = p);
                        },
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () {
                if (titleCtrl.text.trim().isNotEmpty) {
                  final asg = Assignment(
                    id: const Uuid().v4(),
                    title: titleCtrl.text.trim(),
                    subject: subCtrl.text.trim(),
                    description: descCtrl.text.trim(),
                    dueDate: dueDate,
                    priority: priority,
                    status: 'In Progress',
                  );
                  widget.storage.addAssignment(asg);
                  Navigator.pop(ctx);
                }
              },
              child: const Text('Save Assignment'),
            ),
          ],
        ),
      ),
    );
  }
}
