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
 
  StreamSubscription? _connSub;
  StreamSubscription? _allSub;
 
  /// Emits integer timer values (seconds)
  final _timerController = StreamController<int>.broadcast();
  Stream<int> get timerStream => _timerController.stream;
 
  bool get isConnected => _connected;
 
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
      print("⚠️ Already connected, skipping re-init");
      return;
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
        print("⚠️ Socket error: $error, trying to reconnect...");
        reconnect(); // Auto-reconnect on failure
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
 
    // Wait for connection
    _connSub = _client!.onConnectionEstablished.listen((_) {
      _channel!.subscribeIfNotUnsubscribed();
      _connected = true;
      print("✅ Socket connected successfully.");
    });
 
    // Handle timer and other events
    _allSub = _channel!.bindToAll().listen((event) {
      print('[EVENT] ${event.channelName}: ${event.data}');
      try {
        final rawData = event.data;
        final data = rawData is String ? jsonDecode(rawData) : rawData;
 
        if (data is Map && data.containsKey('elapsed')) {
          _timerController.add(data['elapsed']);
        }
      } catch (e) {
        print("❌ Error parsing event data: $e");
      }
    });
 
    _client!.connect();
  }
 
  void disconnect() {
    _connSub?.cancel();
    _allSub?.cancel();
    _client?.disconnect();
    _connected = false;
  }
 
  void dispose() {
    disconnect();
    _timerController.close();
  }
}
 