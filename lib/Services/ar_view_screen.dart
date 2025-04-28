import 'package:arcore_flutter_plugin/arcore_flutter_plugin.dart';
import 'package:flutter/material.dart';
import 'package:vector_math/vector_math_64.dart' as vector;

class ARViewScreen extends StatefulWidget {
  const ARViewScreen({Key? key}) : super(key: key);

  @override
  _ARViewScreenState createState() => _ARViewScreenState();
}

class _ARViewScreenState extends State<ARViewScreen> {
  late ArCoreController arCoreController;

  @override
  void dispose() {
    arCoreController.dispose();
    super.dispose();
  }

  void _onArCoreViewCreated(ArCoreController controller) {
    arCoreController = controller;
    _addSphere();
  }

  void _addSphere() {
    final material = ArCoreMaterial(color: Colors.blue);
    final sphere = ArCoreSphere(materials: [material], radius: 0.1);
    final node = ArCoreNode(
      shape: sphere,
      position: vector.Vector3(0, 0, -1.0),
    );
    arCoreController.addArCoreNode(node);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('AR View')),
      body: ArCoreView(
        onArCoreViewCreated: _onArCoreViewCreated,
        enableTapRecognizer: true,
      ),
    );
  }
}
