import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:reexam/screens/Sigin_screen.dart';
import '../providers/user_provider.dart';
import '../providers/student_provider.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    final userId = Provider.of<UserProvider>(context, listen: false).user?.id;
    if (userId != null) {
      Provider.of<StudentProvider>(context, listen: false).fetchStudent(userId);
    }
  }

  String formatDate(String dateString) {
    try {
      DateTime date = DateTime.parse(dateString);
      return DateFormat('dd MMM yyyy').format(date);
    } catch (_) {
      return dateString;
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserProvider>(context).user!;
    final student = Provider.of<StudentProvider>(context).student;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: const Text('My Profile', style: TextStyle(color: Colors.white,),),
        backgroundColor: Colors.redAccent,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white,),
            onPressed: () {
              Provider.of<UserProvider>(context, listen: false).logout();

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (e) => const SigIn(),
      ),
    );
            },
          )
        ],
      ),
      body: student == null
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 30),
                    decoration: const BoxDecoration(
                      color: Colors.redAccent,
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(30),
                        bottomRight: Radius.circular(30),
                      ),
                    ),
                    child: Column(
                      children: [
                        CircleAvatar(
                          radius: 50,
                          backgroundImage: NetworkImage(
                            'https://re-exam.onrender.com/${user.image}',
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          user.name!,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          user.email!,
                          style: const TextStyle(color: Colors.white70),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      children: [
                        profileField("Phone", student.phone),
                        profileField("Gender", user.gender!),
                     
                        profileField("Faculty", student.faculty['name'] ?? 'N/A'),
                        profileField("Class", student.classInfo['name'] ?? 'N/A'),
                        profileField("Address", student.address),
                        profileField("Date of Birth", formatDate(student.dateOfBirth)),
                        profileField("Emergency Contact", "${student.emergencyName} (${student.emergencyPhone})"),
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),
                ],
              ),
            ),
    );
  }

  Widget profileField(String title, String value) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("$title: ",
              style: const TextStyle(
                  fontWeight: FontWeight.bold, color: Colors.black87)),
          Expanded(
            child: Text(value, style: const TextStyle(color: Colors.black87)),
          ),
        ],
      ),
    );
  }
}
