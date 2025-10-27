import 'package:astro_partner_app/constants/colors_const.dart';
import 'package:astro_partner_app/constants/fonts_const.dart';
import 'package:astro_partner_app/constants/images_const.dart';
import 'package:astro_partner_app/widgets/app_widget.dart';
import 'package:flutter/material.dart';

class AboutUsScreen extends StatefulWidget {
  const AboutUsScreen({super.key});
  @override
  State<AboutUsScreen> createState() => _AboutUsScreenState();
}

class _AboutUsScreenState extends State<AboutUsScreen> {
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
              "About Us",
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
            child: SingleChildScrollView(
              child: RichText(
                text: const TextSpan(
                  style: TextStyle(
                    fontFamily: productSans,
                    fontWeight: FontWeight.normal,
                    color: white,
                    fontSize: 16,
                  ),
                  children: [
                    // TextSpan(
                    //   text: 'What Is Astrology?\n\n',
                    //   style: TextStyle(
                    //     fontFamily: productSans,
                    //     fontWeight: FontWeight.bold,
                    //   ),
                    // ),
                    TextSpan(
                      text:
                          'Vedam Roots offers a unique and spiritual service dedicated to providing Virtual Puja (Virtual Worship) for Dosh Nivaran, a sacred practice that helps individuals overcome obstacles and restore balance in their lives. Our virtual worship services are performed by experienced priests and spiritual experts, ensuring that your prayers reach the divine with utmost sincerity and precision. Whether you are facing personal challenges, relationship issues, or professional hurdles, our personalized guidance offer tailored remedies and solutions.\n\n',
                    ),

                    TextSpan(
                      text:
                          'You can experience the transformative power of traditional rituals from the comfort of your home, helping to remove negative energies and bring positivity into your life. We combine ancient wisdom with modern technology to offer you spiritual support, so you can find peace, clarity, and solutions to your day to day problems.\n\n',
                    ),
                    // TextSpan(
                    //   text: 'How To Calculate Zodiac or Astrology Sign?\n\n',
                    //   style: TextStyle(
                    //     fontFamily: productSans,
                    //     fontWeight: FontWeight.bold,
                    //   ),
                    // ),
                    // TextSpan(
                    //   text:
                    //       'To calculate an individual’s zodiac or astrology sign, astrologers look at the placement of the Sun at the time of their birth. This crucial step in free astrology predictions helps reveal insights into an individual’s character and life path.\n\n',
                    // ),
                    // TextSpan(
                    //   text: 'Are Astrology Predictions True?\n\n',
                    //   style: TextStyle(
                    //     fontFamily: productSans,
                    //     fontWeight: FontWeight.bold,
                    //   ),
                    // ),
                    // TextSpan(
                    //   text:
                    //       'There is a common misconception surrounding astrology’s ability to predict the future. Astrology does not provide an exact glimpse of the future like a crystal ball. Instead, it analyses the movement of the planets across different zodiac signs and their influence on the individual. Based on these calculations, astrologers can offer guidance on potential life events, whether positive or challenging. It serves as a tool for guidance rather than a precise fortune-telling mechanism.\n\n',
                    // ),
                    // TextSpan(
                    //   text: 'How To Consult Online?\n\n',
                    //   style: TextStyle(
                    //     fontFamily: productSans,
                    //     fontWeight: FontWeight.bold,
                    //   ),
                    // ),
                    // TextSpan(
                    //   text:
                    //       'If you seek to consult online, Astrology Matrix is a trusted one-stop solution for all astrology-related matters. We have expert astrologers, tarot readers, numerologists, palmists & vastu specialists who can provide online guidance. You can contact us at +91 8384023652 or email at astrologymatrix@gmail.com, to seek assistance with life’s many problems.\n\n',
                    // ),
                    // TextSpan(
                    //   text: 'What Are The Benefits Of Astrology Matrix’s Consultation Services?\n\n',
                    //   style: TextStyle(
                    //     fontFamily: productSans,
                    //     fontWeight: FontWeight.bold,
                    //   ),
                    // ),
                    // TextSpan(
                    //   text:
                    //       'Astrology Matrix’s astrology consultation services offer several benefits. As a new user, you can access accurate predictions for free, making it a pocket-friendly option. The platform’s astrologers provide relevant insights into your future, offering suggestions on how to make the most of the planetary placements in your astrology chart. Top experts on the platform offer detailed guidance on various life issues, including relationships, career, family, finances, and more.\n\n',
                    // ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
