import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import 'package:qrcode/providers/user_provider.dart';
import '../providers/schedule_provider.dart';
import '../providers/student_provider.dart';

class Periods extends StatefulWidget {
  const Periods({super.key});

  @override
  State<Periods> createState() => _PeriodsState();
}

class _PeriodsState extends State<Periods> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      final studentProvider = context.read<StudentProvider>();
      final userProvider = context.read<UserProvider>();
      final userId = userProvider.user?.id ?? '';
      await studentProvider.fetchStudent(userId);
      final classId = studentProvider.student?.classId;
      if (classId != null && classId.isNotEmpty) {
        context.read<ScheduleProvider>().fetchSchedulesByClass(classId);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final schedules = context.watch<ScheduleProvider>().schedules;
    final isLoading = context.watch<ScheduleProvider>().isLoading;

    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),
      
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: isLoading
            ? ListView.builder(
                itemCount: 3,
                itemBuilder: (context, index) => Shimmer.fromColors(
                  baseColor: Colors.grey.shade300,
                  highlightColor: Colors.grey.shade100,
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    height: 120,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
              )
            : schedules.isEmpty
                ? const Center(
                    child: Text(
                      "No schedule available.",
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  )
                : ListView.builder(
                    itemCount: schedules.length,
                    itemBuilder: (context, index) {
                      final schedule = schedules[index];
                      return Card(
                        elevation: 4,
                        shadowColor: Colors.black12,
                        color: Colors.white, // ✅ White background
                        margin: const EdgeInsets.only(bottom: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Icon(Icons.book, color: Colors.red),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      schedule.subjectName,
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.red,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Column(
                                children: schedule.schedule.map((item) {
                                  return Container(
                                    margin: const EdgeInsets.only(top: 8),
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 10, horizontal: 12),
                                    decoration: BoxDecoration(
                                      color: Colors.red.shade50,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Row(
                                          children: [
                                            const Icon(Icons.calendar_today,
                                                size: 16, color: Colors.red),
                                            const SizedBox(width: 6),
                                            Text(
                                              item.day,
                                              style: const TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.w500,
                                                color: Colors.black87,
                                              ),
                                            ),
                                          ],
                                        ),
                                        Row(
                                          children: [
                                            const Icon(Icons.access_time,
                                                size: 16, color: Colors.red),
                                            const SizedBox(width: 6),
                                            Text(
                                              '${item.startTime} - ${item.endTime}',
                                              style: const TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.w500,
                                                color: Colors.black87,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  );
                                }).toList(),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
      ),
    );
  }
}
