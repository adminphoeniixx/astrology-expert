// import 'dart:async';
// import 'dart:io';
// import 'package:agora_rtc_engine/agora_rtc_engine.dart';
// import 'package:astro_partner_app/constants/colors_const.dart';
// import 'package:astro_partner_app/widgets/app_widget.dart';
// import 'package:astro_partner_app/widgets/countdown_timer.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_callkit_incoming/flutter_callkit_incoming.dart';
// import 'package:get/get.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:permission_handler/permission_handler.dart';
// import 'package:wakelock_plus/wakelock_plus.dart';

// class CallingPage extends StatefulWidget {
//   final String callerName;
//   final String? callerImage;

//   final int callType; // 0 = audio, 1 = video
//   final String appId;
//   final String agoraChannel;
//   final String agoraToken;
//   final int userId;

//   const CallingPage({
//     super.key,
//     required this.callerImage,
//     required this.callerName,
//     required this.callType,
//     required this.appId,
//     required this.agoraChannel,
//     required this.agoraToken,
//     required this.userId,
//   });

//   @override
//   State<CallingPage> createState() => _CallingPageState();
// }

// class _CallingPageState extends State<CallingPage> {
//   int? _remoteUid;
//   bool _localUserJoined = false;
//   bool _videoEnabled = true;
//   bool _audioMuted = false;
//   late RtcEngine _engine;
//   // ignore: unused_field
//   File? _selectedImage;

//   @override
//   void initState() {
//     print("!!!!!!!!!!!!!!!!!!CallingPage!!!!!!!!!!!!!!!!!!!!");
//     print(widget.agoraChannel);
//     print(widget.agoraToken);
//     print(widget.appId);
//     print(widget.userId);
//     print("!!!!!!!!!!!!!!!!!!CallingPage!!!!!!!!!!!!!!!!!!!!");

//     super.initState();
//     initAgora();
//   }

//   Future<void> initAgora() async {
//     await [Permission.microphone, Permission.camera].request();
//     WakelockPlus.enable();

//     _engine = createAgoraRtcEngine();
//     await _engine.initialize(
//       RtcEngineContext(
//         appId: widget.appId,
//         channelProfile: ChannelProfileType.channelProfileCommunication, // ✅ FIX
//       ),
//     );
//     // await _engine.setParameters('{"rtc.local_region":"global"}');
//     // await _engine.setParameters('{"rtc.enable_proxy": true}');
//     // await _engine.setParameters('{"rtc.proxy_server":"global"}');
//     // await _engine.setParameters('{"rtc.enable_bitrate_adaptation": true}');
//     // await _engine.enableDualStreamMode(enabled: true);

//     // await _engine.setVideoEncoderConfiguration(
//     //   const VideoEncoderConfiguration(
//     //     dimensions: VideoDimensions(width: 360, height: 640),
//     //     frameRate: 15,
//     //     bitrate: 600,
//     //   ),
//     // );
//     // await _engine.setParameters('{"rtc.enable_bitrate_adaptation": true}');

//     await _engine.enableAudio(); // ✅ enable audio before joining
//     await _engine.setClientRole(
//       role: ClientRoleType.clientRoleBroadcaster,
//     ); // ✅ FIX

//     _engine.registerEventHandler(
//       RtcEngineEventHandler(
//         onJoinChannelSuccess: (RtcConnection connection, int elapsed) {
//           debugPrint("✅ Local user joined channel: ${connection.channelId}");
//           setState(() => _localUserJoined = true);
//         },
//         onUserJoined: (RtcConnection connection, int remoteUid, int elapsed) {
//           debugPrint("✅ Remote user $remoteUid joined");
//           setState(() => _remoteUid = remoteUid);
//         },
//         onUserOffline:
//             (
//               RtcConnection connection,
//               int remoteUid,
//               UserOfflineReasonType reason,
//             ) {
//               debugPrint("❌ Remote user $remoteUid left: $reason");
//               setState(() => _remoteUid = null);
//               _endCall();
//             },
//         // onError: (ErrorCodeType error, String msg) {
//         //   debugPrint("⚠️ Agora Error $error: $msg");
//         // },
//         onError: (code, msg) {
//           debugPrint("❌ Agora Error: $code - $msg");
//         },
//         onConnectionStateChanged: (connection, state, reason) {
//           debugPrint("📡 Connection State: $state, reason: $reason");
//         },
//       ),
//     );

