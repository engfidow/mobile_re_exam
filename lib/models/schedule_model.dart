class ScheduleItem {
  final String day;
  final String startTime;
  final String endTime;

  ScheduleItem({
    required this.day,
    required this.startTime,
    required this.endTime,
  });

  factory ScheduleItem.fromJson(Map<String, dynamic> json) {
    return ScheduleItem(
      day: json['day'] ?? '',
      startTime: json['startTime'] ?? '',
      endTime: json['endTime'] ?? '',
    );
  }
}

class ScheduleModel {
  final String id;
  final String subjectName;
  final String teacherName;
  final List<ScheduleItem> schedule;

  ScheduleModel({
    required this.id,
    required this.subjectName,
    required this.teacherName,
    required this.schedule,
  });

  factory ScheduleModel.fromJson(Map<String, dynamic> json) {
    return ScheduleModel(
      id: json['_id'] ?? '',
      subjectName: json['subject']?['name'] ?? 'Unknown Subject',
      teacherName: json['teacher']?['name'] ?? 'Unknown Teacher',
      schedule: (json['schedule'] as List<dynamic>)
          .map((item) => ScheduleItem.fromJson(item))
          .toList(),
    );
  }
}
