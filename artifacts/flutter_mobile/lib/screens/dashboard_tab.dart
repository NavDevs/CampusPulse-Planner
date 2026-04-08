import 'package:flutter/material.dart';
import '../store/app_store.dart';
import '../utils/helpers.dart';
import '../widgets/stat_card.dart';
import '../widgets/glass_card.dart';
import '../widgets/priority_badge.dart';
import '../ai/priority_engine.dart';
import '../widgets/ai_suggestion_card.dart';

class DashboardTab extends StatelessWidget {
  const DashboardTab({super.key, required this.store, required this.today});

  final AppStore store;
  final String today;

  @override
  Widget build(BuildContext context) {
    final todayClasses = store.timetable.where((e) => e.day == today).toList()..sort((a, b) => a.startTime.compareTo(b.startTime));
    final pending = store.assignments.where((a) => !a.completed).toList()..sort((a, b) => Helpers.daysUntil(a.dueDate).compareTo(Helpers.daysUntil(b.dueDate)));
    final upcomingExam = (store.exams.where((e) => Helpers.daysUntil(e.date) >= 0).toList()..sort((a, b) => Helpers.daysUntil(a.date).compareTo(Helpers.daysUntil(b.date)))).firstOrNull;
    
    // Get AI Suggestions
    final suggestions = PriorityEngine.analyze(store.assignments, store.exams, todayClasses);
    final topSuggestion = suggestions.where((s) => s.score >= 50).firstOrNull;

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(today, style: theme.textTheme.titleMedium?.copyWith(color: theme.colorScheme.primary)),
                  const SizedBox(height: 4),
                  Text('Overview', style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold)),
                ],
              ),
              CircleAvatar(
                backgroundColor: theme.colorScheme.primaryContainer,
                radius: 24,
                child: Icon(Icons.person, color: theme.colorScheme.primary),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Stats Row
          Row(
            children: [
              StatCard(label: 'Classes', value: '${todayClasses.length}', icon: Icons.menu_book_rounded, iconColor: theme.colorScheme.primary),
              const SizedBox(width: 12),
              StatCard(label: 'Pending', value: '${pending.length}', icon: Icons.assignment_rounded, iconColor: theme.colorScheme.tertiary),
              const SizedBox(width: 12),
              StatCard(label: 'Exams', value: '${store.exams.where((e) { final d = Helpers.daysUntil(e.date); return d >= 0 && d <= 7; }).length}', icon: Icons.school_rounded, iconColor: theme.colorScheme.secondary),
            ],
          ),
          const SizedBox(height: 24),

          // AI Suggestion Integration
          if (topSuggestion != null) ...[
            Row(
              children: [
                Icon(Icons.auto_awesome, size: 18, color: theme.colorScheme.primary),
                const SizedBox(width: 8),
                Text('Top Priority', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 12),
            AISuggestionCard(suggestion: topSuggestion),
            const SizedBox(height: 24),
          ],

          // Today's Classes
          Text('Today\'s Schedule', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          if (todayClasses.isEmpty) 
            const GlassCard(child: Center(child: Text('Free day! No classes scheduled.', style: TextStyle(fontStyle: FontStyle.italic))))
          else
            ...todayClasses.map((c) => GlassCard(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  Container(
                    width: 4,
                    height: 40,
                    decoration: BoxDecoration(color: theme.colorScheme.primary, borderRadius: BorderRadius.circular(4)),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(c.subjectName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(Icons.access_time_rounded, size: 14, color: theme.colorScheme.onSurfaceVariant),
                            const SizedBox(width: 4),
                            Text('${Helpers.formatTime(c.startTime)} - ${Helpers.formatTime(c.endTime)}', style: theme.textTheme.bodySmall),
                            const SizedBox(width: 12),
                            Icon(Icons.location_on_rounded, size: 14, color: theme.colorScheme.onSurfaceVariant),
                            const SizedBox(width: 4),
                            Text(c.classroom, style: theme.textTheme.bodySmall),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            )),

          const SizedBox(height: 24),

          // Assignments
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Pending Assignments', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
              if (pending.isNotEmpty)
                Text('${pending.length} tasks', style: theme.textTheme.bodySmall),
            ],
          ),
          const SizedBox(height: 12),
          if (pending.isEmpty)
             const GlassCard(child: Center(child: Text('All caught up!', style: TextStyle(fontStyle: FontStyle.italic))))
          else
            ...pending.take(3).map((a) => GlassCard(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(a.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                        const SizedBox(height: 4),
                        Text('${a.subject} • ${Helpers.dueLabel(a.dueDate)}', style: theme.textTheme.bodySmall),
                      ],
                    ),
                  ),
                  PriorityBadge(priority: a.priority),
                ],
              ),
            )),

          const SizedBox(height: 24),
          
          // Next Exam
          Text('Next Exam', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          if (upcomingExam == null)
            const GlassCard(child: Center(child: Text('No upcoming exams.', style: TextStyle(fontStyle: FontStyle.italic))))
          else
            GlassCard(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(color: theme.colorScheme.secondary.withOpacity(0.15), borderRadius: BorderRadius.circular(12)),
                    child: Icon(Icons.school_rounded, color: theme.colorScheme.secondary),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(upcomingExam.subject, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        const SizedBox(height: 4),
                        Text('${upcomingExam.date} ${Helpers.formatTime(upcomingExam.time)} • ${upcomingExam.hall}', style: theme.textTheme.bodySmall),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(color: theme.colorScheme.primaryContainer, borderRadius: BorderRadius.circular(8)),
                    child: Text('${Helpers.daysUntil(upcomingExam.date)}d', style: TextStyle(color: theme.colorScheme.primary, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
