import 'dart:convert';
import 'package:http/http.dart' as http;

class SubjectService {
  Future<List<String>> getSubjectsByFacultyId(String facultyId) async {
    final res = await http.get(Uri.parse('https://re-exam.onrender.com/api/subjects/faculty/$facultyId'));
    if (res.statusCode == 200) {
      final data = json.decode(res.body);
      return List<String>.from(data.map((item) => item['name']));
    } else {
      throw Exception('Failed to load subjects');
    }
  }
}
