import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:panorama_viewer/panorama_viewer.dart';

import '../Widgets/the_app_bar.dart';

class PanoramaImageScreen extends StatelessWidget {
  final Uint8List imageBytes;

  const PanoramaImageScreen({Key? key, required this.imageBytes}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: TheAppBar(content: '360° View',style: 2,),
      body: PanoramaViewer(
        child: Image.memory(imageBytes),
      ),
    );
  }
}
