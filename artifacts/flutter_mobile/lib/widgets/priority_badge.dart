import 'package:flutter/material.dart';
import '../ai/priority_engine.dart';

class PriorityBadge extends StatelessWidget {
  final String priority;
  
  const PriorityBadge({super.key, required this.priority});

  @override
  Widget build(BuildContext context) {
    Color bg;
    Color fg;
    
    // Support string priorities or enum names
    String p = priority.toLowerCase();
    
    if (p == 'high' || p == 'critical' || p == 'urgent') {
      bg = Colors.red.shade100;
      fg = Colors.red.shade800;
    } else if (p == 'medium') {
      bg = Colors.amber.shade100;
      fg = Colors.amber.shade900;
    } else if (p == 'low' || p.contains('planahead')) {
      bg = Colors.green.shade100;
      fg = Colors.green.shade800;
    } else {
      bg = Colors.grey.shade200;
      fg = Colors.grey.shade800;
    }
    
    // Check dark mode for adjustments
    if (Theme.of(context).brightness == Brightness.dark) {
      if (p == 'high' || p == 'critical' || p == 'urgent') {
        bg = Colors.red.shade900.withOpacity(0.4);
        fg = Colors.red.shade200;
      } else if (p == 'medium') {
        bg = Colors.amber.shade900.withOpacity(0.4);
        fg = Colors.amber.shade200;
      } else if (p == 'low' || p.contains('planahead')) {
        bg = Colors.green.shade900.withOpacity(0.4);
        fg = Colors.green.shade200;
      } else {
        bg = Colors.grey.shade800;
        fg = Colors.grey.shade300;
      }
    }

    String labelText = priority;
    if (priority == UrgencyCategory.planAhead.name) labelText = 'Plan Ahead';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        labelText,
        style: TextStyle(
          color: fg,
          fontSize: 10,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}
