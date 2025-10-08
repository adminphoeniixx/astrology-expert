import 'package:astro_partner_app/Screens/auth/edit_profile_screen.dart';
import 'package:astro_partner_app/Screens/splesh_screen.dart';
import 'package:astro_partner_app/constants/colors_const.dart';
import 'package:astro_partner_app/constants/fonts_const.dart';
import 'package:astro_partner_app/constants/images_const.dart';
import 'package:astro_partner_app/controllers/user_controller.dart';
import 'package:astro_partner_app/helper/local_storage.dart';
import 'package:astro_partner_app/helper/screen_navigator.dart';
import 'package:astro_partner_app/widgets/app_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class AccountTab extends StatefulWidget {
  const AccountTab({super.key});
  @override
  State<AccountTab> createState() => _AccountTabState();
}

class _AccountTabState extends State<AccountTab> {
  // final UserController _userController = Get.put(UserController());

  List<String> drowerItems = [
    'Profile',
    'About Us',
    'Refund & Return policy',
    'Shipping & Delivery Policy',
    'Disclaimer',
    'Cancellation',
    'Terms & Conditions Policy',
    'Contact Us',
    'Privacy Policy',
    // 'Delete Account',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                  const SizedBox(height: 10),
                  Column(
                    children: List.generate(
                      drowerItems.length,
                      (index) => GestureDetector(
                        onTap: () async {
                          switch (index) {
                            case 0:
                              changeScreen(context, const EditProfile());
                              break;
                            // case 1:
                            //   changeScreen(context, const PaymentPage());
                            //   break;
                            // case 2:
                            //   changeScreen(context, const SessionsPage());
                            //   break;
                            // case 3:
                            //   changeScreen(
                            //       context,
                            //       const ChatScreen(
                            //         astroName: "Chat",
                            //         reciverId: 2,
                            //         roomId: 2,
                            //         senderId: 4,
                            //         subCollection: "message",
                            //         timmer: "0",
                            //       ));
                            //   break;
                            case 1:
                              // changeScreen(
                              //     context, const ServiceOrdersListScreen());
                              break;
                            case 2:
                              // changeScreen(
                              //     context, const ProductOrdersListScreen());
                              break;
                            case 3:
                              //   changeScreen(context, const AstroMoney());
                              break;

                            case 4:
                              // changeScreen(
                              //     context, const AstrologyInfoScreen());
                              break;
                            case 5:
                              //  changeScreen(context, FaqScreen());
                              break;

                            case 6:
                              // Navigator.push(
                              //     context,
                              //     MaterialPageRoute(
                              //       builder: (context) =>
                              //           const RefundPolocyScreen(),
                              //     ));
                              break;
                            case 7:
                              // Navigator.push(
                              //     context,
                              //     MaterialPageRoute(
                              //       builder: (context) =>
                              //           const ShippingAndDeliveryPolocyScreen(),
                              //     ));
                              break;
                            case 8:
                              // Navigator.push(
                              //     context,
                              //     MaterialPageRoute(
                              //       builder: (context) =>
                              //           const DisclaimerPolocyScreen(),
                              //     ));
                              break;
                            case 9:
                              // Navigator.push(
                              //     context,
                              //     MaterialPageRoute(
                              //       builder: (context) =>
                              //           const CancellationPolocyScreen(),
                              //     ));
                              break;
                            case 10:
                              // Navigator.push(
                              //     context,
                              //     MaterialPageRoute(
                              //       builder: (context) =>
                              //           const TermsPolocyScreen(),
                              //     ));
                              break;

                            case 11:
                              // Navigator.push(
                              //     context,
                              //     MaterialPageRoute(
                              //       builder: (context) =>
                              //           const ContactUsPolocyScreen(),
                              //     ));
                              break;

                            case 12:
                              // changeScreen(
                              //     context,
                              //     const PrivacyPolocyScreen(
                              //         title: "Privacy Policy"));
                              break;

                            case 13:
                              shareAppUrl();
                              break;

                            // case 14:
                            //   showDeleteAccountDialog(context);
                            //   break;

                            default:
                          }
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Container(height: 15, width: 2, color: black),
                              const SizedBox(width: 15),
                              text(
                                drowerItems[index],
                                textColor: textLightColorPrimary,
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
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () async {
                          const url =
                              'https://www.facebook.com/astrologymatrix/ ';
                          if (await canLaunchUrl(Uri.parse(url))) {
                            await launchUrl(Uri.parse(url));
                          } else {
                            // Handle error if the URL can't be opened
                            debugPrint("Could not launch $url");
                          }
                        },
                        child: SvgPicture.asset(
                          facebookIcon,
                          height: 25,
                          width: 25,
                        ),
                      ),
                      const SizedBox(width: 10),
                      GestureDetector(
                        onTap: () async {
                          const url =
                              'https://www.instagram.com/astrologymatrix/';
                          if (await canLaunchUrl(Uri.parse(url))) {
                            await launchUrl(Uri.parse(url));
                          } else {
                            // Handle error if the URL can't be opened
                            debugPrint("Could not launch $url");
                          }
                        },
                        child: SvgPicture.asset(
                          instaIcon,
                          height: 25,
                          width: 25,
                        ),
                      ),
                      const SizedBox(width: 10),
                      GestureDetector(
                        onTap: () async {
                          const url =
                              'https://www.youtube.com/@Astrology.Matrix/';
                          if (await canLaunchUrl(Uri.parse(url))) {
                            await launchUrl(Uri.parse(url));
                          } else {
                            // Handle error if the URL can't be opened
                            debugPrint("Could not launch $url");
                          }
                        },
                        child: SvgPicture.asset(
                          youtubeIcon,
                          height: 25,
                          width: 25,
                        ),
                      ),
                      const SizedBox(width: 10),
                      GestureDetector(
                        onTap: () async {
                          const url = 'https://twitter.com/astrologymatrix/';
                          if (await canLaunchUrl(Uri.parse(url))) {
                            await launchUrl(Uri.parse(url));
                          } else {
                            // Handle error if the URL can't be opened
                            debugPrint("Could not launch $url");
                          }
                        },
                        child: SvgPicture.asset(xIcon, height: 25, width: 25),
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
                  const SizedBox(height: 10),
                  Align(
                    alignment: Alignment.bottomLeft,
                    child: SizedBox(
                      width: 200,
                      child: text(
                        "Powered by: Vedam roots experts \n Version 162.325.32",
                        textColor: logoutBorderColor,
                        fontWeight: FontWeight.w500,
                        fontSize: 12.0,
                      ),
                    ),
                  ),
                  const SizedBox(height: 50),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void shareAppUrl() {
    String appUrl =
        'https://play.google.com/store/apps/details?id=com.app.astrologymatrix'; // Replace with your app's URL
    Share.share(appUrl, subject: 'Check out this app!');
  }

  logoutNow() async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF221d25),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
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
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: text(
                "Cancel",
                textColor: textColorSecondary,
                fontSize: 16.0,
                fontFamily: productSans,
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: black, // Red color for logout button
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: () {
                // Proceed with logout
                BasePrefs.clearPrefs().then((value) {
                  Get.offAll(const SpleshScreen());
                });
              },
              child: text(
                "Logout",
                fontSize: 16.0,
                textColor: white,
                fontFamily: productSans,
              ),
            ),
          ],
        );
      },
    );
  }
}
