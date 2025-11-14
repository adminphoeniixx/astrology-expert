import 'dart:async';
import 'dart:io';

import 'package:astro_partner_app/constants/colors_const.dart';
import 'package:astro_partner_app/constants/fonts_const.dart';
import 'package:astro_partner_app/constants/images_const.dart';
import 'package:astro_partner_app/controllers/home_controller.dart';
import 'package:astro_partner_app/model/chat_model.dart';
import 'package:astro_partner_app/model/partner_info_model.dart';
import 'package:astro_partner_app/model/session_details_model.dart';
import 'package:astro_partner_app/services/free_chat_service.dart';
import 'package:astro_partner_app/widgets/app_widget.dart';
import 'package:astro_partner_app/widgets/firebase_chat_widget/msg_bubble.dart';
import 'package:astro_partner_app/widgets/socket_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart';

/// Internal list item that can be either a date header or a chat message
class _ChatListEntry {
  final String? headerLabel;
  final ChatMessageModel? message;

  const _ChatListEntry.header(this.headerLabel) : message = null;
  const _ChatListEntry.message(this.message) : headerLabel = null;

  bool get isHeader => headerLabel != null;
}

class FirebaseChatScreen extends StatefulWidget {
  final String sessionStatus;
  final String startTime;
  final String roomId;
  final String sessionId;

  final String customerName;
  final String remaingTime;
  final String subCollection;
  final int senderId;
  final int reciverId;

