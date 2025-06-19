import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'package:vibration/vibration.dart';
import '../providers/student_provider.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:geolocator/geolocator.dart';

class ScanScreen extends StatefulWidget {
  const ScanScreen({super.key});

  @override
  State<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen> {
  bool isProcessing = false;
  final player = AudioPlayer();
  Position? _currentPosition;
  bool locationLoading = true;
  bool studentLoading = true;

  static const String baseUrl = 'https://re-exam.onrender.com/api/attendance';
  String? studentId;

  @override
  void initState() {
    super.initState();
    _loadStudentAndLocation();
  }

  Future<void> _loadStudentAndLocation() async {
    try {
      final studentProvider = Provider.of<StudentProvider>(context, listen: false);
      studentId = studentProvider.student?.user['_id'];

      if (studentId == null) {
        Fluttertoast.showToast(msg: '❌ Student ID not found');
        Navigator.pop(context);
        return;
      }

      await _getCurrentLocation();
    } catch (e) {
      Fluttertoast.showToast(msg: "⚠ Failed to load student data.");
      Navigator.pop(context);
    }
  }

  Future<void> _getCurrentLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        Fluttertoast.showToast(msg: "⚠ Location services are disabled.");
        Navigator.pop(context);
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          Fluttertoast.showToast(msg: "⚠ Location permission denied.");
          Navigator.pop(context);
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        Fluttertoast.showToast(msg: "⚠ Location permission permanently denied.");
        Navigator.pop(context);
        return;
      }

      Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      setState(() {
        _currentPosition = position;
        locationLoading = false;
      });
    } catch (e) {
      Fluttertoast.showToast(msg: "⚠ Failed to get location.");
      Navigator.pop(context);
    }
  }

  Future<void> handleAttendance(String token) async {
    if (_currentPosition == null) {
      Fluttertoast.showToast(msg: "⚠ Cannot submit attendance without location");
      return;
    }

    try {
      final url = Uri.parse('$baseUrl/scan');
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'token': token,
          'student': studentId,
          'location': {
            'latitude': _currentPosition!.latitude,
            'longitude': _currentPosition!.longitude
          }
        }),
      );

      final responseBody = jsonDecode(response.body);

      if (response.statusCode == 200) {
        Fluttertoast.showToast(msg: '✅ Attendance Recorded');
        await playSuccessSound();
        await vibrateSuccess();
        if (mounted) {
          Future.delayed(const Duration(milliseconds: 500), () {
            if (mounted) Navigator.pop(context);
          });
        }
      } else if (response.statusCode == 409) {
        Fluttertoast.showToast(msg: '⚠ You already scanned attendance');
      } else if (response.statusCode == 403) {
        Fluttertoast.showToast(msg: '❌ You are too far from class location');
      } else {
        Fluttertoast.showToast(msg: '⚠️ ${responseBody['error'] ?? 'Failed to record attendance'}');
      }
    } catch (e) {
      Fluttertoast.showToast(msg: '⚠️ An error occurred.');
    }
  }

  void onDetect(BarcodeCapture capture) async {
    if (isProcessing || _currentPosition == null) return;

    final List<Barcode> barcodes = capture.barcodes;
    if (barcodes.isNotEmpty) {
      final String? token = barcodes.first.rawValue;
      if (token != null) {
        setState(() => isProcessing = true);
        await handleAttendance(token);
        setState(() => isProcessing = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("QR Attendance Scanner")),
      body: locationLoading
          ? const Center(child: CircularProgressIndicator())
          : Stack(
              children: [
                MobileScanner(
                  controller: MobileScannerController(detectionSpeed: DetectionSpeed.noDuplicates),
                  onDetect: onDetect,
                ),
                _buildScannerOverlay(context),
                if (isProcessing)
                  Container(
                    color: Colors.black.withOpacity(0.5),
                    child: const Center(child: CircularProgressIndicator()),
                  ),
              ],
            ),
    );
  }

  Widget _buildScannerOverlay(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        double overlaySize = constraints.maxWidth * 0.7;
        return Stack(
          children: [
            // Dark semi-transparent layer
            ColorFiltered(
              colorFilter: ColorFilter.mode(
                Colors.black.withOpacity(0.7),
                BlendMode.srcOut,
              ),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Container(
                    decoration: const BoxDecoration(
                      color: Colors.black,
                      backgroundBlendMode: BlendMode.dstOut,
                    ),
                  ),
                  Positioned(
                    left: (constraints.maxWidth - overlaySize) / 2,
                    top: (constraints.maxHeight - overlaySize) / 3,
                    child: Container(
                      width: overlaySize,
                      height: overlaySize,
                      decoration: BoxDecoration(
                        color: Colors.black,
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Border with nice rounded frame
            Positioned(
              left: (constraints.maxWidth - overlaySize) / 2,
              top: (constraints.maxHeight - overlaySize) / 3,
              child: Container(
                width: overlaySize,
                height: overlaySize,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Colors.redAccent,
                    width: 4,
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> playSuccessSound() async {
    try {
      await player.play(AssetSource('success.wav'));
    } catch (e) {
      print('Audio error: $e');
    }
  }

  Future<void> vibrateSuccess() async {
    if (await Vibration.hasVibrator() ?? false) {
      Vibration.vibrate(duration: 200);
    }
  }

  @override
  void dispose() {
    player.dispose();
    super.dispose();
  }
}
