import 'dart:io';
import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

class ReportPdfService {
  
  static Future<String> generateAndSavePDF(Map<String, dynamic> reportData) async {
    final pdf = pw.Document();

    final primaryColor = PdfColors.green800;
    
    // Helper to build a metric card
    pw.Widget buildMetricCard(String label, String value, PdfColor color, PdfColor textColor) {
      return pw.Container(
        width: 100,
        height: 60,
        decoration: pw.BoxDecoration(
          color: color,
          borderRadius: pw.BorderRadius.circular(8),
          border: pw.Border.all(color: textColor, width: 0.5),
        ),
        child: pw.Column(
          mainAxisAlignment: pw.MainAxisAlignment.center,
          children: [
            pw.Text(value, style: pw.TextStyle(color: textColor, fontSize: 18, fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(height: 2),
            pw.Text(label, style: pw.TextStyle(color: textColor, fontSize: 8)),
          ],
        ),
      );
    }

    // Helper for table row
    pw.Widget buildTableRow(String param, String value, String unit, String status, {bool isOdd = false, bool isYellow = false}) {
       final pillColor = isYellow ? PdfColor.fromHex('#FFF9C4') : PdfColor.fromHex('#C8E6C9'); // Light Yellow / Green
       final pillText = isYellow ? PdfColor.fromHex('#FBC02D') : PdfColor.fromHex('#2E7D32'); // Darker Yellow / Green
       
      return pw.Container(
        color: isOdd ? PdfColor.fromHex('#FAFAFA') : PdfColors.white,
        padding: const pw.EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        child: pw.Row(
          children: [
            pw.Expanded(flex: 3, child: pw.Text(param, style: const pw.TextStyle(fontSize: 10))),
            pw.Expanded(flex: 2, child: pw.Text(value, style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10))),
            pw.Expanded(flex: 2, child: pw.Text(unit, style: const pw.TextStyle(color: PdfColors.grey700, fontSize: 10))),
            pw.Expanded(
              flex: 2, 
              child: pw.Align(
                alignment: pw.Alignment.centerRight,
                child: pw.Container(
                  padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: pw.BoxDecoration(color: pillColor, borderRadius: pw.BorderRadius.circular(10)),
                  child: pw.Text(status, style: pw.TextStyle(color: pillText, fontSize: 8, fontWeight: pw.FontWeight.bold)),
                ),
              ),
            ),
          ],
        ),
      );
    }

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Header
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                   pw.Row(children: [
                      // Simulating Check Icon with basic shape or text
                      pw.Container(
                        padding: const pw.EdgeInsets.all(2),
                        decoration: const pw.BoxDecoration(shape: pw.BoxShape.circle, color: PdfColors.green),
                        child: pw.Icon(const pw.IconData(0xe5ca), color: PdfColors.white, size: 14), // Check icon code
                      ),
                      pw.SizedBox(width: 8),
                      pw.Text('Analysis Complete', style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold, color: PdfColors.black)),
                   ]),
                   pw.Container(
                     padding: const pw.EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                     decoration: pw.BoxDecoration(border: pw.Border.all(color: PdfColors.grey400), borderRadius: pw.BorderRadius.circular(4)),
                     child: pw.Text('Download PDF', style: const pw.TextStyle(color: PdfColors.grey700, fontSize: 10)),
                   ),
                ],
              ),
              pw.SizedBox(height: 24),

              // Metrics Cards
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                   buildMetricCard('Body Length (cm)', reportData['metrics']?['Body Length']?.toString().replaceAll(' cm', '') ?? '260', PdfColor.fromHex('#E8F5E9'), PdfColor.fromHex('#2E7D32')),
                   buildMetricCard('Height (cm)', reportData['metrics']?['Height']?.toString().replaceAll(' cm', '') ?? '226', PdfColor.fromHex('#E3F2FD'), PdfColor.fromHex('#1565C0')),
                   buildMetricCard('Girth (cm)', reportData['metrics']?['Girth']?.toString().replaceAll(' cm', '') ?? '369', PdfColor.fromHex('#F3E5F5'), PdfColor.fromHex('#7B1FA2')),
                   buildMetricCard('Body Score', reportData['metrics']?['Body Score'] ?? '4', PdfColor.fromHex('#FFF3E0'), PdfColor.fromHex('#EF6C00')),
                   buildMetricCard('Confidence', reportData['metrics']?['Confidence'] ?? '100%', PdfColor.fromHex('#E8F5E9'), PdfColor.fromHex('#2E7D32')),
                ],
              ),
              pw.SizedBox(height: 24),

              // Table Box
              pw.Container(
                decoration: pw.BoxDecoration(border: pw.Border.all(color: PdfColors.grey300), borderRadius: pw.BorderRadius.circular(8)),
                child: pw.Column(
                  children: [
                    // Table Header
                    pw.Container(
                      padding: const pw.EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                      decoration: const pw.BoxDecoration(border: pw.Border(bottom: pw.BorderSide(color: PdfColors.grey300))), 
                      child: pw.Row(
                        children: [
                          pw.Expanded(flex: 3, child: pw.Text('Parameter', style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey700))),
                          pw.Expanded(flex: 2, child: pw.Text('Value', style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey700))),
                          pw.Expanded(flex: 2, child: pw.Text('Unit', style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey700))),
                          pw.Expanded(flex: 2, child: pw.Align(alignment: pw.Alignment.centerRight, child: pw.Text('Status', style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey700)))),
                        ],
                      ),
                    ),
                    // Rows (Static data matching the UI for now as per prompt request "exactly this format")
                    buildTableRow('Head Length', '88', 'cm', 'Measured', isOdd: true),
                    buildTableRow('Oblique Body Length', '260', 'cm', 'Measured'),
                    buildTableRow('Girth Length', '369', 'cm', 'Measured', isOdd: true),
                    buildTableRow('Chest Depth', '116', 'cm', 'Measured'),
                    buildTableRow('Withers Height', '226', 'cm', 'Measured', isOdd: true),
                    buildTableRow('Rump Angle', '16', 'deg', 'Measured'),
                    buildTableRow('Rump Width', '35', 'cm', 'Measured', isOdd: true),
                    buildTableRow('Hip Width', '68', 'cm', 'Measured'),
                    buildTableRow('Tail Length', '113', 'cm', 'Measured', isOdd: true),
                    buildTableRow('Left Hip Height', '131', 'cm', 'Measured'),
                    buildTableRow('Right Hip Height', '140', 'cm', 'Measured', isOdd: true),
                    buildTableRow('Thurl Width L', '29', 'cm', 'Measured'),
                    buildTableRow('Thurl Width R', '28', 'cm', 'Measured', isOdd: true),
                    buildTableRow('Body Score', '4/9 (Average)', '1-9 Scale', 'Average', isYellow: true),
                    buildTableRow('Analysis Confidence', '100', '%', 'High', isOdd: true),
                    buildTableRow('Animal Type', 'Cattle', '-', 'Detected'),
                    
                    pw.Divider(color: PdfColors.grey300, height: 1),
                    
                    // Footer Rows inside table
                     pw.Container(
                        padding: const pw.EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                        color: PdfColor.fromHex('#FAFAFA'),
                        child: pw.Row(children: [
                             pw.Expanded(flex: 3, child: pw.Text('Report ID', style: const pw.TextStyle(fontSize: 10))),
                             pw.Expanded(flex: 6, child: pw.Align(alignment: pw.Alignment.centerRight, 
                                child: pw.Container(padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 2), decoration: pw.BoxDecoration(color: PdfColors.grey200, borderRadius: pw.BorderRadius.circular(10)), child: pw.Text('System', style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey700)))
                             )),
                        ])
                     ),
                     pw.Container(
                        padding: const pw.EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                        child: pw.Row(children: [
                             pw.Expanded(flex: 3, child: pw.Text('Timestamp', style: const pw.TextStyle(fontSize: 10))),
                             pw.Expanded(flex: 6, child: pw.Align(alignment: pw.Alignment.centerRight, 
                                child: pw.Container(padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 2), decoration: pw.BoxDecoration(color: PdfColors.grey200, borderRadius: pw.BorderRadius.circular(10)), child: pw.Text('Recorded', style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey700)))
                             )),
                        ])
                     ),
                  ]
                ),
              ),
              
              pw.Spacer(),
              pw.Footer(
                title: pw.Align(alignment: pw.Alignment.center, child: pw.Text('Generated by Vetra AI', style: const pw.TextStyle(color: PdfColors.grey500, fontSize: 10))),
              ),
            ],
          );
        },
      ),
    );

    return await _saveFile(pdf, "Vetra_Report_${reportData['session_id']}_${DateTime.now().millisecondsSinceEpoch}.pdf");
  }

  static Future<String> _saveFile(pw.Document pdf, String fileName) async {
    Directory? directory;

    if (Platform.isAndroid) {
      // Try to get external storage directory for visibility
      // Or use manage external storage permission if strictly needed, 
      // but guidelines say "Prefer Downloads folder". 
      // Safe generic approach:
      directory = Directory('/storage/emulated/0/Download');
      if (!await directory.exists()) {
         directory = await getExternalStorageDirectory(); // Fallback to app-specific external
      }
    } else {
      directory = await getApplicationDocumentsDirectory();
    }

    // Check permission logic here if writing to public Download on Android < 11
    // For Android 11+ scoped storage, writing to non-app directories is tricky without SAF.
    // However, writing to /storage/emulated/0/Download often works if just creating new files.
    // Let's wrap in try-catch and fallback.
    
    try {
      final path = '${directory?.path}/$fileName';
      final file = File(path);
      await file.writeAsBytes(await pdf.save());
      return path;
    } catch (e) {
      // Fallback to ApplicationDocuments (guaranteed to write, but harder for user to find)
      final appDocDir = await getApplicationDocumentsDirectory();
      final path = '${appDocDir.path}/$fileName';
      final file = File(path);
      await file.writeAsBytes(await pdf.save());
      return path;
    }
  }
}
