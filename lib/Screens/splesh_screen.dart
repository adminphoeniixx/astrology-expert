import 'dart:async';
import 'package:astro_partner_app/Screens/auth/login_screen.dart';
import 'package:astro_partner_app/Screens/home_screen.dart';
import 'package:astro_partner_app/constants/images_const.dart';
import 'package:astro_partner_app/constants/string_const.dart';
import 'package:astro_partner_app/helper/local_storage.dart';
import 'package:astro_partner_app/helper/screen_navigator.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:package_info_plus/package_info_plus.dart';

class SpleshScreen extends StatefulWidget {
  const SpleshScreen({super.key});

  @override
  State<SpleshScreen> createState() => _SpleshScreenState();
}

class _SpleshScreenState extends State<SpleshScreen> {
  @override
  void initState() {
    super.initState();

    Timer(const Duration(seconds: 2), () async {
      // Hide keyboard (if visible)
      SystemChannels.textInput.invokeMethod('TextInput.hide');

      // Check login token
      final dynamic value = await BasePrefs.readData(accessToken);
      print("Access Token: $value");

      // (Optional) App version info
      PackageInfo packageInfo = await PackageInfo.fromPlatform();
      print("App version: ${packageInfo.version}");
      // String? token = await FirebaseMessaging.instance.getToken();
      // print("FCM Token: $token");
      print("!!!!!!!!!0!!!!!!!!!!");
      // if (!mounted) return;
      print("!!!!!!!!!1!!!!!!!!!!");
      if (value == null) {
        print("!!!!!!!!!2!!!!!!!!!!");

        changeScreenReplacement(context, const LoginScreen());
      } else {
        changeScreenReplacement(context, const MyHomePage());
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(loadingImage, scale: 0.5, fit: BoxFit.cover),
          ),
        ],
      ),
      // body: Container(
      //   color: Colors.red,
      //   height: double.infinity,
      //   width: double.infinity,
      // ),
    );
  }
}
