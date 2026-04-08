import 'package:flutter/material.dart';
import '../store/app_store.dart';
import '../models/exam_item.dart';
import '../utils/helpers.dart';
import '../widgets/glass_card.dart';

class ExamsTab extends StatefulWidget {
  const ExamsTab({super.key, required this.store});
  final AppStore store;
  @override
  State<ExamsTab> createState() => _ExamsTabState();
}

class _ExamsTabState extends State<ExamsTab> {
  @override
  Widget build(BuildContext context) {
    final upcoming = widget.store.exams.where((e) => Helpers.daysUntil(e.date) >= 0).toList()..sort((a, b) => Helpers.daysUntil(a.date).compareTo(Helpers.daysUntil(b.date)));
    final past = widget.store.exams.where((e) => Helpers.daysUntil(e.date) < 0).toList()..sort((a, b) => b.date.compareTo(a.date));
    
    final theme = Theme.of(context);

    return Scaffold(
      body: upcoming.isEmpty && past.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.school_rounded, size: 64, color: theme.colorScheme.onSurfaceVariant.withOpacity(0.5)),
                  const SizedBox(height: 16),
                  Text('No exams scheduled', style: theme.textTheme.titleMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
                ],
              ),
            )
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                if (upcoming.isNotEmpty) ...[
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12, left: 4), 
                    child: Text('Upcoming Exams', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold))
                  ),
                  ...upcoming.map((e) => GlassCard(
                        padding: EdgeInsets.zero,
                        child: ListTile(
                          contentPadding: const EdgeInsets.all(16),
                          title: Text(e.subject, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                          subtitle: Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(Icons.calendar_today, size: 14, color: theme.colorScheme.primary),
                                    const SizedBox(width: 4),
                                    Text('${e.date} at ${Helpers.formatTime(e.time)}', style: const TextStyle(fontWeight: FontWeight.w500)),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    Icon(Icons.location_on_outlined, size: 14, color: theme.colorScheme.tertiary),
                                    const SizedBox(width: 4),
                                    Text(e.hall.isEmpty ? 'TBD' : e.hall),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    Icon(Icons.notifications_active_outlined, size: 14, color: theme.colorScheme.secondary),
                                    const SizedBox(width: 4),
                                    Text('Reminder ${e.reminderDaysBefore} day(s) before', style: theme.textTheme.bodySmall),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          trailing: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                            decoration: BoxDecoration(color: theme.colorScheme.primaryContainer, borderRadius: BorderRadius.circular(12)),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text('${Helpers.daysUntil(e.date)}', style: TextStyle(color: theme.colorScheme.primary, fontWeight: FontWeight.bold, fontSize: 16)),
                                Text('days', style: TextStyle(color: theme.colorScheme.primary, fontSize: 10)),
                              ],
                            ),
                          ),
                          onTap: () => _openEditor(context, e),
                        ),
                      )),
                  const SizedBox(height: 24),
                ],
                
                if (past.isNotEmpty) ...[
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12, left: 4), 
                    child: Text('Past Exams', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: theme.colorScheme.onSurfaceVariant))
                  ),
                  ...past.map((e) => GlassCard(
                        padding: EdgeInsets.zero,
                        child: ListTile(
                          title: Text(e.subject, style: TextStyle(color: theme.colorScheme.onSurfaceVariant, fontWeight: FontWeight.w500)),
                          subtitle: Text('${e.date} ${Helpers.formatTime(e.time)} • ${e.hall}'),
                          trailing: IconButton(icon: const Icon(Icons.delete_outline), onPressed: () => widget.store.deleteExam(e.id)),
                          onTap: () => _openEditor(context, e),
                        ),
                      )),
                ],
              ],
            ),
      floatingActionButton: FloatingActionButton(onPressed: () => _openEditor(context, null), child: const Icon(Icons.add)),
    );
  }

  Future<void> _openEditor(BuildContext context, ExamItem? item) async {
    final subject = TextEditingController(text: item?.subject ?? '');
    final date = TextEditingController(text: item?.date ?? DateTime.now().toIso8601String().split('T').first);
    final time = TextEditingController(text: item?.time ?? '09:00');
    final hall = TextEditingController(text: item?.hall ?? '');
    int reminder = item?.reminderDaysBefore ?? 1;
    
    await showDialog<void>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setLocal) => AlertDialog(
          title: Text(item == null ? 'Add Exam' : 'Edit Exam', style: const TextStyle(fontWeight: FontWeight.bold)),
          content: SingleChildScrollView(
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              TextField(controller: subject, decoration: const InputDecoration(labelText: 'Subject')),
              const SizedBox(height: 12),
              TextField(controller: date, decoration: const InputDecoration(labelText: 'Date YYYY-MM-DD')),
              const SizedBox(height: 12),
              TextField(controller: time, decoration: const InputDecoration(labelText: 'Time HH:mm')),
              const SizedBox(height: 12),
              TextField(controller: hall, decoration: const InputDecoration(labelText: 'Hall / Venue')),
              const SizedBox(height: 12),
              DropdownButtonFormField<int>(
                value: reminder,
                items: const [0, 1, 2, 3, 5, 7].map((d) => DropdownMenuItem(value: d, child: Text('$d day(s) before'))).toList(),
                onChanged: (v) => setLocal(() => reminder = v ?? reminder),
                decoration: const InputDecoration(labelText: 'Reminder Alert'),
              ),
            ]),
          ),
          actions: [
            if (item != null)
              TextButton(
                onPressed: () async {
                  await widget.store.deleteExam(item.id);
                  if (!ctx.mounted) return;
                  Navigator.pop(ctx);
                },
                child: Text('Delete', style: TextStyle(color: Theme.of(context).colorScheme.error)),
              ),
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
            FilledButton(
              onPressed: () async {
                if (subject.text.trim().isEmpty) return;
                await widget.store.upsertExam(
                  ExamItem(
                    id: item?.id ?? widget.store.newId(),
                    subject: subject.text.trim(),
                    date: date.text.trim(),
                    time: time.text.trim(),
                    hall: hall.text.trim(),
                    reminderDaysBefore: reminder,
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
