// small placeholder to simulate network availability
class NetworkStatusProvider {
  bool _online = false;
  bool get online => _online;

  void setOnline(bool v) {
    _online = v;
  }
}
