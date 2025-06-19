import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:photo_view/photo_view.dart';
import 'package:provider/provider.dart';
import 'package:reexam/models/re_exam_model.dart';
import 'package:reexam/providers/re_exam_provider.dart';
import 'package:reexam/providers/student_provider.dart';
import 'package:reexam/providers/user_provider.dart';
import 'package:reexam/screens/re_exam_screen.dart';
import 'package:intl/intl.dart';
import 'package:awesome_dialog/awesome_dialog.dart';

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
    loadReExams();
  }

  Future<void> loadReExams() async {
    final userId = Provider.of<UserProvider>(context, listen: false).user?.id;
    if (userId != null) {
      await Provider.of<StudentProvider>(context, listen: false).fetchStudent(userId);
      final student = Provider.of<StudentProvider>(context, listen: false).student;
      if (student != null) {
        await Provider.of<ReExamProvider>(context, listen: false)
            .fetchReExamsByStudentId(student.id);
      }
    }
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
              imageProvider: CachedNetworkImageProvider('https://re-exam.onrender.com/$imageUrl'),
              backgroundDecoration: const BoxDecoration(color: Colors.black),
            ),
          ),
        ),
      ),
    );
  }

  void showReceiptModal(BuildContext context, ReExamModel exam) {
    final dateStr = DateFormat('MMM dd, yyyy – hh:mm a').format(exam.createdAt);
    AwesomeDialog(
      context: context,
      dialogType: DialogType.info,
      animType: AnimType.rightSlide,
      headerAnimationLoop: false,
      title: 'Re-Exam Receipt',
      desc: '',
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            buildReceiptRow("Phone", exam.phone),
            buildReceiptRow("Reason", exam.reason),
            buildReceiptRow("Subjects", exam.subjects.join(', ')),
            buildReceiptRow("Status", exam.status.toUpperCase()),
            buildReceiptRow("Total Fee", "\$${exam.totalFee.toStringAsFixed(2)}"),
            buildReceiptRow("Date", dateStr),
          ],
        ),
      ),
      btnOkOnPress: () {},
    ).show();
  }

  Widget buildReceiptRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("$label: ", style: const TextStyle(fontWeight: FontWeight.bold)),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);

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
                    const SizedBox(height: 20),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text("Latest Re-Exams",
                              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                          ElevatedButton.icon(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (_) => const ReExamRegisterScreen()),
                              );
                            },
                            icon: const Icon(Icons.add, color: Colors.white),
                            label: const Text("Register", style: TextStyle(color: Colors.white),),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.redAccent,
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                    buildReExamList(),
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
            "Hello, ${userProvider.user?.name ?? 'Guest'}\n${getGreetingMessage()}",
            style: GoogleFonts.poppins(
              textStyle: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
                color: Colors.white,
              ),
            ),
          ),
          GestureDetector(
            onTap: () => _showProfilePhoto(context, userProvider.user?.image ?? ""),
            child: CircleAvatar(
              radius: 40,
              backgroundImage: CachedNetworkImageProvider(
                'https://re-exam.onrender.com/${userProvider.user?.image ?? ""}',
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildReExamList() {
    final reExams = Provider.of<ReExamProvider>(context).reExams;

    if (reExams.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 30),
        child: Center(child: Text("No re-exams registered yet.")),
      );
    }

    final latest = reExams.take(10).toList();

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: latest.length,
      itemBuilder: (context, index) {
        final exam = latest[index];
        return GestureDetector(
          onTap: () => showReceiptModal(context, exam),
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border(
                left: BorderSide(
                    width: 5,
                    color: exam.status == 'approved'
                        ? Colors.green
                        : exam.status == 'rejected'
                            ? Colors.red
                            : Colors.orange),
              ),
              boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4)],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Subjects: ${exam.subjects.join(', ')}",
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text("Reason: ${exam.reason}"),
                Text("Status: ${exam.status.toUpperCase()}"),
                Text("Total Fee: \$${exam.totalFee.toStringAsFixed(2)}"),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget buildShimmerUI() {
    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: 6,
      itemBuilder: (context, index) {
        return Container(
          margin: const EdgeInsets.symmetric(vertical: 10),
          height: 120,
          decoration: BoxDecoration(
            color: Colors.grey[300],
            borderRadius: BorderRadius.circular(12),
          ),
        );
      },
    );
  }
}
