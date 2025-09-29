import 'package:astro_partner_app/widgets/video_player/video_player_fullscreen_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';
// import 'package:wakelock/wakelock.dart';


class LandscapePlayerPage extends StatefulWidget {
  final VideoPlayerController controller;
  final String? thumbUrl;
  const LandscapePlayerPage({
    Key? key,
    required this.controller,
    required this.thumbUrl
  }) : super(key: key);

  @override
  _LandscapePlayerPageState createState() => _LandscapePlayerPageState();
}

class _LandscapePlayerPageState extends State<LandscapePlayerPage> {

  @override
  void initState() {
    setLandscape();
    super.initState();
  }

  @override
  void dispose() {
    setAllOrientations();
    setPortrait();
    super.dispose();
  }

  Future setLandscape() async {
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
      // await Wakelock.enabled;
  }
  Future setPortrait() async {
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    // await Wakelock.enabled;
  }

  Future setAllOrientations() async {
    await SystemChrome.setPreferredOrientations(DeviceOrientation.values);
    // await Wakelock.disable();
  }

  @override
  Widget build(BuildContext context) =>
      new WillPopScope(
        onWillPop: ()async{
         await setPortrait();
         Navigator.pop(context, true);
         return Future.value(true);
        },
        child: VideoPlayerFullscreenWidget(controller: widget.controller, thumbUrl: widget.thumbUrl ,));
}