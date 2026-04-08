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
