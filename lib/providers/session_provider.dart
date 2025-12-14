class SessionProvider {
  // Very small in-memory session representation - expand later
  String currentTag = 'TAG-001';
  String species = 'Cow';

  void updateTag(String t) => currentTag = t;
  void updateSpecies(String s) => species = s;
}
