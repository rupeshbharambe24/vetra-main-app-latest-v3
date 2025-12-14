class AnalysisResultModel {
  final int? id; // INTEGER PRIMARY KEY AUTOINCREMENT
  final int sessionId; // session_id INTEGER
  final String analysisJson; // analysis_json TEXT
  final double confidence; // confidence REAL
  final String generatedAt; // generated_at TEXT

  AnalysisResultModel({
    this.id,
    required this.sessionId,
    required this.analysisJson,
    required this.confidence,
    required this.generatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'session_id': sessionId,
      'analysis_json': analysisJson,
      'confidence': confidence,
      'generated_at': generatedAt,
    };
  }

  factory AnalysisResultModel.fromMap(Map<String, dynamic> map) {
    return AnalysisResultModel(
      id: map['id'],
      sessionId: map['session_id'],
      analysisJson: map['analysis_json'],
      confidence: map['confidence'],
      generatedAt: map['generated_at'],
    );
  }
}
