import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconly/iconly.dart';
import 'package:intl/intl.dart';
import 'package:photo_view/photo_view.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import 'package:pie_chart/pie_chart.dart';
import '../providers/user_provider.dart';
import '../providers/attendance_provider.dart';
import '../models/attendance_model.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool loading = true;

  @override
  void initState() {
    super.initState();
    loadAttendance();
  }

  Future<void> loadAttendance() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final studentId = userProvider.user?.id ?? '';

    await Provider.of<AttendanceProvider>(context, listen: false)
        .fetchAttendance(studentId);
    if (mounted) setState(() => loading = false);
  }

  String getGreetingMessage() {
    final hour = DateTime.now().hour;
    if (hour < 12) return "Good Morning";
    if (hour < 17) return "Good Afternoon";
    return "Good Evening";
  }

  void _showProfilePhoto(BuildContext context, String imageUrl) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Scaffold(
          backgroundColor: Colors.black,
          body: Center(
            child: PhotoView(
              imageProvider: CachedNetworkImageProvider(
                  'http://192.168.8.26:5000/$imageUrl'),
              backgroundDecoration: const BoxDecoration(color: Colors.black),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final attendance = Provider.of<AttendanceProvider>(context).records;

    int total = attendance.length;
    int present = attendance.where((e) => e.status == 'present').length;
    int absent = total - present;
    double presentRate = total > 0 ? (present / total * 100) : 0;

    Map<String, int> subjectAbsence = {};
    for (var record in attendance) {
      if (record.status == 'absent') {
        subjectAbsence[record.subjectName] =
            (subjectAbsence[record.subjectName] ?? 0) + 1;
      }
    }

    String? warningMsg;
    subjectAbsence.forEach((subject, count) {
      if (count == 4) {
        warningMsg = '⚠ You have 4 absences in $subject';
      } else if (count >= 5) {
        warningMsg = '❌ You are blocked from exam in $subject';
      }
    });

    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),
      body: SafeArea(
        child: loading
            ? buildShimmerUI()
            : SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    buildHeader(userProvider),
                    if (warningMsg != null) buildWarningBox(warningMsg!),
                    const SizedBox(height: 15),
                    buildPieChart(present, absent),
                    const SizedBox(height: 15),
                    buildStats(total, present, absent, presentRate),
                    const SizedBox(height: 20),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: const Text("Recent Attendance",
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold)),
                    ),
                    const SizedBox(height: 10),
                    buildAttendanceList(attendance),
                  ],
                ),
              ),
      ),
    );
  }

  Widget buildHeader(userProvider) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      height: 160,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFDC143C), Color.fromARGB(158, 237, 48, 85)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 5)],
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(40),
          bottomRight: Radius.circular(40),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            "Hello,${userProvider.user?.name ?? 'Guest'}\n${getGreetingMessage()}",
            style: GoogleFonts.poppins(
              textStyle: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
                color: Colors.white,
              ),
            ),
          ),
          GestureDetector(
            onTap: () =>
                _showProfilePhoto(context, userProvider.user?.image ?? ""),
            child: CircleAvatar(
              radius: 40,
              backgroundImage: CachedNetworkImageProvider(
                'http://192.168.8.26:5000/${userProvider.user?.image ?? ""}',
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildWarningBox(String warningMsg) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: warningMsg.contains('❌') ? Colors.red[100] : Colors.yellow[100],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.black12),
      ),
      child: Row(
        children: [
          Icon(
            warningMsg.contains('❌') ? Icons.block : Icons.warning,
            color: warningMsg.contains('❌') ? Colors.red : Colors.orange,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(warningMsg, style: const TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget buildPieChart(int present, int absent) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: PieChart(
        dataMap: {
          "Present": present.toDouble(),
          "Absent": absent.toDouble(),
        },
        chartRadius: MediaQuery.of(context).size.width / 2.0,
        colorList: const [Colors.green, Colors.red],
        chartValuesOptions: const ChartValuesOptions(showChartValuesInPercentage: true),
      ),
    );
  }

  Widget buildStats(int total, int present, int absent, double presentRate) {
  return Container(
    margin: const EdgeInsets.symmetric(horizontal: 20),
    padding: const EdgeInsets.all(15),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 5)],
    ),
    child: Column(
      children: [
        buildStatRow("Total Periods", total.toString(), IconlyBold.document),
        buildStatRow("Present Periods", present.toString(), IconlyBold.show),
        buildStatRow("Absent Periods", absent.toString(), IconlyBold.hide),
        buildStatRow("Present Rate", "${presentRate.toStringAsFixed(1)}%", IconlyBold.graph),
      ],
    ),
  );
}


  Widget buildStatRow(String title, String value, IconData icon) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 5),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFFDC143C).withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: const Color(0xFFDC143C), size: 20),
            ),
            const SizedBox(width: 10),
            Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
          ],
        ),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
      ],
    ),
  );
}

  Widget buildAttendanceList(List<AttendanceModel> attendance) {
    return ListView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: attendance.length < 6 ? attendance.length : 6,
      itemBuilder: (context, index) {
        final record = attendance[index];
        final dateStr = DateFormat('MMM dd, yyyy').format(record.date);
        final isPresent = record.status == 'present';

        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border(
              left: BorderSide(
                  color: isPresent ? Colors.green : Colors.red, width: 5),
            ),
            borderRadius: BorderRadius.circular(12),
            boxShadow: const [
              BoxShadow(color: Colors.black12, blurRadius: 5),
            ],
          ),
          child: ListTile(
            title: Text('${record.subjectName} - ${record.className}'),
            subtitle: Text('${record.day}, $dateStr\nTime: ${record.timeScanned ?? "-"}'),
            trailing: Text(
              isPresent ? "Present" : "Absent",
              style: TextStyle(
                color: isPresent ? Colors.green : Colors.red,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        );
      },
    );
  }

  // Beautiful shimmer loader:
  Widget buildShimmerUI() {
    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: 6,
      itemBuilder: (context, index) {
        return Shimmer.fromColors(
          baseColor: Colors.grey[300]!,
          highlightColor: Colors.grey[100]!,
          child: Container(
            margin: const EdgeInsets.symmetric(vertical: 10),
            height: 140,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      },
    );
  }
}
