import 'dart:async';
import 'dart:io';

import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:astro_partner_app/constants/colors_const.dart';
import 'package:astro_partner_app/constants/images_const.dart';
import 'package:astro_partner_app/widgets/app_widget.dart';
import 'package:astro_partner_app/widgets/countdown_timer.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

// const appId = "3f16ac1d315140d398de76194bab349e";
// const appCertificate = 'e43862d6dd454a6eab8f25b8f1a55140';
// const token =
//     "007eJxTYNha/+T+xD2+073P/XX4sJhzvphMw/PXM3NeVtutbV705aqzAoNxmqFZYrJhirGhqaGJQYqxpUVKqrmZoaVJUmKSsYll6uEXLOkNgYwML8NVmRgZIBDE52IoSS0uycxLjzc0YmAAACeYJH8=";
// const channel = "testing_12";

class CallingPage extends StatefulWidget {
  // final JoinSessionModel joinSessionModel;
  final String appId;
  final String agoraChannel;
  final String agoraToken;
  final String callerName;

  final int userId;
  final int callType; // 0 for audio, 1 for video
  const CallingPage({
    super.key,required this.callerName,
    required this.callType,
    required this.appId,
    required this.agoraChannel,
    required this.agoraToken,
    // required this.joinSessionModel,
    required this.userId,
  });

  @override
  State<CallingPage> createState() => _CallingPageState();
}

class _CallingPageState extends State<CallingPage> {
  int? _remoteUid;
  bool _localUserJoined = false;
  bool _videoEnabled = true;
  bool _audioMuted = false;
  late RtcEngine _engine;
  // final HomeController _homeController = Get.put(HomeController());

  @override
  void initState() {
    super.initState();
    initAgora();
  }

  Future<void> initAgora() async {
    await [Permission.microphone, Permission.camera].request();
    WakelockPlus.enable();

    _engine = createAgoraRtcEngine();
    await _engine.initialize(
      RtcEngineContext(
        appId: widget.appId,
        channelProfile: ChannelProfileType.channelProfileLiveBroadcasting,
      ),
    );

    _engine.registerEventHandler(
      RtcEngineEventHandler(
        onAudioVolumeIndication:
            (
              RtcConnection connection,
              List<AudioVolumeInfo> speakers,
              int totalVolume,
              int vad,
            ) {
              if (speakers.isNotEmpty) {
                for (var speaker in speakers) {
                  if (speaker.uid == 0) {
                    debugPrint("🎙️ Local Audio Level: ${speaker.volume}");
                  } else {
                    debugPrint(
                      "📢 Remote Audio Level (User ${speaker.uid}): ${speaker.volume}",
                    );
                  }
                }
              } else {
                debugPrint("🔇 No audio detected");
              }
            },
        onJoinChannelSuccess: (RtcConnection connection, int elapsed) {
          debugPrint("Local user ${connection.localUid} joined");
          setState(() {
            _localUserJoined = true;
          });
        },
        onUserJoined: (RtcConnection connection, int remoteUid, int elapsed) {
          debugPrint("Remote user $remoteUid joined");
          setState(() {
            _remoteUid = remoteUid;
          });
        },
        onUserOffline:
            (
              RtcConnection connection,
              int remoteUid,
              UserOfflineReasonType reason,
            ) {
              debugPrint("Remote user $remoteUid left channel");
              setState(() {
                _remoteUid = null;
              });
              _dispose();
              _endCall();
            },
        onTokenPrivilegeWillExpire: (RtcConnection connection, String token) {
          debugPrint(
            '[onTokenPrivilegeWillExpire] connection: ${connection.toJson()}, token: $token',
          );
        },
      ),
    );
    // Ensure speakerphone setting happens after joining the channel
    try {
      if (widget.callType == 4) {
        await _engine.setDefaultAudioRouteToSpeakerphone(true);
      } else {
        await _engine.setDefaultAudioRouteToSpeakerphone(false);
      }
    } catch (e) {
      debugPrint("Error setting speakerphone: $e");
    }

    await _engine.setClientRole(role: ClientRoleType.clientRoleBroadcaster);

    if (widget.callType == 4) {
      _videoEnabled = true;
      await _engine.enableVideo();
      await _engine.startPreview();
      // await _engine
      //     .setEnableSpeakerphone(true); // Enable speaker for video calls
      debugPrint("Video enabled");
    } else {
      _videoEnabled = false;
      await _engine.disableVideo();
      // await _engine
      //     .setEnableSpeakerphone(false); // Disable speaker for audio calls
      debugPrint("Video disabled");
    }
    await _engine.joinChannel(
      token:
         widget.agoraToken,
      channelId:
          widget.agoraChannel,
      uid: widget.userId,
      options: const ChannelMediaOptions(),
    );
  }

  @override
  void dispose() {
    WakelockPlus.disable();
    _dispose();
    super.dispose();
  }

