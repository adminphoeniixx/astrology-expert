import 'package:cloud_firestore/cloud_firestore.dart';

class ChatMessageModel {
  final dynamic id;
  final dynamic msg;
  final Timestamp dateTime;
  final bool isSeen;
  final dynamic msgType; // "media" or other types like "text"
  final dynamic receiverId;
  final dynamic senderId;
  final bool isFirstMessage;

  ChatMessageModel({
    required this.id,
    required this.msg,
    required this.dateTime,
    required this.isSeen,
    required this.msgType,
    required this.receiverId,
    required this.isFirstMessage,
    required this.senderId,
  });

  // Factory constructor to create a ChatMessage from Firestore data
  factory ChatMessageModel.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<dynamic, dynamic>;
    return ChatMessageModel(
      id: doc.id,
      msg: data['msg'] ?? '',
      dateTime: data['dateTime'] ?? "",
      isFirstMessage: data['is_first_message'] ?? false,
      isSeen: data['isSeen'] ?? false,
      msgType: data['msgType'] ?? 'text',
      receiverId: data['receiverId'] ?? '',
      senderId: data['senderId'] ?? '',
    );
  }
}
