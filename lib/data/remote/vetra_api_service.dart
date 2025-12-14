import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../database/models/session_model.dart';
import '../../database/models/captured_image_model.dart';
import '../../database/models/analysis_result_model.dart';
import '../../database/models/report_model.dart';

class VetraApiService {
  // Configurable base URL - default to localhost based on prompt instructions
  // For Android Emulator, localhost is 10.0.2.2. For iOS, it's 127.0.0.1.
  // Using localhost by default as requested.
  final String baseUrl;
  final http.Client _client;

  VetraApiService({
    this.baseUrl = 'http://localhost:3000', // Example default, should be configured
    http.Client? client,
  }) : _client = client ?? http.Client();

  // Helper for headers
  Map<String, String> get _headers => {
        'Content-Type': 'application/json',
      };

  // Sync Session
  Future<void> syncSession(SessionModel session) async {
    final url = Uri.parse('$baseUrl/api/sessions');
    final response = await _client.post(
      url,
      headers: _headers,
      body: jsonEncode(session.toMap()),
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('Failed to sync session: ${response.statusCode} ${response.body}');
    }
  }

  // Sync Captured Image Metadata
  Future<void> syncCapturedImage(CapturedImageModel image) async {
    final url = Uri.parse('$baseUrl/api/captured-images');
    final response = await _client.post(
      url,
      headers: _headers,
      body: jsonEncode(image.toMap()),
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('Failed to sync captured image: ${response.statusCode} ${response.body}');
    }
  }

  // Sync Analysis Result
  Future<void> syncAnalysisResult(AnalysisResultModel result) async {
    final url = Uri.parse('$baseUrl/api/analysis-results');
    final response = await _client.post(
      url,
      headers: _headers,
      body: jsonEncode(result.toMap()),
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('Failed to sync analysis result: ${response.statusCode} ${response.body}');
    }
  }

  // Sync Report
  Future<void> syncReport(ReportModel report) async {
    final url = Uri.parse('$baseUrl/api/reports');
    final response = await _client.post(
      url,
      headers: _headers,
      body: jsonEncode(report.toMap()),
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('Failed to sync report: ${response.statusCode} ${response.body}');
    }
  }
}
