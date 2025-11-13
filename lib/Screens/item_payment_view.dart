import 'package:astro_partner_app/constants/colors_const.dart';
import 'package:astro_partner_app/constants/fonts_const.dart';
import 'package:astro_partner_app/constants/images_const.dart';
import 'package:astro_partner_app/controllers/home_controller.dart';
import 'package:astro_partner_app/model/earning_list_model.dart';
import 'package:astro_partner_app/widgets/app_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

/// ----------------------------------------------
/// ITEM PAYMENT VIEW (Card on list page)
/// ----------------------------------------------
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
    final payoutStatus = widget.earningData.payoutStatus ?? '';

    final weekStart = widget.earningData.weekStart;
    final weekEnd = widget.earningData.weekEnd;

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
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        decoration: BoxDecoration(
          border: Border.all(color: textLightColorThersery),
          borderRadius: BorderRadius.circular(16.0),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// Top Row: Date + Status Badge
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    formatter.format(widget.earningData.createdAt!),
                    style: const TextStyle(
                      fontSize: 16,
                      fontFamily: productSans,
                      fontWeight: FontWeight.bold,
                      color: white,
                    ),
                  ),

                  _statusBadge(payoutStatus),
                ],
              ),
            ),

            const SizedBox(height: 12),

            _earningList("Week", "${widget.earningData.weekNumber ?? 0}"),
            const SizedBox(height: 8),

            _earningList(
              "Week Period",
              "${weekStart != null ? formatter.format(weekStart) : '---'}"
                  " - ${weekEnd != null ? formatter.format(weekEnd) : '---'}",
            ),
            const SizedBox(height: 8),

            _earningList(
              "Total Commission",
              "₹${widget.earningData.totalCommission.toStringAsFixed(2)}",
            ),
            const SizedBox(height: 8),

            _earningList(
              "TDS Deducted",
              "₹${widget.earningData.totalTds.toStringAsFixed(2)}",
            ),
            const SizedBox(height: 8),

            _earningList(
              "Total Payable",
              "₹${widget.earningData.payableAmount.toStringAsFixed(2)}",
            ),
            const SizedBox(height: 8),

            _earningList("UTR Number", widget.earningData.utr ?? "---"),
            const SizedBox(height: 8),

            _earningList("Bank Name", widget.earningData.bankName ?? "---"),
          ],
        ),
      ),
    );
  }

  /// simple key-value row for ItemPaymentView
  //   Widget _earningList(String title, String title2, {bool bold = false}) {
  //     return Padding(
  //       padding: const EdgeInsets.symmetric(horizontal: 10),
  //       child: Row(
  //         mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //         children: [
  //           Text(
  //             title,
  //             style: const TextStyle(
  //               fontSize: 14,
  //               fontFamily: productSans,
  //               color: Colors.white70,
  //             ),
  //           ),
  //           Flexible(
  //             child: Align(
  //               alignment: Alignment.centerRight,
  //               child: Text(
  //                 title2,
  //                 overflow: TextOverflow.ellipsis,
  //                 style: TextStyle(
  //                   fontSize: 14,
  //                   fontFamily: productSans,
  //                   color: white,
  //                   fontWeight: bold ? FontWeight.w600 : FontWeight.w400,
  //                 ),
  //               ),
  //             ),
  //           ),
  //         ],
  //       ),
  //     );
  //   }
  // }

  Widget _earningList(String title, String title2, {bool bold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              fontFamily: productSans,
              color: Colors.white70,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              title2,
              textAlign: TextAlign.end,
              softWrap: true,
              maxLines: 2,
              overflow: TextOverflow.visible,
              style: TextStyle(
                fontSize: 14,
                fontFamily: productSans,
                color: white,
                fontWeight: bold ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _statusBadge(String raw) {
    final status = raw.trim().toLowerCase();

    Color border;
    Color fg;
    String label;

    if (status == 'paid') {
      border = Colors.green;
      // ignore: deprecated_member_use
      fg = Colors.green;
      label = 'PAID';
    } else if (status == 'pending' || status == 'processing') {
      border = Colors.orange;
      // ignore: deprecated_member_use
      fg = Colors.orange;
      label = status.toUpperCase();
    } else if (status == 'unpaid' ||
        status == 'failed' ||
        status == 'rejected' ||
        status == 'cancelled' ||
        status == 'canceled') {
      border = Colors.red;
      // ignore: deprecated_member_use
      fg = Colors.red;
      label = status.toUpperCase();
    } else {
      border = Colors.white24;
      fg = Colors.white70;
      label = raw.isEmpty ? 'UNKNOWN' : raw.toUpperCase();
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: border),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontFamily: productSans,
          fontSize: 12.5,
          color: fg,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.3,
        ),
      ),
    );
  }
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
  final DateFormat formatter = DateFormat("dd MMM yyyy");

  @override
  void initState() {
    super.initState();
    _homeController.fetchEarningDetailsModelData(earningId: widget.earningId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: secondryTabAppBar(title: "Earning Details"),
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
            }

            final transactions =
                _homeController
                    .earningDetailsModel
                    ?.data
                    ?.earning
                    ?.transactions ??
                [];

            if (transactions.isEmpty) {
              return Center(
                child: text(
                  "No sessions found",
                  textColor: Colors.white70,
                  fontFamily: productSans,
                ),
              );
            }

            return SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(height: 30),
                  ListView.separated(
                    physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: transactions.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 16),
                    itemBuilder: (context, index) {
                      final order = transactions[index];

                      final sessionId = order.sessionData?.id?.toString() ?? '';
                      final commission = (order.commission ?? '').toString();

                      final sessionType = order.sessionData?.serviceName ?? '';
                      final startTime =
                          order.sessionData?.startTime?.toString() ?? '';
                      final endTime =
                          order.sessionData?.endTime?.toString() ?? '';

                      final subtotal =
                          order.sessionData?.order?.totalAmount?.toString() ??
                          '0';
                      final payable =
                          order.sessionData?.order?.payableAmount?.toString() ??
                          '0';

                      return Container(
                        padding: const EdgeInsets.all(16),
                        margin: const EdgeInsets.symmetric(horizontal: 20),
                        decoration: BoxDecoration(
                          border: Border.all(color: primaryColor),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          children: [
                            _buildRow(
                              "Date",
                              formatter.format(order.sessionDate!),
                            ),

                            _buildRow("Session ID", "#$sessionId"),
                            _buildRow(
                              "Customer name",
                              order.customerName ?? "",
                            ),

                            _buildRow("Total Earning", "₹$commission"),

                            _buildRow("Session Type", sessionType),
                            _buildRow("Session Start Time", startTime),
                            _buildRow("Session End Time", endTime),

                            _buildRow(
                              "Session Duration",
                              "${order.sessionDurationMin.toString()} min",
                            ),

                            _buildRow("Subtotal", "₹$subtotal"),
                            const Divider(color: Colors.white24, height: 24),
                            _buildRow("Payable", "₹$payable", isBold: true),
                          ],
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  String calculateDuration(String start, String end) {
    try {
      final format = DateFormat("HH:mm:ss"); // 24-hour format with seconds
      final startTime = format.parse(start);
      final endTime = format.parse(end);

      final diff = endTime.difference(startTime);

      final minutes = diff.inMinutes;
      final seconds = diff.inSeconds % 60;

      // ✅ Final readable output
      if (minutes > 0) {
        return "$minutes min ${seconds}s";
      } else {
        return "$seconds sec";
      }
    } catch (e) {
      return "---";
    }
  }

  Widget _buildRow(
    String title,
    String? value, {
    bool isBold = false,
    Widget? trailing,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 14,
                fontFamily: productSans,
              ),
            ),
          ),
          if (trailing != null)
            trailing
          else
            Text(
              value ?? '',
              textAlign: TextAlign.right,
              style: TextStyle(
                color: Colors.white,
                fontSize: isBold ? 15 : 14,
                fontWeight: isBold ? FontWeight.w600 : FontWeight.normal,
                fontFamily: productSans,
              ),
            ),
        ],
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
