// ignore_for_file: use_build_context_synchronously

import 'package:astro_partner_app/Screens/auth/register_otp_screen.dart';
import 'package:astro_partner_app/constants/colors_const.dart';
import 'package:astro_partner_app/constants/images_const.dart';
import 'package:astro_partner_app/controllers/loader_controller.dart';
import 'package:astro_partner_app/controllers/user_controller.dart';
import 'package:astro_partner_app/helper/screen_navigator.dart';
import 'package:astro_partner_app/model/auth/sinup_model.dart';
import 'package:astro_partner_app/utils/enum.dart';
import 'package:astro_partner_app/utils/loading.dart';
import 'package:astro_partner_app/widgets/app_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  bool cbRemember = false;
  bool isHide = true;
  String phoneNumber = "";

  //  StateListItem? selectedItem;
  final UserController _userController = Get.put(UserController());
  final LoaderController _loaderController = Get.put(LoaderController());
  List<String> typeNeg = ["Male", "Female"];
  bool isLoading = false;

  final _formKey = GlobalKey<FormState>();
  bool checkFormValidation = false;
  TextEditingController emailController = TextEditingController();
  TextEditingController mobileController = TextEditingController();

  TextEditingController dobController = TextEditingController();
  TextEditingController nameController = TextEditingController();
  TextEditingController genderController = TextEditingController();

  void showGenderSelectionDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: textColorPrimary,
          contentPadding: EdgeInsets.zero,
          content: SizedBox(
            width: MediaQuery.sizeOf(context).width,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: typeNeg.map((gender) {
                return ListTile(
                  title: text(gender, textColor: white),
                  onTap: () {
                    setState(() => genderController.text = gender);
                    Navigator.pop(context);
                  },
                );
              }).toList(),
            ),
          ),
        );
      },
    );
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
            physics: const ClampingScrollPhysics(),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Form(
                    key: _formKey,
                    // autovalidateMode: checkFormValidation
                    //     ? AutovalidateMode.onUserInteraction
                    //     : AutovalidateMode.onUnfocus,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: MediaQuery.sizeOf(context).width,
                          height: 80,
                        ),
                        Container(
                          constraints: BoxConstraints(
                            maxHeight: MediaQuery.of(context).size.height * 0.4,
                            maxWidth: MediaQuery.of(context).size.width * 0.6,
                          ),
                          child: Image.asset(startImage, fit: BoxFit.contain),
                        ),
                        const SizedBox(height: 16),
                        text(
                          "Signup",
                          textColor: primaryColor,
                          fontSize: 26.0,
                          fontWeight: FontWeight.w500,
                        ),
                        const SizedBox(height: 10),
                        text(
                          "Please provide your details",
                          textColor: textLightColorPrimary,
                          fontSize: 16.0,
                          fontWeight: FontWeight.w300,
                        ),
                        const SizedBox(height: 40),
                        CustomTextFormField(
                          icon: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: SvgPicture.asset(userIcon),
                          ),
                          mController: nameController,
                          text: "Full name",
                          textColor: textLightColorSecondary,
                        ),
                        const SizedBox(height: 15),

                        CustomTextFormField(
                          icon: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: SvgPicture.asset(emailIcon),
                          ),
                          mController: emailController,
                          text: "Your email ID",
                          textColor: textLightColorSecondary,
                        ),
                        const SizedBox(height: 15),

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
                        // const SizedBox(height: 15),
                        // CustomTextFormField(
                        //   icon: Padding(
                        //     padding: const EdgeInsets.symmetric(horizontal: 20),
                        //     child: SvgPicture.asset(genderIcon),
                        //   ),
                        //   mController: genderController,
                        //   text: "Gender",
                        //   readOnly: true,
                        //   onTap: () {
                        //     showGenderSelectionDialog(context);
                        //   },
                        //   textColor: textLightColorSecondary,
                        // ),
                        const SizedBox(height: 28),
                        // Obx(() {
                        //   if (_userController.isRegisterOtpLoding.value) {
                        //     return circularProgress();
                        //   } else {
                        //     return ;
                        //   }
                        // }),
                        isLoading
                            ? circularProgress()
                            : appBotton(
                                txtColor: black,
                                txt: "Continue",
                                onPressed: () async {
                                  setState(() {
                                    checkFormValidation = true;
                                  });

                                  if (_formKey.currentState!.validate()) {
                                    try {
                                      setState(() => isLoading = true);

                                      _userController.setOtpStatus(
                                        OtpFor.signUp,
                                      );
                                      SignUpModel
                                      signUpModel = await _userController
                                          .getRegisterWithOtp(
                                            email: emailController.text,
                                            mobile: phoneNumber,
                                            name: nameController.text,
                                            //  gender: genderController.text,
                                          );

                                      // Stop loader
                                      _loaderController.setLoadingStatus(false);

                                      // Prevent crash: safe null check
                                      if (signUpModel.status == true) {
                                        changeScreen(
                                          context,
                                          RegisterOtpScreen(
                                            phoneNumber: phoneNumber,
                                          ),
                                        );
                                      } else {
                                        showToast(
                                          context,
                                          msg:
                                              signUpModel.message ??
                                              "Something went wrong",
                                        );
                                      }
                                    } catch (e) {
                                      print("ERROR: $e");
                                    } finally {
                                      setState(() => isLoading = false);
                                      _loaderController.setLoadingStatus(false);
                                    }
                                  } else {
                                    showToast(
                                      context,
                                      msg: "Please fill all the details first.",
                                    );
                                  }
                                },
                              ),
                        const SizedBox(height: 35),
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

  OutlineInputBorder borderWidget() {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(30.0),
      borderSide: const BorderSide(color: white, width: 1.5),
    );
  }
}
