// small mock provider helpers (pure Dart - no package dependency)
class MockDataProvider {
  static List<Map<String, String>> sampleRecords() {
    return List.generate(6, (i) => {
      'id': 'TAG-${100 + i}',
      'date': '2025-12-${(i + 1).toString().padLeft(2, '0')}',
      'notes': 'Mock record ${i + 1}',
    });
  }

  static List<Map<String, String>> sampleReports() {
    return List.generate(5, (i) => {
      'title': 'Report #${i + 1}',
      'date': '2025-11-${(10 + i).toString().padLeft(2, '0')}',
    });
  }
}
