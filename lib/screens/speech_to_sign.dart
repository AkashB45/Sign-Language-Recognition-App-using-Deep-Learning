import 'dart:async';
import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import '../utils/mapping.dart';

class SpeechToSignScreen extends StatefulWidget {
  const SpeechToSignScreen({super.key});

  @override
  State<SpeechToSignScreen> createState() => _SpeechToSignScreenState();
}

class _SpeechToSignScreenState extends State<SpeechToSignScreen> {
  stt.SpeechToText speech = stt.SpeechToText();
  bool isListening = false;
  final TextEditingController _controller = TextEditingController();
  String text = '';

  int currentIndex = 0;
  List<String> signList = [];
  bool isPlaying = false;

  @override
  void initState() {
    super.initState();
  }

  /// Mic listening
  void listen() async {
    if (!isListening) {
      bool available = await speech.initialize(
        onStatus: (status) {
          if (status == "done" || status == "notListening") {
            setState(() => isListening = false);
          }
        },
        onError: (error) => setState(() => isListening = false),
      );
      if (available) {
        setState(() => isListening = true);
        speech.listen(
          onResult: (val) {
            setState(() {
              text = val.recognizedWords;
              _controller.text = text;
            });
          },
          listenMode: stt.ListenMode.dictation,
          partialResults: true,
        );
      }
    } else {
      speech.stop();
      setState(() => isListening = false);
    }
  }

  /// Convert text → sign sequence
  void prepareSignList(String inputText) {
    signList = [];
    String temp = inputText.toLowerCase().trim();
    while (temp.isNotEmpty) {
      bool matched = false;
      List<String> multiKeys = mapping.keys.where((k) => k.length > 1).toList()
        ..sort((a, b) => b.length.compareTo(a.length));
      for (var key in multiKeys) {
        if (temp.startsWith(key)) {
          signList.add(mapping[key]!);
          temp = temp.substring(key.length);
          matched = true;
          break;
        }
      }
      if (!matched) {
        String firstChar = temp[0];
        if (mapping.containsKey(firstChar)) {
          signList.add(mapping[firstChar]!);
        }
        temp = temp.substring(1);
      }
    }
  }

  /// Play signs sequentially
  Future<void> playSigns() async {
    if (text.trim().isEmpty || isPlaying) return;
    prepareSignList(text);
    if (signList.isEmpty) return;

    setState(() {
      currentIndex = 0;
      isPlaying = true;
    });

    for (int i = 0; i < signList.length; i++) {
      if (!mounted) return;
      setState(() => currentIndex = i);

      String path = signList[i].toLowerCase();
      Duration waitDuration;

      // GIFs longer (~4s), PNGs shorter (~2s)
      if (path.endsWith('.gif')) {
        waitDuration = const Duration(seconds: 4);
      } else {
        waitDuration = const Duration(seconds: 2);
      }

      await Future.delayed(waitDuration);
    }

    if (mounted) {
      setState(() {
        currentIndex = 0;
        signList = [];
        isPlaying = false;
      });
    }
  }

  void stopSlideshow() {
    setState(() {
      currentIndex = 0;
      signList = [];
      isPlaying = false;
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    speech.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    String currentSign = signList.isNotEmpty && currentIndex < signList.length
        ? signList[currentIndex]
        : '';

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Speech → Sign'),
        backgroundColor: Colors.blue,
      ),
      body: Column(
        children: [
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: TextField(
              controller: _controller,
              style: const TextStyle(color: Colors.black, fontSize: 18),
              decoration: InputDecoration(
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                labelText: 'Type or speak here',
                labelStyle: const TextStyle(color: Colors.black54),
                filled: true,
                fillColor: Colors.grey[100],
                suffixIcon: IconButton(
                  icon: const Icon(Icons.clear, color: Colors.black87),
                  onPressed: () {
                    setState(() {
                      text = '';
                      _controller.clear();
                      stopSlideshow();
                    });
                  },
                ),
              ),
              onChanged: (val) => setState(() => text = val),
            ),
          ),
          const SizedBox(height: 20),

          /// Sign display (GIF or PNG)
          Expanded(
            child: Center(
              child: currentSign.isNotEmpty
                  ? Image.asset(
                      currentSign,
                      key: ValueKey(currentSign),
                      width: MediaQuery.of(context).size.width * 0.75,
                      height: MediaQuery.of(context).size.height * 0.45,
                      fit: BoxFit.contain,
                    )
                  : const Padding(
                      padding: EdgeInsets.all(24.0),
                      child: Text(
                        'Your sign will appear here',
                        style: TextStyle(fontSize: 22, color: Colors.black54),
                        textAlign: TextAlign.center,
                      ),
                    ),
            ),
          ),
        ],
      ),

      /// Bottom buttons
      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
        decoration: const BoxDecoration(
          color: Colors.white,
          boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 8)],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            ElevatedButton.icon(
              onPressed: playSigns,
              icon: const Icon(Icons.play_arrow),
              label: const Text('Play'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueAccent,
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
              ),
            ),
            GestureDetector(
              onTap: listen,
              child: Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isListening ? Colors.redAccent : Colors.white,
                  border: Border.all(color: Colors.black, width: 2),
                ),
                child: Center(
                  child: Icon(
                    isListening ? Icons.mic : Icons.mic_none,
                    size: 32,
                    color: isListening ? Colors.white : Colors.black,
                  ),
                ),
              ),
            ),
            ElevatedButton.icon(
              onPressed: stopSlideshow,
              icon: const Icon(Icons.stop),
              label: const Text('Stop'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
