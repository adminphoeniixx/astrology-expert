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

// import 'dart:async';
// import 'dart:convert';
// import 'package:dart_pusher_channels/dart_pusher_channels.dart';
// import 'package:flutter/widgets.dart';

// class SocketService with WidgetsBindingObserver {
//   static final SocketService _instance = SocketService._internal();
//   factory SocketService() => _instance;

//   SocketService._internal() {
//     WidgetsBinding.instance.addObserver(this);
//   }

//   PusherChannelsClient? _client;
//   PrivateChannel? _channel;

//   bool _connected = false;
//   bool get isConnected => _connected;

//   StreamSubscription? _connSub;
//   StreamSubscription? _allSub;

//   final StreamController<int> _timerController =
//       StreamController<int>.broadcast();
//   Stream<int> get timerStream => _timerController.stream;

//   Timer? _runningTimer;

//   DateTime? _startTimestamp; // REAL TIME BASE START
//   bool _isTimerRunning = false;

//   int _latestElapsed = 0;

//   // ----------------------------------
//   //  LIFECYCLE LISTENER
//   // ----------------------------------
//   @override
//   void didChangeAppLifecycleState(AppLifecycleState state) {
//     if (_isTimerRunning && _startTimestamp != null) {
//       if (state == AppLifecycleState.resumed) {
//         // App resume → recalc time
//         final diff = DateTime.now().difference(_startTimestamp!).inSeconds;
//         _latestElapsed = diff;
//         _timerController.add(diff);
//       }
//     }
//   }

//   // ----------------------------------
//   //  CONNECT SOCKET
//   // ----------------------------------

//   Future<void> connect({
//     required String host,
//     required int port,
//     required bool useTLS,
//     required String appKey,
//     required Uri authEndpoint,
//     required String roomId,
//     required String bearerToken,
//   }) async {
//     if (_connected) return;

//     final options = PusherChannelsOptions.fromHost(
//       scheme: useTLS ? 'wss' : 'ws',
//       host: host,
//       port: port,
//       key: appKey,
//     );

//     _client = PusherChannelsClient.websocket(
//       options: options,
//       connectionErrorHandler: (error, stack, reconnect) async {
//         reconnect();
//       },
//     );

//     _channel = _client!.privateChannel(
//       "private-$roomId",
//       authorizationDelegate:
//           EndpointAuthorizableChannelTokenAuthorizationDelegate.forPrivateChannel(
//             authorizationEndpoint: authEndpoint,
//             headers: {
//               'Authorization': 'Bearer $bearerToken',
//               'Content-Type': 'application/json',
//             },
//           ),
//     );

//     _connSub = _client!.onConnectionEstablished.listen((_) {
//       _channel!.subscribeIfNotUnsubscribed();
//       _connected = true;
//     });

//     _allSub = _channel!.bindToAll().listen((event) {
//       try {
//         final raw = event.data;
//         final json = raw is String ? jsonDecode(raw) : raw;

//         if (json is Map && json.containsKey('status')) {
//           if (json['status'] == "start") {
//             _startTimer();
//           } else if (json['status'] == "stop") {
//             _stopTimer();
//           }
//         }
//       } catch (_) {}
//     });

//     _client!.connect();
//   }

//   // ----------------------------------
//   //  START TIMER  (BACKGROUND SAFE)
//   // ----------------------------------

//   void _startTimer() {
//     _isTimerRunning = true;

//     _startTimestamp = DateTime.now();
//     _latestElapsed = 0;

//     _runningTimer?.cancel();

//     _runningTimer = Timer.periodic(Duration(seconds: 1), (_) {
//       if (_startTimestamp != null) {
//         _latestElapsed = DateTime.now().difference(_startTimestamp!).inSeconds;
//         _timerController.add(_latestElapsed);
//       }
//     });
//   }

//   void _stopTimer() {
//     _isTimerRunning = false;

//     _runningTimer?.cancel();
//     _runningTimer = null;

//     _startTimestamp = null;
//     _latestElapsed = 0;
//   }

//   void disconnect() {
//     _connSub?.cancel();
//     _allSub?.cancel();
//     _runningTimer?.cancel();

//     _client?.disconnect();
//     _connected = false;
//   }

//   void dispose() {
//     WidgetsBinding.instance.removeObserver(this);
//     disconnect();
//     _timerController.close();
//   }
// }

// import 'dart:async';
// import 'dart:convert';
// import 'package:dart_pusher_channels/dart_pusher_channels.dart';
// import 'package:flutter/widgets.dart';

// class SocketService with WidgetsBindingObserver {
//   static final SocketService _instance = SocketService._internal();
//   factory SocketService() => _instance;

//   SocketService._internal() {
//     _initController();
//     WidgetsBinding.instance.addObserver(this);
//   }

