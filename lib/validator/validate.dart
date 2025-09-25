// ignore_for_file: constant_identifier_names

import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart' show DateFormat, NumberFormat;

class Validate {
  static const String EMAIL_REGEX =
      "^[_A-Za-z0-9-\\+]+(\\.[_A-Za-z0-9-]+)*@[A-Za-z0-9-]+(\\.[A-Za-z0-9]+)*(\\.[A-Za-z]{2,})";
  static const String EMAIL_MSG_EMPTY = "Please enter your valid email.";
  static const String EMAIL_MSG_INVALID =
      "You have entered an invalid email address.";

  static const String MOBILE_REGEX = r'(^(?:[+0]9)?[0-9]{10,12}$)';
  static const String MOBILENUMBER_MSG_EMPTY =
      "Please enter your mobile number.";
  static const String MOBILENUMBER_MSG_INVALID =
      "You have entered an invalid mobile number.";

  static const String EMAIL_OR_MOBILE_MSG_EMPTY =
      "Please enter your valid email / mobile number.";

  static const String PASSWORD_MSG_EMPTY = "Please enter your password.";
  static const String PASSWORD_MSG_INVALID =
      "Your password can't start or end with a blank space.";
  static const String PASSWORD_MSG_INVALID_LENGTH =
      "You must be provide at least 6 to 30 characters for password.";

  static const String CONFIRM_PASSWORD_MSG_EMPTY =
      "Please enter your confirm password.";
  static const String CONFIRM_PASSWORD_MSG_INVALID =
      "Password and confirm password does not match.";

  static const String OTP_MSG_EMPTY = "Please enter your OTP.";
  static const String OTP_MSG_INVALID = "You have entered an invalid OTP.";

  static const String FIRST_NAME_MSG_EMPTY = "Please enter your first name.";
  static const String FIRST_NAME_MSG_INVALID =
      "Your first name can't start or end with a blank space.";
  static const String FIRST_NAME_MSG_INVALID_LENGTH =
      "First name should be 3 to 20 Alphabetic Characters only.";

  static const String LAST_NAME_MSG_EMPTY = "Please enter your last name.";
  static const String LAST_NAME_MSG_INVALID =
      "Your last name can't start or end with a blank space.";
  static const String LAST_NAME_MSG_INVALID_LENGTH =
      "Last name should be 3 to 20 Alphabetic Characters only.";
}

bool validEmailAddress(String emailAddress) {
  String email = emailAddress.trim().toString();
  if (email.isEmpty) {
    return false;
  }
  return validEmailPattern(emailAddress);
}

bool validEmailPattern(String emailAddress) {
  RegExp regExp =  RegExp(Validate.EMAIL_REGEX);
  if (!regExp.hasMatch(emailAddress)) {
    return false;
  }
  return true;
}

bool validMobileNumber(String mobile) {
  String mobileNumber = mobile.trim().toString();
  if (mobileNumber.isEmpty) {
    return false;
  }
  return validMobilePattern(mobile);
}

bool validMobilePattern(String mobile) {
  RegExp regExp =  RegExp(Validate.MOBILENUMBER_MSG_INVALID);
  if (!regExp.hasMatch(mobile)) {
    return false;
  }
  return true;
}

bool isValidString(String? data) {
  return data != null && data.isNotEmpty;
}

bool isValidPassword(String? data) {
  return data != null && data.isNotEmpty && data.length > 7;
}

double getValidDecimalInDouble(String value) {
  if (!isValidString(value)) {
    return 0.0;
  }
  dynamic netValue = double.parse(value.replaceAll(',', ''));
  assert(netValue is double);
  return netValue;
}

Color? getColorFormat(String data) {
  if (!isValidString(data)) {
    return null;
  }
  return  Color(int.parse(data.substring(1, 7), radix: 16) + 0xFF000000);
}

Color hexToColor(String hexString, {String alphaChannel = 'FF'}) {
  return Color(int.parse(hexString.replaceFirst('#', '0x$alphaChannel')));
}

String getValidDecimal(String value) {
  if (!isValidString(value)) {
    return "0.00";
  }
  dynamic netValue = double.parse(value.replaceAll(',', ''));
  assert(netValue is double);
  return getValidDecimalFormat(netValue);
}

bool validOtp(String otp, int length) {
  if (otp.isEmpty) {
    return false;
  }
  if (otp.length < length) {
    return false;
  }
  return true;
}

bool validLastName(String editText) {
  String lastName = editText.trim().toString();
  if (lastName.isEmpty) {
    return false;
  }
  if (lastName.length < 3 || lastName.length > 30) {
    return false;
  }
  return true;
}

String getValidDecimalFormat(double value) {
  return value.toStringAsFixed(2);
}


String dateConverter(String date) {
  NumberFormat formatter =  NumberFormat("00");
  List<String> core = date.split(':');
  int hh = int.parse(core[0]);
  int mm = int.parse(core[1]);
  if (hh > 12) {
    return "${formatter.format(hh - 12)}: ${formatter.format(mm)} PM";
  } else {
    return "${formatter.format(hh)}: ${formatter.format(mm)} AM";
  }
}
String timeConverter(DateTime date) {
  final DateFormat formatter = DateFormat('hh: mm a');
  final String formatted = formatter.format(date);
  return formatted;
}

String dateTimeConverter(DateTime date) {
  final DateFormat formatter = DateFormat('yyyy-MM-dd – hh: mm a');
  final String formatted = formatter.format(date);
  return formatted;
}