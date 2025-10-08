import 'dart:convert';

PushNotificationModel pushNotificationModelFromJson(String str) =>
    PushNotificationModel.fromJson(json.decode(str));

String pushNotificationModelToJson(PushNotificationModel data) =>
    json.encode(data.toJson());

class PushNotificationModel {
  final dynamic channelName;
  final dynamic image;
  final dynamic callerName;
  final dynamic callerId;
  final dynamic agoraToken;
  final dynamic redirectScreen;
  final dynamic targetId;
  final dynamic body;
  final dynamic type;
  final dynamic title;
  final dynamic remainingSeconds;
  final dynamic appId;

  PushNotificationModel({
    this.channelName,
    this.image,
    this.callerName,
    this.callerId,
    this.agoraToken,
    this.redirectScreen,
    this.targetId,
    this.body,
    this.type,
    this.title,
    this.remainingSeconds,
    this.appId,
  });

  factory PushNotificationModel.fromJson(Map<String, dynamic> json) {
    return PushNotificationModel(
      channelName: json['channel_name'],
      image: json['image'],
      callerName: json['caller_name'],
      callerId: json['caller_id'],
      agoraToken: json['agora_token'],
      redirectScreen: json['redirect_screen'],
      targetId: json['target_id'],
      body: json['body'],
      type: json['type'],
      title: json['title'],
      remainingSeconds: json['remaining_seconds'],
      appId: json['app_id'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'channel_name': channelName,
      'image': image,
      'caller_name': callerName,
      'caller_id': callerId,
      'agora_token': agoraToken,
      'redirect_screen': redirectScreen,
      'target_id': targetId,
      'body': body,
      'type': type,
      'title': title,
      'remaining_seconds': remainingSeconds,
      'app_id': appId,
    };
  }
}
