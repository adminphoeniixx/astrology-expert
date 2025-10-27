import 'package:astro_partner_app/constants/colors_const.dart';
import 'package:astro_partner_app/helper/screen_navigator.dart';
import 'package:astro_partner_app/widgets/firebase_chat_widget/document_view_widget.dart';
import 'package:astro_partner_app/widgets/firebase_chat_widget/image_view_widget.dart';
import 'package:astro_partner_app/widgets/video_player/video_player_vertical.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class MessageBubble extends StatelessWidget {
  final String message;
  final bool isMe;
  final bool isMedia;
  final dynamic messageTime;
  final Color? bgColor;
  final bool isRead;
  final bool showTime;
  final String msgType;

  const MessageBubble({
    required this.message,
    required this.isMe,
    this.isMedia = false,
    required this.messageTime,
    this.bgColor,
    required this.isRead,
    this.showTime = true,
    required this.msgType,
    super.key,
  });

  String _formatMessageTime(dynamic time) {
    late DateTime dateTime;

    if (time is Timestamp) {
      dateTime = time.toDate();
    } else if (time is DateTime) {
      dateTime = time;
    } else if (time is String && time.isNotEmpty) {
      try {
        dateTime = DateTime.parse(time);
      } catch (_) {
        dateTime = DateTime.now();
      }
    } else {
      dateTime = DateTime.now();
    }

    int hour = dateTime.hour % 12;
    final String amPm = dateTime.hour >= 12 ? 'PM' : 'AM';
    hour = hour == 0 ? 12 : hour;

    return "${hour.toString().padLeft(2, '0')}:"
        "${dateTime.minute.toString().padLeft(2, '0')}:"
        "${dateTime.second.toString().padLeft(2, '0')} $amPm";
  }

  // String _formatMessageTime(dynamic time) {
  //   DateTime dateTime = time.toDate(); // ✅ Convert Timestamp to DateTime
  //   final int hour = dateTime.hour % 12;
  //   final String amPm = dateTime.hour >= 12 ? 'PM' : 'AM';
  //   return "${hour == 0 ? 12 : hour}:${dateTime.minute.toString().padLeft(2, '0')} $amPm";
  // }

  // String _formatMessageTime(Timestamp time) {
  //   DateTime dateTime = time.toDate(); // ✅ Convert Timestamp to DateTime
  //   final int hour = dateTime.hour % 12;
  //   final String amPm = dateTime.hour >= 12 ? 'PM' : 'AM';
  //   return "${hour == 0 ? 12 : hour}:${dateTime.minute.toString().padLeft(2, '0')}:${dateTime.second.toString().padLeft(2, '0')} $amPm";
  // }

  // String _formatMessageTime(Timestamp time) {
  //   DateTime dateTime = time.toDate(); // ✅ Convert Timestamp to DateTime
  //   final int hour = dateTime.hour % 12;
  //   final String amPm = dateTime.hour >= 12 ? 'PM' : 'AM';
  //   return "${hour == 0 ? 12 : hour}:${dateTime.minute.toString().padLeft(2, '0')}:${dateTime.second.toString().padLeft(2, '0')} $amPm";
  // }
  // Basic file extension check
  String? _getFileExtension(String url) {
    final parts = url.split('.');
    if (parts.length > 1) {
      return parts.last.toLowerCase();
    }
    return null;
  }

  // Helper function to detect the media type based on the URL extension
  Widget _buildMediaContent(String mediaUrl, BuildContext context) {
    final extension = _getFileExtension(mediaUrl);
    if (extension == 'jpg' ||
        extension == 'jpeg' ||
        extension == 'png' ||
        extension == 'gif') {
      // If it's an image
      return GestureDetector(
        onTap: () {
          changeScreen(context, FullScreenImage(imageUrl: mediaUrl));
        },
        child: SizedBox(
          width: MediaQuery.sizeOf(context).width / 2,
          child: Image.network(
            mediaUrl,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return const Text('Error loading image');
            },
          ),
        ),
      );
    } else if (extension == 'mp4' || extension == 'mov' || extension == 'avi') {
      // If it's a video
      return GestureDetector(
        onTap: () {
          changeScreen(
            context,
            VideoPlayerVertical(thumbUrl: '', videoUrl: mediaUrl, videoId: 0),
          );
        },
        child: VideoPlayerWidget(url: mediaUrl),
      );
    } else if (extension == 'pdf' ||
        extension == 'docx' ||
        extension == 'txt') {
      // If it's a document
      return GestureDetector(
        onTap: () {
          changeScreen(context, FileViewerScreen(filePath: mediaUrl));
        },
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.insert_drive_file,
              color: isMe ? Colors.white : Colors.black,
            ),
            const SizedBox(width: 8),
            Builder(
              builder: (context) {
                return Text(
                  "Document: ${mediaUrl.split('/').last}",
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: isMe ? Colors.white : Colors.black),
                );
              },
            ),
          ],
        ),
      );
    } else {
      return const Text('Unsupported media type');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: bgColor ?? (isMe ? primaryColor : const Color(0xFF221d25)),
          border: Border.all(
            color: bgColor ?? (isMe ? primaryColor : const Color(0xFF221d25)),
          ),
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(12),
            topRight: const Radius.circular(12),
            bottomLeft: Radius.circular(isMe ? 12 : 0),
            bottomRight: Radius.circular(isMe ? 0 : 12),
          ),
        ),
        child: Column(
          crossAxisAlignment: isMe
              ? CrossAxisAlignment.end
              : CrossAxisAlignment.start,
          children: [
            // ignore: unnecessary_null_comparison
            isMedia && message != null
                ? _buildMediaContent(message, context)
                : Text(
                    message,
                    style: TextStyle(color: isMe ? Colors.black : primaryColor),
                  ),

            const SizedBox(height: 5),
            showTime
                ? Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _formatMessageTime(messageTime),
                        style: TextStyle(
                          fontSize: 10,
                          color: isMe ? Colors.black : primaryColor,
                        ),
                      ),
                      if (isMe) ...[
                        const SizedBox(width: 4),
                        Icon(
                          isRead ? Icons.done_all : Icons.check,
                          size: 14,
                          color: isRead ? black : black,
                        ),
                      ],
                    ],
                  )
                : const SizedBox(),
          ],
        ),
      ),
    );
  }
}

// Custom video player widget for handling video URLs
class VideoPlayerWidget extends StatefulWidget {
  final String url;
  const VideoPlayerWidget({required this.url, super.key});

  @override
  // ignore: library_private_types_in_public_api
  _VideoPlayerWidgetState createState() => _VideoPlayerWidgetState();
}

class _VideoPlayerWidgetState extends State<VideoPlayerWidget> {
  late VideoPlayerController _controller;

  @override
  void initState() {
    super.initState();
    // ignore: deprecated_member_use
    _controller = VideoPlayerController.network(widget.url)
      ..initialize().then((_) {
        setState(() {});
        _controller.play(); // Autoplay video when loaded
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: MediaQuery.sizeOf(context).width / 2,
      child: _controller.value.isInitialized
          ? AspectRatio(
              aspectRatio: _controller.value.aspectRatio,
              child: VideoPlayer(_controller),
            )
          : const SizedBox(),
    );
  }
}
