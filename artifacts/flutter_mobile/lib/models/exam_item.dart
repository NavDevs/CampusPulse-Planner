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
