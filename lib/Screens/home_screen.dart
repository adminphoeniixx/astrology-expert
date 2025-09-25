// ignore_for_file: deprecated_member_use

import 'dart:async';
import 'package:astro_partner_app/Screens/tabs/account_tab.dart';
import 'package:astro_partner_app/Screens/tabs/earning_tab.dart';
import 'package:astro_partner_app/Screens/tabs/session_tab.dart';
import 'package:astro_partner_app/Screens/auth/edit_profile_screen.dart';
import 'package:astro_partner_app/constants/colors_const.dart';
import 'package:astro_partner_app/constants/fonts_const.dart';
import 'package:astro_partner_app/constants/images_const.dart';
import 'package:astro_partner_app/controllers/user_controller.dart';

import 'package:astro_partner_app/widgets/app_widget.dart';
import 'package:astro_partner_app/widgets/tab_item.dart';

import 'package:flutter/material.dart';

import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';

class MyHomePage extends StatefulWidget {
  final TabItem tabItem;
  const MyHomePage({super.key, this.tabItem = TabItem.sessionsTab});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  StreamSubscription? _sub;
  GlobalKey bottomNavigationKey = GlobalKey();
  final UserController _userController = Get.put(UserController());

  final _navigatorKeys = {
    // TabItem.homeTab: GlobalKey<NavigatorState>(),
    TabItem.sessionsTab: GlobalKey<NavigatorState>(),
    TabItem.earnigTab: GlobalKey<NavigatorState>(),
    TabItem.profileTab: GlobalKey<NavigatorState>(),
  };
  TabItem selectedIndex = TabItem.sessionsTab;
  dynamic userIdValue;
  @override
  void initState() {
    _userController.getUserProfile();

    setState(() {
      selectedIndex = widget.tabItem;
    });

    super.initState();
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  void _selectTab(TabItem tabItem) {
    if (selectedIndex == tabItem) {
      // Pop to first route if we're already on the tab
      _navigatorKeys[tabItem]!.currentState!.popUntil((route) => route.isFirst);
    } else {
      setState(() => selectedIndex = tabItem);
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        final isFirstRouteInCurrentTab = !await _navigatorKeys[selectedIndex]!
            .currentState!
            .maybePop();
        if (isFirstRouteInCurrentTab) {
          if (selectedIndex != TabItem.sessionsTab) {
            _selectTab(TabItem.sessionsTab);
            return false;
          }
        }
        return isFirstRouteInCurrentTab;
      },
      child: Scaffold(
        body: FutureBuilder(
          future: _buildSelectedTabScreen(),
          builder: (BuildContext context, AsyncSnapshot snapshot) {
            return snapshot.data ?? const SizedBox(); // Show the fetched page
          },
        ),
        // drawer: const Drawer(width: double.infinity, child: MainDrower()),
        bottomNavigationBar: BottomNavigationBar(
          elevation: 1,
          type: BottomNavigationBarType.fixed,
          backgroundColor: const Color(0xFF221d25), // Yaha add karo
          items: TabItem.values.map((tabItem) {
            return _buildItem(
              tabItem,
              selectedIndex == tabItem ? primaryColor : textColorSecondary,
            );
          }).toList(),
          onTap: (index) => _selectTab(TabItem.values[index]),
          currentIndex: selectedIndex.index,
          selectedItemColor: white,
          unselectedItemColor: textColorSecondary,
          unselectedLabelStyle: const TextStyle(
            fontFamily: productSans,
            color: textColorSecondary,
            fontSize: 12,
          ),
          selectedLabelStyle: const TextStyle(
            fontFamily: productSans,
            color: white,
            fontSize: 12,
          ),
        ),
      ),
    );
  }

  BottomNavigationBarItem _buildItem(TabItem tabItem, Color iconColor) {
    return BottomNavigationBarItem(
      icon: SvgPicture.asset(
        tabItem.icon!,
        color: iconColor,
        width: 18,
        height: 18,
      ),
      label: tabItem.label!,
    );
  }

  Future<dynamic> _buildSelectedTabScreen() async {
    switch (selectedIndex) {
      // case TabItem.homeTab:
      //   return  Scaffold(extendBodyBehindAppBar: true, body: SizedBox(child: Center(child: text("Home"),),));
      case TabItem.sessionsTab:
        return Scaffold(
          appBar: secondryTabAppBar(title: "Sessions"),
          body: const SessionTab(),
        );

      case TabItem.earnigTab:
        return Scaffold(
          appBar: secondryTabAppBar(title: "Earning"),
          body: const EarningTab(),
        );

      case TabItem.profileTab:
        return Scaffold(appBar: profileTabAppBar(), body: const AccountTab());
    }
  }