  const FirebaseChatScreen({
    required this.sessionId,
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
  State<FirebaseChatScreen> createState() => _FirebaseChatScreenState();
}

class _FirebaseChatScreenState extends State<FirebaseChatScreen> {
  final HomeController _homeController = Get.put(HomeController());

  final TextEditingController _messageController = TextEditingController();
  final FocusNode _messageFocusNode = FocusNode();
  final ScrollController _scrollController = ScrollController();

  /// Upload state
  final ValueNotifier<double> _uploadProgress = ValueNotifier<double>(0.0);
  final ValueNotifier<bool> _isUploading = ValueNotifier<bool>(false);
  final ValueNotifier<String> _localUploadPath = ValueNotifier<String>('');

  /// Typing debounce
  Timer? _typingTimer;

  /// Live session flags (runtime)
  bool _isCompleted = false; // current session completed
  bool _isUserEndingChat = false; // prevent popup when user ends chat
  bool _isExitPopupVisible = false; // avoid duplicate popups
  bool _isCompletionPopupVisible = false; // avoid duplicate popups

  StreamSubscription<DocumentSnapshot<Map<String, dynamic>>>? _sessionSub;
  final DateFormat formatter = DateFormat("dd MMM yyyy");

  // ------------------ Date header helpers ------------------
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
    List<ChatMessageModel> descSorted,
  ) {
    // Build on ASC then reverse for reverse: true list
    final asc = List<ChatMessageModel>.from(descSorted.reversed);
    final entries = <_ChatListEntry>[];
    String? last;

    for (final m in asc) {
      final dt = m.dateTime.toDate();
      final key = "${dt.year}-${dt.month}-${dt.day}";
      if (last != key) {
        entries.add(_ChatListEntry.header(_formatDateHeader(dt)));
        last = key;
      }
      entries.add(_ChatListEntry.message(m));
    }
    return entries.reversed.toList();
  }

  // ------------------ Utils ------------------
  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          0.0, // reverse: true, so bottom is offset 0
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  // ------------------ Firestore: session status listener ------------------
  void _listenToSessionStatus() {
    _sessionSub = FirebaseFirestore.instance
        .collection('free_chat_session')
        .doc(widget.roomId)
        .snapshots()
        .listen((snapshot) {
          if (!mounted) return;
          if (!snapshot.exists || snapshot.data() == null) return;

          // final data = snapshot.data()!;
          // final String chatStatus = (data['status'] ?? "") as String;
          // final bool isNewSession = data['is_new_session'] is bool
          //     ? data['is_new_session'] as bool
          //     : false;

          // Debug
          print(
            "📡 status: ${snapshot.data()!['session_id']} session_id ${widget.sessionId} is_new_session: ${snapshot.data()!['is_new_session']}  userEnding: $_isUserEndingChat",
          );

          // if (_isUserEndingChat && chatStatus == "Completed") return;
          if (snapshot.data()!['status'] == "Completed" &&
              snapshot.data()!['session_id'] == widget.sessionId) {
            // _completionPopupShownOnce = true;
            // _isCompleted = true;
            // print(
            //   "📡 status: $chatStatus  is_new_session: $isNewSession  userEnding: $_isUserEndingChat",
            // );
            _showCompletedPopup();
            // return;
            //   if (chatStatus == "Completed"
            //   //&&
            //       // !isNewSession &&
            //       // !_isUserEndingChat &&
            //       //!_completionPopupShownOnce
            //       ) {
            //     _completionPopupShownOnce = true;
            //     //  setState(() => _isCompleted = true);
            //     _showCompletedPopup();
          }
        });
  }

  // ------------------ Typing ------------------
  Future<void> _setTyping(bool typing) async {
    if (_isCompleted || !mounted) return;

    await FirebaseFirestore.instance
        .collection('free_chat')
        .doc(widget.roomId)
        .collection('status')
        .doc('typingStatus')
        .set({"user_${widget.senderId}": typing}, SetOptions(merge: true));
  }

  void _onTypingChanged(String value) {
    if (_isCompleted) return;
    _setTyping(true);
    _typingTimer?.cancel();
    _typingTimer = Timer(const Duration(seconds: 2), () => _setTyping(false));
    if (value.isEmpty) {
      _typingTimer?.cancel();
      _setTyping(false);
    }
  }

  // ------------------ Send text / media ------------------
  Future<void> _sendMessage() async {
    print("!!!!!!!!!!!!!!!!1!!!!!!!!!!!!!!!!!");
    // if (_isCompleted) return;
    final text = _messageController.text.trim();
    // if (text.isEmpty) return;

    // await _setTyping(false);
    print("!!!!!!!!!!!!!!!!2!!!!!!!!!!!!!!!!!");

    final meta = await FirebaseFirestore.instance
        .collection('free_chat_session')
        .doc(widget.roomId)
        .get();

    if (!meta.exists || meta.data() == null) return;
    final data = meta.data()!;
    final String chatStatus = (data['status'] ?? "") as String;
    final bool isNewSession = data['is_new_session'] is bool
        ? data['is_new_session'] as bool
        : false;

    if (chatStatus == "Completed") {
      if (!_isCompletionPopupVisible) _showCompletedPopup();
      return;
    }

    await FreeFirebaseServiceRequest.sendTextMessage(
      sessionId: widget.sessionId,
      customerName: widget.customerName,
      message: text,
      roomId: widget.roomId,
      subCollection: widget.subCollection,
      receiverId: widget.reciverId,
      senderId: widget.senderId,
      isFirstMessage: isNewSession,
    );

    _messageController.clear();
    _scrollToBottom();
  }

  // Future<void> _sendMedia() async {
  //   if (_isCompleted) return;

  //   final picked = await FilePicker.platform.pickFiles(type: FileType.image);
  //   if (picked == null || picked.files.isEmpty) return;

  //   final file = picked.files.single;
  //   if (file.path == null) {
  //     Get.snackbar("Upload Media", "Invalid image path");
  //     return;
  //   }

  //   _uploadProgress.value = 0.0;
  //   _localUploadPath.value = file.path!;
  //   _isUploading.value = true;
  //   _scrollToBottom();

  //   final imageFile = File(file.path!);

  //   await FreeFirebaseServiceRequest.uploadMedia(
  //         file: imageFile,
  //         onProgress: (p) => _uploadProgress.value = p.clamp(0.0, 1.0),
  //       )
  //       .then((resp) async {
  //         _isUploading.value = false;

  //         void reset() {
  //           _localUploadPath.value = '';
  //           _uploadProgress.value = 0.0;
  //         }

  //         if (resp.status == true && (resp.mediaUrl?.isNotEmpty ?? false)) {
  //           final url = resp.mediaUrl!;

  //           final meta = await FirebaseFirestore.instance
  //               .collection('free_chat_session')
  //               .doc(widget.roomId)
  //               .get();

  //           if (!meta.exists || meta.data() == null) {
  //             reset();
  //             return;
  //           }

  //           final data = meta.data()!;
  //           final String chatStatus = (data['status'] ?? "") as String;
  //           final bool isNewSession = data['is_new_session'] is bool
  //               ? data['is_new_session'] as bool
  //               : false;

  //           if (chatStatus == "Completed") {
  //             reset();
  //             if (!_isCompletionPopupVisible) _showCompletedPopup();
  //             return;
  //           }

  //           await FreeFirebaseServiceRequest.sendMediaMessage(
  //             sessionId: widget.sessionId,
  //             isFirstMessage: isNewSession,
  //             customerName: widget.customerName,
  //             roomId: widget.roomId,
  //             subCollection: widget.subCollection,
  //             receiverId: widget.reciverId,
  //             senderId: widget.senderId,
  //             mediaUrl: url,
  //           );

  //           reset();
  //           _scrollToBottom();
  //         } else {
  //           reset();
  //           Get.snackbar("Upload Media", resp.message ?? "Upload failed");
  //         }
  //       })
  //       .catchError((e) {
  //         _isUploading.value = false;
  //         _localUploadPath.value = '';
  //         _uploadProgress.value = 0.0;
  //         Get.snackbar("Upload Media", "Error: $e");
  //       });
  // }
  Future<void> _sendMedia() async {
    if (_isCompleted) {
      print("⚠️ Chat completed. Aborting.");
      return;
    }

    // ✅ Step 1: Permission check
    PermissionStatus status;
    print("🟢 Step 1: Checking permission...");

    if (Platform.isAndroid) {
      if (await Permission.photos.isGranted ||
          await Permission.storage.isGranted ||
          await Permission.mediaLibrary.isGranted) {
        status = PermissionStatus.granted;
      } else {
        print("🔄 Requesting Android permission...");
        status = await Permission.photos.request();
        if (status.isDenied) status = await Permission.storage.request();
      }
    } else {
      print("🔄 Requesting iOS photo permission...");
      status = await Permission.photos.request();
    }

    print("📋 Permission status: $status");

    if (status.isDenied) {
      print("❌ Permission denied");
      Get.snackbar("Permission Required", "Please allow media access.");
      return;
    }

    if (status.isPermanentlyDenied) {
      print("🚫 Permission permanently denied");
      await openAppSettings();
      return;
    }

    // ✅ Step 2: File picker
    print("🟢 Step 2: Opening FilePicker...");
    final picked = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['jpg', 'jpeg', 'png'],
      withData: true, // <-- ensures bytes are available if no path
    );

    if (picked == null || picked.files.isEmpty) {
      print("⚠️ No file selected.");
      return;
    }

    final file = picked.files.single;
    print("📁 File name: ${file.name}");
    print("📂 File path: ${file.path}");
    print("📦 File bytes: ${file.bytes != null}");

    // ✅ Step 3: Path or bytes check
    File? imageFile;
    if (file.path != null) {
      imageFile = File(file.path!);
    } else if (file.bytes != null) {
      final tempDir = await getTemporaryDirectory();
      final tempPath = "${tempDir.path}/${file.name}";
      imageFile = await File(tempPath).writeAsBytes(file.bytes!);
      print("📄 Created temp file: $tempPath");
    } else {
      print("❌ No valid path or bytes found.");
      Get.snackbar("Upload Media", "Unable to read selected image.");
      return;
    }

    // ✅ Step 4: Upload setup
    _uploadProgress.value = 0.0;
    _localUploadPath.value = imageFile.path;
    _isUploading.value = true;
    _scrollToBottom();

    print("🚀 Upload starting: ${imageFile.path}");

    try {
      final resp = await FreeFirebaseServiceRequest.uploadMedia(
        file: imageFile,
        onProgress: (p) {
          final progress = p.clamp(0.0, 1.0);
          _uploadProgress.value = progress;
          print("⬆️ Upload progress: ${(progress * 100).toStringAsFixed(2)}%");
        },
      );

      _isUploading.value = false;
      print(
        "✅ Upload response -> status: ${resp.status}, url: ${resp.mediaUrl}, message: ${resp.message}",
      );

      void reset() {
        print("🔁 Resetting local upload state...");
        _localUploadPath.value = '';
        _uploadProgress.value = 0.0;
      }

      if (resp.status == true && (resp.mediaUrl?.isNotEmpty ?? false)) {
        final url = resp.mediaUrl!;
        print("🌐 Uploaded URL: $url");

        final meta = await FirebaseFirestore.instance
            .collection('free_chat_session')
            .doc(widget.roomId)
            .get();

        print("📄 Firestore meta fetched: ${meta.exists}");

        if (!meta.exists || meta.data() == null) {
          reset();
          return;
        }

        final data = meta.data()!;
        final chatStatus = (data['status'] ?? "") as String;
        final isNewSession =
            data['is_new_session'] is bool && (data['is_new_session'] as bool);

        print("💬 Chat status: $chatStatus | isNewSession: $isNewSession");

        if (chatStatus == "Completed") {
          print("⚠️ Chat already completed.");
          reset();
          if (!_isCompletionPopupVisible) _showCompletedPopup();
          return;
        }

        await FreeFirebaseServiceRequest.sendMediaMessage(
          sessionId: widget.sessionId,
          isFirstMessage: isNewSession,
          customerName: widget.customerName,
          roomId: widget.roomId,
          subCollection: widget.subCollection,
          receiverId: widget.reciverId,
          senderId: widget.senderId,
          mediaUrl: url,
        );

        print("✅ Media message sent successfully.");
        reset();
        _scrollToBottom();
      } else {
        print("❌ Upload failed: ${resp.message}");
        reset();
        Get.snackbar("Upload Media", resp.message ?? "Upload failed");
      }
    } catch (e) {
      print("🔥 Upload error: $e");
      _isUploading.value = false;
      _localUploadPath.value = '';
      _uploadProgress.value = 0.0;
      Get.snackbar("Upload Media", "Error: $e");
    }

    print("🏁 _sendMedia() finished.");
  }

