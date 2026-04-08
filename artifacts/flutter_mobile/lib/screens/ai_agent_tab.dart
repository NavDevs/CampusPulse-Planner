import 'package:flutter/material.dart';
import '../store/app_store.dart';
import '../ai/priority_engine.dart';
import '../utils/helpers.dart';
import '../widgets/glass_card.dart';
import '../widgets/ai_suggestion_card.dart';

class AIAgentTab extends StatelessWidget {
  const AIAgentTab({super.key, required this.store});
  final AppStore store;

  @override
  Widget build(BuildContext context) {
    final today = AppStore.days[DateTime.now().weekday - 1];
    final todayClasses = store.timetable.where((e) => e.day == today).toList();
    
    // Run rule-based AI Priority Engine
    final suggestions = PriorityEngine.analyze(store.assignments, store.exams, todayClasses);
    final summary = PriorityEngine.summarizeWorkload(suggestions, store.assignments.where((a) => !a.completed).length, store.exams.where((e) => Helpers.daysUntil(e.date) >= 0).length);

    final theme = Theme.of(context);
    
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Container(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [theme.colorScheme.primary.withOpacity(0.1), theme.colorScheme.background],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                )
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.auto_awesome, color: theme.colorScheme.primary, size: 28),
                      const SizedBox(width: 8),
                      Text('Pulse AI', style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 16),
                  GlassCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.insights_rounded, color: theme.colorScheme.secondary, size: 20),
                            const SizedBox(width: 8),
                            Text('Workload Summary', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(summary.generalAdvice, style: theme.textTheme.bodyMedium),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _buildMiniStat(context, '${summary.criticalTasks}', 'Critical', theme.colorScheme.error),
                            _buildMiniStat(context, '${summary.upcomingExams}', 'Exams', theme.colorScheme.secondary),
                            _buildMiniStat(context, '${summary.activeAssignments}', 'Pending', theme.colorScheme.tertiary),
                          ],
                        )
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          if (suggestions.isEmpty)
            SliverFillRemaining(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.check_circle_outline, size: 64, color: theme.colorScheme.secondary.withOpacity(0.5)),
                    const SizedBox(height: 16),
                    Text('Nothing requires your attention. Relax!', style: theme.textTheme.titleMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
                  ],
                ),
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.all(16),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    if (index == 0) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12, left: 4),
                        child: Text(
                          'Priority Recommendations',
                          style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                        ),
                      );
                    }
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: AISuggestionCard(suggestion: suggestions[index - 1]),
                    );
                  },
                  childCount: suggestions.length + 1,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildMiniStat(BuildContext context, String value, String label, Color color) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Text(value, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 18)),
        ),
        const SizedBox(height: 6),
        Text(label, style: Theme.of(context).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w500)),
      ],
    );
  }
}
