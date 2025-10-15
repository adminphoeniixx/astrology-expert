// ignore_for_file: avoid_print, deprecated_member_use

import 'dart:convert';
import 'dart:io';
import 'package:astro_partner_app/constants/string_const.dart';
import 'package:astro_partner_app/firebase/firebase_event.dart';
import 'package:astro_partner_app/helper/local_storage.dart';
import 'package:astro_partner_app/model/api_response.dart';
import 'package:astro_partner_app/model/auth/getprofile_model.dart';
import 'package:astro_partner_app/model/auth/sinup_model.dart';
import 'package:astro_partner_app/model/earning_details_model.dart';
import 'package:astro_partner_app/model/earning_list_model.dart';
import 'package:astro_partner_app/model/product_list_model.dart';
import 'package:astro_partner_app/model/review_list_model.dart';
import 'package:astro_partner_app/model/seassion_chat_model.dart';
import 'package:astro_partner_app/model/session_details_model.dart';
import 'package:astro_partner_app/model/session_model.dart';
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
  SignUpModel _signUpModel = SignUpModel();

  ApiResponse _apiResponse = ApiResponse();
  ApiResponse _authResponse = ApiResponse();
  SessionsModel _sessionsModel = SessionsModel();
  GetProfileModel _userProfile = GetProfileModel();
  EarningDetailsModel _earningDetailsModel = EarningDetailsModel();

  SessionDetailsModel _sessionDetailsModel = SessionDetailsModel();
  EarningListModel _earningListModel = EarningListModel();
  Future<ApiResponse> getResendOtp({required String mobile}) async {
    // Fetch FCM token
    // final fcmToken = await _fetchFcmToken();

    try {
      String url = GetBaseUrl + GetDomainUrl + RESEND_OTP;
      dynamic body = json.encode({"mobile_number": mobile});
      //dio.interceptors.add(performanceInterceptor);
      var response = await http.post(
        Uri.parse(url),
        headers: await authHeader(),
        body: body,
      );
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
    try {
      // Fetch FCM token
      final fcmToken = await _fetchFcmToken();

      String url = GetBaseUrl + GetDomainUrl + VERIFY_LOGIN_WITH_OTP;
      var request = http.MultipartRequest('POST', Uri.parse(url));

      // Prepare request body
      Map<String, String> body = {
        "mobile_number": mobile,
        "otp": otp,
        "device_token": fcmToken,
      };

      // Add to request
      request.fields.addAll(body);

      // ✅ Print request URL and body for debugging
      print("######## REQUEST DEBUG ########");
      print("URL: $url");
      print("Headers: ${request.headers}");
      print("Body: $body");
      print("################################");

      http.StreamedResponse response = await request.send();
      var responseData = await response.stream.bytesToString();

      print("######## RESPONSE DEBUG ########");
      print("Status Code: ${response.statusCode}");
      print("Body: $responseData");
      print("################################");

      if (response.statusCode == httpsCode_200 ||
          response.statusCode == httpsCode_201) {
        if (jsonDecode(responseData)['status']) {
          _signUpModel = SignUpModel.fromJson(jsonDecode(responseData));
          _signUpModel.requestStatus = RequestStatus.loaded;
        } else {
          showToast(context, msg: jsonDecode(responseData)['message']);
        }
      } else if (response.statusCode == httpsCode_404 ||
          response.statusCode == httpsCode_401) {
        _signUpModel.requestStatus = RequestStatus.unauthorized;
      } else if (response.statusCode == httpsCode_500) {
        _signUpModel.requestStatus = RequestStatus.server;
      }
    } on Error catch (e) {
      _firebaseService.firebaseDioError(
        apiCall: "getVerifyLoginWithOtp",
        code: "401|404",
        userId: userId,
        message: e.toString(),
      );
    } on SocketException catch (e) {
      _firebaseService.firebaseSocketException(
        apiCall: "getVerifyLoginWithOtp",
        userId: userId,
        message: e.message,
      );
      throw Failure(e.message);
    } on FormatException catch (e) {
      _firebaseService.firebaseFormatException(
        apiCall: "getVerifyLoginWithOtp",
        userId: userId,
        message: e.message,
      );
      throw Failure(e.message);
    } on HttpException catch (e) {
      _firebaseService.firebaseHttpException(
        apiCall: "getVerifyLoginWithOtp",
        userId: userId,
        message: e.message,
      );
      throw Failure(e.message);
    }

    return _signUpModel;
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
}
