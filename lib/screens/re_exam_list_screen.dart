import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:reexam/models/re_exam_model.dart';
import 'package:reexam/providers/re_exam_provider.dart';
import 'package:reexam/providers/student_provider.dart';
import 'package:shimmer/shimmer.dart';

class ReExamListScreen extends StatefulWidget {
  const ReExamListScreen({Key? key}) : super(key: key);

  @override
  State<ReExamListScreen> createState() => _ReExamListScreenState();
}

class _ReExamListScreenState extends State<ReExamListScreen> {
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadReExams();
  }

  Future<void> loadReExams() async {
  final student = Provider.of<StudentProvider>(context, listen: false).student;
  if (student != null) {
    await Provider.of<ReExamProvider>(context, listen: false)
        .fetchReExamsByStudentId(student.id);
  }

  if (mounted) {
    setState(() => isLoading = false);
  }
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

  Color getStatusColor(String status) {
    switch (status) {
      case 'approved':
        return Colors.green;
      case 'rejected':
        return Colors.red;
      default:
        return Colors.orange;
    }
  }

  Widget buildShimmerItem() {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        height: 120,
        width: double.infinity,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final reExams = Provider.of<ReExamProvider>(context).reExams;

    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),
      body: isLoading
          ? ListView.builder(
              padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16, top: 60),
              itemCount: 6,
              itemBuilder: (context, index) => buildShimmerItem(),
            )
          : reExams.isEmpty
              ? const Center(child: Text('No re-exam requests found.'))
              : ListView.builder(
                  padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16, top: 60),
                  itemCount: reExams.length,
                  itemBuilder: (context, index) {
                    final exam = reExams[index];
                    final dateStr = DateFormat('MMM dd, yyyy').format(exam.createdAt);

                    return Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border(
                          left: BorderSide(
                            color: getStatusColor(exam.status),
                            width: 5,
                          ),
                        ),
                      ),
                      child: ListTile(
                        onTap: () => showReceiptModal(context, exam),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        title: Text(
                          exam.subjects.join(', '),
                          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 6),
                            Text("Reason: ${exam.reason}", style: GoogleFonts.poppins()),
                            Text("Status: ${exam.status.toUpperCase()}",
                                style: GoogleFonts.poppins(
                                  color: getStatusColor(exam.status),
                                )),
                            Text("Total: \$${exam.totalFee.toStringAsFixed(2)}",
                                style: GoogleFonts.poppins(fontSize: 13)),
                            Text("Date: $dateStr", style: GoogleFonts.poppins(fontSize: 12)),
                          ],
                        ),
                        trailing: const Icon(Icons.receipt_long_rounded, color: Colors.deepPurple),
                      ),
                    ).animate().fade(duration: 400.ms).slideY(begin: 0.2, curve: Curves.easeOut);
                  },
                ),
    );
  }
}
