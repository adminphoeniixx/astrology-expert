import 'dart:async';
import 'package:astro_partner_app/Screens/auth/login_screen.dart';
import 'package:astro_partner_app/Screens/home_screen.dart';
import 'package:astro_partner_app/constants/images_const.dart';
import 'package:astro_partner_app/constants/string_const.dart';
import 'package:astro_partner_app/controllers/home_controller.dart';
import 'package:astro_partner_app/helper/local_storage.dart';
import 'package:astro_partner_app/helper/screen_navigator.dart';
import 'package:astro_partner_app/update_mentence.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:package_info_plus/package_info_plus.dart';

class SpleshScreen extends StatefulWidget {
  const SpleshScreen({super.key});

  @override
  State<SpleshScreen> createState() => _SpleshScreenState();
}

class _SpleshScreenState extends State<SpleshScreen> {
  final HomeController _homeController = Get.put(HomeController());

  @override
  void initState() {
    super.initState();
    Timer(const Duration(seconds: 3), () async {
      dynamic value = await BasePrefs.readData(accessToken);
      print("!!!!!!!!!!!!!!!!!");
      print(value);
      Future.delayed(Duration.zero, () {
        SystemChannels.textInput.invokeMethod('TextInput.hide');
      });
      PackageInfo packageInfo = await PackageInfo.fromPlatform();
      if (value == null && mounted) {
        changeScreenReplacement(context, const LoginScreen());
      } else {
        _homeController.getUpdateMentenceModelData().then((value2) {
          if (value2!.data!.maintenanceMode == true ||
              (value2.data!.appUpdateEnabled == true &&
                  value2.data!.updateVersion.toString() !=
                      packageInfo.version)) {
            // ignore: use_build_context_synchronously
            changeScreenReplacement(context, const UpdateMentence());
          } else {
            // ignore: use_build_context_synchronously
            changeScreenReplacement(context, const MyHomePage());
          }
        });
      }
      // bool data = await isUserInIndia();
      // BasePrefs.saveData(isIndia, data);
    });

    // Timer(const Duration(seconds: 2), () async {
    //   // Hide keyboard (if visible)
    //   SystemChannels.textInput.invokeMethod('TextInput.hide');
    //   // Check login token
    //   final dynamic value = await BasePrefs.readData(accessToken);
    //   print("Access Token: $value");
    //   // (Optional) App version info
    //   PackageInfo packageInfo = await PackageInfo.fromPlatform();
    //   print("App version: ${packageInfo.version}");
    //   // String? token = await FirebaseMessaging.instance.getToken();
    //   // print("FCM Token: $token");
    //   print("!!!!!!!!!0!!!!!!!!!!");
    //   // if (!mounted) return;
    //   print("!!!!!!!!!1!!!!!!!!!!");
    //   if (value == null) {
    //     print("!!!!!!!!!2!!!!!!!!!!");

    //     changeScreenReplacement(context, const LoginScreen());
    //   } else {
    //     changeScreenReplacement(context, const MyHomePage());
    //   }
    // });
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
