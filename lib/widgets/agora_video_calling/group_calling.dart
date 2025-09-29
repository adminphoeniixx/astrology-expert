// import 'dart:async';
// import 'package:agora_rtc_engine/agora_rtc_engine.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:permission_handler/permission_handler.dart';

// // const appId = "e78031efb24d44bbbe805e0739c3a5a1";
// // const appCertificate = '2cf9b9a610d642c3926812c8459f6a99';
// // const token = "007eJxTYJjjlqQR1PDilDyHt0+H+ZW8hfsOmjOwLhff27ep1/9m+zMFhlRzCwNjw9S0JCOTFBOTpKSkVAsD01QDc2PLZONE00RDC4YFaQ2BjAzvDM+xMjJAIIjPxVCSWlySmZceb2jEwAAAv+ggsA==";
// // const channel = "testing_12";

// class GroupCallingPage extends StatefulWidget {
//   final int callType; // 0 for audio, 1 for video
//   final String appId;
//   final String appCertificate;
//   final String token;
//   final String channel;

//   const GroupCallingPage({
//     super.key,
//     required this.callType,
//     required this.appCertificate,
//     required this.appId,
//     required this.channel,
//     required this.token,
//   });

//   @override
//   State<GroupCallingPage> createState() => _GroupCallingPageState();
// }

// class _GroupCallingPageState extends State<GroupCallingPage> {
//   final List<int> _remoteUids = [];
//   bool _localUserJoined = false;
//   bool _videoEnabled = true;
//   bool _audioMuted = false;
//   RtcEngine? _engine;

//   @override
//   void initState() {
//     super.initState();
//     _requestPermissions();
//     initAgora();
//   }

//   Future<bool> _requestPermissions() async {
//     final statuses = await [
//       Permission.microphone,
//       Permission.camera,
//     ].request();

//     if (statuses[Permission.camera] != PermissionStatus.granted ||
//         statuses[Permission.microphone] != PermissionStatus.granted) {
//       debugPrint("Camera or Microphone permission not granted");
//       return false;
//     }
//     return true;
//   }

//   Future<void> initAgora() async {
//     await [Permission.microphone, Permission.camera].request();
//     _engine = createAgoraRtcEngine();
//     print("call agroha...");
//     await _engine!.initialize(RtcEngineContext(
//       appId: widget.appId,
//       channelProfile: ChannelProfileType.channelProfileLiveBroadcasting,
//     ));
//     print("call agroha...");
//     _engine!.registerEventHandler(
//       RtcEngineEventHandler(
//         onJoinChannelSuccess: (RtcConnection connection, int elapsed) {
//           debugPrint("Local user ${connection.localUid} joined");
//           setState(() {
//             _localUserJoined = true;
//           });
//         },
//         onUserJoined: (RtcConnection connection, int remoteUid, int elapsed) {
//           debugPrint("Remote user $remoteUid joined");
//           setState(() {
//             _remoteUids.add(remoteUid);
//           });
//         },
//         onUserOffline: (RtcConnection connection, int remoteUid,
//             UserOfflineReasonType reason) {
//           debugPrint("Remote user $remoteUid left channel");
//           setState(() {
//             _remoteUids.remove(remoteUid);
//           });
//         },
//         onTokenPrivilegeWillExpire: (RtcConnection connection, String token) {
//           debugPrint(
//               '[onTokenPrivilegeWillExpire] connection: ${connection.toJson()}, token: $token');
//         },
//       ),
//     );
//     await _engine!.setClientRole(role: ClientRoleType.clientRoleBroadcaster);
//     if (widget.callType == 4) {
//       _videoEnabled = true;
//       await _engine!.enableVideo();
//       await _engine!.startPreview();
//       debugPrint("Video enabled");
//     } else {
//       _videoEnabled = false;
//       await _engine!.disableVideo();
//       debugPrint("Video disabled");
//     }
//     await _engine!.joinChannel(
//       token: widget.token,
//       channelId: widget.channel,
//       uid: 0,
//       options: const ChannelMediaOptions(),
//     );
//   }

