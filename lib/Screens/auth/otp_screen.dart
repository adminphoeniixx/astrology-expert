import 'dart:async';
import 'package:astro_partner_app/Screens/home_screen.dart';
import 'package:astro_partner_app/constants/colors_const.dart';
import 'package:astro_partner_app/constants/fonts_const.dart';
import 'package:astro_partner_app/constants/images_const.dart';
import 'package:astro_partner_app/constants/string_const.dart';
import 'package:astro_partner_app/controllers/user_controller.dart';
import 'package:astro_partner_app/helper/local_storage.dart';
import 'package:astro_partner_app/helper/screen_navigator.dart';
import 'package:astro_partner_app/model/auth/sinup_model.dart';
import 'package:astro_partner_app/utils/loading.dart';
import 'package:astro_partner_app/widgets/app_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:otp_pin_field/otp_pin_field.dart';

class OTPVerifyScreen extends StatefulWidget {
  final String phoneNumber;

  const OTPVerifyScreen({super.key, required this.phoneNumber});

  @override
  State<OTPVerifyScreen> createState() => _OTPVerifyScreenState();
}

class _OTPVerifyScreenState extends State<OTPVerifyScreen> {
  int secondsRemaining = 59;
  bool enableResend = false;
  Timer? timer;

  final UserController _userController = Get.put(UserController());
  final GlobalKey<OtpPinFieldState> otpKey = GlobalKey<OtpPinFieldState>();

  String pinCode = "";

  @override
  void initState() {
    super.initState();
    startTimer();
  }

  void startTimer() {
    timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;

      setState(() {
        if (secondsRemaining > 0) {
          secondsRemaining--;
        } else {
          enableResend = true;
          timer.cancel();
        }
      });
    });
  }

  @override
  void dispose() {
    timer?.cancel();
    SystemChannels.textInput.invokeMethod('TextInput.hide');
    super.dispose();
  }

  Future<void> onSubmit() async {
    if (pinCode.length != 4) {
      showToast(context, msg: ENTER_OTP);
      return;
    }

    try {
      final SignUpModel result = await _userController.fetchVerifyOtp(
        context: context,
        otp: pinCode,
        mobile: widget.phoneNumber,
      );

      if (result.status == true) {
        await _userController.getUserProfile();
        goToHomePage(result, const MyHomePage());
      } else {
        showToast(context, msg: result.message ?? "Invalid OTP");
      }
    } catch (e) {
      showToast(context, msg: "Something went wrong. Please try again.");
    }
  }

  void onResendOTP() async {
    await _userController.resendOtp(mobile: widget.phoneNumber);

    // clear OTP UI
    otpKey.currentState?.clearOtp();
    pinCode = "";

    setState(() {
      enableResend = false;
      secondsRemaining = 59;
    });

    startTimer();
  }

  void goToHomePage(SignUpModel value, Widget widget) {
    if (value.message != null) {
      showToast(context, msg: value.message!);
    }

    if (value.expert?.id != null || value.status == true) {
      BasePrefs.saveData(userId, value.expert!.id!);
      BasePrefs.saveData(accessToken, value.accessToken);
      changeToNewScreen(context, widget, "/main");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          /// BACKGROUND
          SizedBox(
            height: double.infinity,
            width: double.infinity,
            child: Image.asset(appBg, fit: BoxFit.fill),
          ),

          /// MAIN CONTENT
          SingleChildScrollView(
            physics: const NeverScrollableScrollPhysics(),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
              //  const SizedBox(height: 120.0),

                SizedBox(width: MediaQuery.sizeOf(context).width, height: 170),
                Container(
                  constraints: BoxConstraints(
                    maxHeight: MediaQuery.of(context).size.height * 0.4,
                    maxWidth: MediaQuery.of(context).size.width * 0.6,
                  ),
                  child: Image.asset(startImage, fit: BoxFit.contain),
                ),
                const SizedBox(height: 20.0),

                text(
                  "Verify Phone Number",
                  textColor: primaryColor,
                  fontSize: 26.0,
                  fontWeight: FontWeight.w500,
                ),

                const SizedBox(height: 10.0),

                Text.rich(
                  TextSpan(
                    children: [
                      const TextSpan(
                        text: "Enter OTP sent on ",
                        style: TextStyle(
                          fontWeight: FontWeight.w300,
                          color: textLightColorPrimary,
                          fontFamily: productSans,
                          fontSize: 16.0,
                        ),
                      ),
                      TextSpan(
                        text: widget.phoneNumber,
                        style: const TextStyle(
                          fontWeight: FontWeight.w300,
                          color: primaryColor,
                          fontSize: 16.0,
                          fontFamily: productSans,
                        ),
                      ),
                    ],
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 20.0),

                /// OTP FIELD — FIXED
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 30.0),
                  child: OtpPinField(
                    key: otpKey,
                    maxLength: 4,
                    cursorColor: primaryColor,
                    highlightBorder: true,

                    onChange: (pin) => setState(() => pinCode = pin),

                    onSubmit: (pin) {
                      setState(() => pinCode = pin);
                      onSubmit();
                    },

                    otpPinFieldStyle: const OtpPinFieldStyle(
                      textStyle: TextStyle(
                        color: primeryLightColor,
                        fontFamily: productSans,
                        fontSize: 20.0,
                      ),
                      fieldPadding: 20.0,
                      activeFieldBorderColor: primaryColor,
                      filledFieldBorderColor: primaryColor,
                      defaultFieldBorderColor: primaryColor,
                    ),
                    otpPinFieldDecoration:
                        OtpPinFieldDecoration.defaultPinBoxDecoration,
                  ),
                ),

                const SizedBox(height: 15.0),

                /// TIMER / RESEND TEXT
                Text(
                  enableResend
                      ? "Your OTP has expired"
                      : "OTP expires in $secondsRemaining seconds",
                  style: const TextStyle(
                    color: textLightColorPrimary,
                    fontSize: 14,
                    fontFamily: productSans,
                  ),
                ),

                const SizedBox(height: 20.0),

                /// RESEND OR SUBMIT BTN
                enableResend
                    ? appBotton(
                        width: 200.0,
                        height: 48.0,
                        txtColor: primaryColor,
                        buttonColor: primaryColor.withOpacity(0.2),
                        txt: "Resend OTP",
                        onPressed: onResendOTP,
                      )
                    : Obx(() {
                        return _userController.isVerifyOtpLoding.value
                            ? circularProgress()
                            : SizedBox(
                                width: 270.0,
                                child: appBotton(
                                  txtColor: black,
                                  txt: "Submit Now",
                                  onPressed: onSubmit,
                                ),
                              );
                      }),

                const SizedBox(height: 80.0),
              ],
            ),
          ),

          /// BACK BUTTON – WORKING
          Positioned(
            top: 45,
            left: 15,
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => Navigator.of(context).pop(),
              child: Container(
                padding: const EdgeInsets.all(10.0),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.arrow_back_ios, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
