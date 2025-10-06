import 'dart:convert';

PushNotificationModel pushNotificationModelFromJson(String str) =>
    PushNotificationModel.fromJson(json.decode(str));

String pushNotificationModelToJson(PushNotificationModel data) =>
    json.encode(data.toJson());

class PushNotificationModel {
  dynamic channelName;
  dynamic callerName;
  dynamic paidMaxMinutes;
  dynamic callerId;
  dynamic agoraToken;
  dynamic agoraAppId;
  dynamic type;
  dynamic remainingSeconds;
  dynamic callerImage;

  PushNotificationModel({
    this.channelName,
    this.callerName,
    this.paidMaxMinutes,
    this.callerId,
    this.agoraToken,
    this.agoraAppId,
    this.type,
    this.remainingSeconds,
    this.callerImage,
  });

  factory PushNotificationModel.fromJson(Map<String, dynamic> json) =>
      PushNotificationModel(
        channelName: json["channel_name"],
        callerName: json["caller_name"],
        paidMaxMinutes: json["paid_max_minutes"],
        callerId: json["caller_id"],
        agoraToken: json["agora_token"],
        agoraAppId: json["agora_app_id"],
        type: json["type"],
        remainingSeconds: json["remaining_seconds"],
        callerImage: json["caller_image"],
      );

  Map<String, dynamic> toJson() => {
    "channel_name": channelName,
    "caller_name": callerName,
    "paid_max_minutes": paidMaxMinutes,
    "caller_id": callerId,
    "agora_token": agoraToken,
    "agora_app_id": agoraAppId,
    "type": type,
    "remaining_seconds": remainingSeconds,
    "caller_image": callerImage,
  };
}
