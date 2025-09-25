import 'dart:io';

import 'package:astro_partner_app/constants/colors_const.dart';
import 'package:astro_partner_app/constants/fonts_const.dart';
import 'package:astro_partner_app/constants/images_const.dart';
import 'package:astro_partner_app/controllers/home_controller.dart';
import 'package:astro_partner_app/services/web_request_constants.dart';
import 'package:astro_partner_app/widgets/app_widget.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
// ignore: depend_on_referenced_packages
import 'package:path_provider/path_provider.dart';
import 'package:intl/intl.dart';

class SessionTab extends StatefulWidget {
  const SessionTab({super.key});
  @override
  State<SessionTab> createState() => _SessionTabState();
}

class _SessionTabState extends State<SessionTab> {
  // int? _selectedIndex;
  final HomeController _homeController = Get.put(HomeController());
  final ScrollController _scrollmainController = ScrollController();
  final ValueNotifier<String> _selectedFilter = ValueNotifier<String>(
    "All Sessions",
  );

  @override
  void initState() {
    _homeController.fetchSessionData(serviceType: "all");
    _scrollmainController.addListener(() {
      if (_scrollmainController.position.pixels ==
          _scrollmainController.position.maxScrollExtent) {
        if (_homeController.nextPageUrlforCommingSession.value != '') {
          _homeController.fetchSessionData(
            pageUrl: _homeController.nextPageUrl.value.replaceAll(http, https),
            isPaginatHit: true,
          );
        }
      }
    });
    super.initState();
  }

  final Map<String, String> serviceTypes = {
    "All Sessions": "all",
    "Live Chat": "1",
    "Audio Recording": "2",
    "Call Consultation": "3",
    "Video Consultation": "4",
  };

