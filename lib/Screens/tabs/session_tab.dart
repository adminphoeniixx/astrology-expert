import 'dart:io';

import 'package:astro_partner_app/constants/colors_const.dart';
import 'package:astro_partner_app/constants/fonts_const.dart';
import 'package:astro_partner_app/constants/images_const.dart';
import 'package:astro_partner_app/constants/string_const.dart';
import 'package:astro_partner_app/controllers/home_controller.dart';
import 'package:astro_partner_app/helper/local_storage.dart';
import 'package:astro_partner_app/model/product_list_model.dart';
import 'package:astro_partner_app/model/session_details_model.dart';
import 'package:astro_partner_app/services/web_request_constants.dart';
import 'package:astro_partner_app/widgets/agora_video_calling/audio_call_page.dart';
import 'package:astro_partner_app/widgets/agora_video_calling/calling.dart';
import 'package:astro_partner_app/widgets/app_widget.dart';
import 'package:astro_partner_app/widgets/firebase_chat_widget/firebase_chat_screen.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
// ignore: depend_on_referenced_packages
import 'package:path_provider/path_provider.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';

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
  Future<bool> requestPermission() async {
    var status = await Permission.storage.request();
    return status.isGranted;
  }

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
                                    print(
                                      _homeController
                                          .sessionListData[index]
                                          .serviceType!
                                          .id,
                                    );
                                    switch (_homeController
                                        .sessionListData[index]
                                        .serviceType!
                                        .id) {
                                      case 1:
                                        Get.to(
                                          const FirebaseChatScreen(
                                            reciverId: 1,
                                            roomId: "chat_expertId_userId",
                                            senderId: 2,
                                            subCollection: 'messages',
                                          ),
                                        );

                                      case 2:
                                        Get.to(
                                          const CallingFreePage(
                                            remaingTime: 1,
                                            appId: "",
                                            callType: 0,
                                            channel: "",
                                            token: "",
                                            userId: 2,
                                            userImageUrl: "",
                                            userName: "",
                                          ),
                                        );
                                      case 3:
                                        Get.to(
                                          const CallingFreePage(
                                            remaingTime: 1,
                                            appId: "",
                                            callType: 1,
                                            channel: "",
                                            token: "",
                                            userId: 2,
                                            userImageUrl: "",
                                            userName: "",
                                          ),
                                        );
                                        // _homeController
                                        //     .joinChatSessions(
                                        //       sessionId: _homeController
                                        //           .commingSessionListData[index]
                                        //           .id
                                        //           .toString(),
                                        //     )
                                        //     .then((
                                        //       joinChatSessionsValue,
                                        //     ) async {
                                        //       BasePrefs.readData(userId).then((
                                        //         mUserId,
                                        //       ) {
                                        //         //_homeController.commingSessionListData[index].status
                                        //         if (joinChatSessionsValue
                                        //                 .joinStatus ==
                                        //             'Completed') {
                                        //           showDialog(
                                        //             // ignore: use_build_context_synchronously
                                        //             context: context,
                                        //             builder: (BuildContext dialogContext) {
                                        //               return AlertDialog(
                                        //                 title: const Text(
                                        //                   "Session Completed",
                                        //                   style: TextStyle(
                                        //                     fontFamily:
                                        //                         productSans,
                                        //                   ),
                                        //                 ),
                                        //                 content: const Text(
                                        //                   "Your session has been completed successfully.",
                                        //                   style: TextStyle(
                                        //                     fontFamily:
                                        //                         productSans,
                                        //                   ),
                                        //                 ),
                                        //                 actions: [
                                        //                   TextButton(
                                        //                     child: const Text(
                                        //                       "OK",
                                        //                       style: TextStyle(
                                        //                         fontFamily:
                                        //                             productSans,
                                        //                         color: black,
                                        //                       ),
                                        //                     ),
                                        //                     onPressed: () {
                                        //                       Navigator.pop(
                                        //                         dialogContext,
                                        //                       );
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
                                        //             builder: (BuildContext dialogContext) {
                                        //               return AlertDialog(
                                        //                 title: const Text(
                                        //                   "Session Cancelled",
                                        //                   style: TextStyle(
                                        //                     fontFamily:
                                        //                         productSans,
                                        //                   ),
                                        //                 ),
                                        //                 content: const Text(
                                        //                   "Your session has been cancelled.",
                                        //                   style: TextStyle(
                                        //                     fontFamily:
                                        //                         productSans,
                                        //                   ),
                                        //                 ),
                                        //                 actions: [
                                        //                   TextButton(
                                        //                     child: const Text(
                                        //                       "OK",
                                        //                       style: TextStyle(
                                        //                         fontFamily:
                                        //                             productSans,
                                        //                         color: black,
                                        //                       ),
                                        //                     ),
                                        //                     onPressed: () {
                                        //                       Navigator.pop(
                                        //                         dialogContext,
                                        //                       );
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
                                        //             builder: (BuildContext dialogContext) {
                                        //               return AlertDialog(
                                        //                 title: const Text(
                                        //                   "Session Cancelled",
                                        //                   style: TextStyle(
                                        //                     fontFamily:
                                        //                         productSans,
                                        //                   ),
                                        //                 ),
                                        //                 content: const Text(
                                        //                   "Your session has been cancelled due to your unavailability. ",
                                        //                   style: TextStyle(
                                        //                     fontFamily:
                                        //                         productSans,
                                        //                   ),
                                        //                 ),
                                        //                 actions: [
                                        //                   TextButton(
                                        //                     child: const Text(
                                        //                       "OK",
                                        //                       style: TextStyle(
                                        //                         fontFamily:
                                        //                             productSans,
                                        //                         color: black,
                                        //                       ),
                                        //                     ),
                                        //                     onPressed: () {
                                        //                       Navigator.pop(
                                        //                         dialogContext,
                                        //                       );
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
                                        //                 mUserId.toString(),
                                        //               ),
                                        //               subCollection: 'messages',
                                        //             ),
                                        //           );
                                        //         }
                                        //       });
                                        //     });
                                        break;
                                      default:
                                    }
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
              sessionData.serviceType!.name != "Audio Recording"
                  ? const SizedBox()
                  : GestureDetector(
                      onTap: () async {
                        var granted = await requestStoragePermission(context);
                        if (!granted) return; // Exit agar permission nahi mili

                        FilePickerResult? result = await FilePicker.platform
                            .pickFiles(
                              type: FileType.custom,
                              allowedExtensions: ["mp3", "wav", "m4a"],
                            );

                        if (result == null) {
                          return; // user ne cancel kar diya
                        }

                        File file = File(result.files.single.path!);

                        // var response = await _homeController.joinAudioSessions(
                        //   sessionId: sessionData.id.toString(),
                        //   file: file,
                        // );

                        // if (response.isFileUploaded == true) {
                        //   if (context.mounted) {
                        //     showAudioDialog(
                        //       context,
                        //       response.file!, // uploaded audio ka URL
                        //     );
                        //   }
                        // } else {
                        //   if (context.mounted) {
                        //     Get.snackbar(
                        //       "Audio",
                        //       response.message ?? "Upload failed",
                        //     );
                        //   }
                        // }
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFF221d25),
                          border: Border.all(color: const Color(0xFF221d25)),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Padding(
                          padding: EdgeInsets.symmetric(
                            vertical: 4,
                            horizontal: 8,
                          ),
                          child: Center(
                            child: Text(
                              "Upload Recording",
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
                onTap: () async {
                  await _homeController
                      .fetchProductListModeData(
                        sessionId: sessionData.orderId.toString(),
                      )
                      .then((value) {
                        showRecommendedProductSheet(
                          context,
                          value.data!.products!,
                          sessionData.orderId.toString(),
                        );
                      });
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
          const SizedBox(height: 10),

          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GestureDetector(
                onTap: () async {
                  await _homeController
                      .fetchSessionDetailsData(
                        sessionId: sessionData.orderId.toString(),
                      )
                      .then((value) {
                        showSessionDetailSheet(context, value.data!.details!);
                      });
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: primaryColor,
                    //  border: Border.all(color: const Color(0xFF221d25)),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Padding(
                    padding: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                    child: Center(
                      child: Text(
                        "Seassion Details",
                        style: TextStyle(
                          fontFamily: productSans,
                          fontSize: 12,
                          color: black,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              GestureDetector(
                onTap: () {
                  _showUpdateNoteDialog(context, sessionData.id.toString());
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: primaryColor,
                    //  border: Border.all(color: const Color(0xFF221d25)),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Padding(
                    padding: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                    child: Center(
                      child: Text(
                        "Upate Note",
                        style: TextStyle(
                          fontFamily: productSans,
                          fontSize: 12,
                          color: black,
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

  Future<bool> requestStoragePermission(BuildContext context) async {
    if (await Permission.storage.isGranted) {
      return true;
    }

    // For Android 11+ (Scoped Storage)
    if (await Permission.manageExternalStorage.request().isGranted) {
      return true;
    }

    // Agar phir bhi deny hua
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Storage permission denied. Please allow in settings."),
        ),
      );
    }

    return false;
  }

  Future<void> showAudioDialog(BuildContext context, String audioUrl) async {
    final player = AudioPlayer();

    try {
      await player.setSourceUrl(audioUrl); // ✅ audioplayers API
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to load audio: $e')));
      return;
    }

    Duration total = Duration.zero;
    Duration position = Duration.zero;

    final durationSub = player.onDurationChanged.listen((d) => total = d);
    final positionSub = player.onPositionChanged.listen((p) => position = p);

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (sheetCtx) {
        return StatefulBuilder(
          builder: (sheetCtx, setState) {
            final posStream = player.onPositionChanged.listen((p) {
              position = p;
              setState(() {});
            });
            final durStream = player.onDurationChanged.listen((d) {
              total = d;
              setState(() {});
            });
            final stateStream = player.onPlayerStateChanged.listen((_) {
              setState(() {});
            });

            void cleanupInner() {
              posStream.cancel();
              durStream.cancel();
              stateStream.cancel();
            }

            // dispose inner listeners when the sheet is popped
            Future.microtask(() {
              if (!sheetCtx.mounted) cleanupInner();
            });

            final isPlaying = player.state == PlayerState.playing;

            String fmt(Duration d) {
              String two(int n) => n.toString().padLeft(2, '0');
              final h = d.inHours,
                  m = d.inMinutes.remainder(60),
                  s = d.inSeconds.remainder(60);
              return h > 0
                  ? '${two(h)}:${two(m)}:${two(s)}'
                  : '${two(m)}:${two(s)}';
            }

            final maxMs = (total.inMilliseconds <= 0)
                ? 1.0
                : total.inMilliseconds.toDouble();
            final valMs = position.inMilliseconds
                .clamp(0, total.inMilliseconds > 0 ? total.inMilliseconds : 1)
                .toDouble();

            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Audio Preview',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Text(fmt(position)),
                        Expanded(
                          child: Slider(
                            value: valMs,
                            min: 0,
                            max: maxMs,
                            onChanged: (v) =>
                                player.seek(Duration(milliseconds: v.toInt())),
                          ),
                        ),
                        Text(fmt(total)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        IconButton(
                          onPressed: () async {
                            await player.seek(Duration.zero);
                            await player.pause();
                          },
                          icon: const Icon(Icons.stop),
                        ),
                        const SizedBox(width: 16),
                        ElevatedButton.icon(
                          onPressed: () async {
                            if (isPlaying) {
                              await player.pause();
                            } else {
                              await player.resume();
                            }
                            setState(() {});
                          },
                          icon: Icon(
                            isPlaying ? Icons.pause : Icons.play_arrow,
                          ),
                          label: Text(isPlaying ? 'Pause' : 'Play'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );

    // Cleanup after the sheet closes
    await player.stop();
    await player.release();
    await player.dispose();
    await durationSub.cancel();
    await positionSub.cancel();
  }

  void _showUpdateNoteDialog(BuildContext context, String sessionId) async {
    final TextEditingController noteController = TextEditingController();

    final noteResult = await _homeController.fetchGetNoteData(
      sessionId: sessionId,
    );

    noteController.text = noteResult.data!.notes ?? "";

    showDialog(
      // ignore: use_build_context_synchronously
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF221d25),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          title: const Text(
            "Update Note",
            style: TextStyle(
              fontFamily: productSans,
              fontSize: 16,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: TextField(
            controller: noteController,
            maxLines: 5,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: "Enter your note here...",
              hintStyle: const TextStyle(
                color: Colors.white54,
                fontFamily: productSans,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              filled: true,
              fillColor: const Color(0xFF2c2732),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text(
                "Cancel",
                style: TextStyle(color: Colors.red, fontFamily: productSans),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: () async {
                String note = noteController.text.trim();
                if (note.isNotEmpty) {
                  final result = await _homeController.fetchUpdateNoteData(
                    sessionId: sessionId,
                    notes: note,
                  );

                  // ignore: use_build_context_synchronously
                  Navigator.pop(context);

                  if (result.success == true) {
                    Get.snackbar(
                      "Success",
                      result.message ?? "Note updated successfully!",
                      snackPosition: SnackPosition.BOTTOM,
                      backgroundColor: Colors.green,
                      colorText: Colors.white,
                    );
                  } else {
                    Get.snackbar(
                      "Failed",
                      result.message ?? "Something went wrong!",
                      snackPosition: SnackPosition.BOTTOM,
                      backgroundColor: Colors.red,
                      colorText: Colors.white,
                    );
                  }
                }
              },
              child: const Text(
                "Update",
                style: TextStyle(color: black, fontFamily: productSans),
              ),
            ),
          ],
        );
      },
    );
  }

  String formatDate(DateTime? date) {
    if (date == null) return "-";
    return DateFormat("yyyy-MM-dd").format(date);
  }

  void showSessionDetailSheet(BuildContext context, SessionDetails details) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(10)),
      ),
      builder: (BuildContext context) {
        return Container(
          decoration: const BoxDecoration(
            color: Color(0xFF221d25),
            border: Border(top: BorderSide(color: Color(0xFF221d25))),
            borderRadius: BorderRadius.only(
              topRight: Radius.circular(10),
              topLeft: Radius.circular(10),
            ),
          ),
          padding: const EdgeInsets.all(16),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Center(
                  child: Text(
                    "Session Details",
                    style: TextStyle(
                      fontFamily: productSans,
                      fontSize: 18,
                      color: white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Order info
                _detailRow("Order ID:", details.orderId?.toString() ?? ""),
                _detailRow("Order Date:", formatDate(details.date)),
                _detailRow("Session Time:", details.consultationTime ?? "NA"),

                const Divider(color: Colors.white30, height: 30),

                // Customer info
                _detailRow("Customer Name:", details.fullName ?? ""),
                _detailRow("Customer Gender:", ""),
                _detailRow("Date Of Birth:", formatDate(details.dateOfBirth)),
                _detailRow("Birth Time:", details.birthTime ?? ""),
                _detailRow(
                  "Birth Date Accuracy:",
                  details.birthTimeAccuracy ?? "",
                ),
                _detailRow("Place Of Birth:", details.placeOfBirth ?? ""),
                const SizedBox(height: 50),
              ],
            ),
          ),
        );
      },
    );
  }

  /// Reusable widget: one detail per line
  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontFamily: productSans,
              fontSize: 14,
              color: Colors.white70,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontFamily: productSans,
                fontSize: 14,
                color: white,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void showRecommendedProductSheet(
    BuildContext context,
    List<Product> products,
    String sessionId,
  ) {
    // ✅ Start me hi recommended products ko select kar lo
    Set<int> selectedIndexes = {
      for (int i = 0; i < products.length; i++)
        if (products[i].isSelected == true) i,
    };

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(10)),
      ),
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Container(
              decoration: const BoxDecoration(
                color: black,
                border: Border(top: BorderSide(color: primaryColor)),
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
                      color: white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Product list
                  SizedBox(
                    height: 400,
                    child: ListView.builder(
                      itemCount: products.length,
                      itemBuilder: (context, index) {
                        final product = products[index];
                        final isSelected = selectedIndexes.contains(index);

                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              if (isSelected) {
                                selectedIndexes.remove(index);
                              } else {
                                selectedIndexes.add(index);
                              }
                            });
                          },
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              color: const Color(0xFF221d25),
                              border: Border.all(
                                color: isSelected
                                    ? primaryColor
                                    : const Color(0xFF221d25),
                              ),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(10.0),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      text(
                                        product.name ?? "",
                                        fontSize: 14.0,
                                        fontFamily: productSans,
                                        textColor: white,
                                        fontWeight: FontWeight.w600,
                                      ),
                                      const SizedBox(height: 6),
                                      text(
                                        "₹${product.sellingPrice ?? ""}",
                                        textColor: white,
                                        fontSize: 12.0,
                                        fontFamily: productSans,
                                        fontWeight: FontWeight.w500,
                                      ),
                                      text(
                                        "₹${product.price ?? ""}",
                                        textColor: Colors.grey,
                                        lineThrough: true,
                                        fontSize: 12.0,
                                        fontFamily: productSans,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ],
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: isSelected
                                          ? primaryColor
                                          : Colors.grey,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: text(
                                      isSelected
                                          ? "Recommended"
                                          : "Not Recommended",
                                      fontSize: 12.0,
                                      fontFamily: productSans,
                                      fontWeight: FontWeight.w500,
                                      textColor: black,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Recommend button
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      minimumSize: const Size(double.infinity, 50),
                    ),
                    onPressed: selectedIndexes.isEmpty
                        ? null
                        : () async {
                            final selectedIds = selectedIndexes
                                .map((i) => products[i].id!)
                                .toList();

                            bool success = await _homeController
                                .fetchRecommendProductModelData(
                                  sessionId: sessionId,
                                  productIds: selectedIds,
                                );

                            if (success) {
                              setState(() {
                                for (var i in selectedIndexes) {
                                  products[i].isSelected = true;
                                }
                              });
                              Navigator.pop(context);
                            }
                          },
                    child: const Text(
                      "Recommend Selected",
                      style: TextStyle(
                        color: black,
                        fontSize: 14,
                        fontFamily: productSans,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
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
