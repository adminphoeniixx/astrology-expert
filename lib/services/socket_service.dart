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

  bool _connected = false;
  bool get isConnected => _connected;

  StreamSubscription? _connSub;
  StreamSubscription? _allSub;

  /// Emits integer timer values (seconds)
  StreamController<int>? _timerController = StreamController<int>.broadcast();

  Stream<int> get timerStream => _timerController!.stream;

  Timer? _runningTimer;
  int _elapsed = 0; // Local timer counter

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

    final options = PusherChannelsOptions.fromHost(
      scheme: useTLS ? 'wss' : 'ws',
      host: host,
      port: port,
      key: appKey,
    );

    _client = PusherChannelsClient.websocket(
      options: options,
      connectionErrorHandler: (error, stack, reconnect) async {
        print("⚠️ Socket error: $error, trying reconnect...");
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
      print("✅ Socket connected.");
    });

    _allSub = _channel!.bindToAll().listen((event) {
      print("[EVENT] ${event.channelName} : ${event.data}");

      try {
        final raw = event.data;
        final data = raw is String ? jsonDecode(raw) : raw;

        if (data is Map && data.containsKey('status')) {
          final status = data['status']; // "start" or "end"
          print("📌 STATUS RECEIVED: $status");

          if (status == "start") {
            _startTimer();
          } else if (status == "stop") {
            _stopTimer();
          }
        }
      } catch (e) {
        print("❌ Error: $e");
      }
    });

    _client!.connect();
  }

  /// -------------------------
  /// TIMER START METHOD
  /// -------------------------

  void _startTimer() {
    print("▶️ Timer STARTED");

    _runningTimer?.cancel(); // Cancel old timer
    _elapsed = 0;

    _runningTimer = Timer.periodic(Duration(seconds: 1), (timer) {
      _elapsed++;
      _safeAddToTimerStream(_elapsed);
    });
  }

  /// -------------------------
  /// TIMER STOP METHOD
  /// -------------------------
  void _stopTimer() {
    print("⏹️ Timer STOPPED");

    _runningTimer?.cancel();
    _runningTimer = null;

    // _elapsed = 0;
    // _safeAddToTimerStream(0);
  }

  /// Adds safely into stream
  void _safeAddToTimerStream(int value) {
    if (_timerController != null && !_timerController!.isClosed) {
      _timerController!.add(value);
    }
  }

  /// disconnect socket
  void disconnect() {
    _connSub?.cancel();
    _allSub?.cancel();

    _runningTimer?.cancel();
    _runningTimer = null;

    _client?.disconnect();
    _connected = false;
  }

  /// dispose everything
  void dispose() {
    disconnect();
    _timerController?.close();
    print("🗑️ SocketService disposed.");
  }
}

// import 'dart:async';
// import 'dart:convert';
// import 'package:dart_pusher_channels/dart_pusher_channels.dart';

// class SocketService {
//   // Singleton
//   static final SocketService _instance = SocketService._internal();
//   factory SocketService() => _instance;
//   SocketService._internal();

//   PusherChannelsClient? _client;
//   PrivateChannel? _channel;

//   bool _connected = false;

//   StreamSubscription? _connSub;
//   StreamSubscription? _allSub;

//   Timer? _runningTimer;
//   int _elapsed = 0;

//   /// CALLBACK instead of Stream
//   void Function(int seconds)? onTimerUpdate;

//   Future<void> connect({
//     required String host,
//     required int port,
//     required bool useTLS,
//     required String appKey,
//     required Uri authEndpoint,
//     required String roomId,
//     required String bearerToken,
//     void Function(int seconds)? onTimer,
//   }) async {
//     if (_connected) {
//       print("⚠ Already connected");
//       return;
//     }

//     /// Save UI callback
//     this.onTimerUpdate = onTimer;

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
//         final data = raw is String ? jsonDecode(raw) : raw;

//         if (data is Map && data.containsKey('status')) {
//           final status = data['status'];

//           if (status == "start") {
//             _startTimer();
//           } else if (status == "stop") {
//             _stopTimer();
//           }
//         }
//       } catch (e) {}
//     });

//     _client!.connect();
//   }

//   /// TIMER START
//   void _startTimer() {
//     _runningTimer?.cancel();
//     _elapsed = 0;

//     _runningTimer = Timer.periodic(Duration(seconds: 1), (timer) {
//       _elapsed++;

//       /// Send value to UI via callback
//       if (onTimerUpdate != null) {
//         onTimerUpdate!(_elapsed);
//       }
//     });
//   }

//   /// TIMER STOP
//   void _stopTimer() {
//     _runningTimer?.cancel();
//     _runningTimer = null;

//     /// Timer stop par current time send nahi karenge
//     /// Because you said: "stop pe 0 nahi chahiye"
//   }

//   void disconnect() {
//     _connSub?.cancel();
//     _allSub?.cancel();
//     _runningTimer?.cancel();
//     _client?.disconnect();
//     _connected = false;
//   }

//   void dispose() {
//     disconnect();
//     onTimerUpdate = null;
//   }
// }
