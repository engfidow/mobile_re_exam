class AttendanceModel {
  final String subjectName;
  final String className;
  final String day;
  final DateTime date;
  final String? timeScanned;
  final String status;

  AttendanceModel({
    required this.subjectName,
    required this.className,
    required this.day,
    required this.date,
    required this.timeScanned,
    required this.status,
  });

  factory AttendanceModel.fromJson(Map<String, dynamic> json) {
    return AttendanceModel(
      subjectName: json['subjectName'],
      className: json['className'],
      day: json['day'],
      date: DateTime.parse(json['date']),
      timeScanned: json['timeScanned'],
      status: json['status'],
    );
  }
}
