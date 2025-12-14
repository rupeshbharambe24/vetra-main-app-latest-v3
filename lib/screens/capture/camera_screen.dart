// lib/screens/capture/camera_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  MethodChannel? _methodChannel;
  EventChannel? _eventChannel;
  
  String _centerDepthText = "Detecting...";
  bool _isCapturing = false;

  void _onPlatformViewCreated(int id) {
    _methodChannel = MethodChannel('com.example.vetra/ar_view_$id');
    _methodChannel!.setMethodCallHandler(_handleMethodCall);

    _eventChannel = EventChannel('com.example.vetra/ar_depth_stream_$id');
    _eventChannel!.receiveBroadcastStream().listen(_onDepthEvent, onError: (e) {
      setState(() {
        _centerDepthText = "Error: $e";
      });
    });
  }

  void _onDepthEvent(dynamic event) {
    if (event is double) {
      setState(() {
        _centerDepthText = "Depth: ${event.toStringAsFixed(2)} m";
      });
    }
  }

  Future<dynamic> _handleMethodCall(MethodCall call) async {
    if (call.method == "onCaptureComplete") {
      final args = call.arguments as Map;
      final success = args['success'] as bool;
      final path = args['depthFilePath'] as String?;
      final imagePath = args['imageFilePath'] as String?; // Get image path
      
      setState(() {
        _isCapturing = false;
      });

      if (success && imagePath != null) {
        // Navigate to review with IMAGE
        if (mounted) {
           // We pass imagePath to review, but return depthPath (or both?) to protocol?
           // The protocol expects a 'file' path to show. It likely wants the image.
           // But we need to save the depth too. 
           // Usually protocol stores the image path. The depth path is implicit or associated.
           // For now, let's return the IMAGE path so the UI works.
           // We might need to store the depth path in a sidecar or session repo.
           // Assuming we just need to return a path for valid display.
           final result = await context.push('/capture/review', extra: imagePath);
           if (result != null && mounted) {
             context.pop(result); // Return the confirmed image path
           }
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Capture failed")));
        }
      }
    }
  }

  Future<void> _capture() async {
    if (_isCapturing || _methodChannel == null) return;
    setState(() {
      _isCapturing = true;
    });
    try {
      await _methodChannel!.invokeMethod('captureDepth');
    } catch (e) {
      setState(() {
        _isCapturing = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
    }
  }

  @override
  Widget build(BuildContext context) {
    // Determine view type based on platform (Android only for now)
    // agents.md focused on Android.
    if (Theme.of(context).platform != TargetPlatform.android) {
       return const Scaffold(body: Center(child: Text("AR only supported on Android")));
    }

    return Scaffold(
      body: Stack(
        children: [
          AndroidView(
            viewType: 'vetra_ar_view',
            onPlatformViewCreated: _onPlatformViewCreated,
            creationParamsCodec: const StandardMessageCodec(),
          ),
          
          // Header / Back Button
          Positioned(
            top: MediaQuery.of(context).padding.top + 10,
            left: 10,
            child: BackButton(color: Colors.white, onPressed: () => context.pop()),
          ),

          // Depth Overlay
          Positioned(
            top: MediaQuery.of(context).padding.top + 20,
            left: 0, 
            right: 0,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  _centerDepthText,
                  style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),

          // Capture Button
          Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                GestureDetector(
                  onTap: _capture,
                  child: Container(
                    height: 74,
                    width: 74,
                    decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: Colors.white, width: 4)),
                    child: Center(
                      child: _isCapturing
                          ? const SizedBox(width: 26, height: 26, child: CircularProgressIndicator(color: Colors.white))
                          : Container(height: 46, width: 46, decoration: const BoxDecoration(shape: BoxShape.circle, color: Colors.white)),
                    ),
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
