import 'package:astro_partner_app/Screens/splesh_screen.dart';
import 'package:astro_partner_app/constants/colors_const.dart';
import 'package:astro_partner_app/constants/fonts_const.dart';
import 'package:flutter/material.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';
import 'package:upgrader/upgrader.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      builder: (BuildContext context, Widget? widget) {
        // ErrorWidget.builder = (FlutterErrorDetails errorDetails) {
        //   return circularProgress();
        // };
        // Wrap the widget with UpgradeAlert
        return UpgradeAlert(child: widget!);
      },
      routes: {  '/': (context) => const SpleshScreen(),},
      title: 'Vedam Roots Experts',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: productSans,
        colorScheme: ColorScheme.fromSeed(seedColor: white),
        useMaterial3: true,
      ),
    );
  }
}
