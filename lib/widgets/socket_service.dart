import 'dart:async';
import 'dart:convert';
import 'package:dart_pusher_channels/dart_pusher_channels.dart';

class SocketService {
  late final PusherChannelsClient _client;
  late final PrivateChannel _channel;
  bool _connected = false;

  StreamSubscription? _connSub;
  StreamSubscription? _allSub;
  StreamSubscription? _timerSub;

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
    required String channel,
  }) async {
    final options = PusherChannelsOptions.fromHost(
      scheme: useTLS ? 'wss' : 'ws',
      host: host,
      port: port,
      key: appKey,
    );

    _client = PusherChannelsClient.websocket(
      options: options,
      connectionErrorHandler: (error, stack, reconnect) async {
        reconnect(); // Auto-reconnect
      },
    );

    _channel = _client.privateChannel(
      roomId,
      authorizationDelegate:
          EndpointAuthorizableChannelTokenAuthorizationDelegate.forPrivateChannel(
            authorizationEndpoint: authEndpoint,
            headers: {
              'Authorization': 'Bearer $bearerToken',
              'Content-Type': 'application/json',
            },
          ),
    );

    _connSub = _client.onConnectionEstablished.listen((_) {
      _channel.subscribeIfNotUnsubscribed();
      _connected = true;
      print("✅ Socket connected successfully.");
    });

    // Listen to all events (for debugging)
    _allSub = _channel.bindToAll().listen((event) {
      print('[ALL EVENTS] ${event.channelName} :: ${event.data}');
    });

    // Listen for timer updates (expects integer seconds)
    _timerSub = _channel.bind(channel).listen((event) {
      try {
        final data = jsonDecode(event.data);
        if (data is int) {
          _timerController.add(data);
        } else if (data is Map && data['seconds'] != null) {
          _timerController.add(data['seconds']);
        } else {
          print("⚠️ Unknown timer format: ${event.data}");
        }
      } catch (e) {
        print("❌ Error parsing timer data: $e");
      }
    });

    _client.connect();
  }

  void disconnect() {
    _timerSub?.cancel();
    _allSub?.cancel();
    _connSub?.cancel();
    _client.disconnect();
    _connected = false;
  }

  void dispose() {
    disconnect();
    _timerController.close();
  }
}
