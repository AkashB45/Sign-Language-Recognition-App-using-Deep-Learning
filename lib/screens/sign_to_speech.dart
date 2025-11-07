import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:csv/csv.dart';
import 'my_camera_view.dart';
import '../utils/keypoint_classifier.dart';
import '../utils/hand_processing.dart';

class SignToSpeechScreen extends StatefulWidget {
  const SignToSpeechScreen({super.key});

  @override
  State<SignToSpeechScreen> createState() => _SignToSpeechScreenState();
}

class _SignToSpeechScreenState extends State<SignToSpeechScreen> {
  String _predictedChar = '';
  String _collectedText = '';
  bool _isPermissionGranted = Platform.isAndroid ? false : true;

  static const cameraPermission = MethodChannel("camera_permission");
  static const landmarkChannel = EventChannel('landmarks');

  late KeyPointClassifier _keypointClassifier;
  late List<String> _keypointClassifierLabels;
  late FlutterTts _flutterTts;
  StreamSubscription? _landmarkSubscription;

  String _lastChar = '';
  int _sameCharCount = 0;
  static const int _stableThreshold = 5;

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    _flutterTts = FlutterTts();
    _keypointClassifier = KeyPointClassifier();
    await _keypointClassifier.load();
    await _loadLabels();

    if (Platform.isAndroid) {
      await _getCameraPermission();
    }

    Future.delayed(Duration.zero, () {
      _landmarkSubscription =
          landmarkChannel.receiveBroadcastStream().listen(_onLandmarkReceived);
    });
  }

  Future<void> _loadLabels() async {
    final csvString = await rootBundle.loadString('assets/models/label.csv');
    final csvTable = CsvToListConverter().convert(csvString);
    _keypointClassifierLabels =
        csvTable.map((row) => row[0].toString()).toList();

    if (_keypointClassifierLabels.isNotEmpty &&
        _keypointClassifierLabels[0].startsWith('\ufeff')) {
      _keypointClassifierLabels[0] =
          _keypointClassifierLabels[0].substring(1);
    }
  }

  void _onLandmarkReceived(dynamic event) {
    if (event is Map) {
      try {
        final landmarks = event['landmarks'] as List<dynamic>;
        final imageWidth = event['width'] as int;
        final imageHeight = event['height'] as int;

        var landmarkList = calcLandmarkList(landmarks, imageWidth, imageHeight);
        if (landmarkList.length > 21) {
          landmarkList = landmarkList.sublist(0, 21);
        }

        final preprocessed = preProcessLandmark(landmarkList);
        final handSignId = _keypointClassifier.call(preprocessed);
        final predictedChar = _keypointClassifierLabels[handSignId];

        // Stable detection logic
        if (predictedChar == _lastChar) {
          _sameCharCount++;
        } else {
          _sameCharCount = 0;
          _lastChar = predictedChar;
        }

        if (_sameCharCount == _stableThreshold) {
          setState(() {
            _predictedChar = predictedChar;
            _collectedText += predictedChar;
          });
        } else {
          setState(() {
            _predictedChar = predictedChar;
          });
        }

      } catch (e) {
        setState(() {
          _predictedChar = 'Error: $e';
        });
      }
    }
  }

  Future<void> _getCameraPermission() async {
    try {
      final bool result =
          await cameraPermission.invokeMethod('getCameraPermission');
      if (result) {
        setState(() {
          _isPermissionGranted = true;
        });
      } else {
        debugPrint("Camera permission denied");
      }
    } on PlatformException catch (e) {
      debugPrint("Failed to get camera permission: '${e.message}'");
    }
  }

  Future<void> _playSpeech() async {
    if (_collectedText.isNotEmpty) {
      await _flutterTts.speak(_collectedText);
    }
  }

  Future<void> _stopSpeech() async {
    await _flutterTts.stop();
  }

  void _clearCollectedText() {
    setState(() {
      _collectedText = '';
    });
  }

  @override
  void dispose() {
    _landmarkSubscription?.cancel();
    _keypointClassifier.dispose();
    _flutterTts.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('Sign to Speech'),
        backgroundColor: Colors.deepPurple,
        centerTitle: true,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            children: [
              /// Camera feed card
              if (_isPermissionGranted)
                Card(
                  margin: const EdgeInsets.all(16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  elevation: 6,
                  child: Container(
                    height: screenHeight * 0.55,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.deepPurple, width: 2),
                    ),
                    child: const ClipRRect(
                      borderRadius: BorderRadius.all(Radius.circular(20)),
                      child: MyCameraView(key: ValueKey('rear_camera_view')),
                    ),
                  ),
                )
              else
                const Padding(
                  padding: EdgeInsets.all(20),
                  child: Text(
                    "Camera permission required",
                    style: TextStyle(color: Colors.black87, fontSize: 16),
                  ),
                ),

              const SizedBox(height: 12),

              /// Detected character
              Text(
                _predictedChar.isNotEmpty
                    ? "Detected: $_predictedChar"
                    : "Waiting for sign...",
                style: const TextStyle(
                  color: Colors.deepPurple,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 20),

              /// Play / Stop / Clear buttons
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _playSpeech,
                        icon: const Icon(Icons.play_arrow),
                        label: const Text("Play"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _stopSpeech,
                        icon: const Icon(Icons.stop),
                        label: const Text("Stop"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _clearCollectedText,
                        icon: const Icon(Icons.clear),
                        label: const Text("Clear"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color.fromARGB(255, 255, 209, 5),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 25),

              /// Collected text card
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Card(
                  elevation: 3,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                  color: Colors.white,
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Text(
                      _collectedText.isNotEmpty
                          ? _collectedText
                          : "No characters yet",
                      style: const TextStyle(
                        color: Colors.black87,
                        fontSize: 18,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}
