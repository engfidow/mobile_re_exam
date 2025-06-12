import 'package:flutter/foundation.dart';
import '../models/student_model.dart';
import '../services/student_service.dart';

class StudentProvider with ChangeNotifier {
  StudentModel? _student;
  final StudentService _studentService = StudentService();

  StudentModel? get student => _student;

  Future<void> fetchStudent(String userId) async {
    _student = await _studentService.getStudentByUserId(userId);
    notifyListeners();
  }
}
