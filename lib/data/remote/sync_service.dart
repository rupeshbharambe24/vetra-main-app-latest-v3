import 'package:flutter/foundation.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../../database/sqlite_service.dart';
import '../../database/models/session_model.dart';
import '../../database/models/captured_image_model.dart';
import '../../database/models/analysis_result_model.dart';
import '../../database/models/report_model.dart';
import 'vetra_api_service.dart';

// Riverpod Provider
final syncServiceProvider = Provider<SyncService>((ref) {
  return SyncService(
    sqliteService: SQLiteService(),
    apiService: VetraApiService(),
  );
});

class SyncService {
  final SQLiteService sqliteService;
  final VetraApiService apiService;

  SyncService({
    required this.sqliteService,
    required this.apiService,
  });

  /// Syncs a session to the backend.
  /// Fails silently on error to prevent blocking local flow.
  Future<void> syncSession(SessionModel session) async {
    try {
      await apiService.syncSession(session);
      if (kDebugMode) {
        print('✅ Synced Session: ${session.id}');
      }
    } catch (e) {
      // Create a silent failure: Log locally but DO NOT throw
      if (kDebugMode) {
        print('⚠️ Sync Failed (Session): $e');
      }
    }
  }

  /// Syncs a captured image metadata to the backend.
  Future<void> syncCapturedImage(CapturedImageModel image) async {
    try {
      await apiService.syncCapturedImage(image);
      if (kDebugMode) {
        print('✅ Synced Image: ${image.id}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('⚠️ Sync Failed (Image): $e');
      }
    }
  }

  /// Syncs analysis result to the backend.
  Future<void> syncAnalysisResult(AnalysisResultModel result) async {
    try {
      await apiService.syncAnalysisResult(result);
      if (kDebugMode) {
        print('✅ Synced Analysis Result: ${result.id}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('⚠️ Sync Failed (Analysis): $e');
      }
    }
  }

  /// Syncs a report to the backend.
  Future<void> syncReport(ReportModel report) async {
    try {
      await apiService.syncReport(report);
      if (kDebugMode) {
        print('✅ Synced Report: ${report.id}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('⚠️ Sync Failed (Report): $e');
      }
    }
  }
}
