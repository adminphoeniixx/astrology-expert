import 'dart:async';
import 'dart:convert';
import 'package:dart_pusher_channels/dart_pusher_channels.dart';

class SocketService {
  // Singleton Setup
  static final SocketService _instance = SocketService._internal();
  factory SocketService() => _instance;
  SocketService._internal();

  PusherChannelsClient? _client;
  PrivateChannel? _channel;
  DateTime? _startTime;
  bool _connected = false;
  bool get isConnected => _connected;

  StreamSubscription? _connSub;
  StreamSubscription? _allSub;

  /// Emits integer timer values (seconds)
  StreamController<int>? _timerController = StreamController<int>.broadcast();
  Stream<int> get timerStream => _timerController!.stream;

  Timer? _runningTimer;
  int _elapsed = 0; // Local timer counter

  // ---------------------------------------------------------------------------
  // CONNECT
  // ---------------------------------------------------------------------------
  Future<void> connect({
    required String host,
    required int port,
    required bool useTLS,
    required String appKey,
    required Uri authEndpoint,
    required String roomId,
    required String bearerToken,
  }) async {
    if (_connected) {
      print("⚠️ Already connected, skipping");
      return;
    }

    // Rebuild timer stream if needed
    if (_timerController == null || _timerController!.isClosed) {
      _timerController = StreamController<int>.broadcast();
      print("🔄 Timer stream reinitialized.");
    }

    print("🔌 Initializing socket…");

    final options = PusherChannelsOptions.fromHost(
      scheme: useTLS ? 'wss' : 'ws',
      host: host,
      port: port,
      key: appKey,
    );

    _client = PusherChannelsClient.websocket(
      options: options,
      connectionErrorHandler: (error, stack, reconnect) async {
        print("⚠️ Socket error: $error → reconnecting…");
        reconnect();
      },
    );

    _channel = _client!.privateChannel(
      "private-$roomId",
      authorizationDelegate:
          EndpointAuthorizableChannelTokenAuthorizationDelegate.forPrivateChannel(
            authorizationEndpoint: authEndpoint,
            headers: {
              'Authorization': 'Bearer $bearerToken',
              'Content-Type': 'application/json',
            },
          ),
    );

    // Connection established
    _connSub = _client!.onConnectionEstablished.listen((_) {
      _channel!.subscribeIfNotUnsubscribed();
      _connected = true;
      print("✅ Socket connected.");
    });

    // LISTEN to all events
    _allSub = _channel!.bindToAll().listen((event) {
      print("🟣 [EVENT]  => ${event.data}");

      final raw = event.data;

      // FIX 1: ignore null events (common for pusher_internal events)
      if (raw == null) {
        print("⚠️ Null event received → ignoring.");
        return;
      }

      // FIX 2: decode safely
      dynamic data;
      try {
        data = raw is String ? jsonDecode(raw) : raw;
      } catch (e) {
        print("❌ JSON Decode Failed: $e");
        return;
      }

      if (data is! Map) {
        print("⚠️ Non-map data ignored.");
        return;
      }

      // Check for "status" key from timer events
      if (data.containsKey('status')) {
        final status = data['status'];
        print("📌 TIMER STATUS: $status");

        if (status == "start") {
          _startTimer();
        } else if (status == "stop") {
          _stopTimer();
        }
      }
    });

    _client!.connect();
  }

  // ---------------------------------------------------------------------------
  // TIMER START
  // ---------------------------------------------------------------------------
  // void _startTimer() {
  //   print("▶️ Timer STARTED");

  //   _runningTimer?.cancel(); // Cancel old timer
  //   _elapsed = 0;

  //   _runningTimer = Timer.periodic(Duration(seconds: 1), (timer) {
  //     _elapsed++;
  //     _safeAddToTimerStream(_elapsed);
  //   });
  // }

  void _startTimer() {
    print("▶️ Timer STARTED");

    _runningTimer?.cancel();
    _elapsed = 0;

    _startTime = DateTime.now(); // save actual start time

    _runningTimer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (_startTime == null) return;

      final now = DateTime.now();
      final diff = now.difference(_startTime!).inSeconds;

      _elapsed = diff;
      _safeAddToTimerStream(_elapsed);
    });
  }

  // ---------------------------------------------------------------------------
  // TIMER STOP
  // ---------------------------------------------------------------------------
  void _stopTimer() {
    print("⏹️ Timer STOPPED");
    _runningTimer?.cancel();
    _runningTimer = null;
    _startTime = null;
  }

  // Safe stream add
  void _safeAddToTimerStream(int value) {
    if (_timerController != null && !_timerController!.isClosed) {
      _timerController!.add(value);
    }
  }

  // ---------------------------------------------------------------------------
  // DISCONNECT
  // ---------------------------------------------------------------------------
  void disconnect() {
    print("🔌 Disconnecting socket…");

    _connSub?.cancel();
    _allSub?.cancel();

    _runningTimer?.cancel();
    _runningTimer = null;

    _client?.disconnect();
    _connected = false;

    print("🛑 Socket disconnected.");
  }

  // ---------------------------------------------------------------------------
  // DISPOSE
  // ---------------------------------------------------------------------------
  void dispose() {
    disconnect();
    _timerController?.close();
    print("🗑️ SocketService disposed.");
  }
}
