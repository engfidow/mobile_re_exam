import 'package:flutter/foundation.dart';
import 'package:reexam/models/re_exam_model.dart';
import 'package:reexam/services/re_exam_service.dart';


class ReExamProvider with ChangeNotifier {
  final ReExamService _service = ReExamService();
  List<ReExamModel> _reExams = [];

  List<ReExamModel> get reExams => _reExams;

  Future<void> fetchReExamsByStudentId(String studentId) async {
    print(studentId);
    _reExams = await _service.getReExamsByStudent(studentId);
    notifyListeners();
  }

  Future<bool> registerReExam(Map<String, dynamic> data) async {
    final result = await _service.registerReExam(data);
    if (result) await fetchReExamsByStudentId(data['studentId']);
    return result;
  }
}
