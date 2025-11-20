import 'package:astro_partner_app/model/api_response.dart';
import 'package:astro_partner_app/model/auth/getprofile_model.dart';
import 'package:astro_partner_app/model/auth/sinup_model.dart';
import 'package:astro_partner_app/services/web_api_services.dart';
import 'package:astro_partner_app/utils/enum.dart';
import 'package:astro_partner_app/utils/request_failure.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

class UserController extends GetxController {
  WebApiServices? _webApiServices;
  OtpFor _otpFor = OtpFor.signUp;
  OtpFor get otpFor => _otpFor;

  late String? autoValidationError;
  late String? deviceToken;
  late String? deviceModel;
  late String? deviceVersion;
  late ApiResponse _apiResponse;

  ApiResponse? get authResponse => _authResponse;
  ApiResponse? _authResponse;
  SignUpModel? get signUpModel => _signUpModel;
  SignUpModel? _signUpModel;
  GetProfileModel? get getprofile => _getprofile;
  GetProfileModel? _getprofile;
  late int stateCode;
  late Failure _failure;
  Failure get failure => _failure;

  @override
  void onInit() {
    _apiResponse = ApiResponse();
    _webApiServices = WebApiServices();
    autoValidationError = "";
    super.onInit();
  }

  void setOtpStatus(OtpFor otpFor) {
    _otpFor = otpFor;
  }

  Future<ApiResponse> resendOtp({required String mobile}) async {
    try {
      _apiResponse.requestStatus = RequestStatus.loading;

      _apiResponse = await _webApiServices!.getResendOtp(mobile: mobile);
    } on Failure catch (e) {
      _apiResponse.requestStatus = RequestStatus.failure;
      _setFailure(e);
    }
    return _apiResponse;
  }

  var isLoginOtpLoding = false.obs;

  Future<ApiResponse> getLoginWithOtp({
    required String screen,
    required String mobile,
  }) async {
    try {
      isLoginOtpLoding(true);
      _authResponse = await _webApiServices!.getLoginWithOtp(
        mobile: mobile,
        screen: screen,
      );
    } on Failure catch (e) {
      isLoginOtpLoding(false);

      _setFailure(e);
    }
    isLoginOtpLoding(false);
    return _authResponse!;
  }

  void _setFailure(Failure failure) {
    _failure = failure;
  }

  SignUpModel? get verifyOtp => _verifyOtp;
  SignUpModel? _verifyOtp;

  var isVerifyOtpLoding = false.obs;

  Future<SignUpModel> fetchVerifyOtp({
    required String otp,
    required String mobile,
    required BuildContext context,
  }) async {
    try {
      isVerifyOtpLoding(true);

      _verifyOtp = SignUpModel(); // reset model

      _verifyOtp = await _webApiServices!.getVerifyLoginWithOtp(
        mobile: mobile,
        otp: otp,
        context: context,
      );
    } on Failure catch (e) {
      _setFailure(e);
    } finally {
      isVerifyOtpLoding(false);
    }

    return _verifyOtp!;
  }

  var isGetProfileModelLoding = false.obs;

  Future<GetProfileModel> getUserProfile() async {
    try {
      isGetProfileModelLoding(true);
      _getprofile = await _webApiServices!.getUserProfile();
    } on Failure catch (e) {
      isGetProfileModelLoding(false);
      _setFailure(e);
    }
    isGetProfileModelLoding(false);
    return _getprofile!;
  }

  set validationError(String msg) {
    autoValidationError = msg;
  }

  var isDeleteAccount = false.obs;
  ApiResponse deleteAccountResponse = ApiResponse();
  Future<ApiResponse> deleteAccount() async {
    try {
      isDeleteAccount(true);
      deleteAccountResponse = await _webApiServices!.deleteAccountAPI();
    } on Failure catch (e) {
      isDeleteAccount(false);

      _setFailure(e);
    }
    isDeleteAccount(false);
    return deleteAccountResponse;
  }

  SignUpModel? _registerModel;
  var isRegisterOtpLoding = false.obs;

  Future<SignUpModel> getRegisterWithOtp({
    required String mobile,
    required String name,
    required String email,
  }) async {
    try {
      isRegisterOtpLoding(true);

      _registerModel = SignUpModel();

      _registerModel = await _webApiServices!.getRegisterWithOtp(
        email: email,
        mobile: mobile,
        name: name,
      );

      print("API Status: ${_registerModel!.status}");
      print("API Message: ${_registerModel!.message}");
    } on Failure catch (e) {
      _setFailure(e);
    } finally {
      isRegisterOtpLoding(false);
    }

    return _registerModel!;
  }

  var isRegisterVerifyOtpLoding = false.obs;
  Future<SignUpModel> registerVerifyOtp({
    required String otp,
    required String mobile,
    required BuildContext context,
  }) async {
    try {
      isRegisterOtpLoding(true);

      _registerModel = SignUpModel();

      _registerModel = await _webApiServices!.getRegisterVerifyOtp(
        mobile: mobile,
        otp: otp,
        context: context,
      );
    } on Failure catch (e) {
      _setFailure(e);
    } finally {
      isRegisterVerifyOtpLoding(false);
    }

    return _registerModel!;
  }
}
