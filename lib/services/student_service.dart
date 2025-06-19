import 'dart:convert';
import 'package:reexam/models/student_model.dart';
import 'package:http/http.dart' as http;

class StudentService {
  final String baseUrl = 'https://re-exam.onrender.com/api/students';

  Future<StudentModel?> getStudentByUserId(String userId) async {
  final response = await http.get(Uri.parse('$baseUrl'));

  if (response.statusCode == 200) {
    List data = json.decode(response.body);
    final filtered = data.where((s) => s['user']['_id'] == userId);
    if (filtered.isNotEmpty) {
      return StudentModel.fromJson(filtered.first);
    }
  }

  return null;
}

}
