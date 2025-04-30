import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:panorama_viewer/panorama_viewer.dart';

class PanoramaImageScreen extends StatelessWidget {
  final Uint8List imageBytes;

  const PanoramaImageScreen({Key? key, required this.imageBytes}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('360° View')),
      body: PanoramaViewer(
        child: Image.memory(imageBytes),
      ),
    );
  }
}
