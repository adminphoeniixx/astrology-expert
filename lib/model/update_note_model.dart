// To parse this JSON data, do
//
//     final updateNoteModel = updateNoteModelFromJson(jsonString);

import 'dart:convert';

import 'package:astro_partner_app/utils/enum.dart';

UpdateNoteModel updateNoteModelFromJson(String str) =>
    UpdateNoteModel.fromJson(json.decode(str));

String updateNoteModelToJson(UpdateNoteModel data) =>
    json.encode(data.toJson());

class UpdateNoteModel {
  bool? success;
  String? message;
  Data? data;
  String? currencySymbol;
  RequestStatus requestStatus;

  UpdateNoteModel({
    this.success,
    this.message,
    this.data,
    this.currencySymbol,
    this.requestStatus = RequestStatus.initial,
  });

  factory UpdateNoteModel.fromJson(Map<String, dynamic> json) =>
      UpdateNoteModel(
        success: json["success"],
        message: json["message"],
        data: json["data"] == null ? null : Data.fromJson(json["data"]),
        currencySymbol: json["currency_symbol"],
      );

  Map<String, dynamic> toJson() => {
    "success": success,
    "message": message,
    "data": data?.toJson(),
    "currency_symbol": currencySymbol,
  };
}

class Data {
  int? id;
  String? notes;
  DateTime? updatedAt;

  Data({this.id, this.notes, this.updatedAt});

  factory Data.fromJson(Map<String, dynamic> json) => Data(
    id: json["id"],
    notes: json["notes"],
    updatedAt: json["updated_at"] == null
        ? null
        : DateTime.parse(json["updated_at"]),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "notes": notes,
    "updated_at": updatedAt?.toIso8601String(),
  };
}
