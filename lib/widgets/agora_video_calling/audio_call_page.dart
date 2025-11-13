import 'package:astro_partner_app/constants/colors_const.dart';
import 'package:astro_partner_app/constants/fonts_const.dart';
import 'package:astro_partner_app/controllers/home_controller.dart';
import 'package:astro_partner_app/model/callerUserInfo_model.dart';
import 'package:astro_partner_app/widgets/app_widget.dart';
import 'package:astro_partner_app/widgets/countdown_timer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_callkit_incoming/flutter_callkit_incoming.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
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
  final String callerId;

  final int remaingTime;
  final String appId;
  final String token;
  final String channel;

  const CallingFreePage({
    super.key,
    required this.remaingTime,
    required this.callerId,
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
  // File? _selectedImage;
  bool _speakerOn = false;
  final DateFormat formatter = DateFormat("dd MMM yyyy");
  final HomeController _homeController = Get.put(HomeController());

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

      await engine.setDefaultAudioRouteToSpeakerphone(false);

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

  Future<void> _toggleSpeaker() async {
    if (_engine == null) return;
    setState(() {
      _speakerOn = !_speakerOn;
    });
    await _engine!.setEnableSpeakerphone(_speakerOn);
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

  // Future<void> _uploadImage() async {
  //   final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
  //   if (picked != null) {
  //     setState(() => _selectedImage = File(picked.path));
  //     debugPrint("🖼️ Selected image: ${_selectedImage!.path}");
  //     Get.snackbar("Image Selected", "Path: ${_selectedImage!.path}");
  //   }
  // }

  @override
  void dispose() {
    _engine?.leaveChannel();
    _engine?.release();
    WakelockPlus.disable();
    super.dispose();
  }

  void _showCustomerDetails(CallerUserInfo data) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF221d25),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: Text(
          "About ${data.name ?? "--"}",
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontFamily: productSans, color: white),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _detailRow("Name", data.name ?? "--"),
            const SizedBox(height: 6),
            _detailRow(
              "Birth Date",
              (data.birthday != null) ? formatter.format(data.birthday!) : "--",
            ),
            const SizedBox(height: 6),
            _detailRow("Birth Time", data.birthTime ?? "--"),
            const SizedBox(height: 6),
            _detailRow("Birth Time Accuracy", data.birthTimeAccuracy ?? "--"),
            const SizedBox(height: 6),
            _detailRow("Birth Place", data.birthPlace ?? "--"),
          ],
        ),
        actions: [
          TextButton(
            child: const Text(
              "Close",
              style: TextStyle(color: Colors.red, fontFamily: productSans),
            ),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  Widget _detailRow(dynamic title, dynamic value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          "$title:",
          style: const TextStyle(
            color: Colors.white70,
            fontFamily: productSans,
          ),
        ),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: const TextStyle(color: white, fontFamily: productSans),
          ),
        ),
      ],
    );
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
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          text(
                            widget.userName,
                            fontSize: 28.0,
                            textColor: white,
                            fontWeight: FontWeight.w600,
                            isCentered: true,
                          ),
                          IconButton(
                            visualDensity: VisualDensity.compact,
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                            icon: const Icon(
                              Icons.info_outline,
                              color: Colors.white,
                              size: 20,
                            ),
                            onPressed: () async {
                              await _homeController
                                  .userInfoModelData(userId: widget.callerId)
                                  .then((value) {
                                    if (value.status == true &&
                                        value.user != null) {
                                      _showCustomerDetails(value.user!);
                                    } else {
                                      Get.snackbar(
                                        'Data Not Found',
                                        'Customer details could not be loaded.',
                                        snackPosition: SnackPosition.TOP,
                                        backgroundColor: Colors.redAccent,
                                        colorText: Colors.white,
                                        duration: const Duration(seconds: 2),
                                      );
                                    }
                                  });
                            },
                          ),
                        ],
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
                              child: CountdownTimer(
                                txtColor: black,
                                minutes: widget.remaingTime,
                                textFontSize: 18.0,
                                onTimerComplete: () =>
                                    _showCompletionDialog(context),
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
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              text(
                                widget.userName,
                                fontSize: 28.0,
                                textColor: white,
                                fontWeight: FontWeight.w600,
                                isCentered: true,
                              ),
                              IconButton(
                                visualDensity: VisualDensity.compact,
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                                icon: const Icon(
                                  Icons.info_outline,
                                  color: Colors.white,
                                  size: 20,
                                ),
                                onPressed: () async {
                                  final response = await _homeController
                                      .userInfoModelData(
                                        userId: widget.callerId,
                                      );

                                  if (response.status == true &&
                                      response.user != null) {
                                    _showCustomerDetails(response.user!);
                                  } else {
                                    Get.snackbar(
                                      'Data Not Found',
                                      'Customer details could not be loaded.',
                                      snackPosition: SnackPosition.TOP,
                                      backgroundColor: Colors.redAccent,
                                      colorText: Colors.white,
                                      duration: const Duration(seconds: 2),
                                    );
                                  }
                                },
                              ),
                            ],
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
                                    onTimerComplete: () =>
                                        _showCompletionDialog(context),
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
                          heroTag: "_toggleSpeaker",
                          backgroundColor: _speakerOn ? white : Colors.grey,
                          onPressed: _toggleSpeaker,
                          child: Icon(
                            _speakerOn ? Icons.volume_up : Icons.volume_off,
                            color: black,
                          ),
                        ),

                        // const SizedBox(width: 15),
                        // FloatingActionButton(
                        //   shape: RoundedRectangleBorder(
                        //     borderRadius: BorderRadius.circular(28.0),
                        //   ),
                        //   heroTag: "_imageUpload",
                        //   backgroundColor: white,
                        //   onPressed: _uploadImage,
                        //   child: const Icon(Icons.image, color: black),
                        // ),
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

  void _showCompletionDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF221d25),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          title: text(
            'Call Complete',
            fontSize: 18.0,
            fontFamily: productSans,
            fontWeight: FontWeight.w600,
          ),
          content: text(
            'The call has been completed.',
            fontFamily: productSans,
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _endCall();
              },
              child: text('Ok', fontFamily: productSans),
            ),
          ],
        );
      },
    );
  }
}
