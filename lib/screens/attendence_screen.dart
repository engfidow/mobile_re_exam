import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import '../providers/user_provider.dart';
import '../providers/attendance_provider.dart';
import '../models/attendance_model.dart';

class AttendenceScreen extends StatefulWidget {
  const AttendenceScreen({super.key});

  @override
  _AttendenceScreenState createState() => _AttendenceScreenState();
}

class _AttendenceScreenState extends State<AttendenceScreen> {
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> loadData() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final studentId = userProvider.user?.id ?? '';

    await Provider.of<AttendanceProvider>(context, listen: false)
        .fetchAttendance(studentId);
    if (mounted) setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    final attendance = Provider.of<AttendanceProvider>(context).records;

    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),
      
      body: _loading
          ? buildShimmerList()
          : ListView.builder(
              itemCount: attendance.length,
              itemBuilder: (context, index) {
                final record = attendance[index];
                final dateStr = DateFormat('MMM dd, yyyy').format(record.date);
                final isPresent = record.status == 'present';

                return buildAttendanceItem(
                  subjectName: record.subjectName,
                  className: record.className,
                  day: record.day,
                  date: dateStr,
                  timeScanned: record.timeScanned ?? "-",
                  isPresent: isPresent,
                );
              },
            ),
    );
  }

  // Reusable shimmer widget
  Widget buildShimmerList() {
    return ListView.builder(
      itemCount: 6,
      itemBuilder: (context, index) {
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: const Border(
              left: BorderSide(
                color: Colors.grey, // static shimmer border
                width: 6,
              ),
            ),
            boxShadow: const [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 4,
                offset: Offset(2, 2),
              ),
            ],
          ),
          child: Shimmer.fromColors(
            baseColor: Colors.grey[300]!,
            highlightColor: Colors.grey[100]!,
            child: ListTile(
              title: Container(
                height: 20,
                width: double.infinity,
                color: Colors.white,
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 8),
                  Container(
                    height: 15,
                    width: 150,
                    color: Colors.white,
                  ),
                  const SizedBox(height: 5),
                  Container(
                    height: 15,
                    width: 100,
                    color: Colors.white,
                  ),
                ],
              ),
              trailing: Container(
                width: 50,
                height: 20,
                color: Colors.white,
              ),
            ),
          ),
        );
      },
    );
  }

  // Reusable item widget
  Widget buildAttendanceItem({
    required String subjectName,
    required String className,
    required String day,
    required String date,
    required String timeScanned,
    required bool isPresent,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border(
          left: BorderSide(
            color: isPresent ? Colors.green : Colors.red,
            width: 6,
          ),
        ),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 4,
            offset: Offset(2, 2),
          ),
        ],
      ),
      child: ListTile(
        title: Text('$subjectName - $className'),
        subtitle: Text('$day, $date\nTime: $timeScanned'),
        trailing: Text(
          isPresent ? "Present" : "Absent",
          style: TextStyle(
            color: isPresent ? Colors.green : Colors.red,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
