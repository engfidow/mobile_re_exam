import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../models/attendance_model.dart';

class AttendanceProvider with ChangeNotifier {
  List<AttendanceModel> _records = [];

  List<AttendanceModel> get records => _records;

  Future<void> fetchAttendance(String studentId) async {
    final url = Uri.parse('http://192.168.8.26:5000/api/attendance/history/$studentId');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      _records = data.map((json) => AttendanceModel.fromJson(json)).toList();
      notifyListeners();
    } else {
      throw Exception('Failed to load attendance');
    }
  }
}
