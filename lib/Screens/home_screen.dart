// ignore_for_file: deprecated_member_use

import 'dart:async';
import 'package:astro_partner_app/Screens/tabs/account_tab.dart';
import 'package:astro_partner_app/Screens/tabs/earning_tab.dart';
import 'package:astro_partner_app/Screens/tabs/review_tab.dart';
import 'package:astro_partner_app/Screens/tabs/session_tab.dart';
import 'package:astro_partner_app/constants/colors_const.dart';
import 'package:astro_partner_app/constants/fonts_const.dart';
import 'package:astro_partner_app/controllers/home_controller.dart';
import 'package:astro_partner_app/controllers/user_controller.dart';

import 'package:astro_partner_app/widgets/app_widget.dart';
import 'package:astro_partner_app/widgets/tab_item.dart';

import 'package:flutter/material.dart';

import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';

class MyHomePage extends StatefulWidget {
  final TabItem tabItem;
  const MyHomePage({super.key, this.tabItem = TabItem.sessionsTab});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  StreamSubscription? _sub;
  GlobalKey bottomNavigationKey = GlobalKey();
  final HomeController _homeController = Get.put(HomeController());

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
    _loadProfileData();
    setState(() {
      selectedIndex = widget.tabItem;
    });

    super.initState();
  }

  bool isOnline = false; // initial switch state

  Future<void> _loadProfileData() async {
    try {
      await _userController.getUserProfile();
      final availableValue =
          _userController.getprofile?.data?.availableForFreeChat ?? "no";

      // ✅ Normalize the string (removes spaces and handles any case)
      final normalized = availableValue.trim().toLowerCase();

      setState(() {
        isOnline = normalized == "yes";
      });

      debugPrint(
        "✅ Loaded availability: '$availableValue' → normalized: '$normalized' → isOnline: $isOnline",
      );
    } catch (e) {
      debugPrint("❌ Error loading profile: $e");
    }
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
          appBar: secondryTabAppBar(title: "Earnings"),
          body: const EarningTab(),
        );
      case TabItem.reviewTab:
        return Scaffold(
          appBar: secondryTabAppBar(title: "Reviews"),
          body: const ReviewTab(),
        );

      case TabItem.profileTab:
        return Scaffold(appBar: profileTabAppBar(), body: const AccountTab());
    }
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

  AppBar profileTabAppBar() {
    return AppBar(
      backgroundColor: const Color(0xFF221d25),
      leadingWidth: 0,
      toolbarHeight: 100,
      shadowColor: const Color(0xFF221d25),
      elevation: 0,
      titleSpacing: 0.0,
      title: Obx(() {
        if (_userController.isGetProfileModelLoding.value) {
          // 🔹 Show shimmer while loading
          return Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Shimmer.fromColors(
                  baseColor: Colors.grey[700]!,
                  highlightColor: Colors.grey[500]!,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(width: 120, height: 16, color: Colors.white),
                      const SizedBox(height: 6),
                      Container(width: 180, height: 14, color: Colors.white),
                      const SizedBox(height: 6),
                      Container(width: 100, height: 14, color: Colors.white),
                    ],
                  ),
                ),
                Shimmer.fromColors(
                  baseColor: Colors.grey[700]!,
                  highlightColor: Colors.grey[500]!,
                  child: Column(
                    children: [
                      Container(width: 40, height: 20, color: Colors.white),
                      const SizedBox(height: 4),
                      Container(width: 60, height: 10, color: Colors.white),
                    ],
                  ),
                ),
              ],
            ),
          );
        }

        // 🔹 When data is loaded
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// 👤 Left Side: Profile Info
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

              /// 🔘 Right Side: Switch + Status
              Column(
                children: [
                  Switch(
                    value: isOnline,
                    onChanged: (val) async {
                      setState(() {
                        isOnline = val;
                      });

                      final available = val ? "Yes" : "No";
                      try {
                        await _homeController.expertOnOffModelData(
                          available: available,
                        );

                        // ✅ Refresh user profile after API success
                        await _userController.getUserProfile();

                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            backgroundColor: val
                                ? Colors.greenAccent
                                : Colors.redAccent,
                            content: Text(
                              val
                                  ? 'You are now Available for chat'
                                  : 'You are now Not Available for chat',
                              style: const TextStyle(
                                color: Colors.black,
                                fontFamily: productSans,
                              ),
                            ),
                            duration: const Duration(seconds: 1),
                          ),
                        );
                      } catch (e) {
                        setState(() => isOnline = !val); // rollback on error
                        debugPrint("❌ Error updating status: $e");
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            backgroundColor: Colors.redAccent,
                            content: Text(
                              "Failed to update availability",
                              style: TextStyle(fontFamily: productSans),
                            ),
                          ),
                        );
                      }
                    },
                    activeColor: Colors.greenAccent,
                    inactiveThumbColor: Colors.grey,
                    inactiveTrackColor: Colors.white24,
                  ),

                  Text(
                    isOnline ? "Available" : "Not Available",
                    style: TextStyle(
                      color: isOnline ? Colors.greenAccent : Colors.redAccent,
                      fontSize: 10,
                      fontFamily: productSans,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      }),
    );
  }
}
