import "package:flutter/material.dart";
import "package:go_router/go_router.dart";

class ARCaptureScreen extends StatelessWidget {
  const ARCaptureScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("AR Capture"),
        leading: BackButton(onPressed: () => context.pop()),
      ),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Icon(Icons.camera_enhance, size: 100),
            SizedBox(height: 10),
            Text("Camera Placeholder"),
          ],
        ),
      ),
    );
  }
}
