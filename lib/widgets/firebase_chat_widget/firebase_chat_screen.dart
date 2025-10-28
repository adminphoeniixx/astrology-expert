import 'dart:async';
import 'dart:io';

import 'package:astro_partner_app/constants/colors_const.dart';
import 'package:astro_partner_app/constants/fonts_const.dart';
import 'package:astro_partner_app/constants/images_const.dart';
import 'package:astro_partner_app/controllers/home_controller.dart';
import 'package:astro_partner_app/model/chat_model.dart';
import 'package:astro_partner_app/services/free_chat_service.dart';
import 'package:astro_partner_app/widgets/app_widget.dart';
import 'package:astro_partner_app/widgets/countdown_timer.dart';
import 'package:astro_partner_app/widgets/firebase_chat_widget/msg_bubble.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

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

class _FirebaseChatScreenState extends State<FirebaseChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final HomeController _homeController = Get.put(HomeController());

  final FocusNode _messagefocusNode = FocusNode();

  /// Upload state
  final ValueNotifier<double> _progress = ValueNotifier<double>(0.0);
  final ValueNotifier<bool> _isUploadingIcon = ValueNotifier<bool>(false);
  final ValueNotifier<String> _selectedImagePath = ValueNotifier<String>('');

  final ScrollController _scrollController = ScrollController();
  bool _isTimerStarted = false;

  /// Typing state
  Timer? _typingTimer;

  void _scrollToBottom() {
    // With reverse: true, bottom is offset 0.0
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          0.0,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _startTimer() {
    if (!_isTimerStarted) {
      setState(() {
        _isTimerStarted = true;
      });
    }
  }

  Future<void> _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;
    _startTimer();

    // Stop typing as we’re sending the message now
    await setTypingStatus(false);

    await FreeFirebaseServiceRequest.sendTextMessage(
      customerName: widget.customerName,
      message: text,
      roomId: widget.roomId,
      subCollection: widget.subCollection,
      receiverId: widget.reciverId,
      senderId: widget.senderId,
    );

    _messageController.clear();
    _scrollToBottom();
  }

  Future<void> _sendMedia() async {
    _startTimer();

    final result = await FilePicker.platform.pickFiles(type: FileType.image);
    if (result == null || result.files.isEmpty) return;

    final file = result.files.single;
    if (file.path == null) {
      Get.snackbar("Upload Media", "Invalid image path");
      return;
    }

    _progress.value = 0.0;
    _selectedImagePath.value = file.path!;
    _isUploadingIcon.value = true;
    _scrollToBottom();

    final imageFile = File(file.path!);

    await FreeFirebaseServiceRequest.uploadMedia(
          file: imageFile,
          onProgress: (p0) {
            // p0 expected as 0.0..1.0
            _progress.value = p0.clamp(0.0, 1.0);
          },
        )
        .then((onValue) async {
          _isUploadingIcon.value = false;
          void localReset() {
            _selectedImagePath.value = '';
            _progress.value = 0.0;
          }

          if (onValue.status == true &&
              (onValue.mediaUrl?.isNotEmpty ?? false)) {
            final url = onValue.mediaUrl!;
            await FreeFirebaseServiceRequest.sendMediaMessage(
              customerName: widget.customerName,
              roomId: widget.roomId,
              subCollection: widget.subCollection,
              receiverId: widget.reciverId,
              senderId: widget.senderId,
              mediaUrl: url,
            );
            localReset();
            _scrollToBottom();
          } else {
            localReset();
            Get.snackbar("Upload Media", onValue.message ?? "Upload failed");
          }
        })
        .catchError((e) {
          _isUploadingIcon.value = false;
          _selectedImagePath.value = '';
          _progress.value = 0.0;
          Get.snackbar("Upload Media", "Error: $e");
        });
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
      barrierDismissible: false,
      builder: (BuildContext context) {
        // ignore: deprecated_member_use
        return WillPopScope(
          onWillPop: () async => false,
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
                  Navigator.of(context).pop();
                  Navigator.of(context).pop();
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
                  Navigator.of(context).pop();
                  Navigator.of(context).pop();
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

  Future<void> setTypingStatus(bool isTyping) async {
    try {
      await FirebaseFirestore.instance
          .collection('free_chat')
          .doc(widget.roomId)
          .collection('status')
          .doc('typingStatus')
          .set({"user_${widget.senderId}": isTyping}, SetOptions(merge: true));
    } catch (e) {
      // ignore: avoid_print
      print("🔥 Error setting typing status: $e");
    }
  }

  /// Call this from TextField.onChanged
  void _handleTyping(String value) {
    // When user types, set true immediately
    setTypingStatus(true);

    // reset debounce timer
    _typingTimer?.cancel();
    _typingTimer = Timer(const Duration(seconds: 2), () {
      // After 2s of inactivity, set false
      setTypingStatus(false);
    });

    // If user clears text fully, set false quickly
    if (value.isEmpty) {
      _typingTimer?.cancel();
      setTypingStatus(false);
    }
  }

  @override
  void initState() {
    super.initState();
    FirebaseFirestore.instance
        .collection('expert_chat_timers')
        .doc("${widget.reciverId}_${widget.roomId}")
        .snapshots()
        .listen((snapshot) {
          if (snapshot.exists && snapshot.data() != null) {
            final data = snapshot.data() as Map<String, dynamic>;
            final String chatStatus = data['chatStatus'] ?? "";

            if (chatStatus == "end") {
              _showExitPopup();
            }
          }
        });

    statusStream = FirebaseFirestore.instance
        .collection('chat_status')
        .doc(widget.roomId)
        .snapshots();

    subscription = statusStream!.listen((snapshot) {
      if (snapshot.exists && snapshot.data() != null) {
        final data = snapshot.data() as Map<String, dynamic>;
        final bool status = data['status'] == true;
        if (status) {
          Future.microtask(() {
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
  }

  @override
  void dispose() {
    subscription.cancel();
    _typingTimer?.cancel();
    setTypingStatus(false);
    _messageController.dispose();
    _messagefocusNode.dispose();
    super.dispose();
  }

  void _showExitPopup() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF221d25),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: text(
          "Exit Chat?",
          textColor: white,
          fontSize: 18.0,
          fontFamily: productSans,
        ),
        content: text(
          "Do you really want to end this chat?",
          textColor: white,
          fontFamily: productSans,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: text(
              "Cancel",
              textColor: Colors.white70,
              fontFamily: productSans,
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              await _homeController
                  .endChat(
                    customerId: widget.reciverId,
                    durationSeconds: int.parse(widget.remaingTime),
                    expertId: widget.senderId,
                    notes: "Chat ended normally",
                  )
                  .then((value) {
                    if (value.status == true) {
                      Navigator.pop(context); // close dialog first
                      Navigator.pop(context); // close dialog first
                    }
                  });
            },
            child: text("End Chat", textColor: white, fontFamily: productSans),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        _showExitPopup(); // ✅ back दबाने पर popup खुलेगा
        return false;
      },
      child: Scaffold(
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
              Navigator.of(context).pop();
            },
            child: const Center(
              child: Icon(Icons.arrow_back_rounded, color: white),
            ),
          ),
          actions: [
            _isTimerStarted
                ? widget.remaingTime == "00" || widget.remaingTime.isEmpty
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
                              minutes: (int.parse(widget.remaingTime) / 60)
                                  .ceil(),
                              textFontSize: 18.0,
                              txtColor: white,
                              fontFamily: productSans,
                              onTimerComplete: () {
                                _showCompletionDialog(context);
                              },
                            ),
                          ),
                        )
                : const SizedBox(),
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
                        valueListenable: _isUploadingIcon,
                        builder: (context, isUploading, child) {
                          if (isUploading) {
                            WidgetsBinding.instance.addPostFrameCallback(
                              (_) => _scrollToBottom(),
                            );
                          }

                          // Last 24 hours filter
                          final DateTime now = DateTime.now();
                          final DateTime cutoffDate = now.subtract(
                            const Duration(days: 1),
                          );

                          final List<ChatMessageModel> recentChatDocs = chatDocs
                              .where((doc) {
                                final message = ChatMessageModel.fromDocument(
                                  doc,
                                );
                                final messageDate = message.dateTime;
                                return messageDate.toDate().isAfter(
                                  cutoffDate,
                                ); // Only recent
                              })
                              .map((doc) => ChatMessageModel.fromDocument(doc))
                              .toList();

                          // Sort by dateTime desc so reverse: true works like chat
                          recentChatDocs.sort(
                            (a, b) => b.dateTime.compareTo(a.dateTime),
                          );

                          return ListView.builder(
                            reverse: true,
                            controller: _scrollController,
                            itemCount:
                                recentChatDocs.length + (isUploading ? 1 : 0),
                            itemBuilder: (ctx, index) {
                              // With reverse:true latest is index 0.
                              if (isUploading && index == 0) {
                                return ValueListenableBuilder<String>(
                                  valueListenable: _selectedImagePath,
                                  builder: (context, localPath, _) {
                                    return _uploadingImageBubble(localPath);
                                  },
                                );
                              }

                              final adjustedIndex = isUploading
                                  ? index - 1
                                  : index;
                              final message = recentChatDocs[adjustedIndex];

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

                /// Typing indicator listener (other user)
                StreamBuilder<DocumentSnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('free_chat')
                      .doc(widget.roomId)
                      .collection('status')
                      .doc('typingStatus')
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData || snapshot.data == null) {
                      return const SizedBox();
                    }
                    final typingData =
                        snapshot.data!.data() as Map<String, dynamic>?;
                    final mkey = 'user_${widget.reciverId}';
                    final isTyping = typingData?[mkey] == true;

                    return isTyping
                        ? MessageBubble(
                            messageTime: Timestamp.now(),
                            message: "typing...",
                            isMe: false,
                            isMedia: false,
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
                focusNode: _messagefocusNode,
                onChanged: _handleTyping, // ✅ only when user types
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

  /// WhatsApp-style uploading image bubble (right aligned)
  Widget _uploadingImageBubble(String localPath) {
    return ListTile(
      title: Align(
        alignment: Alignment.centerRight,
        child: Container(
          decoration: const BoxDecoration(
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(16),
              topRight: Radius.circular(16),
              topLeft: Radius.circular(16),
            ),
            color: primaryColor,
          ),
          padding: const EdgeInsets.all(8),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 240),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  /// Image preview (local)
                  AspectRatio(
                    aspectRatio: 4 / 3,
                    child:
                        (localPath.isNotEmpty && File(localPath).existsSync())
                        ? Image.file(File(localPath), fit: BoxFit.cover)
                        : Container(
                            color: primaryColor,
                            child: const Center(
                              child: Icon(Icons.image, color: Colors.white70),
                            ),
                          ),
                  ),

                  /// Dim overlay while uploading
                  Container(color: primaryColor),

                  /// Circular progress + % text
                  ValueListenableBuilder<double>(
                    valueListenable: _progress,
                    builder: (context, p, _) {
                      final percent = (p * 100).clamp(0, 100).toInt();
                      return Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox(
                            width: 40,
                            height: 40,
                            child: CircularProgressIndicator(
                              value: p,
                              strokeWidth: 3,
                              color: Colors.white,
                              backgroundColor: Colors.white24,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            "$percent%",
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontFamily: productSans,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
