import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/common_widgets.dart';
import '../../core/services/storage_service.dart';
import '../../shared/models/app_models.dart';
import 'package:uuid/uuid.dart';

class NotesScreen extends StatefulWidget {
  final StorageService storage;
  const NotesScreen({super.key, required this.storage});

  @override
  State<NotesScreen> createState() => _NotesScreenState();
}

class _NotesScreenState extends State<NotesScreen> {
  final _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final allNotes = widget.storage.notes;

    final filtered = allNotes.where((n) {
      if (_searchQuery.isEmpty) return true;
      final q = _searchQuery.toLowerCase();
      return n.title.toLowerCase().contains(q) ||
          n.content.toLowerCase().contains(q) ||
          n.subject.toLowerCase().contains(q) ||
          n.tags.any((t) => t.toLowerCase().contains(q));
    }).toList();

    // Split pinned vs others
    final pinned = filtered.where((n) => n.isPinned).toList();
    final others = filtered.where((n) => !n.isPinned).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Quick Study Notes 📖'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: 'Add Note',
            onPressed: () => _openNoteEditor(context, null),
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search notes, subjects, or tags...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _searchQuery = '');
                        },
                      )
                    : null,
              ),
              onChanged: (val) => setState(() => _searchQuery = val),
            ),
          ),

          // Notes View
          Expanded(
            child: filtered.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(Icons.note_alt_outlined, size: 48, color: Colors.grey),
                        SizedBox(height: 12),
                        Text('No notes found!', style: TextStyle(fontWeight: FontWeight.bold)),
                        SizedBox(height: 4),
                        Text('Tap + to jot down formulas or lecture notes.', style: TextStyle(color: Colors.grey)),
                      ],
                    ),
                  )
                : ListView(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    children: [
                      if (pinned.isNotEmpty) ...[
                        const Text('📌 PINNED NOTES', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.1)),
                        const SizedBox(height: 8),
                        ...pinned.map((n) => _buildNoteCard(n, isDark)),
                        const SizedBox(height: 16),
                      ],
                      if (others.isNotEmpty) ...[
                        if (pinned.isNotEmpty)
                          const Text('ALL NOTES', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.1)),
                        const SizedBox(height: 8),
                        ...others.map((n) => _buildNoteCard(n, isDark)),
                      ],
                    ],
                  ),
          ),
          GooglePlayCompliantAdBanner(isPro: widget.storage.isProUser),
        ],
      ),
    );
  }

  Widget _buildNoteCard(NoteItem note, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: CustomCard(
        onTap: () => _openNoteEditor(context, note),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    note.title,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ),
                IconButton(
                  icon: Icon(
                    note.isPinned ? Icons.push_pin : Icons.push_pin_outlined,
                    size: 18,
                    color: note.isPinned ? AppColors.primary : Colors.grey,
                  ),
                  onPressed: () => widget.storage.togglePinNote(note.id),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline, size: 18, color: Colors.grey),
                  onPressed: () async {
                    final confirmed = await showConfirmDeleteDialog(
                      context,
                      title: 'Delete Note?',
                      message: 'Are you sure you want to delete note "${note.title}"? This cannot be undone.',
                    );
                    if (confirmed) {
                      widget.storage.deleteNote(note.id);
                    }
                  },
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              note.content,
              style: TextStyle(
                fontSize: 14,
                color: isDark ? AppColors.darkSubtext : AppColors.lightSubtext,
              ),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(note.subject, style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.primary)),
                ),
                const SizedBox(width: 8),
                Text(
                  DateFormat('dd MMM').format(note.updatedAt),
                  style: const TextStyle(fontSize: 11, color: Colors.grey),
                ),
                const Spacer(),
                if (note.tags.isNotEmpty)
                  Text(
                    note.tags.map((t) => '#$t').join(' '),
                    style: const TextStyle(fontSize: 11, color: AppColors.secondary, fontWeight: FontWeight.w600),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _openNoteEditor(BuildContext context, NoteItem? existing) {
    final titleCtrl = TextEditingController(text: existing?.title ?? '');
    final subCtrl = TextEditingController(text: existing?.subject ?? 'General');
    final contentCtrl = TextEditingController(text: existing?.content ?? '');
    final tagsCtrl = TextEditingController(text: existing?.tags.join(', ') ?? '');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 20,
          bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                existing == null ? 'Create Note 📝' : 'Edit Note ✏️',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              TextField(controller: titleCtrl, decoration: const InputDecoration(labelText: 'Title')),
              const SizedBox(height: 10),
              TextField(controller: subCtrl, decoration: const InputDecoration(labelText: 'Subject (e.g. DBMS, Maths)')),
              const SizedBox(height: 10),
              TextField(
                controller: contentCtrl,
                maxLines: 6,
                decoration: const InputDecoration(labelText: 'Note Content'),
              ),
              const SizedBox(height: 10),
              TextField(controller: tagsCtrl, decoration: const InputDecoration(labelText: 'Tags (comma separated)')),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  if (titleCtrl.text.trim().isNotEmpty) {
                    final tags = tagsCtrl.text.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();

                    if (existing == null) {
                      final n = NoteItem(
                        id: const Uuid().v4(),
                        title: titleCtrl.text.trim(),
                        subject: subCtrl.text.trim(),
                        content: contentCtrl.text.trim(),
                        tags: tags,
                        isPinned: false,
                        isFavorite: false,
                        createdAt: DateTime.now(),
                        updatedAt: DateTime.now(),
                      );
                      widget.storage.addNote(n);
                    } else {
                      final n = NoteItem(
                        id: existing.id,
                        title: titleCtrl.text.trim(),
                        subject: subCtrl.text.trim(),
                        content: contentCtrl.text.trim(),
                        tags: tags,
                        isPinned: existing.isPinned,
                        isFavorite: existing.isFavorite,
                        createdAt: existing.createdAt,
                        updatedAt: DateTime.now(),
                      );
                      widget.storage.updateNote(n);
                    }
                    Navigator.pop(ctx);
                  }
                },
                child: Text(existing == null ? 'Save Note' : 'Update Note'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