//   @override
//   void dispose() {
//     super.dispose();
//     _dispose();
//   }

//   Future<void> _dispose() async {
//     await _engine!.leaveChannel();
//     await _engine!.release();
//   }

//   Future<void> _endCall() async {
//     await _engine!.leaveChannel();
//     Get.back();
//   }

//   Future<void> _toggleVideo() async {
//     setState(() {
//       _videoEnabled = !_videoEnabled;
//     });
//     if (_videoEnabled) {
//       await _engine!.enableVideo();
//       await _engine!.startPreview();
//       debugPrint("Video enabled");
//     } else {
//       await _engine!.disableVideo();
//       await _engine!.stopPreview();
//       debugPrint("Video disabled");
//     }
//   }

//   Future<void> _toggleMute() async {
//     setState(() {
//       _audioMuted = !_audioMuted;
//     });
//     await _engine!.muteLocalAudioStream(_audioMuted);
//   }

//   Widget _buildGridVideoView() {
//     final int userCount = _remoteUids.length + 1; // +1 for the local user
//     return GridView.builder(
//       gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
//         crossAxisCount: userCount <= 2
//             ? 1
//             : 2, // Change layout dynamically based on user count
//         childAspectRatio: userCount <= 2
//             ? 1
//             : (1 / 1.5), // Adjust aspect ratio based on layout
//       ),
//       itemCount: userCount,
//       itemBuilder: (BuildContext context, int index) {
//         if (index == 0) {
//           return _localUserJoined && _videoEnabled
//               ? AgoraVideoView(
//                   controller: VideoViewController(
//                     rtcEngine: _engine!,
//                     canvas: const VideoCanvas(uid: 0),
//                   ),
//                 )
//               : Container(
//                   decoration: BoxDecoration(
//                       borderRadius: BorderRadius.circular(10),
//                       color: Colors.grey[300]),
//                   child: const Center(
//                       child: Icon(
//                     Icons.person,
//                     size: 40,
//                     color: Colors.grey,
//                   )),
//                 );
//         } else {
//           return AgoraVideoView(
//             controller: VideoViewController.remote(
//               rtcEngine: _engine!,
//               canvas: VideoCanvas(uid: _remoteUids[index - 1]),
//               connection: RtcConnection(channelId: widget.channel),
//             ),
//           );
//         }
//       },
//     );
//   }

//   Widget _buildControlButtons() {
//     return Row(
//       mainAxisAlignment: MainAxisAlignment.center,
//       children: [
//         _buildControlButton(Icons.call_end, Colors.red, _endCall),
//         const SizedBox(width: 16),
//         if (widget.callType == 4)
//           _buildControlButton(
//             _videoEnabled ? Icons.videocam : Icons.videocam_off,
//             _videoEnabled ? Colors.blue : Colors.grey,
//             _toggleVideo,
//           ),
//         const SizedBox(width: 16),
//         _buildControlButton(
//           _audioMuted ? Icons.mic_off : Icons.mic,
//           _audioMuted ? Colors.grey : Colors.blue,
//           _toggleMute,
//         ),
//       ],
//     );
//   }

//   Widget _buildControlButton(
//       IconData icon, Color color, VoidCallback onPressed) {
//     return FloatingActionButton(
//       backgroundColor: color,
//       heroTag: "hero",
//       onPressed: onPressed,
//       child: Icon(icon),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return SafeArea(
//       child: Scaffold(
//         body: Stack(
//           children: [
//             if (widget.callType == 4 && _videoEnabled) _buildGridVideoView(),
//             Align(
//               alignment: Alignment.bottomCenter,
//               child: Padding(
//                 padding: const EdgeInsets.all(16.0),
//                 child: _buildControlButtons(),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
