// ignore_for_file: use_build_context_synchronously

import 'package:astro_partner_app/Screens/auth/register_otp_screen.dart';
import 'package:astro_partner_app/constants/colors_const.dart';
import 'package:astro_partner_app/constants/images_const.dart';
import 'package:astro_partner_app/controllers/loader_controller.dart';
import 'package:astro_partner_app/controllers/user_controller.dart';
import 'package:astro_partner_app/helper/screen_navigator.dart';
import 'package:astro_partner_app/utils/enum.dart';
import 'package:astro_partner_app/utils/loading.dart';
import 'package:astro_partner_app/widgets/app_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';

class RegisterScreen extends StatefulWidget {
  final String phoneNumber;

  const RegisterScreen({super.key, required this.phoneNumber});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final UserController _userController = Get.put(UserController());
  final LoaderController _loaderController = Get.put(LoaderController());

  bool isLoading = false;

  TextEditingController emailController = TextEditingController();
  TextEditingController nameController = TextEditingController();

  bool isValidEmail(String email) {
    final emailRegex = RegExp(
      r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$",
    );
    return emailRegex.hasMatch(email);
  }

  bool _validateFields() {
    if (nameController.text.isEmpty) {
      showToast(context, msg: "Please enter your full name");
      return false;
    }
    if (!isValidEmail(emailController.text.trim())) {
      showToast(context, msg: "Please enter a valid email address");
      return false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          /// BACKGROUND IMAGE
          SizedBox(
            height: double.infinity,
            width: double.infinity,
            child: Image.asset(appBg, fit: BoxFit.fill),
          ),

          /// MAIN CONTENT SCROLL (placed BEFORE back button)
          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Column(
                children: [
                  const SizedBox(height: 120),

                  SizedBox(
                    height: MediaQuery.sizeOf(context).height * 0.3,
                    child: Image.asset(startImage),
                  ),
                  const SizedBox(height: 10.0),

                  text(
                    "Signup",
                    textColor: primaryColor,
                    fontSize: 26.0,
                    fontWeight: FontWeight.w500,
                  ),
                  const SizedBox(height: 5.0),

                  text(
                    "Please provide your details",
                    textColor: textLightColorPrimary,
                    fontSize: 16.0,
                    fontWeight: FontWeight.w300,
                  ),
                  const SizedBox(height: 30.0),

                  CustomTextFormField(
                    icon: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                      child: SvgPicture.asset(userIcon),
                    ),
                    mController: nameController,
                    text: "Full name",
                    textColor: textLightColorSecondary,
                  ),
                  const SizedBox(height: 15.0),

                  CustomTextFormField(
                    icon: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                      child: SvgPicture.asset(emailIcon),
                    ),
                    mController: emailController,
                    text: "Your email ID",
                    textColor: textLightColorSecondary,
                  ),
                  const SizedBox(height: 30.0),

                  isLoading
                      ? circularProgress()
                      : appBotton(
                          txtColor: black,
                          txt: "Continue",
                          onPressed: () async {
                            if (!_validateFields()) return;

                            setState(() => isLoading = true);

                            try {
                              _userController.setOtpStatus(OtpFor.signUp);

                              final registerModel = await _userController
                                  .getRegisterWithOtp(
                                    email: emailController.text.trim(),
                                    mobile: widget.phoneNumber,
                                    name: nameController.text.trim(),
                                  );

                              _loaderController.setLoadingStatus(false);

                              if (registerModel.status != true) {
                                showToast(
                                  context,
                                  msg: registerModel.message ?? "",
                                );
                              } else {
                                changeScreen(
                                  context,
                                  RegisterOtpScreen(
                                    phoneNumber: widget.phoneNumber,
                                  ),
                                );
                              }
                            } catch (e) {
                              print("ERROR: $e");
                            } finally {
                              setState(() => isLoading = false);
                            }
                          },
                        ),

                  const SizedBox(height: 35),
                ],
              ),
            ),
          ),

          /// BACK BUTTON (placed LAST so it's on TOP)
          Positioned(
            top: 45,
            left: 15,
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () {
                Navigator.of(context).pop();
              },
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