//     // Enable video only for video call
//     if (widget.callType == 1) {
//       _videoEnabled = true;
//       await _engine.enableVideo();
//       await _engine.startPreview();
//       await _engine.setDefaultAudioRouteToSpeakerphone(true);
//       debugPrint("🎥 Video mode enabled");
//     } else {
//       _videoEnabled = false;
//       await _engine.disableVideo();
//       await _engine.setDefaultAudioRouteToSpeakerphone(true);
//       debugPrint("🎧 Audio mode enabled");
//     }

//     await _engine.joinChannel(
//       token: widget.agoraToken,
//       channelId: widget.agoraChannel,
//       uid: widget.userId,
//       options: const ChannelMediaOptions(
//         clientRoleType: ClientRoleType.clientRoleBroadcaster,
//         channelProfile: ChannelProfileType.channelProfileCommunication,
//         // publishCameraTrack: true,
//         // publishMicrophoneTrack: true,
//         // autoSubscribeAudio: true,
//         // autoSubscribeVideo: true,
//       ),
//     );

//     final connectionState = await _engine.getConnectionState();
//     debugPrint("Agora Connection State: $connectionState");
//   }

//   @override
//   void dispose() {
//     WakelockPlus.disable();
//     _dispose();
//     super.dispose();
//   }

//   Future<void> _dispose() async {
//     try {
//       await _engine.leaveChannel();
//       await _engine.release();
//     } catch (e) {
//       debugPrint("Dispose error: $e");
//     }
//   }

//   Future<void> _endCall() async {
//     try {
//       await _engine.leaveChannel();
//       await FlutterCallkitIncoming.endAllCalls();
//       Get.back();
//     } catch (e) {
//       debugPrint("End call error: $e");
//     }
//   }

//   Future<void> _toggleVideo() async {
//     setState(() => _videoEnabled = !_videoEnabled);
//     try {
//       if (_videoEnabled) {
//         await _engine.enableVideo();
//         await _engine.setDefaultAudioRouteToSpeakerphone(true);
//         await _engine.startPreview();
//       } else {
//         await _engine.disableVideo();
//         await _engine.setDefaultAudioRouteToSpeakerphone(false);
//         await _engine.stopPreview();
//       }
//     } catch (e) {
//       debugPrint("Error toggling video: $e");
//     }
//   }

//   Future<void> _toggleMute() async {
//     setState(() => _audioMuted = !_audioMuted);
//     await _engine.muteLocalAudioStream(_audioMuted); // ✅ FIXED
//   }

//   Future<void> _switchCamera() async {
//     await _engine.switchCamera();
//   }

//   Future<void> _uploadImage() async {
//     final pickedFile = await ImagePicker().pickImage(
//       source: ImageSource.gallery,
//     );
//     if (pickedFile != null) {
//       setState(() => _selectedImage = File(pickedFile.path));
//       Get.snackbar("Image", "Selected: ${pickedFile.name}");
//     }
//   }

//   void _showCompletionDialog(BuildContext context) {
//     showDialog(
//       context: context,
//       barrierDismissible: false,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           title: text(
//             'Call Complete',
//             fontSize: 18.0,
//             fontWeight: FontWeight.w600,
//           ),
//           content: text(
//             'The call has been completed. If you have further information to share, please make the payment.',
//           ),
//           actions: [
//             TextButton(
//               onPressed: () {
//                 Navigator.of(context).pop();
//                 _endCall();
//               },
//               child: text('Cancel'),
//             ),
//             TextButton(
//               onPressed: () => Navigator.of(context).pop(),
//               child: text('Re-Payment'),
//             ),
//           ],
//         );
//       },
//     );
//   }

