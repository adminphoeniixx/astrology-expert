import 'dart:io';
import 'package:astro_partner_app/constants/colors_const.dart';
import 'package:astro_partner_app/widgets/app_widget.dart';
import 'package:astro_partner_app/widgets/countdown_timer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_callkit_incoming/flutter_callkit_incoming.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';

// Example constants — replace with yours if needed
// const appId = "3f16ac1d315140d398de76194bab349e";
// const token =
//     "007eJxTYPB8+PrVP26+KZUbXh5V+T6netO93MevHV9NkGYu/thUsrtQgcE4zdAsMdkwxdjQ1NDEIMXY0iIl1dzM0NIkKTHJ2MQy1f37k4yGQEaGcBZBBkYoBPFZGEpSi0sYGABRKSIN";
// const channel = "test";

class CallingFreePage extends StatefulWidget {
  final int callType; // 0 = audio, 1 = video
  final String userName;
  final String? userImageUrl;
  final int userId;
  final int remaingTime;
  final String appId;
  final String token;
  final String channel;

  const CallingFreePage({
    super.key,
    required this.remaingTime,
    required this.callType,
    required this.userName,
    required this.userId,
    required this.userImageUrl,
    required this.appId,
    required this.token,
    required this.channel,
  });

  @override
  State<CallingFreePage> createState() => _CallingFreePageState();
}

class _CallingFreePageState extends State<CallingFreePage> {
  RtcEngine? _engine;
  bool _engineInitialized = false;
  bool _localJoined = false;
  bool _videoEnabled = true;
  bool _audioMuted = false;
  int? _remoteUid;
  File? _selectedImage;

  @override
  void initState() {
    super.initState();

    _initAgora();
  }

  Future<void> _initAgora() async {
    try {
      await [Permission.microphone, Permission.camera].request();
      WakelockPlus.enable();

      final engine = createAgoraRtcEngine();
      await engine.initialize(RtcEngineContext(appId: widget.appId));

      engine.registerEventHandler(
        RtcEngineEventHandler(
          onJoinChannelSuccess: (RtcConnection connection, int elapsed) {
            debugPrint('✅ Joined channel ${connection.channelId}');
            setState(() => _localJoined = true);
          },
          onUserJoined: (RtcConnection connection, int remoteUid, int elapsed) {
            debugPrint('👤 Remote user joined: $remoteUid');
            setState(() => _remoteUid = remoteUid);
          },
          onUserOffline:
              (
                RtcConnection connection,
                int remoteUid,
                UserOfflineReasonType reason,
              ) {
                debugPrint('👋 Remote user left');
                setState(() => _remoteUid = null);
                _endCall();
              },
          onError: (ErrorCodeType code, String msg) {
            debugPrint('‼️ Agora error $code: $msg');
          },
        ),
      );

      await engine.enableAudio();
      if (widget.callType == 1) {
        await engine.enableVideo();
        await engine.startPreview();
      } else {
        await engine.disableVideo();
      }

      await engine.setDefaultAudioRouteToSpeakerphone(true);

      await engine.joinChannel(
        token: widget.token,
        channelId: widget.channel,
        uid: widget.userId,
        options: const ChannelMediaOptions(
          clientRoleType: ClientRoleType.clientRoleBroadcaster,
          channelProfile: ChannelProfileType.channelProfileCommunication,
        ),
      );
      //  await engine.joinChannelWithUserAccount(
      //         token: widget.token,
      //         channelId: widget.channel,
      //         userAccount: "expert_${widget.userId}",
      //         // uid: widget.userId,
      //         options: const ChannelMediaOptions(
      //           clientRoleType: ClientRoleType.clientRoleBroadcaster,
      //           channelProfile: ChannelProfileType.channelProfileCommunication,
      //         ),
      //       );
      setState(() {
        _engine = engine;
        _engineInitialized = true;
      });
    } catch (e) {
      debugPrint('❌ initAgora failed: $e');
    }
  }

  Future<void> _endCall() async {
    await _engine?.leaveChannel();
    await _engine?.release();
    await FlutterCallkitIncoming.endAllCalls();

    WakelockPlus.disable();
    Get.back();
  }

  Future<void> _toggleVideo() async {
    if (_engine == null) return;
    setState(() => _videoEnabled = !_videoEnabled);
    if (_videoEnabled) {
      await _engine!.enableVideo();
      await _engine!.startPreview();
    } else {
      await _engine!.disableVideo();
      await _engine!.stopPreview();
    }
  }

  Future<void> _toggleMute() async {
    if (_engine == null) return;
    setState(() => _audioMuted = !_audioMuted);
    await _engine!.muteLocalAudioStream(_audioMuted);
  }

