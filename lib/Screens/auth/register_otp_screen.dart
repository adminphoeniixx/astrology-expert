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

class RegisterOtpScreen extends StatefulWidget {
  final String phoneNumber;

  const RegisterOtpScreen({super.key, required this.phoneNumber});

  @override
  State<RegisterOtpScreen> createState() => _RegisterOtpScreenState();
}

class _RegisterOtpScreenState extends State<RegisterOtpScreen> {
  int secondsRemaining = 59;
  bool enableResend = false;
  Timer? timer;
  final TextEditingController textEditingController = TextEditingController();
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final UserController _userController = Get.put(UserController());

  String pinCode = "";

  @override
  void initState() {
    super.initState();
    startTimer();
  }

  void startTimer() {
    timer = Timer.periodic(const Duration(seconds: 1), (timer) {
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
    textEditingController.dispose();
    timer?.cancel();
    Future.delayed(Duration.zero, () {
      SystemChannels.textInput.invokeMethod('TextInput.hide');
    });
    super.dispose();
  }

  void onSubmit() async {
    if (pinCode.isEmpty) {
      showToast(context, msg: ENTER_OTP);
      return;
    }

    try {
      final value = await _userController.registerVerifyOtp(
        context: context,
        otp: pinCode,
        mobile: widget.phoneNumber,
      );

      if (value.status == true) {
        // ✅ OTP verified successfully
        await _userController.getUserProfile();

        goToHomePage(value, const MyHomePage());
      } else {
        showToast(context, msg: value.message ?? "Invalid OTP");
      }
    } catch (e) {
      debugPrint("❌ Error verifying OTP: $e");
      showToast(context, msg: "Something went wrong. Please try again.");
    }
  }

  void onResendOTP() async {
    await _userController.resendOtp(mobile: widget.phoneNumber);
    setState(() {
      enableResend = false;
      secondsRemaining = 180;
    });
    startTimer();
  }

  void goToHomePage(SignUpModel value, Widget widget) {
    showToast(context, msg: value.message!);
    if (value.expert!.id != null || value.status!) {
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
          SizedBox(
            height: double.infinity,
            width: double.infinity,
            child: Image.asset(appBg, fit: BoxFit.fill),
          ),
          SingleChildScrollView(
            physics: const NeverScrollableScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  // color: const Color(0xFF0e0e0e),
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: MediaQuery.sizeOf(context).width,
                        height: 170,
                      ),
                      Container(
                        constraints: BoxConstraints(
                          maxHeight: MediaQuery.of(context).size.height * 0.4,
                          maxWidth: MediaQuery.of(context).size.width * 0.6,
                        ),
                        child: Image.asset(startImage, fit: BoxFit.contain),
                      ),
                      const SizedBox(height: 20),
                      text(
                        "Verify Phone Number",
                        textColor: primaryColor,
                        fontSize: 26.0,
                        fontWeight: FontWeight.w500,
                      ),
                      const SizedBox(height: 10),
                      Text.rich(
                        TextSpan(
                          children: [
                            const TextSpan(
                              text: 'Enter OTP sent on ',
                              style: TextStyle(
                                fontWeight: FontWeight.w300,
                                color: textLightColorPrimary,
                                fontFamily: productSans,
                                fontSize: 16,
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
                      const SizedBox(height: 20),
                      OtpPinField(
                        onSubmit: (String pin) {
                          setState(() {
                            pinCode = pin;
                          });
                        },
                        textInputAction: TextInputAction.done,
                        maxLength: 4,
                        cursorColor: primaryColor,
                        highlightBorder: true,
                        otpPinFieldStyle: const OtpPinFieldStyle(
                          textStyle: TextStyle(
                            color: primeryLightColor,
                            fontFamily: productSans,
                          ),
                          fieldPadding: 20,
                          activeFieldBorderColor: primaryColor,
                          filledFieldBorderColor: primaryColor,
                          defaultFieldBorderColor: primaryColor,
                        ),
                        otpPinFieldDecoration:
                            OtpPinFieldDecoration.defaultPinBoxDecoration,
                        onChange: (String pin) {
                          setState(() {
                            pinCode = pin;
                          });
                        },
                      ),
                      const SizedBox(height: 10),
                      Text.rich(
                        TextSpan(
                          children: [
                            TextSpan(
                              text: enableResend
                                  ? 'Your OTP code has expired'
                                  : 'OTP Code expires in ',
                              style: const TextStyle(
                                fontWeight: FontWeight.w300,
                                color: textLightColorPrimary,
                                fontFamily: productSans,
                                fontSize: 14,
                              ),
                            ),
                            if (!enableResend)
                              TextSpan(
                                text: ' $secondsRemaining Seconds',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w300,
                                  color: primaryColor,
                                  fontSize: 14.0,
                                  fontFamily: productSans,
                                ),
                              ),
                          ],
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 10),
                      enableResend
                          ? appBotton(
                              width: 200,
                              height: 48,
                              txtColor: primaryColor,
                              // ignore: deprecated_member_use
                              buttonColor: primaryColor.withOpacity(0.2),
                              txt: "Resend OTP",
                              onPressed: onResendOTP,
                            )
                          : Obx(() {
                              if (_userController.isVerifyOtpLoding.value) {
                                return circularProgress();
                              } else {
                                return SizedBox(
                                  width: 270,
                                  child: appBotton(
                                    txtColor: black,
                                    txt: "Submit Now",
                                    onPressed: onSubmit,
                                  ),
                                );
                              }
                            }),
                      const SizedBox(height: 80),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
