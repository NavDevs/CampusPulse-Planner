import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final store = AppStore();
  await store.load();
  runApp(TimetableApp(store: store));
}

class TimetableApp extends StatelessWidget {
  const TimetableApp({super.key, required this.store});

  final AppStore store;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: store,
      builder: (context, _) {
        final seed = const Color(0xFF4F6AF5);
        final light = ColorScheme.fromSeed(seedColor: seed, brightness: Brightness.light);
        final dark = ColorScheme.fromSeed(seedColor: seed, brightness: Brightness.dark);
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'CampusPulse Planner',
          theme: ThemeData(colorScheme: light, useMaterial3: true),
          darkTheme: ThemeData(colorScheme: dark, useMaterial3: true),
          themeMode: store.settings.darkMode,
          home: HomePage(store: store),
        );
      },
    );
  }
}

class TimetableEntry {
  TimetableEntry({
    required this.id,
    required this.subjectName,
    required this.day,
    required this.startTime,
    required this.endTime,
    required this.facultyName,
    required this.classroom,
  });

  String id;
  String subjectName;
  String day;
  String startTime;
  String endTime;
  String facultyName;
  String classroom;

  Map<String, dynamic> toJson() => {
    'id': id,
    'subjectName': subjectName,
    'day': day,
    'startTime': startTime,
    'endTime': endTime,
    'facultyName': facultyName,
    'classroom': classroom,
  };

  factory TimetableEntry.fromJson(Map<String, dynamic> json) => TimetableEntry(
    id: json['id'] as String,
    subjectName: json['subjectName'] as String,
    day: json['day'] as String,
    startTime: json['startTime'] as String,
    endTime: json['endTime'] as String,
    facultyName: json['facultyName'] as String? ?? '',
    classroom: json['classroom'] as String? ?? '',
  );
}

class AssignmentItem {
  AssignmentItem({
    required this.id,
    required this.title,
    required this.subject,
    required this.dueDate,
    required this.priority,
    this.completed = false,
  });

  String id;
  String title;
  String subject;
  String dueDate;
  String priority;
  bool completed;

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'subject': subject,
    'dueDate': dueDate,
    'priority': priority,
    'completed': completed,
  };

  factory AssignmentItem.fromJson(Map<String, dynamic> json) => AssignmentItem(
    id: json['id'] as String,
    title: json['title'] as String,
    subject: json['subject'] as String? ?? '',
    dueDate: json['dueDate'] as String,
    priority: json['priority'] as String? ?? 'Medium',
    completed: json['completed'] as bool? ?? false,
  );
}

class ExamItem {
  ExamItem({
    required this.id,
    required this.subject,
    required this.date,
    required this.time,
    required this.hall,
    required this.reminderDaysBefore,
  });

  String id;
  String subject;
  String date;
  String time;
  String hall;
  int reminderDaysBefore;

  Map<String, dynamic> toJson() => {
    'id': id,
    'subject': subject,
    'date': date,
    'time': time,
    'hall': hall,
    'reminderDaysBefore': reminderDaysBefore,
  };

  factory ExamItem.fromJson(Map<String, dynamic> json) => ExamItem(
    id: json['id'] as String,
    subject: json['subject'] as String,
    date: json['date'] as String,
    time: json['time'] as String,
    hall: json['hall'] as String? ?? '',
    reminderDaysBefore: json['reminderDaysBefore'] as int? ?? 1,
  );
}

class AppSettings {
  AppSettings({
    required this.notificationsEnabled,
    required this.classReminderMinutes,
    required this.darkMode,
  });

  bool notificationsEnabled;
  int classReminderMinutes;
  ThemeMode darkMode;

  Map<String, dynamic> toJson() => {
    'notificationsEnabled': notificationsEnabled,
    'classReminderMinutes': classReminderMinutes,
    'darkMode': darkMode.name,
  };

  factory AppSettings.fromJson(Map<String, dynamic> json) => AppSettings(
    notificationsEnabled: json['notificationsEnabled'] as bool? ?? true,
    classReminderMinutes: json['classReminderMinutes'] as int? ?? 15,
    darkMode: _themeModeFrom(json['darkMode'] as String? ?? 'system'),
  );

  static ThemeMode _themeModeFrom(String raw) {
    switch (raw) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      default:
        return ThemeMode.system;
    }
  }
}

