# Bidirectional Communication Assistant for the Hearing and Speech Impaired

## 1. Overview

The **Bidirectional Communication Assistant**, titled **SignApp**, is a mobile-based Artificial Intelligence (AI) application designed to bridge the communication gap between hearing- and speech-impaired individuals and the general public. This project integrates **computer vision**, **machine learning**, and **speech processing** techniques to enable **real-time two-way communication** between sign language users and non-signers.

Unlike conventional systems that focus on one-way translation or depend on external sensors, **SignApp** is designed to operate **entirely offline**, using only a smartphone’s camera and microphone. It specifically supports **Indian Sign Language (ISL)**, ensuring cultural and linguistic relevance for Indian users.


**Demo:**

<img src="assets/demos/demo.gif" width="300" height="300">



---

## 2. Objectives

* Develop a **real-time AI system** that performs both **Sign-to-Speech** and **Speech-to-Sign** translation.
* Provide **offline communication** capability without dependency on cloud computing.
* Achieve high accuracy and low latency suitable for **mobile platforms**.
* Support **Indian Sign Language (ISL)** to promote inclusivity and accessibility.
* Create a **user-friendly Flutter interface** for cross-platform (Android/iOS) use.

---

## 3. Problem Definition

Existing solutions face several limitations:

* Focus primarily on **American Sign Language (ASL)**, ignoring ISL grammar and structure.
* Depend on **expensive hardware** like gloves, sensors, or Kinect cameras.
* Operate only with **internet connectivity**, limiting accessibility.
* Enable **unidirectional translation** (either Sign-to-Text or Speech-to-Sign).
* Lack real-time response and mobile optimization.

**SignApp** addresses these issues by providing a **cost-effective**, **offline**, and **bidirectional** communication platform powered by AI.

---

## 4. System Architecture

The architecture of SignApp consists of two main functional modules:

### 4.1 Sign-to-Speech Module

* The camera captures live ISL gestures.
* **MediaPipe** extracts 21 hand landmarks per frame.
* A **TensorFlow Lite** model classifies gestures into corresponding alphabets or words.
* The recognized sign is converted into **text and audible speech** using **Text-to-Speech (TTS)**.

### 4.2 Speech-to-Sign Module

* The microphone captures spoken input.
* **Speech-to-Text (STT)** engine converts speech into text.
* The system maps recognized text to pre-stored **ISL animations or images**, enabling non-hearing users to understand spoken words visually.

Both modules operate seamlessly within a single Flutter-based mobile interface, supporting **real-time, low-latency interaction**.

---

## 5. Technologies Used

| Component               | Technology / Tool                                                  |
| ----------------------- | ------------------------------------------------------------------ |
| Programming Languages   | Python, Dart                                                       |
| Frameworks              | TensorFlow, TensorFlow Lite, Flutter                               |
| Computer Vision         | MediaPipe Hands                                                    |
| Speech Processing       | FlutterTTS, Speech-to-Text API                                     |
| Dataset                 | Indian Sign Language Research and Training Centre (ISLRTC), Kaggle |
| Development Environment | Google Colab, Android Studio, VS Code                              |
| Deployment Platform     | Android (Offline)                                                  |

---

## 6. Implementation Summary

* Model trained on **A–Z alphabets and 0–9 numerals** using MediaPipe landmark data.
* Hand landmarks converted to 42-dimensional input vectors (x, y coordinates).
* Neural Network (ANN/CNN) trained in **TensorFlow**, converted to **.tflite** for mobile deployment.
* Real-time gesture detection integrated with Flutter UI via camera feed.
* Audio feedback implemented using **Text-to-Speech (TTS)** library.
* Speech input processing handled using **Google Speech-to-Text API**.

**Accuracy Achieved:** ~82.6% on validation dataset
**Average Latency:** ~1.2 seconds per gesture

---

## 7. Key Features

* **Bidirectional Translation:** Supports both Sign-to-Speech and Speech-to-Sign in one platform.
* **Offline Functionality:** Works without internet using on-device inference.
* **ISL-Focused:** Recognizes Indian Sign Language gestures, not ASL.
* **Lightweight AI Model:** Optimized TensorFlow Lite model for mobile efficiency.
* **Cross-Platform Design:** Flutter ensures compatibility with Android and iOS.
* **ISL Dictionary:** In-app reference for alphabets and numerals.
* **Privacy Protection:** All processing happens locally on-device.
* **User-Centric Interface:** Clean UI with animated splash screen and accessible controls.

---

## 8. System Requirements

### Hardware

* Android smartphone (Android 9.0 or later)
* Minimum 3 GB RAM
* 12 MP camera and functional microphone

### Software

* Flutter SDK (3.0 or later)
* TensorFlow Lite and MediaPipe libraries
* Android Studio or VS Code IDE

---

## 9. Installation Guide

1. **Clone the repository**

   ```bash
   git clone https://github.com/Sign-Language-Recognition-App-using-Deep-Learning/SignApp.git
   cd SignApp
   ```

2. **Install dependencies**

   ```bash
   flutter pub get
   ```

3. **Add model and assets**

   * Place the `.tflite` model file under `assets/model/`.
   * Add ISL dictionary images or animations under `assets/dictionary/`.
   * Update `pubspec.yaml` to include these assets.

4. **Run the application**

   ```bash
   flutter run
   ```

---

## 10. Uniqueness of the Project

* Designed specifically for **Indian Sign Language**, addressing linguistic and regional gaps.
* Operates **without any external sensors or internet**.
* Provides **real-time, two-way translation** capability.
* Focuses on **accessibility, affordability, and scalability**.
* Can function as an **assistive tool and educational platform** for learning ISL.

Compared to existing global systems focused on ASL or hardware-based setups, **SignApp** is lightweight, mobile-centric, and culturally adaptive for Indian users.

---

## 11. Future Enhancements

* Integration of **regional languages** (Tamil, Hindi, etc.).
* Implementation of **emotion detection** using facial expression recognition.
* Incorporation of **LSTM/Transformer models** for sentence-level gesture recognition.
* Development of **AI avatar animation** with body and facial gestures.
* Addition of **offline learning modules** for educational purposes.

---

## 12. Conclusion

**SignApp** successfully demonstrates the potential of artificial intelligence and computer vision in enhancing communication accessibility for hearing and speech-impaired individuals. The system achieves high accuracy, low latency, and full offline functionality, making it a **practical, real-time assistive tool** for everyday use. By integrating ISL recognition and speech translation in a single mobile application, SignApp promotes inclusivity, social engagement, and equal opportunities through technological innovation.

