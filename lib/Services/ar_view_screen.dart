import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:panorama/panorama.dart';
import '../Widgets/the_app_bar.dart';

class PanoramaViewerScreen extends StatelessWidget {
  final Uint8List imageBytes;

  const PanoramaViewerScreen({super.key, required this.imageBytes});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: TheAppBar(content: "360° Viewer", style: 2),
      body: Panorama(
        animSpeed: 1.0,
        sensorControl: SensorControl.Orientation,
        child: Image.memory(imageBytes),
      ),
    );
  }
}
