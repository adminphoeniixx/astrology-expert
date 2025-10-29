
import 'dart:async';

import 'package:astro_partner_app/constants/colors_const.dart';
import 'package:astro_partner_app/constants/fonts_const.dart';
import 'package:astro_partner_app/widgets/app_widget.dart';
import 'package:flutter/material.dart';

class CountdownTimer extends StatefulWidget {
  final int minutes;
  final double? textFontSize;
  final Color txtColor;
  final FontWeight fontWeight;
  final String? fontFamily;
  final VoidCallback? onTimerComplete;

  const CountdownTimer({
    super.key,
    required this.minutes,
    this.textFontSize = 16.0,
    this.txtColor = textColorPrimary,
    this.fontWeight = FontWeight.normal,
    this.fontFamily = productSans,
    this.onTimerComplete,
  });

  @override
  _CountdownTimerState createState() => _CountdownTimerState();
}

class _CountdownTimerState extends State<CountdownTimer>
    with WidgetsBindingObserver {
  late Duration duration;
  Timer? timer;
  // bool isPaused = false;
  @override
  void initState() {
    super.initState();
    duration = Duration.zero;
    startTimer();
  }

  void startTimer() {
    timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          duration = duration + const Duration(seconds: 1);
          print(duration.inSeconds);
          if (duration.inMinutes >= widget.minutes) {
            timer.cancel();
            widget.onTimerComplete?.call();
          }
        });
      }
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final minutes = duration.inMinutes.toString().padLeft(2, '0');
    final seconds = (duration.inSeconds % 60).toString().padLeft(2, '0');
    return text('$minutes:$seconds',
        fontSize: widget.textFontSize,
        fontFamily: widget.fontFamily,
        fontWeight: widget.fontWeight,
        textColor: widget.txtColor,
        isCentered: true);
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }
}





class CountdownTimer2 extends StatefulWidget {
  final int totalSeconds;
  final double? textFontSize;
  final Color txtColor;
  final FontWeight fontWeight;
  final String? fontFamily;
  final VoidCallback? onTimerComplete;

  const CountdownTimer2({
    super.key,
    required this.totalSeconds,
    this.textFontSize = 16.0,
    this.txtColor = textColorPrimary,
    this.fontWeight = FontWeight.normal,
    this.fontFamily = productSans,
    this.onTimerComplete,
  });

  @override
  _CountdownTime2rState createState() => _CountdownTime2rState();
}

class _CountdownTime2rState extends State<CountdownTimer2>
    with WidgetsBindingObserver {
  late Duration duration;
  Timer? timer;

  @override
  void initState() {
    super.initState();
    duration = Duration.zero;
    startTimer();
  }

  void startTimer() {
    timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          duration += const Duration(seconds: 1);

          if (duration.inSeconds >= widget.totalSeconds) {
            timer.cancel();
            widget.onTimerComplete?.call();
          }
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final minutes = (duration.inSeconds ~/ 60).toString().padLeft(2, '0');
    final seconds = (duration.inSeconds % 60).toString().padLeft(2, '0');

    return text(
      '$minutes:$seconds',
      fontSize: widget.textFontSize,
      fontFamily: widget.fontFamily,
      fontWeight: widget.fontWeight,
      textColor: widget.txtColor,
      isCentered: true,
    );
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }
}
