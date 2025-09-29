// To parse this JSON data, do
//
//     final sessionDetailsModel = sessionDetailsModelFromJson(jsonString);

import 'dart:convert';
import 'package:astro_partner_app/utils/enum.dart';

SessionDetailsModel sessionDetailsModelFromJson(String str) =>
    SessionDetailsModel.fromJson(json.decode(str));

String sessionDetailsModelToJson(SessionDetailsModel data) =>
    json.encode(data.toJson());

class SessionDetailsModel {
  bool? success;
  String? message;
  Data? data;
  String? currencySymbol;
  RequestStatus requestStatus;

  SessionDetailsModel({
    this.success,
    this.message,
    this.data,
    this.currencySymbol,
    this.requestStatus = RequestStatus.initial,
  });

  factory SessionDetailsModel.fromJson(Map<String, dynamic> json) =>
      SessionDetailsModel(
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
  Session? session;
  SessionDetails? details;
  List<dynamic>? attachments;
  User? user;
  String? title;

  Data({this.session, this.details, this.attachments, this.user, this.title});

  factory Data.fromJson(Map<String, dynamic> json) => Data(
    session: json["session"] == null ? null : Session.fromJson(json["session"]),
    details: json["details"] == null ? null : SessionDetails.fromJson(json["details"]),
    attachments: json["attachments"] == null
        ? []
        : List<dynamic>.from(json["attachments"]!.map((x) => x)),
    user: json["user"] == null ? null : User.fromJson(json["user"]),
    title: json["title"],
  );

  Map<String, dynamic> toJson() => {
    "session": session?.toJson(),
    "details": details?.toJson(),
    "attachments": attachments == null
        ? []
        : List<dynamic>.from(attachments!.map((x) => x)),
    "user": user?.toJson(),
    "title": title,
  };
}

class SessionDetails {
  int? id;
  int? orderId;
  DateTime? date;
  String? slots;
  String? fullName;
  String? birthTime;
  DateTime? dateOfBirth;
  String? placeOfBirth;
  dynamic rightPalmImage;
  dynamic leftPalmImage;
  dynamic consultationTime;
  DateTime? createdAt;
  DateTime? updatedAt;
  int? expertId;
  String? birthTimeAccuracy;
  dynamic partnerName;
  dynamic partnerDateOfBirth;
  dynamic partnerBirthTime;
  dynamic partnerPlaceOfBirth;
  dynamic questionDescription;
  String? birthPartnerAccuracy;
  dynamic preferLanguage;
  String? serviceTypeName;

  SessionDetails({
    this.id,
    this.orderId,
    this.date,
    this.slots,
    this.fullName,
    this.birthTime,
    this.dateOfBirth,
    this.placeOfBirth,
    this.rightPalmImage,
    this.leftPalmImage,
    this.consultationTime,
    this.createdAt,
    this.updatedAt,
    this.expertId,
    this.birthTimeAccuracy,
    this.partnerName,
    this.partnerDateOfBirth,
    this.partnerBirthTime,
    this.partnerPlaceOfBirth,
    this.questionDescription,
    this.birthPartnerAccuracy,
    this.preferLanguage,
    this.serviceTypeName,
  });

  factory SessionDetails.fromJson(Map<String, dynamic> json) => SessionDetails(
    id: json["id"],
    orderId: json["order_id"],
    date: json["date"] == null ? null : DateTime.parse(json["date"]),
    slots: json["slots"],
    fullName: json["full_name"],
    birthTime: json["birth_time"],
    dateOfBirth: json["date_of_birth"] == null
        ? null
        : DateTime.parse(json["date_of_birth"]),
    placeOfBirth: json["place_of_birth"],
    rightPalmImage: json["right_palm_image"],
    leftPalmImage: json["left_palm_image"],
    consultationTime: json["consultation_time"],
    createdAt: json["created_at"] == null
        ? null
        : DateTime.parse(json["created_at"]),
    updatedAt: json["updated_at"] == null
        ? null
        : DateTime.parse(json["updated_at"]),
    expertId: json["expert_id"],
    birthTimeAccuracy: json["birth_time_accuracy"],
    partnerName: json["partner_name"],
    partnerDateOfBirth: json["partner_date_of_birth"],
    partnerBirthTime: json["partner_birth_time"],
    partnerPlaceOfBirth: json["partner_place_of_birth"],
    questionDescription: json["question_description"],
    birthPartnerAccuracy: json["birth_partner_accuracy"],
    preferLanguage: json["prefer_language"],
    serviceTypeName: json["service_type_name"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "order_id": orderId,
    "date":
        "${date!.year.toString().padLeft(4, '0')}-${date!.month.toString().padLeft(2, '0')}-${date!.day.toString().padLeft(2, '0')}",
    "slots": slots,
    "full_name": fullName,
    "birth_time": birthTime,
    "date_of_birth":
        "${dateOfBirth!.year.toString().padLeft(4, '0')}-${dateOfBirth!.month.toString().padLeft(2, '0')}-${dateOfBirth!.day.toString().padLeft(2, '0')}",
    "place_of_birth": placeOfBirth,
    "right_palm_image": rightPalmImage,
    "left_palm_image": leftPalmImage,
    "consultation_time": consultationTime,
    "created_at": createdAt?.toIso8601String(),
    "updated_at": updatedAt?.toIso8601String(),
    "expert_id": expertId,
    "birth_time_accuracy": birthTimeAccuracy,
    "partner_name": partnerName,
    "partner_date_of_birth": partnerDateOfBirth,
    "partner_birth_time": partnerBirthTime,
    "partner_place_of_birth": partnerPlaceOfBirth,
    "question_description": questionDescription,
    "birth_partner_accuracy": birthPartnerAccuracy,
    "prefer_language": preferLanguage,
    "service_type_name": serviceTypeName,
  };
}

class Session {
  int? id;
  int? orderId;
  String? roomId;
  dynamic token;
  int? userId;
  dynamic startDate;
  dynamic startTime;
  String? status;
  DateTime? createdAt;
  DateTime? updatedAt;
  DateTime? date;
  String? customerName;
  String? serviceName;
  int? expertId;
  String? serviceType;
  dynamic audioFile;
  String? astrologerName;
  String? astrologerImage;
  String? sessionTime;
  dynamic endTime;
  dynamic notes;
  dynamic preferLanguage;

