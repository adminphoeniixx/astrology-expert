import 'dart:async';

class SessionRefreshService {
  SessionRefreshService._();

  static final StreamController<void> _controller =
      StreamController<void>.broadcast();

  static Stream<void> get stream => _controller.stream;

  static void refreshSessions() {
    if (!_controller.isClosed) {
      _controller.add(null);
    }
  }
}
