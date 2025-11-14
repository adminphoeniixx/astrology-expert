// To parse this JSON data, do
//
//     final parterInfoModel = parterInfoModelFromJson(jsonString);

import 'dart:convert';

import 'package:astro_partner_app/utils/enum.dart';

ParterInfoModel parterInfoModelFromJson(String str) =>
    ParterInfoModel.fromJson(json.decode(str));

String parterInfoModelToJson(ParterInfoModel data) =>
    json.encode(data.toJson());

class ParterInfoModel {
  bool? status;
  dynamic message;
  PartnerData? data;
  dynamic currencySymbol;
  RequestStatus requestStatus;

  ParterInfoModel({
    this.status,
    this.message,
    this.data,
    this.currencySymbol,
    this.requestStatus = RequestStatus.initial,
  });

  factory ParterInfoModel.fromJson(Map<String, dynamic> json) =>
      ParterInfoModel(
        status: json["status"],
        message: json["message"],
        data: json["data"] == null ? null : PartnerData.fromJson(json["data"]),
        currencySymbol: json["currency_symbol"],
      );

  Map<String, dynamic> toJson() => {
    "status": status,
    "message": message,
    "data": data?.toJson(),
    "currency_symbol": currencySymbol,
  };
}

class PartnerData {
  int? userId;
  dynamic partnerName;
  DateTime? partnerDateOfBirth;
  dynamic partnerBirthTime;
  dynamic partnerPlaceOfBirth;
  dynamic birthPartnerAccuracy;
  dynamic partnerGender;
  DateTime? updatedAt;
  DateTime? createdAt;
  dynamic id;

  PartnerData({
    this.userId,
    this.partnerName,
    this.partnerDateOfBirth,
    this.partnerBirthTime,
    this.partnerPlaceOfBirth,
    this.birthPartnerAccuracy,
    this.partnerGender,
    this.updatedAt,
    this.createdAt,
    this.id,
  });

  factory PartnerData.fromJson(Map<String, dynamic> json) => PartnerData(
    userId: json["user_id"],
    partnerName: json["partner_name"],
    partnerDateOfBirth: json["partner_date_of_birth"] == null
        ? null
        : DateTime.parse(json["partner_date_of_birth"]),
    partnerBirthTime: json["partner_birth_time"],
    partnerPlaceOfBirth: json["partner_place_of_birth"],
    birthPartnerAccuracy: json["birth_partner_accuracy"],
    partnerGender: json["partner_gender"],
    updatedAt: json["updated_at"] == null
        ? null
        : DateTime.parse(json["updated_at"]),
    createdAt: json["created_at"] == null
        ? null
        : DateTime.parse(json["created_at"]),
    id: json["id"],
  );

  Map<String, dynamic> toJson() => {
    "user_id": userId,
    "partner_name": partnerName,
    "partner_date_of_birth":
        "${partnerDateOfBirth!.year.toString().padLeft(4, '0')}-${partnerDateOfBirth!.month.toString().padLeft(2, '0')}-${partnerDateOfBirth!.day.toString().padLeft(2, '0')}",
    "partner_birth_time": partnerBirthTime,
    "partner_place_of_birth": partnerPlaceOfBirth,
    "birth_partner_accuracy": birthPartnerAccuracy,
    "partner_gender": partnerGender,
    "updated_at": updatedAt?.toIso8601String(),
    "created_at": createdAt?.toIso8601String(),
    "id": id,
  };
}
