import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/schedule_model.dart';

class ScheduleService {
  final String baseUrl = 'https://re-exam.onrender.com/api/schedules';

  Future<List<ScheduleModel>> getSchedulesByClassId(String classId) async {
    print("object");
    
    
    final response = await http.get(Uri.parse('$baseUrl/class/$classId'));
    print(response.statusCode);
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => ScheduleModel.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load schedule');
    }
  }
}
