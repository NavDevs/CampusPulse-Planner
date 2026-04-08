import 'package:flutter/material.dart';
import '../store/app_store.dart';
import '../models/timetable_entry.dart';
import '../utils/helpers.dart';
import '../widgets/glass_card.dart';

class TimetableTab extends StatefulWidget {
  const TimetableTab({super.key, required this.store});
  final AppStore store;
  @override
  State<TimetableTab> createState() => _TimetableTabState();
}

class _TimetableTabState extends State<TimetableTab> {
  String selectedDay = 'Monday';

  @override
  Widget build(BuildContext context) {
    final list = widget.store.timetable.where((e) => e.day == selectedDay).toList()..sort((a, b) => a.startTime.compareTo(b.startTime));
    final theme = Theme.of(context);

    return Scaffold(
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(vertical: 12),
            height: 65,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: AppStore.days.map((d) => Padding(
                padding: const EdgeInsets.only(right: 8),
                child: ChoiceChip(
                  label: Text(d.substring(0, 3)),
                  selected: selectedDay == d,
                  onSelected: (_) => setState(() => selectedDay = d),
                  backgroundColor: theme.colorScheme.surface,
                  selectedColor: theme.colorScheme.primary,
                  labelStyle: TextStyle(
                    color: selectedDay == d ? theme.colorScheme.onPrimary : theme.colorScheme.onSurface,
                    fontWeight: FontWeight.bold,
                  ),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  showCheckmark: false,
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
                        Icon(Icons.event_busy_rounded, size: 64, color: theme.colorScheme.onSurfaceVariant.withOpacity(0.5)),
                        const SizedBox(height: 16),
                        Text('No classes for $selectedDay', style: theme.textTheme.titleMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: list.length,
                    itemBuilder: (_, i) {
                      final c = list[i];
                      return GlassCard(
                        padding: EdgeInsets.zero,
                        child: ListTile(
                          contentPadding: const EdgeInsets.all(16),
                          title: Text(c.subjectName, style: const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(Icons.person_outline, size: 14, color: theme.colorScheme.primary),
                                    const SizedBox(width: 4),
                                    Text(c.facultyName),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    Icon(Icons.meeting_room_outlined, size: 14, color: theme.colorScheme.tertiary),
                                    const SizedBox(width: 4),
                                    Text(c.classroom),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    Icon(Icons.access_time_rounded, size: 14, color: theme.colorScheme.secondary),
                                    const SizedBox(width: 4),
                                    Text('${Helpers.formatTime(c.startTime)} - ${Helpers.formatTime(c.endTime)}', style: const TextStyle(fontWeight: FontWeight.w600)),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          onTap: () => _openEditor(context, c),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete_outline, color: Colors.grey),
                            onPressed: () => widget.store.deleteTimetable(c.id),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openEditor(context, null), 
        child: const Icon(Icons.add)
      ),
    );
  }

  Future<void> _openEditor(BuildContext context, TimetableEntry? item) async {
    final subject = TextEditingController(text: item?.subjectName ?? '');
    final faculty = TextEditingController(text: item?.facultyName ?? '');
    final room = TextEditingController(text: item?.classroom ?? '');
    final start = TextEditingController(text: item?.startTime ?? '09:00');
    final end = TextEditingController(text: item?.endTime ?? '10:00');
    String day = item?.day ?? selectedDay;
    
    await showDialog<void>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setLocal) => AlertDialog(
          title: Text(item == null ? 'Add Class' : 'Edit Class', style: const TextStyle(fontWeight: FontWeight.bold)),
          content: SingleChildScrollView(
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              TextField(controller: subject, decoration: const InputDecoration(labelText: 'Subject Name')),
              const SizedBox(height: 12),
              TextField(controller: faculty, decoration: const InputDecoration(labelText: 'Faculty Name')),
              const SizedBox(height: 12),
              TextField(controller: room, decoration: const InputDecoration(labelText: 'Classroom')),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: day,
                items: AppStore.days.map((d) => DropdownMenuItem(value: d, child: Text(d))).toList(),
                onChanged: (v) => setLocal(() => day = v ?? day),
                decoration: const InputDecoration(labelText: 'Day'),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(child: TextField(controller: start, decoration: const InputDecoration(labelText: 'Start HH:mm'))),
                  const SizedBox(width: 12),
                  Expanded(child: TextField(controller: end, decoration: const InputDecoration(labelText: 'End HH:mm'))),
                ],
              ),
            ]),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
            FilledButton(
              onPressed: () async {
                if (subject.text.trim().isEmpty) return;
                await widget.store.upsertTimetable(
                  TimetableEntry(
                    id: item?.id ?? widget.store.newId(),
                    subjectName: subject.text.trim(),
                    day: day,
                    startTime: start.text.trim(),
                    endTime: end.text.trim(),
                    facultyName: faculty.text.trim(),
                    classroom: room.text.trim(),
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
