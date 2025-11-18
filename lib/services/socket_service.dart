// import 'dart:async';
// import 'dart:convert';
// import 'package:dart_pusher_channels/dart_pusher_channels.dart';

// class SocketService {
//   // Singleton Setup
//   static final SocketService _instance = SocketService._internal();
//   factory SocketService() => _instance;
//   SocketService._internal();

//   PusherChannelsClient? _client;
//   PrivateChannel? _channel;

//   bool _connected = false;
//   bool get isConnected => _connected;

//   StreamSubscription? _connSub;
//   StreamSubscription? _allSub;

//   /// Emits integer timer values (seconds)
//   StreamController<int>? _timerController = StreamController<int>.broadcast();

//   Stream<int> get timerStream => _timerController!.stream;

//   Timer? _runningTimer;
//   int _elapsed = 0; // Local timer counter

//   Future<void> connect({
//     required String host,
//     required int port,
//     required bool useTLS,
//     required String appKey,
//     required Uri authEndpoint,
//     required String roomId,
//     required String bearerToken,
//   }) async {
//     if (_connected) {
//       print("⚠️ Already connected, skipping");
//       return;
//     }

//     // Rebuild timer stream if needed
//     if (_timerController == null || _timerController!.isClosed) {
//       _timerController = StreamController<int>.broadcast();
//       print("🔄 Timer stream reinitialized.");
//     }

//     final options = PusherChannelsOptions.fromHost(
//       scheme: useTLS ? 'wss' : 'ws',
//       host: host,
//       port: port,
//       key: appKey,
//     );

//     _client = PusherChannelsClient.websocket(
//       options: options,
//       connectionErrorHandler: (error, stack, reconnect) async {
//         print("⚠️ Socket error: $error, trying reconnect...");
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
//       print("✅ Socket connected.");
//     });

//     _allSub = _channel!.bindToAll().listen((event) {
//       print("[EVENT] ${event.channelName} : ${event.data}");

//       try {
//         final raw = event.data;
//         final data = raw is String ? jsonDecode(raw) : raw;

//         if (data is Map && data.containsKey('status')) {
//           final status = data['status']; // "start" or "end"
//           print("📌 STATUS RECEIVED: $status");

//           if (status == "start") {
//             _startTimer();
//           } else if (status == "stop") {
//             _stopTimer();
//           }
//         }
//       } catch (e) {
//         print("❌ Error: $e");
//       }
//     });

//     _client!.connect();
//   }

//   /// -------------------------
//   /// TIMER START METHOD
//   /// -------------------------

//   void _startTimer() {
//     print("▶️ Timer STARTED");

//     _runningTimer?.cancel(); // Cancel old timer
//     _elapsed = 0;

//     _runningTimer = Timer.periodic(Duration(seconds: 1), (timer) {
//       _elapsed++;
//       _safeAddToTimerStream(_elapsed);
//     });
//   }

//   /// -------------------------
//   /// TIMER STOP METHOD
//   /// -------------------------
//   void _stopTimer() {
//     print("⏹️ Timer STOPPED");

//     _runningTimer?.cancel();
//     _runningTimer = null;

//     // _elapsed = 0;
//     // _safeAddToTimerStream(0);
//   }

//   /// Adds safely into stream
//   void _safeAddToTimerStream(int value) {
//     if (_timerController != null && !_timerController!.isClosed) {
//       _timerController!.add(value);
//     }
//   }

//   /// disconnect socket
//   void disconnect() {
//     _connSub?.cancel();
//     _allSub?.cancel();

//     _runningTimer?.cancel();
//     _runningTimer = null;

//     _client?.disconnect();
//     _connected = false;
//   }

//   /// dispose everything
//   void dispose() {
//     disconnect();
//     _timerController?.close();
//     print("🗑️ SocketService disposed.");
//   }
// }

import 'dart:async';
import 'dart:convert';
import 'package:dart_pusher_channels/dart_pusher_channels.dart';
import 'package:flutter/widgets.dart';

class SocketService with WidgetsBindingObserver {
  static final SocketService _instance = SocketService._internal();
  factory SocketService() => _instance;

  SocketService._internal() {
    WidgetsBinding.instance.addObserver(this);
  }

  PusherChannelsClient? _client;
  PrivateChannel? _channel;

  bool _connected = false;
  bool get isConnected => _connected;

  StreamSubscription? _connSub;
  StreamSubscription? _allSub;

  StreamController<int> _timerController = StreamController<int>.broadcast();
  Stream<int> get timerStream => _timerController.stream;

  Timer? _runningTimer;

  DateTime? _startTimestamp; // REAL TIME BASE START
  bool _isTimerRunning = false;

  int _latestElapsed = 0;

  // ----------------------------------
  //  LIFECYCLE LISTENER
  // ----------------------------------
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (_isTimerRunning && _startTimestamp != null) {
      if (state == AppLifecycleState.resumed) {
        // App resume → recalc time
        final diff = DateTime.now().difference(_startTimestamp!).inSeconds;
        _latestElapsed = diff;
        _timerController.add(diff);
      }
    }
  }

  // ----------------------------------
  //  CONNECT SOCKET
  // ----------------------------------

  Future<void> connect({
    required String host,
    required int port,
    required bool useTLS,
    required String appKey,
    required Uri authEndpoint,
    required String roomId,
    required String bearerToken,
  }) async {
    if (_connected) return;

    final options = PusherChannelsOptions.fromHost(
      scheme: useTLS ? 'wss' : 'ws',
      host: host,
      port: port,
      key: appKey,
    );

    _client = PusherChannelsClient.websocket(
      options: options,
      connectionErrorHandler: (error, stack, reconnect) async {
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

    _connSub = _client!.onConnectionEstablished.listen((_) {
      _channel!.subscribeIfNotUnsubscribed();
      _connected = true;
    });

    _allSub = _channel!.bindToAll().listen((event) {
      try {
        final raw = event.data;
        final json = raw is String ? jsonDecode(raw) : raw;

        if (json is Map && json.containsKey('status')) {
          if (json['status'] == "start") {
            _startTimer();
          } else if (json['status'] == "stop") {
            _stopTimer();
          }
        }
      } catch (_) {}
    });

    _client!.connect();
  }

  // ----------------------------------
  //  START TIMER  (BACKGROUND SAFE)
  // ----------------------------------

  void _startTimer() {
    _isTimerRunning = true;

    _startTimestamp = DateTime.now();
    _latestElapsed = 0;

    _runningTimer?.cancel();

    _runningTimer = Timer.periodic(Duration(seconds: 1), (_) {
      if (_startTimestamp != null) {
        _latestElapsed = DateTime.now().difference(_startTimestamp!).inSeconds;
        _timerController.add(_latestElapsed);
      }
    });
  }

  // ----------------------------------
  //  STOP TIMER
  // ----------------------------------

  void _stopTimer() {
    _isTimerRunning = false;

    _runningTimer?.cancel();
    _runningTimer = null;

    _startTimestamp = null;
    _latestElapsed = 0;
  }

  // ----------------------------------
  //  DISCONNECT
  // ----------------------------------

  void disconnect() {
    _connSub?.cancel();
    _allSub?.cancel();
    _runningTimer?.cancel();

    _client?.disconnect();
    _connected = false;
  }

  // ----------------------------------
  //  DISPOSE
  // ----------------------------------

  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    disconnect();
    _timerController.close();
  }
}
