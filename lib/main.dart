import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:camera/camera.dart';
import 'package:face_recognition/mic_page.dart';
import 'package:flutter/material.dart';
import 'package:record/record.dart';
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:image/image.dart' as img;

enum DetectionStatus { noFace, fail, success }

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Face Recognition Application',
      theme: ThemeData(useMaterial3: true),
      home: const MicPage(),
    );
  }
}

class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  CameraController? controller;
  late WebSocketChannel channel;
  DetectionStatus? status;
  double rightEye = 0.0;
  double leftEye = 0.0;
  String sleepStatus = "";
  AudioRecorder myRecording = AudioRecorder();
  Timer? timer;

  double volume = 0.0;
  double minVolume = -45.0;

  startTimer() async {
    timer ??=
        Timer.periodic(Duration(milliseconds: 10), (timer) => updateVolume());
  }

  updateVolume() async {
    Amplitude ampl = await myRecording.getAmplitude();
    if (ampl.current > minVolume) {
      setState(() {
        volume = (ampl.current - minVolume) / minVolume;
      });
      print("Volume $volume");
    }
  }

  int volumeOto(int maxVolumeToDisplay) {
    return (volume * maxVolumeToDisplay).round().abs();
  }

  Future<bool> startRecording() async {
    if (await myRecording.hasPermission()) {
      if (!await myRecording.isRecording()) {
        await myRecording.startStream(RecordConfig());
      }
      startTimer();
      return true;
    } else {
      return false;
    }
  }

  @override
  void initState() {
    super.initState();
    initializeCamera();
    initializeWebSocket();
  }

  Future<void> initializeCamera() async {
    final cameras = await availableCameras();
    final firstCamera = cameras[1]; // back 0th index & front 1st index

    controller = CameraController(
      firstCamera,
      ResolutionPreset.medium,
      enableAudio: false,
    );

    await controller!.initialize();
    setState(() {});

    Timer.periodic(const Duration(seconds: 1), (timer) async {
      try {
        final image = await controller!.takePicture();
        final compressedImageBytes = compressImage(image.path);
        channel.sink.add(compressedImageBytes);
      } catch (_) {}
    });
  }

  void initializeWebSocket() {
    // 0.0.0.0 -> 10.0.2.2 (emulator)
    channel = IOWebSocketChannel.connect('ws://192.168.1.103:9000');
    channel.stream.listen((dynamic data) {
      String jsonStr = data.toString();
      Map<String, dynamic> parsedJson = json.decode(jsonStr);

      double rightEyeRatio = parsedJson['right_eye_ratio'];
      double leftEyeRatio = parsedJson['left_eye_ratio'];
      rightEye = rightEyeRatio;
      leftEye = leftEyeRatio;
      print('Right Eye Ratio: $rightEyeRatio');
      print('Left Eye Ratio: $leftEyeRatio');
      checkSleep();
      setState(() {});
    }, onError: (dynamic error) {
      debugPrint('Error: $error');
    }, onDone: () {
      debugPrint('WebSocket connection closed');
    });
  }

  Uint8List compressImage(String imagePath, {int quality = 100}) {
    final image =
        img.decodeImage(Uint8List.fromList(File(imagePath).readAsBytesSync()))!;
    final compressedImage =
        img.encodeJpg(image, quality: quality); // lossless compression
    return compressedImage;
  }

  @override
  void dispose() {
    controller?.dispose();
    channel.sink.close();
    super.dispose();
  }

  checkSleep() {
    if (leftEye + rightEye > 16) {
      sleepStatus = "Sleeping Alert";
    } else if (leftEye + rightEye > 8) {
      sleepStatus = "Tired Alert";
    } else if (leftEye + rightEye < 8) {
      sleepStatus = "Active";
    }
  }

  getColor() {
    if (sleepStatus == "Sleeping Alert") {
      return Colors.red;
    } else if (sleepStatus == "Tired Alert") {
      return Colors.orange;
    } else if (sleepStatus == "Active") {
      return Colors.green;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!(controller?.value.isInitialized ?? false)) {
      return const SizedBox();
    }

    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: AspectRatio(
              aspectRatio: controller!.value.aspectRatio,
              child: CameraPreview(controller!),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  sleepStatus,
                  style: TextStyle(fontSize: 40, color: getColor()),
                ),
                FutureBuilder(
                    future: startRecording(),
                    builder: (context, AsyncSnapshot<bool> snapshot) {
                     return  Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text(snapshot.hasData
                              ? volumeOto(100).toString()
                              : "NO DATA"),
                        ],
                      );
                    })
              ],
            ),
          )
        ],
      ),
    );
  }
}
