import 'package:astro_partner_app/constants/colors_const.dart';
import 'package:astro_partner_app/constants/fonts_const.dart';
import 'package:astro_partner_app/constants/images_const.dart';
import 'package:astro_partner_app/controllers/home_controller.dart';
import 'package:astro_partner_app/widgets/app_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class ReviewTab extends StatefulWidget {
  const ReviewTab({super.key});

  @override
  State<ReviewTab> createState() => _ReviewTabState();
}

class _ReviewTabState extends State<ReviewTab> {
  final HomeController homeController = Get.put(HomeController());
  final DateFormat formatter = DateFormat("dd MMM yyyy");

  @override
  void initState() {
    homeController.fetchReviewListModelData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   backgroundColor: primaryColor,
      //   leadingWidth: 60,
      //   toolbarHeight: 81,
      //   titleSpacing: 25.0,

      //   elevation: 0,

      //   title: text(
      //     "Reviews",
      //     fontSize: 20.0,
      //     fontWeight: FontWeight.w600,
      //     fontFamily: productSans,
      //     textColor: white,
      //   ),
      //   // leading: ,
      //   actions: [
      //     Obx(() {
      //       if (homeController.isRatingDataModelLoding.value) {
      //         return const SizedBox();
      //       } else {
      //         return Row(
      //           crossAxisAlignment: CrossAxisAlignment.center,
      //           mainAxisAlignment: MainAxisAlignment.center,
      //           children: [
      //             Padding(
      //               padding: const EdgeInsets.only(top: 8),
      //               child: SvgPicture.asset(reviewTabIcon, color: white),
      //             ),
      //             text(
      //               "-${avrageOfReview(data: homeController.mRatingDataModel?.data ?? []).toStringAsFixed(2)}",
      //               fontSize: 16.0,
      //               textColor: white,
      //               fontWeight: FontWeight.w600,
      //               fontFamily: productSans,
      //             ),
      //           ],
      //         );
      //       }
      //     }),
      //     const SizedBox(width: 20),
      //   ],
      // ),
      body: Stack(
        children: [
          SizedBox(
            height: double.infinity,
            width: double.infinity,
            child: Image.asset(appBg, fit: BoxFit.fill),
          ),
          Obx(() {
            if (homeController.isReviewListModelLoding.value) {
              return circularProgress();
            } else {
              return SingleChildScrollView(
                child: Column(
                  children: [
                    homeController.reviewListModel!.ratings!.isEmpty
                        ? Padding(
                            padding: const EdgeInsets.only(top: 220),
                            child: Center(
                              child: text(
                                "Reviwes Not found!",
                                fontFamily: productSans,
                                textColor: white,
                              ),
                            ),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.only(top: 10),
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount:
                                homeController.reviewListModel!.ratings!.length,
                            itemBuilder: (context, index) {
                              // Sort the data in descending order by createdAt
                              // homeController.mRatingDataModel!.data!.sort((a, b) {
                              //   return b.createdAt.compareTo(a.createdAt);
                              // });

                              return Container(
                                margin: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                  vertical: 10,
                                ),
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: textLightColorSecondary,
                                  ),
                                  borderRadius: BorderRadius.circular(16.0),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 15,
                                    vertical: 15,
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        children: [
                                          SizedBox(
                                            height: 70,
                                            width: 70,
                                            child: ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                              child: Image.asset(
                                                launchImage,
                                                fit: BoxFit.fill,
                                                // gaplessPlayback: true,
                                                // errorBuilder:
                                                //     (context, error, stackTrace) {
                                                //       return const Icon(
                                                //         Icons.error,
                                                //         color: primaryColor,
                                                //       );
                                                //     },
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 10),
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            children: [
                                              Text(
                                                homeController
                                                        .reviewListModel!
                                                        .ratings![index]
                                                        .servicveType ??
                                                    "",
                                                style: const TextStyle(
                                                  fontFamily: productSans,
                                                  fontWeight: FontWeight.w600,
                                                  fontSize: 15,
                                                  color: white,
                                                ),
                                              ),
                                              const SizedBox(height: 5),
                                              Text(
                                                formatter.format(
                                                  homeController
                                                      .reviewListModel!
                                                      .ratings![index]
                                                      .createdAt!,
                                                ),
                                                style: const TextStyle(
                                                  fontFamily: productSans,
                                                  fontWeight: FontWeight.w600,
                                                  fontSize: 12,
                                                  color: white,
                                                ),
                                              ),
                                              const SizedBox(height: 5),
                                              Text(
                                                homeController
                                                        .reviewListModel!
                                                        .ratings![index]
                                                        .customer!
                                                        .name ??
                                                    "",
                                                style: const TextStyle(
                                                  fontFamily: productSans,
                                                  fontWeight: FontWeight.w500,
                                                  fontSize: 12,
                                                  color: white,
                                                ),
                                              ),
                                              const SizedBox(height: 5),
                                              Row(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.center,
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  SvgPicture.asset(
                                                    starIcon,
                                                    height: 12,
                                                    width: 12,
                                                  ),
                                                  const SizedBox(width: 5),
                                                  Text(
                                                    homeController
                                                        .reviewListModel!
                                                        .ratings![index]
                                                        .rating
                                                        .toString(),
                                                    style: const TextStyle(
                                                      fontWeight:
                                                          FontWeight.w500,
                                                      fontSize: 12.0,
                                                      fontFamily: productSans,
                                                      color: white,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(height: 5),
                                              SizedBox(
                                                width: 180,
                                                child: Text(
                                                  homeController
                                                          .reviewListModel!
                                                          .ratings![index]
                                                          .description ??
                                                      "",
                                                  style: const TextStyle(
                                                    fontFamily: productSans,
                                                    fontWeight: FontWeight.w500,
                                                    fontSize: 12,
                                                    color: textColorSecondary,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                  ],
                ),
              );
            }
          }),
        ],
      ),
    );
  }

  // dynamic avrageOfReview({required List<RatingData> data}) {
  //   double total = 0.0; // Initialize total
  //   for (var element in data) {
  //     total += element.rating!;
  //   }
  //   return total / data.length; // Return average rating
  // }
}
