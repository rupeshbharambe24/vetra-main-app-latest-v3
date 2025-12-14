class CapturedImageModel {
  final int? id; // INTEGER PRIMARY KEY AUTOINCREMENT
  final int sessionId; // session_id INTEGER
  final String viewType; // view_type TEXT
  final String filePath; // file_path TEXT
  final String capturedAt; // captured_at TEXT

  CapturedImageModel({
    this.id,
    required this.sessionId,
    required this.viewType,
    required this.filePath,
    required this.capturedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'session_id': sessionId,
      'view_type': viewType,
      'file_path': filePath,
      'captured_at': capturedAt,
    };
  }

  factory CapturedImageModel.fromMap(Map<String, dynamic> map) {
    return CapturedImageModel(
      id: map['id'],
      sessionId: map['session_id'],
      viewType: map['view_type'],
      filePath: map['file_path'],
      capturedAt: map['captured_at'],
    );
  }
}
