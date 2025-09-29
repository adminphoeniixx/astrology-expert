// To parse this JSON data, do
//
//     final chatSessionModel = chatSessionModelFromJson(jsonString);

import 'dart:convert';

import 'package:astro_partner_app/utils/enum.dart';

ChatSessionModel chatSessionModelFromJson(String str) =>
    ChatSessionModel.fromJson(json.decode(str));

String chatSessionModelToJson(ChatSessionModel data) =>
    json.encode(data.toJson());

class ChatSessionModel {
  bool? status;
  String? message;
  Session? session;
  String? joinStatus;
  String? chatSessionUrl;
  String? totalTime;
  String? startTime;
  String? endTime;
  RequestStatus requestStatus;

  ChatSessionModel(
      {this.status,
      this.message,
      this.session,
      this.joinStatus,
      this.chatSessionUrl,
      this.totalTime,
      this.startTime,
      this.endTime,
      this.requestStatus = RequestStatus.initial});

  factory ChatSessionModel.fromJson(Map<String, dynamic> json) =>
      ChatSessionModel(
        status: json["status"],
        message: json["message"],
        joinStatus: json["join_status"],
        session:
            json["session"] == null ? null : Session.fromJson(json["session"]),
        chatSessionUrl: json["chat_session_url"],
        totalTime: json["total_time"],
        startTime: json["start_time"],
        endTime: json["end_time"],
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "message": message,
        "join_status":joinStatus,
        "session": session?.toJson(),
        "chat_session_url": chatSessionUrl,
        "total_time": totalTime,
        "start_time": startTime,
        "end_time": endTime,
      };
}

class Session {
  int? id;
  int? orderId;
  String? roomId;
  dynamic token;
  int? userId;
  dynamic startDate;
  String? startTime;
  String? status;
  DateTime? createdAt;
  DateTime? updatedAt;
  DateTime? date;
  String? customerName;
  String? serviceName;
  int? expertId;
  String? serviceType;
  dynamic audioFile;
  String? astrologerName;
  String? astrologerImage;
  String? sessionTime;
  String? endTime;

  Session({
    this.id,
    this.orderId,
    this.roomId,
    this.token,
    this.userId,
    this.startDate,
    this.startTime,
    this.status,
    this.createdAt,
    this.updatedAt,
    this.date,
    this.customerName,
    this.serviceName,
    this.expertId,
    this.serviceType,
    this.audioFile,
    this.astrologerName,
    this.astrologerImage,
    this.sessionTime,
    this.endTime,
  });

  factory Session.fromJson(Map<String, dynamic> json) => Session(
        id: json["id"],
        orderId: json["order_id"],
        roomId: json["room_id"],
        token: json["token"],
        userId: json["user_id"],
        startDate: json["start_date"],
        startTime: json["start_time"],
        status: json["status"],
        createdAt: json["created_at"] == null
            ? null
            : DateTime.parse(json["created_at"]),
        updatedAt: json["updated_at"] == null
            ? null
            : DateTime.parse(json["updated_at"]),
        date: json["date"] == null ? null : DateTime.parse(json["date"]),
        customerName: json["customer_name"],
        serviceName: json["service_name"],
        expertId: json["expert_id"],
        serviceType: json["service_type"],
        audioFile: json["audio_file"],
        astrologerName: json["astrologer_name"],
        astrologerImage: json["astrologer_image"],
        sessionTime: json["session_time"],
        endTime: json["end_time"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "order_id": orderId,
        "room_id": roomId,
        "token": token,
        "user_id": userId,
        "start_date": startDate,
        "start_time": startTime,
        "status": status,
        "created_at": createdAt?.toIso8601String(),
        "updated_at": updatedAt?.toIso8601String(),
        "date":
            "${date!.year.toString().padLeft(4, '0')}-${date!.month.toString().padLeft(2, '0')}-${date!.day.toString().padLeft(2, '0')}",
        "customer_name": customerName,
        "service_name": serviceName,
        "expert_id": expertId,
        "service_type": serviceType,
        "audio_file": audioFile,
        "astrologer_name": astrologerName,
        "astrologer_image": astrologerImage,
        "session_time": sessionTime,
        "end_time": endTime,
      };
}
