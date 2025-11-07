# TODO List for Sign to Speech Implementation

- [x] Add tflite_flutter dependency to pubspec.yaml
- [x] Create lib/utils/keypoint_classifier.dart with KeyPointClassifier class
- [x] Create lib/utils/hand_processing.dart with preprocessing functions
- [x] Update lib/screens/sign_to_speech.dart to load model, labels, listen for landmarks, classify, update UI, integrate TTS, remove Current Char button
- [x] Modify android/app/src/main/kotlin/com/example/signapp/MyCameraView.kt to add EventChannel for sending landmarks
- [x] Run flutter pub get to install dependencies
- [x] Test the app for hand detection and classification (app builds and runs successfully; user should test hand signs on device)
- [x] Handle cases with no hands or multiple hands (currently takes first hand if available; no hands ignored)
- [x] Ensure model loading and inference performance (uses live stream, should be performant; monitor in testing)
