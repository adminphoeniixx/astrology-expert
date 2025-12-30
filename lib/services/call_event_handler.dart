import 'dart:developer';
import 'package:astro_partner_app/constants/string_const.dart';
import 'package:astro_partner_app/helper/local_storage.dart';
import 'package:astro_partner_app/utils/data_provider.dart';
import 'package:astro_partner_app/widgets/agora_video_calling/audio_call_page.dart';
import 'package:flutter_callkit_incoming/entities/call_event.dart';
import 'package:flutter_callkit_incoming/flutter_callkit_incoming.dart';
import 'package:get/get.dart';

class CallEventHandler {
  static Future<void> register() async {
    FlutterCallkitIncoming.onEvent.listen((CallEvent? event) async {
      if (event == null) return;
      log('📞 CallKit event: ${event.event}, body: ${event.body}');
      switch (event.event) {
        case Event.actionCallAccept:
          await _onCallAccept(event.body);
          break;
        case Event.actionCallDecline:
          log("❌ Call Declined");
          await _onCallDecline(event.body); // 👈 separate handler
          break;

        case Event.actionCallEnded:
          log("📴 Call Ended");
          await _onCallEnd(event.body);
          break;

        case Event.actionCallTimeout:
          log("⏰ Call Timeout");
          await _onCallEnd(event.body);
          break;
        case Event.actionDidUpdateDevicePushTokenVoip:
          log('📲 VoIP Push Token Updated: ${event.body}');
          break;
        default:
          log('⚠️ Unhandled event: ${event.event}');
      }
    });
  }

  static Future<void> _onCallAccept(Map<String, dynamic> body) async {
    try {
      final id = await getUserId();
      final extra = body["extra"] ?? {};
      final remaingTime =
          int.tryParse(extra['remaining_seconds']?.toString() ?? '0') ?? 0;
      final agoraAppId = extra['agora_app_id']?.toString() ?? '';
      final channel = extra['agora_channel']?.toString() ?? '';
      final agoraToken = extra['agora_token']?.toString() ?? '';
      final callerName = extra['caller_name']?.toString() ?? 'Unknown Caller';
      final callerImage = extra['caller_image']?.toString() ?? '';
      final callerId = extra['caller_id']?.toString() ?? '';
      log("🔐 agoraAppId: $agoraAppId");
      log("🔐 Agora Token: $agoraToken");
      log("📺 Channel: $channel");
      log("👤 UID: $id");
      log("👤 callerId: $callerId");
      // final ctx = navigatorKey.currentState?.overlay?.context;
      // if (ctx == null) {
      //   log("❌ No navigation context");
      //   return;
      // }
      final type = extra['type']?.toString();
      if (type == 'CHAT_CALL') {
        Get.offAllNamed('/');
      } else if (type == 'CALL') {
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
      }
    } catch (e, s) {
      log("❌ Error in _onCallAccept: $e\n$s");
    }
  }

  // static Future<void> _onCallAccept(Map<String, dynamic> body) async {
  //   final extra = (body['extra'] as Map?)?.cast<String, dynamic>() ?? {};
  //   final type = extra['type']?.toString();
  //   if (type == 'CHAT_CALL') {
  //     Get.offAllNamed('/');
  //   } else if (type == 'CALL') {
  //     final remaingTime =
  //         int.tryParse(extra['remaining_seconds']?.toString() ?? '0') ?? 0;
  //     final agoraAppId = extra['agora_app_id']?.toString() ?? '';
  //     final channel = extra['agora_channel']?.toString() ?? '';
  //     final agoraToken = extra['agora_token']?.toString() ?? '';
  //     final callerName = extra['caller_name']?.toString() ?? 'Unknown Caller';
  //     final callerImage = extra['caller_image']?.toString() ?? '';
  //     final callerId = extra['caller_id']?.toString() ?? '';
  //     final dynamic userIdExpert = await BasePrefs.readData(userId);
  //     Get.to(
  //       CallingFreePage(
  //         callerId: callerId,
  //         remaingTime: remaingTime,
  //         userImageUrl: callerImage,
  //         callType: 0, // 0 = audio, 1 = video
  //         userId: int.parse(userIdExpert),
  //         appId: agoraAppId,
  //         channel: channel,
  //         token: agoraToken,
  //         userName: callerName,
  //       ),
  //     );
  //   } else {
  //     await FlutterCallkitIncoming.endAllCalls();
  //   }
  // }

  static Future<void> _onCallEnd(Map<String, dynamic> body) async {
    try {
      final callId = body["id"]?.toString();

      log("📴 Ending call. callId = $callId");

      if (callId != null && callId.isNotEmpty) {
        await FlutterCallkitIncoming.endCall(callId);
      }

      // 🧹 SAFETY CLEANUP (VERY IMPORTANT)
      await FlutterCallkitIncoming.endAllCalls();
    } catch (e, s) {
      log("❌ Error in _onCallEnd: $e\n$s");
    }
  }

  static Future<void> _onCallDecline(Map<String, dynamic> body) async {
    try {
      final callId = body["id"]?.toString();
      log("❌ Declining call: $callId");

      if (callId != null && callId.isNotEmpty) {
        await FlutterCallkitIncoming.endCall(callId);
      }

      // 🔥 FORCE cleanup (this is the key)
      await FlutterCallkitIncoming.endAllCalls();

      // 🧹 Android OEM safety
      Future.delayed(const Duration(milliseconds: 300), () async {
        await FlutterCallkitIncoming.endAllCalls();
      });
    } catch (e, s) {
      log("❌ Error in _onCallDecline: $e\n$s");
    }
  }
}
