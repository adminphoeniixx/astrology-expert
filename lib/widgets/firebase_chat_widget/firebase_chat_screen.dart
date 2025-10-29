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

/// Top-level helper to render either a date header or a message row
class _ChatListEntry {
  final String? headerLabel; // non-null when it's a date header
  final ChatMessageModel? message; // non-null when it's a message

  const _ChatListEntry.header(this.headerLabel) : message = null;
  const _ChatListEntry.message(this.message) : headerLabel = null;

  bool get isHeader => headerLabel != null;
}

class FirebaseChatScreen extends StatefulWidget {
  final String sessionStatus;
  final String startTime;
  final String roomId;
  final String customerName;
  final String remaingTime;
  final String subCollection; // e.g., 'adb_bcd'
  final int senderId;
  final int reciverId;

  const FirebaseChatScreen({
    required this.startTime,
    required this.sessionStatus,
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

  bool get _isCompleted => widget.sessionStatus == "Completed"; // ✅ UPDATED

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

  int calculateTimer(String startTimeString) {
    DateTime now = DateTime.now();

    // Parse HH:mm:ss
    List<String> parts = startTimeString.split(":");
    int h = int.parse(parts[0]);
    int m = int.parse(parts[1]);
    int s = int.parse(parts[2]);

    // Convert both times to total seconds since day start
    int nowSeconds = now.hour * 3600 + now.minute * 60 + now.second;
    int startSeconds = h * 3600 + m * 60 + s;

    // Difference
    int diff = nowSeconds - startSeconds;

    // Handle previous day case (if negative)
    if (diff < 0) diff += 24 * 3600;

    return diff;
  }

  // int calculateTimer(String startTimeString) {
  //   // Parse start time "HH:mm:ss"
  //   DateTime now = DateTime.now();
  //   List<String> parts = startTimeString.split(":");
  //   DateTime startTime = DateTime(
  //     now.year,
  //     now.month,
  //     now.day,
  //     int.parse(parts[0]),
  //     int.parse(parts[1]),
  //     int.parse(parts[2]),
  //   );

  //   // Calculate difference
  //   Duration diff = now.difference(startTime);

  //   // Return seconds (ensure no negative)
  //   return diff.inSeconds < 0 ? 0 : diff.inSeconds;
  // }

  void _startTimer() {
    if (_isCompleted) return; // ✅ UPDATED: no timer if completed
    if (!_isTimerStarted) {
      setState(() {
        _isTimerStarted = true;
      });
    }
  }

  Future<void> _sendMessage() async {
    if (_isCompleted) return; // ✅ UPDATED: block send
    final text = _messageController.text.trim();
    if (text.isEmpty) return;
    _startTimer();

    // Stop typing as we’re sending the message now
    await setTypingStatus(false);
    FirebaseFirestore.instance
        .collection('free_chat_session')
        .doc(widget.roomId)
        .get()
        .then((onValue) async {
          final data = onValue.data() as Map<String, dynamic>;
          print("###############free_chat_session#################");
          print(data);
          final String chatStatus = data['status'] ?? "";
          final bool isNewSession = data['is_new_session'] ?? "";
          await FreeFirebaseServiceRequest.sendTextMessage(
            customerName: widget.customerName,
            message: text,
            roomId: widget.roomId,
            subCollection: widget.subCollection,
            receiverId: widget.reciverId,
            senderId: widget.senderId,
            isFirstMessage: isNewSession,
          );
        });

    _messageController.clear();
    _scrollToBottom();
  }

  Future<void> _sendMedia() async {
    if (_isCompleted) return; // ✅ UPDATED: block media
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

            FirebaseFirestore.instance
                .collection('free_chat_session')
                .doc(widget.roomId)
                .get()
                .then((onValue) async {
                  final data = onValue.data() as Map<String, dynamic>;
                  print("###############free_chat_session#################");
                  print(data);
                  final String chatStatus = data['status'] ?? "";
                  final bool isNewSession = data['is_new_session'] ?? "";
                  await FreeFirebaseServiceRequest.sendMediaMessage(
                    isFirstMessage: isNewSession,
                    customerName: widget.customerName,
                    roomId: widget.roomId,
                    subCollection: widget.subCollection,
                    receiverId: widget.reciverId,
                    senderId: widget.senderId,
                    mediaUrl: url,
                  );
                });
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
    if (_isCompleted) return; // ✅ UPDATED: don't show on completed
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
    if (_isCompleted) return; // ✅ UPDATED: don't set typing on completed
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
    if (_isCompleted) return; // ✅ UPDATED
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
    print("################calculateTimer#################");
    print(widget.startTime);
    print(DateTime.now());
    int dd = calculateTimer(widget.startTime);
    print(dd);

    // Listen end signal -> show popup only if NOT completed
    // FirebaseFirestore.instance
    //     .collection('expert_chat_timers')
    //     .doc("${widget.reciverId}_${widget.roomId}")
    //     .snapshots()
    //     .listen((snapshot) {
    //   if (snapshot.exists && snapshot.data() != null) {
    //     final data = snapshot.data() as Map<String, dynamic>;
    //     final String chatStatus = data['chatStatus'] ?? "";

    //     if (chatStatus == "end" && !_isCompleted) {
    //       _showExitPopup(); // ✅ UPDATED guard
    //     }
    //   }
    // });

    // FirebaseFirestore.instance
    //     .collection('free_chat_session')
    //     .doc(widget.roomId)
    //     .snapshots()
    //     .listen((snapshot) {
    //       if (snapshot.exists && snapshot.data() != null) {
    //         final data = snapshot.data() as Map<String, dynamic>;
    //         print("###############free_chat_session#################");
    //         print(data);
    //         final String chatStatus = data['status'] ?? "";
    //         final bool isNewSession = data['is_new_session'] ?? "";
    //         if (chatStatus == "Completed") {
    //           print(chatStatus);
    //           _showExitPopup();
    //         }
    //       }
    //     });

    // External session complete trigger -> keep as-is (will pop screens)
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
    if (!_isCompleted) {
      setTypingStatus(false); // ✅ UPDATED: avoid redundant write when completed
    }
    _messageController.dispose();
    _messagefocusNode.dispose();
    super.dispose();
  }

  void _showExitPopup() {
    if (_isCompleted) return; // ✅ UPDATED: don't show on completed

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
                      Navigator.of(context).pop(true);
                      Navigator.of(context).pop(true);
                    }
                  });
            },
            child: text("End Chat", textColor: white, fontFamily: productSans),
          ),
        ],
      ),
    );
  }

  // ------------------ NEW: Date header helpers ------------------

  /// Month names for dd MMM yyyy without intl
  static const List<String> _months = [
    "Jan",
    "Feb",
    "Mar",
    "Apr",
    "May",
    "Jun",
    "Jul",
    "Aug",
    "Sep",
    "Oct",
    "Nov",
    "Dec",
  ];

  /// Returns "Today", "Yesterday" or "dd MMM yyyy"
  String _formatDateHeader(DateTime dt) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final d = DateTime(dt.year, dt.month, dt.day);

    if (d == today) return "Today";
    if (d == yesterday) return "Yesterday";
    return "${dt.day.toString().padLeft(2, '0')} ${_months[dt.month - 1]} ${dt.year}";
  }

  List<_ChatListEntry> _buildEntriesWithHeaders(
    List<ChatMessageModel> sortedDesc,
  ) {
    final sortedAsc = List<ChatMessageModel>.from(sortedDesc.reversed);

    final entries = <_ChatListEntry>[];
    String? lastDateKey;

    for (final m in sortedAsc) {
      final dt = m.dateTime.toDate();
      final dateKey = "${dt.year}-${dt.month}-${dt.day}";

      if (lastDateKey != dateKey) {
        entries.add(_ChatListEntry.header(_formatDateHeader(dt)));
        lastDateKey = dateKey;
      }
      entries.add(_ChatListEntry.message(m));
    }

    return entries.reversed.toList();
  }

  @override
  Widget build(BuildContext context) {
    // ignore: deprecated_member_use
    return Scaffold(
      backgroundColor: const Color(0xFF221d25),
      appBar: AppBar(
        backgroundColor: const Color(0xFF221d25),
        elevation: 1,
        centerTitle: true,
        leadingWidth: 60,
        leading: GestureDetector(
          onTap: () {
            _showExitPopup(); // back par popup hoga
          },
          child: const Icon(Icons.arrow_back_rounded, color: white),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            text(
              widget.customerName,
              fontSize: 18.0,
              textColor: white,
              fontWeight: FontWeight.w600,
              fontFamily: productSans,
            ),
            const SizedBox(height: 4),

            // ⏳ Timer below name
            !_isCompleted
                ? (_isTimerStarted &&
                          widget.remaingTime != "00" &&
                          widget.remaingTime.isNotEmpty)
                      ? CountdownTimer2(
                          // minutes: (int.parse(widget.remaingTime) / 60).ceil(),
                          totalSeconds: calculateTimer(widget.startTime),
                          textFontSize: 14.0,
                          txtColor: Colors.white70,
                          fontFamily: productSans,
                          onTimerComplete: () {
                            _showCompletionDialog(context);
                          },
                        )
                      : const SizedBox()
                : const SizedBox(),
          ],
        ),

        // 🔴 End Chat button (top-right)
        actions: [
          if (!_isCompleted)
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: ElevatedButton(
                onPressed: () {
                  _showExitPopup();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 6,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: const Text(
                  "End Chat",
                  style: TextStyle(
                    fontSize: 14,
                    fontFamily: productSans,
                    color: Colors.white,
                  ),
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
                      .orderBy(
                        'dateTime',
                        descending: true,
                      ) // ensure server sort
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

                        /// NOTE: Removed 24h filter so older days can show headers like "Yesterday", "21 Jan 2025"
                        final List<ChatMessageModel> allChat = chatDocs
                            .map((doc) => ChatMessageModel.fromDocument(doc))
                            .toList();

                        /// Already DESC by query, but re-ensure:
                        allChat.sort(
                          (a, b) => b.dateTime.compareTo(a.dateTime),
                        );

                        /// Build flattened entries (headers + messages)
                        final entries = _buildEntriesWithHeaders(allChat);

                        return ListView.builder(
                          reverse: true,
                          controller: _scrollController,
                          itemCount:
                              entries.length +
                              ((isUploading && !_isCompleted) ? 1 : 0),
                          itemBuilder: (ctx, index) {
                            // With reverse:true latest is index 0.
                            if (isUploading &&
                                !_isCompleted && // ✅ UPDATED: don't show uploading bubble if completed
                                index == 0) {
                              return ValueListenableBuilder<String>(
                                valueListenable: _selectedImagePath,
                                builder: (context, localPath, _) {
                                  return _uploadingImageBubble(localPath);
                                },
                              );
                            }

                            final adjustedIndex = (isUploading && !_isCompleted)
                                ? index - 1
                                : index;
                            final entry = entries[adjustedIndex];

                            if (entry.isHeader) {
                              return _buildDateSeparator(entry.headerLabel!);
                            }

                            final message = entry.message!;
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
              if (!_isCompleted) // ✅ UPDATED: hide typing on completed
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

              // ✅ UPDATED: Input bar only when NOT completed
              _isCompleted ? const SizedBox() : _buildMessageInput(context),
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
              onPressed: _sendMedia, // will be ignored if completed
            ),
            Expanded(
              child: TextFormField(
                controller: _messageController,
                focusNode: _messagefocusNode,
                onChanged: _handleTyping, // ✅ only when user types (guarded)
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
                readOnly: _isCompleted, // ✅ safety
              ),
            ),
            IconButton(
              icon: const Icon(Icons.send, color: white),
              onPressed: _sendMessage, // will be ignored if completed
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

  /// Date separator chip
  Widget _buildDateSeparator(String date) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          const Expanded(child: Divider(color: Colors.white24, thickness: 1)),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 8),
            decoration: BoxDecoration(
              color: Colors.black38,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white12),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            child: Text(
              date,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 12,
                fontFamily: productSans,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.2,
              ),
            ),
          ),
          const Expanded(child: Divider(color: Colors.white24, thickness: 1)),
        ],
      ),
    );
  }
}
