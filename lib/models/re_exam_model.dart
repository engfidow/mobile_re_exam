class ReExamModel {
  final String id;
  final String reason;
  final String phone;
  final List<String> subjects;
  final String status;
  final double totalFee;
  final DateTime createdAt;

  ReExamModel({
    required this.id,
    required this.reason,
    required this.phone,
    required this.subjects,
    required this.status,
    required this.totalFee,
    required this.createdAt,
  });

  factory ReExamModel.fromJson(Map<String, dynamic> json) {
    return ReExamModel(
      id: json['_id'],
      reason: json['reason'],
      phone: json['phone'],
      subjects: List<String>.from(json['subjects']),
      status: json['status'],
      totalFee: json['totalFee'].toDouble(),
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
}
