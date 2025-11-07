Bidirectional Communication Assistant for the Hearing and Speech Impaired
Overview

The Bidirectional Communication Assistant, named SignApp, is a mobile-based artificial intelligence application designed to bridge the communication gap between hearing- and speech-impaired individuals and the general public. It provides a two-way translation system between Indian Sign Language (ISL) and spoken English, ensuring accessibility, inclusivity, and real-time usability without the need for expensive hardware or internet connectivity.

Objectives

Develop a real-time mobile application that converts sign language gestures into speech and spoken language into sign gestures.

Ensure offline functionality using lightweight AI models for accessibility in rural or low-connectivity environments.

Create a user-friendly interface for both hearing and hearing-impaired users.

Support Indian Sign Language (ISL) to promote inclusivity and regional adaptability.

Problem Definition

Most existing sign language translation systems:

Are designed for American Sign Language (ASL) rather than ISL.

Depend on external hardware such as gloves or sensors.

Are cloud-based and cannot operate offline.

Provide only one-way communication (sign-to-text or speech-to-sign).

To overcome these challenges, SignApp integrates both directions of communication into a single, efficient, and cost-effective mobile platform.

System Architecture

Sign-to-Speech Module

Captures real-time gestures through the mobile camera.

Uses MediaPipe to extract 21 hand landmarks per frame.

Recognizes gestures using a trained TensorFlow Lite model.

Converts recognized signs into text and speech output using a Text-to-Speech engine.

Speech-to-Sign Module

Accepts spoken input through the microphone.

Converts voice to text using a Speech-to-Text (STT) module.

Displays corresponding ISL animations or images for visual interpretation.

Technologies Used
Component	Technology / Tool
Frontend	Flutter (Dart)
Backend / Model	Python, TensorFlow, TensorFlow Lite
Gesture Detection	MediaPipe
Speech Processing	FlutterTTS, Speech-to-Text API
Dataset	Indian Sign Language (ISLRTC, Kaggle)
IDEs	Android Studio, Visual Studio Code
Environment	Android (Offline Capable)
Features

Bidirectional Communication: Converts both signs to speech and speech to signs.

Offline Functionality: Works without internet using on-device models.

ISL-Specific Recognition: Trained exclusively on Indian Sign Language.

Lightweight and Real-Time: Optimized TensorFlow Lite models for mobile performance.

Interactive User Interface: Built with Flutter for seamless experience.

ISL Dictionary Module: Includes reference charts for alphabets and numerals.

Data Privacy: No cloud processing; all data stays on-device.

System Requirements
Hardware

Android smartphone (Android 9.0 or later)

Minimum 3 GB RAM

12 MP camera and microphone

Software

Flutter SDK 3.0 or above

TensorFlow Lite

MediaPipe Hands Library

Android Studio or VS Code

Installation and Setup

Clone the repository:

git clone https://github.com/your-username/SignApp.git
cd SignApp


Install dependencies:

flutter pub get


Configure TensorFlow Lite model and assets:

Place your .tflite model in the assets/model/ directory.

Update pubspec.yaml to include the model and dictionary image assets.

Run the application:

flutter run

Model Training Overview

Model trained on ISL dataset containing alphabets (A–Z) and digits (0–9).

Hand landmarks extracted using MediaPipe Hands.

Trained CNN/DNN architecture in TensorFlow, later converted to .tflite.

Achieved 78–82% accuracy with minimal latency (~1.2 seconds per gesture).

Uniqueness of SignApp:

Mobile app designed specifically for Indian Sign Language.

Completely offline operation without dependency on sensors or cloud servers.

Two-way communication support in a single mobile platform.

Cost-effective and scalable for educational and social use.

High accuracy and real-time response optimized for low-end devices.

Future Enhancements

Add support for regional languages (Tamil, Hindi, etc.).

Introduce emotion and facial expression recognition.

Implement sentence-level sign recognition using LSTM or Transformer models.

Add AI avatar animation with realistic facial and body gestures.

Enable full offline learning mode for educational purposes.