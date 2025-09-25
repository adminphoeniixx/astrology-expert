// To parse this JSON data, do
//
//     final getProfileModel = getProfileModelFromJson(jsonString);

import 'dart:convert';

import 'package:astro_partner_app/utils/enum.dart';

GetProfileModel getProfileModelFromJson(String str) =>
    GetProfileModel.fromJson(json.decode(str));

String getProfileModelToJson(GetProfileModel data) =>
    json.encode(data.toJson());

class GetProfileModel {
  bool? status;
  String? message;
  Data? data;
  String? currencySymbol;
  RequestStatus requestStatus;

  GetProfileModel({
    this.status,
    this.message,
    this.data,
    this.currencySymbol,
    this.requestStatus = RequestStatus.initial,
  });

  factory GetProfileModel.fromJson(Map<String, dynamic> json) =>
      GetProfileModel(
        status: json["status"],
        message: json["message"],
        data: json["data"] == null ? null : Data.fromJson(json["data"]),
        currencySymbol: json["currency_symbol"],
      );

  Map<String, dynamic> toJson() => {
    "status": status,
    "message": message,
    "data": data?.toJson(),
    "currency_symbol": currencySymbol,
  };
}

class Data {
  int? id;
  String? role;
  String? name;
  String? email;
  String? avatar;
  dynamic emailVerifiedAt;
  dynamic settings;
  DateTime? createdAt;
  DateTime? updatedAt;
  dynamic referralCode;
  dynamic referralCodeUsed;
  dynamic stateId;
  int? isWinningAmount;
  String? mobile;
  int? isOtpVerified;
  String? deviceToken;
  String? gender;
  dynamic city;
  dynamic birthday;
  dynamic code;
  dynamic emailOtp;
  int? isEmailVerified;
  int? profileStatus;
  int? profileCompletePercentage;
  dynamic accountNumber;
  dynamic ifscCode;
  dynamic clientName;
  dynamic clientEmail;
  dynamic clientMobile;
  dynamic clientVpa;
  dynamic appVersion;
  String? accountStatus;
  dynamic google2FaSecret;
  dynamic deletedAt;
  dynamic twoFactorConfirmedAt;
  dynamic otp;
  double? rating;
  dynamic description;
  int? slotCharges;
  int? audioRecordingCharges;
  String? experience;
  String? languages;
  String? totalReadings;
  String? availableForFreeChat;
  dynamic birthTime;
  String? availableForSupportChat;
  dynamic birthPlace;
  dynamic birthTimeAccuracy;
  String? availableForPaidChat;
  String? profilePhotoUrl;

  Data({
    this.id,
    this.role,
    this.name,
    this.email,
    this.avatar,
    this.emailVerifiedAt,
    this.settings,
    this.createdAt,
    this.updatedAt,
    this.referralCode,
    this.referralCodeUsed,
    this.stateId,
    this.isWinningAmount,
    this.mobile,
    this.isOtpVerified,
    this.deviceToken,
    this.gender,
    this.city,
    this.birthday,
    this.code,
    this.emailOtp,
    this.isEmailVerified,
    this.profileStatus,
    this.profileCompletePercentage,
    this.accountNumber,
    this.ifscCode,
    this.clientName,
    this.clientEmail,
    this.clientMobile,
    this.clientVpa,
    this.appVersion,
    this.accountStatus,
    this.google2FaSecret,
    this.deletedAt,
    this.twoFactorConfirmedAt,
    this.otp,
    this.rating,
    this.description,
    this.slotCharges,
    this.audioRecordingCharges,
    this.experience,
    this.languages,
    this.totalReadings,
    this.availableForFreeChat,
    this.birthTime,
    this.availableForSupportChat,
    this.birthPlace,
    this.birthTimeAccuracy,
    this.availableForPaidChat,
    this.profilePhotoUrl,
  });

