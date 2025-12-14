import 'dart:io';
import 'package:flutter/material.dart';
import '../../core/widgets/vetra_back_button.dart';
import '../../core/widgets/vetra_gradient_scaffold.dart';
import '../../database/sqlite_service.dart';
import 'package:go_router/go_router.dart';

class RecordsScreen extends StatefulWidget {
  const RecordsScreen({super.key});

  @override
  State<RecordsScreen> createState() => _RecordsScreenState();
}

class _RecordsScreenState extends State<RecordsScreen> {
  final SQLiteService _db = SQLiteService();
  late Future<List<Map<String, dynamic>>> _recordsFuture;

  @override
  void initState() {
    super.initState();
    _recordsFuture = _db.getSessionsWithThumbnail();
  }

  Future<void> _refresh() async {
    setState(() {
      _recordsFuture = _db.getSessionsWithThumbnail();
    });
  }

  @override
  Widget build(BuildContext context) {
    return VetraGradientScaffold(
      appBar: AppBar(
        title: const Text('Records', style: TextStyle(color: Colors.white)),
        leading: const VetraBackButton(color: Colors.white),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _recordsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Colors.white));
          }
          
          if (snapshot.hasError) {
             return Center(child: Text('Error: ${snapshot.error}', style: const TextStyle(color: Colors.white)));
          }

          final rows = snapshot.data ?? [];
          
          if (rows.isEmpty) {
             return const Center(child: Text('No records found.', style: TextStyle(color: Colors.white70)));
          }

          return RefreshIndicator(
            onRefresh: _refresh,
            child: ListView.builder(
              padding: const EdgeInsets.only(top: 100, bottom: 40),
              itemCount: rows.length,
              itemBuilder: (c, i) {
                final r = rows[i];
                final id = r['id'];
                final type = r['animal_type'] ?? 'Unknown';
                final dateRaw = r['created_at'];
                final imagePath = r['file_path'];
                
                // Simple date formatting
                String dateDisplay = dateRaw.toString().split('T').first;
                if (dateRaw.contains('T')) {
                   final time = dateRaw.split('T').last.split('.').first;
                   dateDisplay = '$dateDisplay $time';
                }

                return Card(
                   margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                   shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                   elevation: 2,
                   child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    leading: Container(
                      width: 60, height: 60,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(8),
                        image: imagePath != null && File(imagePath).existsSync()
                             ? DecorationImage(image: FileImage(File(imagePath)), fit: BoxFit.cover)
                             : null,
                      ),
                      child: (imagePath == null || !File(imagePath).existsSync()) 
                          ? const Icon(Icons.image_not_supported, color: Colors.grey) 
                          : null,
                    ),
                    title: Text(type, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text('Session #$id • $dateDisplay'),
                    trailing: IconButton(
                       onPressed: () => context.push('/analysis/result', extra: {'sessionId': id}),
                       icon: const Icon(Icons.chevron_right)
                    ),
                    onTap: () => context.push('/analysis/result', extra: {'sessionId': id}),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
