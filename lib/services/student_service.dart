import 'dart:convert';
import 'package:qrcode/models/student_model.dart';
import 'package:http/http.dart' as http;

class StudentService {
  final String baseUrl = 'http://192.168.8.26:5000/api/students';

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
