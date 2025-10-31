// To parse this JSON data, do
//
//     final socketVerifyModel = socketVerifyModelFromJson(jsonString);

import 'dart:convert';

import 'package:astro_partner_app/utils/enum.dart';

SocketVerifyModel socketVerifyModelFromJson(String str) =>
    SocketVerifyModel.fromJson(json.decode(str));

String socketVerifyModelToJson(SocketVerifyModel data) =>
    json.encode(data.toJson());

class SocketVerifyModel {
  String? auth;
  RequestStatus requestStatus;

  SocketVerifyModel({this.auth, this.requestStatus = RequestStatus.initial});

  factory SocketVerifyModel.fromJson(Map<String, dynamic> json) =>
      SocketVerifyModel(auth: json["auth"]);

  Map<String, dynamic> toJson() => {"auth": auth};
}
