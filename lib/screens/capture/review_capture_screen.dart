import 'dart:io';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/widgets/vetra_gradient_scaffold.dart';

class ReviewCaptureScreen extends StatelessWidget {
  final String? imagePath;
  const ReviewCaptureScreen({super.key, this.imagePath});

  @override
  Widget build(BuildContext context) {
    // Fallback to extra if imagePath not passed directly (legacy support)
    // But AppRouter now passes it directly.
    final path = imagePath ?? GoRouterState.of(context).extra as String?;

    return VetraGradientScaffold(
      appBar: AppBar(
        title: const Text('Review Capture', style: TextStyle(color: Colors.white)),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: path == null
          ? const Center(child: Text('No image provided', style: TextStyle(color: Colors.white)))
          : Column(
              children: [
                Expanded(child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.file(File(path), fit: BoxFit.contain)
                )),
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(side: const BorderSide(color: Colors.white), foregroundColor: Colors.white),
                          onPressed: () {
                            // retake - go back to camera (pop returns null)
                            context.pop();
                          },
                          child: const Text('Retake'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(backgroundColor: Theme.of(context).primaryColor, foregroundColor: Colors.white),
                          onPressed: () {
                            // Accept: Return path to caller
                            context.pop(path);
                          },
                          child: const Text('Accept'),
                        ),
                      ),
                    ],
                  ),
                )
              ],
            ),
    );
  }
}
