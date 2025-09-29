import 'dart:async';

import 'package:astro_partner_app/constants/colors_const.dart';
import 'package:astro_partner_app/widgets/video_player/basic_overlay_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';

class VideoPlayerVertical extends StatefulWidget {
  final String? videoUrl;
  final String? thumbUrl;
  final int videoId;

  final bool isReel;

  const VideoPlayerVertical(
      {super.key,
      required this.videoId,
      required this.videoUrl,
      required this.thumbUrl,
      this.isReel = false});

  @override
  _VideoPlayerVerticalState createState() => _VideoPlayerVerticalState();
}

class _VideoPlayerVerticalState extends State<VideoPlayerVertical> {

  late VideoPlayerController controller;
  bool isFullScreen = false;

  @override
  void initState() {
    super.initState();
    // _homeController.getVideoViewsData(
    //     videoId: widget.videoId, videotype: "podcast");
    controller = VideoPlayerController.network(widget.videoUrl!)
      ..addListener(() => setState(() {}))
      ..setLooping(false)
      ..initialize().then((_) => controller.pause());

    setPortrait(); // Lock screen orientation to portrait for reels

    // Start a timer to auto-hide the controls
  }

  @override
  void dispose() {
    setAllOrientations(); // Reset orientation to allow all modes
    controller.dispose();
    super.dispose();
  }

  Future setPortrait() async {
    if (widget.isReel) {
      await SystemChrome.setPreferredOrientations(
          [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
    } else {
      await SystemChrome.setPreferredOrientations(
          [DeviceOrientation.landscapeLeft, DeviceOrientation.landscapeRight]);
    }
  }

  Future setAllOrientations() async {
    await SystemChrome.setPreferredOrientations(
        [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // AspectRatio(
        //   aspectRatio: controller.value.isInitialized
        //       ? controller.value.aspectRatio
        //       : 16 / 9, // Fallback aspect ratio
        //   child: VideoPlayer(controller)
        // ),
        VideoPlayer(controller),
        BasicOverlayWidget(
            controller: controller,
            isFullScreen: !widget.isReel,
            thumbUrl: widget.thumbUrl),
        Positioned(
            top: 30,
            left: 10,
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: white),
              onPressed: () async {
                await SystemChrome.setPreferredOrientations([
                  DeviceOrientation.portraitUp,
                  DeviceOrientation.portraitDown
                ]);
                Navigator.pop(context);
              },
            ))
      ],
    );
  }
}