  AppBar seconderyAppbarWithSearch({required String title}) {
    return AppBar(
      backgroundColor: const Color(0xFF221d25),
      shadowColor: const Color(0xFF221d25),
      leadingWidth: 0,
      elevation: 0,
      toolbarHeight: 115,
      titleSpacing: 0,
      centerTitle: true,
      title: Column(
        children: [
          const SizedBox(height: 15),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 20),
                child: text(
                  "Products",
                  fontSize: 16.0,
                  fontWeight: FontWeight.w500,
                  textColor: white,
                ),
              ),
              Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      //  changeScreen(context, const AstroMoney());
                    },
                    child: SvgPicture.asset(
                      walletIconSvg,
                      color: white,
                      height: 20,
                      width: 20,
                    ),
                  ),
                  // const SizedBox(width: 16),
                  // GestureDetector(
                  //   onTap: () {
                  //     changeScreen(context, const NotificationPage());
                  //   },
                  //   child: SvgPicture.asset(
                  //     notificationIcon,
                  //     color: black,
                  //     height: 20,
                  //     width: 20,
                  //   ),
                  // ),
                  const SizedBox(width: 20),
                ],
              ),
            ],
          ),
          const SizedBox(height: 15),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Align(
              alignment: Alignment.bottomCenter,
              child: GestureDetector(
                onTap: () {
                  // showSearch(
                  //   context: context,
                  //   delegate: ProductSearchDelegate(),
                  // );
                },
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: textColorSecondary),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: SizedBox(
                    width: MediaQuery.sizeOf(context).width,
                    height: 40,
                    child: Padding(
                      padding: const EdgeInsets.only(right: 150),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          const SizedBox(width: 10),
                          SvgPicture.asset(searchIcon),
                          const SizedBox(width: 10),
                          text(
                            "Search Products...",
                            fontSize: 14.0,
                            fontWeight: FontWeight.w300,
                            textColor: textColorSecondary,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  AppBar secondryTabAppBar({String title = ''}) {
    return AppBar(
      backgroundColor: const Color(0xFF221d25),
      leadingWidth: 30,
      toolbarHeight: 60,
      shadowColor: const Color(0xFF221d25),
      elevation: 0,
      centerTitle: true,
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          text(
            title,
            fontSize: 16.0,
            textColor: white,
            fontWeight: FontWeight.w600,
            fontFamily: productSans,
          ),
        ],
      ),
      // leading: GestureDetector(
      //   onTap: () {
      //     Navigator.of(context!).pop();
      //   },
      //   child: Container(
      //       margin: const EdgeInsets.only(left: 20, top: 10, bottom: 10),
      //       height: 47,
      //       width: 47,
      //       decoration: BoxDecoration(
      //           borderRadius: const BorderRadius.all(Radius.circular(8.0)),
      //           border: Border.all(color: primaryColor, width: 1.5)),
      //       child: const Center(
      //           child: Icon(
      //         Icons.arrow_back_ios_new_rounded,
      //         color: primaryColor,
      //         size: 20,
      //         weight: 20,
      //       ))),
      // ),
    );
  }

  AppBar profileTabAppBar({BuildContext? context}) {
    return AppBar(
      backgroundColor: const Color(0xFF221d25),
      leadingWidth: 0,
      toolbarHeight: 100,
      shadowColor: const Color(0xFF221d25),
      elevation: 0,
      titleSpacing: 0.0,
      title: Obx(() {
        if (_userController.isGetProfileModelLoding.value) {
          return const SizedBox();
        } else {
          return Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // SizedBox(
                //     height: 48,
                //     width: 48,
                //     child: SvgPicture.asset(profileIcon,
                //         color: textColorPrimary)),
                // const SizedBox(width: 20),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    text(
                      _userController.getprofile!.data!.name ?? "",
                      fontSize: 16.0,
                      fontFamily: productSans,
                      fontWeight: FontWeight.w500,
                      textColor: white,
                    ),
                    text(
                      _userController.getprofile!.data!.email ?? "",
                      fontSize: 12.0,
                      fontWeight: FontWeight.w400,
                      textColor: white,
                      fontFamily: productSans,
                    ),
                    text(
                      _userController.getprofile!.data!.mobile ?? "",
                      fontSize: 12.0,
                      fontWeight: FontWeight.w500,
                      fontFamily: productSans,
                      textColor: white,
                    ),
                  ],
                ),
                const Spacer(),
                GestureDetector(
                  onTap: () {
                    Get.to(const EditProfile());
                  },
                  child: SvgPicture.asset(edit2Icon, color: white),
                ),
              ],
            ),
          );
        }
      }),
    );
  }
}
