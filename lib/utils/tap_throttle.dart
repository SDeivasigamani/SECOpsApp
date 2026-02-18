class TapThrottle {
  static int _lastTapTimestamp = 0;
  static const int _throttleDuration = 500; // milliseconds

  static bool canTap() {
    final int now = DateTime.now().millisecondsSinceEpoch;
    if (now - _lastTapTimestamp < _throttleDuration) {
      return false;
    }
    _lastTapTimestamp = now;
    return true;
  }
}
