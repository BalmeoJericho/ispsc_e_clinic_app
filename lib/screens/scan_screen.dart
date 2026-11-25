
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import '../models/medical_record.dart';
import '../services/activity_log_service.dart';
import 'review_basic_info_screen.dart';

class ScanScreen extends StatefulWidget {
  const ScanScreen({super.key});

  @override
  State<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen> {

  CameraController? _cameraController;
  bool isCameraReady = false;
  bool isProcessing = false;

////////////////////////////////////////////////////////////
/// INIT
////////////////////////////////////////////////////////////

  @override
  void initState() {
    super.initState();
    initializeCamera();
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    super.dispose();
  }

////////////////////////////////////////////////////////////
/// CAMERA SETUP
////////////////////////////////////////////////////////////

  Future<void> initializeCamera() async {

    final cameras = await availableCameras();

    if (cameras.isNotEmpty) {

      _cameraController =
          CameraController(cameras.first, ResolutionPreset.high);

      await _cameraController!.initialize();

      if (!mounted) return;

      setState(() => isCameraReady = true);
    }
  }

////////////////////////////////////////////////////////////
/// EXTRACT TEXT VALUE
////////////////////////////////////////////////////////////

  String extractValue(String text, String label) {

    final regex =
        RegExp('$label\\s*:?\\s*(.*)', caseSensitive: false);

    final match = regex.firstMatch(text);

    return match != null ? match.group(1)!.trim() : '';
  }

////////////////////////////////////////////////////////////
/// CAPTURE AND SCAN
////////////////////////////////////////////////////////////

  Future<void> captureAndScan() async {

    if (_cameraController == null ||
        !_cameraController!.value.isInitialized ||
        isProcessing) return;

    setState(() => isProcessing = true);

    try {

////////////////////////////////////////////////////////////
/// TAKE PHOTO
////////////////////////////////////////////////////////////

      final image = await _cameraController!.takePicture();

      final inputImage =
          InputImage.fromFilePath(image.path);

////////////////////////////////////////////////////////////
/// OCR PROCESS
////////////////////////////////////////////////////////////

      final textRecognizer = TextRecognizer();

      final recognizedText =
          await textRecognizer.processImage(inputImage);

      await textRecognizer.close();

      final text = recognizedText.text;

////////////////////////////////////////////////////////////
/// CREATE MEDICAL RECORD
////////////////////////////////////////////////////////////

      final ageGender =
          extractValue(text, "Age/Gender").split("/");

      final record = MedicalRecord(
        patientName: extractValue(text, "Name"),
        patientID: "",
        address: extractValue(text, "Address"),
        dateOfVisit: extractValue(text, "Date"),
        age: ageGender.isNotEmpty
            ? ageGender[0].trim()
            : "",
        gender: ageGender.length > 1
            ? ageGender[1].trim()
            : "",
      );

////////////////////////////////////////////////////////////
/// ACTIVITY LOG — LAB SCAN
////////////////////////////////////////////////////////////

      await ActivityLogService.log(
        action: "Laboratory Scan",
        details:
            "Medical record scanned for ${record.patientName}",
        patientName: record.patientName,
      );

////////////////////////////////////////////////////////////
/// NAVIGATE TO REVIEW SCREEN
////////////////////////////////////////////////////////////

      if (!mounted) return;

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) =>
              ReviewBasicInfoScreen(record: record),
        ),
      );

    } catch (e) {

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Scanning failed. Try again."),
        ),
      );
    }

    setState(() => isProcessing = false);
  }

////////////////////////////////////////////////////////////
/// UI
////////////////////////////////////////////////////////////

  @override
  Widget build(BuildContext context) {

    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    final frameWidth = screenWidth * 0.8;
    final frameHeight = screenHeight * 0.25;

    return Scaffold(

      body: SafeArea(

        child: Column(

          children: [

////////////////////////////////////////////////////////////
/// HEADER
////////////////////////////////////////////////////////////

            Row(
              children: [

                IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () => Navigator.pop(context),
                ),

                const Expanded(
                  child: Text(
                    "Scan Medical Record",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

                const SizedBox(width: 48),
              ],
            ),

////////////////////////////////////////////////////////////
/// CAMERA PREVIEW
////////////////////////////////////////////////////////////

            Expanded(

              child: isCameraReady
                  ? Stack(
                      children: [

                        Positioned.fill(
                          child:
                              CameraPreview(_cameraController!),
                        ),

////////////////////////////////////////////////////////////
/// SCAN FRAME
////////////////////////////////////////////////////////////

                        Center(
                          child: Container(
                            width: frameWidth,
                            height: frameHeight,
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: Colors.green,
                                width: 3,
                              ),
                              borderRadius:
                                  BorderRadius.circular(12),
                            ),
                          ),
                        ),

////////////////////////////////////////////////////////////
/// INSTRUCTION
////////////////////////////////////////////////////////////

                        const Positioned(
                          bottom: 30,
                          left: 0,
                          right: 0,
                          child: Text(
                            "Align the medical form inside the frame",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    )
                  : const Center(
                      child: CircularProgressIndicator(),
                    ),
            ),

////////////////////////////////////////////////////////////
/// CAPTURE BUTTON
////////////////////////////////////////////////////////////

            Padding(
              padding: const EdgeInsets.all(20),

              child: SizedBox(
                width: 70,
                height: 70,

                child: FloatingActionButton(
                  backgroundColor: Colors.green,
                  onPressed:
                      isProcessing ? null : captureAndScan,

                  child: isProcessing
                      ? const CircularProgressIndicator(
                          color: Colors.white,
                        )
                      : const Icon(
                          Icons.camera_alt,
                          size: 32,
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

