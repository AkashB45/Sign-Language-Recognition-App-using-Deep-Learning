import 'dart:async';
import 'package:flutter/material.dart';
import 'home_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _logoController;
  late Animation<double> _logoAnimation;

  late AnimationController _textController1;
  late Animation<Offset> _textAnimation1;

  late AnimationController _textController2;
  late Animation<Offset> _textAnimation2;

  @override
  void initState() {
    super.initState();

    // Logo animation: faster (1.2 seconds)
    _logoController =
        AnimationController(vsync: this, duration: const Duration(milliseconds: 1200))
          ..forward();
    _logoAnimation =
        CurvedAnimation(parent: _logoController, curve: Curves.elasticOut);

    // First line text animation: faster (600ms)
    _textController1 =
        AnimationController(vsync: this, duration: const Duration(milliseconds: 600));
    _textAnimation1 =
        Tween<Offset>(begin: const Offset(0, 1), end: Offset.zero).animate(
      CurvedAnimation(parent: _textController1, curve: Curves.easeOut),
    );

    // Second line text animation: faster (600ms)
    _textController2 =
        AnimationController(vsync: this, duration: const Duration(milliseconds: 600));
    _textAnimation2 =
        Tween<Offset>(begin: const Offset(0, 1), end: Offset.zero).animate(
      CurvedAnimation(parent: _textController2, curve: Curves.easeOut),
    );

    // Sequence animations with shorter delay
    Future.delayed(const Duration(milliseconds: 1200), () {
      _textController1.forward();
    });
    Future.delayed(const Duration(milliseconds: 1400), () {
      _textController2.forward();
    });

    // Move to home screen faster (3 seconds total)
    Timer(const Duration(seconds: 3), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );
    });
  }

  @override
  void dispose() {
    _logoController.dispose();
    _textController1.dispose();
    _textController2.dispose();
    super.dispose();
  }

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
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo with bounce effect
              ScaleTransition(
                scale: _logoAnimation,
                child: Image.asset(
                  'assets/icon/app_logo.png',
                  height: 130,
                ),
              ),
              const SizedBox(height: 40),

              // First line of text
              SlideTransition(
                position: _textAnimation1,
                child: const Text(
                  "SignApp",
                  style: TextStyle(
                    fontSize: 34,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.5,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 8),

              // Second line of text
              SlideTransition(
                position: _textAnimation2,
                child: const Text(
                  "Empowering Communication\nvia Gestures",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.white70,
                    height: 1.4,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
