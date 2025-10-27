import 'package:astro_partner_app/constants/colors_const.dart';
import 'package:astro_partner_app/constants/fonts_const.dart';
import 'package:astro_partner_app/constants/images_const.dart';
import 'package:astro_partner_app/widgets/app_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class ContactUsScreen extends StatefulWidget {
  const ContactUsScreen({super.key});

  @override
  State<ContactUsScreen> createState() => _ContactUsScreenState();
}

class _ContactUsScreenState extends State<ContactUsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF221d25),
        leadingWidth: 30,
        toolbarHeight: 60,
        shadowColor: const Color(0xFF221d25),
        elevation: 0,
        iconTheme: const IconThemeData(color: white),
        centerTitle: true,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            text(
              "Contact Us",
              fontSize: 16.0,
              textColor: white,
              fontWeight: FontWeight.w600,
              fontFamily: productSans,
            ),
          ],
        ),
      ),
      body: Stack(
        children: [
          SizedBox(
            height: double.infinity,
            width: double.infinity,
            child: Image.asset(appBg, fit: BoxFit.fill),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ListTile(
                //   leading: SvgPicture.asset(
                //     emailIcon,
                //     color: primaryColor,
                //   ),
                //   title: text('info@astrologymatrix.in',
                //       fontFamily: productSans, textColor: white),
                // ),
                // const Divider(),
                ListTile(
                  leading: SvgPicture.asset(emailIcon, color: primaryColor),
                  title: text(
                    'nitin@vedamroots.com',
                    fontFamily: productSans,
                    textColor: white,
                  ),
                ),
                // const Divider(),

                ListTile(
                  leading: SvgPicture.asset(callIcon, color: primaryColor),
                  title: text(
                    '+91 8860616130',
                    fontFamily: productSans,
                    textColor: white,
                  ),
                ),
                // const Divider(),
                ListTile(
                  leading: SvgPicture.asset(locationIcon, color: primaryColor),
                  title: text(
                    'Address: B1256 Palam Vihar Gurugram - 122017',
                    fontFamily: productSans,
                    textColor: white,
                  ),
                ),
                // const Divider(),
                // ListTile(
                //   leading: SvgPicture.asset(
                //     panCardIcon,
                //     color: primaryColor,
                //     height: 18,
                //   ),
                //   title: text(
                //     'Pan Card No:',
                //     fontFamily: productSans,
                //     textColor: white,
                //   ),
                // ),
                // const Divider(),
                // ListTile(
                //   leading: SvgPicture.asset(
                //     adharCardIcon,
                //     color: primaryColor,
                //     height: 18,
                //   ),
                //   title: text(
                //     'Addhar Card No:',
                //     fontFamily: productSans,
                //     textColor: white,
                //   ),
                // ),
                // const Divider(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
