import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/timetable_entry.dart';
import '../models/assignment_item.dart';
import '../models/exam_item.dart';
import '../models/app_settings.dart';

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
