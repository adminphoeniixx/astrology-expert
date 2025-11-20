// ignore_for_file: avoid_print, deprecated_member_use

import 'dart:convert';
import 'dart:io';
import 'package:astro_partner_app/constants/string_const.dart';
import 'package:astro_partner_app/firebase/firebase_event.dart';
import 'package:astro_partner_app/helper/local_storage.dart';
import 'package:astro_partner_app/model/api_response.dart';
import 'package:astro_partner_app/model/auth/getprofile_model.dart';
import 'package:astro_partner_app/model/auth/sinup_model.dart';
import 'package:astro_partner_app/model/callerUserInfo_model.dart';
import 'package:astro_partner_app/model/earning_details_model.dart';
import 'package:astro_partner_app/model/earning_list_model.dart';
import 'package:astro_partner_app/model/partner_info_model.dart';
import 'package:astro_partner_app/model/product_list_model.dart';
import 'package:astro_partner_app/model/review_list_model.dart';
import 'package:astro_partner_app/model/seassion_chat_model.dart';
import 'package:astro_partner_app/model/session_details_model.dart';
import 'package:astro_partner_app/model/session_model.dart';
import 'package:astro_partner_app/model/socket_detail_model.dart';
import 'package:astro_partner_app/model/socket_verify_model.dart';
import 'package:astro_partner_app/model/start_timer_chat_model.dart';
import 'package:astro_partner_app/model/update_note_model.dart';
import 'package:astro_partner_app/services/web_request_constants.dart';
import 'package:astro_partner_app/utils/data_provider.dart';
import 'package:astro_partner_app/utils/enum.dart';
import 'package:astro_partner_app/utils/loading.dart';
import 'package:astro_partner_app/utils/request_failure.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class WebApiServices {
  final FirebaseService _firebaseService = FirebaseService();

  ApiResponse _apiResponse = ApiResponse();
  ApiResponse _authResponse = ApiResponse();
  ApiResponse _endChat = ApiResponse();
  ApiResponse _deleteAccount = ApiResponse();

  SessionsModel _sessionsModel = SessionsModel();
  GetProfileModel _userProfile = GetProfileModel();
  EarningDetailsModel _earningDetailsModel = EarningDetailsModel();

  SessionDetailsModel _sessionDetailsModel = SessionDetailsModel();
  EarningListModel _earningListModel = EarningListModel();

  SignUpModel _registerModel = SignUpModel();

  Future<SignUpModel> getRegisterWithOtp({
    required String mobile,
    required String name,
    required String email,
  }) async {
    try {
      String url = "${GetBaseUrl + GetDomainUrl}register";

      var request = http.MultipartRequest('POST', Uri.parse(url));
      request.fields.addAll({
        'mobile_number': mobile,
        'name': name,
        'email': email,
      });

      http.StreamedResponse response = await request.send();

      print("!!!!!!!!!!!!!!!!!getRegisterWithOtp!!!!!!!!!!!!!!!!!!");
      print({'mobile_number': mobile, 'name': name, 'email': email});

      String responseData = await response.stream.bytesToString();
      print("RAW RESPONSE → $responseData");

      // Always reset model FIRST
      _registerModel = SignUpModel();

      dynamic decoded;

      // Try parsing JSON first
      try {
        decoded = jsonDecode(responseData);
      } catch (e) {
        // If server sends plain text instead of JSON
        decoded = {
          "status": false,
          "new_register": false,
          "message": responseData.toString(),
        };
      }

      // If decoded is not a map, wrap it
      if (decoded is! Map<String, dynamic>) {
        decoded = {
          "status": false,
          "new_register": false,
          "message": responseData.toString(),
        };
      }

      // Fill model
      _registerModel = SignUpModel.fromJson(decoded);

      // Set requestStatus based on HTTP code (use your existing enum values)
      if (response.statusCode == httpsCode_200 ||
          response.statusCode == httpsCode_201) {
        _registerModel.requestStatus = RequestStatus.loaded;
      } else if (response.statusCode == httpsCode_401 ||
          response.statusCode == httpsCode_404) {
        _registerModel.requestStatus = RequestStatus.unauthorized;
      } else if (response.statusCode == httpsCode_500) {
        _registerModel.requestStatus = RequestStatus.server;
      } else {
        // Fallback – keep it initial or whatever you prefer
        _registerModel.requestStatus = RequestStatus.initial;
      }

      print("PARSED Status: ${_registerModel.status}");
      print("PARSED Message: ${_registerModel.message}");
    } on SocketException catch (e) {
      _registerModel.requestStatus = RequestStatus.unauthorized;
      throw Failure(e.message);
    } on FormatException catch (e) {
      _registerModel.requestStatus = RequestStatus.unauthorized;
      throw Failure(e.message);
    } on HttpException catch (e) {
      _registerModel.requestStatus = RequestStatus.server;
      throw Failure(e.message);
    } catch (e) {
      _registerModel.requestStatus = RequestStatus.unauthorized;
      throw Failure(e.toString());
    }

    return _registerModel;
  }

  Future<SignUpModel> getRegisterVerifyOtp({
    required String mobile,
    required String otp,
    required BuildContext context,
  }) async {
    SignUpModel model = SignUpModel(); // always return fresh instance

    try {
      String url = "${GetBaseUrl + GetDomainUrl}verify-registration-otp";

      final fcmToken = await _fetchFcmToken();

      var request = http.MultipartRequest('POST', Uri.parse(url));

      request.fields.addAll({
        "mobile_number": mobile,
        "otp": otp,
        "device_token": fcmToken,
      });

      print("!!!!!!!!!!!!!!!!!getRegisterVerifyOtp!!!!!!!!!!!!!!!!!!");
      print({"mobile_number": mobile, "otp": otp, "device_token": fcmToken});

      http.StreamedResponse response = await request.send();
      String responseData = await response.stream.bytesToString();

      print("######## RAW RESPONSE ########");
      print("Status: ${response.statusCode}");
      print("Body: $responseData");
      print("################################");

      dynamic decoded;

      // 🔥 Try parsing JSON
      try {
        decoded = jsonDecode(responseData);
      } catch (_) {
        // If backend sends plain text instead of JSON
        decoded = {
          "status": false,
          "new_register": false,
          "message": responseData.toString(),
        };
      }

      // 🔥 Ensure decoded is a Map
      if (decoded is! Map<String, dynamic>) {
        decoded = {
          "status": false,
          "new_register": false,
          "message": responseData.toString(),
        };
      }

      // 🔥 Now parse into model
      model = SignUpModel.fromJson(decoded);

      // 🔥 HTTP status handling
      if (response.statusCode == httpsCode_200 ||
          response.statusCode == httpsCode_201) {
        if (model.status == true) {
          model.requestStatus = RequestStatus.loaded;
        } else {
          showToast(context, msg: model.message ?? "Invalid OTP");
          model.requestStatus = RequestStatus.initial;
        }
      } else if (response.statusCode == httpsCode_401 ||
          response.statusCode == httpsCode_404) {
        model.requestStatus = RequestStatus.unauthorized;
      } else if (response.statusCode == httpsCode_500) {
        model.requestStatus = RequestStatus.server;
      } else {
        model.requestStatus = RequestStatus.initial;
      }
    } on SocketException catch (_) {
      throw Failure("No internet connection");
    } on FormatException catch (_) {
      throw Failure("Invalid format received");
    } catch (e) {
      throw Failure(e.toString());
    }

    return model;
  }

  Future<ApiResponse> getResendOtp({required String mobile}) async {
    // Fetch FCM token
    // final fcmToken = await _fetchFcmToken();

    try {
      String url = GetBaseUrl + GetDomainUrl + RESEND_OTP;
      dynamic body = json.encode({"mobile_number": mobile});
      var response = await http.post(
        Uri.parse(url),
        headers: await authHeader(),
        body: body,
      );
      print("!!!!!!!!!!!!!!!!!!!!!getResendOtp!!!!!!!!!!!!!!!!!!!!!!!!!!!");

      print(body);
      print("!!!!!!!!!!!!!!!!!!!!!getResendOtp!!!!!!!!!!!!!!!!!!!!!!!!!!!");

      if (response.statusCode == httpsCode_200 ||
          response.statusCode == httpsCode_201) {
        _apiResponse = ApiResponse.fromJson(jsonDecode(response.body));
        _apiResponse.requestStatus = RequestStatus.loaded;
      } else if (response.statusCode == httpsCode_404 ||
          response.statusCode == httpsCode_401) {
        // BasePrefs.clearPrefs().then((value) => Get.offAll(const LoadingPage()));
        _apiResponse.requestStatus = RequestStatus.unauthorized;
      } else if (response.statusCode == httpsCode_500) {
        _apiResponse.requestStatus = RequestStatus.server;
      }
    } on Error catch (e) {
      _firebaseService.firebaseSocketException(
        apiCall: "getResendOtp",
        email: mobile,
        message: e.toString(),
      );
    } on SocketException catch (e) {
      _firebaseService.firebaseSocketException(
        apiCall: "getResendOtp",
        email: mobile,
        message: e.message,
      );
      throw Failure(e.message);
    } on FormatException catch (e) {
      _firebaseService.firebaseFormatException(
        apiCall: "getResendOtp",
        email: mobile,
        message: e.message,
      );
      throw Failure(e.message);
    } on HttpException catch (e) {
      _firebaseService.firebaseHttpException(
        apiCall: "getResendOtp",
        email: mobile,
        message: e.message,
      );
      throw Failure(e.message);
    }
    return _apiResponse;
  }

  Future<ApiResponse> getLoginWithOtp({
    required String mobile,
    required String screen,
  }) async {
    // Fetch FCM token
    try {
      String url = GetBaseUrl + GetDomainUrl + LOGIN_WITH_OTP;

      dynamic request = http.MultipartRequest('POST', Uri.parse(url));
      request.fields.addAll({'mobile_number': mobile});
      http.StreamedResponse response = await request.send();
      dynamic responseData = await response.stream.bytesToString();
      print({'mobile_number': mobile});
      print(url);
      print(responseData);
      if (response.statusCode == httpsCode_200 ||
          response.statusCode == httpsCode_201) {
        _authResponse = ApiResponse.fromJson(jsonDecode(responseData));
        _authResponse.requestStatus = RequestStatus.loaded;
      } else if (response.statusCode == httpsCode_404 ||
          response.statusCode == httpsCode_401) {
        // BasePrefs.clearPrefs().then((value) => Get.offAll(const LoadingPage()));
        _apiResponse.requestStatus = RequestStatus.unauthorized;
      } else if (response.statusCode == httpsCode_500) {
        _apiResponse.requestStatus = RequestStatus.server;
      }
    } on Error catch (e) {
      _firebaseService.firebaseDioError(
        apiCall: "getLoginWithOtp",
        code: 401,
        userId: userId,
        message: e.toString(),
      );
    } on SocketException catch (e) {
      _firebaseService.firebaseSocketException(
        apiCall: "getLoginWithOtp",
        userId: userId,
        message: e.message,
      );
      throw Failure(e.message);
    } on FormatException catch (e) {
      _firebaseService.firebaseFormatException(
        apiCall: "getLoginWithOtp",
        userId: userId,
        message: e.message,
      );
      throw Failure(e.message);
    } on HttpException catch (e) {
      _firebaseService.firebaseHttpException(
        apiCall: "getLoginWithOtp",
        userId: userId,
        message: e.message,
      );
      throw Failure(e.message);
    }
    return _authResponse;
  }

  Future<String> _fetchFcmToken() async {
    try {
      final token = await FirebaseMessaging.instance.getToken();
      return token ?? ''; // Return empty string if token is null
    } catch (e) {
      // Log the error or handle it appropriately
      print("Error fetching FCM token: $e");
      return ''; // Return empty string on error
    }
  }

  Future<SignUpModel> getVerifyLoginWithOtp({
    required String mobile,
    required String otp,
    required BuildContext context,
  }) async {
    SignUpModel model = SignUpModel(); // always return fresh model

    try {
      final fcmToken = await _fetchFcmToken();

      String url = GetBaseUrl + GetDomainUrl + VERIFY_LOGIN_WITH_OTP;
      var request = http.MultipartRequest('POST', Uri.parse(url));

      Map<String, String> body = {
        "mobile_number": mobile,
        "otp": otp,
        "device_token": fcmToken,
      };

      request.fields.addAll(body);

      print("######## REQUEST DEBUG ########");
      print("URL: $url");
      print("Body: $body");
      print("################################");

      http.StreamedResponse response = await request.send();
      String responseData = await response.stream.bytesToString();

      print("######## RESPONSE DEBUG ########");
      print("Status Code: ${response.statusCode}");
      print("Body: $responseData");
      print("################################");

      dynamic decoded;

      // Try decode JSON
      try {
        decoded = jsonDecode(responseData);
      } catch (e) {
        // fall back to plain text error message
        decoded = {
          "status": false,
          "message": responseData.toString(),
          "new_register": false,
        };
      }

      // Ensure decoded is Map
      if (decoded is! Map<String, dynamic>) {
        decoded = {
          "status": false,
          "message": responseData.toString(),
          "new_register": false,
        };
      }

      // Now parse model
      model = SignUpModel.fromJson(decoded);

      // map status codes
      if (response.statusCode == httpsCode_200 ||
          response.statusCode == httpsCode_201) {
        if (model.status == true) {
          model.requestStatus = RequestStatus.loaded;
        } else {
          showToast(context, msg: model.message ?? "Invalid OTP");
          model.requestStatus = RequestStatus.initial;
        }
      } else if (response.statusCode == httpsCode_401 ||
          response.statusCode == httpsCode_404) {
        model.requestStatus = RequestStatus.unauthorized;
      } else if (response.statusCode == httpsCode_500) {
        model.requestStatus = RequestStatus.server;
      } else {
        model.requestStatus = RequestStatus.initial;
      }
    } catch (e) {
      throw Failure(e.toString());
    }

    return model;
  }

  Future<SessionsModel> getSessionsModel({required String pageUrl}) async {
    try {
      // Prepare headers
      Map<String, String> headers = await authHeader();
      headers['Content-Type'] = 'application/json';

      http.Response response = await http.get(
        Uri.parse(pageUrl),
        headers: headers,
      );
      print(headers);
      // Log response
      debugPrint("Response Status: ${response.statusCode}");
      debugPrint("Response Body: ${response.body}");
      if (response.statusCode == 200 || response.statusCode == 201) {
        _sessionsModel = SessionsModel.fromJson(jsonDecode(response.body));
        _sessionsModel.requestStatus = RequestStatus.loaded;
      } else if (response.statusCode == 401 || response.statusCode == 404) {
        _sessionsModel.requestStatus = RequestStatus.unauthorized;
      } else if (response.statusCode == 500) {
        _sessionsModel.requestStatus = RequestStatus.server;
      } else {
        throw HttpException("Unexpected response: ${response.statusCode}");
      }
    } on SocketException catch (e) {
      _firebaseService.firebaseSocketException(
        apiCall: "getSessionsModel",
        // userId: userId,
        message: e.message,
      );
      throw Failure("No Internet connection. Please check your network.");
    } on FormatException catch (e) {
      _firebaseService.firebaseFormatException(
        apiCall: "getSessionsModel",
        // userId: userId,
        message: e.message,
      );
      throw Failure("Invalid server response format.");
    } on HttpException catch (e) {
      _firebaseService.firebaseHttpException(
        apiCall: "getSessionsModel",
        // userId: userId,
        message: e.message,
      );
      throw Failure("HTTP Error: ${e.message}");
    } catch (e) {
      _firebaseService.firebaseDioError(
        apiCall: "getSessionsModel",
        code: "unknown",
        // userId: userId,
        message: e.toString(),
      );
      throw Failure("An unexpected error occurred.");
    }

    return _sessionsModel;
  }

  Future<SessionDetailsModel> getSessionDetailsModel({
    required String sessionId,
  }) async {
    try {
      String url = "${GetBaseUrl + GetDomainUrl2}service-details/$sessionId";

      final response = await http.get(
        Uri.parse(url),
        headers: await authHeader(),
      );

      print("########_sessionDetailsModel#############");
      print(url);
      print(await authHeader());
      print(response.body);
      print("#########_sessionDetailsModel############");

      if (response.statusCode == 200 || response.statusCode == 201) {
        _sessionDetailsModel = SessionDetailsModel.fromJson(
          jsonDecode(response.body),
        );
        _sessionDetailsModel.requestStatus = RequestStatus.loaded;
      } else if (response.statusCode == 401 || response.statusCode == 404) {
        _sessionDetailsModel.requestStatus = RequestStatus.unauthorized;
      } else if (response.statusCode == 500) {
        _sessionDetailsModel.requestStatus = RequestStatus.server;
      } else {
        throw HttpException("Unexpected response: ${response.statusCode}");
      }
    } on SocketException catch (e) {
      _firebaseService.firebaseSocketException(
        apiCall: "_sessionDetailsModel",
        userId: userId,
        message: e.message,
      );
      throw Failure(e.message);
    } on FormatException catch (e) {
      _firebaseService.firebaseFormatException(
        apiCall: "_sessionDetailsModel",
        userId: userId,
        message: e.message,
      );
      throw Failure(e.message);
    } on HttpException catch (e) {
      _firebaseService.firebaseHttpException(
        apiCall: "_sessionDetailsModel",
        userId: userId,
        message: e.message,
      );
      throw Failure(e.message);
    } catch (e) {
      _firebaseService.firebaseDioError(
        apiCall: "_sessionDetailsModel",
        code: "401|404",
        userId: userId,
        message: e.toString(),
      );
    }

    return _sessionDetailsModel;
  }

  Future<EarningListModel> getEarningListModel({
    required String pageUrl,
  }) async {
    try {
      // Prepare headers
      Map<String, String> headers = await authHeader();
      headers['Content-Type'] = 'application/json';

      http.Response response = await http.get(
        Uri.parse(pageUrl),
        headers: headers,
      );
      print(headers);
      // Log response
      debugPrint("Response Status: ${response.statusCode}");
      debugPrint("Response Body: ${response.body}");
      if (response.statusCode == 200 || response.statusCode == 201) {
        _earningListModel = EarningListModel.fromJson(
          jsonDecode(response.body),
        );
        _earningListModel.requestStatus = RequestStatus.loaded;
      } else if (response.statusCode == 401 || response.statusCode == 404) {
        _earningListModel.requestStatus = RequestStatus.unauthorized;
      } else if (response.statusCode == 500) {
        _earningListModel.requestStatus = RequestStatus.server;
      } else {
        throw HttpException("Unexpected response: ${response.statusCode}");
      }
    } on SocketException catch (e) {
      _firebaseService.firebaseSocketException(
        apiCall: "_earningListModel",
        userId: userId,
        message: e.message,
      );
      throw Failure("No Internet connection. Please check your network.");
    } on FormatException catch (e) {
      _firebaseService.firebaseFormatException(
        apiCall: "_earningListModel",
        userId: userId,
        message: e.message,
      );
      throw Failure("Invalid server response format.");
    } on HttpException catch (e) {
      _firebaseService.firebaseHttpException(
        apiCall: "_earningListModel",
        userId: userId,
        message: e.message,
      );
      throw Failure("HTTP Error: ${e.message}");
    } catch (e) {
      _firebaseService.firebaseDioError(
        apiCall: "getSessionsModel",
        code: "unknown",
        userId: userId,
        message: e.toString(),
      );
      throw Failure("An unexpected error occurred.");
    }

    return _earningListModel;
  }

  Future<EarningDetailsModel> getEarningDetailsModel({
    required String earningId,
  }) async {
    try {
      String url = "${GetBaseUrl + GetDomainUrl2}expert-earnings/$earningId";

      final response = await http.get(
        Uri.parse(url),
        headers: await authHeader(),
      );

      print("########EarningDetailsModel#############");
      print(url);
      print(await authHeader());
      print(response.body);
      print("#########EarningDetailsModel############");

      if (response.statusCode == 200 || response.statusCode == 201) {
        _earningDetailsModel = EarningDetailsModel.fromJson(
          jsonDecode(response.body),
        );
        _earningDetailsModel.requestStatus = RequestStatus.loaded;
      } else if (response.statusCode == 401 || response.statusCode == 404) {
        _earningDetailsModel.requestStatus = RequestStatus.unauthorized;
      } else if (response.statusCode == 500) {
        _earningDetailsModel.requestStatus = RequestStatus.server;
      } else {
        throw HttpException("Unexpected response: ${response.statusCode}");
      }
    } on SocketException catch (e) {
      _firebaseService.firebaseSocketException(
        apiCall: "EarningDetailsModel",
        userId: userId,
        message: e.message,
      );
      throw Failure(e.message);
    } on FormatException catch (e) {
      _firebaseService.firebaseFormatException(
        apiCall: "EarningDetailsModel",
        userId: userId,
        message: e.message,
      );
      throw Failure(e.message);
    } on HttpException catch (e) {
      _firebaseService.firebaseHttpException(
        apiCall: "EarningDetailsModel",
        userId: userId,
        message: e.message,
      );
      throw Failure(e.message);
    } catch (e) {
      _firebaseService.firebaseDioError(
        apiCall: "EarningDetailsModel",
        code: "401|404",
        userId: userId,
        message: e.toString(),
      );
    }

    return _earningDetailsModel;
  }

  UpdateNoteModel _updateNoteModel = UpdateNoteModel();

  Future<UpdateNoteModel> getUpdateNoteModel({
    required String sessionId,
    required String notes,
  }) async {
    try {
      String url = "${GetBaseUrl + GetDomainUrl2}service-sessions/notes";

      final bodyData = {
        "id": int.tryParse(sessionId) ?? sessionId,
        "notes": notes,
      };

      final response = await http.post(
        Uri.parse(url),
        headers: {...(await authHeader()), "Content-Type": "application/json"},
        body: json.encode(bodyData),
      );

      print("########UpdateNoteModel#############");
      print(url);
      print("Headers: ${await authHeader()}");
      print("Body Sent: ${json.encode(bodyData)}");
      print("Response: ${response.body}");
      print("#########UpdateNoteModel############");

      if (response.statusCode == 200 || response.statusCode == 201) {
        _updateNoteModel = UpdateNoteModel.fromJson(jsonDecode(response.body));
        _updateNoteModel.requestStatus = RequestStatus.loaded;
      } else if (response.statusCode == 401 || response.statusCode == 404) {
        _updateNoteModel.requestStatus = RequestStatus.unauthorized;
      } else if (response.statusCode == 500) {
        _updateNoteModel.requestStatus = RequestStatus.server;
      } else {
        throw HttpException("Unexpected response: ${response.statusCode}");
      }
    } on SocketException catch (e) {
      _firebaseService.firebaseSocketException(
        apiCall: "_updateNoteModel",
        userId: userId,
        message: e.message,
      );
      throw Failure(e.message);
    } on FormatException catch (e) {
      _firebaseService.firebaseFormatException(
        apiCall: "_updateNoteModel",
        userId: userId,
        message: e.message,
      );
      throw Failure(e.message);
    } on HttpException catch (e) {
      _firebaseService.firebaseHttpException(
        apiCall: "_updateNoteModel",
        userId: userId,
        message: e.message,
      );
      throw Failure(e.message);
    } catch (e) {
      _firebaseService.firebaseDioError(
        apiCall: "_updateNoteModel",
        code: "401|404",
        userId: userId,
        message: e.toString(),
      );
    }

    return _updateNoteModel;
  }

  Future<UpdateNoteModel> getNotesModel({required String sessionId}) async {
    try {
      String url = "${GetBaseUrl + GetDomainUrl2}service-sessions/show-notes";

      final bodyData = {"id": int.tryParse(sessionId) ?? sessionId};

      final response = await http.post(
        Uri.parse(url),
        headers: {...(await authHeader()), "Content-Type": "application/json"},
        body: json.encode(bodyData),
      );

      print("########getNotesModel#############");
      print(url);
      print("Headers: ${await authHeader()}");
      print("Body Sent: ${json.encode(bodyData)}");
      print("Response: ${response.body}");
      print("#########getNotesModel############");

      if (response.statusCode == 200 || response.statusCode == 201) {
        _updateNoteModel = UpdateNoteModel.fromJson(jsonDecode(response.body));
        _updateNoteModel.requestStatus = RequestStatus.loaded;
      } else if (response.statusCode == 401 || response.statusCode == 404) {
        _updateNoteModel.requestStatus = RequestStatus.unauthorized;
      } else if (response.statusCode == 500) {
        _updateNoteModel.requestStatus = RequestStatus.server;
      } else {
        throw HttpException("Unexpected response: ${response.statusCode}");
      }
    } on SocketException catch (e) {
      _firebaseService.firebaseSocketException(
        apiCall: "getNotesModel",
        userId: userId,
        message: e.message,
      );
      throw Failure(e.message);
    } on FormatException catch (e) {
      _firebaseService.firebaseFormatException(
        apiCall: "getNotesModel",
        userId: userId,
        message: e.message,
      );
      throw Failure(e.message);
    } on HttpException catch (e) {
      _firebaseService.firebaseHttpException(
        apiCall: "getNotesModel",
        userId: userId,
        message: e.message,
      );
      throw Failure(e.message);
    } catch (e) {
      _firebaseService.firebaseDioError(
        apiCall: "getNotesModel",
        code: "401|404",
        userId: userId,
        message: e.toString(),
      );
    }

    return _updateNoteModel;
  }

  ProductListModel _productListModel = ProductListModel();

  Future<ProductListModel> getProductListModel({
    required String sessionId,
  }) async {
    try {
      String url =
          "${GetBaseUrl + GetDomainUrl2}recommended-products/${int.tryParse(sessionId) ?? sessionId}";

      final response = await http.get(
        Uri.parse(url),
        headers: {...(await authHeader()), "Content-Type": "application/json"},
      );

      print("########_productListModel#############");
      print(url);
      print("Headers: ${await authHeader()}");
      print("Response: ${response.body}");
      print("#########_productListModel############");

      if (response.statusCode == 200 || response.statusCode == 201) {
        _productListModel = ProductListModel.fromJson(
          jsonDecode(response.body),
        );
        _productListModel.requestStatus = RequestStatus.loaded;
      } else if (response.statusCode == 401 || response.statusCode == 404) {
        _productListModel.requestStatus = RequestStatus.unauthorized;
      } else if (response.statusCode == 500) {
        _productListModel.requestStatus = RequestStatus.server;
      } else {
        throw HttpException("Unexpected response: ${response.statusCode}");
      }
    } on SocketException catch (e) {
      _firebaseService.firebaseSocketException(
        apiCall: "_productListModel",
        userId: userId,
        message: e.message,
      );
      throw Failure(e.message);
    } on FormatException catch (e) {
      _firebaseService.firebaseFormatException(
        apiCall: "_productListModel",
        userId: userId,
        message: e.message,
      );
      throw Failure(e.message);
    } on HttpException catch (e) {
      _firebaseService.firebaseHttpException(
        apiCall: "_productListModel",
        userId: userId,
        message: e.message,
      );
      throw Failure(e.message);
    } catch (e) {
      _firebaseService.firebaseDioError(
        apiCall: "_productListModel",
        code: "401|404",
        userId: userId,
        message: e.toString(),
      );
    }

    return _productListModel;
  }

  ProductListModel _recommendProductModel = ProductListModel();

  Future<ProductListModel> getRecommendProductModel({
    required String sessionId,
    required List<int> productIds,
  }) async {
    try {
      String url = "${GetBaseUrl + GetDomainUrl2}reschedule-product-assign";

      final bodyData = {
        "session_id": int.tryParse(sessionId) ?? sessionId,
        "productIds": productIds,
      };

      final response = await http.post(
        Uri.parse(url),
        headers: {...(await authHeader()), "Content-Type": "application/json"},
        body: json.encode(bodyData),
      );

      print("########_recommendProductModel#############");
      print(url);
      print("Headers: ${await authHeader()}");
      print("Body Sent: ${json.encode(bodyData)}");

      print("Response: ${response.body}");
      print("#########_recommendProductModel############");

      if (response.statusCode == 200 || response.statusCode == 201) {
        _recommendProductModel = ProductListModel.fromJson(
          jsonDecode(response.body),
        );
        _recommendProductModel.requestStatus = RequestStatus.loaded;
      } else if (response.statusCode == 401 || response.statusCode == 404) {
        _recommendProductModel.requestStatus = RequestStatus.unauthorized;
      } else if (response.statusCode == 500) {
        _recommendProductModel.requestStatus = RequestStatus.server;
      } else {
        throw HttpException("Unexpected response: ${response.statusCode}");
      }
    } on SocketException catch (e) {
      _firebaseService.firebaseSocketException(
        apiCall: "_recommendProductModel",
        userId: userId,
        message: e.message,
      );
      throw Failure(e.message);
    } on FormatException catch (e) {
      _firebaseService.firebaseFormatException(
        apiCall: "_recommendProductModel",
        userId: userId,
        message: e.message,
      );
      throw Failure(e.message);
    } on HttpException catch (e) {
      _firebaseService.firebaseHttpException(
        apiCall: "_recommendProductModel",
        userId: userId,
        message: e.message,
      );
      throw Failure(e.message);
    } catch (e) {
      _firebaseService.firebaseDioError(
        apiCall: "_recommendProductModel",
        code: "401|404",
        userId: userId,
        message: e.toString(),
      );
    }

    return _recommendProductModel;
  }

  SessionChatModel _sessionChatModel = SessionChatModel();

  Future<SessionChatModel> getSessionChatModel({
    required String sessionId,
  }) async {
    const String url = "${GetBaseUrl + GetDomainUrl2}sessions/details";
    final headers = await authHeader();

    try {
      // ✅ Request body
      final body = jsonEncode({"session_id": sessionId});

      print("########_sessionChatModel#############");
      print("URL: $url");
      print("Headers: $headers");
      print("Body: $body");

      // ✅ Make POST request
      final response = await http.post(
        Uri.parse(url),
        headers: {
          ...headers,
          "Content-Type": "application/json", // ensure correct content type
        },
        body: body,
      );

      print("Response (${response.statusCode}): ${response.body}");
      print("#########_sessionChatModel############");

      // ✅ Parse response
      if (response.statusCode == 200 || response.statusCode == 201) {
        _sessionChatModel = SessionChatModel.fromJson(
          jsonDecode(response.body),
        );
        _sessionChatModel.requestStatus = RequestStatus.loaded;
      } else if (response.statusCode == 401 || response.statusCode == 404) {
        _sessionChatModel.requestStatus = RequestStatus.unauthorized;
      } else if (response.statusCode == 500) {
        _sessionChatModel.requestStatus = RequestStatus.server;
      } else {
        throw HttpException("Unexpected response: ${response.statusCode}");
      }
    } on SocketException catch (e) {
      _firebaseService.firebaseSocketException(
        apiCall: "_sessionChatModel",
        userId: userId,
        message: e.message,
      );
      throw Failure(e.message);
    } on FormatException catch (e) {
      _firebaseService.firebaseFormatException(
        apiCall: "_sessionChatModel",
        userId: userId,
        message: e.message,
      );
      throw Failure(e.message);
    } on HttpException catch (e) {
      _firebaseService.firebaseHttpException(
        apiCall: "_sessionChatModel",
        userId: userId,
        message: e.message,
      );
      throw Failure(e.message);
    } catch (e) {
      _firebaseService.firebaseDioError(
        apiCall: "_sessionChatModel",
        code: "401|404",
        userId: userId,
        message: e.toString(),
      );
      throw Failure(e.toString());
    }

    return _sessionChatModel;
  }

  Future<GetProfileModel> getUserProfile() async {
    try {
      String url = GetBaseUrl + GetDomainUrl2 + GET_USER_PROFILE;
      var request = http.MultipartRequest('POST', Uri.parse(url));
      request.headers.addAll(await authHeader());
      http.StreamedResponse response = await request.send();
      dynamic responseData = await response.stream.bytesToString();
      print("#############USER#############");
      print(url);
      print(jsonDecode(responseData));
      if (response.statusCode == httpsCode_200 ||
          response.statusCode == httpsCode_201) {
        _userProfile = GetProfileModel.fromJson(jsonDecode(responseData));
        print("#############USER#############");
        _userProfile.requestStatus = RequestStatus.loaded;
      } else if (response.statusCode == httpsCode_404 ||
          response.statusCode == httpsCode_401) {
        // BasePrefs.clearPrefs().then((value) => Get.offAll(const LoadingPage()));
        _userProfile.requestStatus = RequestStatus.unauthorized;
      } else if (response.statusCode == httpsCode_500) {
        _userProfile.requestStatus = RequestStatus.server;
      }
    } on Error catch (e) {
      _firebaseService.firebaseDioError(
        apiCall: "getUserProfile",
        code: "401|404",
        userId: userId,
        message: e.toString(),
      );
    } on SocketException catch (e) {
      _firebaseService.firebaseSocketException(
        apiCall: "getUserProfile",
        userId: userId,
        message: e.message,
      );
      throw Failure(e.message);
    } on FormatException catch (e) {
      _firebaseService.firebaseFormatException(
        apiCall: "getUserProfile",
        userId: userId,
        message: e.message,
      );
      throw Failure(e.message);
    } on HttpException catch (e) {
      _firebaseService.firebaseHttpException(
        apiCall: "getUserProfile",
        userId: userId,
        message: e.message,
      );
      throw Failure(e.message);
    }
    return _userProfile;
  }

  // Future<SignUpModel> editUserProfile({
  //   required String name,
  //   required String email,
  //   required String gender,
  //   required String city,
  //   required String birthday,
  // }) async {
  //   try {
  //     String url = GetBaseUrl + GetDomainUrl + EDIT_USER_PROFILE;
  //     var request = http.MultipartRequest('POST', Uri.parse(url));
  //     request.fields.addAll({
  //       'name': name,
  //       'email': email,
  //       'gender': gender,
  //       'city': city,
  //       'birthday': birthday,
  //     });
  //     request.headers.addAll(await authHeader());
  //     http.StreamedResponse response = await request.send();
  //     dynamic responseData = await response.stream.bytesToString();
  //     print("#############USER#############");
  //     print(jsonDecode(responseData));
  //     if (response.statusCode == httpsCode_200 ||
  //         response.statusCode == httpsCode_201) {
  //       _edituserPdofile = signUpModelFromJson(responseData);
  //       print("##########################");
  //       _edituserPdofile.requestStatus = RequestStatus.loaded;
  //     } else if (response.statusCode == httpsCode_404 ||
  //         response.statusCode == httpsCode_401) {
  //       // BasePrefs.clearPrefs().then((value) => Get.offAll(const LoadingPage()));
  //       _edituserPdofile.requestStatus = RequestStatus.unauthorized;
  //     } else if (response.statusCode == httpsCode_500) {
  //       _edituserPdofile.requestStatus = RequestStatus.server;
  //     }
  //   } on Error catch (e) {
  //     _firebaseService.firebaseDioError(
  //       apiCall: "editUserProfile",
  //       code: "401|404",
  //       userId: userId,
  //       message: e.toString(),
  //     );
  //   } on SocketException catch (e) {
  //     _firebaseService.firebaseSocketException(
  //       apiCall: "editUserProfile",
  //       userId: userId,
  //       message: e.message,
  //     );
  //     throw Failure(e.message);
  //   } on FormatException catch (e) {
  //     _firebaseService.firebaseFormatException(
  //       apiCall: "editUserProfile",
  //       userId: userId,
  //       message: e.message,
  //     );
  //     throw Failure(e.message);
  //   } on HttpException catch (e) {
  //     _firebaseService.firebaseHttpException(
  //       apiCall: "editUserProfile",
  //       userId: userId,
  //       message: e.message,
  //     );
  //     throw Failure(e.message);
  //   }
  //   return _edituserPdofile;
  // }

  ReviewListModel _reviewListModel = ReviewListModel();

  Future<ReviewListModel> getReviewListModel() async {
    try {
      final dynamic userIdExpert = await BasePrefs.readData(userId);

      String url =
          "${GetBaseUrl + GetDomainUrl}ratings/${int.tryParse(userIdExpert) ?? userIdExpert}";

      final response = await http.get(
        Uri.parse(url),
        headers: {...(await authHeader()), "Content-Type": "application/json"},
      );

      print("########_reviewListModel#############");
      print(url);
      print("Headers: ${await authHeader()}");
      print("Response: ${response.body}");
      print("#########_reviewListModel############");

      if (response.statusCode == 200 || response.statusCode == 201) {
        _reviewListModel = ReviewListModel.fromJson(jsonDecode(response.body));
        _reviewListModel.requestStatus = RequestStatus.loaded;
      } else if (response.statusCode == 401 || response.statusCode == 404) {
        _reviewListModel.requestStatus = RequestStatus.unauthorized;
      } else if (response.statusCode == 500) {
        _reviewListModel.requestStatus = RequestStatus.server;
      } else {
        throw HttpException("Unexpected response: ${response.statusCode}");
      }
    } on SocketException catch (e) {
      _firebaseService.firebaseSocketException(
        apiCall: "_reviewListModel",
        userId: userId,
        message: e.message,
      );
      throw Failure(e.message);
    } on FormatException catch (e) {
      _firebaseService.firebaseFormatException(
        apiCall: "_reviewListModel",
        userId: userId,
        message: e.message,
      );
      throw Failure(e.message);
    } on HttpException catch (e) {
      _firebaseService.firebaseHttpException(
        apiCall: "_reviewListModel",
        userId: userId,
        message: e.message,
      );
      throw Failure(e.message);
    } catch (e) {
      _firebaseService.firebaseDioError(
        apiCall: "_reviewListModel",
        code: "401|404",
        userId: userId,
        message: e.toString(),
      );
    }

    return _reviewListModel;
  }

  Future<ApiResponse> endChatAPI({
    required int expertId,
    required int customerId,
    required int durationSeconds,
    required String notes,
  }) async {
    try {
      const String url = "$GetBaseUrl${GetDomainUrl2}chat/sessions/end";
      final headers = await authHeader();
      headers.remove("Content-Type"); // ✅ Server rejects JSON type

      print("########## endChatAPI ##########");
      print(headers);
      print("URL: $url");
      print("########## endChatAPI ##########");

      final response = await http.post(
        Uri.parse(url),
        headers: headers,
        body: {
          "expert_id": expertId.toString(),
          "customer_id": customerId.toString(),
          "duration_seconds": durationSeconds.toString(),
          "notes": notes,
        },
      );

      print("########## endChatAPI Response ##########");
      print("Status Code: ${response.statusCode}");
      print("Response Body: ${response.body}");
      print("########## endChatAPI Response ##########");

      if (response.statusCode == 200 || response.statusCode == 201) {
        final parsed = jsonDecode(response.body);
        return ApiResponse.fromJson(parsed)
          ..requestStatus = RequestStatus.loaded;
      } else {
        _endChat.requestStatus = RequestStatus.failure;
      }
    } catch (e) {
      _endChat.requestStatus = RequestStatus.failure;
    }
    return _endChat;
  }

  Future<ApiResponse> deleteAccountAPI() async {
    try {
      const String url = "$GetBaseUrl${GetDomainUrl2}expert-delete-account";
      final headers = await authHeader();
      headers.remove("Content-Type"); // ✅ Server rejects JSON type

      print("########## deleteAccountAPI ##########");
      print(headers);
      print("URL: $url");
      print("########## deleteAccountAPI ##########");

      final response = await http.post(Uri.parse(url), headers: headers);

      print("########## deleteAccountAPI Response ##########");
      print("Status Code: ${response.statusCode}");
      print("Response Body: ${response.body}");
      print("########## deleteAccountAPI Response ##########");

      if (response.statusCode == 200 || response.statusCode == 201) {
        final parsed = jsonDecode(response.body);
        return ApiResponse.fromJson(parsed)
          ..requestStatus = RequestStatus.loaded;
      } else {
        _deleteAccount.requestStatus = RequestStatus.failure;
      }
    } catch (e) {
      _deleteAccount.requestStatus = RequestStatus.failure;
    }
    return _deleteAccount;
  }

  SocketDetailsModel _socketDetailsModel = SocketDetailsModel();

  Future<SocketDetailsModel> getSocketDetailsModel() async {
    try {
      String url = "${GetBaseUrl + GetDomainUrl3}socketi-details";

      final response = await http.post(
        Uri.parse(url),
        headers: {...(await authHeader()), "Content-Type": "application/json"},
      );

      print("########SocketDetailsModel#############");
      print(url);
      print("Headers: ${await authHeader()}");
      print("Response: ${response.body}");
      print("#########SocketDetailsModel############");

      if (response.statusCode == 200 || response.statusCode == 201) {
        _socketDetailsModel = SocketDetailsModel.fromJson(
          jsonDecode(response.body),
        );
        _socketDetailsModel.requestStatus = RequestStatus.loaded;
      } else if (response.statusCode == 401 || response.statusCode == 404) {
        _socketDetailsModel.requestStatus = RequestStatus.unauthorized;
      } else if (response.statusCode == 500) {
        _socketDetailsModel.requestStatus = RequestStatus.server;
      } else {
        throw HttpException("Unexpected response: ${response.statusCode}");
      }
    } on SocketException catch (e) {
      _firebaseService.firebaseSocketException(
        apiCall: "SocketDetailsModel",
        userId: userId,
        message: e.message,
      );
      throw Failure(e.message);
    } on FormatException catch (e) {
      _firebaseService.firebaseFormatException(
        apiCall: "SocketDetailsModel",
        userId: userId,
        message: e.message,
      );
      throw Failure(e.message);
    } on HttpException catch (e) {
      _firebaseService.firebaseHttpException(
        apiCall: "SocketDetailsModel",
        userId: userId,
        message: e.message,
      );
      throw Failure(e.message);
    } catch (e) {
      _firebaseService.firebaseDioError(
        apiCall: "SocketDetailsModel",
        code: "401|404",
        userId: userId,
        message: e.toString(),
      );
    }

    return _socketDetailsModel;
  }

  SocketVerifyModel _socketVerifyModel = SocketVerifyModel();

  Future<SocketVerifyModel> getSocketVerifyModel({
    required String socketId,
    required String channelName,
  }) async {
    const String url = "${GetBaseUrl + GetDomainUrl2}pusher/auth";
    final headers = await authHeader();

    try {
      // ✅ Request body
      final body = jsonEncode({
        "socket_id": socketId,
        "channel_name": channelName,
      });

      print("########SocketVerifyModel#############");
      print("URL: $url");
      print("Headers: $headers");
      print("Body: $body");

      // ✅ Make POST request
      final response = await http.post(
        Uri.parse(url),
        headers: {...headers, "Content-Type": "application/json"},
        body: body,
      );

      print("Response (${response.statusCode}): ${response.body}");
      print("#########SocketVerifyModel############");

      // ✅ Parse response
      if (response.statusCode == 200 || response.statusCode == 201) {
        _socketVerifyModel = SocketVerifyModel.fromJson(
          jsonDecode(response.body),
        );
        _socketVerifyModel.requestStatus = RequestStatus.loaded;
      } else if (response.statusCode == 401 || response.statusCode == 404) {
        _socketVerifyModel.requestStatus = RequestStatus.unauthorized;
      } else if (response.statusCode == 500) {
        _socketVerifyModel.requestStatus = RequestStatus.server;
      } else {
        throw HttpException("Unexpected response: ${response.statusCode}");
      }
    } on SocketException catch (e) {
      _firebaseService.firebaseSocketException(
        apiCall: "SocketVerifyModel",
        userId: userId,
        message: e.message,
      );
      throw Failure(e.message);
    } on FormatException catch (e) {
      _firebaseService.firebaseFormatException(
        apiCall: "SocketVerifyModel",
        userId: userId,
        message: e.message,
      );
      throw Failure(e.message);
    } on HttpException catch (e) {
      _firebaseService.firebaseHttpException(
        apiCall: "SocketVerifyModel",
        userId: userId,
        message: e.message,
      );
      throw Failure(e.message);
    } catch (e) {
      _firebaseService.firebaseDioError(
        apiCall: "SocketVerifyModel",
        code: "401|404",
        userId: userId,
        message: e.toString(),
      );
      throw Failure(e.toString());
    }

    return _socketVerifyModel;
  }

  StartTimerChatModel _startTimerChatModel = StartTimerChatModel();

  Future<StartTimerChatModel> getStartTimerChatModel({
    required String sessionId,
    required String roomId,
  }) async {
    const String url = "${GetBaseUrl + GetDomainUrl2}v1/session-timers/start";
    final headers = await authHeader();

    try {
      // ✅ Request body
      final body = jsonEncode({"session_id": sessionId, "room_id": roomId});

      print("#############StartTimerChatModel##################");
      print("URL: $url");
      print("Headers: $headers");
      print("Body: $body");

      // ✅ Make POST request
      final response = await http.post(
        Uri.parse(url),
        headers: {...headers, "Content-Type": "application/json"},
        body: body,
      );

      print("Response (${response.statusCode}): ${response.body}");
      print("#########StartTimerChatModel2############");

      // ✅ Parse response
      if (response.statusCode == 200 || response.statusCode == 201) {
        _startTimerChatModel = StartTimerChatModel.fromJson(
          jsonDecode(response.body),
        );
        _startTimerChatModel.requestStatus = RequestStatus.loaded;
      } else if (response.statusCode == 401 || response.statusCode == 404) {
        _startTimerChatModel.requestStatus = RequestStatus.unauthorized;
      } else if (response.statusCode == 500) {
        _startTimerChatModel.requestStatus = RequestStatus.server;
      } else {
        throw HttpException("Unexpected response: ${response.statusCode}");
      }
    } on SocketException catch (e) {
      _firebaseService.firebaseSocketException(
        apiCall: "StartTimerChatModel",
        userId: userId,
        message: e.message,
      );
      throw Failure(e.message);
    } on FormatException catch (e) {
      _firebaseService.firebaseFormatException(
        apiCall: "StartTimerChatModel",
        userId: userId,
        message: e.message,
      );
      throw Failure(e.message);
    } on HttpException catch (e) {
      _firebaseService.firebaseHttpException(
        apiCall: "StartTimerChatModel",
        userId: userId,
        message: e.message,
      );
      throw Failure(e.message);
    } catch (e) {
      _firebaseService.firebaseDioError(
        apiCall: "StartTimerChatModel",
        code: "401|404",
        userId: userId,
        message: e.toString(),
      );
      throw Failure(e.toString());
    }

    return _startTimerChatModel;
  }

  GetProfileModel _expertOnOffModel = GetProfileModel();

  Future<GetProfileModel> getExpertOnOffModel({
    required String available,
  }) async {
    const String url = "${GetBaseUrl + GetDomainUrl2}update-free-chat-status";
    final headers = await authHeader();

    try {
      // ✅ Request body
      final body = jsonEncode({"available_for_free_chat": available});

      print("#############_expertOnOffModel##################");
      print("URL: $url");
      print("Headers: $headers");
      print("Body: $body");

      // ✅ Make POST request
      final response = await http.post(
        Uri.parse(url),
        headers: {...headers, "Content-Type": "application/json"},
        body: body,
      );

      print("Response (${response.statusCode}): ${response.body}");
      print("#########_expertOnOffModel############");

      // ✅ Parse response
      if (response.statusCode == 200 || response.statusCode == 201) {
        _expertOnOffModel = GetProfileModel.fromJson(jsonDecode(response.body));
        _expertOnOffModel.requestStatus = RequestStatus.loaded;
      } else if (response.statusCode == 401 || response.statusCode == 404) {
        _expertOnOffModel.requestStatus = RequestStatus.unauthorized;
      } else if (response.statusCode == 500) {
        _expertOnOffModel.requestStatus = RequestStatus.server;
      } else {
        throw HttpException("Unexpected response: ${response.statusCode}");
      }
    } on SocketException catch (e) {
      _firebaseService.firebaseSocketException(
        apiCall: "_expertOnOffModel",
        userId: userId,
        message: e.message,
      );
      throw Failure(e.message);
    } on FormatException catch (e) {
      _firebaseService.firebaseFormatException(
        apiCall: "_expertOnOffModel",
        userId: userId,
        message: e.message,
      );
      throw Failure(e.message);
    } on HttpException catch (e) {
      _firebaseService.firebaseHttpException(
        apiCall: "_expertOnOffModel",
        userId: userId,
        message: e.message,
      );
      throw Failure(e.message);
    } catch (e) {
      _firebaseService.firebaseDioError(
        apiCall: "_expertOnOffModel",
        code: "401|404",
        userId: userId,
        message: e.toString(),
      );
      throw Failure(e.toString());
    }

    return _expertOnOffModel;
  }

  CallerUserInfoModel _userInfoModel = CallerUserInfoModel();

  Future<CallerUserInfoModel> getuserInfoModel({
    required dynamic userId,
  }) async {
    String url = "${GetBaseUrl + GetDomainUrl2}get-user?id=$userId";
    // final headers = await authHeader();

    try {
      print("#############_userInfoModel##################");
      print("URL: $url");
      //  print("Headers: $headers");

      // ✅ Make POST request
      final response = await http.get(
        Uri.parse(url),
        headers: {"Content-Type": "application/json"},
      );

      print("Response (${response.statusCode}): ${response.body}");
      print("#########_userInfoModel############");

      // ✅ Parse response
      if (response.statusCode == 200 || response.statusCode == 201) {
        _userInfoModel = CallerUserInfoModel.fromJson(
          jsonDecode(response.body),
        );
        _userInfoModel.requestStatus = RequestStatus.loaded;
      } else if (response.statusCode == 401 || response.statusCode == 404) {
        _userInfoModel.requestStatus = RequestStatus.unauthorized;
      } else if (response.statusCode == 500) {
        _userInfoModel.requestStatus = RequestStatus.server;
      } else {
        throw HttpException("Unexpected response: ${response.statusCode}");
      }
    } on SocketException catch (e) {
      _firebaseService.firebaseSocketException(
        apiCall: "_userInfoModel",
        userId: userId,
        message: e.message,
      );
      throw Failure(e.message);
    } on FormatException catch (e) {
      _firebaseService.firebaseFormatException(
        apiCall: "_userInfoModel",
        userId: userId,
        message: e.message,
      );
      throw Failure(e.message);
    } on HttpException catch (e) {
      _firebaseService.firebaseHttpException(
        apiCall: "_userInfoModel",
        userId: userId,
        message: e.message,
      );
      throw Failure(e.message);
    } catch (e) {
      _firebaseService.firebaseDioError(
        apiCall: "_userInfoModel",
        code: "401|404",
        userId: userId,
        message: e.toString(),
      );
      throw Failure(e.toString());
    }

    return _userInfoModel;
  }

  GetProfileModel _callOnOffModel = GetProfileModel();

  Future<GetProfileModel> getCallOnOffModel({required String available}) async {
    const String url = "${GetBaseUrl + GetDomainUrl2}update-call-status";
    final headers = await authHeader();

    try {
      // ✅ Request body
      final body = jsonEncode({"available_for_call": available});

      print("#############_callOnOffModel##################");
      print("URL: $url");
      print("Headers: $headers");
      print("Body: $body");

      // ✅ Make POST request
      final response = await http.post(
        Uri.parse(url),
        headers: {...headers, "Content-Type": "application/json"},
        body: body,
      );

      print("Response (${response.statusCode}): ${response.body}");
      print("#########_callOnOffModel############");

      // ✅ Parse response
      if (response.statusCode == 200 || response.statusCode == 201) {
        _callOnOffModel = GetProfileModel.fromJson(jsonDecode(response.body));
        _callOnOffModel.requestStatus = RequestStatus.loaded;
      } else if (response.statusCode == 401 || response.statusCode == 404) {
        _callOnOffModel.requestStatus = RequestStatus.unauthorized;
      } else if (response.statusCode == 500) {
        _callOnOffModel.requestStatus = RequestStatus.server;
      } else {
        throw HttpException("Unexpected response: ${response.statusCode}");
      }
    } on SocketException catch (e) {
      _firebaseService.firebaseSocketException(
        apiCall: "_callOnOffModel",
        userId: userId,
        message: e.message,
      );
      throw Failure(e.message);
    } on FormatException catch (e) {
      _firebaseService.firebaseFormatException(
        apiCall: "_callOnOffModel",
        userId: userId,
        message: e.message,
      );
      throw Failure(e.message);
    } on HttpException catch (e) {
      _firebaseService.firebaseHttpException(
        apiCall: "_callOnOffModel",
        userId: userId,
        message: e.message,
      );
      throw Failure(e.message);
    } catch (e) {
      _firebaseService.firebaseDioError(
        apiCall: "_expertOnOffModel",
        code: "401|404",
        userId: userId,
        message: e.toString(),
      );
      throw Failure(e.toString());
    }

    return _callOnOffModel;
  }

  GetProfileModel _chatOnOffModel = GetProfileModel();

  Future<GetProfileModel> getChatOnOffModel({required String available}) async {
    const String url = "${GetBaseUrl + GetDomainUrl2}update-chat-status";
    final headers = await authHeader();

    try {
      // ✅ Request body
      final body = jsonEncode({"available_for_chat": available});

      print("#############_chatOnOffModel##################");
      print("URL: $url");
      print("Headers: $headers");
      print("Body: $body");

      // ✅ Make POST request
      final response = await http.post(
        Uri.parse(url),
        headers: {...headers, "Content-Type": "application/json"},
        body: body,
      );

      print("Response (${response.statusCode}): ${response.body}");
      print("#########_chatOnOffModel############");

      // ✅ Parse response
      if (response.statusCode == 200 || response.statusCode == 201) {
        _chatOnOffModel = GetProfileModel.fromJson(jsonDecode(response.body));
        _chatOnOffModel.requestStatus = RequestStatus.loaded;
      } else if (response.statusCode == 401 || response.statusCode == 404) {
        _chatOnOffModel.requestStatus = RequestStatus.unauthorized;
      } else if (response.statusCode == 500) {
        _chatOnOffModel.requestStatus = RequestStatus.server;
      } else {
        throw HttpException("Unexpected response: ${response.statusCode}");
      }
    } on SocketException catch (e) {
      _firebaseService.firebaseSocketException(
        apiCall: "_chatOnOffModel",
        userId: userId,
        message: e.message,
      );
      throw Failure(e.message);
    } on FormatException catch (e) {
      _firebaseService.firebaseFormatException(
        apiCall: "_chatOnOffModel",
        userId: userId,
        message: e.message,
      );
      throw Failure(e.message);
    } on HttpException catch (e) {
      _firebaseService.firebaseHttpException(
        apiCall: "_chatOnOffModel",
        userId: userId,
        message: e.message,
      );
      throw Failure(e.message);
    } catch (e) {
      _firebaseService.firebaseDioError(
        apiCall: "_chatOnOffModel",
        code: "401|404",
        userId: userId,
        message: e.toString(),
      );
      throw Failure(e.toString());
    }

    return _chatOnOffModel;
  }

  ParterInfoModel _parterInfoModel = ParterInfoModel();
  Future<ParterInfoModel> getParterInfoModel({required dynamic userId2}) async {
    String url = "${GetBaseUrl + GetDomainUrl2}get-partner-details";
    final headers = await authHeader();

    try {
      print("#############_parterInfoModel##################");
      print("URL: $url");

      final body = jsonEncode({'user_id': userId2});

      final response = await http.post(
        Uri.parse(url),
        headers: {...headers, "Content-Type": "application/json"},

        body: body,
      );

      print("Body: $body");
      print("Response (${response.statusCode}): ${response.body}");
      print("#########_parterInfoModel############");

      if (response.statusCode == 200 || response.statusCode == 201) {
        _parterInfoModel = ParterInfoModel.fromJson(jsonDecode(response.body));
        _parterInfoModel.requestStatus = RequestStatus.loaded;
      } else if (response.statusCode == 401 || response.statusCode == 404) {
        _parterInfoModel.requestStatus = RequestStatus.unauthorized;
      } else if (response.statusCode == 500) {
        _parterInfoModel.requestStatus = RequestStatus.server;
      } else {
        throw HttpException("Unexpected response: ${response.statusCode}");
      }
    } catch (e) {
      _firebaseService.firebaseDioError(
        apiCall: "_parterInfoModel",
        code: "401|404",
        userId: userId,
        message: e.toString(),
      );
      throw Failure(e.toString());
    }

    return _parterInfoModel;
  }
}
