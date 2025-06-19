import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:reexam/models/re_exam_model.dart';


class ReExamService {
  final String baseUrl = 'https://re-exam.onrender.com/api/reexams';

  Future<List<ReExamModel>> getReExamsByStudent(String studentId) async {
    final res = await http.get(Uri.parse('$baseUrl/student/$studentId'));
    if (res.statusCode == 200) {
      final List data = json.decode(res.body);
      return data.map((e) => ReExamModel.fromJson(e)).toList();
    } else {
      throw Exception('Failed to load re-exams');
    }
  }

  Future<bool> registerReExam(Map<String, dynamic> payload) async {
    final res = await http.post(
      Uri.parse(baseUrl),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(payload),
    );
    return res.statusCode == 201;
  }
}