  Future<void> _switchCamera() async {
    if (_engine == null) return;
    await _engine!.switchCamera();
  }

  Future<void> _uploadImage() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() => _selectedImage = File(picked.path));
      debugPrint("🖼️ Selected image: ${_selectedImage!.path}");
      Get.snackbar("Image Selected", "Path: ${_selectedImage!.path}");
    }
  }

  @override
  void dispose() {
    _engine?.leaveChannel();
    _engine?.release();
    WakelockPlus.disable();
    super.dispose();
  }

  Widget _remoteVideo() {
    if (_remoteUid != null && _engineInitialized) {
      return AgoraVideoView(
        controller: VideoViewController.remote(
          rtcEngine: _engine!,
          connection: RtcConnection(channelId: widget.channel),
          canvas: VideoCanvas(uid: _remoteUid),
        ),
      );
    } else {
      return Align(
        alignment: Alignment.bottomCenter,
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: 350),
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 50, // Adjust size as needed
                        backgroundColor: Colors.grey[300], // Placeholder color
                        backgroundImage: NetworkImage(
                          widget.userImageUrl!,
                        ), // If image is available, load from network
                      ),
                      const SizedBox(height: 16),
                      text(
                        widget.userName,
                        fontSize: 28.0,
                        textColor: white,
                        fontWeight: FontWeight.w600,
                        isCentered: true,
                      ),
                      _remoteUid == null
                          ? text(
                              "Ringing...",
                              fontSize: 18.0,
                              textColor: white,
                              isCentered: true,
                            )
                          : Container(
                              decoration: BoxDecoration(
                                color: white,
                                borderRadius: BorderRadius.circular(30),
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 4,
                              ),
                              child: const CountdownTimer(
                                txtColor: black,
                                minutes: 1,
                                textFontSize: 18.0,
                                // onTimerComplete: () =>
                                //  _showCompletionDialog(context),
                              ),
                            ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: black,
      body: Stack(
        children: [
          if (widget.callType == 1 && _videoEnabled)
            Center(child: _remoteVideo()),
          Align(
            alignment: Alignment.topLeft,
            child: SizedBox(
              width: 100,
              height: 150,
              child: Center(
                child: _localJoined && _videoEnabled
                    ? AgoraVideoView(
                        controller: VideoViewController(
                          rtcEngine: _engine!,
                          canvas: const VideoCanvas(uid: 0),
                        ),
                      )
                    : const SizedBox(),
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 15,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(bottom: 350),
                      child: Column(
                        children: [
                          CircleAvatar(
                            radius: 50, // Adjust size as needed
                            backgroundColor:
                                Colors.grey[300], // Placeholder color
                            backgroundImage: widget.userImageUrl == null
                                ? NetworkImage(widget.userImageUrl!)
                                : null, // If image is available, load from network
                            child: widget.userImageUrl == null
                                ? const Icon(
                                    Icons.person,
                                    size: 50,
                                    color: Colors.grey,
                                  ) // Fallback icon
                                : null,
                          ),
                          const SizedBox(height: 16),
                          text(
                            widget.userName,
                            fontSize: 28.0,
                            textColor: white,
                            fontWeight: FontWeight.w600,
                            isCentered: true,
                          ),
                          const SizedBox(height: 16),

                          _remoteUid == null
                              ? text(
                                  "Ringing...",
                                  fontSize: 18.0,
                                  textColor: white,
                                  isCentered: true,
                                )
                              : Container(
                                  decoration: BoxDecoration(
                                    color: white,
                                    borderRadius: BorderRadius.circular(30),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 4,
                                  ),
                                  child: CountdownTimer(
                                    txtColor: black,
                                    minutes: widget.remaingTime,
                                    textFontSize: 18.0,
                                    onTimerComplete: () => _endCall(),
                                  ),
                                ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        FloatingActionButton(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(28.0),
                          ),
                          heroTag: "end_call",
                          backgroundColor: Colors.red,
                          onPressed: _endCall,
                          child: const Icon(Icons.call_end),
                        ),
                        const SizedBox(width: 15),
                        if (widget.callType == 1)
                          FloatingActionButton(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(28.0),
                            ),
                            heroTag: "_toggleVideo",
                            backgroundColor: _videoEnabled
                                ? white
                                : Colors.grey,
                            onPressed: _toggleVideo,
                            child: Icon(
                              _videoEnabled
                                  ? Icons.videocam
                                  : Icons.videocam_off,
                              color: black,
                            ),
                          ),
                        const SizedBox(width: 15),
                        FloatingActionButton(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(28.0),
                          ),
                          heroTag: "_toggleMute",
                          backgroundColor: _audioMuted ? Colors.grey : white,
                          onPressed: _toggleMute,
                          child: Icon(
                            _audioMuted ? Icons.mic_off : Icons.mic,
                            color: black,
                          ),
                        ),
                        const SizedBox(width: 15),
                        if (widget.callType == 1)
                          FloatingActionButton(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(28.0),
                            ),
                            heroTag: "_switchCamera",
                            backgroundColor: white,
                            onPressed: _switchCamera,
                            child: const Icon(Icons.cameraswitch, color: black),
                          ),
                        const SizedBox(width: 15),
                        FloatingActionButton(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(28.0),
                          ),
                          heroTag: "_imageUpload",
                          backgroundColor: white,
                          onPressed: _uploadImage,
                          child: const Icon(Icons.image, color: black),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'package:flutter_callkit_incoming/flutter_callkit_incoming.dart';
// import 'package:get/get.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:permission_handler/permission_handler.dart';
// import 'package:wakelock_plus/wakelock_plus.dart';
// import 'package:agora_rtc_engine/agora_rtc_engine.dart';
// import 'package:cached_network_image/cached_network_image.dart';

// // Example constants — replace with yours if needed
// const appId = "3f16ac1d315140d398de76194bab349e";
// const token =
//     "007eJxTYPB8+PrVP26+KZUbXh5V+T6netO93MevHV9NkGYu/thUsrtQgcE4zdAsMdkwxdjQ1NDEIMXY0iIl1dzM0NIkKTHJ2MQy1f37k4yGQEaGcBZBBkYoBPFZGEpSi0sYGABRKSIN";
// const channel = "test";

// class CallingFreePage extends StatefulWidget {
//   final int callType; // 0 = audio, 1 = video
//   final String userName;
//   final String? userImageUrl;
//   final int userId;

//   const CallingFreePage({
//     super.key,
//     required this.callType,
//     required this.userName,
//     required this.userId,
//     this.userImageUrl,
//   });

//   @override
//   State<CallingFreePage> createState() => _CallingFreePageState();
// }

// class _CallingFreePageState extends State<CallingFreePage> {
//   RtcEngine? _engine;
//   bool _engineInitialized = false;
//   bool _localJoined = false;
//   bool _videoEnabled = true;
//   bool _audioMuted = false;
//   int? _remoteUid;
//   File? _selectedImage;

//   @override
//   void initState() {
//     super.initState();
//     _initAgora();
//   }

//   Future<void> _initAgora() async {
//     try {
//       await [Permission.microphone, Permission.camera].request();
//       WakelockPlus.enable();

//       final engine = createAgoraRtcEngine();
//       await engine.initialize(const RtcEngineContext(appId: appId));

//       engine.registerEventHandler(
//         RtcEngineEventHandler(
//           onJoinChannelSuccess: (RtcConnection connection, int elapsed) {
//             debugPrint('✅ Joined channel ${connection.channelId}');
//             setState(() => _localJoined = true);
//           },
//           onUserJoined: (RtcConnection connection, int remoteUid, int elapsed) {
//             debugPrint('👤 Remote user joined: $remoteUid');
//             setState(() => _remoteUid = remoteUid);
//           },
//           onUserOffline:
//               (
//                 RtcConnection connection,
//                 int remoteUid,
//                 UserOfflineReasonType reason,
//               ) {
//                 debugPrint('👋 Remote user left');
//                 setState(() => _remoteUid = null);
//                 _endCall();
//               },
//           onError: (ErrorCodeType code, String msg) {
//             debugPrint('‼️ Agora error $code: $msg');
//           },
//         ),
//       );

//       await engine.enableAudio();
//       if (widget.callType == 1) {
//         await engine.enableVideo();
//         await engine.startPreview();
//       } else {
//         await engine.disableVideo();
//       }

//       await engine.setDefaultAudioRouteToSpeakerphone(true);

//       await engine.joinChannel(
//         token: token,
//         channelId: channel,
//         uid: widget.userId,
//         options: const ChannelMediaOptions(
//           clientRoleType: ClientRoleType.clientRoleBroadcaster,
//           channelProfile: ChannelProfileType.channelProfileCommunication,
//         ),
//       );

//       setState(() {
//         _engine = engine;
//         _engineInitialized = true;
//       });
//     } catch (e) {
//       debugPrint('❌ initAgora failed: $e');
//     }
//   }

//   Future<void> _endCall() async {
//     await _engine?.leaveChannel();
//     await _engine?.release();
//     WakelockPlus.disable();
//     await FlutterCallkitIncoming.endAllCalls();

//     Get.back();
//   }

//   Future<void> _toggleVideo() async {
//     if (_engine == null) return;
//     setState(() => _videoEnabled = !_videoEnabled);
//     if (_videoEnabled) {
//       await _engine!.enableVideo();
//       await _engine!.startPreview();
//     } else {
//       await _engine!.disableVideo();
//       await _engine!.stopPreview();
//     }
//   }

//   Future<void> _toggleMute() async {
//     if (_engine == null) return;
//     setState(() => _audioMuted = !_audioMuted);
//     await _engine!.muteLocalAudioStream(_audioMuted);
//   }

//   Future<void> _switchCamera() async {
//     if (_engine == null) return;
//     await _engine!.switchCamera();
//   }

//   Future<void> _uploadImage() async {
//     final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
//     if (picked != null) {
//       setState(() => _selectedImage = File(picked.path));
//       debugPrint("🖼️ Selected image: ${_selectedImage!.path}");
//       Get.snackbar("Image Selected", "Path: ${_selectedImage!.path}");
//     }
//   }

//   @override
//   void dispose() {
//     _engine?.leaveChannel();
//     _engine?.release();
//     WakelockPlus.disable();

//     super.dispose();
//   }

//   Widget _remoteVideo() {
//     if (_remoteUid != null && _engineInitialized) {
//       return AgoraVideoView(
//         controller: VideoViewController.remote(
//           rtcEngine: _engine!,
//           connection: const RtcConnection(channelId: channel),
//           canvas: VideoCanvas(uid: _remoteUid),
//         ),
//       );
//     } else {
//       return Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           CircleAvatar(
//             radius: 60,
//             backgroundImage: CachedNetworkImageProvider(widget.userImageUrl!),
//           ),
//           const SizedBox(height: 16),
//           Text(
//             widget.userName,
//             style: const TextStyle(fontSize: 24, color: Colors.white),
//           ),
//           const SizedBox(height: 8),
//           const Text("Ringing...", style: TextStyle(color: Colors.white70)),
//         ],
//       );
//     }
//   }

//   Widget _localVideo() {
//     if (_localJoined && _videoEnabled && _engineInitialized) {
//       return Align(
//         alignment: Alignment.topLeft,
//         child: Container(
//           width: 120,
//           height: 160,
//           margin: const EdgeInsets.all(12),
//           child: AgoraVideoView(
//             controller: VideoViewController(
//               rtcEngine: _engine!,
//               canvas: const VideoCanvas(uid: 0),
//             ),
//           ),
//         ),
//       );
//     } else {
//       return const SizedBox();
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.black,
//       body: !_engineInitialized
//           ? const Center(child: CircularProgressIndicator())
//           : Stack(
//               children: [
//                 Center(
//                   child: widget.callType == 1 ? _remoteVideo() : _remoteVideo(),
//                 ),
//                 _localVideo(),
//                 Align(
//                   alignment: Alignment.bottomCenter,
//                   child: Padding(
//                     padding: const EdgeInsets.only(bottom: 24),
//                     child: Row(
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       children: [
//                         FloatingActionButton(
//                           heroTag: "end",
//                           backgroundColor: Colors.red,
//                           onPressed: _endCall,
//                           child: const Icon(Icons.call_end),
//                         ),
//                         const SizedBox(width: 15),
//                         if (widget.callType == 1)
//                           FloatingActionButton(
//                             heroTag: "video",
//                             backgroundColor: _videoEnabled
//                                 ? Colors.white
//                                 : Colors.grey,
//                             onPressed: _toggleVideo,
//                             child: Icon(
//                               _videoEnabled
//                                   ? Icons.videocam
//                                   : Icons.videocam_off,
//                               color: Colors.black,
//                             ),
//                           ),
//                         const SizedBox(width: 15),
//                         FloatingActionButton(
//                           heroTag: "mute",
//                           backgroundColor: _audioMuted
//                               ? Colors.grey
//                               : Colors.white,
//                           onPressed: _toggleMute,
//                           child: Icon(
//                             _audioMuted ? Icons.mic_off : Icons.mic,
//                             color: Colors.black,
//                           ),
//                         ),
//                         const SizedBox(width: 15),
//                         if (widget.callType == 1)
//                           FloatingActionButton(
//                             heroTag: "switch",
//                             backgroundColor: Colors.white,
//                             onPressed: _switchCamera,
//                             child: const Icon(
//                               Icons.cameraswitch,
//                               color: Colors.black,
//                             ),
//                           ),
//                         const SizedBox(width: 15),
//                         FloatingActionButton(
//                           heroTag: "image",
//                           backgroundColor: Colors.white,
//                           onPressed: _uploadImage,
//                           child: const Icon(Icons.image, color: Colors.black),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//     );
//   }
// }