//   PusherChannelsClient? _client;
//   PrivateChannel? _channel;

//   bool _connected = false;
//   bool get isConnected => _connected;

//   StreamSubscription? _connSub;
//   StreamSubscription? _allSub;

//   StreamController<int>? _timerController;
//   Stream<int> get timerStream =>
//       _timerController?.stream ?? Stream.value(0); // ⭐ SAFE STREAM RETURN

//   Timer? _runningTimer;

//   DateTime? _startTimestamp;
//   bool _isTimerRunning = false;

//   int _latestElapsed = 0;

//   // ⭐ NULL-SAFE INITIALIZATION
//   void _initController() {
//     // If controller exists and not closed → close it
//     if (_timerController != null && !_timerController!.isClosed) {
//       _timerController!.close();
//     }

//     // Create new broadcast controller
//     _timerController = StreamController<int>.broadcast();

//     // ⭐ Emit 0 initially
//     _timerController!.add(0);
//   }

//   @override
//   void didChangeAppLifecycleState(AppLifecycleState state) {
//     if (_isTimerRunning && _startTimestamp != null) {
//       if (state == AppLifecycleState.resumed) {
//         final diff = DateTime.now().difference(_startTimestamp!).inSeconds;
//         _latestElapsed = diff;

//         if (_timerController != null && !_timerController!.isClosed) {
//           _timerController!.add(diff);
//         }
//       }
//     }
//   }

//   Future<void> connect({
//     required String host,
//     required int port,
//     required bool useTLS,
//     required String appKey,
//     required Uri authEndpoint,
//     required String roomId,
//     required String bearerToken,
//   }) async {
//     if (_connected) return;

//     final options = PusherChannelsOptions.fromHost(
//       scheme: useTLS ? 'wss' : 'ws',
//       host: host,
//       port: port,
//       key: appKey,
//     );

//     _client = PusherChannelsClient.websocket(
//       options: options,
//       connectionErrorHandler: (error, stack, reconnect) async {
//         reconnect();
//       },
//     );

//     _channel = _client!.privateChannel(
//       "private-$roomId",
//       authorizationDelegate:
//           EndpointAuthorizableChannelTokenAuthorizationDelegate.forPrivateChannel(
//             authorizationEndpoint: authEndpoint,
//             headers: {
//               'Authorization': 'Bearer $bearerToken',
//               'Content-Type': 'application/json',
//             },
//           ),
//     );

//     _connSub = _client!.onConnectionEstablished.listen((_) {
//       _channel!.subscribeIfNotUnsubscribed();
//       _connected = true;
//     });

//     _allSub = _channel!.bindToAll().listen((event) {
//       try {
//         final raw = event.data;
//         final json = raw is String ? jsonDecode(raw) : raw;

//         if (json is Map && json.containsKey('status')) {
//           if (json['status'] == "start") {
//             _startTimer();
//           } else if (json['status'] == "stop") {
//             _stopTimer();
//           }
//         }
//       } catch (_) {}
//     });

//     _client!.connect();
//   }

//   void _startTimer() {
//     if (_isTimerRunning) {
//       _runningTimer?.cancel();
//     }

//     if (_timerController == null || _timerController!.isClosed) {
//       _initController();
//     }

//     _isTimerRunning = true;
//     _startTimestamp = DateTime.now();
//     _latestElapsed = 0;

//     _runningTimer = Timer.periodic(Duration(seconds: 1), (_) {
//       if (_isTimerRunning &&
//           _startTimestamp != null &&
//           _timerController != null &&
//           !_timerController!.isClosed) {
//         _latestElapsed = DateTime.now().difference(_startTimestamp!).inSeconds;

//         try {
//           _timerController!.add(_latestElapsed);
//         } catch (e) {
//           _runningTimer?.cancel();
//           _isTimerRunning = false;
//         }
//       }
//     });
//   }

//   void _stopTimer() {
//     _isTimerRunning = false;
//     _runningTimer?.cancel();
//     _runningTimer = null;
//     _startTimestamp = null;
//     _latestElapsed = 0;

//     // ⭐ Emit "0" after stop
//     if (_timerController != null && !_timerController!.isClosed) {
//       _timerController!.add(0);
//     }
//   }

//   void disconnect() {
//     _connSub?.cancel();
//     _allSub?.cancel();
//     _runningTimer?.cancel();

//     _client?.disconnect();
//     _connected = false;
//   }

//   void dispose() {
//     WidgetsBinding.instance.removeObserver(this);
//     disconnect();

//     if (_timerController != null && !_timerController!.isClosed) {
//       _timerController!.close();
//     }
//   }

//   // Reset for reuse
//   void reset() {
//     _stopTimer();
//     _initController();
//   }
// }