class AppStore extends ChangeNotifier {
  static const _ttKey = 'flutter_tt_timetable';
  static const _asKey = 'flutter_tt_assignments';
  static const _exKey = 'flutter_tt_exams';
  static const _setKey = 'flutter_tt_settings';
  static const days = <String>['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];

  final List<TimetableEntry> timetable = [];
  final List<AssignmentItem> assignments = [];
  final List<ExamItem> exams = [];
  AppSettings settings = AppSettings(notificationsEnabled: true, classReminderMinutes: 15, darkMode: ThemeMode.system);
  SharedPreferences? _prefs;

  Future<void> load() async {
    _prefs = await SharedPreferences.getInstance();
    final ttRaw = _prefs!.getString(_ttKey);
    final asRaw = _prefs!.getString(_asKey);
    final exRaw = _prefs!.getString(_exKey);
    final setRaw = _prefs!.getString(_setKey);
    if (ttRaw != null) {
      final list = (jsonDecode(ttRaw) as List<dynamic>);
      timetable.addAll(list.map((e) => TimetableEntry.fromJson(e as Map<String, dynamic>)));
    }
    if (asRaw != null) {
      final list = (jsonDecode(asRaw) as List<dynamic>);
      assignments.addAll(list.map((e) => AssignmentItem.fromJson(e as Map<String, dynamic>)));
    }
    if (exRaw != null) {
      final list = (jsonDecode(exRaw) as List<dynamic>);
      exams.addAll(list.map((e) => ExamItem.fromJson(e as Map<String, dynamic>)));
    }
    if (setRaw != null) {
      settings = AppSettings.fromJson(jsonDecode(setRaw) as Map<String, dynamic>);
    }
  }

  String newId() => DateTime.now().microsecondsSinceEpoch.toString();

  Future<void> _save() async {
    await _prefs?.setString(_ttKey, jsonEncode(timetable.map((e) => e.toJson()).toList()));
    await _prefs?.setString(_asKey, jsonEncode(assignments.map((e) => e.toJson()).toList()));
    await _prefs?.setString(_exKey, jsonEncode(exams.map((e) => e.toJson()).toList()));
    await _prefs?.setString(_setKey, jsonEncode(settings.toJson()));
    notifyListeners();
  }

  Future<void> upsertTimetable(TimetableEntry entry) async {
    final idx = timetable.indexWhere((e) => e.id == entry.id);
    if (idx == -1) {
      timetable.add(entry);
    } else {
      timetable[idx] = entry;
    }
    await _save();
  }

  Future<void> deleteTimetable(String id) async {
    timetable.removeWhere((e) => e.id == id);
    await _save();
  }

  Future<void> upsertAssignment(AssignmentItem item) async {
    final idx = assignments.indexWhere((e) => e.id == item.id);
    if (idx == -1) {
      assignments.add(item);
    } else {
      assignments[idx] = item;
    }
    await _save();
  }

  Future<void> deleteAssignment(String id) async {
    assignments.removeWhere((e) => e.id == id);
    await _save();
  }

  Future<void> toggleAssignment(String id) async {
    final idx = assignments.indexWhere((e) => e.id == id);
    if (idx != -1) {
      assignments[idx].completed = !assignments[idx].completed;
      await _save();
    }
  }

  Future<void> upsertExam(ExamItem item) async {
    final idx = exams.indexWhere((e) => e.id == item.id);
    if (idx == -1) {
      exams.add(item);
    } else {
      exams[idx] = item;
    }
    await _save();
  }

  Future<void> deleteExam(String id) async {
    exams.removeWhere((e) => e.id == id);
    await _save();
  }

  Future<void> updateSettings({bool? notificationsEnabled, int? classReminderMinutes, ThemeMode? darkMode}) async {
    if (notificationsEnabled != null) settings.notificationsEnabled = notificationsEnabled;
    if (classReminderMinutes != null) settings.classReminderMinutes = classReminderMinutes;
    if (darkMode != null) settings.darkMode = darkMode;
    await _save();
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key, required this.store});

  final AppStore store;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final store = widget.store;
    final today = AppStore.days[DateTime.now().weekday - 1];
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            SvgPicture.asset('assets/images/icon.svg', width: 24, height: 24),
            const SizedBox(width: 8),
            const Text('CampusPulse Planner'),
          ],
        ),
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: [
          DashboardTab(store: store, today: today),
          TimetableTab(store: store),
          AssignmentsTab(store: store),
          ExamsTab(store: store),
          SettingsTab(store: store),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) => setState(() => _currentIndex = index),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined), label: 'Dashboard'),
          NavigationDestination(icon: Icon(Icons.schedule), label: 'Timetable'),
          NavigationDestination(icon: Icon(Icons.assignment), label: 'Assignments'),
          NavigationDestination(icon: Icon(Icons.school), label: 'Exams'),
          NavigationDestination(icon: Icon(Icons.settings), label: 'Settings'),
        ],
      ),
    );
  }
}