//   Widget _remoteVideo() {
//     if (_remoteUid != null) {
//       return AgoraVideoView(
//         controller: VideoViewController.remote(
//           rtcEngine: _engine,
//           canvas: VideoCanvas(uid: _remoteUid),
//           connection: RtcConnection(channelId: widget.agoraChannel),
//         ),
//       );
//     } else {
//       return const SizedBox();
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: black,
//       body: Stack(
//         children: [
//           if (widget.callType == 1 && _videoEnabled)
//             Center(child: _remoteVideo()),
//           Align(
//             alignment: Alignment.topLeft,
//             child: SizedBox(
//               width: 100,
//               height: 150,
//               child: Center(
//                 child: _localUserJoined && _videoEnabled
//                     ? AgoraVideoView(
//                         controller: VideoViewController(
//                           rtcEngine: _engine,
//                           canvas: const VideoCanvas(uid: 0),
//                         ),
//                       )
//                     : const SizedBox(),
//               ),
//             ),
//           ),
//           Align(
//             alignment: Alignment.bottomCenter,
//             child: SafeArea(
//               child: Padding(
//                 padding: const EdgeInsets.symmetric(
//                   horizontal: 10,
//                   vertical: 15,
//                 ),
//                 child: Column(
//                   mainAxisAlignment: MainAxisAlignment.end,
//                   children: [
//                     _remoteUid == null
//                         ? Padding(
//                             padding: const EdgeInsets.only(bottom: 350),
//                             child: Column(
//                               children: [
//                                 CircleAvatar(
//                                   radius: 50, // Adjust size as needed
//                                   backgroundColor:
//                                       Colors.grey[300], // Placeholder color
//                                   backgroundImage: widget.callerImage == null
//                                       ? NetworkImage(widget.callerImage!)
//                                       : null, // If image is available, load from network
//                                   child: widget.callerImage == null
//                                       ? const Icon(
//                                           Icons.person,
//                                           size: 50,
//                                           color: Colors.grey,
//                                         ) // Fallback icon
//                                       : null,
//                                 ),
//                                 const SizedBox(height: 16),
//                                 text(
//                                   widget.callerName,
//                                   fontSize: 28.0,
//                                   textColor: white,
//                                   fontWeight: FontWeight.w600,
//                                   isCentered: true,
//                                 ),
//                                 text(
//                                   "Ringing...",
//                                   fontSize: 18.0,
//                                   textColor: white,
//                                   isCentered: true,
//                                 ),
//                               ],
//                             ),
//                           )
//                         : Container(
//                             decoration: BoxDecoration(
//                               color: white,
//                               borderRadius: BorderRadius.circular(30),
//                             ),
//                             padding: const EdgeInsets.symmetric(
//                               horizontal: 16,
//                               vertical: 4,
//                             ),
//                             child: CountdownTimer(
//                               txtColor: black,
//                               minutes: 1,
//                               textFontSize: 18.0,
//                               onTimerComplete: () =>
//                                   _showCompletionDialog(context),
//                             ),
//                           ),
//                     const SizedBox(height: 20),
//                     Row(
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       children: [
//                         FloatingActionButton(
//                           shape: RoundedRectangleBorder(
//                             borderRadius: BorderRadius.circular(28.0),
//                           ),
//                           heroTag: "end_call",
//                           backgroundColor: Colors.red,
//                           onPressed: _endCall,
//                           child: const Icon(Icons.call_end),
//                         ),
//                         const SizedBox(width: 15),
//                         if (widget.callType == 1)
//                           FloatingActionButton(
//                             shape: RoundedRectangleBorder(
//                               borderRadius: BorderRadius.circular(28.0),
//                             ),
//                             heroTag: "_toggleVideo",
//                             backgroundColor: _videoEnabled
//                                 ? white
//                                 : Colors.grey,
//                             onPressed: _toggleVideo,
//                             child: Icon(
//                               _videoEnabled
//                                   ? Icons.videocam
//                                   : Icons.videocam_off,
//                               color: black,
//                             ),
//                           ),
//                         const SizedBox(width: 15),
//                         FloatingActionButton(
//                           shape: RoundedRectangleBorder(
//                             borderRadius: BorderRadius.circular(28.0),
//                           ),
//                           heroTag: "_toggleMute",
//                           backgroundColor: _audioMuted ? Colors.grey : white,
//                           onPressed: _toggleMute,
//                           child: Icon(
//                             _audioMuted ? Icons.mic_off : Icons.mic,
//                             color: black,
//                           ),
//                         ),
//                         const SizedBox(width: 15),
//                         if (widget.callType == 1)
//                           FloatingActionButton(
//                             shape: RoundedRectangleBorder(
//                               borderRadius: BorderRadius.circular(28.0),
//                             ),
//                             heroTag: "_switchCamera",
//                             backgroundColor: white,
//                             onPressed: _switchCamera,
//                             child: const Icon(Icons.cameraswitch, color: black),
//                           ),
//                         const SizedBox(width: 15),
//                         FloatingActionButton(
//                           shape: RoundedRectangleBorder(
//                             borderRadius: BorderRadius.circular(28.0),
//                           ),
//                           heroTag: "_imageUpload",
//                           backgroundColor: white,
//                           onPressed: _uploadImage,
//                           child: const Icon(Icons.image, color: black),
//                         ),
//                       ],
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
