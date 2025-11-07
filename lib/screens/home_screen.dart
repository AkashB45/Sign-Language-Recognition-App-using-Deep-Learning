import 'package:flutter/material.dart';
import 'sign_to_speech.dart';
import 'speech_to_sign.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.black, Colors.deepPurple],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                "Welcome to SignApp",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                "Choose a mode below to begin",
                style: TextStyle(color: Colors.white70, fontSize: 16),
              ),
              const SizedBox(height: 50),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: [
                    _buildOptionButton(
                      context,
                      title: "Sign to Speech",
                      icon: Icons.handshake,
                      color: Colors.deepPurple,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const SignToSpeechScreen(),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 25),
                    _buildOptionButton(
                      context,
                      title: "Speech to Sign",
                      icon: Icons.record_voice_over,
                      color: Colors.pinkAccent,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const SpeechToSignScreen(),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 25),
                    _buildDictionaryButton(context),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOptionButton(BuildContext context,
      {required String title,
      required IconData icon,
      required Color color,
      required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 24),
        decoration: BoxDecoration(
          color: color.withOpacity(0.8),
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.5),
              blurRadius: 12,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 28),
            const SizedBox(width: 12),
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildDictionaryButton(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const ISLDictionaryScreen()),
        );
      },
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
        decoration: BoxDecoration(
          color: Colors.blueGrey.withOpacity(0.8),
          borderRadius: BorderRadius.circular(14),
        ),
        child: const Text(
          "ISL Dictionary",
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

// New screen to show dictionary images
class ISLDictionaryScreen extends StatelessWidget {
  const ISLDictionaryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("ISL Dictionary"),
        backgroundColor: Colors.deepPurple,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text(
              "Indian Sign Language - Alphabet & Numbers",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            Image.asset(
              'assets/dictionary/characters.png',
              fit: BoxFit.contain,
            ),
            const SizedBox(height: 20),
            Image.asset(
              'assets/dictionary/numbers.webp',
              fit: BoxFit.contain,
            ),
          ],
        ),
      ),
    );
  }
}
