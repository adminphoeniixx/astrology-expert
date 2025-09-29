// import 'package:astro/constants/colors_const.dart';
// import 'package:astro/services/streem_method.dart';
// import 'package:astro/widget/connecting_call_widget.dart';
// import 'package:flutter/material.dart';
// import 'package:stream_video_flutter/stream_video_flutter.dart' as stream_video;

// class AudioRoomScreen extends StatefulWidget {
//   final dynamic callId;
//   final dynamic token;
//   final dynamic apikey;

//   const AudioRoomScreen(
//       {super.key, this.callId, required this.token, required this.apikey});

//   @override
//   State<AudioRoomScreen> createState() => _AudioRoomScreenState();
// }

// class _AudioRoomScreenState extends State<AudioRoomScreen> {
//   late stream_video.Call _audioRoomCall;
//   late stream_video.CallState _callState;
//   var microphoneEnabled = true;
//   Future<stream_video.Call?>? _callFuture;

//   @override
//   void initState() {
//     super.initState();
//     _callFuture = _initializeCall();
//   }

//   Future<stream_video.Call?> _initializeCall() async {
//     final call = await createAudioRoom(
//       callId: widget.callId,
//       apiKey: widget.apikey,
//       role: "user",
//       userId: "87",
//       userName: "Aman",
//       userToken: widget.token,
//     );

//     call!.onPermissionRequest = (permissionRequest) {
//       call.grantPermissions(
//         userId: permissionRequest.user.id,
//         permissions: permissionRequest.permissions.toList(),
//       );
//     };

//     _callState = call.state.value;
//     return call;
//   }

//   @override
//   void dispose() {
//     _leaveCall();
//     super.dispose();
//   }

//   Future<void> _leaveCall() async {
//     await _audioRoomCall.end();
//     await _audioRoomCall.leave();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.black,
//       floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
//       floatingActionButton: floatingWidget(),
//       body: FutureBuilder<stream_video.Call?>(
//         future: _callFuture,
//         builder: (context, snapshot) {
//           if (snapshot.connectionState == ConnectionState.waiting) {
//             return CallConnectingScreen(callId: widget.callId);
//           }

//           if (snapshot.hasError) {
//             // return CallConnectingScreen(callId: widget.callId);
//             return const Center(
//               child: Text('Cannot fetch call state.',
//                   style: TextStyle(color: Colors.white)),
//             );
//           }

//           if (snapshot.hasData) {
//             _audioRoomCall = snapshot.data!;

//             return StreamBuilder<stream_video.CallState>(
//               initialData: _callState,
//               stream: _audioRoomCall.state.valueStream,
//               builder: (context, callSnapshot) {
//                 if (callSnapshot.hasError) {
//                   return const Center(
//                     child: Text('Cannot fetch call state.'),
//                   );
//                 }

//                 if (callSnapshot.hasData) {
//                   var callState = callSnapshot.data!;

//                   return SafeArea(
//                     child: GridView.builder(
//                       padding: const EdgeInsets.all(20),
//                       itemCount: callState.callParticipants.length,
//                       gridDelegate:
//                           const SliverGridDelegateWithFixedCrossAxisCount(
//                         crossAxisCount: 2,
//                       ),
//                       itemBuilder: (context, index) {
//                         return Align(
//                           widthFactor: 0.8,
//                           child: stream_video.StreamCallParticipant(
//                             call: _audioRoomCall,
//                             backgroundColor: Colors.transparent,
//                             participant: callState.callParticipants[index],
//                             showParticipantLabel: false,
//                             audioLevelIndicatorColor: primaryColor,
//                             showConnectionQualityIndicator: false,
//                             userAvatarTheme:
//                                 const stream_video.StreamUserAvatarThemeData(
//                               initialsBackground: primaryColor,
//                               constraints: BoxConstraints.expand(
//                                 height: 100,
//                                 width: 100,
//                               ),
//                             ),
//                           ),
//                         );
//                       },
//                     ),
//                   );
//                 }
//                 return const Center(
//                   child: CircularProgressIndicator(),
//                 );
//               },
//             );
//           }

//           return const Center(
//             child: Text('Failed to initialize the call.'),
//           );
//         },
//       ),
//     );
//   }

//   FutureBuilder<stream_video.Call?> floatingWidget() {
//     return FutureBuilder<stream_video.Call?>(
//       future: _callFuture,
//       builder: (context, snapshot) {
//         if (snapshot.connectionState == ConnectionState.waiting) {
//           return const SizedBox();
//         }

//         if (snapshot.hasError || !snapshot.hasData) {
//           return const SizedBox.shrink();
//         }

//         _audioRoomCall = snapshot.data!;

//         return Row(
//           mainAxisSize: MainAxisSize.min,
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             FloatingActionButton(
//               backgroundColor: primaryColor,
//               heroTag: 'mic_button',
//               child: microphoneEnabled
//                   ? const Icon(Icons.mic)
//                   : const Icon(Icons.mic_off),
//               onPressed: () {
//                 if (microphoneEnabled) {
//                   _audioRoomCall.setMicrophoneEnabled(enabled: false);
//                   setState(() {
//                     microphoneEnabled = false;
//                   });
//                 } else {
//                   if (!_audioRoomCall
//                       .hasPermission(stream_video.CallPermission.sendAudio)) {
//                     _audioRoomCall.requestPermissions([
//                       stream_video.CallPermission.sendAudio,
//                     ]);
//                   }
//                   _audioRoomCall.setMicrophoneEnabled(enabled: true);
//                   setState(() {
//                     microphoneEnabled = true;
//                   });
//                 }
//               },
//             ),
//             const SizedBox(width: 16),
//             FloatingActionButton(
//               heroTag: 'cut_button',
//               backgroundColor: Colors.red,
//               child: const Icon(Icons.call_end),
//               onPressed: () async {
//                 if (_audioRoomCall != null) {
//                   await _audioRoomCall.leave();
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
