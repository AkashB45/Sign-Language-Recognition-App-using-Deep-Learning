import 'package:flutter/material.dart';
import 'screens/splash_screen.dart'; // Make sure this path is correct
import 'screens/home_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const SignApp());
}

class SignApp extends StatelessWidget {
  const SignApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SignApp',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
        fontFamily: 'Poppins', // Global font
        textTheme: const TextTheme(
          bodyLarge: TextStyle(color: Colors.black87),
          bodyMedium: TextStyle(color: Colors.black87),
          bodySmall: TextStyle(color: Colors.black87),
          headlineLarge: TextStyle(fontWeight: FontWeight.bold),
          headlineMedium: TextStyle(fontWeight: FontWeight.bold),
          headlineSmall: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      // Show SplashScreen first
      home: const SplashScreen(),
    );
  }
}
