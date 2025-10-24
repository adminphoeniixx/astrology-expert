import 'package:astro_partner_app/constants/colors_const.dart';
import 'package:astro_partner_app/constants/fonts_const.dart';
import 'package:astro_partner_app/constants/images_const.dart';
import 'package:astro_partner_app/controllers/home_controller.dart';
import 'package:astro_partner_app/model/earning_details_model.dart';
import 'package:astro_partner_app/model/earning_list_model.dart';
import 'package:astro_partner_app/widgets/app_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class ItemPaymentView extends StatefulWidget {
  final EarningData earningData;
  const ItemPaymentView({super.key, required this.earningData});

  @override
  State<ItemPaymentView> createState() => _ItemPaymentViewState();
}

class _ItemPaymentViewState extends State<ItemPaymentView> {
  final DateFormat formatter = DateFormat("dd MMM yyyy");

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => OrdersTableScreen(
              earningId: widget.earningData.id ?? "",
              orderDate: formatter.format(widget.earningData.createdAt!),
            ),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 10),
        margin: const EdgeInsets.symmetric(horizontal: 5),
        decoration: BoxDecoration(
          border: Border.all(color: textLightColorThersery),
          borderRadius: BorderRadius.circular(16.0),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    widget.earningData.payoutDate ?? "Date",
                    style: const TextStyle(
                      fontSize: 16,
                      fontFamily: productSans,
                      fontWeight: FontWeight.bold,
                      color: white,
                    ),
                  ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color:
                              (widget.earningData.payoutStatus?.toLowerCase() ==
                                  "paid")
                              ? Colors.green
                              : Colors.red,
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        child: Text(
                          widget.earningData.payoutStatus ?? "",
                          style: TextStyle(
                            fontSize: 13,
                            fontFamily: productSans,
                            color:
                                (widget.earningData.payoutStatus
                                        ?.toLowerCase() ==
                                    "paid")
                                ? Colors.green
                                : Colors.red,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 15),

              Text(
                "Week - ${widget.earningData.weekNumber.toString()}",
                style: const TextStyle(
                  fontSize: 14,
                  fontFamily: productSans,
                  color: white,
                ),
              ),
              const SizedBox(height: 12),

              Text(
                "Week Period - ${formatter.format(widget.earningData.weekStart!)} "
                "to ${formatter.format(widget.earningData.weekEnd!)}",
                style: const TextStyle(
                  fontSize: 14,
                  fontFamily: productSans,
                  color: white,
                ),
              ),
              const SizedBox(height: 12),

              Text(
                "Total Commision - ₹${widget.earningData.totalCommission.toString()}",
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  fontFamily: productSans,
                  color: white,
                ),
              ),
              const SizedBox(height: 12),

              Text(
                "TDS Deducted - ₹${widget.earningData.totalTds.toString()}",
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  fontFamily: productSans,
                  color: white,
                ),
              ),
              const SizedBox(height: 12),

              Text(
                "Total Payable - ₹${widget.earningData.payableAmount.toString()}",
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  fontFamily: productSans,
                  color: white,
                ),
              ),

              const SizedBox(height: 12),

              Text(
                "UTR Number - ${widget.earningData.utr ?? "---"}",
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  fontFamily: productSans,
                  color: white,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                "Bank Name - ${widget.earningData.bankName ?? "---"}",
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  fontFamily: productSans,
                  color: white,
                ),
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }
}

AppBar secondryTabAppBar({String title = ''}) {
  return AppBar(
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
          title,
          fontSize: 16.0,
          textColor: white,
          fontWeight: FontWeight.w600,
          fontFamily: productSans,
        ),
      ],
    ),
  );
}

class OrdersTableScreen extends StatefulWidget {
  final String earningId;
  final String orderDate;
  const OrdersTableScreen({
    super.key,
    required this.earningId,
    required this.orderDate,
  });

  @override
  State<OrdersTableScreen> createState() => _OrdersTableScreenState();
}

