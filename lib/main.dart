
import 'dart:async';
import 'dart:io';
import 'package:astro_partner_app/Screens/splesh_screen.dart';
import 'package:astro_partner_app/constants/images_const.dart';
import 'package:astro_partner_app/constants/string_const.dart';
import 'package:astro_partner_app/firebase_options.dart';
import 'package:astro_partner_app/helper/local_storage.dart';
import 'package:astro_partner_app/model/push_notification_model.dart';
import 'package:astro_partner_app/widgets/agora_video_calling/audio_call_page.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_callkit_incoming/flutter_callkit_incoming.dart';
import 'package:flutter_callkit_incoming/entities/call_kit_params.dart';
import 'package:flutter_callkit_incoming/entities/call_event.dart';
import 'package:flutter_callkit_incoming/entities/notification_params.dart';
import 'package:flutter_callkit_incoming/entities/android_params.dart';
import 'package:flutter_callkit_incoming/entities/ios_params.dart';
// ignore: depend_on_referenced_packages
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import 'package:upgrader/upgrader.dart';

// ====== Global singletons / constants ======
final RouteObserver<PageRoute> routeObserver = RouteObserver<PageRoute>();
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

const AndroidNotificationChannel kAndroidChannel = AndroidNotificationChannel(
  'high_importance_channel',
  'High Importance Notifications',
  description: 'This channel is used for important notifications.',
  importance: Importance.max,
  playSound: true,
  sound: RawResourceAndroidNotificationSound('notification_sound'),
);

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

StreamSubscription<CallEvent?>? _callkitSub;

// ====== Firebase background handler ======
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  debugPrint('[Notification Data] FCM data: ${message.data}');
  await _ensureCallListener();

  final type = message.data['type']?.toString();
  print("!!!!!!!!!!!!!!one!!!!!!!!!!!!!");
  print(message.data);

  if (type == 'CALL') {
    await showCallkitIncoming(
      pushNotificationModel: PushNotificationModel.fromJson(message.data),
    );
  } else {
    await showLocalNotification(message.notification);
  }
}

// ====== Show CallKit Incoming ======
Future<void> showCallkitIncoming({
  required PushNotificationModel pushNotificationModel,
}) async {
  final params = CallKitParams(
    id: const Uuid().v4(),
    nameCaller: pushNotificationModel.callerName,
    appName: 'Vedam Roots Experts',
    avatar: launchImage,
    handle: '0123456789',
    type: 0, // 0 = audio
    duration: 30000,
    textAccept: 'Accept',
    textDecline: 'Decline',
    missedCallNotification: const NotificationParams(
      showNotification: true,
      isShowCallback: true,
      subtitle: 'Missed call',
      callbackText: 'Call back',
    ),
    extra: <String, dynamic>{
      'type': 'CALL',
      'caller_id': pushNotificationModel.callerId,
      'caller_name': pushNotificationModel.callerName,
      'caller_image': pushNotificationModel.image ?? "",
      'agora_app_id': pushNotificationModel.appId ?? "NA",
      'agora_channel': pushNotificationModel.channelName ?? "NA",
      'agora_token': pushNotificationModel.agoraToken ?? "NA",
      'remaining_seconds':
          pushNotificationModel.remainingSeconds?.toString() ?? '0', // ✅ FIXED
    },
    android: const AndroidParams(
      incomingCallNotificationChannelName: 'high_importance_channel',
      missedCallNotificationChannelName: 'high_importance_channel',
      isCustomNotification: true,
      isShowLogo: true,
      isShowFullLockedScreen: true,
      isImportant: true,
      ringtonePath: 'system_ringtone_default',
      backgroundColor: '#1A1A1A',
      actionColor: '#4CAF50',
      textColor: '#ffffff',
    ),
    ios: const IOSParams(
      iconName: 'CallKitLogo',
      handleType: '',
      configureAudioSession: true,
      supportsVideo: true,
      ringtonePath: 'system_ringtone_default',
    ),
  );

  await FlutterCallkitIncoming.showCallkitIncoming(params);
}

// ====== Local notifications ======
Future<void> initLocalNotifications() async {
  const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
  const iosInit = DarwinInitializationSettings();
  const initSettings = InitializationSettings(
    android: androidInit,
    iOS: iosInit,
  );
  await flutterLocalNotificationsPlugin.initialize(initSettings);
  final androidPlugin = flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin
      >();
  await androidPlugin?.createNotificationChannel(kAndroidChannel);
}

