import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_callkit_incoming/entities/android_params.dart';
import 'package:flutter_callkit_incoming/entities/call_kit_params.dart';
import 'package:flutter_callkit_incoming/entities/ios_params.dart';
import 'package:flutter_callkit_incoming/flutter_callkit_incoming.dart';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';

class CallService {
  static final _firestore = FirebaseFirestore.instance;
  static final _auth = FirebaseAuth.instance;

  static const String _agoraAppId = 'YOUR_AGORA_APP_ID';

  static Future<String> _getAgoraToken(String channelId) async {
    return 'YOUR_TEMP_TOKEN_FOR_$channelId';
  }

  /// Outgoing call – caller side se use karo
  static Future<String> startOutgoingCall({
    required String receiverId,
    required String receiverName,
    required String type, // 'audio' or 'video'
  }) async {
    final currentUser = _auth.currentUser!;
    final callerId = currentUser.uid;
    final callerName = currentUser.email?.split('@').first ?? 'User';

    // random channel id
    final channelId =
        'ch_${callerId.substring(0, 5)}_${Random().nextInt(999999)}';

    final callRef = _firestore.collection('calls').doc();
    final callId = callRef.id;

    await callRef.set({
      'id': callId,
      'channelId': channelId,
      'callerId': callerId,
      'callerName': callerName,
      'receiverId': receiverId,
      'receiverName': receiverName,
      'type': type,
      'status': 'ringing',
      'createdAt': FieldValue.serverTimestamp(),
    });
    // 🔔 Send FCM notification to receiver – Cloud Function se
    //   data payload: { type: "incoming_call", callId, channelId, callerName, callType }
    //   niche function code dunga
    return callId;
  }

  /// Listener for call doc – dono side pe use kar sakte ho
  static Stream<DocumentSnapshot<Map<String, dynamic>>> callStream(
    String callId,
  ) {
    return _firestore.collection('calls').doc(callId).snapshots();
  }

  static Future<void> updateStatus(String callId, String status) async {
    await _firestore.collection('calls').doc(callId).update({'status': status});
  }

  // --------------------- CallKit / Incoming UI -------------------------

  static Future<void> showIncomingCallUIFromPush(
    Map<String, dynamic> data,
  ) async {
    // yeh FCM onMessage / onBackgroundMessage se call hoga
    final callId = data['callId'] as String;
    final callerName = data['callerName'] as String? ?? 'Unknown';
    final channelId = data['channelId'] as String;
    final callType = data['callType'] as String? ?? 'audio';

    final params = CallKitParams(
      id: callId,
      nameCaller: callerName,
      appName: 'Snap Messenger',
      avatar: 'https://i.pravatar.cc/100', // optional
      handle: 'SnapCall',
      type: callType == 'video'
          ? 1 // video
          : 0, // audio
      duration: 30000,
      textAccept: 'Accept',
      textDecline: 'Decline',
      extra: {'channelId': channelId, 'callType': callType},
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
    );

    await FlutterCallkitIncoming.showCallkitIncoming(params);
  }

  // --------------------- Agora join/leave -------------------------------

  static Future<RtcEngine> _createEngine() async {
    final engine = createAgoraRtcEngine();
    await engine.initialize(RtcEngineContext(appId: _agoraAppId));
    return engine;
  }

  /// caller or callee dono is function se channel join kar sakte hain
  static Future<RtcEngine> joinAgoraCall({
    required String channelId,
    required String callType,
    required int uid,
    required RtcEngineEventHandler handler,
  }) async {
    final engine = await _createEngine();
    await engine.enableVideo();

    engine.registerEventHandler(handler);

    final token = await _getAgoraToken(channelId);

    await engine.joinChannel(
      token: token,
      channelId: channelId,
      uid: uid,
      options: ChannelMediaOptions(
        clientRoleType: ClientRoleType.clientRoleBroadcaster,
        channelProfile: ChannelProfileType.channelProfileCommunication,
      ),
    );

    if (callType == 'audio') {
      await engine.disableVideo();
    }

    return engine;
  }

  static Future<void> leaveAgoraCall(RtcEngine engine) async {
    await engine.leaveChannel();
    await engine.release();
  }
}
