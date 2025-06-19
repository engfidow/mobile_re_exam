import 'package:flutter/material.dart';
import 'package:reexam/models/schedule_model.dart';
import 'package:reexam/services/schedule_service.dart';

class ScheduleProvider with ChangeNotifier {
  List<ScheduleModel> _schedules = [];
  bool _isLoading = false;

  List<ScheduleModel> get schedules => _schedules;
  bool get isLoading => _isLoading;

  Future<void> fetchSchedulesByClass(String classId) async {
    _isLoading = true;
    print(classId);
    notifyListeners();

    try {
      final data = await ScheduleService().getSchedulesByClassId(classId);
      _schedules = data;
    } catch (e) {
      print("Error fetching schedules: $e");
    }

    _isLoading = false;
    notifyListeners();
  }
}
