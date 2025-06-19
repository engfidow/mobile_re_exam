import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:multi_select_flutter/multi_select_flutter.dart';
import 'package:provider/provider.dart';
import 'package:reexam/providers/re_exam_provider.dart';
import 'package:reexam/providers/student_provider.dart';
import 'package:reexam/services/SubjectService.dart';
import 'package:form_builder_validators/form_builder_validators.dart';



class ReExamRegisterScreen extends StatefulWidget {
  const ReExamRegisterScreen({Key? key}) : super(key: key);

  @override
  State<ReExamRegisterScreen> createState() => _ReExamRegisterScreenState();
}

class _ReExamRegisterScreenState extends State<ReExamRegisterScreen> {
  final _formKey = GlobalKey<FormBuilderState>();
  final TextEditingController _phoneController = TextEditingController();
  List<String> subjectOptions = [];
  List<String> selectedSubjects = [];
  bool isLoading = false;
  bool subjectLoading = true;

  final List<Map<String, String>> reasonOptions = [
    {'value': 'medical', 'label': 'Medical Reason'},
    {'value': 'family', 'label': 'Family Emergency'},
    {'value': 'attendence', 'label': 'Attendance Issue'},
    {'value': 'payment', 'label': 'Payment Issue'},
    {'value': 'failed_exam', 'label': 'Failed Exam'},
  ];

  @override
  void initState() {
    super.initState();
    loadStudentAndSubjects();
  }

  Future<void> loadStudentAndSubjects() async {
    final student = Provider.of<StudentProvider>(context, listen: false).student;
    if (student != null) {
      _phoneController.text = student.phone;
      final result = await SubjectService().getSubjectsByFacultyId(student.faculty['_id']);
      setState(() {
        subjectOptions = result;
        subjectLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final student = Provider.of<StudentProvider>(context).student;
    final reExamProvider = Provider.of<ReExamProvider>(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Register Re-Exam')),
      body: student == null
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16),
              child: FormBuilder(
                key: _formKey,
                child: ListView(
                  children: [
                    Text(
                      "Student: ${student.user['name']}",
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    const SizedBox(height: 20),

                    FormBuilderTextField(
                      name: 'phone',
                      controller: _phoneController,
                      decoration: const InputDecoration(
                        labelText: 'Phone Number',
                        prefixIcon: Icon(Icons.phone),
                        border: OutlineInputBorder(),
                      ),
                      validator: FormBuilderValidators.compose([
                        FormBuilderValidators.required(),
                        FormBuilderValidators.match(
  RegExp(r'^61\d{7}$'),
  errorText: 'Enter valid Somali number'
),

                      ]),
                      keyboardType: TextInputType.phone,
                    ),
                    const SizedBox(height: 20),

                    subjectLoading
                        ? const Center(child: CircularProgressIndicator())
                        : FormBuilderField<List<String>>(
                            name: 'subjects',
                            validator: (val) => (val == null || val.isEmpty)
                                ? 'Please select at least one subject'
                                : null,
                            builder: (field) {
                              return MultiSelectDialogField(
                                items: subjectOptions
                                    .map((s) => MultiSelectItem(s, s))
                                    .toList(),
                                title: const Text("Subjects"),
                                selectedColor: Colors.deepPurple,
                                buttonText: const Text("Select Subjects"),
                                onConfirm: (values) {
                                  field.didChange(List<String>.from(values));
                                },
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                    color: field.hasError ? Colors.red : Colors.grey,
                                  ),
                                ),
                              );
                            },
                          ),
                    const SizedBox(height: 20),

                    FormBuilderDropdown<String>(
                      name: 'reason',
                      decoration: const InputDecoration(
                        labelText: 'Reason',
                        prefixIcon: Icon(Icons.flag),
                        border: OutlineInputBorder(),
                      ),
                      items: reasonOptions
                          .map((opt) => DropdownMenuItem(
                              value: opt['value'], child: Text(opt['label']!)))
                          .toList(),
                      validator: FormBuilderValidators.required(),
                    ),
                    const SizedBox(height: 30),

                    ElevatedButton.icon(
                      onPressed: isLoading
                          ? null
                          : () async {
                              if (_formKey.currentState?.saveAndValidate() ?? false) {
                                setState(() => isLoading = true);

                                final values = _formKey.currentState!.value;
                                final payload = {
                                  'studentId': student.id,
                                  'phone': values['phone'],
                                  'subjects': values['subjects'],
                                  'reason': values['reason'],
                                };

                                final success = await reExamProvider.registerReExam(payload);
                                setState(() => isLoading = false);

                                if (success) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Re-exam registered successfully')),
                                  );
                                  Navigator.pop(context);
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Failed to register re-exam')),
                                  );
                                }
                              }
                            },
                      icon: const Icon(Icons.send),
                      label: isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text("Submit"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepPurple,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
    );
  }
}
