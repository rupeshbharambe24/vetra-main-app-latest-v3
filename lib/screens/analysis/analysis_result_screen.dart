import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'dart:convert';
import '../../core/widgets/vetra_gradient_scaffold.dart';
import '../../core/widgets/vetra_back_button.dart';
import '../../database/repositories/session_repository.dart';
import '../../database/sqlite_service.dart';
import '../../database/models/captured_image_model.dart';
import 'dart:io';

class AnalysisResultScreen extends StatefulWidget {
  final int? sessionId;
  const AnalysisResultScreen({super.key, this.sessionId});

  @override
  State<AnalysisResultScreen> createState() => _AnalysisResultScreenState();
}

class _AnalysisResultScreenState extends State<AnalysisResultScreen> {
  final SessionRepository _sessionRepository = SessionRepository();
  final SQLiteService _db = SQLiteService();
  late Future<List<CapturedImageModel>> _imagesFuture;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.sessionId != null) {
      _imagesFuture = _db.getImagesForSession(widget.sessionId!);
    } else {
      _imagesFuture = Future.value([]);
    }
  }

  Future<void> _downloadPDF() async {
    if (widget.sessionId == null) return;
    
    setState(() => _isLoading = true);
    
    try {
      final reportData = {
        'session_id': widget.sessionId,
        'created_at': DateTime.now().toString(),
        'animal_type': 'Cattle',
        'metrics': {
           'Body Length': '260 cm',
           'Height': '226 cm',
           'Girth': '369 cm',
           'Body Score': '4/9',
           'Confidence': '100%',
        }
      };

      // Use Repository to generate and save
      final path = await _sessionRepository.generateAndSaveReport(widget.sessionId!, reportData);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Report saved to: $path'), duration: const Duration(seconds: 4)),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error generating PDF: $e')));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showImagePreview(BuildContext context, String imagePath) {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: EdgeInsets.zero,
        child: Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(
              width: double.infinity,
              height: double.infinity,
              child: InteractiveViewer(
                child: Image.file(File(imagePath), fit: BoxFit.contain),
              ),
            ),
            Positioned(
              top: 40,
              right: 20,
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.white, size: 30),
                onPressed: () => Navigator.pop(ctx),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Handling navigation extra if widget.sessionId is null (which happens with GoRouter construction usually)
    // But since we pass it in constructor in our route definition (next step), we rely on that.
    // If route definition doesn't pass it, we might need to look at GoRouterState.
    
    return VetraGradientScaffold(
      // appBar: null, // Removing AppBar property to handle it custom in body
      body: SafeArea(
        child: ListView(
        padding: const EdgeInsets.all(0), 
        children: [
          // Custom Header (Scrollable)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const VetraBackButton(color: Colors.white),
                    const SizedBox(width: 8),
                    const Text('Analysis Complete', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                  ],
                ),
                if (_isLoading)
                   const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)),
              ],
            ),
          ),
          
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: [
                // Top Summary Cards
          const Row(
            children: [
              Expanded(child: _SummaryCard(label: 'Body Length (cm)', value: '260', color: Color(0xFFE8F5E9), textColor: Color(0xFF2E7D32))),
              SizedBox(width: 8),
              Expanded(child: _SummaryCard(label: 'Height (cm)', value: '226', color: Color(0xFFE3F2FD), textColor: Color(0xFF1565C0))),
            ],
          ),
          const SizedBox(height: 8),
          const Row(
            children: [
              Expanded(child: _SummaryCard(label: 'Girth (cm)', value: '369', color: Color(0xFFF3E5F5), textColor: Color(0xFF7B1FA2))),
              SizedBox(width: 8),
              Expanded(child: _SummaryCard(label: 'Body Score', value: '4', color: Color(0xFFFFF3E0), textColor: Color(0xFFEF6C00))),
              SizedBox(width: 8),
              Expanded(child: _SummaryCard(label: 'Confidence', value: '100%', color: Color(0xFFE8F5E9), textColor: Color(0xFF2E7D32))),
            ],
          ),
          
          const SizedBox(height: 24),

          
                // IMAGES SECTION (Requested: "All 4 image views should be visible" & Minimized padding)
                const SizedBox(height: 24),
                const Text('Captured Views', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                FutureBuilder<List<CapturedImageModel>>(
                  future: _imagesFuture,
                  builder: (context, snapshot) {
                    if (!snapshot.hasData || snapshot.data!.isEmpty) {
                       return const SizedBox.shrink();
                    }
                    final images = snapshot.data!;
                    return GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 4, // Minimized padding
                        mainAxisSpacing: 4,  // Minimized padding
                        childAspectRatio: 1.0,
                      ),
                      itemCount: images.length,
                      itemBuilder: (context, index) {
                        final img = images[index];
                        final title = img.viewType.split('_').map((e) => e.capitalize()).join(' '); 
                        
                        return GestureDetector(
                          onTap: () => _showImagePreview(context, img.filePath),
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white10,
                              borderRadius: BorderRadius.circular(8), // Slightly smaller radius due to tight spacing
                              image: DecorationImage(
                                image: FileImage(File(img.filePath)),
                                fit: BoxFit.cover,
                              ),
                            ),
                            alignment: Alignment.bottomCenter,
                            child: Container(
                              width: double.infinity,
                              decoration: const BoxDecoration(
                                color: Colors.black54,
                                borderRadius: BorderRadius.only(bottomLeft: Radius.circular(8), bottomRight: Radius.circular(8)),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 2), // Smaller padding
                              child: Text(title, 
                                style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold), 
                                textAlign: TextAlign.center
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),

                const SizedBox(height: 24),
                
                // Detailed Table / List (Keeping as is, just need to ensure tags close properly for ListView children wrapper)

          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 8, offset: const Offset(0, 4))],
            ),
            child: Column(
              children: [
                _tableHeader(),
                const Divider(height: 1),
                _tableRow('Head Length', '88', 'cm', 'Measured'),
                _tableRow('Oblique Body Length', '260', 'cm', 'Measured'),
                _tableRow('Girth Length', '369', 'cm', 'Measured'),
                _tableRow('Chest Depth', '116', 'cm', 'Measured'),
                _tableRow('Withers Height', '226', 'cm', 'Measured'),
                _tableRow('Rump Angle', '16', 'deg', 'Measured'),
                _tableRow('Rump Width', '35', 'cm', 'Measured'),
                _tableRow('Hip Width', '68', 'cm', 'Measured'),
                _tableRow('Tail Length', '113', 'cm', 'Measured'),
                _tableRow('Left Hip Height', '131', 'cm', 'Measured'),
                _tableRow('Right Hip Height', '140', 'cm', 'Measured'),
                _tableRow('Thurl Width L', '29', 'cm', 'Measured'),
                _tableRow('Thurl Width R', '28', 'cm', 'Measured'),
                _tableRow('Body Score', '4/9 (Average)', '1-9 Scale', 'Average', isPillYellow: true),
                _tableRow('Analysis Confidence', '100', '%', 'High', isPillGreen: true),
                _tableRow('Animal Type', 'Cattle', '-', 'Detected', last: true),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Footer Info
          Container(
             padding: const EdgeInsets.all(12),
             decoration: BoxDecoration(color: Colors.white.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
             child: const Column(
               children: [
                 _InfoRow(label: 'Report ID', value: '63a3caa1-97bf-4a1d-b587-04405f019f91'),
                 SizedBox(height: 8),
                 _InfoRow(label: 'Timestamp', value: '12/8/2025, 5:22:37 AM'),
               ],
             ),
          ),
          
          const SizedBox(height: 24),

          // Actions
          Row(
            children: [
              Expanded(
                flex: 2,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00C853),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  onPressed: _downloadPDF,
                  child: const Row(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.description, size: 20), SizedBox(width: 8), Text('Download Full Report')]),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    side: const BorderSide(color: Colors.white),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  onPressed: () => context.go('/records'),
                  child: const Text('View All Records'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    side: const BorderSide(color: Colors.white),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  onPressed: () => context.go('/capture/protocol'),
                  child: const Text('New Analysis'),
                ),
              ),
            ],
          ),
           const SizedBox(height: 30),
            ],
          ),
          ), 
        ],
      ),
      ),
    );
  }

  Widget _tableHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          const Expanded(flex: 3, child: Text('Parameter', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey))),
          const Expanded(flex: 2, child: Text('Value', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey))),
          const Expanded(flex: 2, child: Text('Unit', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey))),
          Expanded(flex: 2, child: Container(alignment: Alignment.centerRight, child: const Text('Status', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)))),
        ],
      ),
    );
  }

  Widget _tableRow(String p, String v, String u, String s, {bool last = false, bool isPillGreen = true, bool isPillYellow = false}) {
    Color pillColor = const Color(0xFFE8F5E9);
    Color pillText = const Color(0xFF2E7D32);

    if (isPillYellow) {
      pillColor = const Color(0xFFFFF8E1);
      pillText = const Color(0xFFFFA000);
    } else if (!isPillGreen && !isPillYellow && s == 'Detected') { // Example for 'Detected' gray
       pillColor = const Color(0xFFF5F5F5);
       pillText = Colors.grey[700]!;
    }

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Expanded(flex: 3, child: Text(p, style: const TextStyle(fontWeight: FontWeight.w500))),
              Expanded(flex: 2, child: Text(v, style: const TextStyle(fontWeight: FontWeight.bold))),
              Expanded(flex: 2, child: Text(u, style: const TextStyle(color: Colors.grey))),
              Expanded(
                flex: 2,
                child: Align(
                  alignment: Alignment.centerRight,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(color: pillColor, borderRadius: BorderRadius.circular(12)),
                    child: Text(s, style: TextStyle(color: pillText, fontSize: 11, fontWeight: FontWeight.bold)),
                  ),
                ),
              ),
            ],
          ),
        ),
        if (!last) const Divider(height: 1, color: Color(0xFFEEEEEE)),
      ],
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final Color textColor;

  const _SummaryCard({required this.label, required this.value, required this.color, required this.textColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: textColor.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Text(value, style: TextStyle(color: textColor, fontSize: 22, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(label, style: TextStyle(color: textColor.withOpacity(0.8), fontSize: 11), textAlign: TextAlign.center),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label, value;
  const _InfoRow({required this.label, required this.value});
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: Colors.white70, fontSize: 12)),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            value, 
            style: const TextStyle(color: Colors.white, fontSize: 12, fontFamily: 'monospace'),
            textAlign: TextAlign.right,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

extension StringExtension on String {
  String capitalize() {
    if (isEmpty) return this;
    return "${this[0].toUpperCase()}${substring(1).toLowerCase()}";
  }
}
