class ReportModel {
  final int? id; // INTEGER PRIMARY KEY AUTOINCREMENT
  final int sessionId; // session_id INTEGER
  final String reportJson; // report_json TEXT
  final int exported; // exported INTEGER DEFAULT 0
  final String createdAt; // created_at TEXT

  ReportModel({
    this.id,
    required this.sessionId,
    required this.reportJson,
    this.exported = 0,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'session_id': sessionId,
      'report_json': reportJson,
      'exported': exported,
      'created_at': createdAt,
    };
  }

  factory ReportModel.fromMap(Map<String, dynamic> map) {
    return ReportModel(
      id: map['id'],
      sessionId: map['session_id'],
      reportJson: map['report_json'],
      exported: map['exported'],
      createdAt: map['created_at'],
    );
  }
}
