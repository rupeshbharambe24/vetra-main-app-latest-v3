import 'package:flutter/material.dart';
import '../../core/widgets/vetra_back_button.dart';
import '../../core/widgets/vetra_gradient_scaffold.dart';
import 'package:open_filex/open_filex.dart';
import '../../database/sqlite_service.dart';
import 'dart:convert';
import 'dart:io';
import '../../services/report_pdf_service.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}



class _ReportsScreenState extends State<ReportsScreen> {
  final SQLiteService _db = SQLiteService();
  late Future<List<Map<String, dynamic>>> _reportsFuture;

  @override
  void initState() {
    super.initState();
    _loadReports();
  }

  void _loadReports() {
    setState(() {
      _reportsFuture = _db.getAllReports();
    });
  }

  Future<void> _openReport(Map<String, dynamic> reportRecord) async {
    // Extract info from the DB record
    String? jsonStr = reportRecord['report_json'];
    Map<String, dynamic> reportData = {};
    String? filePath;

    if (jsonStr != null) {
      try {
        reportData = jsonDecode(jsonStr);
        if (reportData.containsKey('filePath')) {
          filePath = reportData['filePath'];
        }
      } catch (_) {}
    }

    // Checking if file exists
    bool fileExists = false;
    if (filePath != null) {
      fileExists = await File(filePath).exists();
    }

    // Fallback: Regenerate if missing
    if (!fileExists) {
      // We need valid reportData to regenerate involving metrics etc.
      // If we have reportData from JSON, we can try to regenerate.
      if (reportData.isNotEmpty) {
          try {
             ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Regenerating report...')));
             // Regenerate
             final newPath = await ReportPdfService.generateAndSavePDF(reportData);
             filePath = newPath;
             
             // Ideally here we could update the DB with the new path to avoid regen next time,
             // but strictly we can just open it.
          } catch (e) {
             ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error regenerating: $e')));
             return;
          }
      } else {
         ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Report data corrupted or missing.')));
         return;
      }
    }

    // Final attempt to open
    if (filePath != null) {
        final result = await OpenFilex.open(filePath);
        if (result.type != ResultType.done) {
           if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Could not open file: ${result.message}')));
        }
    } else {
       if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Report file path missing')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return VetraGradientScaffold(
      appBar: AppBar(
        title: const Text('Reports', style: TextStyle(color: Colors.white)),
        leading: const VetraBackButton(color: Colors.white),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _reportsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Colors.white));
          }
          if (snapshot.hasError) {
             return Center(child: Text('Error: ${snapshot.error}', style: const TextStyle(color: Colors.white)));
          }
          
          final reports = snapshot.data ?? [];
          if (reports.isEmpty) {
             return const Center(child: Text('No reports generated yet.', style: TextStyle(color: Colors.white70)));
          }

          return ListView.builder(
            padding: const EdgeInsets.only(top: 100, bottom: 40),
            itemCount: reports.length,
            itemBuilder: (c, i) {
              final r = reports[i];
              // Parsing logic depends on what we stored. 
              // Assuming report_json JSON string contains "filePath" or similar if we modified it.
              // If not, we might be missing the file path storage.
              // Taking a safe bet: display what we have and try to extract path.
              
              String title = 'Report #${r['id']}';
              String subtitle = r['created_at'].toString().split('T').first;
              String? filePath;
              
              if (r['animal_type'] != null) title = '${r['animal_type']} Report';

              if (r['report_json'] != null) {
                  try {
                      final data = jsonDecode(r['report_json']);
                      if (data is Map && data.containsKey('filePath')) {
                          filePath = data['filePath'];
                      }
                  } catch (_) {}
              }

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: ListTile(
                  leading: const Icon(Icons.picture_as_pdf, color: Colors.redAccent),
                  title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(subtitle),
                  trailing: IconButton(
                      onPressed: () => _openReport(r),
                      icon: const Icon(Icons.open_in_new, color: Colors.blue)
                  ),
                  onTap: () => _openReport(r),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
