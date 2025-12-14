import 'dart:io';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'dart:convert';
import '../sqlite_service.dart';
import '../models/session_model.dart';
import '../models/captured_image_model.dart';
import '../models/report_model.dart';
import '../../services/report_pdf_service.dart';
import '../../data/remote/sync_service.dart';
import '../../data/remote/vetra_api_service.dart';

class SessionRepository {
  final SQLiteService _db = SQLiteService();
  final SyncService _syncService = SyncService(
    sqliteService: SQLiteService(),
    apiService: VetraApiService(),
  );

  /// Creates a new session, saves images to app storage, and records them in SQLite.
  /// 
  /// [captures] is a list of maps containing 'title' (e.g., 'Side View') and 'file' (path string).
  Future<int> createSessionWithImages(String animalType, List<Map<String, dynamic>> captures) async {
    final now = DateTime.now().toIso8601String();

    // 1. Create Session Record
    final sessionModel = SessionModel(
      animalType: animalType,
      createdAt: now,
    );
    final sessionId = await _db.createSession(sessionModel);

    // Sync Session (Fire-and-forget)
    _syncService.syncSession(SessionModel(
      id: sessionId,
      animalType: sessionModel.animalType,
      createdAt: sessionModel.createdAt,
    ));

    // 2. Prepare Storage Directory
    final appDir = await getApplicationDocumentsDirectory();
    final imagesDir = Directory(p.join(appDir.path, 'captured_images'));
    if (!await imagesDir.exists()) {
      await imagesDir.create(recursive: true);
    }

    // 3. Process and Save Each Image
    for (var capture in captures) {
      final String? originalPath = capture['file'];
      if (originalPath != null) {
        final viewType = (capture['title'] as String).toLowerCase().replaceAll(' ', '_');
        
        // Copy file to permanent storage
        final file = File(originalPath);
        final fileName = 'session_${sessionId}_${viewType}_${DateTime.now().millisecondsSinceEpoch}${p.extension(originalPath)}';
        final savedFile = await file.copy(p.join(imagesDir.path, fileName));

        // Save metadata to DB
        // Save metadata to DB
        final imageModel = CapturedImageModel(
          sessionId: sessionId,
          viewType: viewType,
          filePath: savedFile.path,
          capturedAt: now,
        );
        final imageId = await _db.saveCapturedImage(imageModel);

        // Sync Image (Fire-and-forget)
        _syncService.syncCapturedImage(CapturedImageModel(
          id: imageId,
          sessionId: imageModel.sessionId,
          viewType: imageModel.viewType,
          filePath: imageModel.filePath,
          capturedAt: imageModel.capturedAt,
        ));
      }
    }

    return sessionId;
  }

  /// Generates a PDF report, saves it, and records the entry in SQLite.
  Future<String> generateAndSaveReport(int sessionId, Map<String, dynamic> reportData) async {
    // 1. Generate PDF
    final path = await ReportPdfService.generateAndSavePDF(reportData);

    // 2. Add path to report data for future retrieval (if re-generating or opening)
    final reportDataToSave = Map<String, dynamic>.from(reportData);
    reportDataToSave['filePath'] = path;

    // 3. Save Record to DB
    // 3. Save Record to DB
    final reportModel = ReportModel(
      sessionId: sessionId,
      reportJson: jsonEncode(reportDataToSave),
      exported: 1, // Mark as exported since we generated the PDF
      createdAt: DateTime.now().toIso8601String(),
    );
    final reportId = await _db.saveReport(reportModel);

    // Sync Report (Fire-and-forget)
    _syncService.syncReport(ReportModel(
      id: reportId,
      sessionId: reportModel.sessionId,
      reportJson: reportModel.reportJson,
      exported: reportModel.exported,
      createdAt: reportModel.createdAt,
    ));

    return path;
  }
}
