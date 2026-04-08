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