  factory Data.fromJson(Map<String, dynamic> json) => Data(
    id: json["id"],
    role: json["role"],
    name: json["name"],
    email: json["email"],
    avatar: json["avatar"],
    emailVerifiedAt: json["email_verified_at"],
    settings: json["settings"],
    createdAt: json["created_at"] == null
        ? null
        : DateTime.parse(json["created_at"]),
    updatedAt: json["updated_at"] == null
        ? null
        : DateTime.parse(json["updated_at"]),
    referralCode: json["referral_code"],
    referralCodeUsed: json["referral_code_used"],
    stateId: json["state_id"],
    isWinningAmount: json["is_winning_amount"],
    mobile: json["mobile"],
    isOtpVerified: json["is_otp_verified"],
    deviceToken: json["device_token"],
    gender: json["gender"],
    city: json["city"],
    birthday: json["birthday"],
    code: json["code"],
    emailOtp: json["email_otp"],
    isEmailVerified: json["is_email_verified"],
    profileStatus: json["profile_status"],
    profileCompletePercentage: json["profile_complete_percentage"],
    accountNumber: json["account_number"],
    ifscCode: json["ifsc_code"],
    clientName: json["client_name"],
    clientEmail: json["client_email"],
    clientMobile: json["client_mobile"],
    clientVpa: json["client_vpa"],
    appVersion: json["app_version"],
    accountStatus: json["account_status"],
    google2FaSecret: json["google2fa_secret"],
    deletedAt: json["deleted_at"],
    twoFactorConfirmedAt: json["two_factor_confirmed_at"],
    otp: json["otp"],
    rating: json["rating"]?.toDouble(),
    description: json["description"],
    slotCharges: json["slot_charges"],
    audioRecordingCharges: json["audio_recording_charges"],
    experience: json["experience"],
    languages: json["languages"],
    totalReadings: json["total_readings"],
    availableForFreeChat: json["available_for_free_chat"],
    birthTime: json["birth_time"],
    availableForSupportChat: json["available_for_support_chat"],
    birthPlace: json["birth_place"],
    birthTimeAccuracy: json["birth_time_accuracy"],
    availableForPaidChat: json["available_for_paid_chat"],
    profilePhotoUrl: json["profile_photo_url"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "role": role,
    "name": name,
    "email": email,
    "avatar": avatar,
    "email_verified_at": emailVerifiedAt,
    "settings": settings,
    "created_at": createdAt?.toIso8601String(),
    "updated_at": updatedAt?.toIso8601String(),
    "referral_code": referralCode,
    "referral_code_used": referralCodeUsed,
    "state_id": stateId,
    "is_winning_amount": isWinningAmount,
    "mobile": mobile,
    "is_otp_verified": isOtpVerified,
    "device_token": deviceToken,
    "gender": gender,
    "city": city,
    "birthday": birthday,
    "code": code,
    "email_otp": emailOtp,
    "is_email_verified": isEmailVerified,
    "profile_status": profileStatus,
    "profile_complete_percentage": profileCompletePercentage,
    "account_number": accountNumber,
    "ifsc_code": ifscCode,
    "client_name": clientName,
    "client_email": clientEmail,
    "client_mobile": clientMobile,
    "client_vpa": clientVpa,
    "app_version": appVersion,
    "account_status": accountStatus,
    "google2fa_secret": google2FaSecret,
    "deleted_at": deletedAt,
    "two_factor_confirmed_at": twoFactorConfirmedAt,
    "otp": otp,
    "rating": rating,
    "description": description,
    "slot_charges": slotCharges,
    "audio_recording_charges": audioRecordingCharges,
    "experience": experience,
    "languages": languages,
    "total_readings": totalReadings,
    "available_for_free_chat": availableForFreeChat,
    "birth_time": birthTime,
    "available_for_support_chat": availableForSupportChat,
    "birth_place": birthPlace,
    "birth_time_accuracy": birthTimeAccuracy,
    "available_for_paid_chat": availableForPaidChat,
    "profile_photo_url": profilePhotoUrl,
  };
}