Future<void> showLocalNotification(RemoteNotification? notification) async {
  if (notification == null) return;
  final details = NotificationDetails(
    android: AndroidNotificationDetails(
      kAndroidChannel.id,
      kAndroidChannel.name,
      channelDescription: kAndroidChannel.description,
      importance: Importance.max,
      priority: Priority.max,
      playSound: true,
      sound: const RawResourceAndroidNotificationSound('notification_sound'),
    ),
    iOS: const DarwinNotificationDetails(),
  );
  await flutterLocalNotificationsPlugin.show(
    notification.hashCode,
    notification.title,
    notification.body,
    details,
  );
}

// ====== CallKit helpers ======
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

  if (type == 'CALL') {
    final remaingTime =
        int.tryParse(extra['remaining_seconds']?.toString() ?? '0') ?? 0;
    final agoraAppId = extra['agora_app_id']?.toString() ?? '';
    final channel = extra['agora_channel']?.toString() ?? '';
    final agoraToken = extra['agora_token']?.toString() ?? '';
    final callerName = extra['caller_name']?.toString() ?? 'Unknown Caller';
    final callerImage = extra['caller_image']?.toString() ?? '';
    final dynamic userIdExpert = await BasePrefs.readData(userId);

    Get.to(
      CallingFreePage(
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

Future<void> _ensureCallListener() async {
  if (_callkitSub != null) return;
  _callkitSub = FlutterCallkitIncoming.onEvent.listen((CallEvent? event) {
    if (event == null) return;
    switch (event.event) {
      case Event.actionCallAccept:
      case Event.actionCallCustom:
        checkAndNavigationCallingPage();
        break;
      default:
        break;
    }
  });
}

// ====== FCM permission ======
Future<void> initializeFirebaseMessaging() async {
  final settings = await FirebaseMessaging.instance.requestPermission(
    alert: true,
    badge: true,
    sound: true,
  );
  debugPrint('FCM permission: ${settings.authorizationStatus}');
  await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
    alert: true,
    badge: true,
    sound: true,
  );
}

Future<void> ensureFullIntentPermission() async {
  final prefs = await SharedPreferences.getInstance();
  final granted = prefs.getBool('full_intent_permission_granted') ?? false;
  await _ensureCallListener();
  if (!granted) {
    prefs.setBool('full_intent_permission_granted', true);
    try {
      await FlutterCallkitIncoming.requestFullIntentPermission();
    } catch (e) {
      debugPrint('requestFullIntentPermission error: $e');
    }
  }
}

// ====== MAIN ======
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await initLocalNotifications();
  await initializeFirebaseMessaging();
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});
  static final GlobalKey<NavigatorState> appNavigatorKey =
      GlobalKey<NavigatorState>();

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    if (Platform.isIOS || Platform.isAndroid) {
      FirebaseMessaging.instance.requestPermission();
      ensureFullIntentPermission();
    }
    _bindFirebaseMessagingHandlers();
    FlutterCallkitIncoming.getDevicePushTokenVoIP().then((v) {
      debugPrint('VoIP token: $v');
    });
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _callkitSub?.cancel();
    _callkitSub = null;
    super.dispose();
  }

  @override
  Future<void> didChangeAppLifecycleState(AppLifecycleState state) async {
    if (state == AppLifecycleState.resumed) {
      await checkAndNavigationCallingPage();
    }
  }

  void _bindFirebaseMessagingHandlers() {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      final type = message.data['type']?.toString();
      print("!!!!!!!!!!!!!!two!!!!!!!!!!!!!");
      print(message.data);
      if (type == 'CALL') {
        await showCallkitIncoming(
          pushNotificationModel: PushNotificationModel.fromJson(message.data),
        );
      } else {
        await showLocalNotification(message.notification);
      }
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) async {
      final type = message.data['type']?.toString();
      print("!!!!!!!!!!!!!!three!!!!!!!!!!!!!");
      print(message.data);

      if (type == 'CALL') {
        await checkAndNavigationCallingPage();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      navigatorKey: MyApp.appNavigatorKey,
      title: 'Vedam Roots Experts',
      debugShowCheckedModeBanner: false,
      navigatorObservers: [routeObserver],
      theme: ThemeData(useMaterial3: true),
      routes: {'/': (_) => const SpleshScreen()},
      builder: (context, child) {
        return UpgradeAlert(child: child ?? const SizedBox.shrink());
      },
    );
  }
}
