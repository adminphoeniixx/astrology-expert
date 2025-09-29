// import 'package:astro/constants/colors_const.dart';
// import 'package:astro/constants/fonts_const.dart';
// import 'package:astro/services/streem_method.dart';
// import 'package:astro/widget/connecting_call_widget.dart';
// import 'package:flutter/material.dart';
// import 'package:permission_handler/permission_handler.dart';
// import 'package:stream_video_flutter/stream_video_flutter.dart' as stream_video;

// class VideoRoomScreen extends StatefulWidget {
//   final dynamic callId;
//   final dynamic token;
//   final dynamic apikey;

//   const VideoRoomScreen({
//     Key? key,
//     this.callId,
//     required this.token,
//     required this.apikey,
//   }) : super(key: key);

//   @override
//   State<VideoRoomScreen> createState() => _VideoRoomScreenState();
// }

// class _VideoRoomScreenState extends State<VideoRoomScreen> {
//   late stream_video.Call _videoRoomCall;
//   late stream_video.CallState _callState;
//   var microphoneEnabled = true;
//   var cameraEnabled = true;
//   Future<stream_video.Call?>? _callFuture;

//   @override
//   void initState() {
//     super.initState();
//     _checkPermissions();
//     _callFuture = _initializeCall();
//   }

//   Future<void> _checkPermissions() async {
//     var cameraPermission = await Permission.camera.request();
//     var microphonePermission = await Permission.microphone.request();

//     if (cameraPermission.isDenied || microphonePermission.isDenied) {
//       print("Permissions not granted for Camera or Microphone.");
//     } else {
//       print("Camera and Microphone permissions granted.");
//     }
//   }

//   Future<stream_video.Call?> _initializeCall() async {
//     final call = await createAudioRoom(
//       callId: widget.callId,
//       userId: "89",
//       userToken: widget.token,
//       userName: 'a',
//       apiKey: widget.apikey,
//       role: 'user',
//     );

//     if (call != null) {
//       print("Call initialized successfully");

//       call.onPermissionRequest = (permissionRequest) {
//         print("Permission request: ${permissionRequest.permissions}");
//         call.grantPermissions(
//           userId: permissionRequest.user.id,
//           permissions: permissionRequest.permissions.toList(),
//         );
//       };

//       _callState = call.state.value;

//       if (cameraEnabled) {
//         await call.setCameraEnabled(enabled: true);
//       }
//     } else {
//       print("Failed to initialize the call");
//     }

//     return call;
//   }

//   @override
//   void dispose() {
//     _leaveCall();
//     super.dispose();
//   }

//   Future<void> _leaveCall() async {
//     if (_videoRoomCall != null) {
//       await _videoRoomCall.leave();
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.black,
//       floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
//       floatingActionButton: _floatingWidget(),
//       body: FutureBuilder<stream_video.Call?>(
//         future: _callFuture,
//         builder: (context, snapshot) {
//           if (snapshot.connectionState == ConnectionState.waiting) {
//             return CallConnectingScreen(callId: widget.callId);
//           }

//           if (snapshot.hasError || !snapshot.hasData) {
//             return const Center(
//               child: Text(
//                 'Failed to initialize the call.',
//                 style: TextStyle(color: Colors.white),
//               ),
//             );
//           }

//           _videoRoomCall = snapshot.data!;

//           return StreamBuilder<stream_video.CallState>(
//             initialData: _callState,
//             stream: _videoRoomCall.state.valueStream,
//             builder: (context, callSnapshot) {
//               if (callSnapshot.hasError) {
//                 return const Center(
//                   child: Text('Error fetching call state.'),
//                 );
//               }

//               if (callSnapshot.hasData) {
//                 var callState = callSnapshot.data!;
//                 print(
//                     "Participants count: ${callState.callParticipants.length}");
//                 for (var participant in callState.callParticipants) {
//                   print(
//                     "Participant ID: ${participant.userId}, Video enabled: ${participant.isVideoEnabled}, Audio enabled: ${participant.isAudioEnabled}",
//                   );
//                 }

