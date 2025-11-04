// To parse this JSON data, do
//
//     final startTimerChatModel = startTimerChatModelFromJson(jsonString);

import 'dart:convert';

import 'package:astro_partner_app/utils/enum.dart';

StartTimerChatModel startTimerChatModelFromJson(String str) =>
    StartTimerChatModel.fromJson(json.decode(str));

String startTimerChatModelToJson(StartTimerChatModel data) =>
    json.encode(data.toJson());

class StartTimerChatModel {
  bool? status;
  String? message;
  String? sessionId;
  String? roomId;
  int? maxSeconds;
  String? currencySymbol;
  RequestStatus requestStatus;

  StartTimerChatModel({
    this.status,
    this.message,
    this.sessionId,
    this.roomId,
    this.maxSeconds,
    this.currencySymbol,
    this.requestStatus = RequestStatus.initial,
  });

  factory StartTimerChatModel.fromJson(Map<String, dynamic> json) =>
      StartTimerChatModel(
        status: json["status"],
        message: json["message"],
        sessionId: json["session_id"],
        roomId: json["room_id"],
        maxSeconds: json["max_seconds"],
        currencySymbol: json["currency_symbol"],
      );

  Map<String, dynamic> toJson() => {
    "status": status,
    "message": message,
    "session_id": sessionId,
    "room_id": roomId,
    "max_seconds": maxSeconds,
    "currency_symbol": currencySymbol,
  };
}