  Session({
    this.id,
    this.orderId,
    this.roomId,
    this.token,
    this.userId,
    this.startDate,
    this.startTime,
    this.status,
    this.createdAt,
    this.updatedAt,
    this.date,
    this.customerName,
    this.serviceName,
    this.expertId,
    this.serviceType,
    this.audioFile,
    this.astrologerName,
    this.astrologerImage,
    this.sessionTime,
    this.endTime,
    this.notes,
    this.preferLanguage,
  });

  factory Session.fromJson(Map<String, dynamic> json) => Session(
    id: json["id"],
    orderId: json["order_id"],
    roomId: json["room_id"],
    token: json["token"],
    userId: json["user_id"],
    startDate: json["start_date"],
    startTime: json["start_time"],
    status: json["status"],
    createdAt: json["created_at"] == null
        ? null
        : DateTime.parse(json["created_at"]),
    updatedAt: json["updated_at"] == null
        ? null
        : DateTime.parse(json["updated_at"]),
    date: json["date"] == null ? null : DateTime.parse(json["date"]),
    customerName: json["customer_name"],
    serviceName: json["service_name"],
    expertId: json["expert_id"],
    serviceType: json["service_type"],
    audioFile: json["audio_file"],
    astrologerName: json["astrologer_name"],
    astrologerImage: json["astrologer_image"],
    sessionTime: json["session_time"],
    endTime: json["end_time"],
    notes: json["notes"],
    preferLanguage: json["prefer_language"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "order_id": orderId,
    "room_id": roomId,
    "token": token,
    "user_id": userId,
    "start_date": startDate,
    "start_time": startTime,
    "status": status,
    "created_at": createdAt?.toIso8601String(),
    "updated_at": updatedAt?.toIso8601String(),
    "date":
        "${date!.year.toString().padLeft(4, '0')}-${date!.month.toString().padLeft(2, '0')}-${date!.day.toString().padLeft(2, '0')}",
    "customer_name": customerName,
    "service_name": serviceName,
    "expert_id": expertId,
    "service_type": serviceType,
    "audio_file": audioFile,
    "astrologer_name": astrologerName,
    "astrologer_image": astrologerImage,
    "session_time": sessionTime,
    "end_time": endTime,
    "notes": notes,
    "prefer_language": preferLanguage,
  };
}

class User {
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
  String? city;
  DateTime? birthday;
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
  int? rating;
  dynamic description;
  int? slotCharges;
  int? audioRecordingCharges;
  dynamic experience;
  dynamic languages;
  dynamic totalReadings;
  String? availableForFreeChat;
  String? birthTime;
  dynamic availableForSupportChat;
  dynamic birthPlace;
  dynamic birthTimeAccuracy;
  String? availableForPaidChat;
  String? profilePhotoUrl;

  User({
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

  factory User.fromJson(Map<String, dynamic> json) => User(
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
    birthday: json["birthday"] == null
        ? null
        : DateTime.parse(json["birthday"]),
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
    rating: json["rating"],
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
    "birthday":
        "${birthday!.year.toString().padLeft(4, '0')}-${birthday!.month.toString().padLeft(2, '0')}-${birthday!.day.toString().padLeft(2, '0')}",
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
