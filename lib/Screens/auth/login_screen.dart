// ignore_for_file: use_build_context_synchronously

import 'package:astro_partner_app/Screens/auth/otp_screen.dart';
import 'package:astro_partner_app/Screens/auth/register_screen.dart';
import 'package:astro_partner_app/constants/colors_const.dart';
import 'package:astro_partner_app/constants/images_const.dart';
import 'package:astro_partner_app/controllers/user_controller.dart';
import 'package:astro_partner_app/helper/screen_navigator.dart';
import 'package:astro_partner_app/model/api_response.dart';
import 'package:astro_partner_app/utils/enum.dart';
import 'package:astro_partner_app/utils/loading.dart';
import 'package:astro_partner_app/widgets/app_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final UserController _userController = Get.put(UserController());
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
                        Obx(() {
                          if (_userController.isLoginOtpLoding.value) {
                            return circularProgress();
                          } else {
                            return appBotton(
                              txt: "Get OTP",
                              txtColor: black,
                              onPressed: () async {
                                if (_formKey.currentState!.validate() &&
                                    phoneNumber.isNotEmpty) {
                                  _userController.setOtpStatus(OtpFor.login);
                                  ApiResponse loginModel = await _userController
                                      .getLoginWithOtp(
                                        mobile: phoneNumber,
                                        screen: 'login',
                                      );
                                  if (loginModel.status!) {
                                    changeScreen(
                                      context,
                                      OTPVerifyScreen(phoneNumber: phoneNumber),
                                    );
                                  } else if (loginModel.status == false) {
                                    changeScreen(
                                      context,
                                      const RegisterScreen(),
                                    );
                                  } else {
                                    showToast(context, msg: loginModel.message);
                                  }
                                } else {
                                  showToast(context, msg: "somthing wrong..");
                                }
                              },
                            );
                          }
                        }),

                        const SizedBox(height: 95),
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
