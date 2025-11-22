// To parse this JSON data, do
//
//     final updateMentenceModel = updateMentenceModelFromJson(jsonString);

import 'dart:convert';

import 'package:astro_partner_app/utils/enum.dart';


UpdateMentenceModel updateMentenceModelFromJson(String str) =>
    UpdateMentenceModel.fromJson(json.decode(str));

String updateMentenceModelToJson(UpdateMentenceModel data) =>
    json.encode(data.toJson());

class UpdateMentenceModel {
  dynamic status;
  Data? data;
  RequestStatus requestStatus;

  UpdateMentenceModel({
    this.status,
    this.data,
    this.requestStatus = RequestStatus.initial,
  });

  factory UpdateMentenceModel.fromJson(Map<String, dynamic> json) =>
      UpdateMentenceModel(
        status: json["status"],
        data: json["data"] == null ? null : Data.fromJson(json["data"]),
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "data": data?.toJson(),
      };
}

class Data {
  dynamic maintenanceImage;
  bool? maintenanceMode;
  dynamic maintenanceMessage;
  dynamic androidUrl;
  bool? appUpdateEnabled;
  dynamic appUpdateImageUrl;
  dynamic iosUrl;
  dynamic updateVersion;

  Data(
      {this.maintenanceImage,
      this.maintenanceMode,
      this.maintenanceMessage,
      this.androidUrl,
      this.appUpdateEnabled,
      this.appUpdateImageUrl,
      this.iosUrl,
      this.updateVersion});

  factory Data.fromJson(Map<String, dynamic> json) => Data(
      maintenanceImage: json["maintenance_image"],
      maintenanceMode: json["maintenance_mode"],
      maintenanceMessage: json["maintenance_message"],
      androidUrl: json["android_url"],
      appUpdateEnabled: json["app_update_enabled"],
      appUpdateImageUrl: json["app_update_image_url"],
      iosUrl: json["ios_url"],
      updateVersion: json['update_version']);

  Map<String, dynamic> toJson() => {
        "maintenance_image": maintenanceImage,
        "maintenance_mode": maintenanceMode,
        "maintenance_message": maintenanceMessage,
        "android_url": androidUrl,
        "app_update_enabled": appUpdateEnabled,
        "app_update_image_url": appUpdateImageUrl,
        "ios_url": iosUrl,
        'update_version': updateVersion
      };
}
