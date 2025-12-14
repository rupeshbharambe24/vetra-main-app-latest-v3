class SessionModel {
  final int? id; // INTEGER PRIMARY KEY AUTOINCREMENT
  final String animalType; // animal_type TEXT
  final String createdAt; // created_at TEXT

  SessionModel({
    this.id,
    required this.animalType,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'animal_type': animalType,
      'created_at': createdAt,
    };
  }

  factory SessionModel.fromMap(Map<String, dynamic> map) {
    return SessionModel(
      id: map['id'],
      animalType: map['animal_type'],
      createdAt: map['created_at'],
    );
  }
}