  Future<void> _markSeen(ChatMessageModel msg) async {
    if (!msg.isSeen && msg.receiverId == widget.senderId) {
      await FreeFirebaseServiceRequest.markAsSeen(
        msgId: msg.id,
        roomId: widget.roomId,
        subCollection: widget.subCollection,
      );
    }
  }

  // ------------------ Popups / Loader ------------------
  void _showLoader() {
    if (!mounted) return;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => circularProgress(),
    );
  }

  void _showExitPopup() {
    if (_isCompleted || _isExitPopupVisible || !mounted) return;

    _isExitPopupVisible = true;

    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (dialogContext) => WillPopScope(
        onWillPop: () async => false, // Disable back button
        child: AlertDialog(
          backgroundColor: const Color(0xFF221d25),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          title: const Text(
            "Exit Chat?",
            style: TextStyle(fontFamily: productSans, color: white),
          ),
          content: const Text(
            "Do you really want to end this chat?",
            style: TextStyle(fontFamily: productSans, color: white),
          ),
          actions: [
            TextButton(
              onPressed: () {
                _isExitPopupVisible = false;
                Navigator.of(dialogContext).pop();
              },
              child: const Text(
                "Cancel",
                style: TextStyle(
                  fontFamily: productSans,
                  color: Colors.white70,
                ),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              onPressed: () async {
                Navigator.of(dialogContext).pop(); // close confirm
                _showLoader();

                try {
                  // prevent completed popup from our own update
                  _isUserEndingChat = true;
                  await _sessionSub?.cancel();

                  final result = await _homeController.endChat(
                    customerId: widget.reciverId,
                    durationSeconds: int.tryParse(widget.remaingTime) ?? 0,
                    expertId: widget.senderId,
                    notes: "Chat ended by user",
                  );

                  if (!mounted) return;
                  Navigator.of(
                    context,
                    rootNavigator: true,
                  ).pop(); // hide loader

                  if (result.status == true) {
                    SocketService().dispose();
                    _isExitPopupVisible = false;
                    Navigator.of(context).pop(true); // leave screen
                  } else {
                    // restore listener if API failed
                    _isUserEndingChat = false;
                    _listenToSessionStatus();
                    Get.snackbar("End Chat", "Failed to end chat. Try again.");
                  }
                } catch (e) {
                  if (mounted) {
                    _isUserEndingChat = false;
                    _listenToSessionStatus();
                    Navigator.of(context, rootNavigator: true).pop();
                    Get.snackbar("End Chat", "Error: $e");
                  }
                }
              },
              child: const Text(
                "End Chat",
                style: TextStyle(fontFamily: productSans, color: white),
              ),
            ),
          ],
        ),
      ),
    ).then((_) => _isExitPopupVisible = false);
  }

  void _showCompletedPopup() {
    if (_isCompletionPopupVisible || !mounted || _isCompleted) return;

    _isCompletionPopupVisible = true;

    showDialog(
      context: context,
      barrierDismissible: false, // prevent tap-outside dismissal
      // ignore: deprecated_member_use
      builder: (dialogContext) => WillPopScope(
        onWillPop: () async => false, // Disable back button
        child: AlertDialog(
          backgroundColor: const Color(0xFF221d25),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          title: const Text(
            "Session Completed",
            style: TextStyle(fontFamily: productSans, color: white),
          ),
          content: const Text(
            "Your session has been completed successfully.",
            style: TextStyle(fontFamily: productSans, color: white),
          ),
          actions: [
            TextButton(
              child: const Text(
                "OK",
                style: TextStyle(fontFamily: productSans, color: white),
              ),
              onPressed: () async {
                Navigator.of(dialogContext).pop(); // close popup
                _showLoader();

                try {
                  final result = await _homeController.endChat(
                    customerId: widget.reciverId,
                    durationSeconds: int.tryParse(widget.remaingTime) ?? 0,
                    expertId: widget.senderId,
                    notes: "Chat ended normally",
                  );
                  if (!mounted) return;
                  Navigator.of(
                    context,
                    rootNavigator: true,
                  ).pop(); // hide loader

                  if (result.status == true) {
                    SocketService().dispose();
                    Navigator.of(context).pop(true); // leave screen
                  }
                } catch (e) {
                  if (mounted) {
                    Navigator.of(context, rootNavigator: true).pop();
                    Get.snackbar("End Chat", "Error: $e");
                  }
                }
              },
            ),
          ],
        ),
      ),
    ).then((_) => _isCompletionPopupVisible = false);
  }

  // ------------------ Lifecycle ------------------
  @override
  void initState() {
    super.initState();
    _isCompleted = widget.sessionStatus == "Completed";
    if (!_isCompleted) {
      _listenToSessionStatus();
    }
  }

  @override
  void dispose() {
    _typingTimer?.cancel();
    if (!_isCompleted) {
      _setTyping(false);
    }
    _sessionSub?.cancel();

    _messageController.dispose();
    _messageFocusNode.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  String _formatDate(dynamic value) {
    if (value == null) return "--";

    if (value is DateTime) {
      return formatter.format(value);
    }

    // If value is String → try parsing it
    if (value is String) {
      try {
        return formatter.format(DateTime.parse(value));
      } catch (e) {
        return value; // return as-is if parsing fails
      }
    }

    return "--";
  }

  void _showCustomerDetails(User data, PartnerData? data2) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF221d25),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: Text(
          "About ${data.name ?? "--"}",
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontFamily: productSans, color: white),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _detailRow("Name", data.name ?? "--"),
            const SizedBox(height: 6),
            _detailRow(
              "Birth Date",
              (data.birthday != null) ? _formatDate(data.birthday!) : "--",
            ),
            const SizedBox(height: 6),
            _detailRow("Birth Time", data.birthTime ?? "--"),
            const SizedBox(height: 6),
            _detailRow("Birth Time Accuracy", data.birthTimeAccuracy ?? "--"),
            const SizedBox(height: 6),
            _detailRow("Birth Place", data.birthPlace ?? "--"),
            const SizedBox(height: 14),

            // ---------- PARTNER SECTION CHECK --------------
            if (data2 != null) ...[
              const Text(
                "Partner Details",
                style: TextStyle(
                  fontFamily: productSans,
                  fontSize: 16,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),

              _detailRow("Name", data2.partnerName ?? "--"),
              const SizedBox(height: 6),
              _detailRow(
                "Birth Date",
                (data2.partnerDateOfBirth != null)
                    ? _formatDate(data2.partnerDateOfBirth!)
                    : "--",
              ),
              const SizedBox(height: 6),
              _detailRow("Birth Time", data2.partnerBirthTime ?? "--"),
              const SizedBox(height: 6),
              _detailRow(
                "Birth Time Accuracy",
                data2.birthPartnerAccuracy ?? "--",
              ),
              const SizedBox(height: 6),
              _detailRow("Birth Place", data2.partnerPlaceOfBirth ?? "--"),
            ],
          ],
        ),
        actions: [
          TextButton(
            child: const Text(
              "Close",
              style: TextStyle(color: Colors.red, fontFamily: productSans),
            ),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  Widget _detailRow(dynamic title, dynamic value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          "$title:",
          style: const TextStyle(
            color: Colors.white70,
            fontFamily: productSans,
          ),
        ),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: const TextStyle(color: white, fontFamily: productSans),
          ),
        ),
      ],
    );
  }

  // ------------------ UI ------------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF221d25),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(65), // 👈 custom height
        child: AppBar(
          backgroundColor: const Color(0xFF221d25),
          elevation: 1,
          centerTitle: true,
          leadingWidth: 60,
          leading: GestureDetector(
            onTap: () => Navigator.pop(context),
            child: const Icon(Icons.arrow_back_rounded, color: Colors.white),
          ),
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Flexible(
                    child: Text(
                      widget.customerName,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 18.0,
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontFamily: productSans,
                      ),
                    ),
                  ),
                  //  const SizedBox(width: 4),
                  IconButton(
                    visualDensity: VisualDensity.compact,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    icon: const Icon(
                      Icons.info_outline,
                      color: Colors.white,
                      size: 20,
                    ),
                    onPressed: () async {
                      final userResponse = await _homeController
                          .fetchSessionDetailsData(sessionId: widget.sessionId);
                      final partnerResponse = await _homeController
                          .parterInfoModelData(userId2: widget.reciverId);

                      if (userResponse.success == true &&
                          userResponse.data != null) {
                        _showCustomerDetails(
                          userResponse.data!.user!,
                          partnerResponse.data!, // <-- pass partner model here
                        );
                      } else {
                        Get.snackbar(
                          'Data Not Found',
                          'Details could not be loaded.',
                          snackPosition: SnackPosition.TOP,
                          backgroundColor: Colors.redAccent,
                          colorText: Colors.white,
                          duration: const Duration(seconds: 2),
                        );
                      }
                    },
                  ),
                ],
              ),
              // const SizedBox(height: 4),
              if (!_isCompleted)
                StreamBuilder<int>(
                  stream: SocketService().timerStream,
                  builder: (context, snapshot) {
                    final seconds = snapshot.data ?? 0;
                    final d = Duration(seconds: seconds);
                    final h = d.inHours.toString().padLeft(2, '0');
                    final m = (d.inMinutes % 60).toString().padLeft(2, '0');
                    final s = (d.inSeconds % 60).toString().padLeft(2, '0');

                    return Text(
                      "$h:$m:$s",
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.white70,
                        fontFamily: productSans,
                        fontWeight: FontWeight.w500,
                      ),
                    );
                  },
                ),
            ],
          ),
          actions: [
            if (!_isCompleted)
              Padding(
                padding: const EdgeInsets.only(right: 12),
                child: ElevatedButton(
                  onPressed: _showExitPopup,
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
      ),
      body: Stack(
        children: [
          // background
          SizedBox(
            height: double.infinity,
            width: double.infinity,
            child: Image.asset(appBg, fit: BoxFit.fill),
          ),

          Column(
            children: [
              // Chat messages
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('free_chat')
                      .doc(widget.roomId)
                      .collection(widget.subCollection)
                      .orderBy('dateTime', descending: true)
                      .snapshots(),
                  builder: (context, snap) {
                    if (snap.connectionState == ConnectionState.waiting) {
                      return circularProgress();
                    }
                    final docs = snap.data?.docs ?? [];

                    return ValueListenableBuilder<bool>(
                      valueListenable: _isUploading,
                      builder: (context, uploading, _) {
                        if (uploading) {
                          WidgetsBinding.instance.addPostFrameCallback(
                            (_) => _scrollToBottom(),
                          );
                        }

                        final List<ChatMessageModel> all =
                            docs
                                .map((d) => ChatMessageModel.fromDocument(d))
                                .toList()
                              ..sort(
                                (a, b) => b.dateTime.compareTo(a.dateTime),
                              );

                        final entries = _buildEntriesWithHeaders(all);

                        final itemCount =
                            entries.length +
                            ((uploading && !_isCompleted) ? 1 : 0);

                        return ListView.builder(
                          reverse: true,
                          controller: _scrollController,
                          itemCount: itemCount,
                          itemBuilder: (ctx, index) {
                            // uploading bubble placeholder at top (since reverse = true)
                            if (uploading && !_isCompleted && index == 0) {
                              return ValueListenableBuilder<String>(
                                valueListenable: _localUploadPath,
                                builder: (context, path, _) =>
                                    _uploadingBubble(path),
                              );
                            }

                            final adj = (uploading && !_isCompleted)
                                ? index - 1
                                : index;
                            final entry = entries[adj];

                            if (entry.isHeader) {
                              return _dateChip(entry.headerLabel!);
                            }

                            final msg = entry.message!;
                            _markSeen(msg);

                            return MessageBubble(
                              messageTime: msg.dateTime,
                              message: msg.msg,
                              isRead: msg.isSeen,
                              isMe: msg.senderId == widget.senderId,
                              isMedia: msg.msgType == 'Media',
                              msgType: msg.msgType,
                            );
                          },
                        );
                      },
                    );
                  },
                ),
              ),

              // Typing indicator (other user)
              if (!_isCompleted)
                StreamBuilder<DocumentSnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('free_chat')
                      .doc(widget.roomId)
                      .collection('status')
                      .doc('typingStatus')
                      .snapshots(),
                  builder: (context, s) {
                    if (!s.hasData || s.data == null) {
                      return const SizedBox.shrink();
                    }
                    final data = s.data!.data() as Map<String, dynamic>?;
                    final key = 'user_${widget.reciverId}';
                    final isTyping = data?[key] == true;
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
                        : const SizedBox.shrink();
                  },
                ),

              // Input
              _isCompleted ? const SizedBox.shrink() : _inputBar(),
            ],
          ),
        ],
      ),
    );
  }

  Widget _inputBar() {
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
                focusNode: _messageFocusNode,
                onChanged: _onTypingChanged,
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
                readOnly: _isCompleted,
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

  /// Right-aligned uploading placeholder bubble with progress
  Widget _uploadingBubble(String localPath) {
    return ListTile(
      title: Align(
        alignment: Alignment.centerRight,
        child: Container(
          decoration: const BoxDecoration(
            color: primaryColor,
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(16),
              topRight: Radius.circular(16),
              topLeft: Radius.circular(16),
            ),
          ),
          padding: const EdgeInsets.all(8),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 240),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Stack(
                alignment: Alignment.center,
                children: [
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
                  // dim overlay
                  // ignore: deprecated_member_use
                  Container(color: primaryColor.withOpacity(0.35)),
                  ValueListenableBuilder<double>(
                    valueListenable: _uploadProgress,
                    builder: (_, p, __) {
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

  Widget _dateChip(String text) {
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
              text,
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
