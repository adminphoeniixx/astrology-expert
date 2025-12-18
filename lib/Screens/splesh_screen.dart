import 'dart:async';
import 'package:astro_partner_app/screens/auth/login_screen.dart';
import 'package:astro_partner_app/screens/home_screen.dart';
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

    // Set expert availability
    _homeController.expertOnOffModelData(available: "Yes");

    // Start timer
    Timer(const Duration(seconds: 3), () async {
      if (!mounted) return;

      // Hide keyboard
      Future.delayed(Duration.zero, () {
        SystemChannels.textInput.invokeMethod('TextInput.hide');
      });

      // Read token
      dynamic token = await BasePrefs.readData(accessToken);
      print("TOKEN FOUND: $token");

      // Get app version
      PackageInfo packageInfo = await PackageInfo.fromPlatform();
      String currentVersion = packageInfo.version;

      // If no token → go to login
      if (token == null) {
        if (mounted) {
          changeScreenReplacement(context, const LoginScreen());
        }
        return;
      }

      // GET UPDATE/MAINTENANCE STATUS SAFELY
      var updateModel;
      try {
        updateModel = await _homeController.getUpdateMentenceModelData();
      } catch (e) {
        print("🔥 ERROR FETCHING UPDATE MODEL: $e");
        updateModel = null;
      }

      if (!mounted) return;

      // Null-safe values
      final maintenanceMode = updateModel?.data?.maintenanceMode ?? false;
      final updateEnabled = updateModel?.data?.appUpdateEnabled ?? false;
      final updateVersion = updateModel?.data?.updateVersion ?? "";

      print("maintenanceMode → $maintenanceMode");
      print("updateEnabled   → $updateEnabled");
      print("updateVersion   → $updateVersion");
      print("currentVersion  → $currentVersion");

      // If maintenance enabled → redirect
      if (maintenanceMode == true) {
        changeScreenReplacement(context, const UpdateMentence());
        return;
      }

      // If update required → redirect
      if (updateEnabled == true && updateVersion != currentVersion) {
        changeScreenReplacement(context, const UpdateMentence());
        return;
      }

      // Else → go to home
      changeScreenReplacement(context, const MyHomePage());
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(child: Image.asset(loadingImage, fit: BoxFit.cover)),
        ],
      ),
    );
  }
}
