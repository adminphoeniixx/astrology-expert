import 'dart:convert';

PushNotificationModel pushNotificationModelFromJson(String str) =>
    PushNotificationModel.fromJson(json.decode(str));

String pushNotificationModelToJson(PushNotificationModel data) =>
    json.encode(data.toJson());

class PushNotificationModel {
  final String? channelName;
  final String? image;
  final String? callerName;
  final int? callerId;
  final String? agoraToken;
  final String? redirectScreen;
  final int? targetId;
  final String? body;
  final String? type;
  final String? title;
  final String? appId;

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
    this.appId,
  });

  factory PushNotificationModel.fromJson(Map<String, dynamic> json) {
    return PushNotificationModel(
      channelName: json['channel_name'],
      image: json['image'],
      callerName: json['caller_name'],
      callerId: json['caller_id'] is int
          ? json['caller_id']
          : int.tryParse(json['caller_id']?.toString() ?? ''),
      agoraToken: json['agora_token'],
      redirectScreen: json['redirect_screen'],
      targetId: json['target_id'] is int
          ? json['target_id']
          : int.tryParse(json['target_id']?.toString() ?? ''),
      body: json['body'],
      type: json['type'],
      title: json['title'],
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
      'app_id': appId,
    };
  }
}
