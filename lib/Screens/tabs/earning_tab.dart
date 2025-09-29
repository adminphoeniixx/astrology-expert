import 'package:astro_partner_app/Screens/item_payment_view.dart';
import 'package:astro_partner_app/constants/colors_const.dart';
import 'package:astro_partner_app/constants/fonts_const.dart';
import 'package:astro_partner_app/constants/images_const.dart';
import 'package:astro_partner_app/controllers/home_controller.dart';
import 'package:astro_partner_app/services/web_request_constants.dart';
import 'package:astro_partner_app/widgets/app_widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class EarningTab extends StatefulWidget {
  const EarningTab({super.key});

  @override
  State<EarningTab> createState() => _EarningTabState();
}

class _EarningTabState extends State<EarningTab> {
  final HomeController _homeController = Get.put(HomeController());
  final ScrollController _scrollmainController = ScrollController();

  @override
  void initState() {
    _homeController.fetchEarningListData();
    _scrollmainController.addListener(() {
      if (_scrollmainController.position.pixels ==
          _scrollmainController.position.maxScrollExtent) {
        if (_homeController.nextPageUrlforEarningListModel.value != '') {
          _homeController.fetchEarningListData(
            pageUrl: _homeController.nextPageUrl.value.replaceAll(http, https),
            isPaginatHit: true,
          );
        }
      }
    });
    super.initState();
  }

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
          const SizedBox(height: 20),
          Obx(() {
            if (_homeController.isEarningListModelLoding.value) {
              return circularProgress();
            } else {
              return _homeController.earningListData.isEmpty
                  ? Padding(
                      padding: const EdgeInsets.only(top: 320),
                      child: Center(
                        child: text(
                          "No earning are available.",
                          fontFamily: productSans,
                          textColor: white,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    )
                  : Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 15),
                      child: ListView.builder(
                        padding: const EdgeInsets.only(top: 20),
                        itemCount: _homeController.earningListData.length,
                        itemBuilder: (BuildContext context, int index) {
                          if (index == _homeController.sessionListData.length) {
                            return _homeController
                                        .nextPageUrlforCommingSession
                                        .value !=
                                    ""
                                ? const Padding(
                                    padding: EdgeInsets.all(8.0),
                                    child: CupertinoActivityIndicator(),
                                  )
                                : const SizedBox();
                          } else {
                            return ItemPaymentView(
                              earningData: _homeController
                                  .earningListData[index], // <-- pass data here
                            );
                          }
                        },
                      ),
                    );
            }
          }),
        ],
      ),
    );
  }
}