class DashboardTab extends StatelessWidget {
  const DashboardTab({super.key, required this.store, required this.today});

  final AppStore store;
  final String today;

  @override
  Widget build(BuildContext context) {
    final todayClasses = store.timetable.where((e) => e.day == today).toList()..sort((a, b) => a.startTime.compareTo(b.startTime));
    final pending = store.assignments.where((a) => !a.completed).toList()..sort((a, b) => _daysUntil(a.dueDate).compareTo(_daysUntil(b.dueDate)));
    final upcomingExam = (store.exams.where((e) => _daysUntil(e.date) >= 0).toList()..sort((a, b) => _daysUntil(a.date).compareTo(_daysUntil(b.date)))).firstOrNull;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(today, style: Theme.of(context).textTheme.bodyMedium),
        const SizedBox(height: 4),
        Text('Dashboard', style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: 16),
        Row(
          children: [
            _stat(context, 'Today', todayClasses.length, Icons.menu_book_outlined),
            const SizedBox(width: 8),
            _stat(context, 'Pending', pending.length, Icons.pending_actions_outlined),
            const SizedBox(width: 8),
            _stat(context, 'Exams(7d)', store.exams.where((e) { final d = _daysUntil(e.date); return d >= 0 && d <= 7; }).length, Icons.warning_amber_rounded),
          ],
        ),
        const SizedBox(height: 18),
        Text("Today's Classes", style: Theme.of(context).textTheme.titleMedium),
        ...todayClasses.map((c) => Card(child: ListTile(title: Text(c.subjectName), subtitle: Text('${_formatTime(c.startTime)} - ${_formatTime(c.endTime)}  ${c.classroom}')))),
        if (todayClasses.isEmpty) const Card(child: ListTile(title: Text('No classes today'))),
        const SizedBox(height: 12),
        Text('Upcoming Assignments', style: Theme.of(context).textTheme.titleMedium),
        ...pending.take(3).map((a) => Card(child: ListTile(title: Text(a.title), subtitle: Text('${a.subject} • ${_dueLabel(a.dueDate)}'), trailing: Text(a.priority)))),
        if (pending.isEmpty) const Card(child: ListTile(title: Text('All caught up'))),
        const SizedBox(height: 12),
        Text('Next Exam', style: Theme.of(context).textTheme.titleMedium),
        Card(
          child: ListTile(
            title: Text(upcomingExam?.subject ?? 'No exams scheduled'),
            subtitle: Text(upcomingExam == null ? '' : '${upcomingExam.date} ${_formatTime(upcomingExam.time)} • ${upcomingExam.hall}'),
            trailing: upcomingExam == null ? null : Text('${_daysUntil(upcomingExam.date)}d'),
          ),
        ),
      ],
    );
  }

  Widget _stat(BuildContext context, String label, int value, IconData icon) {
    return Expanded(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Icon(icon), const SizedBox(height: 8), Text('$value', style: Theme.of(context).textTheme.headlineSmall), Text(label)]),
        ),
      ),
    );
  }
}

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
    return Scaffold(
      body: Column(
        children: [
          SizedBox(
            height: 54,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: AppStore.days
                  .map((d) => Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                        child: ChoiceChip(label: Text(d.substring(0, 3)), selected: selectedDay == d, onSelected: (_) => setState(() => selectedDay = d)),
                      ))
                  .toList(),
            ),
          ),
          Expanded(
            child: list.isEmpty
                ? const Center(child: Text('No classes on selected day'))
                : ListView.builder(
                    itemCount: list.length,
                    itemBuilder: (_, i) {
                      final c = list[i];
                      return Card(
                        child: ListTile(
                          title: Text(c.subjectName),
                          subtitle: Text('${c.facultyName} • ${c.classroom}\n${_formatTime(c.startTime)} - ${_formatTime(c.endTime)}'),
                          isThreeLine: true,
                          onTap: () => _openEditor(context, c),
                          trailing: IconButton(icon: const Icon(Icons.delete_outline), onPressed: () => widget.store.deleteTimetable(c.id)),
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
          title: Text(item == null ? 'Add Class' : 'Edit Class'),
          content: SingleChildScrollView(
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              TextField(controller: subject, decoration: const InputDecoration(labelText: 'Subject Name')),
              TextField(controller: faculty, decoration: const InputDecoration(labelText: 'Faculty Name')),
              TextField(controller: room, decoration: const InputDecoration(labelText: 'Classroom')),
              DropdownButtonFormField<String>(
                initialValue: day,
                items: AppStore.days.map((d) => DropdownMenuItem(value: d, child: Text(d))).toList(),
                onChanged: (v) => setLocal(() => day = v ?? day),
                decoration: const InputDecoration(labelText: 'Day'),
              ),
              TextField(controller: start, decoration: const InputDecoration(labelText: 'Start Time HH:mm')),
              TextField(controller: end, decoration: const InputDecoration(labelText: 'End Time HH:mm')),
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

class AssignmentsTab extends StatefulWidget {
  const AssignmentsTab({super.key, required this.store});
  final AppStore store;
  @override
  State<AssignmentsTab> createState() => _AssignmentsTabState();
}

class _AssignmentsTabState extends State<AssignmentsTab> {
  String filter = 'All';

  @override
  Widget build(BuildContext context) {
    var list = [...widget.store.assignments];
    if (filter == 'Pending') list = list.where((e) => !e.completed).toList();
    if (filter == 'Completed') list = list.where((e) => e.completed).toList();
    list.sort((a, b) => _daysUntil(a.dueDate).compareTo(_daysUntil(b.dueDate)));
    return Scaffold(
      body: Column(
        children: [
          SizedBox(
            height: 52,
            child: ListView(scrollDirection: Axis.horizontal, children: ['All', 'Pending', 'Completed'].map((f) => Padding(padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8), child: ChoiceChip(label: Text(f), selected: filter == f, onSelected: (_) => setState(() => filter = f)))).toList()),
          ),
          Expanded(
            child: list.isEmpty
                ? const Center(child: Text('No assignments'))
                : ListView.builder(
                    itemCount: list.length,
                    itemBuilder: (_, i) {
                      final a = list[i];
                      return Card(
                        child: CheckboxListTile(
                          value: a.completed,
                          title: Text(a.title),
                          subtitle: Text('${a.subject} • ${_dueLabel(a.dueDate)} • ${a.priority}'),
                          secondary: IconButton(icon: const Icon(Icons.delete_outline), onPressed: () => widget.store.deleteAssignment(a.id)),
                          onChanged: (_) => widget.store.toggleAssignment(a.id),
                          controlAffinity: ListTileControlAffinity.leading,
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
          title: Text(item == null ? 'Add Assignment' : 'Edit Assignment'),
          content: SingleChildScrollView(
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              TextField(controller: title, decoration: const InputDecoration(labelText: 'Title')),
              TextField(controller: subject, decoration: const InputDecoration(labelText: 'Subject')),
              TextField(controller: due, decoration: const InputDecoration(labelText: 'Due Date YYYY-MM-DD')),
              DropdownButtonFormField<String>(
                initialValue: priority,
                items: const ['Low', 'Medium', 'High'].map((p) => DropdownMenuItem(value: p, child: Text(p))).toList(),
                onChanged: (v) => setLocal(() => priority = v ?? priority),
                decoration: const InputDecoration(labelText: 'Priority'),
              ),
              SwitchListTile(
                value: completed,
                onChanged: (v) => setLocal(() => completed = v),
                contentPadding: EdgeInsets.zero,
                title: const Text('Completed'),
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

class ExamsTab extends StatefulWidget {
  const ExamsTab({super.key, required this.store});
  final AppStore store;
  @override
  State<ExamsTab> createState() => _ExamsTabState();
}

class _ExamsTabState extends State<ExamsTab> {
  @override
  Widget build(BuildContext context) {
    final upcoming = widget.store.exams.where((e) => _daysUntil(e.date) >= 0).toList()..sort((a, b) => _daysUntil(a.date).compareTo(_daysUntil(b.date)));
    final past = widget.store.exams.where((e) => _daysUntil(e.date) < 0).toList()..sort((a, b) => b.date.compareTo(a.date));
    return Scaffold(
      body: ListView(
        children: [
          if (upcoming.isNotEmpty) const Padding(padding: EdgeInsets.all(12), child: Text('Upcoming')),
          ...upcoming.map((e) => Card(
                child: ListTile(
                  title: Text(e.subject),
                  subtitle: Text('${e.date} ${_formatTime(e.time)} • ${e.hall}\nReminder: ${e.reminderDaysBefore}d before'),
                  isThreeLine: true,
                  trailing: Text('${_daysUntil(e.date)}d'),
                  onTap: () => _openEditor(context, e),
                ),
              )),
          if (past.isNotEmpty) const Padding(padding: EdgeInsets.all(12), child: Text('Past')),
          ...past.map((e) => Card(
                child: ListTile(
                  title: Text(e.subject),
                  subtitle: Text('${e.date} ${_formatTime(e.time)} • ${e.hall}'),
                  trailing: IconButton(icon: const Icon(Icons.delete_outline), onPressed: () => widget.store.deleteExam(e.id)),
                  onTap: () => _openEditor(context, e),
                ),
              )),
          if (upcoming.isEmpty && past.isEmpty) const ListTile(title: Text('No exams scheduled')),
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
          title: Text(item == null ? 'Add Exam' : 'Edit Exam'),
          content: SingleChildScrollView(
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              TextField(controller: subject, decoration: const InputDecoration(labelText: 'Subject')),
              TextField(controller: date, decoration: const InputDecoration(labelText: 'Date YYYY-MM-DD')),
              TextField(controller: time, decoration: const InputDecoration(labelText: 'Time HH:mm')),
              TextField(controller: hall, decoration: const InputDecoration(labelText: 'Hall / Venue')),
              DropdownButtonFormField<int>(
                initialValue: reminder,
                items: const [0, 1, 2, 3, 5, 7].map((d) => DropdownMenuItem(value: d, child: Text('$d day(s) before'))).toList(),
                onChanged: (v) => setLocal(() => reminder = v ?? reminder),
                decoration: const InputDecoration(labelText: 'Reminder'),
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
                child: const Text('Delete'),
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

class SettingsTab extends StatelessWidget {
  const SettingsTab({super.key, required this.store});
  final AppStore store;

  @override
  Widget build(BuildContext context) {
    final pending = store.assignments.where((a) => !a.completed).length;
    return ListView(
      children: [
        SwitchListTile(
          title: const Text('Enable Notifications'),
          subtitle: const Text('Receive reminders for classes, assignments and exams'),
          value: store.settings.notificationsEnabled,
          onChanged: (v) => store.updateSettings(notificationsEnabled: v),
        ),
        ListTile(
          title: const Text('Class Reminder Minutes'),
          subtitle: Text('${store.settings.classReminderMinutes} minutes'),
          trailing: DropdownButton<int>(
            value: store.settings.classReminderMinutes,
            items: const [15, 30].map((m) => DropdownMenuItem(value: m, child: Text('$m'))).toList(),
            onChanged: (v) => store.updateSettings(classReminderMinutes: v ?? 15),
          ),
        ),
        ListTile(
          title: const Text('Theme'),
          subtitle: Text(store.settings.darkMode.name),
          trailing: DropdownButton<ThemeMode>(
            value: store.settings.darkMode,
            items: const [
              DropdownMenuItem(value: ThemeMode.system, child: Text('system')),
              DropdownMenuItem(value: ThemeMode.light, child: Text('light')),
              DropdownMenuItem(value: ThemeMode.dark, child: Text('dark')),
            ],
            onChanged: (v) => store.updateSettings(darkMode: v ?? ThemeMode.system),
          ),
        ),
        const Divider(),
        ListTile(title: const Text('Classes Scheduled'), trailing: Text('${store.timetable.length}')),
        ListTile(title: const Text('Assignments'), trailing: Text('${store.assignments.length}')),
        ListTile(title: const Text('Pending Assignments'), trailing: Text('$pending')),
        ListTile(title: const Text('Exams Scheduled'), trailing: Text('${store.exams.length}')),
      ],
    );
  }
}

int _daysUntil(String dateStr) {
  final target = DateTime.tryParse(dateStr);
  if (target == null) return 9999;
  final t = DateTime(target.year, target.month, target.day);
  final now = DateTime.now();
  final n = DateTime(now.year, now.month, now.day);
  return t.difference(n).inDays;
}

String _formatTime(String time) {
  final parts = time.split(':');
  if (parts.isEmpty) return time;
  final h = int.tryParse(parts[0]) ?? 0;
  final m = parts.length > 1 ? parts[1] : '00';
  final ampm = h >= 12 ? 'PM' : 'AM';
  final hh = h % 12 == 0 ? 12 : h % 12;
  return '$hh:$m $ampm';
}

String _dueLabel(String date) {
  final d = _daysUntil(date);
  if (d < 0) return '${d.abs()}d overdue';
  if (d == 0) return 'Due today';
  if (d == 1) return 'Due tomorrow';
  return '$d days left';
}
