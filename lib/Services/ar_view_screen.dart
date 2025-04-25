import 'package:ar_flutter_plugin/datatypes/config_planedetection.dart';
import 'package:ar_flutter_plugin/datatypes/node_types.dart';
import 'package:ar_flutter_plugin/managers/ar_anchor_manager.dart';
import 'package:ar_flutter_plugin/managers/ar_location_manager.dart';
import 'package:ar_flutter_plugin/managers/ar_object_manager.dart';
import 'package:ar_flutter_plugin/managers/ar_session_manager.dart';
import 'package:ar_flutter_plugin/models/ar_node.dart';
import 'package:flutter/material.dart';
import 'package:ar_flutter_plugin/ar_flutter_plugin.dart';
import 'package:vector_math/vector_math_64.dart';

class ARViewScreen extends StatefulWidget {
  const ARViewScreen({Key? key}) : super(key: key);

  @override
  State<ARViewScreen> createState() => _ARViewScreenState();
}

class _ARViewScreenState extends State<ARViewScreen> {
  late ARSessionManager arSessionManager;
  late ARObjectManager arObjectManager;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AR View'),
      ),
      body: ARView(
        onARViewCreated: onARViewCreated,
        planeDetectionConfig: PlaneDetectionConfig.horizontal,
      ),
    );
  }

  void onARViewCreated(
      ARSessionManager arSessionManager,
      ARObjectManager arObjectManager,
      ARAnchorManager arAnchorManager,
      ARLocationManager arLocationManager,
      ) {
    this.arSessionManager = arSessionManager;
    this.arObjectManager = arObjectManager;

    arSessionManager.onInitialize(
      showFeaturePoints: false,
      showPlanes: true,
      customPlaneTexturePath: "assets/triangle.png",
      showWorldOrigin: true,
    );

    arObjectManager.onInitialize();

    addARImagePlane();
  }

  Future<void> addARImagePlane() async {
    var imageNode = ARNode(
      type: NodeType.localGLTF2,
      uri: "assets/overlay_image.glb", // You must add this to pubspec.yaml
      scale: Vector3(0.3, 0.3, 0.3),
      position: Vector3(0.0, 0.0, -1.0),
      rotation: Vector4(1.0, 0.0, 0.0, 0.0),
    );

    await arObjectManager.addNode(imageNode);
  }


  @override
  void dispose() {
    arSessionManager.dispose();
    super.dispose();
  }
}
