import 'dart:io';

import 'package:astro_partner_app/Screens/splesh_screen.dart';
import 'package:astro_partner_app/constants/string_const.dart';
import 'package:astro_partner_app/firebase_options.dart';
import 'package:astro_partner_app/helper/local_storage.dart';
import 'package:astro_partner_app/services/call_event_handler.dart';
import 'package:astro_partner_app/services/push_notification_service.dart';
import 'package:astro_partner_app/widgets/agora_video_calling/audio_call_page.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_callkit_incoming/flutter_callkit_incoming.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:upgrader/upgrader.dart';

/// Global navigator key so we can navigate from CallKit events
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
final RouteObserver<PageRoute> routeObserver = RouteObserver<PageRoute>();

/// 🔔 Background FCM handler
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print("############onMessageOpenedApp###############");
  print(message);
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await PushNotificationService.handleRemoteMessage(
    message,
    isBackground: true,
  );
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  // Register background handler
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
  // Init FCM + notification logic
  await PushNotificationService.init();
  // Register CallKit event listener
  await CallEventHandler.register();
  runApp(const SnapMessenger());
}

class SnapMessenger extends StatefulWidget {
  const SnapMessenger({super.key});
  static final GlobalKey<NavigatorState> appNavigatorKey =
      GlobalKey<NavigatorState>();

  @override
  State<SnapMessenger> createState() => _SnapMessengerState();
}

class _SnapMessengerState extends State<SnapMessenger>
    with WidgetsBindingObserver {
  Future<void> ensureFullIntentPermission() async {
    final prefs = await SharedPreferences.getInstance();
    final granted = prefs.getBool('full_intent_permission_granted') ?? false;
    // await _ensureCallListener();
    if (!granted) {
      prefs.setBool('full_intent_permission_granted', true);
      try {
        await FlutterCallkitIncoming.requestFullIntentPermission();
      } catch (e) {
        debugPrint('requestFullIntentPermission error: $e');
      }
    }
  }

  @override
  void initState() {
    super.initState();
    if (Platform.isIOS || Platform.isAndroid) {
      FirebaseMessaging.instance.requestPermission();
      ensureFullIntentPermission();
    }
    FlutterCallkitIncoming.getDevicePushTokenVoIP().then((v) {
      debugPrint('VoIP token: $v');
    });
  }

  Future<Map<String, dynamic>?> getCurrentCall() async {
    final calls = await FlutterCallkitIncoming.activeCalls();
    if (calls is List && calls.isNotEmpty) {
      final dynamic first = calls.first;
      if (first is Map) return first.cast<String, dynamic>();
    }
    return null;
  }

  Future<void> checkAndNavigationCallingPage() async {
    final currentCall = await getCurrentCall();
    if (currentCall == null) return;
    final extra = (currentCall['extra'] as Map?)?.cast<String, dynamic>() ?? {};
    final type = extra['type']?.toString();
    if (type == 'CHAT_CALL') {
      Get.offAllNamed('/');
    } else if (type == 'CALL') {
      final remaingTime =
          int.tryParse(extra['remaining_seconds']?.toString() ?? '0') ?? 0;
      final agoraAppId = extra['agora_app_id']?.toString() ?? '';
      final channel = extra['agora_channel']?.toString() ?? '';
      final agoraToken = extra['agora_token']?.toString() ?? '';
      final callerName = extra['caller_name']?.toString() ?? 'Unknown Caller';
      final callerImage = extra['caller_image']?.toString() ?? '';
      final callerId = extra['caller_id']?.toString() ?? '';
      final dynamic userIdExpert = await BasePrefs.readData(userId);
      Get.to(
        CallingFreePage(
          callerId: callerId,
          remaingTime: remaingTime,
          userImageUrl: callerImage,
          callType: 0, // 0 = audio, 1 = video
          userId: int.parse(userIdExpert),
          appId: agoraAppId,
          channel: channel,
          token: agoraToken,
          userName: callerName,
        ),
      );
    } else {
      await FlutterCallkitIncoming.endAllCalls();
    }
  }

  @override
  Future<void> didChangeAppLifecycleState(AppLifecycleState state) async {
    if (state == AppLifecycleState.resumed) {
      await checkAndNavigationCallingPage();
    }
  }

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      navigatorKey: SnapMessenger.appNavigatorKey,
      title: 'Vedam Roots Experts',
      debugShowCheckedModeBanner: false,
      navigatorObservers: [routeObserver],
      theme: ThemeData(useMaterial3: true),
      routes: {'/': (_) => SpleshScreen()},
      builder: (context, child) {
        return UpgradeAlert(child: child ?? const SizedBox.shrink());
      },
    );
  }
}
