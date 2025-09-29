// ignore_for_file: avoid_print, deprecated_member_use

import 'dart:convert';
import 'dart:io';
import 'package:astro_partner_app/constants/string_const.dart';
import 'package:astro_partner_app/firebase/firebase_event.dart';
import 'package:astro_partner_app/model/api_response.dart';
import 'package:astro_partner_app/model/auth/getprofile_model.dart';
import 'package:astro_partner_app/model/auth/sinup_model.dart';
import 'package:astro_partner_app/model/earning_details_model.dart';
import 'package:astro_partner_app/model/earning_list_model.dart';
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
  // HoroscopeListModel _horoscopeListModel = HoroscopeListModel();
  // ServiceDetailsModel _serviceDetailsModel = ServiceDetailsModel();
  // ProductListModel _productListModel = ProductListModel();
  // ProductDetailsModel _productDetailsModel = ProductDetailsModel();
  // ServiceTypesModel _serviceTypesModel = ServiceTypesModel();
  // ExpertsDataModel _expertsDataModel = ExpertsDataModel();
  // SlotsDataModel _slotsDataModel = SlotsDataModel();
  // ServiceOrderModel _serviceOrderModel = ServiceOrderModel();
  // CheckPaymentStatusModel _checkPaymentStatusModel = CheckPaymentStatusModel();
  ApiResponse _changePaymentStatus = ApiResponse();

  // UpCommingSessionsModel _commingSessionsModel = UpCommingSessionsModel();
  // JoinSessionModel _joinSessionModel = JoinSessionModel();
  // AudioModel _audioModel = AudioModel();
  // ChatSessionModel _chatSessionModel = ChatSessionModel();
  // AudioTimeRecodeModel _audioTimeRecodeModel = AudioTimeRecodeModel();
  // OrderListModel _orderListModel = OrderListModel();
  // SignUpModel _edituserPdofile = SignUpModel();
  // LikeVideoModel _likeVideoModel = LikeVideoModel();
  // LiveChatListModel _liveChatListModel = LiveChatListModel();
  // FreeChatModel _freeChatModel = FreeChatModel();

  // PodCastVideoModel _trandingVideoModel = PodCastVideoModel();
  // PodCastVideoModel _podCastVideoModel = PodCastVideoModel();
  // PodCastVideoModel _youtubeVideoModel = PodCastVideoModel();
  // CouponListModel _couponListModel = CouponListModel();
  // ServiceOrderModel _applyCoupon = ServiceOrderModel();
  // ServiceOrderModel _removeCoupon = ServiceOrderModel();
  // ChatAstrologerModel _chatAstrologerModel = ChatAstrologerModel();
  // ReviewListModel _reviewListModel = ReviewListModel();
  // VideoBannerModel _videoBannerModel = VideoBannerModel();

  // ProductCartModel _productCartModel = ProductCartModel();
  // AstrologerProfileModel _astrologerProfileModel = AstrologerProfileModel();

  // ProductCartModel _getProductCartModel = ProductCartModel();

  // ProductCartModel _removeProductCartModel = ProductCartModel();
  // CreateWalletModel _createWalletModel = CreateWalletModel();

  // ProductCartModel _applyStoreCoupon = ProductCartModel();
  // ServiceOrderModel _serviceApplyWalletModel = ServiceOrderModel();
  // ServiceOrderModel _serviceRemoveWalletModel = ServiceOrderModel();
  ApiResponse _productApplyWalletModel = ApiResponse();
  ApiResponse _productRemoveWalletModel = ApiResponse();
  ApiResponse _deleteUser = ApiResponse();
  ApiResponse _freeChatEmail = ApiResponse();
  ApiResponse _supportChatEmail = ApiResponse();
  GetProfileModel _userProfile = GetProfileModel();
  EarningDetailsModel _earningDetailsModel = EarningDetailsModel();
  // ProductCartModel _removeStoreCoupon = ProductCartModel();

  // ProductOrderModel _productOrderModel = ProductOrderModel();
  SessionDetailsModel _sessionDetailsModel = SessionDetailsModel();
  ApiResponse _apiResponseOrderPaymentConform = ApiResponse();
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
      dynamic request = http.MultipartRequest('POST', Uri.parse(url));

      request.fields.addAll({
        "mobile_number": mobile,
        "otp": otp,
        'device_token': fcmToken,
      });
      print("########token#############");
      print({"mobile_number": mobile, "otp": otp, 'device_token': fcmToken});

      http.StreamedResponse response = await request.send();
      dynamic responseData = await response.stream.bytesToString();
      print("########register response#############");
      print(responseData);
      print("#####################");
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
        // BasePrefs.clearPrefs().then((value) => Get.offAll(const LoadingPage()));
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
        userId: userId,
        message: e.message,
      );
      throw Failure("No Internet connection. Please check your network.");
    } on FormatException catch (e) {
      _firebaseService.firebaseFormatException(
        apiCall: "getSessionsModel",
        userId: userId,
        message: e.message,
      );
      throw Failure("Invalid server response format.");
    } on HttpException catch (e) {
      _firebaseService.firebaseHttpException(
        apiCall: "getSessionsModel",
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
      headers: {
        ...(await authHeader()),
        "Content-Type": "application/json",
      },
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

  // Future<HomeModel> getHomeDataForCheck(Map<String, String> authHeader) async {
  //   final fcmToken = await _fetchFcmToken();
  //   try {
  //     String url = GetBaseUrl + GetDomainUrl + GET_HOME;
  //     debugPrint("API URL: $url");
  //     // Prepare headers
  //     Map<String, String> headers = authHeader;
  //     headers['Content-Type'] = 'application/json';
  //     // Prepare request body
  //     Map<String, dynamic> requestBody = {'fcm_token': fcmToken};
  //     // Send POST request
  //     http.Response response = await http.post(
  //       Uri.parse(url),
  //       headers: headers,
  //       body: jsonEncode(requestBody),
  //     );
  //     print(headers);
  //     // Log response
  //     debugPrint("Response Status: ${response.statusCode}");
  //     debugPrint("Response Body: ${response.body}");
  //     if (response.statusCode == 200 || response.statusCode == 201) {
  //       _homeModel = HomeModel.fromJson(jsonDecode(response.body));
  //       _homeModel.requestStatus = RequestStatus.loaded;
  //     } else if (response.statusCode == 401 || response.statusCode == 404) {
  //       _homeModel.requestStatus = RequestStatus.unauthorized;
  //     } else if (response.statusCode == 500) {
  //       _homeModel.requestStatus = RequestStatus.server;
  //     } else {
  //       throw HttpException("Unexpected response: ${response.statusCode}");
  //     }
  //   } on SocketException catch (e) {
  //     _firebaseService.firebaseSocketException(
  //       apiCall: "getHomeData",
  //       userId: userId,
  //       message: e.message,
  //     );
  //     throw Failure("No Internet connection. Please check your network.");
  //   } on FormatException catch (e) {
  //     _firebaseService.firebaseFormatException(
  //       apiCall: "getHomeData",
  //       userId: userId,
  //       message: e.message,
  //     );
  //     throw Failure("Invalid server response format.");
  //   } on HttpException catch (e) {
  //     _firebaseService.firebaseHttpException(
  //       apiCall: "getHomeData",
  //       userId: userId,
  //       message: e.message,
  //     );
  //     throw Failure("HTTP Error: ${e.message}");
  //   } catch (e) {
  //     _firebaseService.firebaseDioError(
  //       apiCall: "getHomeData",
  //       code: "unknown",
  //       userId: userId,
  //       message: e.toString(),
  //     );
  //     throw Failure("An unexpected error occurred.");
  //   }

  //   return _homeModel; // Ensures _homeModel is never null
  // }

  // Future<HoroscopeListModel> getHoroscope() async {
  //   try {
  //     String url = GetBaseUrl + GetDomainUrl + GET_HOROSCOPE;
  //     //dio.interceptors.add(performanceInterceptor);
  //     dynamic request = http.Request('POST', Uri.parse(url));

  //     request.headers.addAll(await authHeader());

  //     http.StreamedResponse response = await request.send();

  //     dynamic responseData = await response.stream.bytesToString();

  //     if (response.statusCode == httpsCode_200 ||
  //         response.statusCode == httpsCode_201) {
  //       print("@@@@@@@@@@11111111111@@@@@@@");
  //       print(await authHeader());
  //       print(jsonDecode(responseData));
  //       print("@@@@@@@@11111111@@@@@@@@@");
  //       _horoscopeListModel = HoroscopeListModel.fromJson(
  //         jsonDecode(responseData),
  //       );
  //       _horoscopeListModel.requestStatus = RequestStatus.loaded;
  //     } else if (response.statusCode == httpsCode_404 ||
  //         response.statusCode == httpsCode_401) {
  //       // BasePrefs.clearPrefs().then((value) => Get.offAll(const LoadingPage()));
  //       _horoscopeListModel.requestStatus = RequestStatus.unauthorized;
  //     } else if (response.statusCode == httpsCode_500) {
  //       _horoscopeListModel.requestStatus = RequestStatus.server;
  //     }
  //   } on Error catch (e) {
  //     _firebaseService.firebaseDioError(
  //       apiCall: "getHoroscope",
  //       code: "401|404",
  //       userId: userId,
  //       message: e.toString(),
  //     );
  //   } on SocketException catch (e) {
  //     _firebaseService.firebaseSocketException(
  //       apiCall: "getHoroscope",
  //       userId: userId,
  //       message: e.message,
  //     );
  //     throw Failure(e.message);
  //   } on FormatException catch (e) {
  //     _firebaseService.firebaseFormatException(
  //       apiCall: "getHoroscope",
  //       userId: userId,
  //       message: e.message,
  //     );
  //     throw Failure(e.message);
  //   } on HttpException catch (e) {
  //     _firebaseService.firebaseHttpException(
  //       apiCall: "getHoroscope",
  //       userId: userId,
  //       message: e.message,
  //     );
  //     throw Failure(e.message);
  //   }
  //   return _horoscopeListModel;
  // }

  // Future<ServiceDetailsModel> getServicesDetailsData({required int id}) async {
  //   try {
  //     String url = GetBaseUrl + GetDomainUrl + SERVICE_DETAILS;
  //     //dio.interceptors.add(performanceInterceptor);
  //     // dynamic body = json.encode({"id": id});

  //     // var response = await http.post(Uri.parse(url),
  //     //     headers: await authHeader(), body: body);

  //     var request = http.MultipartRequest('POST', Uri.parse(url));

  //     request.headers.addAll(await authHeader());
  //     request.fields.addAll({"id": "$id"});

  //     http.StreamedResponse response = await request.send();

  //     dynamic responseData = await response.stream.bytesToString();

  //     if (response.statusCode == httpsCode_200 ||
  //         response.statusCode == httpsCode_201) {
  //       _serviceDetailsModel = ServiceDetailsModel.fromJson(
  //         jsonDecode(responseData),
  //       );
  //       _serviceDetailsModel.requestStatus = RequestStatus.loaded;
  //     } else if (response.statusCode == httpsCode_404 ||
  //         response.statusCode == httpsCode_401) {
  //       // BasePrefs.clearPrefs().then((value) => Get.offAll(const LoadingPage()));
  //       _homeModel.requestStatus = RequestStatus.unauthorized;
  //     } else if (response.statusCode == httpsCode_500) {
  //       _homeModel.requestStatus = RequestStatus.server;
  //     }
  //   } on Error catch (e) {
  //     _firebaseService.firebaseDioError(
  //       apiCall: "getServicesDetailsData",
  //       code: "401|404",
  //       userId: userId,
  //       message: e.toString(),
  //     );
  //   } on SocketException catch (e) {
  //     _firebaseService.firebaseSocketException(
  //       apiCall: "getServicesDetailsData",
  //       userId: userId,
  //       message: e.message,
  //     );
  //     throw Failure(e.message);
  //   } on FormatException catch (e) {
  //     _firebaseService.firebaseFormatException(
  //       apiCall: "getServicesDetailsData",
  //       userId: userId,
  //       message: e.message,
  //     );
  //     throw Failure(e.message);
  //   } on HttpException catch (e) {
  //     _firebaseService.firebaseHttpException(
  //       apiCall: "getServicesDetailsData",
  //       userId: userId,
  //       message: e.message,
  //     );
  //     throw Failure(e.message);
  //   }
  //   return _serviceDetailsModel;
  // }

  // Future<ProductListModel> getProductListData({
  //   required int id,
  //   required String url,
  // }) async {
  //   try {
  //     // String url = GetBaseUrl + GetDomainUrl + PRDUCTS;

  //     //dio.interceptors.add(performanceInterceptor);
  //     // dynamic body = json.encode({"id": id});
  //     // var response = await http.post(Uri.parse(url),
  //     //     headers: await authHeader(), body: body);

  //     var request = http.MultipartRequest('POST', Uri.parse(url));

  //     request.headers.addAll(await authHeader());
  //     request.fields.addAll({"id": "$id"});

  //     http.StreamedResponse response = await request.send();

  //     dynamic responseData = await response.stream.bytesToString();
  //     print(
  //       "!!!!!!!!!!!!!!!!!!!ProductListModel!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!",
  //     );
  //     print(await authHeader());
  //     print(responseData);
  //     print(
  //       "!!!!!!!!!!!!!!!!!!!ProductListModel!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!",
  //     );

  //     if (response.statusCode == httpsCode_200 ||
  //         response.statusCode == httpsCode_201) {
  //       _productListModel = ProductListModel.fromJson(jsonDecode(responseData));
  //       _productListModel.requestStatus = RequestStatus.loaded;
  //     } else if (response.statusCode == httpsCode_404 ||
  //         response.statusCode == httpsCode_401) {
  //       // BasePrefs.clearPrefs().then((value) => Get.offAll(const LoadingPage()));
  //       _productListModel.requestStatus = RequestStatus.unauthorized;
  //     } else if (response.statusCode == httpsCode_500) {
  //       _productListModel.requestStatus = RequestStatus.server;
  //     }
  //   } on Error catch (e) {
  //     _firebaseService.firebaseDioError(
  //       apiCall: "getServicesDetailsData",
  //       code: "401|404",
  //       userId: userId,
  //       message: e.toString(),
  //     );
  //   } on SocketException catch (e) {
  //     _firebaseService.firebaseSocketException(
  //       apiCall: "getServicesDetailsData",
  //       userId: userId,
  //       message: e.message,
  //     );
  //     throw Failure(e.message);
  //   } on FormatException catch (e) {
  //     _firebaseService.firebaseFormatException(
  //       apiCall: "getServicesDetailsData",
  //       userId: userId,
  //       message: e.message,
  //     );
  //     throw Failure(e.message);
  //   } on HttpException catch (e) {
  //     _firebaseService.firebaseHttpException(
  //       apiCall: "getServicesDetailsData",
  //       userId: userId,
  //       message: e.message,
  //     );
  //     throw Failure(e.message);
  //   }
  //   return _productListModel;
  // }

  // Future<ProductDetailsModel> getProductDetailsData({required int id}) async {
  //   try {
  //     String url = GetBaseUrl + GetDomainUrl + PRDUCTS_DETAILS;
  //     //dio.interceptors.add(performanceInterceptor);
  //     // dynamic body = json.encode({"id": id});
  //     // var response = await http.post(Uri.parse(url),
  //     //     headers: await authHeader(), body: body);
  //     var request = http.MultipartRequest('POST', Uri.parse(url));

  //     request.headers.addAll(await authHeader());
  //     request.fields.addAll({"id": "$id"});

  //     http.StreamedResponse response = await request.send();

  //     dynamic responseData = await response.stream.bytesToString();

  //     if (response.statusCode == httpsCode_200 ||
  //         response.statusCode == httpsCode_201) {
  //       _productDetailsModel = ProductDetailsModel.fromJson(
  //         jsonDecode(responseData),
  //       );
  //       _productListModel.requestStatus = RequestStatus.loaded;
  //     } else if (response.statusCode == httpsCode_404 ||
  //         response.statusCode == httpsCode_401) {
  //       // BasePrefs.clearPrefs().then((value) => Get.offAll(const LoadingPage()));
  //       _productListModel.requestStatus = RequestStatus.unauthorized;
  //     } else if (response.statusCode == httpsCode_500) {
  //       _productListModel.requestStatus = RequestStatus.server;
  //     }
  //   } on Error catch (e) {
  //     _firebaseService.firebaseDioError(
  //       apiCall: "getProductDetailsData",
  //       code: "401|404",
  //       userId: userId,
  //       message: e.toString(),
  //     );
  //   } on SocketException catch (e) {
  //     _firebaseService.firebaseSocketException(
  //       apiCall: "getProductDetailsData",
  //       userId: userId,
  //       message: e.message,
  //     );
  //     throw Failure(e.message);
  //   } on FormatException catch (e) {
  //     _firebaseService.firebaseFormatException(
  //       apiCall: "getProductDetailsData",
  //       userId: userId,
  //       message: e.message,
  //     );
  //     throw Failure(e.message);
  //   } on HttpException catch (e) {
  //     _firebaseService.firebaseHttpException(
  //       apiCall: "getProductDetailsData",
  //       userId: userId,
  //       message: e.message,
  //     );
  //     throw Failure(e.message);
  //   }
  //   return _productDetailsModel;
  // }

  // Future<ServiceTypesModel> getAllServicesTypeData({
  //   required String pageUrl,
  // }) async {
  //   try {
  //     // var response =
  //     //     await http.post(Uri.parse(pageUrl), headers: await authHeader());

  //     dynamic request = http.Request('POST', Uri.parse(pageUrl));

  //     request.headers.addAll(await authHeader());

  //     http.StreamedResponse response = await request.send();

  //     dynamic responseData = await response.stream.bytesToString();
  //     print("##########################");
  //     print(jsonDecode(responseData));
  //     if (response.statusCode == httpsCode_200 ||
  //         response.statusCode == httpsCode_201) {
  //       _serviceTypesModel = ServiceTypesModel.fromJson(
  //         jsonDecode(responseData),
  //       );
  //       print("##########################");
  //       _serviceTypesModel.requestStatus = RequestStatus.loaded;
  //     } else if (response.statusCode == httpsCode_404 ||
  //         response.statusCode == httpsCode_401) {
  //       // BasePrefs.clearPrefs().then((value) => Get.offAll(const LoadingPage()));
  //       _serviceTypesModel.requestStatus = RequestStatus.unauthorized;
  //     } else if (response.statusCode == httpsCode_500) {
  //       _serviceTypesModel.requestStatus = RequestStatus.server;
  //     }
  //   } on Error catch (e) {
  //     _firebaseService.firebaseDioError(
  //       apiCall: "getAllServicesTypeData",
  //       code: "401|404",
  //       userId: userId,
  //       message: e.toString(),
  //     );
  //   } on SocketException catch (e) {
  //     _firebaseService.firebaseSocketException(
  //       apiCall: "getAllServicesTypeData",
  //       userId: userId,
  //       message: e.message,
  //     );
  //     throw Failure(e.message);
  //   } on FormatException catch (e) {
  //     _firebaseService.firebaseFormatException(
  //       apiCall: "getAllServicesTypeData",
  //       userId: userId,
  //       message: e.message,
  //     );
  //     throw Failure(e.message);
  //   } on HttpException catch (e) {
  //     _firebaseService.firebaseHttpException(
  //       apiCall: "getAllServicesTypeData",
  //       userId: userId,
  //       message: e.message,
  //     );
  //     throw Failure(e.message);
  //   }
  //   return _serviceTypesModel;
  // }

  // Future<ExpertsDataModel> getAllExpertsData({
  //   required String pageUrl,
  //   required int serviceId,
  // }) async {
  //   try {
  //     var request = http.MultipartRequest('POST', Uri.parse(pageUrl));

  //     request.fields.addAll({"service_id": "$serviceId"});

  //     request.headers.addAll(await authHeader());

  //     http.StreamedResponse response = await request.send();

  //     dynamic responseData = await response.stream.bytesToString();
  //     print("@@@@@@@@@@SLOTS@@@@@@@@@@@@");

  //     print(responseData);
  //     if (response.statusCode == httpsCode_200 ||
  //         response.statusCode == httpsCode_201) {
  //       _expertsDataModel = ExpertsDataModel.fromJson(jsonDecode(responseData));

  //       _expertsDataModel.requestStatus = RequestStatus.loaded;
  //     } else if (response.statusCode == httpsCode_404 ||
  //         response.statusCode == httpsCode_401) {
  //       // BasePrefs.clearPrefs().then((value) => Get.offAll(const LoadingPage()));
  //       _expertsDataModel.requestStatus = RequestStatus.unauthorized;
  //     } else if (response.statusCode == httpsCode_500) {
  //       _expertsDataModel.requestStatus = RequestStatus.server;
  //     }
  //   } on Error catch (e) {
  //     _firebaseService.firebaseDioError(
  //       apiCall: "getAllExpertsData",
  //       code: "401|404",
  //       userId: userId,
  //       message: e.toString(),
  //     );
  //   } on SocketException catch (e) {
  //     _firebaseService.firebaseSocketException(
  //       apiCall: "getAllExpertsData",
  //       userId: userId,
  //       message: e.message,
  //     );
  //     throw Failure(e.message);
  //   } on FormatException catch (e) {
  //     _firebaseService.firebaseFormatException(
  //       apiCall: "getAllExpertsData",
  //       userId: userId,
  //       message: e.message,
  //     );
  //     throw Failure(e.message);
  //   } on HttpException catch (e) {
  //     _firebaseService.firebaseHttpException(
  //       apiCall: "getAllExpertsData",
  //       userId: userId,
  //       message: e.message,
  //     );
  //     throw Failure(e.message);
  //   }
  //   return _expertsDataModel;
  // }

  // Future<SlotsDataModel> getSlotsData({
  //   required String pageUrl,
  //   required int serviceId,
  //   required int expertId,
  //   required String date,
  // }) async {
  //   try {
  //     // dynamic body = json.encode(
  //     //     {'service_id': serviceId, 'expert_id': expertId, 'date': date});
  //     // var response = await http.post(Uri.parse(pageUrl),
  //     //     headers: await authHeader(), body: body);

  //     var request = http.MultipartRequest('POST', Uri.parse(pageUrl));

  //     request.headers.addAll(await authHeader());

  //     request.fields.addAll({
  //       'service_id': "$serviceId",
  //       'expert_id': "$expertId",
  //       'date': date,
  //     });

  //     http.StreamedResponse response = await request.send();

  //     dynamic responseData = await response.stream.bytesToString();

  //     print("@@@@@@@@@@SLOTS@@@@@@@@@@@@");
  //     print({
  //       'service_id': "$serviceId",
  //       'expert_id': "$expertId",
  //       'date': date,
  //     });

  //     print(responseData);

  //     if (response.statusCode == httpsCode_200 ||
  //         response.statusCode == httpsCode_201) {
  //       _slotsDataModel = SlotsDataModel.fromJson(jsonDecode(responseData));
  //       print("@@@@@@@@@@@@@@@@@@@@@@");
  //       _slotsDataModel.requestStatus = RequestStatus.loaded;
  //     } else if (response.statusCode == httpsCode_404 ||
  //         response.statusCode == httpsCode_401) {
  //       // BasePrefs.clearPrefs().then((value) => Get.offAll(const LoadingPage()));
  //       _slotsDataModel.requestStatus = RequestStatus.unauthorized;
  //     } else if (response.statusCode == httpsCode_500) {
  //       _slotsDataModel.requestStatus = RequestStatus.server;
  //     }
  //   } on Error catch (e) {
  //     _firebaseService.firebaseDioError(
  //       apiCall: "getSlotsData",
  //       code: "401|404",
  //       userId: userId,
  //       message: e.toString(),
  //     );
  //   } on SocketException catch (e) {
  //     _firebaseService.firebaseSocketException(
  //       apiCall: "getSlotsData",
  //       userId: userId,
  //       message: e.message,
  //     );
  //     throw Failure(e.message);
  //   } on FormatException catch (e) {
  //     _firebaseService.firebaseFormatException(
  //       apiCall: "getSlotsData",
  //       userId: userId,
  //       message: e.message,
  //     );
  //     throw Failure(e.message);
  //   } on HttpException catch (e) {
  //     _firebaseService.firebaseHttpException(
  //       apiCall: "getSlotsData",
  //       userId: userId,
  //       message: e.message,
  //     );
  //     throw Failure(e.message);
  //   }
  //   return _slotsDataModel;
  // }

  // Future<ServiceOrderModel> serviceOrderPlacedApi({
  //   required int serviceId,
  //   required int serviceTypeId,
  //   required int expertId,
  //   required List<int> slots,
  //   required int audioSlots,
  //   required String date,
  //   required String fullName,
  //   required String birthTime,
  //   required String dateOfBirth,
  //   required String placeOfBirth,
  //   required String birthTmeAccuracy,
  //   required String partnerName,
  //   required String partnerdob,
  //   required String partnerBirthTime,
  //   required String partnerBirthPlace,
  //   required String audioQuestion,
  //   required String partnerbirthTmeAccuracy,
  //   required List<File> files,
  // }) async {
  //   try {
  //     String slotsResult = slots.join(',');
  //     String url = GetBaseUrl + GetDomainUrl + SERVICEORDERPLACED;
  //     // dynamic body = json.encode(
  //     //     {'service_id': serviceId, 'expert_id': expertId, 'date': date});
  //     // var response = await http.post(Uri.parse(pageUrl),
  //     //     headers: await authHeader(), body: body);

  //     var request = http.MultipartRequest('POST', Uri.parse(url));

  //     request.headers.addAll(await authHeader());

  //     if (serviceTypeId == 2) {
  //       request.fields.addAll({
  //         'service_id': '$serviceId',
  //         'service_type_id': '$serviceTypeId',
  //         'expert_id': '$expertId',
  //         'date': date,
  //         'slots': '$audioSlots',
  //         'full_name': fullName,
  //         'birth_time': birthTime,
  //         'date_of_birth': dateOfBirth,
  //         'place_of_birth': placeOfBirth,
  //         'birth_time_accuracy': birthTmeAccuracy,
  //         'partner_name': partnerName,
  //         'partner_date_of_birth': partnerdob,
  //         'partner_birth_time': partnerBirthTime,
  //         'partner_place_of_birth': partnerBirthPlace,
  //         'question_description': audioQuestion,
  //         'birth_partner_accuracy': partnerbirthTmeAccuracy,
  //       });
  //     } else {
  //       request.fields.addAll({
  //         'service_id': '$serviceId',
  //         'service_type_id': '$serviceTypeId',
  //         'expert_id': '$expertId',
  //         'date': date,
  //         'slots': slotsResult,
  //         'full_name': fullName,
  //         'birth_time': birthTime,
  //         'date_of_birth': dateOfBirth,
  //         'place_of_birth': placeOfBirth,
  //         'birth_time_accuracy': birthTmeAccuracy,
  //         'partner_name': partnerName,
  //         'partner_date_of_birth': partnerdob,
  //         'partner_birth_time': partnerBirthTime,
  //         'partner_place_of_birth': partnerBirthPlace,
  //         'birth_partner_accuracy': partnerbirthTmeAccuracy,
  //       });
  //     }

  //     for (var element in files) {
  //       request.files.add(
  //         await http.MultipartFile.fromPath('attachments[]', element.path),
  //       );
  //     }

  //     http.StreamedResponse response = await request.send();

  //     dynamic responseData = await response.stream.bytesToString();
  //     print("@@@@@@@@@@@ Create Service order OUTPUT@@@@@@@@@@@");
  //     for (var entry in request.fields.entries) {
  //       print("${entry.key}: ${entry.value}");
  //     }
  //     print(responseData);
  //     print("@@@@@@@@@@@Create audio Service order OUTPUT@@@@@@@@@@");
  //     if (response.statusCode == httpsCode_200 ||
  //         response.statusCode == httpsCode_201) {
  //       _serviceOrderModel = ServiceOrderModel.fromJson(
  //         jsonDecode(responseData),
  //       );
  //       print("@@@@@@@@@@@Create Service order OUTPUT@@@@@@@@@@@");
  //       _serviceOrderModel.requestStatus = RequestStatus.loaded;
  //     } else if (response.statusCode == httpsCode_404 ||
  //         response.statusCode == httpsCode_401) {
  //       // BasePrefs.clearPrefs().then((value) => Get.offAll(const LoadingPage()));
  //       _serviceOrderModel.requestStatus = RequestStatus.unauthorized;
  //     } else if (response.statusCode == httpsCode_500) {
  //       _serviceOrderModel.requestStatus = RequestStatus.server;
  //     }
  //   } on Error catch (e) {
  //     _firebaseService.firebaseDioError(
  //       apiCall: "serviceOrderPlacedApi",
  //       code: "401|404",
  //       userId: userId,
  //       message: e.toString(),
  //     );
  //   } on SocketException catch (e) {
  //     _firebaseService.firebaseSocketException(
  //       apiCall: "serviceOrderPlacedApi",
  //       userId: userId,
  //       message: e.message,
  //     );
  //     throw Failure(e.message);
  //   } on FormatException catch (e) {
  //     _firebaseService.firebaseFormatException(
  //       apiCall: "serviceOrderPlacedApi",
  //       userId: userId,
  //       message: e.message,
  //     );
  //     throw Failure(e.message);
  //   } on HttpException catch (e) {
  //     _firebaseService.firebaseHttpException(
  //       apiCall: "serviceOrderPlacedApi",
  //       userId: userId,
  //       message: e.message,
  //     );
  //     throw Failure(e.message);
  //   }
  //   return _serviceOrderModel;
  // }

  // Future<ServiceOrderModel> applyCouponApi(
  //     {required int orderId, required String couponCode}) async {
  //   try {
  //     String url = GetBaseUrl + GetDomainUrl + SERVICEORDERPLACED;
  //     // dynamic body = json.encode(
  //     //     {'service_id': serviceId, 'expert_id': expertId, 'date': date});
  //     // var response = await http.post(Uri.parse(pageUrl),
  //     //     headers: await authHeader(), body: body);
  //     var request = http.MultipartRequest('POST', Uri.parse(url));
  //     request.headers.addAll(await authHeader());
  //     request.fields
  //         .addAll({'order_id': '$orderId', 'coupon_code': couponCode});
  //     http.StreamedResponse response = await request.send();
  //     dynamic responseData = await response.stream.bytesToString();
  //     print("@@@@@@@@@@@OUTPUT@@@@@@@@@@@");
  //     print(responseData);
  //     if (response.statusCode == httpsCode_200 ||
  //         response.statusCode == httpsCode_201) {
  //       _serviceOrderModel =
  //           ServiceOrderModel.fromJson(jsonDecode(responseData));
  //       print("@@@@@@@@@@@@@@@@@@@@@@");
  //       _serviceOrderModel.requestStatus = RequestStatus.loaded;
  //     } else if (response.statusCode == httpsCode_404 ||
  //         response.statusCode == httpsCode_401) {
  //       // BasePrefs.clearPrefs().then((value) => Get.offAll(const LoadingPage()));
  //       _serviceOrderModel.requestStatus = RequestStatus.unauthorized;
  //     } else if (response.statusCode == httpsCode_500) {
  //       _serviceOrderModel.requestStatus = RequestStatus.server;
  //     }
  //   } on Error catch (e) {
  //     _firebaseService.firebaseDioError(
  //         apiCall: "getSlotsData",
  //         code: "401|404",
  //         userId: userId,
  //         message: e.toString());
  //   } on SocketException catch (e) {
  //     _firebaseService.firebaseSocketException(
  //         apiCall: "getSlotsData", userId: userId, message: e.message);
  //     throw Failure(e.message);
  //   } on FormatException catch (e) {
  //     _firebaseService.firebaseFormatException(
  //         apiCall: "getSlotsData", userId: userId, message: e.message);
  //     throw Failure(e.message);
  //   } on HttpException catch (e) {
  //     _firebaseService.firebaseHttpException(
  //         apiCall: "getSlotsData", userId: userId, message: e.message);
  //     throw Failure(e.message);
  //   }
  //   return _serviceOrderModel;
  // }

  Future<ApiResponse> changePaymentStatus({
    required int orderId,
    required String transactionId,
    required String status,
    required String paymentMode,
    required String totalMinutes,
    required String paymentType,
    File? screenshot,
  }) async {
    try {
      print("@@@@@@@@@@@checkPaymentStatus@@@@@@@@@@@");
      String url = GetBaseUrl + GetDomainUrl + CONFORM_ORDER;
      var request = http.MultipartRequest('POST', Uri.parse(url));
      request.headers.addAll(await authHeader());
      request.fields.addAll({
        'order_id': '$orderId',
        'status': status,
        'transaction_id': transactionId,
        'payment_mode': paymentMode,
        'session_time': totalMinutes,
        'payment_type': paymentType,
      });

      if (screenshot != null) {
        request.files.add(
          await http.MultipartFile.fromPath('screenshot', screenshot.path),
        );
      }
      http.StreamedResponse response = await request.send();
      dynamic responseData = await response.stream.bytesToString();
      print("@@@@@@@@@@@OUTPUT@@@@@@@@@@@");
      print(url);
      print(response.statusCode);
      print(screenshot);
      print({
        'order_id': '$orderId',
        'status': status,
        'transaction_id': transactionId,
        'payment_mode': paymentMode,
        'session_time': totalMinutes,
        'payment_type': paymentType,
      });
      print(responseData);
      print("@@@@@@@@@@@OUTPUT@@@@@@@@@@@");
      if (response.statusCode == httpsCode_200 ||
          response.statusCode == httpsCode_201) {
        _changePaymentStatus = ApiResponse.fromJson(jsonDecode(responseData));
        _changePaymentStatus.requestStatus = RequestStatus.loaded;
      } else if (response.statusCode == httpsCode_404 ||
          response.statusCode == httpsCode_401) {
        // BasePrefs.clearPrefs().then((value) => Get.offAll(const LoadingPage()));
        _changePaymentStatus.requestStatus = RequestStatus.unauthorized;
      } else if (response.statusCode == httpsCode_500) {
        _changePaymentStatus.requestStatus = RequestStatus.server;
      }
    } on Error catch (e) {
      _firebaseService.firebaseDioError(
        apiCall: "getSlotsData",
        code: "401|404",
        userId: userId,
        message: e.toString(),
      );
    } on SocketException catch (e) {
      _firebaseService.firebaseSocketException(
        apiCall: "getSlotsData",
        userId: userId,
        message: e.message,
      );
      throw Failure(e.message);
    } on FormatException catch (e) {
      _firebaseService.firebaseFormatException(
        apiCall: "getSlotsData",
        userId: userId,
        message: e.message,
      );
      throw Failure(e.message);
    } on HttpException catch (e) {
      _firebaseService.firebaseHttpException(
        apiCall: "getSlotsData",
        userId: userId,
        message: e.message,
      );
      throw Failure(e.message);
    }
    return _changePaymentStatus;
  }

  // Future<CheckPaymentStatusModel> checkPaymentStatus({
  //   required String merchantId,
  //   required String transactionId,
  //   required String saltIndex,
  // }) async {
  //   try {
  //     String url =
  //         "https://mercury-uat.phonepe.com/v3/transaction/$merchantId/$transactionId/status ";

  //     String concatString =
  //         "/v3/transaction/$merchantId/$transactionId/status$saltIndex";
  //     var byts = utf8.encode(concatString);
  //     String digest = sha256.convert(byts).toString();
  //     String xVerify = "$digest###$saltIndex";
  //     Map<String, String> header = {
  //       "Content-Type": "application/json",
  //       "X-VERIFY": xVerify,
  //       "X-MERCHANT-ID": merchantId,
  //     };
  //     Response response = await http.get(Uri.parse(url), headers: header);
  //     print("@@@@@@@@@@@checkPaymentStatus@@@@@@@@@@@");
  //     print(response.body);
  //     if (response.statusCode == httpsCode_200 ||
  //         response.statusCode == httpsCode_201) {
  //       _checkPaymentStatusModel = checkPaymentStatusModelFromJson(
  //         response.body,
  //       );
  //       print("@@@@@@@@@@@checkPaymentStatus@@@@@@@@@@@");
  //       _checkPaymentStatusModel.requestStatus = RequestStatus.loaded;
  //     } else if (response.statusCode == httpsCode_404 ||
  //         response.statusCode == httpsCode_401) {
  //       // BasePrefs.clearPrefs().then((value) => Get.offAll(const LoadingPage()));
  //       _checkPaymentStatusModel.requestStatus = RequestStatus.unauthorized;
  //     } else if (response.statusCode == httpsCode_500) {
  //       _checkPaymentStatusModel.requestStatus = RequestStatus.server;
  //     }
  //   } on Error catch (e) {
  //     _firebaseService.firebaseDioError(
  //       apiCall: "checkPaymentStatus",
  //       code: "401|404",
  //       userId: userId,
  //       message: e.toString(),
  //     );
  //   } on SocketException catch (e) {
  //     _firebaseService.firebaseSocketException(
  //       apiCall: "checkPaymentStatus",
  //       userId: userId,
  //       message: e.message,
  //     );
  //     throw Failure(e.message);
  //   } on FormatException catch (e) {
  //     _firebaseService.firebaseFormatException(
  //       apiCall: "checkPaymentStatus",
  //       userId: userId,
  //       message: e.message,
  //     );
  //     throw Failure(e.message);
  //   } on HttpException catch (e) {
  //     _firebaseService.firebaseHttpException(
  //       apiCall: "checkPaymentStatus",
  //       userId: userId,
  //       message: e.message,
  //     );
  //     throw Failure(e.message);
  //   }
  //   return _checkPaymentStatusModel;
  // }

  // Future<UpCommingSessionsModel> getCommingSessionsData({
  //   required String pageUrl,
  // }) async {
  //   try {
  //     // var response =
  //     //     await http.post(Uri.parse(pageUrl), headers: await authHeader());

  //     dynamic request = http.Request('POST', Uri.parse(pageUrl));

  //     request.headers.addAll(await authHeader());

  //     http.StreamedResponse response = await request.send();

  //     dynamic responseData = await response.stream.bytesToString();
  //     print("##########################");
  //     print(jsonDecode(responseData));
  //     if (response.statusCode == httpsCode_200 ||
  //         response.statusCode == httpsCode_201) {
  //       _commingSessionsModel = upCommingSessionsModelFromJson(responseData);
  //       print("##########################");
  //       _commingSessionsModel.requestStatus = RequestStatus.loaded;
  //     } else if (response.statusCode == httpsCode_404 ||
  //         response.statusCode == httpsCode_401) {
  //       // BasePrefs.clearPrefs().then((value) => Get.offAll(const LoadingPage()));
  //       _commingSessionsModel.requestStatus = RequestStatus.unauthorized;
  //     } else if (response.statusCode == httpsCode_500) {
  //       _commingSessionsModel.requestStatus = RequestStatus.server;
  //     }
  //   } on Error catch (e) {
  //     _firebaseService.firebaseDioError(
  //       apiCall: "getCommingSessionsData",
  //       code: "401|404",
  //       userId: userId,
  //       message: e.toString(),
  //     );
  //   } on SocketException catch (e) {
  //     _firebaseService.firebaseSocketException(
  //       apiCall: "getCommingSessionsData",
  //       userId: userId,
  //       message: e.message,
  //     );
  //     throw Failure(e.message);
  //   } on FormatException catch (e) {
  //     _firebaseService.firebaseFormatException(
  //       apiCall: "getCommingSessionsData",
  //       userId: userId,
  //       message: e.message,
  //     );
  //     throw Failure(e.message);
  //   } on HttpException catch (e) {
  //     _firebaseService.firebaseHttpException(
  //       apiCall: "getCommingSessionsData",
  //       userId: userId,
  //       message: e.message,
  //     );
  //     throw Failure(e.message);
  //   }
  //   return _commingSessionsModel;
  // }

  // Future<JoinSessionModel> joinSessions({required String sessionId}) async {
  //   try {
  //     String url = GetBaseUrl + GetDomainUrl + JOIN_SESSION;
  //     print("##########################");
  //     print(await authHeader());
  //     print(url);
  //     var request = http.MultipartRequest('POST', Uri.parse(url));
  //     request.fields.addAll({'session_id': sessionId});
  //     request.headers.addAll(await authHeader());
  //     http.StreamedResponse response = await request.send();
  //     dynamic responseData = await response.stream.bytesToString();
  //     print("##########################");
  //     print(jsonDecode(responseData));
  //     if (response.statusCode == httpsCode_200 ||
  //         response.statusCode == httpsCode_201) {
  //       _joinSessionModel = joinSessionModelFromJson(responseData);
  //       print("##########################");
  //       _joinSessionModel.requestStatus = RequestStatus.loaded;
  //     } else if (response.statusCode == httpsCode_404 ||
  //         response.statusCode == httpsCode_401) {
  //       // BasePrefs.clearPrefs().then((value) => Get.offAll(const LoadingPage()));
  //       _joinSessionModel.requestStatus = RequestStatus.unauthorized;
  //     } else if (response.statusCode == httpsCode_500) {
  //       _joinSessionModel.requestStatus = RequestStatus.server;
  //     }
  //   } on Error catch (e) {
  //     _firebaseService.firebaseDioError(
  //       apiCall: "joinSessions",
  //       code: "401|404",
  //       userId: userId,
  //       message: e.toString(),
  //     );
  //   } on SocketException catch (e) {
  //     _firebaseService.firebaseSocketException(
  //       apiCall: "joinSessions",
  //       userId: userId,
  //       message: e.message,
  //     );
  //     throw Failure(e.message);
  //   } on FormatException catch (e) {
  //     _firebaseService.firebaseFormatException(
  //       apiCall: "joinSessions",
  //       userId: userId,
  //       message: e.message,
  //     );
  //     throw Failure(e.message);
  //   } on HttpException catch (e) {
  //     _firebaseService.firebaseHttpException(
  //       apiCall: "joinSessions",
  //       userId: userId,
  //       message: e.message,
  //     );
  //     throw Failure(e.message);
  //   }
  //   return _joinSessionModel;
  // }

  // Future<AudioModel> joinAudioSessions({required String sessionId}) async {
  //   try {
  //     String url = GetBaseUrl + GetDomainUrl + JOIN_AUDIO_SESSION;
  //     var request = http.MultipartRequest('POST', Uri.parse(url));
  //     request.fields.addAll({'session_id': sessionId});
  //     request.headers.addAll(await authHeader());
  //     http.StreamedResponse response = await request.send();
  //     dynamic responseData = await response.stream.bytesToString();
  //     print("##########################");
  //     print(await authHeader());
  //     print({'session_id': sessionId});
  //     print(jsonDecode(responseData));
  //     if (response.statusCode == httpsCode_200 ||
  //         response.statusCode == httpsCode_201) {
  //       _audioModel = audioModelFromJson(responseData);
  //       print("##########################");
  //       _audioModel.requestStatus = RequestStatus.loaded;
  //     } else if (response.statusCode == httpsCode_404 ||
  //         response.statusCode == httpsCode_401) {
  //       // BasePrefs.clearPrefs().then((value) => Get.offAll(const LoadingPage()));
  //       _audioModel.requestStatus = RequestStatus.unauthorized;
  //     } else if (response.statusCode == httpsCode_500) {
  //       _audioModel.requestStatus = RequestStatus.server;
  //     }
  //   } on Error catch (e) {
  //     _firebaseService.firebaseDioError(
  //       apiCall: "joinAudioSessions",
  //       code: "401|404",
  //       userId: userId,
  //       message: e.toString(),
  //     );
  //   } on SocketException catch (e) {
  //     _firebaseService.firebaseSocketException(
  //       apiCall: "joinAudioSessions",
  //       userId: userId,
  //       message: e.message,
  //     );
  //     throw Failure(e.message);
  //   } on FormatException catch (e) {
  //     _firebaseService.firebaseFormatException(
  //       apiCall: "joinAudioSessions",
  //       userId: userId,
  //       message: e.message,
  //     );
  //     throw Failure(e.message);
  //   } on HttpException catch (e) {
  //     _firebaseService.firebaseHttpException(
  //       apiCall: "joinAudioSessions",
  //       userId: userId,
  //       message: e.message,
  //     );
  //     throw Failure(e.message);
  //   }
  //   return _audioModel;
  // }

  // Future<ChatSessionModel> joinChatSessions({required String sessionId}) async {
  //   try {
  //     String url = GetBaseUrl + GetDomainUrl + JOIN_CHAT_SESSION;

  //     var request = http.MultipartRequest('POST', Uri.parse(url));
  //     request.fields.addAll({'session_id': sessionId});

  //     request.headers.addAll(await authHeader());

  //     http.StreamedResponse response = await request.send();
  //     dynamic responseData = await response.stream.bytesToString();
  //     print("##########################");
  //     print({'session_id': sessionId});
  //     print(jsonDecode(responseData));
  //     if (response.statusCode == httpsCode_200 ||
  //         response.statusCode == httpsCode_201) {
  //       _chatSessionModel = chatSessionModelFromJson(responseData);
  //       print("##########################");
  //       _chatSessionModel.requestStatus = RequestStatus.loaded;
  //     } else if (response.statusCode == httpsCode_404 ||
  //         response.statusCode == httpsCode_401) {
  //       // BasePrefs.clearPrefs().then((value) => Get.offAll(const LoadingPage()));
  //       _chatSessionModel.requestStatus = RequestStatus.unauthorized;
  //     } else if (response.statusCode == httpsCode_500) {
  //       _chatSessionModel.requestStatus = RequestStatus.server;
  //     }
  //   } on Error catch (e) {
  //     _firebaseService.firebaseDioError(
  //       apiCall: "joinAudioSessions",
  //       code: "401|404",
  //       userId: userId,
  //       message: e.toString(),
  //     );
  //   } on SocketException catch (e) {
  //     _firebaseService.firebaseSocketException(
  //       apiCall: "joinAudioSessions",
  //       userId: userId,
  //       message: e.message,
  //     );
  //     throw Failure(e.message);
  //   } on FormatException catch (e) {
  //     _firebaseService.firebaseFormatException(
  //       apiCall: "joinAudioSessions",
  //       userId: userId,
  //       message: e.message,
  //     );
  //     throw Failure(e.message);
  //   } on HttpException catch (e) {
  //     _firebaseService.firebaseHttpException(
  //       apiCall: "joinAudioSessions",
  //       userId: userId,
  //       message: e.message,
  //     );
  //     throw Failure(e.message);
  //   }
  //   return _chatSessionModel;
  // }

  // Future<AudioTimeRecodeModel> getAudioRecodingTime({
  //   required int serviceId,
  //   required int expertId,
  // }) async {
  //   try {
  //     String url = GetBaseUrl + GetDomainUrl + GET_AUDIO_TIME;
  //     print("##########AudioTimeRecodeModel################");
  //     print(url);
  //     var request = http.MultipartRequest('POST', Uri.parse(url));

  //     request.headers.addAll(await authHeader());

  //     request.fields.addAll({
  //       'service_id': "$serviceId",
  //       'expert_id': "$expertId",
  //     });

  //     http.StreamedResponse response = await request.send();
  //     dynamic responseData = await response.stream.bytesToString();

  //     print(jsonDecode(responseData));
  //     if (response.statusCode == httpsCode_200 ||
  //         response.statusCode == httpsCode_201) {
  //       _audioTimeRecodeModel = audioTimeRecodeModelFromJson(responseData);
  //       print("#########AudioTimeRecodeModel#################");
  //       _audioModel.requestStatus = RequestStatus.loaded;
  //     } else if (response.statusCode == httpsCode_404 ||
  //         response.statusCode == httpsCode_401) {
  //       // BasePrefs.clearPrefs().then((value) => Get.offAll(const LoadingPage()));
  //       _audioTimeRecodeModel.requestStatus = RequestStatus.unauthorized;
  //     } else if (response.statusCode == httpsCode_500) {
  //       _audioTimeRecodeModel.requestStatus = RequestStatus.server;
  //     }
  //   } on Error catch (e) {
  //     _firebaseService.firebaseDioError(
  //       apiCall: "getAudioRecodingTime",
  //       code: "401|404",
  //       userId: userId,
  //       message: e.toString(),
  //     );
  //   } on SocketException catch (e) {
  //     _firebaseService.firebaseSocketException(
  //       apiCall: "getAudioRecodingTime",
  //       userId: userId,
  //       message: e.message,
  //     );
  //     throw Failure(e.message);
  //   } on FormatException catch (e) {
  //     _firebaseService.firebaseFormatException(
  //       apiCall: "getAudioRecodingTime",
  //       userId: userId,
  //       message: e.message,
  //     );
  //     throw Failure(e.message);
  //   } on HttpException catch (e) {
  //     _firebaseService.firebaseHttpException(
  //       apiCall: "getAudioRecodingTime",
  //       userId: userId,
  //       message: e.message,
  //     );
  //     throw Failure(e.message);
  //   }
  //   return _audioTimeRecodeModel;
  // }

  // // API call to create meeting
  // Future<String> createMeeting() async {
  //   String token =
  //       "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJhcGlrZXkiOiIyNjRjNGJmMC0yM2FkLTRhMTgtOTg2OS0yYjgzZDAwYjgyZGEiLCJwZXJtaXNzaW9ucyI6WyJhbGxvd19qb2luIl0sImlhdCI6MTcyMTM2NDQ3NywiZXhwIjoxNzIzOTU2NDc3fQ.1rdxkot3PseuVrZaJTA5jgAadieplkpK8RYD0Q2NkBM";
  //   final http.Response httpResponse = await http.post(
  //     Uri.parse("https://api.videosdk.live/v2/rooms"),
  //     headers: {'Authorization': token},
  //   );
  //   //Destructuring the roomId from the response
  //   return json.decode(httpResponse.body)['roomId'];
  // }

  // Future<OrderListModel> getOrderList({required String url}) async {
  //   try {
  //     var request = http.MultipartRequest('POST', Uri.parse(url));
  //     request.headers.addAll(await authHeader());
  //     http.StreamedResponse response = await request.send();
  //     dynamic responseData = await response.stream.bytesToString();
  //     print("###########ORDER###############");
  //     print(jsonDecode(responseData));
  //     if (response.statusCode == httpsCode_200 ||
  //         response.statusCode == httpsCode_201) {
  //       _orderListModel = orderListModelFromJson(responseData);
  //       print("############ORDER##############");
  //       _orderListModel.requestStatus = RequestStatus.loaded;
  //     } else if (response.statusCode == httpsCode_404 ||
  //         response.statusCode == httpsCode_401) {
  //       // BasePrefs.clearPrefs().then((value) => Get.offAll(const LoadingPage()));
  //       _orderListModel.requestStatus = RequestStatus.unauthorized;
  //     } else if (response.statusCode == httpsCode_500) {
  //       _orderListModel.requestStatus = RequestStatus.server;
  //     }
  //   } on Error catch (e) {
  //     _firebaseService.firebaseDioError(
  //       apiCall: "getOrderList",
  //       code: "401|404",
  //       userId: userId,
  //       message: e.toString(),
  //     );
  //   } on SocketException catch (e) {
  //     _firebaseService.firebaseSocketException(
  //       apiCall: "getOrderList",
  //       userId: userId,
  //       message: e.message,
  //     );
  //     throw Failure(e.message);
  //   } on FormatException catch (e) {
  //     _firebaseService.firebaseFormatException(
  //       apiCall: "getOrderList",
  //       userId: userId,
  //       message: e.message,
  //     );
  //     throw Failure(e.message);
  //   } on HttpException catch (e) {
  //     _firebaseService.firebaseHttpException(
  //       apiCall: "getOrderList",
  //       userId: userId,
  //       message: e.message,
  //     );
  //     throw Failure(e.message);
  //   }
  //   return _orderListModel;
  // }

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

  // Future<PodCastVideoModel> getTrandingVideo({required String pageUrl}) async {
  //   try {
  //     // String url = GetBaseUrl + GetDomainUrl + TREDINF_VIDEO_GET;

  //     var request = http.MultipartRequest('POST', Uri.parse(pageUrl));

  //     request.headers.addAll(await authHeader());

  //     http.StreamedResponse response = await request.send();
  //     dynamic responseData = await response.stream.bytesToString();
  //     print("#############getTrandingVideo#############");
  //     print(jsonDecode(responseData));
  //     if (response.statusCode == httpsCode_200 ||
  //         response.statusCode == httpsCode_201) {
  //       _trandingVideoModel = podCastVideoModelFromJson(responseData);
  //       print(_trandingVideoModel.videos!.data!.length);
  //       print("##########################");
  //       _trandingVideoModel.requestStatus = RequestStatus.loaded;
  //     } else if (response.statusCode == httpsCode_404 ||
  //         response.statusCode == httpsCode_401) {
  //       // BasePrefs.clearPrefs().then((value) => Get.offAll(const LoadingPage()));
  //       _trandingVideoModel.requestStatus = RequestStatus.unauthorized;
  //     } else if (response.statusCode == httpsCode_500) {
  //       _trandingVideoModel.requestStatus = RequestStatus.server;
  //     }
  //   } on Error catch (e) {
  //     _firebaseService.firebaseDioError(
  //       apiCall: "getTrandingVideo",
  //       code: "401|404",
  //       userId: userId,
  //       message: e.toString(),
  //     );
  //   } on SocketException catch (e) {
  //     _firebaseService.firebaseSocketException(
  //       apiCall: "getTrandingVideo",
  //       userId: userId,
  //       message: e.message,
  //     );
  //     throw Failure(e.message);
  //   } on FormatException catch (e) {
  //     _firebaseService.firebaseFormatException(
  //       apiCall: "getTrandingVideo",
  //       userId: userId,
  //       message: e.message,
  //     );
  //     throw Failure(e.message);
  //   } on HttpException catch (e) {
  //     _firebaseService.firebaseHttpException(
  //       apiCall: "getTrandingVideo",
  //       userId: userId,
  //       message: e.message,
  //     );
  //     throw Failure(e.message);
  //   }
  //   return _trandingVideoModel;
  // }

  // Future<PodCastVideoModel> getPodCastVideo({required String pageUrl}) async {
  //   try {
  //     // String url = GetBaseUrl + GetDomainUrl + PODCAST_VIDEO_GET;

  //     var request = http.MultipartRequest('POST', Uri.parse(pageUrl));

  //     request.headers.addAll(await authHeader());

  //     http.StreamedResponse response = await request.send();
  //     dynamic responseData = await response.stream.bytesToString();
  //     print("#############getPodCastVideo#############");
  //     print(jsonDecode(responseData));
  //     if (response.statusCode == httpsCode_200 ||
  //         response.statusCode == httpsCode_201) {
  //       _podCastVideoModel = podCastVideoModelFromJson(responseData);
  //       print("##########################");
  //       _podCastVideoModel.requestStatus = RequestStatus.loaded;
  //     } else if (response.statusCode == httpsCode_404 ||
  //         response.statusCode == httpsCode_401) {
  //       // BasePrefs.clearPrefs().then((value) => Get.offAll(const LoadingPage()));
  //       _podCastVideoModel.requestStatus = RequestStatus.unauthorized;
  //     } else if (response.statusCode == httpsCode_500) {
  //       _podCastVideoModel.requestStatus = RequestStatus.server;
  //     }
  //   } on Error catch (e) {
  //     _firebaseService.firebaseDioError(
  //       apiCall: "getPodCastVideo",
  //       code: "401|404",
  //       userId: userId,
  //       message: e.toString(),
  //     );
  //   } on SocketException catch (e) {
  //     _firebaseService.firebaseSocketException(
  //       apiCall: "getPodCastVideo",
  //       userId: userId,
  //       message: e.message,
  //     );
  //     throw Failure(e.message);
  //   } on FormatException catch (e) {
  //     _firebaseService.firebaseFormatException(
  //       apiCall: "getPodCastVideo",
  //       userId: userId,
  //       message: e.message,
  //     );
  //     throw Failure(e.message);
  //   } on HttpException catch (e) {
  //     _firebaseService.firebaseHttpException(
  //       apiCall: "getPodCastVideo",
  //       userId: userId,
  //       message: e.message,
  //     );
  //     throw Failure(e.message);
  //   }
  //   return _podCastVideoModel;
  // }

  // Future<PodCastVideoModel> getYoutubeVideo({required String pageUrl}) async {
  //   try {
  //     // String url = GetBaseUrl + GetDomainUrl + YOUTUBE_VIDEO_GET;

  //     var request = http.MultipartRequest('POST', Uri.parse(pageUrl));

  //     request.headers.addAll(await authHeader());

  //     http.StreamedResponse response = await request.send();
  //     dynamic responseData = await response.stream.bytesToString();
  //     print("#############getYoutubeVideo#############");
  //     print(jsonDecode(responseData));
  //     if (response.statusCode == httpsCode_200 ||
  //         response.statusCode == httpsCode_201) {
  //       _youtubeVideoModel = podCastVideoModelFromJson(responseData);
  //       print("##########################");
  //       _youtubeVideoModel.requestStatus = RequestStatus.loaded;
  //     } else if (response.statusCode == httpsCode_404 ||
  //         response.statusCode == httpsCode_401) {
  //       // BasePrefs.clearPrefs().then((value) => Get.offAll(const LoadingPage()));
  //       _youtubeVideoModel.requestStatus = RequestStatus.unauthorized;
  //     } else if (response.statusCode == httpsCode_500) {
  //       _youtubeVideoModel.requestStatus = RequestStatus.server;
  //     }
  //   } on Error catch (e) {
  //     _firebaseService.firebaseDioError(
  //       apiCall: "getYoutubeVideo",
  //       code: "401|404",
  //       userId: userId,
  //       message: e.toString(),
  //     );
  //   } on SocketException catch (e) {
  //     _firebaseService.firebaseSocketException(
  //       apiCall: "getYoutubeVideo",
  //       userId: userId,
  //       message: e.message,
  //     );
  //     throw Failure(e.message);
  //   } on FormatException catch (e) {
  //     _firebaseService.firebaseFormatException(
  //       apiCall: "getYoutubeVideo",
  //       userId: userId,
  //       message: e.message,
  //     );
  //     throw Failure(e.message);
  //   } on HttpException catch (e) {
  //     _firebaseService.firebaseHttpException(
  //       apiCall: "getYoutubeVideo",
  //       userId: userId,
  //       message: e.message,
  //     );
  //     throw Failure(e.message);
  //   }
  //   return _youtubeVideoModel;
  // }

  // Future<CouponListModel> getCouponList({required String pageUrl}) async {
  //   try {
  //     // String url = GetBaseUrl + GetDomainUrl + PODCAST_VIDEO_GET;
  //     var request = http.MultipartRequest('POST', Uri.parse(pageUrl));
  //     request.headers.addAll(await authHeader());
  //     http.StreamedResponse response = await request.send();
  //     dynamic responseData = await response.stream.bytesToString();
  //     print("#############getCouponList#############");
  //     print(jsonDecode(responseData));
  //     if (response.statusCode == httpsCode_200 ||
  //         response.statusCode == httpsCode_201) {
  //       _couponListModel = couponListModelFromJson(responseData);
  //       print("##########################");
  //       _couponListModel.requestStatus = RequestStatus.loaded;
  //     } else if (response.statusCode == httpsCode_404 ||
  //         response.statusCode == httpsCode_401) {
  //       // BasePrefs.clearPrefs().then((value) => Get.offAll(const LoadingPage()));
  //       _couponListModel.requestStatus = RequestStatus.unauthorized;
  //     } else if (response.statusCode == httpsCode_500) {
  //       _couponListModel.requestStatus = RequestStatus.server;
  //     }
  //   } on Error catch (e) {
  //     _firebaseService.firebaseDioError(
  //       apiCall: "getCouponList",
  //       code: "401|404",
  //       userId: userId,
  //       message: e.toString(),
  //     );
  //   } on SocketException catch (e) {
  //     _firebaseService.firebaseSocketException(
  //       apiCall: "getCouponList",
  //       userId: userId,
  //       message: e.message,
  //     );
  //     throw Failure(e.message);
  //   } on FormatException catch (e) {
  //     _firebaseService.firebaseFormatException(
  //       apiCall: "getCouponList",
  //       userId: userId,
  //       message: e.message,
  //     );
  //     throw Failure(e.message);
  //   } on HttpException catch (e) {
  //     _firebaseService.firebaseHttpException(
  //       apiCall: "getCouponList",
  //       userId: userId,
  //       message: e.message,
  //     );
  //     throw Failure(e.message);
  //   }
  //   return _couponListModel;
  // }

  // Future<ServiceOrderModel> applyeCoupon({
  //   required int orderId,
  //   required String couponCode,
  // }) async {
  //   try {
  //     String url = GetBaseUrl + GetDomainUrl + COUPON_APPLY;
  //     var request = http.MultipartRequest('POST', Uri.parse(url));
  //     request.headers.addAll(await authHeader());
  //     request.fields.addAll({
  //       'order_id': '$orderId',
  //       'coupon_code': couponCode,
  //     });
  //     http.StreamedResponse response = await request.send();
  //     dynamic responseData = await response.stream.bytesToString();
  //     print("@@@@@@@@@@@applyeCouponOUTPUT@@@@@@@@@@@");
  //     print(responseData);
  //     print("@@@@@@@@@@@applyeCouponOUTPUT@@@@@@@@@@@");
  //     if (response.statusCode == httpsCode_200 ||
  //         response.statusCode == httpsCode_201) {
  //       ApiResponse _apiResponse = ApiResponse.fromJson(
  //         jsonDecode(responseData),
  //       );
  //       if (_apiResponse.status!) {
  //         _applyCoupon = ServiceOrderModel.fromJson(jsonDecode(responseData));
  //         print("@@@@@@@@@@@@@@@@@@@@@@");
  //         _applyCoupon.requestStatus = RequestStatus.loaded;
  //       } else {
  //         _applyCoupon = ServiceOrderModel(
  //           status: false,
  //           message: _apiResponse.message,
  //         );
  //       }
  //     } else if (response.statusCode == httpsCode_404 ||
  //         response.statusCode == httpsCode_401) {
  //       // BasePrefs.clearPrefs().then((value) => Get.offAll(const LoadingPage()));
  //       _applyCoupon.requestStatus = RequestStatus.unauthorized;
  //     } else if (response.statusCode == httpsCode_500) {
  //       _applyCoupon.requestStatus = RequestStatus.server;
  //     }
  //   } on Error catch (e) {
  //     _firebaseService.firebaseDioError(
  //       apiCall: "applyeCoupon",
  //       code: "401|404",
  //       userId: userId,
  //       message: e.toString(),
  //     );
  //   } on SocketException catch (e) {
  //     _firebaseService.firebaseSocketException(
  //       apiCall: "applyeCoupon",
  //       userId: userId,
  //       message: e.message,
  //     );
  //     throw Failure(e.message);
  //   } on FormatException catch (e) {
  //     _firebaseService.firebaseFormatException(
  //       apiCall: "applyeCoupon",
  //       userId: userId,
  //       message: e.message,
  //     );
  //     throw Failure(e.message);
  //   } on HttpException catch (e) {
  //     _firebaseService.firebaseHttpException(
  //       apiCall: "applyeCoupon",
  //       userId: userId,
  //       message: e.message,
  //     );
  //     throw Failure(e.message);
  //   }
  //   return _applyCoupon;
  // }

  // Future<ServiceOrderModel> removeCoupon({
  //   required int orderId,
  //   required String couponCode,
  // }) async {
  //   try {
  //     String url = GetBaseUrl + GetDomainUrl + COUPON_REMOVE;
  //     var request = http.MultipartRequest('POST', Uri.parse(url));
  //     request.headers.addAll(await authHeader());
  //     request.fields.addAll({
  //       'order_id': '$orderId',
  //       'coupon_code': couponCode,
  //     });
  //     http.StreamedResponse response = await request.send();
  //     dynamic responseData = await response.stream.bytesToString();
  //     print("@@@@@@@@@@@removeCoupon@@@@@@@@@@@");
  //     print(responseData);
  //     print("@@@@@@@@@@@removeCoupon@@@@@@@@@@@");
  //     if (response.statusCode == httpsCode_200 ||
  //         response.statusCode == httpsCode_201) {
  //       ApiResponse _apiResponse = ApiResponse.fromJson(
  //         jsonDecode(responseData),
  //       );
  //       if (_apiResponse.status!) {
  //         _removeCoupon = ServiceOrderModel.fromJson(jsonDecode(responseData));
  //         print("@@@@@@@@@@@@@@@@@@@@@@");
  //         _removeCoupon.requestStatus = RequestStatus.loaded;
  //       } else {
  //         _removeCoupon = ServiceOrderModel(
  //           status: false,
  //           message: _apiResponse.message,
  //         );
  //       }
  //     } else if (response.statusCode == httpsCode_404 ||
  //         response.statusCode == httpsCode_401) {
  //       // BasePrefs.clearPrefs().then((value) => Get.offAll(const LoadingPage()));
  //       _removeCoupon.requestStatus = RequestStatus.unauthorized;
  //     } else if (response.statusCode == httpsCode_500) {
  //       _removeCoupon.requestStatus = RequestStatus.server;
  //     }
  //   } on Error catch (e) {
  //     _firebaseService.firebaseDioError(
  //       apiCall: "removeCoupon",
  //       code: "401|404",
  //       userId: userId,
  //       message: e.toString(),
  //     );
  //   } on SocketException catch (e) {
  //     _firebaseService.firebaseSocketException(
  //       apiCall: "removeCoupon",
  //       userId: userId,
  //       message: e.message,
  //     );
  //     throw Failure(e.message);
  //   } on FormatException catch (e) {
  //     _firebaseService.firebaseFormatException(
  //       apiCall: "removeCoupon",
  //       userId: userId,
  //       message: e.message,
  //     );
  //     throw Failure(e.message);
  //   } on HttpException catch (e) {
  //     _firebaseService.firebaseHttpException(
  //       apiCall: "removeCoupon",
  //       userId: userId,
  //       message: e.message,
  //     );
  //     throw Failure(e.message);
  //   }
  //   return _removeCoupon;
  // }

  // Future<ProductCartModel> productAddToCart({
  //   required int productId,
  //   required int quantity,
  // }) async {
  //   try {
  //     String url = GetBaseUrl + GetDomainUrl + PRODUCT_ADDTO_CART;
  //     var request = http.MultipartRequest('POST', Uri.parse(url));
  //     request.headers.addAll(await authHeader());

  //     request.fields.addAll({
  //       'product_id': '$productId',
  //       'quantity': '$quantity',
  //     });

  //     http.StreamedResponse response = await request.send();
  //     dynamic responseData = await response.stream.bytesToString();

  //     print("@@@@@@@@@@@productAddToCart@@@@@@@@@@@");
  //     print(responseData);
  //     print("@@@@@@@@@@@productAddToCart@@@@@@@@@@@");

  //     if (response.statusCode == httpsCode_200 ||
  //         response.statusCode == httpsCode_201) {
  //       _productCartModel = productCartModelFromJson(responseData);
  //     } else if (response.statusCode == httpsCode_404 ||
  //         response.statusCode == httpsCode_401) {
  //       // BasePrefs.clearPrefs().then((value) => Get.offAll(const LoadingPage()));
  //       _productCartModel.requestStatus = RequestStatus.unauthorized;
  //     } else if (response.statusCode == httpsCode_500) {
  //       _productCartModel.requestStatus = RequestStatus.server;
  //     }
  //   } on Error catch (e) {
  //     _firebaseService.firebaseDioError(
  //       apiCall: "addToCart",
  //       code: "401|404",
  //       userId: userId,
  //       message: e.toString(),
  //     );
  //   } on SocketException catch (e) {
  //     _firebaseService.firebaseSocketException(
  //       apiCall: "addToCart",
  //       userId: userId,
  //       message: e.message,
  //     );
  //     throw Failure(e.message);
  //   } on FormatException catch (e) {
  //     _firebaseService.firebaseFormatException(
  //       apiCall: "addToCart",
  //       userId: userId,
  //       message: e.message,
  //     );
  //     throw Failure(e.message);
  //   } on HttpException catch (e) {
  //     _firebaseService.firebaseHttpException(
  //       apiCall: "addToCart",
  //       userId: userId,
  //       message: e.message,
  //     );
  //     throw Failure(e.message);
  //   }
  //   return _productCartModel;
  // }

  // Future<ProductCartModel> getProductCart() async {
  //   try {
  //     String url = GetBaseUrl + GetDomainUrl + PRODUCT_GET_CART;
  //     var request = http.MultipartRequest('POST', Uri.parse(url));
  //     request.headers.addAll(await authHeader());

  //     http.StreamedResponse response = await request.send();

  //     dynamic responseData = await response.stream.bytesToString();

  //     print("@@@@@@@@@@@getProductCart@@@@@@@@@@@");
  //     print(responseData);
  //     print("@@@@@@@@@@@getProductCart@@@@@@@@@@@");

  //     if (response.statusCode == httpsCode_200 ||
  //         response.statusCode == httpsCode_201) {
  //       _getProductCartModel = productCartModelFromJson(responseData);
  //     } else if (response.statusCode == httpsCode_404 ||
  //         response.statusCode == httpsCode_401) {
  //       // BasePrefs.clearPrefs().then((value) => Get.offAll(const LoadingPage()));
  //       _getProductCartModel.requestStatus = RequestStatus.unauthorized;
  //     } else if (response.statusCode == httpsCode_500) {
  //       _getProductCartModel.requestStatus = RequestStatus.server;
  //     }
  //   } on Error catch (e) {
  //     _firebaseService.firebaseDioError(
  //       apiCall: "getProductCart",
  //       code: "401|404",
  //       userId: userId,
  //       message: e.toString(),
  //     );
  //   } on SocketException catch (e) {
  //     _firebaseService.firebaseSocketException(
  //       apiCall: "getProductCart",
  //       userId: userId,
  //       message: e.message,
  //     );
  //     throw Failure(e.message);
  //   } on FormatException catch (e) {
  //     _firebaseService.firebaseFormatException(
  //       apiCall: "getProductCart",
  //       userId: userId,
  //       message: e.message,
  //     );
  //     throw Failure(e.message);
  //   } on HttpException catch (e) {
  //     _firebaseService.firebaseHttpException(
  //       apiCall: "getProductCart",
  //       userId: userId,
  //       message: e.message,
  //     );
  //     throw Failure(e.message);
  //   }
  //   return _getProductCartModel;
  // }

  // Future<ProductCartModel> removeProductFromCart({required int itemId}) async {
  //   try {
  //     String url = GetBaseUrl + GetDomainUrl + PRODUCT_REMOVE_ITEM_FROM_CART;
  //     var request = http.MultipartRequest('POST', Uri.parse(url));
  //     request.headers.addAll(await authHeader());

  //     request.fields.addAll({'item_id': '$itemId'});

  //     http.StreamedResponse response = await request.send();

  //     dynamic responseData = await response.stream.bytesToString();

  //     print("@@@@@@@@@@@removeProductFromCart@@@@@@@@@@@");
  //     print(responseData);
  //     print("@@@@@@@@@@@removeProductFromCart@@@@@@@@@@@");

  //     if (response.statusCode == httpsCode_200 ||
  //         response.statusCode == httpsCode_201) {
  //       _removeProductCartModel = productCartModelFromJson(responseData);
  //     } else if (response.statusCode == httpsCode_404 ||
  //         response.statusCode == httpsCode_401) {
  //       // BasePrefs.clearPrefs().then((value) => Get.offAll(const LoadingPage()));
  //       _removeProductCartModel.requestStatus = RequestStatus.unauthorized;
  //     } else if (response.statusCode == httpsCode_500) {
  //       _removeProductCartModel.requestStatus = RequestStatus.server;
  //     }
  //   } on Error catch (e) {
  //     _firebaseService.firebaseDioError(
  //       apiCall: "getProductCart",
  //       code: "401|404",
  //       userId: userId,
  //       message: e.toString(),
  //     );
  //   } on SocketException catch (e) {
  //     _firebaseService.firebaseSocketException(
  //       apiCall: "removeProductFromCart",
  //       userId: userId,
  //       message: e.message,
  //     );
  //     throw Failure(e.message);
  //   } on FormatException catch (e) {
  //     _firebaseService.firebaseFormatException(
  //       apiCall: "removeProductFromCart",
  //       userId: userId,
  //       message: e.message,
  //     );
  //     throw Failure(e.message);
  //   } on HttpException catch (e) {
  //     _firebaseService.firebaseHttpException(
  //       apiCall: "removeProductFromCart",
  //       userId: userId,
  //       message: e.message,
  //     );
  //     throw Failure(e.message);
  //   }
  //   return _removeProductCartModel;
  // }

  // Future<ProductCartModel> storeApplyeCoupon({
  //   required int orderId,
  //   required String couponCode,
  // }) async {
  //   try {
  //     String url = GetBaseUrl + GetDomainUrl + STORE_COUPON_APPLY;
  //     var request = http.MultipartRequest('POST', Uri.parse(url));
  //     request.headers.addAll(await authHeader());
  //     request.fields.addAll({'cart_id': '$orderId', 'coupon_code': couponCode});
  //     http.StreamedResponse response = await request.send();
  //     dynamic responseData = await response.stream.bytesToString();
  //     print("@@@@@@@@@@@storeApplyeCoupon@@@@@@@@@@@");
  //     print(responseData);
  //     print("@@@@@@@@@@@storeApplyeCoupon@@@@@@@@@@@");
  //     if (response.statusCode == httpsCode_200 ||
  //         response.statusCode == httpsCode_201) {
  //       _applyStoreCoupon = productCartModelFromJson(responseData);
  //     } else if (response.statusCode == httpsCode_404 ||
  //         response.statusCode == httpsCode_401) {
  //       // BasePrefs.clearPrefs().then((value) => Get.offAll(const LoadingPage()));
  //       _applyStoreCoupon.requestStatus = RequestStatus.unauthorized;
  //     } else if (response.statusCode == httpsCode_500) {
  //       _applyStoreCoupon.requestStatus = RequestStatus.server;
  //     }
  //   } on Error catch (e) {
  //     _firebaseService.firebaseDioError(
  //       apiCall: "storeApplyeCoupon",
  //       code: "401|404",
  //       userId: userId,
  //       message: e.toString(),
  //     );
  //   } on SocketException catch (e) {
  //     _firebaseService.firebaseSocketException(
  //       apiCall: "storeApplyeCoupon",
  //       userId: userId,
  //       message: e.message,
  //     );
  //     throw Failure(e.message);
  //   } on FormatException catch (e) {
  //     _firebaseService.firebaseFormatException(
  //       apiCall: "storeApplyeCoupon",
  //       userId: userId,
  //       message: e.message,
  //     );
  //     throw Failure(e.message);
  //   } on HttpException catch (e) {
  //     _firebaseService.firebaseHttpException(
  //       apiCall: "storeApplyeCoupon",
  //       userId: userId,
  //       message: e.message,
  //     );
  //     throw Failure(e.message);
  //   }
  //   return _applyStoreCoupon;
  // }

  // Future<ProductCartModel> storeRemoveCoupon({
  //   required int orderId,
  //   required String couponCode,
  // }) async {
  //   try {
  //     String url = GetBaseUrl + GetDomainUrl + STORE_COUPON_REMOVE;
  //     var request = http.MultipartRequest('POST', Uri.parse(url));
  //     request.headers.addAll(await authHeader());
  //     request.fields.addAll({'cart_id': '$orderId', 'coupon_code': couponCode});
  //     http.StreamedResponse response = await request.send();
  //     dynamic responseData = await response.stream.bytesToString();

  //     print("@@@@@@@@@@@storeRemoveCoupon@@@@@@@@@@@");
  //     print(responseData);
  //     print("@@@@@@@@@@@storeRemoveCoupon@@@@@@@@@@@");

  //     if (response.statusCode == httpsCode_200 ||
  //         response.statusCode == httpsCode_201) {
  //       _removeStoreCoupon = productCartModelFromJson(responseData);
  //     } else if (response.statusCode == httpsCode_404 ||
  //         response.statusCode == httpsCode_401) {
  //       // BasePrefs.clearPrefs().then((value) => Get.offAll(const LoadingPage()));
  //       _removeStoreCoupon.requestStatus = RequestStatus.unauthorized;
  //     } else if (response.statusCode == httpsCode_500) {
  //       _removeStoreCoupon.requestStatus = RequestStatus.server;
  //     }
  //   } on Error catch (e) {
  //     _firebaseService.firebaseDioError(
  //       apiCall: "storeRemoveCoupon",
  //       code: "401|404",
  //       userId: userId,
  //       message: e.toString(),
  //     );
  //   } on SocketException catch (e) {
  //     _firebaseService.firebaseSocketException(
  //       apiCall: "storeRemoveCoupon",
  //       userId: userId,
  //       message: e.message,
  //     );
  //     throw Failure(e.message);
  //   } on FormatException catch (e) {
  //     _firebaseService.firebaseFormatException(
  //       apiCall: "storeRemoveCoupon",
  //       userId: userId,
  //       message: e.message,
  //     );
  //     throw Failure(e.message);
  //   } on HttpException catch (e) {
  //     _firebaseService.firebaseHttpException(
  //       apiCall: "storeRemoveCoupon",
  //       userId: userId,
  //       message: e.message,
  //     );
  //     throw Failure(e.message);
  //   }
  //   return _removeStoreCoupon;
  // }

  // Future<ProductOrderModel> productOrderPlacedApi({
  //   required int cartId,
  //   required String addressId,
  // }) async {
  //   try {
  //     String url = GetBaseUrl + GetDomainUrl + PRODUCTORDERPLACED;
  //     // dynamic body = json.encode(
  //     //     {'service_id': serviceId, 'expert_id': expertId, 'date': date});
  //     // var response = await http.post(Uri.parse(pageUrl),
  //     //     headers: await authHeader(), body: body);

  //     var request = http.MultipartRequest('POST', Uri.parse(url));

  //     print("@@@@@@@@@@@productOrderPlacedApi ! check @@@@@@@@@@@");
  //     print({'cart_id': '$cartId', 'address_id': addressId});
  //     request.fields.addAll({'cart_id': '$cartId', 'address_id': addressId});

  //     request.headers.addAll(await authHeader());

  //     http.StreamedResponse response = await request.send();

  //     dynamic responseData = await response.stream.bytesToString();
  //     print("@@@@@@@@@@@productOrderPlacedApi ! check @@@@@@@@@@@");
  //     print(responseData);
  //     if (response.statusCode == httpsCode_200 ||
  //         response.statusCode == httpsCode_201) {
  //       _productOrderModel = ProductOrderModel.fromJson(
  //         jsonDecode(responseData),
  //       );
  //       print("@@@@@@@@@@@@@@@@@@@@@@");
  //       _productOrderModel.requestStatus = RequestStatus.loaded;
  //     } else if (response.statusCode == httpsCode_404 ||
  //         response.statusCode == httpsCode_401) {
  //       // BasePrefs.clearPrefs().then((value) => Get.offAll(const LoadingPage()));
  //       _productOrderModel.requestStatus = RequestStatus.unauthorized;
  //     } else if (response.statusCode == httpsCode_500) {
  //       _productOrderModel.requestStatus = RequestStatus.server;
  //     }
  //   } on Error catch (e) {
  //     _firebaseService.firebaseDioError(
  //       apiCall: "productOrderPlacedApi",
  //       code: "401|404",
  //       userId: userId,
  //       message: e.toString(),
  //     );
  //   } on SocketException catch (e) {
  //     _firebaseService.firebaseSocketException(
  //       apiCall: "productOrderPlacedApi",
  //       userId: userId,
  //       message: e.message,
  //     );
  //     throw Failure(e.message);
  //   } on FormatException catch (e) {
  //     _firebaseService.firebaseFormatException(
  //       apiCall: "productOrderPlacedApi",
  //       userId: userId,
  //       message: e.message,
  //     );
  //     throw Failure(e.message);
  //   } on HttpException catch (e) {
  //     _firebaseService.firebaseHttpException(
  //       apiCall: "productOrderPlacedApi",
  //       userId: userId,
  //       message: e.message,
  //     );
  //     throw Failure(e.message);
  //   }
  //   return _productOrderModel;
  // }

  Future<ApiResponse> productOrderConformationPlacedApi({
    required int orderId,
    required String transactionId,
    required String status,
    required String paymentMode,
    File? screenshot,
    required String paymentType,
    required String orderAddress,
  }) async {
    try {
      String url = GetBaseUrl + GetDomainUrl + PRODUCTORDERCONFORM;

      // dynamic body = json.encode(
      //     {'service_id': serviceId, 'expert_id': expertId, 'date': date});
      // var response = await http.post(Uri.parse(pageUrl),
      //     headers: await authHeader(), body: body);

      var request = http.MultipartRequest('POST', Uri.parse(url));

      request.fields.addAll({
        'order_id': '$orderId',
        'status': status,
        'transaction_id': transactionId,
        'payment_mode': paymentMode,
        'payment_type': paymentType,
        'order_address': orderAddress,
      });
      if (screenshot != null) {
        request.files.add(
          await http.MultipartFile.fromPath('screenshot', screenshot.path),
        );
      }
      request.headers.addAll(await authHeader());
      print("@@@@@@@@@@@productOrderConformationPlacedApi@@@@@@@@@@@");
      print(url);
      print(await authHeader());
      print({
        'order_id': '$orderId',
        'status': status,
        'transaction_id': transactionId,
        'payment_mode': paymentMode,
        'order_address': orderAddress,
      });
      http.StreamedResponse response = await request.send();

      dynamic responseData = await response.stream.bytesToString();
      print(responseData);
      if (response.statusCode == httpsCode_200 ||
          response.statusCode == httpsCode_201) {
        _apiResponseOrderPaymentConform = ApiResponse.fromJson(
          jsonDecode(responseData),
        );
        print("@@@@@@@@@@@@@@@@@@@@@@");
        _apiResponseOrderPaymentConform.requestStatus = RequestStatus.loaded;
      } else if (response.statusCode == httpsCode_404 ||
          response.statusCode == httpsCode_401) {
        // BasePrefs.clearPrefs().then((value) => Get.offAll(const LoadingPage()));
        _apiResponseOrderPaymentConform.requestStatus =
            RequestStatus.unauthorized;
      } else if (response.statusCode == httpsCode_500) {
        _apiResponseOrderPaymentConform.requestStatus = RequestStatus.server;
      }
    } on Error catch (e) {
      _firebaseService.firebaseDioError(
        apiCall: "_apiResponseOrderPaymentConform",
        code: "401|404",
        userId: userId,
        message: e.toString(),
      );
    } on SocketException catch (e) {
      _firebaseService.firebaseSocketException(
        apiCall: "_apiResponseOrderPaymentConform",
        userId: userId,
        message: e.message,
      );
      throw Failure(e.message);
    } on FormatException catch (e) {
      _firebaseService.firebaseFormatException(
        apiCall: "_apiResponseOrderPaymentConform",
        userId: userId,
        message: e.message,
      );
      throw Failure(e.message);
    } on HttpException catch (e) {
      _firebaseService.firebaseHttpException(
        apiCall: "_apiResponseOrderPaymentConform",
        userId: userId,
        message: e.message,
      );
      throw Failure(e.message);
    }
    return _apiResponseOrderPaymentConform;
  }

  // Future<ProductCategoryModel> getProductsCategory({
  //   required String url,
  // }) async {
  //   try {
  //     // String url = GetBaseUrl + GetDomainUrl + PRODUCT_CATEGORY;
  //     var request = http.MultipartRequest('POST', Uri.parse(url));
  //     request.headers.addAll(await authHeader());

  //     http.StreamedResponse response = await request.send();

  //     dynamic responseData = await response.stream.bytesToString();

  //     print("@@@@@@@@@@@ getProductsCategory @@@@@@@@@@@");
  //     print(responseData);

  //     if (response.statusCode == httpsCode_200 ||
  //         response.statusCode == httpsCode_201) {
  //       _productCategoryModel = productCategoryModelFromJson(responseData);
  //       print("@@@@@@@@@@@ getProductsCategory @@@@@@@@@@@");
  //     } else if (response.statusCode == httpsCode_404 ||
  //         response.statusCode == httpsCode_401) {
  //       // BasePrefs.clearPrefs().then((value) => Get.offAll(const LoadingPage()));
  //       _productCategoryModel.requestStatus = RequestStatus.unauthorized;
  //     } else if (response.statusCode == httpsCode_500) {
  //       _productCategoryModel.requestStatus = RequestStatus.server;
  //     }
  //   } on Error catch (e) {
  //     _firebaseService.firebaseDioError(
  //       apiCall: "getProductsCategory",
  //       code: "401|404",
  //       userId: userId,
  //       message: e.toString(),
  //     );
  //   } on SocketException catch (e) {
  //     _firebaseService.firebaseSocketException(
  //       apiCall: "getProductsCategory",
  //       userId: userId,
  //       message: e.message,
  //     );
  //     throw Failure(e.message);
  //   } on FormatException catch (e) {
  //     _firebaseService.firebaseFormatException(
  //       apiCall: "getProductsCategory",
  //       userId: userId,
  //       message: e.message,
  //     );
  //     throw Failure(e.message);
  //   } on HttpException catch (e) {
  //     _firebaseService.firebaseHttpException(
  //       apiCall: "getProductsCategory",
  //       userId: userId,
  //       message: e.message,
  //     );
  //     throw Failure(e.message);
  //   }
  //   return _productCategoryModel;
  // }

  // Future<SearchProductListModel> getSearchProductsCategory({
  //   required String quary,
  // }) async {
  //   try {
  //     String url = GetBaseUrl + GetDomainUrl + PRODUCT_SEARCH;
  //     var request = http.MultipartRequest('POST', Uri.parse(url));
  //     request.headers.addAll(await authHeader());
  //     request.fields.addAll({'name': quary});

  //     http.StreamedResponse response = await request.send();

  //     dynamic responseData = await response.stream.bytesToString();

  //     print("@@@@@@@@@@@ getSearchProductsCategory @@@@@@@@@@@");
  //     print(responseData);
  //     print("@@@@@@@@@@@ getSearchProductsCategory @@@@@@@@@@@");

  //     if (response.statusCode == httpsCode_200 ||
  //         response.statusCode == httpsCode_201) {
  //       _searchProductListModel = searchProductListModelFromJson(responseData);
  //     } else if (response.statusCode == httpsCode_404 ||
  //         response.statusCode == httpsCode_401) {
  //       // BasePrefs.clearPrefs().then((value) => Get.offAll(const LoadingPage()));
  //       _searchProductListModel.requestStatus = RequestStatus.unauthorized;
  //     } else if (response.statusCode == httpsCode_500) {
  //       _searchProductListModel.requestStatus = RequestStatus.server;
  //     }
  //   } on Error catch (e) {
  //     _firebaseService.firebaseDioError(
  //       apiCall: "getSearchProductsCategory",
  //       code: "401|404",
  //       userId: userId,
  //       message: e.toString(),
  //     );
  //   } on SocketException catch (e) {
  //     _firebaseService.firebaseSocketException(
  //       apiCall: "getSearchProductsCategory",
  //       userId: userId,
  //       message: e.message,
  //     );
  //     throw Failure(e.message);
  //   } on FormatException catch (e) {
  //     _firebaseService.firebaseFormatException(
  //       apiCall: "getSearchProductsCategory",
  //       userId: userId,
  //       message: e.message,
  //     );
  //     throw Failure(e.message);
  //   } on HttpException catch (e) {
  //     _firebaseService.firebaseHttpException(
  //       apiCall: "getSearchProductsCategory",
  //       userId: userId,
  //       message: e.message,
  //     );
  //     throw Failure(e.message);
  //   }
  //   return _searchProductListModel;
  // }

  // Future<ApiResponse> submitAddress({
  //   required String state,
  //   required String city,
  //   required String zipcode,
  //   required String addressLine1,
  //   required String addressLine2,
  //   required String name,
  //   required String mobileNumber,
  // }) async {
  //   String url = GetBaseUrl + GetDomainUrl + ADDRESS_STORE;
  //   try {
  //     var request = http.MultipartRequest('POST', Uri.parse(url));

  //     request.fields.addAll({
  //       'state': state,
  //       'city': city,
  //       'zipcode': zipcode,
  //       'address_line_1': addressLine1,
  //       'address_line_2': addressLine2,
  //       'name': name,
  //       'mobile_number': mobileNumber,
  //     });

  //     // Add Authorization header
  //     request.headers.addAll(await authHeader());

  //     http.StreamedResponse response = await request.send();

  //     if (response.statusCode == 200 || response.statusCode == 201) {
  //       dynamic responseData = await response.stream.bytesToString();
  //       return ApiResponse.fromJson(jsonDecode(responseData));
  //     } else {
  //       throw HttpException('Failed with status: ${response.statusCode}');
  //     }
  //   } on SocketException catch (e) {
  //     throw Failure('No Internet connection: ${e.message}');
  //   } on FormatException catch (e) {
  //     throw Failure('Invalid response format: ${e.message}');
  //   } on HttpException catch (e) {
  //     throw Failure('HTTP error: ${e.message}');
  //   } catch (e) {
  //     throw Failure('Unexpected error: $e');
  //   }
  // }

  // Future<AddressListModel> getAddressList() async {
  //   try {
  //     String url = GetBaseUrl + GetDomainUrl + GET_ADDRESS_STORE;
  //     var request = http.MultipartRequest('POST', Uri.parse(url));
  //     request.headers.addAll(await authHeader());
  //     // request.fields.addAll({'name': quary});

  //     http.StreamedResponse response = await request.send();

  //     dynamic responseData = await response.stream.bytesToString();

  //     print("@@@@@@@@@@@ getAddressList @@@@@@@@@@@");
  //     print(responseData);
  //     print("@@@@@@@@@@@ getAddressList @@@@@@@@@@@");

  //     if (response.statusCode == httpsCode_200 ||
  //         response.statusCode == httpsCode_201) {
  //       _addressListModel = addressListModelFromJson(responseData);
  //     } else if (response.statusCode == httpsCode_404 ||
  //         response.statusCode == httpsCode_401) {
  //       // BasePrefs.clearPrefs().then((value) => Get.offAll(const LoadingPage()));
  //       _addressListModel.requestStatus = RequestStatus.unauthorized;
  //     } else if (response.statusCode == httpsCode_500) {
  //       _addressListModel.requestStatus = RequestStatus.server;
  //     }
  //   } on Error catch (e) {
  //     _firebaseService.firebaseDioError(
  //       apiCall: "getAddressList",
  //       code: "401|404",
  //       userId: userId,
  //       message: e.toString(),
  //     );
  //   } on SocketException catch (e) {
  //     _firebaseService.firebaseSocketException(
  //       apiCall: "getAddressList",
  //       userId: userId,
  //       message: e.message,
  //     );
  //     throw Failure(e.message);
  //   } on FormatException catch (e) {
  //     _firebaseService.firebaseFormatException(
  //       apiCall: "getAddressList",
  //       userId: userId,
  //       message: e.message,
  //     );
  //     throw Failure(e.message);
  //   } on HttpException catch (e) {
  //     _firebaseService.firebaseHttpException(
  //       apiCall: "getAddressList",
  //       userId: userId,
  //       message: e.message,
  //     );
  //     throw Failure(e.message);
  //   }
  //   return _addressListModel;
  // }

  Future<ApiResponse> editAddress({
    required String state,
    required String city,
    required String zipcode,
    required String addressLine1,
    required String addressLine2,
    required String name,
    required String mobileNumber,
    required String id,
  }) async {
    String url = GetBaseUrl + GetDomainUrl + ADDRESS_EDIT;
    try {
      var request = http.MultipartRequest('POST', Uri.parse(url));

      request.fields.addAll({
        'state': state,
        'city': city,
        'zipcode': zipcode,
        'address_line_1': addressLine1,
        'address_line_2': addressLine2,
        'name': name,
        'mobile_number': mobileNumber,
        '_id': id,
      });

      // Add Authorization header
      request.headers.addAll(await authHeader());

      http.StreamedResponse response = await request.send();

      if (response.statusCode == 200 || response.statusCode == 201) {
        dynamic responseData = await response.stream.bytesToString();
        return ApiResponse.fromJson(jsonDecode(responseData));
      } else {
        throw HttpException('Failed with status: ${response.statusCode}');
      }
    } on SocketException catch (e) {
      throw Failure('No Internet connection: ${e.message}');
    } on FormatException catch (e) {
      throw Failure('Invalid response format: ${e.message}');
    } on HttpException catch (e) {
      throw Failure('HTTP error: ${e.message}');
    } catch (e) {
      throw Failure('Unexpected error: $e');
    }
  }

  Future<ApiResponse> deleteAddress({required String id}) async {
    String url = GetBaseUrl + GetDomainUrl + ADDRESS_DELETE;
    try {
      var request = http.MultipartRequest('POST', Uri.parse(url));

      request.fields.addAll({'_id': id});

      // Add Authorization header
      request.headers.addAll(await authHeader());

      http.StreamedResponse response = await request.send();

      if (response.statusCode == 200 || response.statusCode == 201) {
        dynamic responseData = await response.stream.bytesToString();
        return ApiResponse.fromJson(jsonDecode(responseData));
      } else {
        throw HttpException('Failed with status: ${response.statusCode}');
      }
    } on SocketException catch (e) {
      throw Failure('No Internet connection: ${e.message}');
    } on FormatException catch (e) {
      throw Failure('Invalid response format: ${e.message}');
    } on HttpException catch (e) {
      throw Failure('HTTP error: ${e.message}');
    } catch (e) {
      throw Failure('Unexpected error: $e');
    }
  }

  // Future<ProductsOrderDetailsModel> getProductsOrderDetails({
  //   required int id,
  // }) async {
  //   try {
  //     String url = GetBaseUrl + GetDomainUrl + GET_PRODUCTS_ORDER_DETAILS;
  //     var request = http.MultipartRequest('POST', Uri.parse(url));
  //     request.headers.addAll(await authHeader());
  //     // request.fields.addAll({'name': quary});
  //     request.fields.addAll({'id': "$id"});
  //     http.StreamedResponse response = await request.send();

  //     dynamic responseData = await response.stream.bytesToString();

  //     print("@@@@@@@@@@@ getProductsOrderDetails @@@@@@@@@@@");
  //     print(responseData);
  //     print("@@@@@@@@@@@ getProductsOrderDetails @@@@@@@@@@@");

  //     if (response.statusCode == httpsCode_200 ||
  //         response.statusCode == httpsCode_201) {
  //       try {
  //         _productsOrderDetailsModel = productsOrderDetailsModelFromJson(
  //           responseData,
  //         );
  //       } catch (e) {
  //         print("##########productsOrderDetailsModelFromJson#############");
  //         print(e);
  //       }
  //     } else if (response.statusCode == httpsCode_404 ||
  //         response.statusCode == httpsCode_401) {
  //       // BasePrefs.clearPrefs().then((value) => Get.offAll(const LoadingPage()));
  //       _productsOrderDetailsModel.requestStatus = RequestStatus.unauthorized;
  //     } else if (response.statusCode == httpsCode_500) {
  //       _productsOrderDetailsModel.requestStatus = RequestStatus.server;
  //     }
  //   } on Error catch (e) {
  //     _firebaseService.firebaseDioError(
  //       apiCall: "getProductsOrderDetails",
  //       code: "401|404",
  //       userId: userId,
  //       message: e.toString(),
  //     );
  //   } on SocketException catch (e) {
  //     _firebaseService.firebaseSocketException(
  //       apiCall: "getProductsOrderDetails",
  //       userId: userId,
  //       message: e.message,
  //     );
  //     throw Failure(e.message);
  //   } on FormatException catch (e) {
  //     _firebaseService.firebaseFormatException(
  //       apiCall: "getProductsOrderDetails",
  //       userId: userId,
  //       message: e.message,
  //     );
  //     throw Failure(e.message);
  //   } on HttpException catch (e) {
  //     _firebaseService.firebaseHttpException(
  //       apiCall: "getProductsOrderDetails",
  //       userId: userId,
  //       message: e.message,
  //     );
  //     throw Failure(e.message);
  //   }
  //   return _productsOrderDetailsModel;
  // }

  // Future<ServicesOrderDetailsModel> getServicesOrderDetails({
  //   required int id,
  // }) async {
  //   try {
  //     String url = GetBaseUrl + GetDomainUrl + GET_SEVICES_ORDER_DETAILS;
  //     var request = http.MultipartRequest('POST', Uri.parse(url));
  //     request.headers.addAll(await authHeader());
  //     // request.fields.addAll({'name': quary});

  //     request.fields.addAll({'id': "$id"});

  //     http.StreamedResponse response = await request.send();

  //     dynamic responseData = await response.stream.bytesToString();

  //     print("@@@@@@@@@@@ getServicesOrderDetails @@@@@@@@@@@");
  //     print(responseData);
  //     print("@@@@@@@@@@@ getServicesOrderDetails @@@@@@@@@@@");

  //     if (response.statusCode == httpsCode_200 ||
  //         response.statusCode == httpsCode_201) {
  //       _servicesOrderDetailsModel = servicesOrderDetailsModelFromJson(
  //         responseData,
  //       );
  //     } else if (response.statusCode == httpsCode_404 ||
  //         response.statusCode == httpsCode_401) {
  //       // BasePrefs.clearPrefs().then((value) => Get.offAll(const LoadingPage()));
  //       _servicesOrderDetailsModel.requestStatus = RequestStatus.unauthorized;
  //     } else if (response.statusCode == httpsCode_500) {
  //       _servicesOrderDetailsModel.requestStatus = RequestStatus.server;
  //     }
  //   } on Error catch (e) {
  //     _firebaseService.firebaseDioError(
  //       apiCall: "getServicesOrderDetails",
  //       code: "401|404",
  //       userId: userId,
  //       message: e.toString(),
  //     );
  //   } on SocketException catch (e) {
  //     _firebaseService.firebaseSocketException(
  //       apiCall: "getServicesOrderDetails",
  //       userId: userId,
  //       message: e.message,
  //     );
  //     throw Failure(e.message);
  //   } on FormatException catch (e) {
  //     _firebaseService.firebaseFormatException(
  //       apiCall: "getServicesOrderDetails",
  //       userId: userId,
  //       message: e.message,
  //     );
  //     throw Failure(e.message);
  //   } on HttpException catch (e) {
  //     _firebaseService.firebaseHttpException(
  //       apiCall: "getServicesOrderDetails",
  //       userId: userId,
  //       message: e.message,
  //     );
  //     throw Failure(e.message);
  //   }
  //   return _servicesOrderDetailsModel;
  // }

  // Future<LiveChatListModel> getLiveChatListModelApi({
  //   required String pageUrl,
  // }) async {
  //   try {
  //     var request = http.MultipartRequest('GET', Uri.parse(pageUrl));

  //     request.headers.addAll(await authHeader());

  //     http.StreamedResponse response = await request.send();

  //     dynamic responseData = await response.stream.bytesToString();

  //     if (response.statusCode == httpsCode_200 ||
  //         response.statusCode == httpsCode_201) {
  //       _liveChatListModel = LiveChatListModel.fromJson(
  //         jsonDecode(responseData),
  //       );

  //       _expertsDataModel.requestStatus = RequestStatus.loaded;
  //     } else if (response.statusCode == httpsCode_404 ||
  //         response.statusCode == httpsCode_401) {
  //       // BasePrefs.clearPrefs().then((value) => Get.offAll(const LoadingPage()));
  //       _expertsDataModel.requestStatus = RequestStatus.unauthorized;
  //     } else if (response.statusCode == httpsCode_500) {
  //       _expertsDataModel.requestStatus = RequestStatus.server;
  //     }
  //   } on Error catch (e) {
  //     _firebaseService.firebaseDioError(
  //       apiCall: "getAllExpertsData",
  //       code: "401|404",
  //       userId: userId,
  //       message: e.toString(),
  //     );
  //   } on SocketException catch (e) {
  //     _firebaseService.firebaseSocketException(
  //       apiCall: "getAllExpertsData",
  //       userId: userId,
  //       message: e.message,
  //     );
  //     throw Failure(e.message);
  //   } on FormatException catch (e) {
  //     _firebaseService.firebaseFormatException(
  //       apiCall: "getAllExpertsData",
  //       userId: userId,
  //       message: e.message,
  //     );
  //     throw Failure(e.message);
  //   } on HttpException catch (e) {
  //     _firebaseService.firebaseHttpException(
  //       apiCall: "getAllExpertsData",
  //       userId: userId,
  //       message: e.message,
  //     );
  //     throw Failure(e.message);
  //   }
  //   return _liveChatListModel;
  // }

  // Future<FreeChatModel> getFreeChatModelApi({required String pageUrl}) async {
  //   try {
  //     var request = http.MultipartRequest('POST', Uri.parse(pageUrl));

  //     request.headers.addAll(await authHeader());

  //     http.StreamedResponse response = await request.send();

  //     dynamic responseData = await response.stream.bytesToString();

  //     if (response.statusCode == httpsCode_200 ||
  //         response.statusCode == httpsCode_201) {
  //       _freeChatModel = FreeChatModel.fromJson(jsonDecode(responseData));
  //       _expertsDataModel.requestStatus = RequestStatus.loaded;
  //     } else if (response.statusCode == httpsCode_404 ||
  //         response.statusCode == httpsCode_401) {
  //       // BasePrefs.clearPrefs().then((value) => Get.offAll(const LoadingPage()));
  //       _expertsDataModel.requestStatus = RequestStatus.unauthorized;
  //     } else if (response.statusCode == httpsCode_500) {
  //       _expertsDataModel.requestStatus = RequestStatus.server;
  //     }
  //   } on Error catch (e) {
  //     _firebaseService.firebaseDioError(
  //       apiCall: "_freeChatModel",
  //       code: "401|404",
  //       userId: userId,
  //       message: e.toString(),
  //     );
  //   } on SocketException catch (e) {
  //     _firebaseService.firebaseSocketException(
  //       apiCall: "_freeChatModel",
  //       userId: userId,
  //       message: e.message,
  //     );
  //     throw Failure(e.message);
  //   } on FormatException catch (e) {
  //     _firebaseService.firebaseFormatException(
  //       apiCall: "_freeChatModel",
  //       userId: userId,
  //       message: e.message,
  //     );
  //     throw Failure(e.message);
  //   } on HttpException catch (e) {
  //     _firebaseService.firebaseHttpException(
  //       apiCall: "_freeChatModel",
  //       userId: userId,
  //       message: e.message,
  //     );
  //     throw Failure(e.message);
  //   }
  //   return _freeChatModel;
  // }

  // Future<AstroWalletBalanceModel> getAstroWalletBalanceModelApi() async {
  //   try {
  //     String url = GetBaseUrl + GetDomainUrl + astroWalletBalance;
  //     var request = http.MultipartRequest('GET', Uri.parse(url));
  //     request.headers.addAll(await authHeader());
  //     // request.fields.addAll({'name': quary});

  //     http.StreamedResponse response = await request.send();

  //     dynamic responseData = await response.stream.bytesToString();

  //     print("@@@@@@@@@@@ AstroWalletBalanceModel @@@@@@@@@@@");
  //     print(responseData);
  //     print("@@@@@@@@@@@ AstroWalletBalanceModel @@@@@@@@@@@");

  //     if (response.statusCode == httpsCode_200 ||
  //         response.statusCode == httpsCode_201) {
  //       _astroWalletBalanceModel = astroWalletBalanceModelFromJson(
  //         responseData,
  //       );
  //     } else if (response.statusCode == httpsCode_404 ||
  //         response.statusCode == httpsCode_401) {
  //       // BasePrefs.clearPrefs().then((value) => Get.offAll(const LoadingPage()));
  //       _astroWalletBalanceModel.requestStatus = RequestStatus.unauthorized;
  //     } else if (response.statusCode == httpsCode_500) {
  //       _astroWalletBalanceModel.requestStatus = RequestStatus.server;
  //     }
  //   } on Error catch (e) {
  //     _firebaseService.firebaseDioError(
  //       apiCall: "AstroWalletBalanceModel",
  //       code: "401|404",
  //       userId: userId,
  //       message: e.toString(),
  //     );
  //   } on SocketException catch (e) {
  //     _firebaseService.firebaseSocketException(
  //       apiCall: "AstroWalletBalanceModel",
  //       userId: userId,
  //       message: e.message,
  //     );
  //     throw Failure(e.message);
  //   } on FormatException catch (e) {
  //     _firebaseService.firebaseFormatException(
  //       apiCall: "AstroWalletBalanceModel",
  //       userId: userId,
  //       message: e.message,
  //     );
  //     throw Failure(e.message);
  //   } on HttpException catch (e) {
  //     _firebaseService.firebaseHttpException(
  //       apiCall: "AstroWalletBalanceModel",
  //       userId: userId,
  //       message: e.message,
  //     );
  //     throw Failure(e.message);
  //   }
  //   return _astroWalletBalanceModel;
  // }

  // Future<WalletLedgerModel> getWalletLedgerModelApi() async {
  //   try {
  //     String url = GetBaseUrl + GetDomainUrl + walletLegderList;
  //     var request = http.MultipartRequest('GET', Uri.parse(url));
  //     request.headers.addAll(await authHeader());
  //     // request.fields.addAll({'name': quary});

  //     http.StreamedResponse response = await request.send();

  //     dynamic responseData = await response.stream.bytesToString();

  //     print("@@@@@@@@@@@ WalletLedgerModel @@@@@@@@@@@");
  //     print(responseData);
  //     print("@@@@@@@@@@@ WalletLedgerModel @@@@@@@@@@@");

  //     if (response.statusCode == httpsCode_200 ||
  //         response.statusCode == httpsCode_201) {
  //       _ledgerModel = walletLedgerModelFromJson(responseData);
  //     } else if (response.statusCode == httpsCode_404 ||
  //         response.statusCode == httpsCode_401) {
  //       // BasePrefs.clearPrefs().then((value) => Get.offAll(const LoadingPage()));
  //       _ledgerModel.requestStatus = RequestStatus.unauthorized;
  //     } else if (response.statusCode == httpsCode_500) {
  //       _ledgerModel.requestStatus = RequestStatus.server;
  //     }
  //   } on Error catch (e) {
  //     _firebaseService.firebaseDioError(
  //       apiCall: "WalletLedgerModel",
  //       code: "401|404",
  //       userId: userId,
  //       message: e.toString(),
  //     );
  //   } on SocketException catch (e) {
  //     _firebaseService.firebaseSocketException(
  //       apiCall: "WalletLedgerModel",
  //       userId: userId,
  //       message: e.message,
  //     );
  //     throw Failure(e.message);
  //   } on FormatException catch (e) {
  //     _firebaseService.firebaseFormatException(
  //       apiCall: "WalletLedgerModel",
  //       userId: userId,
  //       message: e.message,
  //     );
  //     throw Failure(e.message);
  //   } on HttpException catch (e) {
  //     _firebaseService.firebaseHttpException(
  //       apiCall: "WalletLedgerModel",
  //       userId: userId,
  //       message: e.message,
  //     );
  //     throw Failure(e.message);
  //   }
  //   return _ledgerModel;
  // }

  // Future<CreateWalletModel> getCreateWalletModelApi({
  //   required int amount,
  //   required dynamic dateTime,
  // }) async {
  //   try {
  //     String url = GetBaseUrl + GetDomainUrl + createwallet;
  //     var request = http.MultipartRequest('POST', Uri.parse(url));
  //     request.headers.addAll(await authHeader());
  //     request.fields.addAll({'amount': "$amount", 'date_time': dateTime});
  //     http.StreamedResponse response = await request.send();
  //     dynamic responseData = await response.stream.bytesToString();
  //     print("@@@@@@@@@@@ CreateWalletModel @@@@@@@@@@@");
  //     print(responseData);
  //     print("@@@@@@@@@@@ CreateWalletModel @@@@@@@@@@@");

  //     if (response.statusCode == httpsCode_200 ||
  //         response.statusCode == httpsCode_201) {
  //       _createWalletModel = createWalletModelFromJson(responseData);
  //     } else if (response.statusCode == httpsCode_404 ||
  //         response.statusCode == httpsCode_401) {
  //       // BasePrefs.clearPrefs().then((value) => Get.offAll(const LoadingPage()));
  //       _createWalletModel.requestStatus = RequestStatus.unauthorized;
  //     } else if (response.statusCode == httpsCode_500) {
  //       _createWalletModel.requestStatus = RequestStatus.server;
  //     }
  //   } on Error catch (e) {
  //     _firebaseService.firebaseDioError(
  //       apiCall: "getConfirmWalletModelApi",
  //       code: "401|404",
  //       userId: userId,
  //       message: e.toString(),
  //     );
  //   } on SocketException catch (e) {
  //     _firebaseService.firebaseSocketException(
  //       apiCall: "getConfirmWalletModelApi",
  //       userId: userId,
  //       message: e.message,
  //     );
  //     throw Failure(e.message);
  //   } on FormatException catch (e) {
  //     _firebaseService.firebaseFormatException(
  //       apiCall: "getConfirmWalletModelApi",
  //       userId: userId,
  //       message: e.message,
  //     );
  //     throw Failure(e.message);
  //   } on HttpException catch (e) {
  //     _firebaseService.firebaseHttpException(
  //       apiCall: "getConfirmWalletModelApi",
  //       userId: userId,
  //       message: e.message,
  //     );
  //     throw Failure(e.message);
  //   }
  //   return _createWalletModel;
  // }

  Future<ApiResponse> getConfirmWalletModelApi({
    required dynamic transactionId,
    required dynamic cfOrderId,
    required String paymentMode,
    File? screenshot,
    required String paymentType,
    required dynamic status,
  }) async {
    try {
      String url = GetBaseUrl + GetDomainUrl + confirmwallet;
      var request = http.MultipartRequest('POST', Uri.parse(url));
      request.headers.addAll(await authHeader());
      request.fields.addAll({
        'cf_order_id': cfOrderId,
        'status': status,
        'payment_type': paymentType,
        'payment_mode': paymentMode,
        'transaction_id': transactionId,
      });
      if (screenshot != null) {
        request.files.add(
          await http.MultipartFile.fromPath('screenshot', screenshot.path),
        );
      }
      http.StreamedResponse response = await request.send();
      dynamic responseData = await response.stream.bytesToString();
      print("@@@@@@@@@@@ getConfirmWalletModelApi @@@@@@@@@@@");
      print(url);
      print(await authHeader());
      print({
        'cf_order_id': cfOrderId,
        'status': status,
        'payment_type': paymentType,
        'payment_mode': paymentMode,
        'transaction_id': transactionId,
      });
      print(responseData);
      print("@@@@@@@@@@@ getConfirmWalletModelApi @@@@@@@@@@@");

      if (response.statusCode == httpsCode_200 ||
          response.statusCode == httpsCode_201) {
        _apiResponse = ApiResponse.fromJson(jsonDecode(responseData));
      } else if (response.statusCode == httpsCode_404 ||
          response.statusCode == httpsCode_401) {
        // BasePrefs.clearPrefs().then((value) => Get.offAll(const LoadingPage()));
        _apiResponse.requestStatus = RequestStatus.unauthorized;
      } else if (response.statusCode == httpsCode_500) {
        _apiResponse.requestStatus = RequestStatus.server;
      }
    } on Error catch (e) {
      _firebaseService.firebaseDioError(
        apiCall: "getConfirmWalletModelApi",
        code: "401|404",
        userId: userId,
        message: e.toString(),
      );
    } on SocketException catch (e) {
      _firebaseService.firebaseSocketException(
        apiCall: "getConfirmWalletModelApi",
        userId: userId,
        message: e.message,
      );
      throw Failure(e.message);
    } on FormatException catch (e) {
      _firebaseService.firebaseFormatException(
        apiCall: "getConfirmWalletModelApi",
        userId: userId,
        message: e.message,
      );
      throw Failure(e.message);
    } on HttpException catch (e) {
      _firebaseService.firebaseHttpException(
        apiCall: "getConfirmWalletModelApi",
        userId: userId,
        message: e.message,
      );
      throw Failure(e.message);
    }
    return _apiResponse;
  }

  // Future<ChatAstrologerModel> getChatAstrologerModelApi({
  //   required dynamic astrologerId,
  //   required dynamic customerId,
  //   required dynamic date,
  //   required dynamic time,
  // }) async {
  //   try {
  //     String url = GetBaseUrl + GetDomainUrl + chatfreeAstro;
  //     var request = http.MultipartRequest('POST', Uri.parse(url));
  //     request.headers.addAll(await authHeader());
  //     print("@@@@@@@@@@@ChatAstrologerModel@@@@@@@@@@@");
  //     print(url);
  //     print(await authHeader());
  //     print({
  //       'astrologer_id': astrologerId,
  //       'customer_id': customerId,
  //       'date': date,
  //       'time': time,
  //     });
  //     request.fields.addAll({
  //       'astrologer_id': astrologerId,
  //       'customer_id': customerId,
  //       'date': date,
  //       'time': time,
  //     });

  //     http.StreamedResponse response = await request.send();

  //     dynamic responseData = await response.stream.bytesToString();

  //     print(responseData);
  //     print("@@@@@@@@@@@ChatAstrologerModel@@@@@@@@@@@");

  //     if (response.statusCode == httpsCode_200 ||
  //         response.statusCode == httpsCode_201) {
  //       _chatAstrologerModel = ChatAstrologerModel.fromJson(
  //         jsonDecode(responseData),
  //       );
  //     } else if (response.statusCode == httpsCode_404 ||
  //         response.statusCode == httpsCode_401) {
  //       // BasePrefs.clearPrefs().then((value) => Get.offAll(const LoadingPage()));
  //       _chatAstrologerModel.requestStatus = RequestStatus.unauthorized;
  //     } else if (response.statusCode == httpsCode_500) {
  //       _chatAstrologerModel.requestStatus = RequestStatus.server;
  //     }
  //   } on Error catch (e) {
  //     _firebaseService.firebaseDioError(
  //       apiCall: "ChatAstrologerModel",
  //       code: "401|404",
  //       userId: userId,
  //       message: e.toString(),
  //     );
  //   } on SocketException catch (e) {
  //     _firebaseService.firebaseSocketException(
  //       apiCall: "ChatAstrologerModel",
  //       userId: userId,
  //       message: e.message,
  //     );
  //     throw Failure(e.message);
  //   } on FormatException catch (e) {
  //     _firebaseService.firebaseFormatException(
  //       apiCall: "ChatAstrologerModel",
  //       userId: userId,
  //       message: e.message,
  //     );
  //     throw Failure(e.message);
  //   } on HttpException catch (e) {
  //     _firebaseService.firebaseHttpException(
  //       apiCall: "ChatAstrologerModel",
  //       userId: userId,
  //       message: e.message,
  //     );
  //     throw Failure(e.message);
  //   }
  //   return _chatAstrologerModel;
  // }

  // Future<AstrologerProfileModel> getAstrologerProfileModelApi({
  //   required int astroId,
  // }) async {
  //   try {
  //     String url =
  //         GetBaseUrl + GetDomainUrl + astroProfileDetails(astroId: astroId);
  //     var request = http.MultipartRequest('GET', Uri.parse(url));
  //     request.headers.addAll(await authHeader());
  //     // request.fields.addAll({'name': quary});

  //     http.StreamedResponse response = await request.send();

  //     dynamic responseData = await response.stream.bytesToString();

  //     if (response.statusCode == httpsCode_200 ||
  //         response.statusCode == httpsCode_201) {
  //       _astrologerProfileModel = astrologerProfileModelFromJson(responseData);
  //       print("@@@@@@@@@@@AstrologerProfileModel@@@@@@@@@@@");
  //       print(url);
  //       print(responseData);
  //       print(await authHeader());
  //       print(_astrologerProfileModel.data!.services!.length);
  //       print("@@@@@@@@@@@ AstrologerProfileModel @@@@@@@@@@@");
  //     } else if (response.statusCode == httpsCode_404 ||
  //         response.statusCode == httpsCode_401) {
  //       // BasePrefs.clearPrefs().then((value) => Get.offAll(const LoadingPage()));
  //       _astrologerProfileModel.requestStatus = RequestStatus.unauthorized;
  //     } else if (response.statusCode == httpsCode_500) {
  //       _astrologerProfileModel.requestStatus = RequestStatus.server;
  //     }
  //   } on Error catch (e) {
  //     _firebaseService.firebaseDioError(
  //       apiCall: "AstrologerProfileModel",
  //       code: "401|404",
  //       userId: userId,
  //       message: e.toString(),
  //     );
  //   } on SocketException catch (e) {
  //     _firebaseService.firebaseSocketException(
  //       apiCall: "AstrologerProfileModel",
  //       userId: userId,
  //       message: e.message,
  //     );
  //     throw Failure(e.message);
  //   } on FormatException catch (e) {
  //     _firebaseService.firebaseFormatException(
  //       apiCall: "AstrologerProfileModel",
  //       userId: userId,
  //       message: e.message,
  //     );
  //     throw Failure(e.message);
  //   } on HttpException catch (e) {
  //     _firebaseService.firebaseHttpException(
  //       apiCall: "AstrologerProfileModel",
  //       userId: userId,
  //       message: e.message,
  //     );
  //     throw Failure(e.message);
  //   }
  //   return _astrologerProfileModel;
  // }

  // Future<ReviewListModel> getReviewListModelApi({
  //   required int astroId,
  //   required String orderType,
  // }) async {
  //   try {
  //     String url =
  //         GetBaseUrl +
  //         GetDomainUrl +
  //         reviewlist(astroId: astroId, orderType: orderType);
  //     var request = http.MultipartRequest('GET', Uri.parse(url));
  //     request.headers.addAll(await authHeader());
  //     // request.fields.addAll({'name': quary});

  //     http.StreamedResponse response = await request.send();

  //     dynamic responseData = await response.stream.bytesToString();

  //     print("@@@@@@@@@@@ ReviewListModel @@@@@@@@@@@");
  //     print(responseData);
  //     print(url);
  //     print("@@@@@@@@@@@ ReviewListModel @@@@@@@@@@@");

  //     if (response.statusCode == httpsCode_200 ||
  //         response.statusCode == httpsCode_201) {
  //       _reviewListModel = reviewListModelFromJson(responseData);
  //     } else if (response.statusCode == httpsCode_404 ||
  //         response.statusCode == httpsCode_401) {
  //       // BasePrefs.clearPrefs().then((value) => Get.offAll(const LoadingPage()));
  //       _reviewListModel.requestStatus = RequestStatus.unauthorized;
  //     } else if (response.statusCode == httpsCode_500) {
  //       _reviewListModel.requestStatus = RequestStatus.server;
  //     }
  //   } on Error catch (e) {
  //     _firebaseService.firebaseDioError(
  //       apiCall: "ReviewListModel",
  //       code: "401|404",
  //       userId: userId,
  //       message: e.toString(),
  //     );
  //   } on SocketException catch (e) {
  //     _firebaseService.firebaseSocketException(
  //       apiCall: "ReviewListModel",
  //       userId: userId,
  //       message: e.message,
  //     );
  //     throw Failure(e.message);
  //   } on FormatException catch (e) {
  //     _firebaseService.firebaseFormatException(
  //       apiCall: "ReviewListModel",
  //       userId: userId,
  //       message: e.message,
  //     );
  //     throw Failure(e.message);
  //   } on HttpException catch (e) {
  //     _firebaseService.firebaseHttpException(
  //       apiCall: "ReviewListModel",
  //       userId: userId,
  //       message: e.message,
  //     );
  //     throw Failure(e.message);
  //   }
  //   return _reviewListModel;
  // }

  Future<ApiResponse> getPostReviewApi({
    required int astroId,
    required double rating,
    required String comment,
    required int customerId,
    required String dateTime,
    required String type,
    required int productId,
  }) async {
    try {
      String url = GetBaseUrl + GetDomainUrl + postReview;
      var request = http.MultipartRequest('POST', Uri.parse(url));
      request.headers.addAll(await authHeader());
      print("@@@@@@@@@@@ getPostReviewApi @@@@@@@@@@@");
      print({
        'astrologer_id': astroId.toString(),
        'customer_id': customerId.toString(),
        'rating': rating.toString(),
        'comment': comment,
        'date': dateTime,
        'type': type,
        'product_id': productId.toString(),
      });
      print(url);
      print("@@@@@@@@@@@ getPostReviewApi @@@@@@@@@@@");

      request.fields.addAll({
        'astrologer_id': astroId.toString(),
        'customer_id': customerId.toString(),
        'rating': rating.toString(),
        'comment': comment,
        'date': dateTime,
        'type': type,
        'product_id': productId.toString(),
      });
      http.StreamedResponse response = await request.send();

      dynamic responseData = await response.stream.bytesToString();

      print("@@@@@@@@@@@ getPostReviewApi @@@@@@@@@@@");
      print(responseData);
      print("@@@@@@@@@@@ getPostReviewApi @@@@@@@@@@@");

      if (response.statusCode == httpsCode_200 ||
          response.statusCode == httpsCode_201) {
        _apiResponse = ApiResponse.fromJson(jsonDecode(responseData));
      } else if (response.statusCode == httpsCode_404 ||
          response.statusCode == httpsCode_401) {
        // BasePrefs.clearPrefs().then((value) => Get.offAll(const LoadingPage()));
        _apiResponse.requestStatus = RequestStatus.unauthorized;
      } else if (response.statusCode == httpsCode_500) {
        _apiResponse.requestStatus = RequestStatus.server;
      }
    } on Error catch (e) {
      _firebaseService.firebaseDioError(
        apiCall: "getPostReviewApi",
        code: "401|404",
        userId: userId,
        message: e.toString(),
      );
    } on SocketException catch (e) {
      _firebaseService.firebaseSocketException(
        apiCall: "getPostReviewApi",
        userId: userId,
        message: e.message,
      );
      throw Failure(e.message);
    } on FormatException catch (e) {
      _firebaseService.firebaseFormatException(
        apiCall: "getPostReviewApi",
        userId: userId,
        message: e.message,
      );
      throw Failure(e.message);
    } on HttpException catch (e) {
      _firebaseService.firebaseHttpException(
        apiCall: "getPostReviewApi",
        userId: userId,
        message: e.message,
      );
      throw Failure(e.message);
    }
    return _apiResponse;
  }

  Future<ApiResponse> getPostLikeApi({
    required int videoId,
    required int customerId,
    required String videotype,
  }) async {
    try {
      String url = GetBaseUrl + GetDomainUrl + videoLike;
      var request = http.MultipartRequest('POST', Uri.parse(url));
      request.headers.addAll(await authHeader());
      print("@@@@@@@@@@@ getPostLikeApi @@@@@@@@@@@");
      print(url);
      print("@@@@@@@@@@@ getPostLikeApi @@@@@@@@@@@");

      request.fields.addAll({
        'video_id': '$videoId',
        'video_type': videotype,
        'customer_id': '$customerId',
      });
      http.StreamedResponse response = await request.send();

      dynamic responseData = await response.stream.bytesToString();

      print("@@@@@@@@@@@ getPostLikeApi @@@@@@@@@@@");
      print(responseData);
      print("@@@@@@@@@@@ getPostLikeApi @@@@@@@@@@@");

      if (response.statusCode == httpsCode_200 ||
          response.statusCode == httpsCode_201) {
        _apiResponse = ApiResponse.fromJson(jsonDecode(responseData));
      } else if (response.statusCode == httpsCode_404 ||
          response.statusCode == httpsCode_401) {
        // BasePrefs.clearPrefs().then((value) => Get.offAll(const LoadingPage()));
        _apiResponse.requestStatus = RequestStatus.unauthorized;
      } else if (response.statusCode == httpsCode_500) {
        _apiResponse.requestStatus = RequestStatus.server;
      }
    } on Error catch (e) {
      _firebaseService.firebaseDioError(
        apiCall: "getPostLikeApi",
        code: "401|404",
        userId: userId,
        message: e.toString(),
      );
    } on SocketException catch (e) {
      _firebaseService.firebaseSocketException(
        apiCall: "getPostLikeApi",
        userId: userId,
        message: e.message,
      );
      throw Failure(e.message);
    } on FormatException catch (e) {
      _firebaseService.firebaseFormatException(
        apiCall: "getPostLikeApi",
        userId: userId,
        message: e.message,
      );
      throw Failure(e.message);
    } on HttpException catch (e) {
      _firebaseService.firebaseHttpException(
        apiCall: "getPostLikeApi",
        userId: userId,
        message: e.message,
      );
      throw Failure(e.message);
    }
    return _apiResponse;
  }

  // Future<SupportChatModel> getSupportChatModelApi({
  //   required dynamic customerId,
  // }) async {
  //   try {
  //     String url = GetBaseUrl + GetDomainUrl + supportChat;
  //     var request = http.MultipartRequest('POST', Uri.parse(url));
  //     request.headers.addAll(await authHeader());
  //     request.fields.addAll({'customer_id': customerId});
  //     http.StreamedResponse response = await request.send();
  //     dynamic responseData = await response.stream.bytesToString();
  //     print("@@@@@@@@@@@ _supportChatModel @@@@@@@@@@@");
  //     print(responseData);
  //     print("@@@@@@@@@@@ _supportChatModel @@@@@@@@@@@");
  //     if (response.statusCode == httpsCode_200 ||
  //         response.statusCode == httpsCode_201) {
  //       _supportChatModel = SupportChatModel.fromJson(jsonDecode(responseData));
  //     } else if (response.statusCode == httpsCode_404 ||
  //         response.statusCode == httpsCode_401) {
  //       // BasePrefs.clearPrefs().then((value) => Get.offAll(const LoadingPage()));
  //       _supportChatModel.requestStatus = RequestStatus.unauthorized;
  //     } else if (response.statusCode == httpsCode_500) {
  //       _supportChatModel.requestStatus = RequestStatus.server;
  //     }
  //   } on Error catch (e) {
  //     _firebaseService.firebaseDioError(
  //       apiCall: "_supportChatModel",
  //       code: "401|404",
  //       userId: userId,
  //       message: e.toString(),
  //     );
  //   } on SocketException catch (e) {
  //     _firebaseService.firebaseSocketException(
  //       apiCall: "_supportChatModel",
  //       userId: userId,
  //       message: e.message,
  //     );
  //     throw Failure(e.message);
  //   } on FormatException catch (e) {
  //     _firebaseService.firebaseFormatException(
  //       apiCall: "_supportChatModel",
  //       userId: userId,
  //       message: e.message,
  //     );
  //     throw Failure(e.message);
  //   } on HttpException catch (e) {
  //     _firebaseService.firebaseHttpException(
  //       apiCall: "_supportChatModel",
  //       userId: userId,
  //       message: e.message,
  //     );
  //     throw Failure(e.message);
  //   }
  //   return _supportChatModel;
  // }

  // Future<ApiResponse> getVideoViewsApi({
  //   required int videoId,
  //   required String videotype,
  // }) async {
  //   try {
  //     String url = GetBaseUrl + GetDomainUrl + videoView;
  //     var request = http.MultipartRequest('POST', Uri.parse(url));
  //     request.headers.addAll(await authHeader());
  //     print("@@@@@@@@@@@ getVideoViewsApi @@@@@@@@@@@");
  //     print(url);
  //     print("@@@@@@@@@@@ getVideoViewsApi @@@@@@@@@@@");

  //     request.fields.addAll({'video_id': '$videoId', 'video_type': videotype});
  //     http.StreamedResponse response = await request.send();

  //     dynamic responseData = await response.stream.bytesToString();

  //     print("@@@@@@@@@@@ getVideoViewsApi @@@@@@@@@@@");
  //     print(responseData);
  //     print("@@@@@@@@@@@ getVideoViewsApi @@@@@@@@@@@");

  //     if (response.statusCode == httpsCode_200 ||
  //         response.statusCode == httpsCode_201) {
  //       _apiResponse = ApiResponse.fromJson(jsonDecode(responseData));
  //     } else if (response.statusCode == httpsCode_404 ||
  //         response.statusCode == httpsCode_401) {
  //       // BasePrefs.clearPrefs().then((value) => Get.offAll(const LoadingPage()));
  //       _apiResponse.requestStatus = RequestStatus.unauthorized;
  //     } else if (response.statusCode == httpsCode_500) {
  //       _apiResponse.requestStatus = RequestStatus.server;
  //     }
  //   } on Error catch (e) {
  //     _firebaseService.firebaseDioError(
  //       apiCall: "getVideoViewsApi",
  //       code: "401|404",
  //       userId: userId,
  //       message: e.toString(),
  //     );
  //   } on SocketException catch (e) {
  //     _firebaseService.firebaseSocketException(
  //       apiCall: "getVideoViewsApi",
  //       userId: userId,
  //       message: e.message,
  //     );
  //     throw Failure(e.message);
  //   } on FormatException catch (e) {
  //     _firebaseService.firebaseFormatException(
  //       apiCall: "getVideoViewsApi",
  //       userId: userId,
  //       message: e.message,
  //     );
  //     throw Failure(e.message);
  //   } on HttpException catch (e) {
  //     _firebaseService.firebaseHttpException(
  //       apiCall: "getVideoViewsApi",
  //       userId: userId,
  //       message: e.message,
  //     );
  //     throw Failure(e.message);
  //   }
  //   return _apiResponse;
  // }

  // Future<VideoBannerModel> getVideoBannerModelApi() async {
  //   try {
  //     String url = GetBaseUrl + GetDomainUrl + videoBanner;
  //     var request = http.MultipartRequest('POST', Uri.parse(url));
  //     request.headers.addAll(await authHeader());
  //     print("@@@@@@@@@@@ VideoBannerModel @@@@@@@@@@@");
  //     print(url);
  //     print("@@@@@@@@@@@ VideoBannerModel @@@@@@@@@@@");

  //     // request.fields.addAll({
  //     //   'video_id': '$videoId',
  //     //   'video_type': videotype,
  //     // });
  //     http.StreamedResponse response = await request.send();

  //     dynamic responseData = await response.stream.bytesToString();

  //     print("@@@@@@@@@@@ VideoBannerModel @@@@@@@@@@@");
  //     print(responseData);
  //     print("@@@@@@@@@@@ VideoBannerModel @@@@@@@@@@@");

  //     if (response.statusCode == httpsCode_200 ||
  //         response.statusCode == httpsCode_201) {
  //       _videoBannerModel = VideoBannerModel.fromJson(jsonDecode(responseData));
  //     } else if (response.statusCode == httpsCode_404 ||
  //         response.statusCode == httpsCode_401) {
  //       // BasePrefs.clearPrefs().then((value) => Get.offAll(const LoadingPage()));
  //       _videoBannerModel.requestStatus = RequestStatus.unauthorized;
  //     } else if (response.statusCode == httpsCode_500) {
  //       _videoBannerModel.requestStatus = RequestStatus.server;
  //     }
  //   } on Error catch (e) {
  //     _firebaseService.firebaseDioError(
  //       apiCall: "VideoBannerModel",
  //       code: "401|404",
  //       userId: userId,
  //       message: e.toString(),
  //     );
  //   } on SocketException catch (e) {
  //     _firebaseService.firebaseSocketException(
  //       apiCall: "VideoBannerModel",
  //       userId: userId,
  //       message: e.message,
  //     );
  //     throw Failure(e.message);
  //   } on FormatException catch (e) {
  //     _firebaseService.firebaseFormatException(
  //       apiCall: "VideoBannerModel",
  //       userId: userId,
  //       message: e.message,
  //     );
  //     throw Failure(e.message);
  //   } on HttpException catch (e) {
  //     _firebaseService.firebaseHttpException(
  //       apiCall: "VideoBannerModel",
  //       userId: userId,
  //       message: e.message,
  //     );
  //     throw Failure(e.message);
  //   }
  //   return _videoBannerModel;
  // }

  Future<ApiResponse> getSaveVideosApi({
    required int videoId,
    required int customerId,
    required String videotype,
  }) async {
    try {
      String url = GetBaseUrl + GetDomainUrl + savedVideo;
      var request = http.MultipartRequest('POST', Uri.parse(url));
      request.headers.addAll(await authHeader());
      print("@@@@@@@@@@@ getSaveVideosApi @@@@@@@@@@@");
      print(url);
      print("@@@@@@@@@@@ getSaveVideosApi @@@@@@@@@@@");

      request.fields.addAll({
        'video_id': '$videoId',
        'video_type': videotype,
        'customer_id': '$customerId',
      });
      http.StreamedResponse response = await request.send();

      dynamic responseData = await response.stream.bytesToString();

      print("@@@@@@@@@@@ getSaveVideosApi @@@@@@@@@@@");
      print(responseData);
      print("@@@@@@@@@@@ getSaveVideosApi @@@@@@@@@@@");

      if (response.statusCode == httpsCode_200 ||
          response.statusCode == httpsCode_201) {
        _apiResponse = ApiResponse.fromJson(jsonDecode(responseData));
      } else if (response.statusCode == httpsCode_404 ||
          response.statusCode == httpsCode_401) {
        // BasePrefs.clearPrefs().then((value) => Get.offAll(const LoadingPage()));
        _apiResponse.requestStatus = RequestStatus.unauthorized;
      } else if (response.statusCode == httpsCode_500) {
        _apiResponse.requestStatus = RequestStatus.server;
      }
    } on Error catch (e) {
      _firebaseService.firebaseDioError(
        apiCall: "getSaveVideosApi",
        code: "401|404",
        userId: userId,
        message: e.toString(),
      );
    } on SocketException catch (e) {
      _firebaseService.firebaseSocketException(
        apiCall: "getSaveVideosApi",
        userId: userId,
        message: e.message,
      );
      throw Failure(e.message);
    } on FormatException catch (e) {
      _firebaseService.firebaseFormatException(
        apiCall: "getSaveVideosApi",
        userId: userId,
        message: e.message,
      );
      throw Failure(e.message);
    } on HttpException catch (e) {
      _firebaseService.firebaseHttpException(
        apiCall: "getSaveVideosApi",
        userId: userId,
        message: e.message,
      );
      throw Failure(e.message);
    }
    return _apiResponse;
  }

  Future<ApiResponse> getSessionCheckApi({required int sessionId}) async {
    try {
      String url = GetBaseUrl + GetDomainUrl + sessionCheck;
      var request = http.MultipartRequest('POST', Uri.parse(url));
      request.headers.addAll(await authHeader());
      print("@@@@@@@@@@@ sessionId @@@@@@@@@@@");
      print(url);
      print("@@@@@@@@@@@ sessionId @@@@@@@@@@@");

      request.fields.addAll({'session_id': '$sessionId'});
      http.StreamedResponse response = await request.send();

      dynamic responseData = await response.stream.bytesToString();

      print("@@@@@@@@@@@ sessionId @@@@@@@@@@@");
      print(responseData);
      print("@@@@@@@@@@@ sessionId @@@@@@@@@@@");

      if (response.statusCode == httpsCode_200 ||
          response.statusCode == httpsCode_201) {
        _apiResponse = ApiResponse.fromJson(jsonDecode(responseData));
      } else if (response.statusCode == httpsCode_404 ||
          response.statusCode == httpsCode_401) {
        // BasePrefs.clearPrefs().then((value) => Get.offAll(const LoadingPage()));
        _apiResponse.requestStatus = RequestStatus.unauthorized;
      } else if (response.statusCode == httpsCode_500) {
        _apiResponse.requestStatus = RequestStatus.server;
      }
    } on Error catch (e) {
      _firebaseService.firebaseDioError(
        apiCall: "sessionId",
        code: "401|404",
        userId: userId,
        message: e.toString(),
      );
    } on SocketException catch (e) {
      _firebaseService.firebaseSocketException(
        apiCall: "sessionId",
        userId: userId,
        message: e.message,
      );
      throw Failure(e.message);
    } on FormatException catch (e) {
      _firebaseService.firebaseFormatException(
        apiCall: "sessionId",
        userId: userId,
        message: e.message,
      );
      throw Failure(e.message);
    } on HttpException catch (e) {
      _firebaseService.firebaseHttpException(
        apiCall: "sessionId",
        userId: userId,
        message: e.message,
      );
      throw Failure(e.message);
    }
    return _apiResponse;
  }

  Future<ApiResponse> getfreeChatCheckApi({
    required String roomId,
    required String startTime,
    required String endTime,
  }) async {
    try {
      String url = GetBaseUrl + GetDomainUrl + freeChatCheck;
      var request = http.MultipartRequest('POST', Uri.parse(url));
      request.headers.addAll(await authHeader());
      print("@@@@@@@@@@@ getfreeChatCheckApi @@@@@@@@@@@");
      print(url);
      print("@@@@@@@@@@@ getfreeChatCheckApi @@@@@@@@@@@");

      request.fields.addAll({
        'chat_start_at': startTime,
        'chat_end_at': endTime,
        'room_id': roomId,
      });
      http.StreamedResponse response = await request.send();

      dynamic responseData = await response.stream.bytesToString();

      print("@@@@@@@@@@@ getfreeChatCheckApi @@@@@@@@@@@");
      print(responseData);
      print("@@@@@@@@@@@ getfreeChatCheckApi @@@@@@@@@@@");

      if (response.statusCode == httpsCode_200 ||
          response.statusCode == httpsCode_201) {
        _apiResponse = ApiResponse.fromJson(jsonDecode(responseData));
      } else if (response.statusCode == httpsCode_404 ||
          response.statusCode == httpsCode_401) {
        // BasePrefs.clearPrefs().then((value) => Get.offAll(const LoadingPage()));
        _apiResponse.requestStatus = RequestStatus.unauthorized;
      } else if (response.statusCode == httpsCode_500) {
        _apiResponse.requestStatus = RequestStatus.server;
      }
    } on Error catch (e) {
      _firebaseService.firebaseDioError(
        apiCall: "getfreeChatCheckApi",
        code: "401|404",
        userId: userId,
        message: e.toString(),
      );
    } on SocketException catch (e) {
      _firebaseService.firebaseSocketException(
        apiCall: "getfreeChatCheckApi",
        userId: userId,
        message: e.message,
      );
      throw Failure(e.message);
    } on FormatException catch (e) {
      _firebaseService.firebaseFormatException(
        apiCall: "getfreeChatCheckApi",
        userId: userId,
        message: e.message,
      );
      throw Failure(e.message);
    } on HttpException catch (e) {
      _firebaseService.firebaseHttpException(
        apiCall: "getfreeChatCheckApi",
        userId: userId,
        message: e.message,
      );
      throw Failure(e.message);
    }
    return _apiResponse;
  }

  // Future<AllBannerModel> getAllBannerModelApi() async {
  //   try {
  //     String url = GetBaseUrl + GetDomainUrl + allBanner;
  //     var request = http.MultipartRequest('GET', Uri.parse(url));
  //     request.headers.addAll(await authHeader());
  //     print("@@@@@@@@@@@ AllBannerModel @@@@@@@@@@@");
  //     print(url);
  //     print(await authHeader());
  //     print("@@@@@@@@@@@ AllBannerModel @@@@@@@@@@@");

  //     // request.fields.addAll({
  //     //   'video_id': '$videoId',
  //     //   'video_type': videotype,
  //     // });
  //     http.StreamedResponse response = await request.send();

  //     dynamic responseData = await response.stream.bytesToString();

  //     print("@@@@@@@@@@@ AllBannerModel @@@@@@@@@@@");
  //     print(responseData);
  //     print("@@@@@@@@@@@ AllBannerModel @@@@@@@@@@@");

  //     if (response.statusCode == httpsCode_200 ||
  //         response.statusCode == httpsCode_201) {
  //       _allBannerModel = AllBannerModel.fromJson(jsonDecode(responseData));
  //     } else if (response.statusCode == httpsCode_404 ||
  //         response.statusCode == httpsCode_401) {
  //       // BasePrefs.clearPrefs().then((value) => Get.offAll(const LoadingPage()));
  //       _allBannerModel.requestStatus = RequestStatus.unauthorized;
  //     } else if (response.statusCode == httpsCode_500) {
  //       _allBannerModel.requestStatus = RequestStatus.server;
  //     }
  //   } on Error catch (e) {
  //     _firebaseService.firebaseDioError(
  //       apiCall: "AllBannerModel",
  //       code: "401|404",
  //       userId: userId,
  //       message: e.toString(),
  //     );
  //   } on SocketException catch (e) {
  //     _firebaseService.firebaseSocketException(
  //       apiCall: "AllBannerModel",
  //       userId: userId,
  //       message: e.message,
  //     );
  //     throw Failure(e.message);
  //   } on FormatException catch (e) {
  //     _firebaseService.firebaseFormatException(
  //       apiCall: "AllBannerModel",
  //       userId: userId,
  //       message: e.message,
  //     );
  //     throw Failure(e.message);
  //   } on HttpException catch (e) {
  //     _firebaseService.firebaseHttpException(
  //       apiCall: "AllBannerModel",
  //       userId: userId,
  //       message: e.message,
  //     );
  //     throw Failure(e.message);
  //   }
  //   return _allBannerModel;
  // }

  // Future<ApiResponse> getvastuFormApi({
  //   required String name,
  //   required String phone,
  //   required String email,
  //   required String propertyType,
  //   required String dob,
  //   required String address,
  //   required String propertyArea,
  //   required String noOfFloors,
  //   required String specificConcernsType,
  //   required String specificConcernsArea,
  //   required String bad,
  //   required String consultDatetime,
  //   required List<File> imagePath,
  // }) async {
  //   try {
  //     String url = GetBaseUrl + GetDomainUrl + vastuForm;
  //     var request = http.MultipartRequest('POST', Uri.parse(url));
  //     request.headers.addAll(await authHeader());
  //     print("@@@@@@@@@@@ getvastuFormApi @@@@@@@@@@@");
  //     print(url);
  //     print("@@@@@@@@@@@ getvastuFormApi @@@@@@@@@@@");

  //     request.fields.addAll({
  //       'name': name,
  //       'phone': phone,
  //       'email': email,
  //       'dob': dob,
  //       'address': address,
  //       'property_type': propertyType,
  //       'property_area': propertyArea,
  //       'no_of_floors': noOfFloors,
  //       'specific_concerns_type': specificConcernsType,
  //       'specific_concerns_area': specificConcernsArea,
  //       'bad': bad,
  //       'consult_datetime': consultDatetime,
  //     });
  //     for (var file in imagePath) {
  //       if (await file.exists()) {
  //         request.files.add(
  //           await http.MultipartFile.fromPath('files[]', file.path),
  //         );
  //       }
  //     }
  //     print("##############getvastuFormApi################");
  //     print(request.fields);
  //     print(request.files);

  //     // request.files.add(await http.MultipartFile.fromPath(
  //     //     'files', 'postman-cloud:///1efca960-3297-4b10-99ee-aecc64f39c1c'));

  //     http.StreamedResponse response = await request.send();
  //     dynamic responseData = await response.stream.bytesToString();
  //     print("@@@@@@@@@@@ getvastuFormApi @@@@@@@@@@@");
  //     print(responseData);
  //     print("@@@@@@@@@@@ getvastuFormApi @@@@@@@@@@@");

  //     if (response.statusCode == httpsCode_200 ||
  //         response.statusCode == httpsCode_201) {
  //       _apiResponse = ApiResponse.fromJson(jsonDecode(responseData));
  //     } else if (response.statusCode == httpsCode_404 ||
  //         response.statusCode == httpsCode_401) {
  //       // BasePrefs.clearPrefs().then((value) => Get.offAll(const LoadingPage()));
  //       _apiResponse.requestStatus = RequestStatus.unauthorized;
  //     } else if (response.statusCode == httpsCode_500) {
  //       _apiResponse.requestStatus = RequestStatus.server;
  //     }
  //   } on Error catch (e) {
  //     _firebaseService.firebaseDioError(
  //       apiCall: "getvastuFormApi",
  //       code: "401|404",
  //       userId: userId,
  //       message: e.toString(),
  //     );
  //   } on SocketException catch (e) {
  //     _firebaseService.firebaseSocketException(
  //       apiCall: "getvastuFormApi",
  //       userId: userId,
  //       message: e.message,
  //     );
  //     throw Failure(e.message);
  //   } on FormatException catch (e) {
  //     _firebaseService.firebaseFormatException(
  //       apiCall: "getvastuFormApi",
  //       userId: userId,
  //       message: e.message,
  //     );
  //     throw Failure(e.message);
  //   } on HttpException catch (e) {
  //     _firebaseService.firebaseHttpException(
  //       apiCall: "getvastuFormApi",
  //       userId: userId,
  //       message: e.message,
  //     );
  //     throw Failure(e.message);
  //   }
  //   return _apiResponse;
  // }

  // Future<UpdateMentenceModel> getUpdateMentenceModelApi() async {
  //   try {
  //     String url = GetBaseUrl + GetDomainUrl + updateMentence;
  //     var request = http.MultipartRequest('GET', Uri.parse(url));
  //     request.headers.addAll(await authHeader());
  //     print("@@@@@@@@@@@ UpdateMentenceModel @@@@@@@@@@@");
  //     print(url);
  //     print("@@@@@@@@@@@ UpdateMentenceModel @@@@@@@@@@@");

  //     http.StreamedResponse response = await request.send();

  //     dynamic responseData = await response.stream.bytesToString();

  //     print("@@@@@@@@@@@ UpdateMentenceModel @@@@@@@@@@@");
  //     print(responseData);
  //     print("@@@@@@@@@@@ UpdateMentenceModel @@@@@@@@@@@");

  //     if (response.statusCode == httpsCode_200 ||
  //         response.statusCode == httpsCode_201) {
  //       _updateMentenceModel = UpdateMentenceModel.fromJson(
  //         jsonDecode(responseData),
  //       );
  //     } else if (response.statusCode == httpsCode_404 ||
  //         response.statusCode == httpsCode_401) {
  //       // BasePrefs.clearPrefs().then((value) => Get.offAll(const LoadingPage()));
  //       _updateMentenceModel.requestStatus = RequestStatus.unauthorized;
  //     } else if (response.statusCode == httpsCode_500) {
  //       _updateMentenceModel.requestStatus = RequestStatus.server;
  //     }
  //   } on Error catch (e) {
  //     _firebaseService.firebaseDioError(
  //       apiCall: "UpdateMentenceModel",
  //       code: "401|404",
  //       userId: userId,
  //       message: e.toString(),
  //     );
  //   } on SocketException catch (e) {
  //     _firebaseService.firebaseSocketException(
  //       apiCall: "UpdateMentenceModel",
  //       userId: userId,
  //       message: e.message,
  //     );
  //     throw Failure(e.message);
  //   } on FormatException catch (e) {
  //     _firebaseService.firebaseFormatException(
  //       apiCall: "UpdateMentenceModel",
  //       userId: userId,
  //       message: e.message,
  //     );
  //     throw Failure(e.message);
  //   } on HttpException catch (e) {
  //     _firebaseService.firebaseHttpException(
  //       apiCall: "UpdateMentenceModel",
  //       userId: userId,
  //       message: e.message,
  //     );
  //     throw Failure(e.message);
  //   }
  //   return _updateMentenceModel;
  // }

  // Future<PopUpModel> getPopUpModelApi() async {
  //   try {
  //     String url = GetBaseUrl + GetDomainUrl + popUp;
  //     var request = http.MultipartRequest('GET', Uri.parse(url));
  //     request.headers.addAll(await authHeader());
  //     print("@@@@@@@@@@@ PopUpModel @@@@@@@@@@@");
  //     print(url);
  //     print("@@@@@@@@@@@ PopUpModel @@@@@@@@@@@");

  //     http.StreamedResponse response = await request.send();

  //     dynamic responseData = await response.stream.bytesToString();

  //     print("@@@@@@@@@@@ PopUpModel @@@@@@@@@@@");
  //     print(responseData);
  //     print("@@@@@@@@@@@ PopUpModel @@@@@@@@@@@");

  //     if (response.statusCode == httpsCode_200 ||
  //         response.statusCode == httpsCode_201) {
  //       _popUpModel = PopUpModel.fromJson(jsonDecode(responseData));
  //     } else if (response.statusCode == httpsCode_404 ||
  //         response.statusCode == httpsCode_401) {
  //       // BasePrefs.clearPrefs().then((value) => Get.offAll(const LoadingPage()));
  //       _popUpModel.requestStatus = RequestStatus.unauthorized;
  //     } else if (response.statusCode == httpsCode_500) {
  //       _popUpModel.requestStatus = RequestStatus.server;
  //     }
  //   } on Error catch (e) {
  //     _firebaseService.firebaseDioError(
  //       apiCall: "PopUpModel",
  //       code: "401|404",
  //       userId: userId,
  //       message: e.toString(),
  //     );
  //   } on SocketException catch (e) {
  //     _firebaseService.firebaseSocketException(
  //       apiCall: "PopUpModel",
  //       userId: userId,
  //       message: e.message,
  //     );
  //     throw Failure(e.message);
  //   } on FormatException catch (e) {
  //     _firebaseService.firebaseFormatException(
  //       apiCall: "PopUpModel",
  //       userId: userId,
  //       message: e.message,
  //     );
  //     throw Failure(e.message);
  //   } on HttpException catch (e) {
  //     _firebaseService.firebaseHttpException(
  //       apiCall: "PopUpModel",
  //       userId: userId,
  //       message: e.message,
  //     );
  //     throw Failure(e.message);
  //   }
  //   return _popUpModel;
  // }

  // Future<CallImageUploadModel> getCallImageUploadModelApi({
  //   required dynamic sessionId,
  //   required dynamic roomId,
  //   required dynamic imagePath,
  // }) async {
  //   try {
  //     String url = GetBaseUrl + GetDomainUrl + callImageUpload;
  //     var request = http.MultipartRequest('POST', Uri.parse(url));
  //     request.headers.addAll(await authHeader());
  //     print("@@@@@@@@@@@ CallImageUploadModel @@@@@@@@@@@");
  //     print(url);
  //     print("@@@@@@@@@@@ CallImageUploadModel @@@@@@@@@@@");

  //     request.fields.addAll({'session_id': sessionId, 'room_id': roomId});
  //     request.files.add(await http.MultipartFile.fromPath('image', imagePath));
  //     http.StreamedResponse response = await request.send();

  //     dynamic responseData = await response.stream.bytesToString();

  //     print("@@@@@@@@@@@ CallImageUploadModel @@@@@@@@@@@");
  //     print(responseData);
  //     print("@@@@@@@@@@@ CallImageUploadModel @@@@@@@@@@@");

  //     if (response.statusCode == httpsCode_200 ||
  //         response.statusCode == httpsCode_201) {
  //       _callImageUploadModel = CallImageUploadModel.fromJson(
  //         jsonDecode(responseData),
  //       );
  //     } else if (response.statusCode == httpsCode_404 ||
  //         response.statusCode == httpsCode_401) {
  //       // BasePrefs.clearPrefs().then((value) => Get.offAll(const LoadingPage()));
  //       _callImageUploadModel.requestStatus = RequestStatus.unauthorized;
  //     } else if (response.statusCode == httpsCode_500) {
  //       _callImageUploadModel.requestStatus = RequestStatus.server;
  //     }
  //   } on Error catch (e) {
  //     _firebaseService.firebaseDioError(
  //       apiCall: "CallImageUploadModel",
  //       code: "401|404",
  //       userId: userId,
  //       message: e.toString(),
  //     );
  //   } on SocketException catch (e) {
  //     _firebaseService.firebaseSocketException(
  //       apiCall: "CallImageUploadModel",
  //       userId: userId,
  //       message: e.message,
  //     );
  //     throw Failure(e.message);
  //   } on FormatException catch (e) {
  //     _firebaseService.firebaseFormatException(
  //       apiCall: "CallImageUploadModel",
  //       userId: userId,
  //       message: e.message,
  //     );
  //     throw Failure(e.message);
  //   } on HttpException catch (e) {
  //     _firebaseService.firebaseHttpException(
  //       apiCall: "CallImageUploadModel",
  //       userId: userId,
  //       message: e.message,
  //     );
  //     throw Failure(e.message);
  //   }
  //   return _callImageUploadModel;
  // }

  // Future<ServiceOrderModel> getServiceApplyWalletModelApi({
  //   required int orderId,
  // }) async {
  //   try {
  //     String url = GetBaseUrl + GetDomainUrl + serviceApplyWallet;
  //     var request = http.MultipartRequest('POST', Uri.parse(url));
  //     request.headers.addAll(await authHeader());
  //     print("@@@@@@@@@@@ ServiceApplyWalletModel @@@@@@@@@@@");
  //     print(url);
  //     print("@@@@@@@@@@@ ServiceApplyWalletModel @@@@@@@@@@@");
  //     request.fields.addAll({"order_id": orderId.toString()});
  //     http.StreamedResponse response = await request.send();
  //     dynamic responseData = await response.stream.bytesToString();
  //     print("@@@@@@@@@@@ ServiceApplyWalletModel @@@@@@@@@@@");
  //     print(responseData);
  //     print("@@@@@@@@@@@ ServiceApplyWalletModel @@@@@@@@@@@");
  //     if (response.statusCode == httpsCode_200 ||
  //         response.statusCode == httpsCode_201) {
  //       _serviceApplyWalletModel = ServiceOrderModel.fromJson(
  //         jsonDecode(responseData),
  //       );
  //     } else if (response.statusCode == httpsCode_404 ||
  //         response.statusCode == httpsCode_401) {
  //       // BasePrefs.clearPrefs().then((value) => Get.offAll(const LoadingPage()));
  //       _serviceApplyWalletModel.requestStatus = RequestStatus.unauthorized;
  //     } else if (response.statusCode == httpsCode_500) {
  //       _serviceApplyWalletModel.requestStatus = RequestStatus.server;
  //     }
  //   } on Error catch (e) {
  //     _firebaseService.firebaseDioError(
  //       apiCall: "ServiceApplyWalletModel",
  //       code: "401|404",
  //       userId: userId,
  //       message: e.toString(),
  //     );
  //   } on SocketException catch (e) {
  //     _firebaseService.firebaseSocketException(
  //       apiCall: "ServiceApplyWalletModel",
  //       userId: userId,
  //       message: e.message,
  //     );
  //     throw Failure(e.message);
  //   } on FormatException catch (e) {
  //     _firebaseService.firebaseFormatException(
  //       apiCall: "ServiceApplyWalletModel",
  //       userId: userId,
  //       message: e.message,
  //     );
  //     throw Failure(e.message);
  //   } on HttpException catch (e) {
  //     _firebaseService.firebaseHttpException(
  //       apiCall: "ServiceApplyWalletModel",
  //       userId: userId,
  //       message: e.message,
  //     );
  //     throw Failure(e.message);
  //   }
  //   return _serviceApplyWalletModel;
  // }

  // Future<ServiceOrderModel> getServiceRemoveWalletModelApi({
  //   required int orderId,
  // }) async {
  //   try {
  //     String url = GetBaseUrl + GetDomainUrl + serviceRemoveWallet;
  //     var request = http.MultipartRequest('POST', Uri.parse(url));
  //     request.headers.addAll(await authHeader());
  //     print("@@@@@@@@@@@ ServiceRemoveWalletModel @@@@@@@@@@@");
  //     print(url);
  //     print("@@@@@@@@@@@ ServiceRemoveWalletModel @@@@@@@@@@@");

  //     request.fields.addAll({"order_id": orderId.toString()});
  //     http.StreamedResponse response = await request.send();

  //     dynamic responseData = await response.stream.bytesToString();

  //     print("@@@@@@@@@@@ ServiceRemoveWalletModel @@@@@@@@@@@");
  //     print(responseData);
  //     print("@@@@@@@@@@@ ServiceRemoveWalletModel @@@@@@@@@@@");

  //     if (response.statusCode == httpsCode_200 ||
  //         response.statusCode == httpsCode_201) {
  //       _serviceRemoveWalletModel = ServiceOrderModel.fromJson(
  //         jsonDecode(responseData),
  //       );
  //     } else if (response.statusCode == httpsCode_404 ||
  //         response.statusCode == httpsCode_401) {
  //       // BasePrefs.clearPrefs().then((value) => Get.offAll(const LoadingPage()));
  //       _serviceRemoveWalletModel.requestStatus = RequestStatus.unauthorized;
  //     } else if (response.statusCode == httpsCode_500) {
  //       _serviceRemoveWalletModel.requestStatus = RequestStatus.server;
  //     }
  //   } on Error catch (e) {
  //     _firebaseService.firebaseDioError(
  //       apiCall: "ServiceRemoveWalletModel",
  //       code: "401|404",
  //       userId: userId,
  //       message: e.toString(),
  //     );
  //   } on SocketException catch (e) {
  //     _firebaseService.firebaseSocketException(
  //       apiCall: "ServiceRemoveWalletModel",
  //       userId: userId,
  //       message: e.message,
  //     );
  //     throw Failure(e.message);
  //   } on FormatException catch (e) {
  //     _firebaseService.firebaseFormatException(
  //       apiCall: "ServiceRemoveWalletModel",
  //       userId: userId,
  //       message: e.message,
  //     );
  //     throw Failure(e.message);
  //   } on HttpException catch (e) {
  //     _firebaseService.firebaseHttpException(
  //       apiCall: "ServiceRemoveWalletModel",
  //       userId: userId,
  //       message: e.message,
  //     );
  //     throw Failure(e.message);
  //   }
  //   return _serviceRemoveWalletModel;
  // }

  Future<ApiResponse> getProductApplyWalletModelApi({
    required int cartId,
  }) async {
    try {
      String url = GetBaseUrl + GetDomainUrl + productApplyWallet;
      var request = http.MultipartRequest('POST', Uri.parse(url));
      request.headers.addAll(await authHeader());
      print("@@@@@@@@@@@ ProductApplyWalletModel @@@@@@@@@@@");
      print(url);
      print("@@@@@@@@@@@ ProductApplyWalletModel @@@@@@@@@@@");

      request.fields.addAll({"cart_id": cartId.toString()});
      http.StreamedResponse response = await request.send();

      dynamic responseData = await response.stream.bytesToString();

      print("@@@@@@@@@@@ ProductApplyWalletModel @@@@@@@@@@@");
      print(responseData);
      print("@@@@@@@@@@@ ProductApplyWalletModel @@@@@@@@@@@");

      if (response.statusCode == httpsCode_200 ||
          response.statusCode == httpsCode_201) {
        _productApplyWalletModel = ApiResponse.fromJson(
          jsonDecode(responseData),
        );
      } else if (response.statusCode == httpsCode_404 ||
          response.statusCode == httpsCode_401) {
        // BasePrefs.clearPrefs().then((value) => Get.offAll(const LoadingPage()));
        _productApplyWalletModel.requestStatus = RequestStatus.unauthorized;
      } else if (response.statusCode == httpsCode_500) {
        _productApplyWalletModel.requestStatus = RequestStatus.server;
      }
    } on Error catch (e) {
      _firebaseService.firebaseDioError(
        apiCall: "ProductApplyWalletModel",
        code: "401|404",
        userId: userId,
        message: e.toString(),
      );
    } on SocketException catch (e) {
      _firebaseService.firebaseSocketException(
        apiCall: "ProductApplyWalletModel",
        userId: userId,
        message: e.message,
      );
      throw Failure(e.message);
    } on FormatException catch (e) {
      _firebaseService.firebaseFormatException(
        apiCall: "ProductApplyWalletModel",
        userId: userId,
        message: e.message,
      );
      throw Failure(e.message);
    } on HttpException catch (e) {
      _firebaseService.firebaseHttpException(
        apiCall: "ProductApplyWalletModel",
        userId: userId,
        message: e.message,
      );
      throw Failure(e.message);
    }
    return _productApplyWalletModel;
  }

  Future<ApiResponse> getProductRemoveWalletModelApi({
    required int cartId,
  }) async {
    try {
      String url = GetBaseUrl + GetDomainUrl + productRemoveWallet;
      var request = http.MultipartRequest('POST', Uri.parse(url));
      request.headers.addAll(await authHeader());
      print("@@@@@@@@@@@ ProductRemoveWalletModel @@@@@@@@@@@");
      print(url);
      print("@@@@@@@@@@@ ProductRemoveWalletModel @@@@@@@@@@@");
      request.fields.addAll({"cart_id": cartId.toString()});
      http.StreamedResponse response = await request.send();
      dynamic responseData = await response.stream.bytesToString();
      print("@@@@@@@@@@@ ProductRemoveWalletModel @@@@@@@@@@@");
      print(responseData);
      print("@@@@@@@@@@@ ProductRemoveWalletModel @@@@@@@@@@@");
      if (response.statusCode == httpsCode_200 ||
          response.statusCode == httpsCode_201) {
        _productRemoveWalletModel = ApiResponse.fromJson(
          jsonDecode(responseData),
        );
      } else if (response.statusCode == httpsCode_404 ||
          response.statusCode == httpsCode_401) {
        // BasePrefs.clearPrefs().then((value) => Get.offAll(const LoadingPage()));
        _productRemoveWalletModel.requestStatus = RequestStatus.unauthorized;
      } else if (response.statusCode == httpsCode_500) {
        _productRemoveWalletModel.requestStatus = RequestStatus.server;
      }
    } on Error catch (e) {
      _firebaseService.firebaseDioError(
        apiCall: "ProductRemoveWalletModel",
        code: "401|404",
        userId: userId,
        message: e.toString(),
      );
    } on SocketException catch (e) {
      _firebaseService.firebaseSocketException(
        apiCall: "ProductRemoveWalletModel",
        userId: userId,
        message: e.message,
      );
      throw Failure(e.message);
    } on FormatException catch (e) {
      _firebaseService.firebaseFormatException(
        apiCall: "ProductRemoveWalletModel",
        userId: userId,
        message: e.message,
      );
      throw Failure(e.message);
    } on HttpException catch (e) {
      _firebaseService.firebaseHttpException(
        apiCall: "ProductRemoveWalletModel",
        userId: userId,
        message: e.message,
      );
      throw Failure(e.message);
    }
    return _productRemoveWalletModel;
  }

  Future<ApiResponse> deleteUser({required int customerId}) async {
    try {
      String url = GetBaseUrl + GetDomainUrl + deleteUserAccount;
      var request = http.MultipartRequest('POST', Uri.parse(url));
      request.headers.addAll(await authHeader());
      print("@@@@@@@@@@@ deleteUser @@@@@@@@@@@");
      print(url);
      print("@@@@@@@@@@@ deleteUser @@@@@@@@@@@");

      request.fields.addAll({"user_id": customerId.toString()});
      http.StreamedResponse response = await request.send();

      dynamic responseData = await response.stream.bytesToString();

      print("@@@@@@@@@@@ deleteUser @@@@@@@@@@@");
      print(responseData);
      print("@@@@@@@@@@@ deleteUser @@@@@@@@@@@");

      if (response.statusCode == httpsCode_200 ||
          response.statusCode == httpsCode_201) {
        _deleteUser = ApiResponse.fromJson(jsonDecode(responseData));
      } else if (response.statusCode == httpsCode_404 ||
          response.statusCode == httpsCode_401) {
        // BasePrefs.clearPrefs().then((value) => Get.offAll(const LoadingPage()));
        _deleteUser.requestStatus = RequestStatus.unauthorized;
      } else if (response.statusCode == httpsCode_500) {
        _deleteUser.requestStatus = RequestStatus.server;
      }
    } on Error catch (e) {
      _firebaseService.firebaseDioError(
        apiCall: "deleteUser",
        code: "401|404",
        userId: userId,
        message: e.toString(),
      );
    } on SocketException catch (e) {
      _firebaseService.firebaseSocketException(
        apiCall: "deleteUser",
        userId: userId,
        message: e.message,
      );
      throw Failure(e.message);
    } on FormatException catch (e) {
      _firebaseService.firebaseFormatException(
        apiCall: "deleteUser",
        userId: userId,
        message: e.message,
      );
      throw Failure(e.message);
    } on HttpException catch (e) {
      _firebaseService.firebaseHttpException(
        apiCall: "deleteUser",
        userId: userId,
        message: e.message,
      );
      throw Failure(e.message);
    }
    return _deleteUser;
  }

  Future<ApiResponse> sentfreeChatEmail({
    required String customerId,
    required String userName,
    required String message,
    required String sessionId,
    required String astrologerId,
    required String astrologerName,
  }) async {
    try {
      String url = GetBaseUrl + GetDomainUrl + freeChatEmail;
      var request = http.MultipartRequest('POST', Uri.parse(url));
      request.headers.addAll(await authHeader());
      print("@@@@@@@@@@@ sentfreeChatEmail @@@@@@@@@@@");
      print(url);
      print("@@@@@@@@@@@ sentfreeChatEmail @@@@@@@@@@@");
      request.fields.addAll({
        "userName": userName,
        "message": message,
        "sessionId": sessionId,
        "customerId": customerId,
        "astrologerName": astrologerName,
        "astrologerId": astrologerId,
      });
      http.StreamedResponse response = await request.send();

      dynamic responseData = await response.stream.bytesToString();

      print("@@@@@@@@@@@ sentfreeChatEmail @@@@@@@@@@@");
      print(responseData);
      print("@@@@@@@@@@@ sentfreeChatEmail @@@@@@@@@@@");

      if (response.statusCode == httpsCode_200 ||
          response.statusCode == httpsCode_201) {
        _freeChatEmail = ApiResponse.fromJson(jsonDecode(responseData));
      } else if (response.statusCode == httpsCode_404 ||
          response.statusCode == httpsCode_401) {
        // BasePrefs.clearPrefs().then((value) => Get.offAll(const LoadingPage()));
        _freeChatEmail.requestStatus = RequestStatus.unauthorized;
      } else if (response.statusCode == httpsCode_500) {
        _freeChatEmail.requestStatus = RequestStatus.server;
      }
    } on Error catch (e) {
      _firebaseService.firebaseDioError(
        apiCall: "sentfreeChatEmail",
        code: "401|404",
        userId: userId,
        message: e.toString(),
      );
    } on SocketException catch (e) {
      _firebaseService.firebaseSocketException(
        apiCall: "sentfreeChatEmail",
        userId: userId,
        message: e.message,
      );
      throw Failure(e.message);
    } on FormatException catch (e) {
      _firebaseService.firebaseFormatException(
        apiCall: "sentfreeChatEmail",
        userId: userId,
        message: e.message,
      );
      throw Failure(e.message);
    } on HttpException catch (e) {
      _firebaseService.firebaseHttpException(
        apiCall: "sentfreeChatEmail",
        userId: userId,
        message: e.message,
      );
      throw Failure(e.message);
    }
    return _freeChatEmail;
  }

  Future<ApiResponse> sendSupportChatEmail({
    required String customerId,
    required String userName,
    required String message,
    required String sessionId,
    required String supportId,
    required String supportName,
  }) async {
    try {
      String url = GetBaseUrl + GetDomainUrl + supportChatEmail;
      var request = http.MultipartRequest('POST', Uri.parse(url));
      request.headers.addAll(await authHeader());
      print("@@@@@@@@@@@ sentfreeChatEmail @@@@@@@@@@@");
      print(url);
      print("@@@@@@@@@@@ sentfreeChatEmail @@@@@@@@@@@");
      request.fields.addAll({
        "userName": userName,
        "message": message,
        "sessionId": sessionId,
        "customerId": customerId,
        "supportName": supportName,
        "supportId": supportId,
      });
      http.StreamedResponse response = await request.send();
      dynamic responseData = await response.stream.bytesToString();
      print("@@@@@@@@@@@ sentfreeChatEmail @@@@@@@@@@@");
      print(responseData);
      print("@@@@@@@@@@@ sentfreeChatEmail @@@@@@@@@@@");
      if (response.statusCode == httpsCode_200 ||
          response.statusCode == httpsCode_201) {
        _supportChatEmail = ApiResponse.fromJson(jsonDecode(responseData));
      } else if (response.statusCode == httpsCode_404 ||
          response.statusCode == httpsCode_401) {
        // BasePrefs.clearPrefs().then((value) => Get.offAll(const LoadingPage()));
        _supportChatEmail.requestStatus = RequestStatus.unauthorized;
      } else if (response.statusCode == httpsCode_500) {
        _supportChatEmail.requestStatus = RequestStatus.server;
      }
    } on Error catch (e) {
      _firebaseService.firebaseDioError(
        apiCall: "sendSupportChatEmail",
        code: "401|404",
        userId: userId,
        message: e.toString(),
      );
    } on SocketException catch (e) {
      _firebaseService.firebaseSocketException(
        apiCall: "sendSupportChatEmail",
        userId: userId,
        message: e.message,
      );
      throw Failure(e.message);
    } on FormatException catch (e) {
      _firebaseService.firebaseFormatException(
        apiCall: "sendSupportChatEmail",
        userId: userId,
        message: e.message,
      );
      throw Failure(e.message);
    } on HttpException catch (e) {
      _firebaseService.firebaseHttpException(
        apiCall: "sendSupportChatEmail",
        userId: userId,
        message: e.message,
      );
      throw Failure(e.message);
    }

    return _supportChatEmail;
  }
}
