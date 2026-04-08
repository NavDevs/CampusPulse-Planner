import '../models/assignment_item.dart';
import '../models/exam_item.dart';
import '../models/timetable_entry.dart';
import '../utils/helpers.dart';

enum UrgencyCategory { critical, urgent, high, medium, planAhead, low }

class AISuggestion {
  final String title;
  final String subtitle;
  final String reasoning;
  final String action;
  final UrgencyCategory category;
  final int score;
  final String? relatedId;

  AISuggestion({
    required this.title,
    required this.subtitle,
    required this.reasoning,
    required this.action,
    required this.category,
    required this.score,
    this.relatedId,
  });
}

class WorkloadSummary {
  final int activeAssignments;
  final int upcomingExams;
  final int criticalTasks;
  final String generalAdvice;

  WorkloadSummary({
    required this.activeAssignments,
    required this.upcomingExams,
    required this.criticalTasks,
    required this.generalAdvice,
  });
}

class PriorityEngine {
  static List<AISuggestion> analyze(
      List<AssignmentItem> assignments,
      List<ExamItem> exams,
      List<TimetableEntry> todayClasses) {
    
    List<AISuggestion> suggestions = [];
    
    // Analyze Assignments
    for (var a in assignments.where((x) => !x.completed)) {
      final days = Helpers.daysUntil(a.dueDate);
      int score = 0;
      UrgencyCategory category;
      String action;
      String reasoning;

      // Base score from priority
      if (a.priority == 'High') score += 40;
      else if (a.priority == 'Medium') score += 20;
      else score += 10;

      // Time score
      if (days < 0) {
        score += 100; // Overdue is critical
        category = UrgencyCategory.critical;
        reasoning = 'This assignment is overdue by ${days.abs()} days.';
        action = 'Complete immediately to avoid severe penalty.';
      } else if (days == 0) {
        score += 80;
        category = UrgencyCategory.critical;
        reasoning = 'This is due today.';
        action = 'Finish and submit today.';
      } else if (days <= 2) {
        score += 60;
        category = UrgencyCategory.urgent;
        reasoning = 'Due in $days days with a ${a.priority} priority.';
        action = 'Prioritize working on this today.';
      } else if (days <= 7) {
        score += 30;
        category = a.priority == 'High' ? UrgencyCategory.high : UrgencyCategory.medium;
        reasoning = 'Coming up next week.';
        action = 'Start gathering materials or begin initial draft.';
      } else {
        score += 10;
        category = UrgencyCategory.planAhead;
        reasoning = 'Plenty of time left ($days days).';
        action = 'Keep it on your radar.';
      }

      suggestions.add(AISuggestion(
        title: 'Assignment: ${a.title}',
        subtitle: a.subject,
        reasoning: reasoning,
        action: action,
        category: category,
        score: score,
        relatedId: a.id,
      ));
    }

    // Analyze Exams
    for (var e in exams) {
      final days = Helpers.daysUntil(e.date);
      if (days < 0) continue; // Skip past exams

      int score = 30; // Base score for exam
      UrgencyCategory category;
      String action;
      String reasoning;

      if (days == 0) {
        score += 100;
        category = UrgencyCategory.critical;
        reasoning = 'You have an exam today!';
        action = 'Do final light review and rest well.';
      } else if (days <= 3) {
        score += 80;
        category = UrgencyCategory.urgent;
        reasoning = 'Exam is in $days days.';
        action = 'Intense focus on revision and mock papers.';
      } else if (days <= 7) {
        score += 50;
        category = UrgencyCategory.high;
        reasoning = 'Exam is next week.';
        action = 'Ensure all topics are covered, start active recall.';
      } else if (days <= 14) {
        score += 30;
        category = UrgencyCategory.planAhead;
        reasoning = 'Exam is in ${days ~/ 7} weeks.';
        action = 'Begin structured study schedule.';
      } else {
        score += 15;
        category = UrgencyCategory.planAhead;
        reasoning = 'Exam is far out ($days days).';
        action = 'Attend classes and take good notes.';
      }

      suggestions.add(AISuggestion(
        title: 'Exam: ${e.subject}',
        subtitle: '${e.date} at ${Helpers.formatTime(e.time)}',
        reasoning: reasoning,
        action: action,
        category: category,
        score: score,
        relatedId: e.id,
      ));
    }

    // Suggest considering today's class load
    if (todayClasses.isNotEmpty && suggestions.where((s) => s.category == UrgencyCategory.critical || s.category == UrgencyCategory.urgent).isEmpty) {
      suggestions.add(AISuggestion(
        title: 'Light Day Today',
        subtitle: '${todayClasses.length} classes scheduled',
        reasoning: 'You have classes today but no immediate pressing deadlines.',
        action: 'Use free time to look ahead or rest up.',
        category: UrgencyCategory.planAhead,
        score: 5,
      ));
    } else if (todayClasses.length >= 4) {
      // Very heavy class day penalty? Just an observation
       suggestions.add(AISuggestion(
        title: 'Heavy Class Load',
        subtitle: '${todayClasses.length} classes scheduled',
        reasoning: 'You have a packed schedule today.',
        action: 'Focus on attending and absorbing. Save heavy assignments for tomorrow.',
        category: UrgencyCategory.low,
        score: 2,
      ));
    }

    // Sort by score descending
    suggestions.sort((a, b) => b.score.compareTo(a.score));
    return suggestions;
  }

  static WorkloadSummary summarizeWorkload(List<AISuggestion> rankedSuggestions, int activeAssigns, int upExams) {
    int criticalCount = rankedSuggestions.where((s) => s.score >= 80).length;
    
    String advice = 'Looking clear! Keep up the good work.';
    if (criticalCount >= 3) {
      advice = 'You have a very heavy critical workload. Please focus entirely on urgent tasks and ignore long-term planning for now.';
    } else if (upExams > 0 && criticalCount > 0) {
      advice = 'Balance your time between immediate due dates and impending exams. Prioritize urgent assignments, but leave 1-2 hours for exam revision.';
    } else if (criticalCount > 0) {
      advice = 'A few urgent items require your immediate attention. Get them out of the way!';
    } else if (activeAssigns > 5) {
      advice = 'No immediate crises, but you have many pending tasks. Good time to knock out some ' + ((rankedSuggestions.firstOrNull?.category == UrgencyCategory.planAhead) ? 'long-term' : 'medium') + ' priority work.';
    }

    return WorkloadSummary(
      activeAssignments: activeAssigns,
      upcomingExams: upExams,
      criticalTasks: criticalCount,
      generalAdvice: advice,
    );
  }
}
