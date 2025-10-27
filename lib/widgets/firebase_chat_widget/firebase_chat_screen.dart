import 'dart:async';
import 'package:astro_partner_app/constants/colors_const.dart';
import 'package:astro_partner_app/constants/fonts_const.dart';
import 'package:astro_partner_app/constants/images_const.dart';
import 'package:astro_partner_app/model/chat_model.dart';
import 'package:astro_partner_app/services/free_chat_service.dart';
import 'package:astro_partner_app/widgets/app_widget.dart';
import 'package:astro_partner_app/widgets/countdown_timer.dart';
import 'package:astro_partner_app/widgets/firebase_chat_widget/msg_bubble.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:get/get.dart';
import 'dart:io';

class FirebaseChatScreen extends StatefulWidget {
  final String roomId;
  final String customerName;
  final String remaingTime;
  final String subCollection; // e.g., 'adb_bcd'
  final int senderId;
  final int reciverId;

  const FirebaseChatScreen({
    required this.customerName,
    required this.reciverId,
    required this.remaingTime,
    required this.roomId,
    required this.subCollection,
    required this.senderId,
    super.key,
  });

  @override
  // ignore: library_private_types_in_public_api
  _FirebaseChatScreenState createState() => _FirebaseChatScreenState();
}

class _FirebaseChatScreenState extends State<FirebaseChatScreen>
    with WidgetsBindingObserver {
  final TextEditingController _messageController = TextEditingController();
  final FocusNode _messagefocusNode = FocusNode();
  final ValueNotifier<double> _progress = ValueNotifier<double>(0.0);
  final ValueNotifier<bool> _isUploadinglicon = ValueNotifier<bool>(false);
  final ValueNotifier<String> _selectedImageUrl = ValueNotifier<String>('');
  final ScrollController _scrollController = ScrollController();
  // final HomeController _homeController = Get.put(HomeController());
  // final ValueNotifier<String> _typingStatus = ValueNotifier<String>('');

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _sendMessage() async {
    if (_messageController.text.trim().isNotEmpty) {
      await FreeFirebaseServiceRequest.sendTextMessage(
        customerName: widget.customerName,
        message: _messageController.text,
        roomId: widget.roomId,
        subCollection: widget.subCollection,
        receiverId: widget.reciverId,
        senderId: widget.senderId,
      );
      _messageController.clear();
    }
  }

  Future<void> _sendMedia() async {
    // Pick an image file
    final result = await FilePicker.platform.pickFiles(type: FileType.image);
    if (result != null && result.files.isNotEmpty) {
      // Get the picked file
      _isUploadinglicon.value = true;
      final file = result.files.single;
      _selectedImageUrl.value = file.path!;
      File imageFile = File(file.path!);
      await FreeFirebaseServiceRequest.uploadMedia(
        file: imageFile,
        onProgress: (p0) {
          _progress.value = p0;
          print('Upload %: $p0');
        },
      ).then((onValue) async {
        _isUploadinglicon.value = false;
        _selectedImageUrl.value = "";
        if (onValue.status!) {
          print("##########${onValue.mediaUrl}##########");
          await FreeFirebaseServiceRequest.sendMediaMessage(
            customerName: widget.customerName,
            roomId: widget.roomId,
            subCollection: widget.subCollection,
            receiverId: widget.reciverId,
            senderId: widget.senderId,
            mediaUrl: onValue.mediaUrl!,
          );
        } else {
          Get.snackbar("Upload Media", onValue.message ?? "");
        }
      });
    }
  }

  Future<String> uploadImage(File image) async {
    final storageRef = FirebaseStorage.instance
        .ref()
        .child('chat_media')
        .child('${DateTime.now().millisecondsSinceEpoch}.jpg');
    await storageRef.putFile(image);
    return await storageRef.getDownloadURL();
  }

  Future<void> _markMessageAsSeen(ChatMessageModel message) async {
    if (!message.isSeen && message.receiverId == widget.senderId) {
      await FreeFirebaseServiceRequest.markAsSeen(
        msgId: message.id,
        roomId: widget.roomId,
        subCollection: widget.subCollection,
      );
    }
  }

  void _showCompletionDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false, // Tap outside dialog also disabled
      builder: (BuildContext context) {
        // ignore: deprecated_member_use
        return WillPopScope(
          onWillPop: () async {
            return false; // Back button disable
          },
          child: AlertDialog(
            backgroundColor: const Color(0xFF221d25),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            actionsAlignment: MainAxisAlignment.spaceBetween,
            title: text(
              'Chat Complete',
              fontSize: 18.0,
              fontFamily: productSans,
              fontWeight: FontWeight.w600,
              textColor: white,
            ),
            content: text(
              'The Chat has been completed.',
              fontSize: 18.0,
              fontFamily: productSans,
              fontWeight: FontWeight.w500,
              textColor: white,
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Close the dialog
                  Navigator.of(
                    context,
                  ).pop(); // Close previous screen if needed
                },
                child: text(
                  'Cancel',
                  fontSize: 18.0,
                  fontFamily: productSans,
                  fontWeight: FontWeight.w500,
                  textColor: white,
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Close the dialog
                  Navigator.of(context).pop(); // Close previous screen
                },
                child: text(
                  'Ok',
                  fontSize: 18.0,
                  fontFamily: productSans,
                  fontWeight: FontWeight.w500,
                  textColor: white,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Stream<DocumentSnapshot>? statusStream;
  late StreamSubscription<DocumentSnapshot> subscription;
  Timer? _typingTimer;
  // ignore: unused_field
  final bool _isTypingSent = false;

  // void _handleTyping() {
  //   print("👀 _handleTyping triggered");
  //   if (!_isTypingSent) {
  //     print("✅ Sending typing status: TRUE");
  //     setTypingStatus(true);
  //     _isTypingSent = true;
  //   } else {
  //     print("⏳ Already sent typing TRUE, skipping...");
  //   }
  //   _typingTimer?.cancel();
  //   print("🕒 Reset typing timer for 3 seconds...");
  //   _typingTimer = Timer(const Duration(seconds: 3), () {
  //     print("❌ Typing timeout. Sending typing status: FALSE");
  //     setTypingStatus(false);
  //     _isTypingSent = false;
  //   });
  // }
  // void _handleFocusChange() {
  //   if (_messagefocusNode.hasFocus) {
  //     print("🎯 Focus gained — user typing");
  //     setTypingStatus(true);
  //   } else {
  //     print("💤 Focus lost — user stopped typing");
  //     setTypingStatus(false);
  //   }
  // }

  Future<void> setTypingStatus(bool isTyping) async {
    try {
      await FirebaseFirestore.instance
          .collection('free_chat')
          .doc(widget.roomId)
          .collection('status')
          .doc('typingStatus')
          .set({"user_${widget.senderId}": isTyping}, SetOptions(merge: true));
    } catch (e) {
      print("🔥 Error setting typing status: $e");
    }
  }

  @override
  void initState() {
    WidgetsBinding.instance.addObserver(this);
    // Listen to Firestore document changes
    // _messageController.addListener(_handleTyping); // Not inline
    // _messagefocusNode.addListener(_handleFocusChange);
    statusStream = FirebaseFirestore.instance
        .collection('chat_status')
        .doc(widget.roomId)
        .snapshots();
    subscription = statusStream!.listen((snapshot) {
      if (snapshot.exists && snapshot.data() != null) {
        var data = snapshot.data() as Map<String, dynamic>;
        bool status = data['status'];
        if (status) {
          // Show popup when status becomes false
          Future.delayed(Duration.zero, () {
            showDialog(
              // ignore: use_build_context_synchronously
              context: context,
              barrierDismissible: false,
              builder: (BuildContext dialogContext) {
                return AlertDialog(
                  title: const Text(
                    "Session Completed",
                    style: TextStyle(fontFamily: productSans),
                  ),
                  content: const Text(
                    "Your session has been completed successfully.",
                    style: TextStyle(fontFamily: productSans),
                  ),
                  actions: [
                    TextButton(
                      child: const Text(
                        "OK",
                        style: TextStyle(fontFamily: productSans, color: black),
                      ),
                      onPressed: () {
                        Navigator.pop(dialogContext);
                        Navigator.pop(dialogContext);
                      },
                    ),
                  ],
                );
              },
            );
          });
        }
      }
    });
    super.initState();
  }

  @override
  void didChangeMetrics() {
    final bottomInset = WidgetsBinding.instance.window.viewInsets.bottom;
    final isKeyboardVisible = bottomInset > 0.0;
    print("⌨️ Keyboard visibility changed: $isKeyboardVisible");
    setTypingStatus(isKeyboardVisible);
    // if (isKeyboardVisible) {
    //   print("👋 Keyboard closed via system button or back gesture");
    //   setTypingStatus(false);
    // }
  }

  @override
  void dispose() {
    subscription.cancel();
    // _homeController.isCommingSessionsLoding(true);
    //_homeController.getCommingSessionsData();
    _typingTimer?.cancel();
    setTypingStatus(false);
    _messageController.dispose();
    _messagefocusNode.dispose();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // backgroundColor: white,
      backgroundColor: const Color(0xFF221d25),

      appBar: AppBar(
        backgroundColor: const Color(0xFF221d25),
        shadowColor: const Color(0xFF221d25),
        leadingWidth: 60,
        toolbarHeight: 60,
        elevation: 1,
        centerTitle: true,
        title: text(
          widget.customerName,
          fontSize: 20.0,
          maxLine: 1,
          textColor: white,
          fontWeight: FontWeight.w600,
          fontFamily: productSans,
        ),
        leading: GestureDetector(
          onTap: () {
            // _homeController.getCommingSessionsData();
            Navigator.of(context).pop();
          },
          child: const Center(
            child: Icon(Icons.arrow_back_rounded, color: white),
          ),
        ),
        actions: [
          widget.remaingTime == "00" || widget.remaingTime.isEmpty
              ? const SizedBox()
              : Container(
                  margin: const EdgeInsets.only(right: 8),
                  decoration: BoxDecoration(
                    color: black,
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 4,
                    ),
                    child: CountdownTimer(
                      minutes: (int.parse(widget.remaingTime) / 60).ceil(),
                      textFontSize: 18.0,
                      txtColor: white,
                      fontFamily: productSans,
                      onTimerComplete: () {
                        _showCompletionDialog(context);
                      },
                    ),
                  ),
                ),
        ],
      ),
      body: Stack(
        children: [
          SizedBox(
            height: double.infinity,
            width: double.infinity,
            child: Image.asset(appBg, fit: BoxFit.fill),
          ),
          Column(
            children: [
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('free_chat')
                      .doc(widget.roomId)
                      .collection(widget.subCollection)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return circularProgress();
                    }
                    final chatDocs = snapshot.data?.docs ?? [];
                    return ValueListenableBuilder<bool>(
                      valueListenable: _isUploadinglicon,
                      builder:
                          (
                            BuildContext context,
                            bool isUploadingliconValur,
                            Widget? child,
                          ) {
                            if (isUploadingliconValur) {
                              WidgetsBinding.instance.addPostFrameCallback(
                                (_) => _scrollToBottom(),
                              );
                            }
                            // Get the current date and define the cutoff (e.g., last 24 hours)
                            final DateTime now = DateTime.now();
                            final DateTime cutoffDate = now.subtract(
                              const Duration(days: 1),
                            ); // 24 hours ago
                            // Filter chatDocs to only include messages within the last 24 hours
                            final List<ChatMessageModel> recentChatDocs =
                                chatDocs
                                    .where((doc) {
                                      final message =
                                          ChatMessageModel.fromDocument(doc);
                                      final messageDate = message.dateTime;
                                      return messageDate.toDate().isAfter(
                                        cutoffDate,
                                      ); // Only messages after cutoff
                                    })
                                    .map(
                                      (doc) =>
                                          ChatMessageModel.fromDocument(doc),
                                    )
                                    .toList();
                            // Sort the filtered messages by dateTime in descending order
                            recentChatDocs.sort(
                              (a, b) => b.dateTime.compareTo(a.dateTime),
                            );

                            return ListView.builder(
                              reverse: true,
                              controller: _scrollController,
                              itemCount:
                                  recentChatDocs.length +
                                  (isUploadingliconValur ? 1 : 0),
                              // separatorBuilder: (context, index) {
                              //   if (isUploadingliconValur &&
                              //       index == recentChatDocs.length) {
                              //     return const SizedBox.shrink();
                              //   }
                              //   final message = recentChatDocs[index];
                              //   final currentDate = message.dateTime;
                              //   final previousDate = index > 0
                              //       ? recentChatDocs[index - 1].dateTime
                              //       : null;

                              //   final showDateHeader = previousDate == null ||
                              //       currentDate.toDate().day !=
                              //           previousDate.toDate().day ||
                              //       currentDate.toDate().month !=
                              //           previousDate.toDate().month ||
                              //       currentDate.toDate().year !=
                              //           previousDate.toDate().year;

                              //   return showDateHeader
                              //       ? _buildDateSeparator(currentDate)
                              //       : const SizedBox.shrink();
                              // },
                              itemBuilder: (ctx, index) {
                                if (isUploadingliconValur &&
                                    index == recentChatDocs.length) {
                                  return ValueListenableBuilder<String>(
                                    valueListenable: _selectedImageUrl,
                                    builder:
                                        (
                                          BuildContext context,
                                          String value,
                                          Widget? child,
                                        ) {
                                          return msgPlaceHolder(
                                            _getFileExtension(value) ?? "",
                                          );
                                        },
                                  );
                                }

                                final message = recentChatDocs[index];

                                // Mark the message as seen
                                _markMessageAsSeen(message);

                                return MessageBubble(
                                  messageTime: message.dateTime,
                                  message: message.msg,
                                  isRead: message.isSeen,
                                  isMe: message.senderId == widget.senderId,
                                  isMedia: message.msgType == 'Media',
                                  msgType: message.msgType,
                                );
                              },
                            );
                          },
                    );
                  },
                ),
              ),
              StreamBuilder<DocumentSnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('free_chat')
                    .doc(widget.roomId)
                    .collection('status')
                    .doc('typingStatus')
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData || snapshot.data == null) {
                    return const SizedBox(); // No data available yet
                  }
                  final typingData =
                      snapshot.data!.data() as Map<String, dynamic>?;
                  final mkey = 'user_${widget.roomId}';
                  final isTyping = typingData?[mkey] ?? false;
                  return isTyping
                      ? MessageBubble(
                          messageTime: Timestamp.now(),
                          message: "typing...",
                          isMe: false, // Show it as a received message
                          isMedia: false, // It's a text message
                          isRead: false,
                          showTime: false,
                          msgType: "text",
                        )
                      : const SizedBox();
                },
              ),
              _buildMessageInput(context),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMessageInput(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 10.0),
      color: Colors.transparent,
      child: SafeArea(
        child: Row(
          children: [
            IconButton(
              icon: const Icon(Icons.image, color: white),
              onPressed: _sendMedia,
            ),
            Expanded(
              child: TextFormField(
                controller: _messageController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: "Type a message...",
                  hintStyle: const TextStyle(color: white),
                  enabledBorder: OutlineInputBorder(
                    borderSide: const BorderSide(
                      color: primaryColor,
                      width: 1.0,
                    ),
                    borderRadius: BorderRadius.circular(30.0),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: const BorderSide(
                      color: primaryColor,
                      width: 1.0,
                    ),
                    borderRadius: BorderRadius.circular(30.0),
                  ),
                  filled: true,
                  fillColor: const Color(0xFF221d25),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 20.0,
                    vertical: 10.0,
                  ),
                ),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.send, color: white),
              onPressed: _sendMessage,
            ),
          ],
        ),
      ),
    );
  }

  // Widget _buildMessageInput(BuildContext context) {
  //   return Container(
  //     padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 10.0),
  //     color: white,
  //     child: SafeArea(
  //       child: Row(
  //         children: [
  //           IconButton(
  //             icon: const Icon(Icons.image, color: black),
  //             onPressed: _sendMedia,
  //           ),
  //           Expanded(
  //             child: TextFormField(
  //               controller: _messageController,
  //               focusNode: _messagefocusNode,
  //               decoration: InputDecoration(
  //                 hintText: "Type a message...",
  //                 border: OutlineInputBorder(
  //                   borderSide: BorderSide.none, // No visible border
  //                   borderRadius:
  //                       BorderRadius.circular(30.0), // Rounded corners
  //                 ),
  //                 filled: true,
  //                 fillColor:
  //                     Colors.grey[200], // Background color of the TextFormField
  //                 contentPadding: const EdgeInsets.symmetric(
  //                     horizontal: 20.0, vertical: 10.0),
  //               ),
  //             ),
  //           ),
  //           IconButton(
  //             icon: const Icon(Icons.send, color: black),
  //             onPressed: _sendMessage,
  //           ),
  //         ],
  //       ),
  //     ),
  //   );
  // }

  // Widget _buildDateSeparator(Timestamp date) {
  //   DateTime dateTime = date.toDate(); // ✅ Convert Timestamp to DateTime

  //   final now = DateTime.now();
  //   final today = DateTime(now.year, now.month, now.day);
  //   final comparisonDate = DateTime(
  //     dateTime.year,
  //     dateTime.month,
  //     dateTime.day,
  //   );
  //   final difference = today.difference(comparisonDate).inDays;

  //   String displayDate;
  //   if (difference == 0) {
  //     displayDate = 'Today';
  //   } else if (difference == 1) {
  //     displayDate = 'Yesterday';
  //   } else if (difference == -1) {
  //     displayDate = 'Tomorrow';
  //   } else {
  //     displayDate = DateFormat(
  //       'd MMMM yyyy',
  //     ).format(dateTime); // ✅ Pass DateTime instead of Timestamp
  //   }

  //   return Padding(
  //     padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
  //     child: Row(
  //       children: <Widget>[
  //         const Expanded(
  //           child: Divider(color: Colors.grey, thickness: 1, endIndent: 10),
  //         ),
  //         Text(
  //           displayDate,
  //           style: const TextStyle(
  //             color: Colors.black,
  //             fontSize: 14,
  //           ), // ✅ Fixed 'black' variable error
  //         ),
  //         const Expanded(
  //           child: Divider(color: Colors.grey, thickness: 1, indent: 10),
  //         ),
  //       ],
  //     ),
  //   );
  // }

  // ListTile msgPlaceHolder(String extension) {
  //   return ListTile(
  //     title: Align(
  //       alignment: Alignment.centerRight,
  //       child: ValueListenableBuilder(
  //           valueListenable: _progress,
  //           builder:
  //               (BuildContext context, double progressValue, Widget? child) {
  //             return Column(
  //               crossAxisAlignment: CrossAxisAlignment.end,
  //               children: [
  //                 Container(
  //                   decoration: const BoxDecoration(
  //                     borderRadius: BorderRadius.only(
  //                       bottomLeft: Radius.circular(20),
  //                       topRight: Radius.circular(20),
  //                       topLeft: Radius.circular(20),
  //                     ),
  //                     color: black,
  //                   ),
  //                   padding:
  //                       const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
  //                   child: Row(
  //                     mainAxisSize: MainAxisSize.min,
  //                     crossAxisAlignment: CrossAxisAlignment.end,
  //                     children: [
  //                       SizedBox(
  //                         height: 15,
  //                         width: 15,
  //                         child: Stack(
  //                           children: [
  //                             CircularProgressIndicator(
  //                               value: progressValue,
  //                               strokeWidth: 2,
  //                               color: Colors.white,
  //                             ),
  //                             const Center(
  //                               child: Icon(
  //                                 Icons.download, // Choose your desired icon
  //                                 size:
  //                                     8, // Adjust the size to fit in the center
  //                                 color:
  //                                     Colors.green, // Set the color of the icon
  //                               ),
  //                             ),
  //                           ],
  //                         ),
  //                       ),
  //                       Padding(
  //                         padding: const EdgeInsets.only(left: 4.0),
  //                         child: Text("${(progressValue * 100).toInt()}%",
  //                             style:
  //                                 const TextStyle(fontSize: 10, color: white)),
  //                       ),
  //                       const SizedBox(width: 4),
  //                       Column(
  //                         children: [
  //                           if (extension == 'jpg' ||
  //                               extension == 'jpeg' ||
  //                               extension == 'png' ||
  //                               extension == 'gif')
  //                             const SizedBox(
  //                               height: 100,
  //                               width: 100,
  //                               child: Icon(Icons.image,
  //                                   size: 40, color: Colors.white),
  //                             ),
  //                           if (extension == 'mp4' ||
  //                               extension == 'mov' ||
  //                               extension == 'avi')
  //                             const Icon(Icons.videocam,
  //                                 size: 40, color: Colors.white),
  //                           // if (valueFileType == 'audio')
  //                           //   const Icon(Icons.audiotrack,
  //                           //       size: 40, color: Colors.white),
  //                           if (extension == 'pdf' ||
  //                               extension == 'docx' ||
  //                               extension == 'txt')
  //                             const Icon(Icons.insert_drive_file,
  //                                 size: 40, color: Colors.white),
  //                         ],
  //                       ),
  //                     ],
  //                   ),
  //                 ),
  //                 const SizedBox(height: 5),
  //               ],
  //             );
  //           }),
  //     ),
  //   );
  // }

  ListTile msgPlaceHolder(String extension) {
    return ListTile(
      title: Align(
        alignment: Alignment.centerRight,
        child: ValueListenableBuilder(
          valueListenable: _progress,
          builder: (BuildContext context, double progressValue, Widget? child) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Container(
                  decoration: const BoxDecoration(
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                      topLeft: Radius.circular(20),
                    ),
                    color: black,
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      SizedBox(
                        height: 15,
                        width: 15,
                        child: Stack(
                          children: [
                            CircularProgressIndicator(
                              value: progressValue,
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                            const Center(
                              child: Icon(
                                Icons.download, // Choose your desired icon
                                size: 8, // Adjust the size to fit in the center
                                color:
                                    Colors.green, // Set the color of the icon
                              ),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 4.0),
                        child: Text(
                          "${(progressValue * 100).toInt()}%",
                          style: const TextStyle(fontSize: 10, color: white),
                        ),
                      ),
                      const SizedBox(width: 4),
                      Column(
                        children: [
                          if (extension == 'jpg' ||
                              extension == 'jpeg' ||
                              extension == 'png' ||
                              extension == 'gif')
                            const SizedBox(
                              height: 100,
                              width: 100,
                              child: Icon(
                                Icons.image,
                                size: 40,
                                color: Colors.white,
                              ),
                            ),
                          if (extension == 'mp4' ||
                              extension == 'mov' ||
                              extension == 'avi')
                            const Icon(
                              Icons.videocam,
                              size: 40,
                              color: Colors.white,
                            ),
                          // if (valueFileType == 'audio')
                          //   const Icon(Icons.audiotrack,
                          //       size: 40, color: Colors.white),
                          if (extension == 'pdf' ||
                              extension == 'docx' ||
                              extension == 'txt')
                            const Icon(
                              Icons.insert_drive_file,
                              size: 40,
                              color: Colors.white,
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 5),
              ],
            );
          },
        ),
      ),
    );
  }

  // Basic file extension check
  String? _getFileExtension(String url) {
    final parts = url.split('.');
    if (parts.length > 1) {
      return parts.last.toLowerCase();
    }
    return null;
  }
}
