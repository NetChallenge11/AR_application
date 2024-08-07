import 'package:arcore_flutter_plugin/arcore_flutter_plugin.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:vector_math/vector_math_64.dart' as vector64;

class ArEarthMapScreen extends StatefulWidget {
  const ArEarthMapScreen({super.key});

  @override
  State<ArEarthMapScreen> createState() => _ArEarthMapScreenState();
}

class _ArEarthMapScreenState extends State<ArEarthMapScreen> {
  ArCoreController? augmentedRealityCoreController;
  ArCoreNode? earthNode;

  @override
  void dispose() {
    augmentedRealityCoreController?.dispose();
    super.dispose();
  }

  void augmentedRealityViewCreated(ArCoreController coreController) {
    augmentedRealityCoreController = coreController;
    augmentedRealityCoreController!.onError = (String error) {
      print("ARCore Error: $error");
    };

    // Set up a tap listener
    augmentedRealityCoreController!.onPlaneTap = (List<ArCoreHitTestResult> hits) {
      if (hits.isNotEmpty) {
        final hit = hits.first;
        if (earthNode == null) {
          // Display the AR texture at the tapped location
          displayArTexture(hit);
        } else {
          // Remove the node if it exists
          augmentedRealityCoreController!.removeNode(nodeName: earthNode!.name!);
          earthNode = null;
        }
      }
    };
  }

  void displayArTexture(ArCoreHitTestResult hit) async {
    // Load the image as texture
    final ByteData textureBytes = await rootBundle.load("images/clipboard.jpg");

    // Create a material with the image texture
    final material = ArCoreMaterial(
      color: Colors.transparent, // Base color
      textureBytes: textureBytes.buffer.asUint8List(),
    );

    // Create a shape to apply the material
    final cube = ArCoreCube(
      materials: [material],
      size: vector64.Vector3(1, 0.01, 1), // Very thin cube to simulate a plane
    );

    // Create a node with the cube shape
    final node = ArCoreNode(
      name: "earthNode",
      shape: cube,
      position: hit.pose.translation, // Use the tapped position
      rotation: vector64.Vector4(1.0, 0.0, 0.0, -3.14159 / 2), // Correct 90-degree rotation
      scale: vector64.Vector3(1, 1, 1), // Adjust scale if needed
    );

    augmentedRealityCoreController?.addArCoreNodeWithAnchor(node);
    earthNode = node;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("AR Store Sign"),
        centerTitle: true,
      ),
      body: ArCoreView(
        onArCoreViewCreated: augmentedRealityViewCreated,
        enableTapRecognizer: true, // Enable tap recognition
      ),
    );
  }
}