//                 return SafeArea(
//                   child: GridView.builder(
//                     padding: const EdgeInsets.all(10),
//                     itemCount: callState.callParticipants.length,
//                     gridDelegate:
//                         const SliverGridDelegateWithFixedCrossAxisCount(
//                             crossAxisCount: 1,
//                             crossAxisSpacing: 20,
//                             mainAxisSpacing: 10),
//                     itemBuilder: (context, index) {
//                       return Align(
//                         widthFactor: 0.8,
//                         child: Stack(
//                           children: [
//                             stream_video.StreamCallParticipant(
//                               call: _videoRoomCall,
//                               participant: callState.callParticipants[index],
//                               showParticipantLabel: false,
//                               backgroundColor: primeryLightColor,
//                               speakerBorderColor: primaryColor,
//                               audioLevelIndicatorColor: primaryColor,
//                               borderRadius: BorderRadius.circular(10),
//                               showConnectionQualityIndicator: false,
//                               userAvatarTheme:
//                                   const stream_video.StreamUserAvatarThemeData(
//                                 selectionColor: primaryColor,
//                                 initialsBackground: primaryColor,
//                                 borderRadius:
//                                     BorderRadius.all(Radius.circular(10)),
//                                 initialsTextStyle: TextStyle(
//                                     fontSize: 25,
//                                     fontFamily: productSans,
//                                     color: black),
//                                 constraints: BoxConstraints.expand(
//                                   height: 120,
//                                   width: 120,
//                                 ),
//                               ),
//                             ),
//                           ],
//                         ),
//                       );
//                     },
//                   ),
//                 );
//               }

//               return const Center(
//                 child: CircularProgressIndicator(),
//               );
//             },
//           );
//         },
//       ),
//     );
//   }

//   Widget _floatingWidget() {
//     return FutureBuilder<stream_video.Call?>(
//       future: _callFuture,
//       builder: (context, snapshot) {
//         if (snapshot.connectionState == ConnectionState.waiting) {
//           return const SizedBox();
//         }

//         if (snapshot.hasError || !snapshot.hasData) {
//           return const SizedBox.shrink();
//         }

//         _videoRoomCall = snapshot.data!;

//         return Row(
//           mainAxisSize: MainAxisSize.min,
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             FloatingActionButton(
//               backgroundColor: primaryColor,
//               heroTag: 'mic_button',
//               child: Icon(
//                 microphoneEnabled ? Icons.mic : Icons.mic_off,
//               ),
//               onPressed: () {
//                 if (microphoneEnabled) {
//                   _videoRoomCall.setMicrophoneEnabled(enabled: false);
//                   setState(() {
//                     microphoneEnabled = false;
//                   });
//                 } else {
//                   if (!_videoRoomCall
//                       .hasPermission(stream_video.CallPermission.sendAudio)) {
//                     _videoRoomCall.requestPermissions([
//                       stream_video.CallPermission.sendAudio,
//                     ]);
//                   }
//                   _videoRoomCall.setMicrophoneEnabled(enabled: true);
//                   setState(() {
//                     microphoneEnabled = true;
//                   });
//                 }
//               },
//             ),
//             const SizedBox(width: 16),
//             FloatingActionButton(
//               backgroundColor: primaryColor,
//               heroTag: 'camera_button',
//               child: Icon(
//                 cameraEnabled ? Icons.videocam : Icons.videocam_off,
//               ),
//               onPressed: () async {
//                 setState(() {
//                   cameraEnabled = !cameraEnabled;
//                 });
//                 await _videoRoomCall.setCameraEnabled(enabled: cameraEnabled);
//               },
//             ),
//             const SizedBox(width: 16),
//             FloatingActionButton(
//               heroTag: 'cut_button',
//               backgroundColor: Colors.red,
//               child: const Icon(Icons.call_end),
//               onPressed: () async {
//                 if (_videoRoomCall != null) {
//                   await _videoRoomCall.leave();
//                 }
//                 // ignore: use_build_context_synchronously
//                 Navigator.of(context).pop();
//               },
//             ),
//           ],
//         );
//       },
//     );
//   }
// }
