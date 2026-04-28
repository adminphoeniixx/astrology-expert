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
import 'package:flutter_callkit_incoming/entities/android_params.dart';
import 'package:flutter_callkit_incoming/entities/ios_params.dart';
// ignore: depend_on_referenced_packages
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import 'package:upgrader/upgrader.dart';

// ====== Global singletons / constants ======
final RouteObserver<PageRoute> routeObserver = RouteObserver<PageRoute>();
// final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

const AndroidNotificationChannel kAndroidChannel = AndroidNotificationChannel(
  'high_importance_channel',
  'High Importance Notifications',
  description: 'This channel is used for important notifications.',
  importance: Importance.max,
  playSound: true,
  sound: RawResourceAndroidNotificationSound('system_ringtone_default'),
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

  // if (type == 'CALL') {
  //   await showCallkitIncoming(
  //     pushNotificationModel: PushNotificationModel.fromJson(message.data),
  //   );
  // } else {
  //   await showLocalNotification(message.notification);
  // }

  if (type == 'CALL' || type == 'CHAT_CALL') {
    // await RingtoneService.play(); // ✅ foreground only
    await showCallkitIncoming(
      pushNotificationModel: PushNotificationModel.fromJson(message.data),
    );
  }

  // // ✅ ONLY chat / other notification
  // await showLocalNotification(message.notification);
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
    handle: pushNotificationModel.title,
    type: 0, // 0 = audio
    duration: 30000,
    textAccept: 'Accept',
    textDecline: 'Decline',
    // missedCallNotification: const NotificationParams(
    //   showNotification: true,
    //   isShowCallback: true,
    //   subtitle: 'Missed call',
    //   callbackText: 'Call back',
    // ),
    extra: <String, dynamic>{
      'type': pushNotificationModel.type,
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
      handleType: 'generic',
      configureAudioSession: true,
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

// Future<void> showLocalNotification(RemoteNotification? notification) async {
//   if (notification == null) return;
//   final details = NotificationDetails(
//     android: AndroidNotificationDetails(
//       kAndroidChannel.id,
//       kAndroidChannel.name,
//       channelDescription: kAndroidChannel.description,
//       importance: Importance.max,
//       priority: Priority.max,
//       // playSound: true,
//       // sound: const RawResourceAndroidNotificationSound(
//       //   'system_ringtone_default',
//       // ),
//     ),
//     iOS: const DarwinNotificationDetails(),
//   );
//   await flutterLocalNotificationsPlugin.show(
//     notification.hashCode,
//     notification.title,
//     notification.body,
//     details,
//   );
//   final params = CallKitParams(
//     id: callId,
//     nameCaller: callerName,
//     appName: 'Snap Messenger',
//     avatar: 'https://i.pravatar.cc/100', // optional
//     handle: 'SnapCall',
//     type: callType == 'video'
//         ? 1 // video
//         : 0, // audio
//     duration: 30000,
//     textAccept: 'Accept',
//     textDecline: 'Decline',
//     extra: {'channelId': channelId, 'callType': callType},
//     ios: const IOSParams(
//       iconName: 'CallKitLogo',
//       handleType: 'generic',
//       configureAudioSession: true,
//       supportsVideo: true,
//       maximumCallGroups: 2,
//       maximumCallsPerCallGroup: 1,
//       audioSessionMode: 'default',
//       audioSessionActive: true,
//       audioSessionPreferredSampleRate: 44100.0,
//       audioSessionPreferredIOBufferDuration: 0.005,
//       supportsDTMF: true,
//       supportsHolding: true,
//       supportsGrouping: false,
//       supportsUngrouping: false,
//       ringtonePath: 'system_ringtone_default',
//     ),
//     android: const AndroidParams(
//       incomingCallNotificationChannelName: 'high_importance_channel',
//       missedCallNotificationChannelName: 'high_importance_channel',
//       isCustomNotification: true,
//       isShowLogo: true,
//       isShowFullLockedScreen: true,
//       isImportant: true,
//       ringtonePath: 'system_ringtone_default',
//       backgroundColor: '#1A1A1A',
//       actionColor: '#4CAF50',
//       textColor: '#ffffff',
//     ),
//   );

//   await FlutterCallkitIncoming.showCallkitIncoming(params);
// }

// Future<void> showLocalNotificationn({
//   required PushNotificationModel pushNotificationModel,
// }) async {
//   final params = CallKitParams(
//     id: const Uuid().v4(),
//     nameCaller: pushNotificationModel.callerName,
//     appName: 'Vedam Roots Experts',
//     avatar: launchImage,
//     handle: pushNotificationModel.title,
//     type: 0, // 0 = audio
//     duration: 30000,
//     textAccept: 'Accept',
//     textDecline: 'Decline',
//     missedCallNotification: const NotificationParams(
//       showNotification: true,
//       isShowCallback: true,
//       subtitle: 'Missed call',
//       callbackText: 'Call back',
//     ),
//     extra: {'channelId': '0', 'callType': '0'},
//     android: const AndroidParams(
//       incomingCallNotificationChannelName: 'high_importance_channel',
//       missedCallNotificationChannelName: 'high_importance_channel',
//       isCustomNotification: false,
//       isShowLogo: true,
//       isShowFullLockedScreen: true,
//       isImportant: true,
//       //  ringtonePath: 'system_ringtone_default',
//       backgroundColor: '#1A1A1A',
//       actionColor: '#4CAF50',
//       textColor: '#ffffff',
//     ),
//     ios: const IOSParams(
//       iconName: 'CallKitLogo',
//       handleType: 'generic',
//       configureAudioSession: true,
//       supportsVideo: true,
//       maximumCallGroups: 2,
//       maximumCallsPerCallGroup: 1,
//       audioSessionMode: 'default',
//       audioSessionActive: true,
//       audioSessionPreferredSampleRate: 44100.0,
//       audioSessionPreferredIOBufferDuration: 0.005,
//       supportsDTMF: true,
//       supportsHolding: true,
//       supportsGrouping: false,
//       supportsUngrouping: false,
//       // ringtonePath: 'system_ringtone_default',
//     ),
//   );
//   await FlutterCallkitIncoming.showCallkitIncoming(params);
// }

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

Future<void> _ensureCallListener() async {
  if (_callkitSub != null) return;

  _callkitSub = FlutterCallkitIncoming.onEvent.listen((CallEvent? event) async {
    if (event == null) return;

    switch (event.event) {
      case Event.actionCallAccept:
      case Event.actionCallCustom:
        // await RingtoneService.stop(); // ⏹ FIRST STOP
        await checkAndNavigationCallingPage();
        break;

      case Event.actionCallDecline:
      case Event.actionCallEnded:
      case Event.actionCallTimeout:
        // await RingtoneService.stop(); // ⏹ STOP
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
  // bool _expertMarkedOffline = false;
  // final HomeController _homeController = Get.put(HomeController());
  // static const _lifecycleChannel = MethodChannel('app_lifecycle_channel');
  @override
  void initState() {
    super.initState();
    // _lifecycleChannel.setMethodCallHandler((call) async {
    //   if (call.method == 'onAppRemovedFromRecents') {
    //     _setExpertOffline();
    //   }
    // });
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
      // RingtoneService.stop();
    }
    // if (state == AppLifecycleState.detached) {
    //   // ✅ App process kill hone wala hai
    //   _setExpertOffline();
    // }
  }

  // Future<bool> _isUserLoggedIn() async {
  //   final token = await BasePrefs.readData(accessToken);
  //   return token != null && token.toString().isNotEmpty;
  // }

  // void _setExpertOffline() async {
  //   if (_expertMarkedOffline) return;
  //   if (!await _isUserLoggedIn()) return;

  //   _expertMarkedOffline = true;

  //   // ✅ UNAVAILABLE
  //   _homeController.expertOnOffModelData(available: "No");
  // }

  void _bindFirebaseMessagingHandlers() {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      final type = message.data['type'];

      if (type == 'CALL' || type == 'CHAT_CALL') {
        // await RingtoneService.play(); // ✅ foreground only
        await showCallkitIncoming(
          pushNotificationModel: PushNotificationModel.fromJson(message.data),
        );
      }
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) async {
      final type = message.data['type'];

      if (type == 'CALL' || type == 'CHAT_CALL') {
        // await RingtoneService.play(); // ✅ foreground only
        await showCallkitIncoming(
          pushNotificationModel: PushNotificationModel.fromJson(message.data),
        );
      }

      // if (type == 'CALL') {
      //   await checkAndNavigationCallingPage();
      // } else {
      //   await showLocalNotification(message.notification);
      // }
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
      routes: {'/': (_) => SpleshScreen()},
      builder: (context, child) {
        return UpgradeAlert(
          navigatorKey: MyApp.appNavigatorKey,
          child: child ?? const SizedBox.shrink(),
        );
      },
    );
  }
}

// X3YSQQX547
// 4N2USG2LAR

// class MyWidget extends StatefulWidget {
//   const MyWidget({super.key});
//   @override
//   State<MyWidget> createState() => _MyWidgetState();
// }
// class _MyWidgetState extends State<MyWidget> {
//   XFile? _pickedImage;
//   final ImagePicker _picker = ImagePicker();
//   bool _isLoading = false;
//   // ================= GALLERY PICK =================
//   Future<void> pickImage() async {
//     if (_isLoading) return;
//     setState(() => _isLoading = true);
//     try {
//       /// ✅ iOS permission only
//       if (Platform.isIOS) {
//         final status = await Permission.photos.request();
//         if (!status.isGranted) {
//           _showSnackBar('Gallery permission denied');
//           openAppSettings();
//           return;
//         }
//       }
//       /// ✅ Android: NO permission needed
//       final picked = await _picker.pickImage(
//         source: ImageSource.gallery,
//         imageQuality: 85,
//         maxWidth: 1080,
//         maxHeight: 1080,
//       );
//       if (picked != null) {
//         setState(() => _pickedImage = picked);
//         _showSnackBar('Image selected');
//       }
//     } catch (e) {
//       _showSnackBar('Error: $e');
//     } finally {
//       if (mounted) setState(() => _isLoading = false);
//     }
//   }
//   // ================= UI =================
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text('Gallery Picker')),
//       body: Padding(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           children: [
//             Container(
//               height: 280,
//               width: double.infinity,
//               decoration: BoxDecoration(
//                 border: Border.all(color: Colors.grey),
//                 borderRadius: BorderRadius.circular(12),
//               ),
//               child: _pickedImage == null
//                   ? const Center(child: Text('No image selected'))
//                   : ClipRRect(
//                       borderRadius: BorderRadius.circular(12),
//                       child: Image.file(
//                         File(_pickedImage!.path),
//                         fit: BoxFit.cover,
//                       ),
//                     ),
//             ),
//             const SizedBox(height: 24),

//             if (_isLoading) const CircularProgressIndicator(),

//             ElevatedButton.icon(
//               onPressed: pickImage,
//               icon: const Icon(Icons.photo_library),
//               label: const Text('Pick from Gallery'),
//             ),

//             if (_pickedImage != null)
//               TextButton(
//                 onPressed: () => setState(() => _pickedImage = null),
//                 child: const Text('Clear'),
//               ),
//           ],
//         ),
//       ),
//     );
//   }
//   void _showSnackBar(String msg) {
//     ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
//   }
// }
