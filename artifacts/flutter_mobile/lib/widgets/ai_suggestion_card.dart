import 'package:flutter/material.dart';
import '../ai/priority_engine.dart';
import 'priority_badge.dart';
import 'glass_card.dart';

class AISuggestionCard extends StatelessWidget {
  final AISuggestion suggestion;
  
  const AISuggestionCard({super.key, required this.suggestion});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    IconData icon;
    Color iconColor;
    switch (suggestion.category) {
      case UrgencyCategory.critical:
        icon = Icons.warning_rounded;
        iconColor = Colors.red;
        break;
      case UrgencyCategory.urgent:
        icon = Icons.priority_high_rounded;
        iconColor = Colors.deepOrange;
        break;
      case UrgencyCategory.high:
        icon = Icons.trending_up_rounded;
        iconColor = Colors.orange;
        break;
      case UrgencyCategory.medium:
        icon = Icons.linear_scale_rounded;
        iconColor = Colors.amber;
        break;
      case UrgencyCategory.planAhead:
        icon = Icons.calendar_month_rounded;
        iconColor = Colors.blue;
        break;
      case UrgencyCategory.low:
        icon = Icons.low_priority_rounded;
        iconColor = Colors.green;
        break;
    }

    return GlassCard(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: iconColor, size: 24),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        suggestion.title,
                        style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    PriorityBadge(priority: suggestion.category.name),
                  ],
                ),
                if (suggestion.subtitle.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    suggestion.subtitle,
                    style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                  ),
                ],
                const SizedBox(height: 8),
                Text(
                  suggestion.reasoning,
                  style: theme.textTheme.bodyMedium,
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Icon(Icons.tips_and_updates_rounded, size: 14, color: theme.colorScheme.primary),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        suggestion.action,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
