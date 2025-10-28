import 'package:astro_partner_app/Screens/auth/edit_profile_screen.dart';
import 'package:astro_partner_app/Screens/splesh_screen.dart';
import 'package:astro_partner_app/constants/colors_const.dart';
import 'package:astro_partner_app/constants/fonts_const.dart';
import 'package:astro_partner_app/constants/images_const.dart';
import 'package:astro_partner_app/controllers/user_controller.dart';
import 'package:astro_partner_app/helper/local_storage.dart';
import 'package:astro_partner_app/helper/screen_navigator.dart';
import 'package:astro_partner_app/model/auth/getprofile_model.dart';
import 'package:astro_partner_app/widgets/about_us.dart';
import 'package:astro_partner_app/widgets/app_widget.dart';
import 'package:astro_partner_app/widgets/contact_us.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AccountTab extends StatefulWidget {
  const AccountTab({super.key});

  @override
  State<AccountTab> createState() => _AccountTabState();
}

class _AccountTabState extends State<AccountTab> {
  List<String> drowerItems = [
    'Profile',
    'About Us',
    'Contact Us',
    'Delete account',
  ];
  final UserController _userController = Get.put(UserController());

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Stack(
          children: [
            SizedBox(
              height: double.infinity,
              width: double.infinity,
              child: Image.asset(appBg, fit: BoxFit.cover),
            ),
            SingleChildScrollView(
              physics: const ClampingScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    const SizedBox(height: 30),

                    bankDetailsBox(_userController.getprofile!.data!),
                    const SizedBox(height: 30),

                    /// ✅ Drawer Options
                    Column(
                      children: List.generate(
                        drowerItems.length,
                        (index) => GestureDetector(
                          onTap: () async {
                            switch (index) {
                              case 0:
                                changeScreen(context, const EditProfile());
                                break;
                              case 1:
                                changeScreen(context, const AboutUsScreen());
                                break;
                              case 2:
                                changeScreen(context, const ContactUsScreen());
                                break;
                              case 3:
                                deleteAccountDialog();
                                break;
                              default:
                            }
                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Container(
                                  height: 15,
                                  width: 2,
                                  color: const Color(0xFF221d25),
                                ),
                                const SizedBox(width: 15),
                                text(
                                  drowerItems[index],
                                  textColor:
                                      drowerItems[index] == "Delete account"
                                      ? Colors.red
                                      : textLightColorPrimary,
                                  fontSize: 16.0,
                                  fontWeight: FontWeight.w400,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    /// ✅ Bottom Info + Logout
                    Row(
                      children: [
                        SizedBox(
                          width: 200,
                          child: text(
                            "Powered by: Vedam Roots Co.\nVersion 162.325.32",
                            textColor: logoutBorderColor,
                            fontWeight: FontWeight.w500,
                            fontSize: 12.0,
                          ),
                        ),
                        const Spacer(),
                        GestureDetector(
                          onTap: () {
                            logoutNow();
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              border: Border.all(color: logoutBorderColor),
                              borderRadius: BorderRadius.circular(30),
                            ),
                            child: Center(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                  vertical: 10,
                                ),
                                child: text(
                                  "Logout",
                                  textColor: logoutBorderColor,
                                  fontWeight: FontWeight.w500,
                                  fontSize: 14.0,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 60),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// ✅ Bank Details Widget
  Widget bankDetailsBox(ProfileData data) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF221d25),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Bank Details",
            style: TextStyle(
              fontFamily: productSans,
              fontSize: 16.0,
              fontWeight: FontWeight.w600,
              color: white,
            ),
          ),
          const SizedBox(height: 12),
          bankDetailRow("Account Holder", data.clientName ?? "NA"),
          bankDetailRow("Bank Name", data.bankName ?? "NA"),
          bankDetailRow("Account Number", data.accountNumber ?? "NA"),
          bankDetailRow("IFSC Code", data.ifscCode ?? "NA"),
        ],
      ),
    );
  }

  Widget bankDetailRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 13.0,
              color: textColorSecondary,
              fontFamily: productSans,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 13.0,
              color: white,
              fontFamily: productSans,
            ),
          ),
        ],
      ),
    );
  }

  /// 🟥 Delete Account Dialog
  deleteAccountDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF221d25),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: text(
          "Delete Account",
          fontWeight: FontWeight.w500,
          fontSize: 18.0,
          fontFamily: productSans,
          textColor: Colors.redAccent,
        ),
        content: text(
          "This action is permanent and cannot be undone.\nAre you sure you want to delete your account?",
          textColor: white,
          fontFamily: productSans,
          fontSize: 15.0,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: text(
              "Cancel",
              textColor: textLightColorPrimary,
              fontFamily: productSans,
              fontSize: 14.0,
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            onPressed: () async {
              await _userController.deleteAccount().then((value) {
                BasePrefs.clearPrefs();
                Get.offAll(const SpleshScreen());
              });
            },
            child: text(
              "Delete",
              textColor: white,
              fontFamily: productSans,
              fontSize: 14.0,
            ),
          ),
        ],
      ),
    );
  }

  /// ✅ Logout Function
  logoutNow() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF221d25),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: text(
          "Confirm Logout",
          fontWeight: FontWeight.bold,
          fontSize: 18.0,
          fontFamily: productSans,
          textColor: white,
        ),
        content: text(
          "Are you sure you want to logout?",
          fontSize: 16.0,
          fontFamily: productSans,
          textColor: white,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: text(
              "Cancel",
              textColor: textColorSecondary,
              fontSize: 16.0,
              fontFamily: productSans,
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: black),
            onPressed: () {
              BasePrefs.clearPrefs();
              Get.offAll(const SpleshScreen());
            },
            child: text(
              "Logout",
              textColor: white,
              fontSize: 16.0,
              fontFamily: productSans,
            ),
          ),
        ],
      ),
    );
  }
}
