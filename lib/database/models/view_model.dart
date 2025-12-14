class ViewModel {
  final int? id;
  final int sessionId; // Foreign Key to SessionModel
  final String viewName;
  final String imagePath;
  final DateTime createdAt;

  ViewModel({
    this.id,
    required this.sessionId,
    required this.viewName,
    required this.imagePath,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'sessionId': sessionId,
      'viewName': viewName,
      'imagePath': imagePath,
      'createdAt': createdAt.millisecondsSinceEpoch,
    };
  }

  factory ViewModel.fromMap(Map<String, dynamic> map) {
    return ViewModel(
      id: map['id'],
      sessionId: map['sessionId'],
      viewName: map['viewName'],
      imagePath: map['imagePath'],
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt']),
    );
  }
}
