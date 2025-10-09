// To parse this JSON data, do
//
//     final sessionChatModel = sessionChatModelFromJson(jsonString);

import 'dart:convert';

import 'package:astro_partner_app/utils/enum.dart';

SessionChatModel sessionChatModelFromJson(String str) =>
    SessionChatModel.fromJson(json.decode(str));

String sessionChatModelToJson(SessionChatModel data) =>
    json.encode(data.toJson());

class SessionChatModel {
  bool? success;
  dynamic message;
  Session? session;
  Pricing? pricing;
  RequestStatus requestStatus;

  SessionChatModel({
    this.success,
    this.message,
    this.session,
    this.pricing,
    this.requestStatus = RequestStatus.initial,
  });

  factory SessionChatModel.fromJson(
    Map<String, dynamic> json,
  ) => SessionChatModel(
    success: json["success"],
    message: json["message"],
    session: json["session"] == null ? null : Session.fromJson(json["session"]),
    pricing: json["pricing"] == null ? null : Pricing.fromJson(json["pricing"]),
  );

  Map<String, dynamic> toJson() => {
    "success": success,
    "message": message,
    "session": session?.toJson(),
    "pricing": pricing?.toJson(),
  };
}

class Pricing {
  dynamic serviceType;
  dynamic pricePer15;
  dynamic pricePerMin;
  double? walletBalance;
  dynamic paidMaxMinutes;
  dynamic remainingSeconds;

  Pricing({
    this.serviceType,
    this.pricePer15,
    this.pricePerMin,
    this.walletBalance,
    this.paidMaxMinutes,
    this.remainingSeconds,
  });

  factory Pricing.fromJson(Map<String, dynamic> json) => Pricing(
    serviceType: json["service_type"],
    pricePer15: json["price_per_15"],
    pricePerMin: json["price_per_min"],
    walletBalance: json["wallet_balance"]?.toDouble(),
    paidMaxMinutes: json["paid_max_minutes"],
    remainingSeconds: json["remaining_seconds"],
  );

  Map<String, dynamic> toJson() => {
    "service_type": serviceType,
    "price_per_15": pricePer15,
    "price_per_min": pricePerMin,
    "wallet_balance": walletBalance,
    "paid_max_minutes": paidMaxMinutes,
    "remaining_seconds": remainingSeconds,
  };
}

class Session {
  dynamic orderId;
  dynamic roomId;
  dynamic token;
  dynamic userId;
  dynamic customerId;
  dynamic expertId;
  DateTime? date;
  DateTime? startDate;
  dynamic startTime;
  dynamic endTime;
  dynamic status;
  dynamic serviceType;
  dynamic customerName;
  dynamic serviceName;
  dynamic astrologerName;
  dynamic astrologerImage;
  dynamic preferLanguage;
  dynamic sessionTime;
  dynamic notes;
  DateTime? updatedAt;
  DateTime? createdAt;
  dynamic id;

  Session({
    this.orderId,
    this.roomId,
    this.token,
    this.userId,
    this.customerId,
    this.expertId,
    this.date,
    this.startDate,
    this.startTime,
    this.endTime,
    this.status,
    this.serviceType,
    this.customerName,
    this.serviceName,
    this.astrologerName,
    this.astrologerImage,
    this.preferLanguage,
    this.sessionTime,
    this.notes,
    this.updatedAt,
    this.createdAt,
    this.id,
  });

  factory Session.fromJson(Map<String, dynamic> json) => Session(
    orderId: json["order_id"],
    roomId: json["room_id"],
    token: json["token"],
    userId: json["user_id"],
    customerId: json["customer_id"],
    expertId: json["expert_id"],
    date: json["date"] == null ? null : DateTime.parse(json["date"]),
    startDate: json["start_date"] == null
        ? null
        : DateTime.parse(json["start_date"]),
    startTime: json["start_time"],
    endTime: json["end_time"],
    status: json["status"],
    serviceType: json["service_type"],
    customerName: json["customer_name"],
    serviceName: json["service_name"],
    astrologerName: json["astrologer_name"],
    astrologerImage: json["astrologer_image"],
    preferLanguage: json["prefer_language"],
    sessionTime: json["session_time"],
    notes: json["notes"],
    updatedAt: json["updated_at"] == null
        ? null
        : DateTime.parse(json["updated_at"]),
    createdAt: json["created_at"] == null
        ? null
        : DateTime.parse(json["created_at"]),
    id: json["id"],
  );

  Map<String, dynamic> toJson() => {
    "order_id": orderId,
    "room_id": roomId,
    "token": token,
    "user_id": userId,
    "customer_id": customerId,
    "expert_id": expertId,
    "date":
        "${date!.year.toString().padLeft(4, '0')}-${date!.month.toString().padLeft(2, '0')}-${date!.day.toString().padLeft(2, '0')}",
    "start_date":
        "${startDate!.year.toString().padLeft(4, '0')}-${startDate!.month.toString().padLeft(2, '0')}-${startDate!.day.toString().padLeft(2, '0')}",
    "start_time": startTime,
    "end_time": endTime,
    "status": status,
    "service_type": serviceType,
    "customer_name": customerName,
    "service_name": serviceName,
    "astrologer_name": astrologerName,
    "astrologer_image": astrologerImage,
    "prefer_language": preferLanguage,
    "session_time": sessionTime,
    "notes": notes,
    "updated_at": updatedAt?.toIso8601String(),
    "created_at": createdAt?.toIso8601String(),
    "id": id,
  };
}
