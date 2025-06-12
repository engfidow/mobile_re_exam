class StudentModel {
  final Map<String, dynamic> user;
  final String phone;
  final Map<String, dynamic> faculty;
  final Map<String, dynamic> classInfo;
  final String address;
  final String dateOfBirth;
  final String emergencyName;
  final String emergencyPhone;

  StudentModel({
    required this.user,
    required this.phone,
    required this.faculty,
    required this.classInfo,
    required this.address,
    required this.dateOfBirth,
    required this.emergencyName,
    required this.emergencyPhone,
  });

  factory StudentModel.fromJson(Map<String, dynamic> json) {
    return StudentModel(
      user: json['user'],
      phone: json['phone'],
      faculty: json['faculty'],
      classInfo: json['class'],
      address: json['address'] ?? '',
      dateOfBirth: json['dateOfBirth'] ?? '',
      emergencyName: json['emergencyName'] ?? '',
      emergencyPhone: json['emergencyPhone'] ?? '',
    );
  }

  String get classId => classInfo['_id']; // 👈 This solves your classId error
  
}
