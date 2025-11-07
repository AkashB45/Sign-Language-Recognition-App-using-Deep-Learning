import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class MyCameraView extends StatefulWidget {
  const MyCameraView({super.key});

  @override
  State<MyCameraView> createState() => _MyCameraViewState();
}

class _MyCameraViewState extends State<MyCameraView> {
  final Map<String, dynamic> creationParams = <String, dynamic>{};

  @override
  Widget build(BuildContext context) {
    return Platform.isAndroid
        ? AndroidView(
            viewType: 'cameraView',
            layoutDirection: TextDirection.ltr,
            creationParams: creationParams,
            creationParamsCodec: const StandardMessageCodec(),
          )
        : const Placeholder();
  }
}
