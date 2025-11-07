import 'dart:typed_data';
import 'package:tflite_flutter/tflite_flutter.dart';

class KeyPointClassifier {
  late Interpreter _interpreter;
  late List<int> _inputShape;
  late List<int> _outputShape;

  Future<void> load({String modelPath = 'assets/models/model.tflite'}) async {
    _interpreter = await Interpreter.fromAsset(modelPath);
    _inputShape = _interpreter.getInputTensor(0).shape;
    _outputShape = _interpreter.getOutputTensor(0).shape;

    print('✅ Loaded model: $modelPath');
    print('Input shape: $_inputShape');
    print('Output shape: $_outputShape');
    print('Input type: ${_interpreter.getInputTensor(0).type}');
    print('Output type: ${_interpreter.getOutputTensor(0).type}');
  }

  int call(List<double> landmarkList) {
    // Ensure input shape = [1, N]
    final inputLen = landmarkList.length;
    if (_inputShape.length == 2 && _inputShape[1] != inputLen) {
      _interpreter.resizeInputTensor(0, [1, inputLen]);
      _interpreter.allocateTensors();
      _inputShape = _interpreter.getInputTensor(0).shape;
      _outputShape = _interpreter.getOutputTensor(0).shape;
    }

    // Convert to Float32 input tensor
    final inputBuffer = Float32List.fromList(landmarkList).reshape([1, inputLen]);

    // Prepare output buffer
    final outputBuffer = List.filled(_outputShape.reduce((a, b) => a * b), 0.0)
        .reshape([1, _outputShape.last]);

    // Run inference
    _interpreter.run(inputBuffer, outputBuffer);

    // Convert to usable probabilities
    final probabilities = List<double>.from(outputBuffer[0]);

    // Find max index
    int maxIndex = 0;
    double maxValue = probabilities[0];
    for (int i = 1; i < probabilities.length; i++) {
      if (probabilities[i] > maxValue) {
        maxValue = probabilities[i];
        maxIndex = i;
      }
    }

    print('Prediction probabilities: $probabilities');
    print('Predicted index: $maxIndex');

    return maxIndex;
  }

  void dispose() {
    _interpreter.close();
  }
}
