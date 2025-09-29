import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class YoutubeVideoPlayerScreen extends StatefulWidget {
  final String thumbUrl;
  final String videoMedia;
  final int videoId;
  const YoutubeVideoPlayerScreen(
      {super.key, required this.videoMedia, required this.thumbUrl, required this.videoId});

  @override
  _YoutubeVideoPlayerScreenState createState() =>
      _YoutubeVideoPlayerScreenState();
}

class _YoutubeVideoPlayerScreenState extends State<YoutubeVideoPlayerScreen> {
  late YoutubePlayerController _controller;
    // final HomeController _homeController = Get.put(HomeController());


  @override
  void initState() {
    //  _homeController.getVideoViewsData(
    //     videoId: widget.videoId, videotype: "mantra");
    //      _homeController.getVideoViewsData(
    //     videoId: widget.videoId, videotype: "podcast");
    _controller = YoutubePlayerController(
      initialVideoId: widget.videoMedia,
      flags: const YoutubePlayerFlags(
        autoPlay: false,
        mute: false,
        showLiveFullscreenButton: false,
      ),
    );
    setPortrait();
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    setAllOrientations();
    super.dispose();
  }

  Future setPortrait() async {
    await SystemChrome.setPreferredOrientations(
        [DeviceOrientation.landscapeLeft, DeviceOrientation.landscapeRight]);
  }

  Future setAllOrientations() async {
    await SystemChrome.setPreferredOrientations(
        [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          YoutubePlayer(
            // thumbnail: Image.network(widget.thumbUrl, fit: Box,),
            controller: _controller,
            showVideoProgressIndicator: true,
            // progressColors: ProgressBarColors(),
          ),
          Positioned(
            top: 30,
            left: 10,
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ),
        ],
      ),
    );
  }
}