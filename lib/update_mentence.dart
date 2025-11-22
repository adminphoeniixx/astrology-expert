import 'dart:io';
import 'package:astro_partner_app/controllers/home_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

class UpdateMentence extends StatefulWidget {
  const UpdateMentence({super.key});

  @override
  State<UpdateMentence> createState() => _UpdateMentenceState();
}

class _UpdateMentenceState extends State<UpdateMentence> {
  final HomeController _homeController = Get.put(HomeController());

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    bool appUpdateEnabled =
        _homeController.mUpdateMentenceModel?.data?.appUpdateEnabled ?? false;
    bool maintenanceMode =
        _homeController.mUpdateMentenceModel?.data?.maintenanceMode ?? false;
    String appUpdateImageUrl =
        _homeController.mUpdateMentenceModel?.data?.appUpdateImageUrl ?? "";
    String maintenanceImageUrl =
        _homeController.mUpdateMentenceModel?.data?.maintenanceImage ?? "";

    return Scaffold(
      body: Center(
        child: (appUpdateEnabled && appUpdateImageUrl.isNotEmpty)
            ? GestureDetector(
                onTap: () async {
                  String url = "";
                  // Check platform-specific update URL
                  if (Platform.isAndroid) {
                    url = _homeController.mUpdateMentenceModel?.data?.androidUrl ?? "";
                  } else if (Platform.isIOS) {
                    url = _homeController.mUpdateMentenceModel?.data?.iosUrl ?? "";
                  }

                  if (url.isNotEmpty && await canLaunchUrl(Uri.parse(url))) {
                    await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
                  } else {
                    debugPrint("Could not launch $url");
                  }
                },
                child: Container(
                  width: double.infinity,
                  height: double.infinity,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: NetworkImage(appUpdateImageUrl),
                      fit: BoxFit.cover, // Ensures the image covers the screen
                    ),
                  ),
                ),
              )
            : (maintenanceMode && maintenanceImageUrl.isNotEmpty)
                ? Container(
                    width: double.infinity,
                    height: double.infinity,
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: NetworkImage(maintenanceImageUrl),
                        fit: BoxFit.cover, // Ensures the image covers the screen
                      ),
                    ),
                  )
                : const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Center(
                      child: Text(
                        "No update or maintenance mode is active",
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
      ),
    );
  }
}
