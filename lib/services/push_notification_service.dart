import 'dart:developer';
import 'package:astro_partner_app/constants/images_const.dart';
import 'package:astro_partner_app/model/push_notification_model.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_callkit_incoming/entities/android_params.dart';
import 'package:flutter_callkit_incoming/entities/call_kit_params.dart';
import 'package:flutter_callkit_incoming/entities/ios_params.dart';
import 'package:flutter_callkit_incoming/entities/notification_params.dart';
import 'package:flutter_callkit_incoming/flutter_callkit_incoming.dart';

class PushNotificationService {
  static final FirebaseMessaging _fcm = FirebaseMessaging.instance;

  /// Call this from main()
  static Future<void> init() async {
    // Ask permission (mainly iOS)
    await _fcm.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
      announcement: false,
      carPlay: false,
      criticalAlert: false,
    );

    // Get FCM token (send this to your backend)
    final token = await _fcm.getToken();
    log('🔥 FCM Token: $token');

    // Foreground messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      print("############onMessage###############");
      print(message.data);
      await handleRemoteMessage(message, isBackground: false);
    });

    // When app opened from notification (background)
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) async {
      print("############onMessageOpenedApp###############");
      print(message);
      await handleRemoteMessage(
        message,
        isBackground: false,
        openedFromTray: true,
      );
    });

    // When app launched from terminated via notification
    final initialMessage = await _fcm.getInitialMessage();
    if (initialMessage != null) {
      await handleRemoteMessage(
        initialMessage,
        isBackground: false,
        openedFromTray: true,
      );
    }
  }

  /// Handle all FCM data here (background + foreground)
  static Future<void> handleRemoteMessage(
    RemoteMessage message, {
    bool isBackground = false,
    bool openedFromTray = false,
  }) async {
    final data = message.data;
    log(
      '📩 FCM data: $data, background: $isBackground, openedFromTray: $openedFromTray',
    );
    // final type = data['type'];
    await _handleIncomingCall(
      pushNotificationModel: PushNotificationModel.fromJson(message.data),
    );
    // if (type == 'CALL') {
    //   await _handleIncomingCall(data);
    // } else {
    //   // handle other notification types here if you have
    //   log('ℹ️ Non-call notification received');
    // }
  }

  /// Show CallKit incoming screen
  static Future<void> _handleIncomingCall({
    required PushNotificationModel pushNotificationModel,
  }) async {
    final params = CallKitParams(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      nameCaller: pushNotificationModel.type == "CHAT_CALL"
          ? "New Chat Session"
          : pushNotificationModel.callerName ?? 'Vedam Roots Customer',
      appName: 'Vedam Roots Experts',
      avatar: launchImage,
      handle: pushNotificationModel.callerId.toString(),
      type: 0, // 0 = audio
      missedCallNotification: const NotificationParams(
        showNotification: true,
        isShowCallback: true,
        subtitle: 'Missed audio call',
        callbackText: 'Call back',
      ),
      extra: <String, dynamic>{
        'type': pushNotificationModel.type,
        'caller_id': pushNotificationModel.callerId,
        'caller_name': pushNotificationModel.callerName,
        'caller_image': pushNotificationModel.image ?? "",
        'agora_app_id': pushNotificationModel.appId ?? "NA",
        'agora_channel': pushNotificationModel.channelName ?? "NA",
        'agora_token': pushNotificationModel.agoraToken ?? "NA",
        'remaining_seconds':
            pushNotificationModel.remainingSeconds?.toString() ?? '0',
      },
      // ios: const IOSParams(
      //   iconName: 'CallKitLogo',
      //   handleType: 'generic',
      //   configureAudioSession: true,
      //   supportsVideo: true,
      //   maximumCallGroups: 2,
      //   maximumCallsPerCallGroup: 1,
      //   audioSessionMode: 'default',
      //   audioSessionActive: true,
      //   audioSessionPreferredSampleRate: 44100.0,
      //   audioSessionPreferredIOBufferDuration: 0.005,
      //   supportsDTMF: true,
      //   supportsHolding: true,
      //   supportsGrouping: false,
      //   supportsUngrouping: false,
      //   ringtonePath: 'system_ringtone_default',
      // ),
      ios: IOSParams(
        iconName: 'CallKitLogo',
        handleType: 'generic',
        supportsVideo: true,
        maximumCallGroups: 2,
        maximumCallsPerCallGroup: 1,
        audioSessionMode: 'default',
        audioSessionActive: true,
        audioSessionPreferredSampleRate: 44100.0,
        audioSessionPreferredIOBufferDuration: 0.005,
        supportsDTMF: true,
        supportsHolding: true,
        supportsGrouping: false,
        supportsUngrouping: false,
        ringtonePath: 'system_ringtone_default',
      ),
      android: const AndroidParams(
        incomingCallNotificationChannelName: 'high_importance_channel',
        missedCallNotificationChannelName: 'high_importance_channel',
        isCustomNotification: false,
        isCustomSmallExNotification: true,
        isBot: false,
        isShowLogo: false,
        isShowFullLockedScreen: true,
        isImportant: true,
        ringtonePath: 'system_ringtone_default',
        backgroundColor: '#1A1A1A',
        actionColor: '#4CAF50',
        textColor: '#ffffff',
      ),
    );

    await FlutterCallkitIncoming.showCallkitIncoming(params);
  }
}
