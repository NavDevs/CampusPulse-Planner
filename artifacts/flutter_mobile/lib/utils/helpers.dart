class Helpers {
  static int daysUntil(String dateStr) {
    final target = DateTime.tryParse(dateStr);
    if (target == null) return 9999;
    final t = DateTime(target.year, target.month, target.day);
    final now = DateTime.now();
    final n = DateTime(now.year, now.month, now.day);
    return t.difference(n).inDays;
  }

  static String formatTime(String time) {
    final parts = time.split(':');
    if (parts.isEmpty) return time;
    final h = int.tryParse(parts[0]) ?? 0;
    final m = parts.length > 1 ? parts[1] : '00';
    final ampm = h >= 12 ? 'PM' : 'AM';
    final hh = h % 12 == 0 ? 12 : h % 12;
    return '$hh:$m $ampm';
  }

  static String dueLabel(String date) {
    final d = daysUntil(date);
    if (d < 0) return '${d.abs()}d overdue';
    if (d == 0) return 'Due today';
    if (d == 1) return 'Due tomorrow';
    return '$d days left';
  }
}