  Future<void> _dispose() async {
    await _engine.leaveChannel();
    await _engine.release();
  }

  Future<void> _endCall() async {
    await _engine.leaveChannel();
    // Navigator.pop(context);
    Get.back();
  }

  Future<void> _toggleVideo() async {
    setState(() {
      _videoEnabled = !_videoEnabled;
    });
    try {
      if (_videoEnabled) {
        await _engine.enableVideo();
        await _engine.setDefaultAudioRouteToSpeakerphone(true);

        await _engine.startPreview();
        debugPrint("Video enabled");
      } else {
        await _engine.disableVideo();
        await _engine.setDefaultAudioRouteToSpeakerphone(false);
        await _engine.stopPreview();
        debugPrint("Video disabled");
      }
    } catch (e) {
      debugPrint("Error toggling video/speakerphone: $e");
    }
  }

  Future<void> _toggleMute() async {
    setState(() {
      _audioMuted = !_audioMuted;
    });
    await _engine.muteRecordingSignal(_audioMuted);
  }

  Future<void> _switchCamera() async {
    await _engine.switchCamera();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: black,
      body: Stack(
        children: [
          if (widget.callType == 4) // && _videoEnabled
            Center(child: _remoteVideo()),
          Align(
            alignment: Alignment.topLeft,
            child: SizedBox(
              width: 100,
              height: 150,
              child: Center(
                child: _localUserJoined && _videoEnabled
                    ? AgoraVideoView(
                        controller: VideoViewController(
                          rtcEngine: _engine,
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
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    _remoteUid == null
                        ? Padding(
                            padding: const EdgeInsets.only(bottom: 350),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const CircleAvatar(
                                  radius: 50,
                                  backgroundColor: Colors.transparent,
                                  child: ClipOval(
                                    child: Image(
                                      image:
                                          AssetImage(launchImage)
                                              as ImageProvider,
                                      fit: BoxFit.contain,
                                      width: 100,
                                      height: 100,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 16), // Add spacing
                                text(
                                  widget.callerName,
                                  fontSize: 28.0,
                                  textColor: white,
                                  fontWeight: FontWeight.w600,
                                  isCentered: true,
                                ),
                                text(
                                  "Ringing...",
                                  fontSize: 18.0,
                                  textColor: white,
                                  isCentered: true,
                                ),
                              ],
                            ),
                          )
                        : Container(
                            decoration: BoxDecoration(
                              color: white,
                              borderRadius: BorderRadius.circular(30),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 4,
                              ),
                              child: CountdownTimer(
                                txtColor: black,
                                minutes: int.parse(
                                  //  widget.joinSessionModel.totalTime ??
                                  "0",
                                ),
                                textFontSize: 18.0,
                                onTimerComplete: () {
                                  _showCompletionDialog(context);
                                },
                              ),
                            ),
                          ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
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
                        if (widget.callType == 4)
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
                        if (widget.callType == 4)
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
                          onPressed: () {
                            _uploadImage();
                          },
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

  // Function to upload an image
  File? _selectedImage;

  Future<void> _uploadImage() async {
    final pickedFile = await ImagePicker().pickImage(
      source: ImageSource.gallery,
    );

    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });

      // Call the API with the file path instead of the File object
      // _homeController
      //     .getCallImageUploadModelData(
      //   imagePath: _selectedImage!.path, // Pass file path as String
      //   roomId: widget.joinSessionModel.channelName,
      //   sessionId: widget.joinSessionModel.session!.id.toString(),
      // )
      //     .then(
      //   (value) {
      //     if (value!.message == 'Image uploaded successfully') {
      //       Get.snackbar("Image", "Image uploaded successfully");
      //     } else {
      //       Get.snackbar("Image", "Image uploaded unsuccessfully");
      //     }
      //   },
      // );
    }
  }

  void _showCompletionDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          actionsAlignment: MainAxisAlignment.spaceBetween,
          title: text(
            'Call Complete',
            fontSize: 18.0,
            fontWeight: FontWeight.w600,
          ),
          content: text(
            'The call has been completed. If you have any further information to share, please make the payment.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
                _endCall();
              },
              child: text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: text('Re-Payment'),
            ),
          ],
        );
      },
    );
  }

  Widget _remoteVideo() {
    if (_remoteUid != null) {
      return AgoraVideoView(
        controller: VideoViewController.remote(
          rtcEngine: _engine,
          canvas: VideoCanvas(uid: _remoteUid),
          connection: RtcConnection(
            channelId:
               widget.agoraChannel,
          ),
        ),
      );
    } else {
      return const SizedBox();
      // return Column(
      //   mainAxisAlignment: MainAxisAlignment.center,
      //   children: [
      //     text(widget.joinSessionModel.session!.astrologerName ?? "",
      //         fontSize: 28.0, fontWeight: FontWeight.w600, isCentered: true),
      //     text("Ringing...", fontSize: 18.0, isCentered: true),
      //   ],
      // );
    }
  }
}
