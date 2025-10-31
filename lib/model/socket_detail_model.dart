// To parse this JSON data, do
//
//     final socketDetailsModel = socketDetailsModelFromJson(jsonString);

import 'dart:convert';

import 'package:astro_partner_app/utils/enum.dart';

SocketDetailsModel socketDetailsModelFromJson(String str) =>
    SocketDetailsModel.fromJson(json.decode(str));

String socketDetailsModelToJson(SocketDetailsModel data) =>
    json.encode(data.toJson());

class SocketDetailsModel {
  bool? success;
  Soketi? soketi;
  String? currencySymbol;
  RequestStatus requestStatus;

  SocketDetailsModel({
    this.success,
    this.soketi,
    this.currencySymbol,
    this.requestStatus = RequestStatus.initial,
  });

  factory SocketDetailsModel.fromJson(Map<String, dynamic> json) =>
      SocketDetailsModel(
        success: json["success"],
        soketi: json["soketi"] == null ? null : Soketi.fromJson(json["soketi"]),
        currencySymbol: json["currency_symbol"],
      );

  Map<String, dynamic> toJson() => {
    "success": success,
    "soketi": soketi?.toJson(),
    "currency_symbol": currencySymbol,
  };
}

class Soketi {
  String? appId;
  String? key;
  String? secret;
  String? host;
  String? port;
  String? scheme;
  String? cluster;

  Soketi({
    this.appId,
    this.key,
    this.secret,
    this.host,
    this.port,
    this.scheme,
    this.cluster,
  });

  factory Soketi.fromJson(Map<String, dynamic> json) => Soketi(
    appId: json["app_id"],
    key: json["key"],
    secret: json["secret"],
    host: json["host"],
    port: json["port"],
    scheme: json["scheme"],
    cluster: json["cluster"],
  );

  Map<String, dynamic> toJson() => {
    "app_id": appId,
    "key": key,
    "secret": secret,
    "host": host,
    "port": port,
    "scheme": scheme,
    "cluster": cluster,
  };
}
