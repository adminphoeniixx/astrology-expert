// To parse this JSON data, do
//
//     final mediaUploadModel = mediaUploadModelFromJson(jsonString);

import 'dart:convert';

MediaUploadModel mediaUploadModelFromJson(String str) =>
    MediaUploadModel.fromJson(json.decode(str));

String mediaUploadModelToJson(MediaUploadModel data) =>
    json.encode(data.toJson());

class MediaUploadModel {
  bool? status;
  dynamic message;
  dynamic mediaUrl;

  MediaUploadModel({this.status, this.message, this.mediaUrl});

  factory MediaUploadModel.fromJson(Map<String, dynamic> json) =>
      MediaUploadModel(
        status: json["status"],
        message: json["message"],
        mediaUrl: json["mediaUrl"],
      );

  Map<String, dynamic> toJson() => {
    "status": status,
    "message": message,
    "mediaUrl": mediaUrl,
  };
}
