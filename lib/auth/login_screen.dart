// ignore_for_file: use_build_context_synchronously

import 'package:astro_partner_app/auth/otp_screen.dart';
import 'package:astro_partner_app/constants/colors_const.dart';
import 'package:astro_partner_app/constants/images_const.dart';
import 'package:astro_partner_app/helper/screen_navigator.dart';
import 'package:astro_partner_app/widgets/app_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  // final UserController _userController = Get.put(UserController());
  // final LoaderController _loaderController = Get.put(LoaderController());
  TextEditingController mobileController = TextEditingController();
  String phoneNumber = "";
  @override
  void dispose() {
    Future.delayed(Duration.zero, () {
      SystemChannels.textInput.invokeMethod('TextInput.hide');
    });
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // backgroundColor: black,
      body: Stack(
        children: [
          SizedBox(
            height: double.infinity,
            width: double.infinity,
            child: Image.asset(appBg, fit: BoxFit.fill),
          ),
          SingleChildScrollView(
            physics: const NeverScrollableScrollPhysics(),
            child: Column(crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Form(
                    key: _formKey,
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
                          "Login",
                          textColor: primaryColor,
                          fontSize: 26.0,
                          fontWeight: FontWeight.w500,
                        ),
                        const SizedBox(height: 50),
                        // text("Please Provide your mobile number",
                        //     textColor: textLightColorPrimary,
                        //     fontSize: 16.0,
                        //     fontWeight: FontWeight.w300),
                        // const SizedBox(height: 40),
                        CustomNumberTextFormField(
                          icon: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: SvgPicture.asset(phoneIcon),
                          ),
                          mController: mobileController,
                          text: "Enter Phone number",
                          textColor: textLightColorSecondary,
                          onChanged: (phone) {
                            setState(() {
                              phoneNumber = phone.completeNumber;
                            });
                          },
                        ),
                        const SizedBox(height: 25),
                        // Obx(() {
                        //   if (_userController.isLoginOtpLoding.value) {
                        //     return circularProgress();
                        //   } else {
                        //     return
                        //     appBotton(
                        //         txt: "Get OTP",
                        //         txtColor: black,
                        //         onPressed: () async {
                        //           if (_formKey.currentState!.validate() &&
                        //               phoneNumber.isNotEmpty) {
                        //             _userController.setOtpStatus(OtpFor.login);
                        //             ApiResponse signUpModel =
                        //                 await _userController.getLoginWithOtp(
                        //                     mobile: phoneNumber,
                        //                     screen: 'login');
                        //             if (signUpModel.status!) {
                        //               changeScreen(
                        //                   context,
                        //                   OTPVerifyScreen(
                        //                       phoneNumber: phoneNumber));
                        //             } else {
                        //               showToast(context,
                        //                   msg: signUpModel.message);
                        //             }
                        //           } else {
                        //             showToast(
                        //               context,
                        //               msg: "somthing wrong..",
                        //             );
                        //           }
                        //         });
                        //   }
                        // }
                        // ),
                        appBotton(
                          txt: "Get OTP",
                          txtColor: black,
                          onPressed: () async {
                            changeScreen(
                                    context,
                                    OTPVerifyScreen(
                                        phoneNumber: phoneNumber));
                            // if (_formKey.currentState!.validate() &&
                            //     phoneNumber.isNotEmpty) {
                            //   _userController.setOtpStatus(OtpFor.login);
                            //   ApiResponse signUpModel =
                            //       await _userController.getLoginWithOtp(
                            //           mobile: phoneNumber,
                            //           screen: 'login');
                            //   if (signUpModel.status!) {
                            //     changeScreen(
                            //         context,
                            //         OTPVerifyScreen(
                            //             phoneNumber: phoneNumber));
                            //   } else {
                            //     showToast(context,
                            //         msg: signUpModel.message);
                            //   }
                            // } else {
                            //   showToast(
                            //     context,
                            //     msg: "somthing wrong..",
                            //   );
                            // }
                          },
                        ),
                        const SizedBox(height: 16),
                        // GestureDetector(
                        //   onTap: () {
                        //     changeScreenReplacement(
                        //         context, const RegisterScreen());
                        //   },
                        //   child: text("Sign Up",
                        //       textColor: primaryColor,
                        //       fontSize: 16.0,
                        //       fontWeight: FontWeight.w500),
                        // ),
                        const SizedBox(height: 80),
                      ],
                    ),
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
