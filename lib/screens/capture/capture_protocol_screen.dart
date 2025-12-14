// lib/screens/capture/capture_protocol_screen.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../core/widgets/vetra_gradient_scaffold.dart';
import '../../core/widgets/vetra_back_button.dart';
import '../../core/widgets/primary_button.dart';
import '../../database/repositories/session_repository.dart';

class CaptureProtocolScreen extends StatefulWidget {
  const CaptureProtocolScreen({super.key});

  @override
  State<CaptureProtocolScreen> createState() => _CaptureProtocolScreenState();
}

class _CaptureProtocolScreenState extends State<CaptureProtocolScreen> {
  // Define the required views
  final List<Map<String, dynamic>> _steps = [
    {'title': 'Side View', 'status': 'Pending', 'file': null},
    {'title': 'Back View', 'status': 'Pending', 'file': null},
    {'title': 'Udder Side View', 'status': 'Pending', 'file': null},
    {'title': 'Udder Back View', 'status': 'Pending', 'file': null},
  ];

  // Logic to determine active step
  int get _currentStep => _steps.indexWhere((s) => s['status'] == 'Pending');
  bool get _isComplete => _steps.every((s) => s['status'] == 'Done');

// ... class definition ...

  Future<void> _uploadImage(BuildContext context, int index) async {
    // Request permission is best practice though ImagePicker often handles it
    // final status = await Permission.photos.request(); 
    // On Android 13+ it might be Permission.photos or Permission.mediaLibrary. 
    // ImagePicker handles this well usually.
    
    try {
      final XFile? file = await ImagePicker().pickImage(source: ImageSource.gallery, imageQuality: 85);
      if (file == null) return;
      
      setState(() {
        _steps[index]['file'] = file.path;
        _steps[index]['status'] = 'Done';
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  Future<void> _openCamera(BuildContext context, int index) async {
    // Permission check for Camera is still good practice
    PermissionStatus status = await Permission.camera.status;
    if (!status.isGranted) {
      status = await Permission.camera.request();
    }
    
    if (status.isPermanentlyDenied) {
      if (mounted) {
         showDialog(
           context: context,
           builder: (ctx) => AlertDialog(
             title: const Text('Camera Permission'),
             content: const Text('Camera permission is required for AR features. Please enable it in settings.'),
             actions: [
               TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
               TextButton(onPressed: () {
                 openAppSettings();
                 Navigator.pop(ctx);
               }, child: const Text('Open Settings')),
             ],
           ),
         );
      }
      return;
    }

    if (!status.isGranted) return; 

    // Navigate to AR Camera Screen
    if (mounted) {
      final result = await context.push('/capture/camera');
      if (result != null && result is String) {
          setState(() {
            _steps[index]['file'] = result;
            _steps[index]['status'] = 'Done';
          });
      }
    }
  }

  // ... imports moved to top ...

  // ... inside class ...

  final SessionRepository _sessionRepository = SessionRepository();

  Future<void> _startAnalysis() async {
    try {
      // Create session and ensure images are saved via repository
      final sessionId = await _sessionRepository.createSessionWithImages('Cattle', _steps);

      if (mounted) {
        context.push('/analysis/result', extra: {'sessionId': sessionId});
      }
    } catch (e) {
      if (mounted) {
         ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error starting analysis: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Current active index is the first pending one, or -1 if all done.
    final activeIndex = _currentStep == -1 ? _steps.length : _currentStep;

    return VetraGradientScaffold(
      appBar: AppBar(
        title: const Text('Capture Protocol', style: TextStyle(color: Colors.white)),
        centerTitle: true,
        leading: const VetraBackButton(color: Colors.white),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 30, 24, 24),
            child: Text(
              'Select views of Cattle or Buffalo',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 24,
                  ),
              textAlign: TextAlign.center,
            ),
          ),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              itemCount: _steps.length,
              separatorBuilder: (_, __) => const SizedBox(height: 60),
              itemBuilder: (ctx, i) {
                final step = _steps[i];
                final isDone = step['status'] == 'Done';
                final isLocked = i > activeIndex; // Locked if after current active step
                final isActive = i == activeIndex; // The one currently needed

                return Opacity(
                  opacity: isLocked ? 0.5 : 1.0,
                  child: Card(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    color: isActive ? Colors.white : Colors.white.withOpacity(0.9), // Highlight active
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                      child: Row(
                        children: [
                           // Icon/Number
                           Container(
                             width: 32, height: 32,
                             alignment: Alignment.center,
                             decoration: BoxDecoration(
                               color: isDone ? Colors.green : (isActive ? Theme.of(context).primaryColor : Colors.grey),
                               shape: BoxShape.circle,
                             ),
                             child: isDone 
                               ? const Icon(Icons.check, color: Colors.white, size: 20)
                               : Text('${i+1}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                           ),
                           const SizedBox(width: 16),
                           
                           // Text
                           Expanded(
                             child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                               Text(step['title'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                               if (isDone) 
                                 const Text('captured', style: TextStyle(color: Colors.green, fontSize: 12))
                               else if (isActive)
                                 const Text('Tap options to capture', style: TextStyle(color: Colors.blue, fontSize: 12))
                               else
                                 const Text('Locked', style: TextStyle(color: Colors.grey, fontSize: 12)),
                             ]),
                           ),

                           // Actions (Only if active or done - to retake?)
                           // Requirement: "after capturing... go on next view". 
                           // We allow retake if done? "simultaneously it should take other 2 images".
                           // Let's allow interaction only if !isLocked.
                           if (!isLocked) ...[
                             IconButton(
                               onPressed: isLocked ? null : () => _uploadImage(context, i),
                               icon: const Icon(Icons.upload_file),
                               tooltip: 'Upload',
                             ),
                             IconButton(
                               onPressed: isLocked ? null : () => _openCamera(context, i),
                               icon: const Icon(Icons.camera_alt),
                               tooltip: 'Camera',
                             ),
                           ]
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          
          // Bottom Action
          if (_isComplete)
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: PrimaryButton(
                label: 'Start Analyzing',
                onPressed: _startAnalysis,
                expanded: true,
              ),
            )
          else 
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Text(
                'Capture all views to proceed', 
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.white70),
                textAlign: TextAlign.center,
              ),
            ),
        ],
        ),
      ),
    );
  }
}
