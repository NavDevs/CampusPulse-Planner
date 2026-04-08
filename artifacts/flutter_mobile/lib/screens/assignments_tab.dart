import 'package:flutter/material.dart';
import '../store/app_store.dart';
import '../models/assignment_item.dart';
import '../utils/helpers.dart';
import '../widgets/glass_card.dart';
import '../widgets/priority_badge.dart';

class AssignmentsTab extends StatefulWidget {
  const AssignmentsTab({super.key, required this.store});
  final AppStore store;
  @override
  State<AssignmentsTab> createState() => _AssignmentsTabState();
}

class _AssignmentsTabState extends State<AssignmentsTab> {
  String filter = 'Pending';

  @override
  Widget build(BuildContext context) {
    var list = [...widget.store.assignments];
    if (filter == 'Pending') list = list.where((e) => !e.completed).toList();
    if (filter == 'Completed') list = list.where((e) => e.completed).toList();
    list.sort((a, b) => Helpers.daysUntil(a.dueDate).compareTo(Helpers.daysUntil(b.dueDate)));
    
    final theme = Theme.of(context);

    return Scaffold(
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(vertical: 12),
            height: 65,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: ['Pending', 'Completed', 'All'].map((f) => Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: ChoiceChip(
                  label: Text(f), 
                  selected: filter == f, 
                  onSelected: (_) => setState(() => filter = f),
                  backgroundColor: theme.colorScheme.surface,
                  selectedColor: theme.colorScheme.primary,
                  labelStyle: TextStyle(color: filter == f ? theme.colorScheme.onPrimary : theme.colorScheme.onSurface),
                  showCheckmark: false,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                ),
              )).toList(),
            ),
          ),
          Expanded(
            child: list.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.assignment_turned_in_rounded, size: 64, color: theme.colorScheme.onSurfaceVariant.withOpacity(0.5)),
                        const SizedBox(height: 16),
                        Text(filter == 'Pending' ? 'All caught up!' : 'No assignments', style: theme.textTheme.titleMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: list.length,
                    itemBuilder: (_, i) {
                      final a = list[i];
                      final isOverdue = Helpers.daysUntil(a.dueDate) < 0 && !a.completed;
                      
                      return GlassCard(
                        padding: EdgeInsets.zero,
                        child: Row(
                          children: [
                            Checkbox(
                              value: a.completed,
                              onChanged: (_) => widget.store.toggleAssignment(a.id),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                              activeColor: theme.colorScheme.secondary,
                            ),
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                child: InkWell(
                                  onTap: () => _openEditor(context, a),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        a.title, 
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold, 
                                          fontSize: 16,
                                          decoration: a.completed ? TextDecoration.lineThrough : null,
                                          color: a.completed ? theme.colorScheme.onSurfaceVariant : theme.colorScheme.onSurface,
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      Row(
                                        children: [
                                          Icon(Icons.menu_book, size: 12, color: theme.colorScheme.onSurfaceVariant),
                                          const SizedBox(width: 4),
                                          Text(a.subject, style: theme.textTheme.bodySmall),
                                          const SizedBox(width: 12),
                                          Icon(Icons.calendar_today, size: 12, color: isOverdue ? theme.colorScheme.error : theme.colorScheme.onSurfaceVariant),
                                          const SizedBox(width: 4),
                                          Text(
                                            Helpers.dueLabel(a.dueDate), 
                                            style: theme.textTheme.bodySmall?.copyWith(
                                              color: isOverdue ? theme.colorScheme.error : theme.colorScheme.onSurfaceVariant,
                                              fontWeight: isOverdue ? FontWeight.bold : null,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(right: 8.0),
                              child: PriorityBadge(priority: a.priority),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete_outline, color: Colors.grey, size: 20),
                              onPressed: () => widget.store.deleteAssignment(a.id),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(onPressed: () => _openEditor(context, null), child: const Icon(Icons.add)),
    );
  }

  Future<void> _openEditor(BuildContext context, AssignmentItem? item) async {
    final title = TextEditingController(text: item?.title ?? '');
    final subject = TextEditingController(text: item?.subject ?? '');
    final due = TextEditingController(text: item?.dueDate ?? DateTime.now().toIso8601String().split('T').first);
    String priority = item?.priority ?? 'Medium';
    bool completed = item?.completed ?? false;
    
    await showDialog<void>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setLocal) => AlertDialog(
          title: Text(item == null ? 'Add Assignment' : 'Edit Assignment', style: const TextStyle(fontWeight: FontWeight.bold)),
          content: SingleChildScrollView(
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              TextField(controller: title, decoration: const InputDecoration(labelText: 'Title')),
              const SizedBox(height: 12),
              TextField(controller: subject, decoration: const InputDecoration(labelText: 'Subject')),
              const SizedBox(height: 12),
              TextField(controller: due, decoration: const InputDecoration(labelText: 'Due Date YYYY-MM-DD')),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: priority,
                items: const ['Low', 'Medium', 'High'].map((p) => DropdownMenuItem(value: p, child: Text(p))).toList(),
                onChanged: (v) => setLocal(() => priority = v ?? priority),
                decoration: const InputDecoration(labelText: 'Priority'),
              ),
              const SizedBox(height: 12),
              SwitchListTile(
                value: completed,
                onChanged: (v) => setLocal(() => completed = v),
                contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                title: const Text('Status: Completed'),
                activeColor: Theme.of(context).colorScheme.primary,
              ),
            ]),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
            FilledButton(
              onPressed: () async {
                if (title.text.trim().isEmpty) return;
                await widget.store.upsertAssignment(
                  AssignmentItem(
                    id: item?.id ?? widget.store.newId(),
                    title: title.text.trim(),
                    subject: subject.text.trim(),
                    dueDate: due.text.trim(),
                    priority: priority,
                    completed: completed,
                  ),
                );
                if (!ctx.mounted) return;
                Navigator.pop(ctx);
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }
}
