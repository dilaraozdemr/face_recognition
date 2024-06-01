import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'dart:typed_data';

class FaceDetectionScreen extends StatefulWidget {
  @override
  _FaceDetectionScreenState createState() => _FaceDetectionScreenState();
}

class _FaceDetectionScreenState extends State<FaceDetectionScreen> {
  late CameraController _cameraController;
  final FaceDetector _faceDetector = FaceDetector(
    options: FaceDetectorOptions(
      enableClassification: true,
    ),
  );
  bool _isDetecting = false;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  @override
  void dispose() {
    _cameraController.dispose();
    _faceDetector.close();
    super.dispose();
  }

  Future<void> _initializeCamera() async {
    final cameras = await availableCameras();
    final camera = cameras.first;
    _cameraController = CameraController(
      camera,
      ResolutionPreset.medium,
      enableAudio: false,
    );

    await _cameraController.initialize();
    _cameraController.startImageStream((CameraImage image) {
      if (!_isDetecting) {
        _isDetecting = true;
        _detectFaces(image);
      }
    });

    setState(() {});
  }

  InputImageRotation _rotationIntToImageRotation(int rotation) {
    switch (rotation) {
      case 90:
        return InputImageRotation.rotation90deg;
      case 180:
        return InputImageRotation.rotation180deg;
      case 270:
        return InputImageRotation.rotation270deg;
      case 0:
      default:
        return InputImageRotation.rotation0deg;
    }
  }

  Future<void> _detectFaces(CameraImage image) async {
    final WriteBuffer allBytes = WriteBuffer();
    for (Plane plane in image.planes) {
      allBytes.putUint8List(plane.bytes);
    }
    final bytes = allBytes.done().buffer.asUint8List();

    final Size imageSize =
    Size(image.width.toDouble(), image.height.toDouble());

    final InputImageRotation imageRotation = _rotationIntToImageRotation(
        _cameraController.description.sensorOrientation);

    const InputImageFormat inputImageFormat = InputImageFormat.bgra8888;

    final planeData = image.planes.map(
          (Plane plane) {
        return InputImagePlaneMetadata(
          bytesPerRow: plane.bytesPerRow,
          height: plane.height,
          width: plane.width,
        );
      },
    ).toList();

    final inputImageData = InputImageData(
      size: imageSize,
      imageRotation: imageRotation,
      inputImageFormat: inputImageFormat,
      planeData: planeData,
    );

    final inputImage2 =
    InputImagee.fromBytes(bytes: bytes, inputImageData: inputImageData);

    final List<Face> faces = await _faceDetector.processImage(inputImage2 as InputImage);

    for (Face face in faces) {

      final leftEyeOpen = face.leftEyeOpenProbability!;
      final rightEyeOpen = face.rightEyeOpenProbability!;

      String leftEyeState = _determineEyeState(leftEyeOpen);
      String rightEyeState = _determineEyeState(rightEyeOpen);
      print("Left eye is $leftEyeState, Right eye is $rightEyeState");

    }

    _isDetecting = false;
  }
  _determineEyeState(double eyeOpenProbability) {
    if (eyeOpenProbability >= 0.7) {
      return "Sleeping Alert";
    } else if (eyeOpenProbability >= 0.3) {
      return  "Tired Alert";
    } else {
      return  "Active";
    }
  }
  @override
  Widget build(BuildContext context) {
    if (!_cameraController.value.isInitialized) {
      return const Center(child: CircularProgressIndicator());
    }
    return Scaffold(
      appBar: AppBar(title: Text('Face Detection')),
      body: Stack(
        children: [
          CameraPreview(_cameraController),
        ],
      ),
    );
  }
}

class InputImageData {
  final Size size;
  final dynamic imageRotation;
  final InputImageFormat inputImageFormat;
  final List<dynamic> planeData;

  InputImageData({
    required this.size,
    required this.imageRotation,
    required this.inputImageFormat,
    required this.planeData,
  });
}
class InputImagee {
  final Uint8List bytes;
  final InputImageData? inputImageData;

  InputImagee.fromBytes({
    required this.bytes,
    this.inputImageData,
  });
}

class InputImagePlaneMetadata {
  final int bytesPerRow;
  final int? height;
  final int? width;

  InputImagePlaneMetadata({
    required this.bytesPerRow,
    this.height,
    this.width,
  });
}