  Widget _buildFilterChip(String label, bool isSelected) {
    return GestureDetector(
      onTap: () {
        final type = serviceTypes[label] ?? "all";
        _homeController.fetchSessionData(serviceType: type);
        setState(() {
          _selectedFilter.value = label;
        });
      },
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? primaryColor : Colors.transparent,
          border: Border.all(color: isSelected ? primaryColor : primaryColor),
          borderRadius: BorderRadius.circular(15),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontFamily: productSans,
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: isSelected ? black : white,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: white,

      body: Stack(
        children: [
          SizedBox(
            height: double.infinity,
            width: double.infinity,
            child: Image.asset(appBg, fit: BoxFit.fill),
          ),
          Obx(() {
            if (_homeController.isSessionsModelLoding.value) {
              return circularProgress();
            } else {
              return SingleChildScrollView(
                physics: const ClampingScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 15),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 18),
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: ValueListenableBuilder<String>(
                          valueListenable: _selectedFilter,
                          builder: (context, selected, _) {
                            return Row(
                              children: serviceTypes.keys.map((label) {
                                return _buildFilterChip(
                                  label,
                                  selected == label,
                                );
                              }).toList(),
                            );
                          },
                        ),
                      ),
                    ),

                    const SizedBox(height: 15),
                    _homeController.sessionListData.isEmpty
                        ? Padding(
                            padding: const EdgeInsets.only(top: 320),
                            child: Center(
                              child: text(
                                "No sessions are available.",
                                fontFamily: productSans,
                                textColor: white,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          )
                        : ListView.builder(
                            physics: const ClampingScrollPhysics(),
                            shrinkWrap: true,
                            itemCount: _homeController.sessionListData.length,
                            itemBuilder: (BuildContext context, int index) {
                              if (index ==
                                  _homeController.sessionListData.length) {
                                return _homeController
                                            .nextPageUrlforCommingSession
                                            .value !=
                                        ""
                                    ? const Padding(
                                        padding: EdgeInsets.all(8.0),
                                        child: CupertinoActivityIndicator(),
                                      )
                                    : const SizedBox();
                              } else {
                                return GestureDetector(
                                  onTap: () async {
                                    // await _homeController.getSessionCheckData(
                                    //     sessionId: _homeController
                                    //         .commingSessionListData[index].id!);
                                    // if (_homeController.mSessionCheck!.status ==
                                    //     false) {
                                    //   showDialog(
                                    //     // ignore: use_build_context_synchronously
                                    //     context: context,
                                    //     builder: (BuildContext dialogContext) {
                                    //       // Use a separate context for the dialog
                                    //       return AlertDialog(
                                    //         title: const Text(
                                    //           "Session",
                                    //           style: TextStyle(
                                    //               fontFamily: productSans),
                                    //         ),
                                    //         content: const Text(
                                    //           "Oops! You're early. ⏰ Your session hasn’t started yet. Please join at the scheduled time. We’ll be ready for you!",
                                    //           style: TextStyle(
                                    //               fontFamily: productSans),
                                    //         ),
                                    //         actions: [
                                    //           TextButton(
                                    //             child: const Text(
                                    //               "OK",
                                    //               style: TextStyle(
                                    //                   fontFamily: productSans,
                                    //                   color: black),
                                    //             ),
                                    //             onPressed: () {
                                    //               Navigator.pop(
                                    //                   dialogContext); // Use the dialog-specific context
                                    //             },
                                    //           ),
                                    //         ],
                                    //       );
                                    //     },
                                    //   );
                                    // } else {
                                    // switch (int.parse(_homeController
                                    //     .commingSessionListData[index]
                                    //     .serviceType
                                    //     .toString())) {
                                    //   case 1:
                                    //     _homeController
                                    //         .joinChatSessions(
                                    //             sessionId: _homeController
                                    //                 .commingSessionListData[
                                    //                     index]
                                    //                 .id
                                    //                 .toString())
                                    //         .then(
                                    //             (joinChatSessionsValue) async {
                                    //       print(
                                    //           "!!!!!!!!!joinChatSessionsValue!!!!!!!!!");
                                    //       print(joinChatSessionsValue
                                    //           .joinStatus);
                                    //       BasePrefs.readData(userId)
                                    //           .then((mUserId) {
                                    //         //_homeController.commingSessionListData[index].status
                                    //         if (joinChatSessionsValue
                                    //                 .joinStatus ==
                                    //             'Completed') {
                                    //           showDialog(
                                    //             // ignore: use_build_context_synchronously
                                    //             context: context,
                                    //             builder: (BuildContext
                                    //                 dialogContext) {
                                    //               return AlertDialog(
                                    //                 title: const Text(
                                    //                   "Session Completed",
                                    //                   style: TextStyle(
                                    //                       fontFamily:
                                    //                           productSans),
                                    //                 ),
                                    //                 content: const Text(
                                    //                   "Your session has been completed successfully.",
                                    //                   style: TextStyle(
                                    //                       fontFamily:
                                    //                           productSans),
                                    //                 ),
                                    //                 actions: [
                                    //                   TextButton(
                                    //                     child: const Text(
                                    //                       "OK",
                                    //                       style: TextStyle(
                                    //                           fontFamily:
                                    //                               productSans,
                                    //                           color: black),
                                    //                     ),
                                    //                     onPressed: () {
                                    //                       Navigator.pop(
                                    //                           dialogContext);
                                    //                     },
                                    //                   ),
                                    //                 ],
                                    //               );
                                    //             },
                                    //           );
                                    //         } else if (joinChatSessionsValue
                                    //                 .joinStatus ==
                                    //             'Cancelled') {
                                    //           showDialog(
                                    //             // ignore: use_build_context_synchronously
                                    //             context: context,
                                    //             builder: (BuildContext
                                    //                 dialogContext) {
                                    //               return AlertDialog(
                                    //                 title: const Text(
                                    //                   "Session Cancelled",
                                    //                   style: TextStyle(
                                    //                       fontFamily:
                                    //                           productSans),
                                    //                 ),
                                    //                 content: const Text(
                                    //                   "Your session has been cancelled.",
                                    //                   style: TextStyle(
                                    //                       fontFamily:
                                    //                           productSans),
                                    //                 ),
                                    //                 actions: [
                                    //                   TextButton(
                                    //                     child: const Text(
                                    //                       "OK",
                                    //                       style: TextStyle(
                                    //                           fontFamily:
                                    //                               productSans,
                                    //                           color: black),
                                    //                     ),
                                    //                     onPressed: () {
                                    //                       Navigator.pop(
                                    //                           dialogContext);
                                    //                     },
                                    //                   ),
                                    //                 ],
                                    //               );
                                    //             },
                                    //           );
                                    //         } else if (joinChatSessionsValue
                                    //                 .joinStatus ==
                                    //             'Customer Not Available') {
                                    //           showDialog(
                                    //             // ignore: use_build_context_synchronously
                                    //             context: context,
                                    //             builder: (BuildContext
                                    //                 dialogContext) {
                                    //               return AlertDialog(
                                    //                 title: const Text(
                                    //                   "Session Cancelled",
                                    //                   style: TextStyle(
                                    //                       fontFamily:
                                    //                           productSans),
                                    //                 ),
                                    //                 content: const Text(
                                    //                   "Your session has been cancelled due to your unavailability. ",
                                    //                   style: TextStyle(
                                    //                       fontFamily:
                                    //                           productSans),
                                    //                 ),
                                    //                 actions: [
                                    //                   TextButton(
                                    //                     child: const Text(
                                    //                       "OK",
                                    //                       style: TextStyle(
                                    //                           fontFamily:
                                    //                               productSans,
                                    //                           color: black),
                                    //                     ),
                                    //                     onPressed: () {
                                    //                       Navigator.pop(
                                    //                           dialogContext);
                                    //                     },
                                    //                   ),
                                    //                 ],
                                    //               );
                                    //             },
                                    //           );
                                    //         } else {
                                    //           Get.to(
                                    //             FirebaseChatScreen(
                                    //               chatSessionModel:
                                    //                   joinChatSessionsValue,
                                    //               senderId: int.parse(
                                    //                   mUserId.toString()),
                                    //               subCollection: 'messages',
                                    //             ),
                                    //           );
                                    //         }
                                    //       });
                                    //     });
                                    //     break;
                                    //   case 2:
                                    //     _homeController
                                    //         .joinAudioSessions(
                                    //             sessionId: _homeController
                                    //                 .commingSessionListData[
                                    //                     index]
                                    //                 .id
                                    //                 .toString())
                                    //         .then((joinAudioSessions) {
                                    //       if (joinAudioSessions.joinStatus ==
                                    //           'Completed') {
                                    //         showDialog(
                                    //           // ignore: use_build_context_synchronously
                                    //           context: context,
                                    //           builder: (BuildContext
                                    //               dialogContext) {
                                    //             return AlertDialog(
                                    //               title: const Text(
                                    //                 "Session Completed",
                                    //                 style: TextStyle(
                                    //                     fontFamily:
                                    //                         productSans),
                                    //               ),
                                    //               content: const Text(
                                    //                 "Your session has been completed successfully.",
                                    //                 style: TextStyle(
                                    //                     fontFamily:
                                    //                         productSans),
                                    //               ),
                                    //               actions: [
                                    //                 TextButton(
                                    //                   child: const Text(
                                    //                     "OK",
                                    //                     style: TextStyle(
                                    //                         fontFamily:
                                    //                             productSans,
                                    //                         color: black),
                                    //                   ),
                                    //                   onPressed: () {
                                    //                     Navigator.pop(
                                    //                         dialogContext);
                                    //                   },
                                    //                 ),
                                    //               ],
                                    //             );
                                    //           },
                                    //         );
                                    //       } else if (joinAudioSessions
                                    //               .joinStatus ==
                                    //           'Cancelled') {
                                    //         showDialog(
                                    //           // ignore: use_build_context_synchronously
                                    //           context: context,
                                    //           builder: (BuildContext
                                    //               dialogContext) {
                                    //             return AlertDialog(
                                    //               title: const Text(
                                    //                 "Session Cancelled",
                                    //                 style: TextStyle(
                                    //                     fontFamily:
                                    //                         productSans),
                                    //               ),
                                    //               content: const Text(
                                    //                 "Your session has been cancelled.",
                                    //                 style: TextStyle(
                                    //                     fontFamily:
                                    //                         productSans),
                                    //               ),
                                    //               actions: [
                                    //                 TextButton(
                                    //                   child: const Text(
                                    //                     "OK",
                                    //                     style: TextStyle(
                                    //                         fontFamily:
                                    //                             productSans,
                                    //                         color: black),
                                    //                   ),
                                    //                   onPressed: () {
                                    //                     Navigator.pop(
                                    //                         dialogContext);
                                    //                   },
                                    //                 ),
                                    //               ],
                                    //             );
                                    //           },
                                    //         );
                                    //       } else if (joinAudioSessions
                                    //               .joinStatus ==
                                    //           'Customer Not Available') {
                                    //         showDialog(
                                    //           // ignore: use_build_context_synchronously
                                    //           context: context,
                                    //           builder: (BuildContext
                                    //               dialogContext) {
                                    //             return AlertDialog(
                                    //               title: const Text(
                                    //                 "Session Cancelled",
                                    //                 style: TextStyle(
                                    //                     fontFamily:
                                    //                         productSans),
                                    //               ),
                                    //               content: const Text(
                                    //                 "Your session has been cancelled due to your unavailability. ",
                                    //                 style: TextStyle(
                                    //                     fontFamily:
                                    //                         productSans),
                                    //               ),
                                    //               actions: [
                                    //                 TextButton(
                                    //                   child: const Text(
                                    //                     "OK",
                                    //                     style: TextStyle(
                                    //                         fontFamily:
                                    //                             productSans,
                                    //                         color: black),
                                    //                   ),
                                    //                   onPressed: () {
                                    //                     Navigator.pop(
                                    //                         dialogContext);
                                    //                   },
                                    //                 ),
                                    //               ],
                                    //             );
                                    //           },
                                    //         );
                                    //       } else {
                                    //         if (joinAudioSessions
                                    //             .isFileUploaded!) {
                                    //           showAudioDialog(context,
                                    //               joinAudioSessions.file!);
                                    //         } else {
                                    //           Get.snackbar(
                                    //               "Audio",
                                    //               joinAudioSessions.message ??
                                    //                   "");
                                    //         }
                                    //       }
                                    //     });
                                    //     break;
                                    //   case 3:
                                    //     final userIdValue =
                                    //         await BasePrefs.readData(userId);
                                    //     _homeController
                                    //         .joinSessions(
                                    //             sessionId: _homeController
                                    //                 .commingSessionListData[
                                    //                     index]
                                    //                 .id!
                                    //                 .toString())
                                    //         .then((joinSessionsOnValue) {
                                    //       var re = RegExp(
                                    //           "\\w{4}\\-\\w{4}\\-\\w{4}");
                                    //       if (joinSessionsOnValue.session!
                                    //               .roomId!.isNotEmpty &&
                                    //           re.hasMatch(joinSessionsOnValue
                                    //               .session!.roomId!) &&
                                    //           joinSessionsOnValue.token !=
                                    //               null) {
                                    //         //_homeController.commingSessionListData[index].status
                                    //         if (joinSessionsOnValue
                                    //                 .joinStatus ==
                                    //             'Completed') {
                                    //           showDialog(
                                    //             // ignore: use_build_context_synchronously
                                    //             context: context,
                                    //             builder: (BuildContext
                                    //                 dialogContext) {
                                    //               return AlertDialog(
                                    //                 title: const Text(
                                    //                   "Session Completed",
                                    //                   style: TextStyle(
                                    //                       fontFamily:
                                    //                           productSans),
                                    //                 ),
                                    //                 content: const Text(
                                    //                   "Your session has been completed successfully.",
                                    //                   style: TextStyle(
                                    //                       fontFamily:
                                    //                           productSans),
                                    //                 ),
                                    //                 actions: [
                                    //                   TextButton(
                                    //                     child: const Text(
                                    //                       "OK",
                                    //                       style: TextStyle(
                                    //                           fontFamily:
                                    //                               productSans,
                                    //                           color: black),
                                    //                     ),
                                    //                     onPressed: () {
                                    //                       Navigator.pop(
                                    //                           dialogContext);
                                    //                     },
                                    //                   ),
                                    //                 ],
                                    //               );
                                    //             },
                                    //           );
                                    //         } else if (joinSessionsOnValue
                                    //                 .joinStatus ==
                                    //             'Cancelled') {
                                    //           showDialog(
                                    //             // ignore: use_build_context_synchronously
                                    //             context: context,
                                    //             builder: (BuildContext
                                    //                 dialogContext) {
                                    //               return AlertDialog(
                                    //                 title: const Text(
                                    //                   "Session Cancelled",
                                    //                   style: TextStyle(
                                    //                       fontFamily:
                                    //                           productSans),
                                    //                 ),
                                    //                 content: const Text(
                                    //                   "Your session has been cancelled.",
                                    //                   style: TextStyle(
                                    //                       fontFamily:
                                    //                           productSans),
                                    //                 ),
                                    //                 actions: [
                                    //                   TextButton(
                                    //                     child: const Text(
                                    //                       "OK",
                                    //                       style: TextStyle(
                                    //                           fontFamily:
                                    //                               productSans,
                                    //                           color: black),
                                    //                     ),
                                    //                     onPressed: () {
                                    //                       Navigator.pop(
                                    //                           dialogContext);
                                    //                     },
                                    //                   ),
                                    //                 ],
                                    //               );
                                    //             },
                                    //           );
                                    //         } else if (joinSessionsOnValue
                                    //                 .joinStatus ==
                                    //             'Customer Not Available') {
                                    //           showDialog(
                                    //             // ignore: use_build_context_synchronously
                                    //             context: context,
                                    //             builder: (BuildContext
                                    //                 dialogContext) {
                                    //               return AlertDialog(
                                    //                 title: const Text(
                                    //                   "Session Cancelled",
                                    //                   style: TextStyle(
                                    //                       fontFamily:
                                    //                           productSans),
                                    //                 ),
                                    //                 content: const Text(
                                    //                   "Your session has been cancelled due to your unavailability.",
                                    //                   style: TextStyle(
                                    //                       fontFamily:
                                    //                           productSans),
                                    //                 ),
                                    //                 actions: [
                                    //                   TextButton(
                                    //                     child: const Text(
                                    //                       "OK",
                                    //                       style: TextStyle(
                                    //                           fontFamily:
                                    //                               productSans,
                                    //                           color: black),
                                    //                     ),
                                    //                     onPressed: () {
                                    //                       Navigator.pop(
                                    //                           dialogContext);
                                    //                     },
                                    //                   ),
                                    //                 ],
                                    //               );
                                    //             },
                                    //           );
                                    //         } else {
                                    //           Get.to(CallingPage(
                                    //             callType: 0,
                                    //             joinSessionModel:
                                    //                 joinSessionsOnValue,
                                    //             userId: int.parse(
                                    //                 userIdValue.toString()),
                                    //           ));
                                    //         }
                                    //       } else {
                                    //         Get.snackbar("Calling",
                                    //             "Please enter valid meeting id");
                                    //       }
                                    //     });

                                    //     break;
                                    //   case 4:
                                    //     final userIdValue =
                                    //         await BasePrefs.readData(userId);
                                    //     _homeController
                                    //         .joinSessions(
                                    //             sessionId: _homeController
                                    //                 .commingSessionListData[
                                    //                     index]
                                    //                 .id!
                                    //                 .toString())
                                    //         .then((joinSessionsOnValue) {
                                    //       // var re =
                                    //       //     RegExp("\\w{4}\\-\\w{4}\\-\\w{4}");
                                    //       if (joinSessionsOnValue
                                    //           .session!.roomId!.isNotEmpty) {
                                    //         // _homeController.commingSessionListData[index].status
                                    //         if (joinSessionsOnValue
                                    //                 .joinStatus ==
                                    //             'Completed') {
                                    //           showDialog(
                                    //             // ignore: use_build_context_synchronously
                                    //             context: context,
                                    //             builder: (BuildContext
                                    //                 dialogContext) {
                                    //               return AlertDialog(
                                    //                 title: const Text(
                                    //                   "Session Completed",
                                    //                   style: TextStyle(
                                    //                       fontFamily:
                                    //                           productSans),
                                    //                 ),
                                    //                 content: const Text(
                                    //                   "Your session has been completed successfully.",
                                    //                   style: TextStyle(
                                    //                       fontFamily:
                                    //                           productSans),
                                    //                 ),
                                    //                 actions: [
                                    //                   TextButton(
                                    //                     child: const Text(
                                    //                       "OK",
                                    //                       style: TextStyle(
                                    //                           fontFamily:
                                    //                               productSans,
                                    //                           color: black),
                                    //                     ),
                                    //                     onPressed: () {
                                    //                       Navigator.pop(
                                    //                           dialogContext);
                                    //                     },
                                    //                   ),
                                    //                 ],
                                    //               );
                                    //             },
                                    //           );
                                    //         } else if (joinSessionsOnValue
                                    //                 .joinStatus ==
                                    //             'Cancelled') {
                                    //           showDialog(
                                    //             // ignore: use_build_context_synchronously
                                    //             context: context,
                                    //             builder: (BuildContext
                                    //                 dialogContext) {
                                    //               return AlertDialog(
                                    //                 title: const Text(
                                    //                   "Session Cancelled",
                                    //                   style: TextStyle(
                                    //                       fontFamily:
                                    //                           productSans),
                                    //                 ),
                                    //                 content: const Text(
                                    //                   "Your session has been cancelled.",
                                    //                   style: TextStyle(
                                    //                       fontFamily:
                                    //                           productSans),
                                    //                 ),
                                    //                 actions: [
                                    //                   TextButton(
                                    //                     child: const Text(
                                    //                       "OK",
                                    //                       style: TextStyle(
                                    //                           fontFamily:
                                    //                               productSans,
                                    //                           color: black),
                                    //                     ),
                                    //                     onPressed: () {
                                    //                       Navigator.pop(
                                    //                           dialogContext);
                                    //                     },
                                    //                   ),
                                    //                 ],
                                    //               );
                                    //             },
                                    //           );
                                    //         } else if (joinSessionsOnValue
                                    //                 .joinStatus ==
                                    //             'Customer Not Available') {
                                    //           showDialog(
                                    //             // ignore: use_build_context_synchronously
                                    //             context: context,
                                    //             builder: (BuildContext
                                    //                 dialogContext) {
                                    //               return AlertDialog(
                                    //                 title: const Text(
                                    //                   "Session Cancelled",
                                    //                   style: TextStyle(
                                    //                       fontFamily:
                                    //                           productSans),
                                    //                 ),
                                    //                 content: const Text(
                                    //                   "Your session has been cancelled due to your unavailability.",
                                    //                   style: TextStyle(
                                    //                       fontFamily:
                                    //                           productSans),
                                    //                 ),
                                    //                 actions: [
                                    //                   TextButton(
                                    //                     child: const Text(
                                    //                       "OK",
                                    //                       style: TextStyle(
                                    //                           fontFamily:
                                    //                               productSans,
                                    //                           color: black),
                                    //                     ),
                                    //                     onPressed: () {
                                    //                       Navigator.pop(
                                    //                           dialogContext);
                                    //                     },
                                    //                   ),
                                    //                 ],
                                    //               );
                                    //             },
                                    //           );
                                    //         } else {
                                    //           // Get.to(CallingPage(
                                    //           //   callType: int.parse(
                                    //           //       joinSessionsOnValue
                                    //           //           .session!
                                    //           //           .serviceType!),
                                    //           //   joinSessionModel:
                                    //           //       joinSessionsOnValue,
                                    //           //   userId: int.parse(
                                    //           //       userIdValue.toString()),
                                    //           // ));
                                    //         }
                                    //       } else {
                                    //         Get.snackbar("Calling",
                                    //             "Please enter valid meeting id");
                                    //       }
                                    //     });
                                    //     break;
                                    //   default:
                                    // }
                                    // }
                                  },
                                  child: sessionItemsWidget(index),
                                );
                              }
                            },
                          ),
                  ],
                ),
              );
            }
          }),
        ],
      ),
    );
  }

  bool isCurrentTimeLessThanSixPM() {
    final currentTime = DateTime.now();
    final comparisonTime = DateTime(
      currentTime.year,
      currentTime.month,
      currentTime.day,
      18,
      0,
      0,
    );

    return currentTime.isBefore(comparisonTime);
  }

  Container sessionItemsWidget(int index) {
    final sessionData = _homeController.sessionListData[index];
    // Future<bool> requestPermission() async {
    //   while (true) {
    //     //var status = await Permission.storage.request();
    //     // if (status.isGranted) {
    //     //   return true; // Permission granted
    //     // } else if (status.isPermanentlyDenied) {
    //     //  // await openAppSettings();
    //     // } else if (status.isDenied) {
    //     //   // Keep requesting until user grants permission
    //     //   continue;
    //     // }
    //   }
    // }

    Future<String> getDownloadsDirectoryPath() async {
      Directory? downloadsDirectory;
      if (Platform.isAndroid) {
        downloadsDirectory = await getExternalStorageDirectory();
        final path =
            "${downloadsDirectory!.parent.parent.parent.parent.path}/Download";
        return path;
      } else if (Platform.isIOS) {
        downloadsDirectory = await getApplicationDocumentsDirectory();
        return downloadsDirectory.path;
      }
      throw Exception("Unsupported platform");
    }

    Future<void> showDownloadDialog(
      BuildContext context,
      String url,
      String sessionId,
    ) async {
      double progress = 0;

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return AlertDialog(
            title: const Text("Downloading"),
            content: StatefulBuilder(
              builder: (BuildContext context, StateSetter setState) {
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    LinearProgressIndicator(value: progress),
                    const SizedBox(height: 20),
                    Text("${(progress * 100).toStringAsFixed(0)}% downloaded"),
                  ],
                );
              },
            ),
          );
        },
      );

      try {
        final dio = Dio();
        final downloadsDirectoryPath = await getDownloadsDirectoryPath();
        final filePath = "$downloadsDirectoryPath/${sessionId}_audio.mp3";

        await dio.download(
          url,
          filePath,
          onReceiveProgress: (received, total) {
            if (total != -1) {
              final currentProgress = received / total;
              // Update the progress in the dialog
              (context as Element).markNeedsBuild();
              setState(() {
                progress = currentProgress;
              });
            }
          },
        );

        // ignore: use_build_context_synchronously
        Navigator.of(context).pop(); // Close the dialog after download
        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Download completed: $filePath")),
        );
      } catch (e) {
        // ignore: use_build_context_synchronously
        Navigator.of(context).pop(); // Close the dialog on error
        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Error downloading audio: $e")));
      }
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: textLightColorThersery),
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image Container
              Padding(
                padding: const EdgeInsets.only(top: 5),
                child: Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(32),
                    color: textLightColorSecondary,
                  ),
                  clipBehavior: Clip.hardEdge,
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Image.network(
                      sessionData.serviceType?.image ?? "",
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) {
                        return const Icon(Icons.image, color: Colors.black);
                      },
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10), // Space between image and text content
              // Text Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    text(
                      sessionData.astrologerName ?? "",
                      fontSize: 16.0,
                      fontWeight: FontWeight.w600,
                      textColor: white,
                    ),
                    const SizedBox(height: 4),
                    text(
                      sessionData.serviceName ?? "",
                      fontSize: 14.0,
                      fontWeight: FontWeight.w500,
                      textColor: white,
                    ),
                    const SizedBox(height: 4),
                    text(
                      "Start at: ${sessionData.startTime ?? "NA"}",
                      fontSize: 12.0,
                      fontWeight: FontWeight.w400,
                      textColor: white,
                    ),
                    const SizedBox(height: 4),
                    GestureDetector(
                      onTap: () async {
                        // try {
                        //   final userIdValue = await BasePrefs.readData(userId);
                        //   final supportData =
                        //       await _homeController.getSupportChatModelData(
                        //     customerId: userIdValue.toString(),
                        //   );
                        //   Get.to(SecondryTopNavBar(
                        //     title: "Help",
                        //     isAction: true,
                        //     widget: SupportChatScreen(
                        //       reciverId: supportData.supportId!,
                        //       roomId: supportData.roomId!,
                        //       senderId: int.parse(userIdValue),
                        //       subCollection: "messages",
                        //     ),
                        //   ));
                        // } catch (error) {
                        //   debugPrint(
                        //       "Error navigating to support chat: $error");
                        // }
                      },
                      child: text(
                        "Need Help?",
                        fontSize: 12.0,
                        fontWeight: FontWeight.w500,
                        textColor: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),

              // Status and Session Type
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  text(
                    sessionData.status ?? "",
                    fontSize: 11.0,
                    fontWeight: FontWeight.w500,
                    textColor: white,
                  ),
                  const SizedBox(height: 55),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF221d25),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: text(
                      sessionData.serviceType!.name ?? "",
                      fontSize: 12.0,
                      fontWeight: FontWeight.w500,
                      textColor: Colors.white,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 15),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GestureDetector(
                onTap: () async {
                  // bool hasPermission = await requestPermission();
                  // if (hasPermission) {
                  //   if (context.mounted) {
                  //     // await showDownloadDialog(
                  //     //     context, sessionData.audioFile, sessionData.id);
                  //     showAudioDialog(context, sessionData.audioFile);
                  //   }
                  // } else {
                  //   if (context.mounted) {
                  //     ScaffoldMessenger.of(context).showSnackBar(
                  //       const SnackBar(
                  //           content: Text("Storage permission denied.")),
                  //     );
                  //   }
                  // }
                  // showAudioDialog(context, sessionData.audioFile);

                  // _homeController
                  //     .joinAudioSessions(
                  //         sessionId: _homeController
                  //             .commingSessionListData[index].id
                  //             .toString())
                  //     .then((onValue) {
                  //   if (onValue.isFileUploaded!) {
                  //     // (FileViewer(
                  //     //   fileType: "audio",
                  //     //   fileUrl: onValue.file!,
                  //     // ));
                  //   //  showAudioDialog(context, onValue.file!);
                  //   } else {
                  //     Get.snackbar("Audio", onValue.message ?? "");
                  //   }
                  // });
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFF221d25),
                    border: Border.all(color: const Color(0xFF221d25)),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Padding(
                    padding: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                    child: Center(
                      child: Text(
                        "Play Recording",
                        style: TextStyle(
                          fontFamily: productSans,
                          fontSize: 12,
                          color: white,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              GestureDetector(
                onTap: () {
                  showRecommendedProductSheet(context);
                  // Navigator.push(
                  //   context,
                  //   MaterialPageRoute(
                  //     builder: (context) => StoreTab(
                  //       onPush: widget.onPush,
                  //       isFromOther: true,
                  //     ),
                  //   ),
                  // );
                },
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: const Color(0xFF221d25)),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Padding(
                    padding: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                    child: Center(
                      child: Text(
                        "Recommended Product",
                        style: TextStyle(
                          fontFamily: productSans,
                          fontSize: 12,
                          color: white,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void showRecommendedProductSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(10)),
      ),
      builder: (BuildContext context) {
        return Container(
          decoration: const BoxDecoration(
            color: white,
            borderRadius: BorderRadius.only(
              topRight: Radius.circular(10),
              topLeft: Radius.circular(10),
            ),
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "Recommended Products",
                style: TextStyle(
                  fontFamily: productSans,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 400, // Define a height for the list
                child: ListView.builder(
                  itemCount: 4,
                  itemBuilder: (context, index) {
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: white,
                        border: Border.all(color: black),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                // Image Section
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: Container(
                                    height: 50,
                                    width: 50,
                                    color: Colors.grey[200],
                                    child: const Icon(
                                      Icons.image_not_supported,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    text(
                                      "Unknown Product",
                                      fontSize: 14.0,
                                      fontFamily: productSans,
                                      fontWeight: FontWeight.w600,
                                    ),

                                    // const SizedBox(height: 6),
                                    // text(
                                    //   "₹${product.price ?? "0.00"}",
                                    //   textColor: black,
                                    //   fontSize: 12.0,
                                    //   fontFamily: productSans,
                                    //   fontWeight: FontWeight.w500,
                                    // ),
                                    Row(
                                      children: [
                                        text(
                                          "01",
                                          textColor: black,
                                          fontSize: 12.0,
                                          fontFamily: productSans,
                                          fontWeight: FontWeight.w500,
                                        ),
                                        const SizedBox(width: 5),
                                        text(
                                          "00",
                                          textColor: Colors.grey,
                                          lineThrough: true,
                                          fontSize: 12.0,
                                          fontFamily: productSans,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            GestureDetector(
                              onTap: () {
                                // changeScreen(
                                //   context,
                                //   ProductDetailsScreen(
                                //     productData: product,
                                //   ),
                                // );
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: black,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: text(
                                  "Buy",
                                  fontSize: 12.0,
                                  fontFamily: productSans,
                                  fontWeight: FontWeight.w500,
                                  textColor: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  String typeCall(int type) {
    switch (type) {
      case 1:
        return 'Chat';
      case 2:
        return 'Recording';
      case 3:
        return 'Audio';
      case 4:
        return 'Video';
      default:
        return '';
    }
  }

  dynamic formatDateTime(dynamic date, dynamic startTime, dynamic serviceType) {
    try {
      if (serviceType == "2") {
        // Only show the date if serviceType is "2"
        DateTime dateTime = DateTime.parse(date);
        return DateFormat('d MMM, yyyy').format(dateTime).toLowerCase();
      } else {
        // Combine the date and time into a single string
        String dateTimeString = "$date $startTime";

        // Parse the combined string into a DateTime object
        DateTime dateTime = DateTime.parse(dateTimeString);

        // Format the date and time into the desired output format
        return DateFormat('d MMM, yyyy h:mma').format(dateTime).toLowerCase();
      }
    } catch (e) {
      // Handle the exception gracefully
      return 'Invalid date format';
    }
  }
}