class _OrdersTableScreenState extends State<OrdersTableScreen> {
  final HomeController _homeController = Get.put(HomeController());
  @override
  void initState() {
    _homeController.fetchEarningDetailsModelData(earningId: widget.earningId);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: secondryTabAppBar(
        title: "Sessions of Date - ${widget.orderDate}",
      ),
      body: Stack(
        children: [
          SizedBox(
            height: double.infinity,
            width: double.infinity,
            child: Image.asset(appBg, fit: BoxFit.fill),
          ),
          Obx(() {
            if (_homeController.isEarningDetailsModelLoding.value) {
              return circularProgress();
            } else {
              return SingleChildScrollView(
                child: Column(
                  children: [
                    const SizedBox(height: 20),
                    ListView.separated(
                      physics: const NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      separatorBuilder: (context, index) =>
                          const SizedBox(height: 20),
                      itemCount: _homeController
                          .earningDetailsModel!
                          .data!
                          .earning!
                          .transactions!
                          .length,
                      itemBuilder: (context, index) {
                        return Container(
                          padding: const EdgeInsets.all(16),
                          margin: const EdgeInsets.symmetric(horizontal: 20),
                          decoration: BoxDecoration(
                            border: Border.all(color: primaryColor),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              vertical: 12,
                              horizontal: 12,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Table(
                                  columnWidths: const {
                                    0: FlexColumnWidth(
                                      2,
                                    ), // Adjust these to control the width of each column
                                    1: FlexColumnWidth(3),
                                  },
                                  children: [
                                    TableRow(
                                      children: [
                                        const Text(
                                          "Total Commision",
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontFamily: productSans,
                                            color: white,
                                          ),
                                        ),
                                        Align(
                                          alignment: Alignment.centerRight,
                                          child: Text(
                                            "₹${_homeController.earningDetailsModel!.data!.earning!.transactions![index].commission.toString()}",
                                            style: const TextStyle(
                                              fontSize: 14,
                                              fontFamily: productSans,
                                              color: white,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    // const TableRow(
                                    //   children: [
                                    //     SizedBox(height: 8),
                                    //     SizedBox(height: 8),
                                    //   ],
                                    // ),
                                    // TableRow(
                                    //   children: [
                                    //     const Text(
                                    //       "Total Discount",
                                    //       style: TextStyle(
                                    //         fontSize: 14,
                                    //         fontFamily: productSans,
                                    //         color: white,
                                    //       ),
                                    //     ),
                                    //     Align(
                                    //       alignment: Alignment.centerRight,
                                    //       child: Text(
                                    //         "${_homeController.earningDetailsModel!.data!.earning!.transactions![index].tdsPercentage.toString()}%",
                                    //         style: const TextStyle(
                                    //           fontSize: 14,
                                    //           fontFamily: productSans,
                                    //           color: white,
                                    //         ),
                                    //       ),
                                    //     ),
                                    //   ],
                                    // ),
                                    const TableRow(
                                      children: [
                                        SizedBox(height: 8),
                                        SizedBox(height: 8),
                                      ],
                                    ),

                                    TableRow(
                                      children: [
                                        const Text(
                                          "Total Amount",
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontFamily: productSans,
                                            color: white,
                                          ),
                                        ),
                                        Align(
                                          alignment: Alignment.centerRight,
                                          child: Text(
                                            "₹${_homeController.earningDetailsModel!.data!.earning!.transactions![index].payableAmount ?? ""}",
                                            style: const TextStyle(
                                              fontSize: 14,
                                              fontFamily: productSans,
                                              color: white,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const TableRow(
                                      children: [
                                        SizedBox(height: 8),
                                        SizedBox(height: 8),
                                      ],
                                    ),

                                    TableRow(
                                      children: [
                                        const Text(
                                          "Payout Status",
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontFamily: productSans,
                                            color:
                                                white, // keep label consistent
                                          ),
                                        ),
                                        Align(
                                          alignment: Alignment.centerRight,
                                          child: Builder(
                                            builder: (context) {
                                              final status =
                                                  _homeController
                                                      .earningDetailsModel!
                                                      .data!
                                                      .earning!
                                                      .transactions![index]
                                                      .status ??
                                                  "";

                                              final statusColor =
                                                  status.toLowerCase() == "paid"
                                                  ? Colors.green
                                                  : Colors.red;

                                              return Container(
                                                decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                  border: Border.all(
                                                    color: statusColor,
                                                  ),
                                                ),
                                                child: Padding(
                                                  padding:
                                                      const EdgeInsets.symmetric(
                                                        horizontal: 8,
                                                        vertical: 2,
                                                      ),
                                                  child: Text(
                                                    status,
                                                    style: TextStyle(
                                                      fontSize: 13,
                                                      fontFamily: productSans,
                                                      color: statusColor,
                                                    ),
                                                  ),
                                                ),
                                              );
                                            },
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
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      padding: const EdgeInsets.only(top: 10, bottom: 20),
                      itemCount: _homeController
                          .earningDetailsModel!
                          .data!
                          .earning!
                          .transactions!
                          .length,
                      separatorBuilder: (context, index) =>
                          const SizedBox(height: 20),
                      itemBuilder: (context, index) {
                        return orderAmountItem(
                          _homeController
                              .earningDetailsModel!
                              .data!
                              .earning!
                              .transactions![index]
                              .sessionData!,
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

  Column orderAmountItem(SessionDetailData orderData) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(8.0),
          margin: const EdgeInsets.symmetric(horizontal: 20),
          decoration: BoxDecoration(
            color: Colors.transparent,
            border: Border.all(color: textLightColorSecondary),
            borderRadius: BorderRadius.circular(16.0),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Table(
                  columnWidths: const {
                    0: FlexColumnWidth(
                      2,
                    ), // Adjust these to control the width of each column
                    1: FlexColumnWidth(3),
                  },
                  children: [
                    TableRow(
                      children: [
                        const Text(
                          "Session id",
                          style: TextStyle(
                            fontSize: 14,
                            fontFamily: productSans,
                            color: white,
                          ),
                        ),
                        Align(
                          alignment: Alignment.centerRight,
                          child: Text(
                            "#${orderData.orderId ?? ""}",
                            style: const TextStyle(
                              fontSize: 14,
                              fontFamily: productSans,
                              color: white,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const TableRow(
                      children: [SizedBox(height: 8), SizedBox(height: 8)],
                    ),
                    // TableRow(
                    //   children: [
                    //     const Text(
                    //       "Session name",
                    //       style: TextStyle(
                    //         fontSize: 14,
                    //         fontFamily: productSans,
                    //         color: white,
                    //       ),
                    //     ),
                    //     Align(
                    //       alignment: Alignment.centerRight,
                    //       child: Text(
                    //         orderData.serviceName??"",
                    //         style: const TextStyle(
                    //           fontSize: 14,
                    //           fontFamily: productSans,
                    //           color: white,
                    //         ),
                    //       ),
                    //     ),
                    //   ],
                    // ),
                    // const TableRow(
                    //   children: [SizedBox(height: 8), SizedBox(height: 8)],
                    // ),
                    TableRow(
                      children: [
                        const Text(
                          "Session type",
                          style: TextStyle(
                            fontSize: 14,
                            fontFamily: productSans,
                            color: white,
                          ),
                        ),
                        Align(
                          alignment: Alignment.centerRight,
                          child: Text(
                            orderData.order!.serviceType ?? "--",
                            style: const TextStyle(
                              fontSize: 14,
                              fontFamily: productSans,
                              color: white,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const TableRow(
                      children: [SizedBox(height: 8), SizedBox(height: 8)],
                    ),
                    TableRow(
                      children: [
                        const Text(
                          "SessionSession time",
                          style: TextStyle(
                            fontSize: 14,
                            fontFamily: productSans,
                            color: white,
                          ),
                        ),
                        Align(
                          alignment: Alignment.centerRight,
                          child: Text(
                            "${orderData.sessionTime ?? "0"} Minute",
                            style: const TextStyle(
                              fontSize: 14,
                              fontFamily: productSans,
                              color: white,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const TableRow(
                      children: [SizedBox(height: 8), SizedBox(height: 8)],
                    ),
                    TableRow(
                      children: [
                        const Text(
                          "Session Subtotal:",
                          style: TextStyle(
                            fontSize: 14,
                            fontFamily: productSans,
                            color: white,
                          ),
                        ),
                        Align(
                          alignment: Alignment.centerRight,
                          child: Text(
                            "₹${orderData.order!.total ?? "0"}",
                            style: const TextStyle(
                              fontSize: 14,
                              fontFamily: productSans,
                              color: white,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const TableRow(
                      children: [
                        SizedBox(height: 8), // Add spacing between rows
                        SizedBox(height: 8),
                      ],
                    ),

                    TableRow(
                      children: [
                        const Text(
                          "Payable:",
                          style: TextStyle(
                            fontSize: 16,
                            fontFamily: productSans,
                            fontWeight: FontWeight.w600,
                            color: white,
                          ),
                        ),
                        Align(
                          alignment: Alignment.centerRight,
                          child: Text(
                            "₹${orderData.order!.total ?? "0"}",
                            style: const TextStyle(
                              fontSize: 16,
                              fontFamily: productSans,
                              fontWeight: FontWeight.w600,
                              color: white,
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
        ),
        const SizedBox(height: 15),
      ],
    );
  }
}
