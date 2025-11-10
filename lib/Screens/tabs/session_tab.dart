import 'package:astro_partner_app/constants/colors_const.dart';
import 'package:astro_partner_app/constants/fonts_const.dart';
import 'package:astro_partner_app/constants/images_const.dart';
import 'package:astro_partner_app/controllers/home_controller.dart';
import 'package:astro_partner_app/model/product_list_model.dart';
import 'package:astro_partner_app/model/session_details_model.dart';
import 'package:astro_partner_app/services/web_request_constants.dart';
import 'package:astro_partner_app/widgets/app_widget.dart';
import 'package:astro_partner_app/widgets/firebase_chat_widget/firebase_chat_screen.dart';
import 'package:astro_partner_app/widgets/socket_service.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
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
    "Live Chat Consultation": "1",
    // "Audio Recording": "2",
    "Call Consultation": "3",
    // "Video Consultation": "4",
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
              return RefreshIndicator(
                color: primaryColor,
                backgroundColor: Colors.black,
                onRefresh: _refreshSessionData,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  controller: _scrollmainController,
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
                                        "@@@@@@@@@@@@@@@@serviceType@@@@@@@@@@@@@@@@@@@@@@@",
                                      );
                                      print(
                                        _homeController
                                            .sessionListData[index]
                                            .serviceType!,
                                      );
                                      print(
                                        "@@@@@@@@@@@@@@@@serviceType@@@@@@@@@@@@@@@@@@@@@@@",
                                      );

                                      switch (_homeController
                                          .sessionListData[index]
                                          .serviceType!) {
                                        case 1:
                                          _showLoader(); // Show loader before starting calls

                                          final sessionId = _homeController
                                              .sessionListData[index]
                                              .id!;
                                          final session = _homeController
                                              .sessionListData[index];

                                          final value = await _homeController
                                              .fetchSessionChatModelData(
                                                sessionId: sessionId,
                                              );

                                          final socketDetails =
                                              await _homeController
                                                  .socketDetailsModelData();

                                          final socketVerify =
                                              await _homeController
                                                  .socketVerifyModelData(
                                                    socketId: "1234.5678",
                                                    channelName:
                                                        value.session?.roomId
                                                            ?.toString() ??
                                                        "",
                                                  );

                                          await SocketService().connect(
                                            appKey:
                                                socketDetails.soketi?.key ?? "",
                                            authEndpoint: Uri.parse(
                                              "https://vedamroots.com/api/pusher/auth",
                                            ),
                                            bearerToken:
                                                socketVerify.auth ?? "",
                                            host:
                                                socketDetails.soketi?.host ??
                                                "",
                                            port:
                                                int.tryParse(
                                                  socketDetails.soketi?.port ??
                                                      "0",
                                                ) ??
                                                0,
                                            roomId:
                                                value.session?.roomId
                                                    ?.toString() ??
                                                "",
                                            useTLS: false,
                                          );

                                          Navigator.pop(context); // Hide loader

                                          // Navigate to chat screen
                                          Get.to(
                                            FirebaseChatScreen(
                                              sessionId: sessionId,
                                              startTime:
                                                  session.startTime ?? "",
                                              sessionStatus:
                                                  session.status ?? "",
                                              customerName:
                                                  value.session?.customerName ??
                                                  "",
                                              remaingTime:
                                                  value
                                                      .pricing
                                                      ?.remainingSeconds
                                                      ?.toString() ??
                                                  "0",
                                              reciverId:
                                                  int.tryParse(
                                                    value.session?.customerId
                                                            ?.toString() ??
                                                        "0",
                                                  ) ??
                                                  0,
                                              senderId:
                                                  int.tryParse(
                                                    value.session?.expertId
                                                            ?.toString() ??
                                                        "0",
                                                  ) ??
                                                  0,
                                              roomId:
                                                  value.session?.roomId
                                                      ?.toString() ??
                                                  "",
                                              subCollection: 'messages',
                                            ),
                                          );
                                          break;
                                      }
                                    },
                                    child: sessionItemsWidget(index),
                                  );
                                }
                              },
                            ),
                    ],
                  ),
                ),
              );
            }
          }),
        ],
      ),
    );
  }

  void _showLoader() {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) => Center(child: circularProgress()),
    );
  }

  Future<void> _refreshSessionData() async {
    final type = serviceTypes[_selectedFilter.value] ?? "all";
    await _homeController.fetchSessionData(serviceType: type);
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

    // Future<String> getDownloadsDirectoryPath() async {
    //   Directory? downloadsDirectory;
    //   if (Platform.isAndroid) {
    //     downloadsDirectory = await getExternalStorageDirectory();
    //     final path =
    //         "${downloadsDirectory!.parent.parent.parent.parent.path}/Download";
    //     return path;
    //   } else if (Platform.isIOS) {
    //     downloadsDirectory = await getApplicationDocumentsDirectory();
    //     return downloadsDirectory.path;
    //   }
    //   throw Exception("Unsupported platform");
    // }

    // Future<void> showDownloadDialog(
    //   BuildContext context,
    //   String url,
    //   String sessionId,
    // ) async {
    //   double progress = 0;

    //   showDialog(
    //     context: context,
    //     barrierDismissible: false,
    //     builder: (context) {
    //       return AlertDialog(
    //         title: const Text("Downloading"),
    //         content: StatefulBuilder(
    //           builder: (BuildContext context, StateSetter setState) {
    //             return Column(
    //               mainAxisSize: MainAxisSize.min,
    //               children: [
    //                 LinearProgressIndicator(value: progress),
    //                 const SizedBox(height: 20),
    //                 Text("${(progress * 100).toStringAsFixed(0)}% downloaded"),
    //               ],
    //             );
    //           },
    //         ),
    //       );
    //     },
    //   );

    //   try {
    //     final dio = Dio();
    //     final downloadsDirectoryPath = await getDownloadsDirectoryPath();
    //     final filePath = "$downloadsDirectoryPath/${sessionId}_audio.mp3";

    //     await dio.download(
    //       url,
    //       filePath,
    //       onReceiveProgress: (received, total) {
    //         if (total != -1) {
    //           final currentProgress = received / total;
    //           // Update the progress in the dialog
    //           (context as Element).markNeedsBuild();
    //           setState(() {
    //             progress = currentProgress;
    //           });
    //         }
    //       },
    //     );

    //     // ignore: use_build_context_synchronously
    //     Navigator.of(context).pop(); // Close the dialog after download
    //     // ignore: use_build_context_synchronously
    //     ScaffoldMessenger.of(context).showSnackBar(
    //       SnackBar(content: Text("Download completed: $filePath")),
    //     );
    //   } catch (e) {
    //     // ignore: use_build_context_synchronously
    //     Navigator.of(context).pop(); // Close the dialog on error
    //     // ignore: use_build_context_synchronously
    //     ScaffoldMessenger.of(
    //       context,
    //     ).showSnackBar(SnackBar(content: Text("Error downloading audio: $e")));
    //   }
    // }

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
                child: SizedBox(
                  height: 70,
                  width: 70,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.asset(launchImage, fit: BoxFit.fill),
                  ),
                ),

                //  Container(
                //   width: 70,
                //   height: 70,
                //   decoration: const BoxDecoration(
                //   //  shape: BoxShape.circle, // 👈 makes it circular
                //     color: textLightColorSecondary,
                //   ),
                //   clipBehavior: Clip.hardEdge,
                //   child: Image.network(
                //     sessionData.astrologerImage ?? "",
                //     fit: BoxFit.cover, // 👈 keeps the aspect ratio intact
                //     errorBuilder: (context, error, stackTrace) {
                //       return const Icon(Icons.image, color: Colors.black);
                //     },
                //   ),
                // ),
              ),
              const SizedBox(width: 10), // Space between image and text content
              // Text Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 4),
                    text(
                      sessionData.customerName ?? "NA",
                      fontSize: 16.0,
                      fontWeight: FontWeight.w600,
                      textColor: white,
                    ),

                    const SizedBox(height: 4),
                    text(
                      "Date : ${formatDate(sessionData.date)}",
                      fontSize: 12.0,
                      fontWeight: FontWeight.w400,
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
                    text(
                      "End at: ${sessionData.endTime ?? "NA"}",
                      fontSize: 12.0,
                      fontWeight: FontWeight.w400,
                      textColor: white,
                    ),
                    const SizedBox(height: 4),

                    // GestureDetector(
                    //   onTap: () async {
                    //     // try {
                    //     //   final userIdValue = await BasePrefs.readData(userId);
                    //     //   final supportData =
                    //     //       await _homeController.getSupportChatModelData(
                    //     //     customerId: userIdValue.toString(),
                    //     //   );
                    //     //   Get.to(SecondryTopNavBar(
                    //     //     title: "Help",
                    //     //     isAction: true,
                    //     //     widget: SupportChatScreen(
                    //     //       reciverId: supportData.supportId!,
                    //     //       roomId: supportData.roomId!,
                    //     //       senderId: int.parse(userIdValue),
                    //     //       subCollection: "messages",
                    //     //     ),
                    //     //   ));
                    //     // } catch (error) {
                    //     //   debugPrint(
                    //     //       "Error navigating to support chat: $error");
                    //     // }
                    //   },
                    //   child: text(
                    //     "Need Help?",
                    //     fontSize: 12.0,
                    //     fontWeight: FontWeight.w500,
                    //     textColor: Colors.white,
                    //   ),
                    // ),
                  ],
                ),
              ),

              // Status and Session Type
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: getStatusColor(sessionData.status ?? ""),
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: text(
                      sessionData.status ?? "",
                      fontSize: 11.0,
                      fontWeight: FontWeight.w500,
                      textColor: getStatusColor(sessionData.status ?? ""),
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
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  border: Border.all(color: const Color(0xFF221d25)),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: text(
                  sessionData.serviceName ?? "",
                  fontSize: 12.0,
                  fontWeight: FontWeight.w500,
                  textColor: Colors.white,
                ),
              ),
              sessionData.serviceName != "Audio Recording"
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

                        // File file = File(result.files.single.path!);

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
                  final response = await _homeController
                      .fetchProductListModeData(
                        sessionId: sessionData.id.toString(),
                      );

                  // Check if API returned data successfully
                  if (response.data != null &&
                      response.data!.products != null &&
                      response.data!.products!.isNotEmpty) {
                    showRecommendedProductSheet(
                      context,
                      response.data!.products!,
                      sessionData.id.toString(),
                    );
                  } else {
                    // Handle empty or invalid data
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: text(
                          "No products available right now.",
                          fontFamily: productSans,
                          textColor: white,
                        ),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
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
                        sessionId: sessionData.id.toString(),
                      )
                      .then((value) {
                        if (value.success == true && value.data != null) {
                          showSessionDetailSheet(
                            context,
                            value.data!.session!,
                            value.data!.user!,
                          );
                        } else {
                          Get.snackbar(
                            'Data Not Found',
                            'Customer details could not be loaded.',
                            snackPosition: SnackPosition.TOP,
                            backgroundColor: Colors.redAccent,
                            colorText: Colors.white,
                            duration: const Duration(seconds: 2),
                          );
                        }
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
                        "Customer Details",
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
                  _showUpdateNoteDialog(context, sessionData.id!);
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
                        "Update Note",
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

  Color getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case "ongoing":
        return Colors.orange;
      case "completed":
        return Colors.green;
      case "missed":
        return Colors.red;
      case "pending":
        return Colors.yellow;
      default:
        return Colors.white; // default color
    }
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

  String formatDate(dynamic date) {
    if (date == null) return "-";
    try {
      if (date is String) {
        return DateFormat("dd-MMM-yyyy").format(DateTime.parse(date));
      } else if (date is DateTime) {
        return DateFormat("dd-MMM-yyyy").format(date);
      } else {
        return "-";
      }
    } catch (e) {
      return "-";
    }
  }

  void showSessionDetailSheet(
    BuildContext context,
    SessionDetails details,
    User data,
  ) {
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
                    "Customer Details",
                    style: TextStyle(
                      fontFamily: productSans,
                      fontSize: 18,
                      color: white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // // Customer info
                _detailRow("Customer Name:", details.customerName ?? ""),
                // _detailRow("Customer Gender:", ""),
                _detailRow("Date Of Birth:", formatDate(data.birthday)),
                _detailRow("Birth Time:", data.birthTime ?? "--"),
                _detailRow(
                  "Birth Date Accuracy:",
                  data.birthTimeAccuracy ?? "",
                ),
                _detailRow("Place Of Birth:", data.birthPlace ?? "--"),
                const SizedBox(height: 20),
              ],
            ),
          ),
        );
      },
    );
  }

  /// Reusable widget: one detail per line
  Widget _detailRow(dynamic label, dynamic value) {
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
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          product.name ?? "",

                                          style: const TextStyle(
                                            fontSize: 14.0,
                                            fontFamily: productSans,
                                            color: white,
                                            fontWeight: FontWeight.w600,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
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
                                  ),
                                  const SizedBox(width: 8),
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
                            final List<int> selectedIds = selectedIndexes
                                .map<int>((i) => products[i].id!)
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
                        fontWeight: FontWeight.w500,
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
