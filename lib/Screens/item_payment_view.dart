import 'package:astro_partner_app/constants/colors_const.dart';
import 'package:astro_partner_app/constants/fonts_const.dart';
import 'package:astro_partner_app/constants/images_const.dart';
import 'package:astro_partner_app/widgets/app_widget.dart';
import 'package:flutter/material.dart';

class ItemPaymentView extends StatefulWidget {
  const ItemPaymentView({super.key});

  @override
  State<ItemPaymentView> createState() => _ItemPaymentViewState();
}

class _ItemPaymentViewState extends State<ItemPaymentView> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const OrdersTableScreen()),
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
                  const Text(
                    "Date",
                    style: TextStyle(
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
                        border: Border.all(color: Colors.green),
                      ),
                      child: const Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        child: Text(
                          'Pending',
                          style: TextStyle(
                            fontSize: 13,
                            fontFamily: productSans,
                            color: Colors.green,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Table(
                columnWidths: const {
                  0: FlexColumnWidth(
                    2,
                  ), // Adjust these to control the width of each column
                  1: FlexColumnWidth(3),
                },
                children: const [
                  TableRow(
                    children: [
                      Text(
                        "Total Payable",
                        style: TextStyle(
                          fontSize: 14,
                          fontFamily: productSans,
                          color: white,
                        ),
                      ),
                      Align(
                        alignment: Alignment.centerRight,
                        child: Text(
                          "₹ totalPayable",
                          style: TextStyle(
                            fontSize: 14,
                            fontFamily: productSans,
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

// Screen to show the orders list in a table-like format without borders
class OrdersTableScreen extends StatefulWidget {
  const OrdersTableScreen({super.key});

  @override
  State<OrdersTableScreen> createState() => _OrdersTableScreenState();
}

class _OrdersTableScreenState extends State<OrdersTableScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: secondryTabAppBar(title: "Orders of Date"),
      body: Stack(
        children: [
          SizedBox(
            height: double.infinity,
            width: double.infinity,
            child: Image.asset(appBg, fit: BoxFit.fill),
          ),
          SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 20),
                ListView.separated(
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 20),
                  itemCount: 1,
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
                                const TableRow(
                                  children: [
                                    Text(
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
                                        "₹ totalPayable",
                                        style: TextStyle(
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
                                const TableRow(
                                  children: [
                                    Text(
                                      "Daily fee",
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontFamily: productSans,
                                        color: white,
                                      ),
                                    ),
                                    Align(
                                      alignment: Alignment.centerRight,
                                      child: Text(
                                        "-₹ dailyOrderFee",
                                        style: TextStyle(
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
                                const TableRow(
                                  children: [
                                    Text(
                                      "Total Payable",
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontFamily: productSans,
                                        color: white,
                                      ),
                                    ),
                                    Align(
                                      alignment: Alignment.centerRight,
                                      child: Text(
                                        "₹ finalTotalPayable",
                                        style: TextStyle(
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
                                        color: Colors.green,
                                      ),
                                    ),
                                    Align(
                                      alignment: Alignment.centerRight,
                                      child: Container(
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(
                                            10,
                                          ),
                                          border: Border.all(
                                            color: Colors.green,
                                          ),
                                        ),
                                        child: const Padding(
                                          padding: EdgeInsets.symmetric(
                                            horizontal: 8,
                                            vertical: 2,
                                          ),
                                          child: Text(
                                            'Pending',
                                            style: TextStyle(
                                              fontSize: 13,
                                              fontFamily: productSans,
                                              color: Colors.green,
                                            ),
                                          ),
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
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  padding: const EdgeInsets.only(top: 10, bottom: 20),
                  itemCount: 5,
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 20),
                  itemBuilder: (context, index) {
                    return orderAmountItem();
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Column orderAmountItem() {
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
                  children: const [
                    TableRow(
                      children: [
                        Text(
                          "Order id",
                          style: TextStyle(
                            fontSize: 14,
                            fontFamily: productSans,
                            color: white,
                          ),
                        ),
                        Align(
                          alignment: Alignment.centerRight,
                          child: Text(
                            "#orderId",
                            style: TextStyle(
                              fontSize: 14,
                              fontFamily: productSans,
                              color: white,
                            ),
                          ),
                        ),
                      ],
                    ),
                    TableRow(
                      children: [SizedBox(height: 8), SizedBox(height: 8)],
                    ),
                    TableRow(
                      children: [
                        Text(
                          "Order Subtotal:",
                          style: TextStyle(
                            fontSize: 14,
                            fontFamily: productSans,
                            color: white,
                          ),
                        ),
                        Align(
                          alignment: Alignment.centerRight,
                          child: Text(
                            "₹ orderSubtotal",
                            style: TextStyle(
                              fontSize: 14,
                              fontFamily: productSans,
                              color: white,
                            ),
                          ),
                        ),
                      ],
                    ),
                    TableRow(
                      children: [
                        SizedBox(height: 8), // Add spacing between rows
                        SizedBox(height: 8),
                      ],
                    ),
                    TableRow(
                      children: [
                        Text(
                          "Order fee:",
                          style: TextStyle(
                            fontSize: 14,
                            fontFamily: productSans,
                            color: white,
                          ),
                        ),
                        Align(
                          alignment: Alignment.centerRight,
                          child: Text(
                            "-₹orderFee",
                            style: TextStyle(
                              fontSize: 14,
                              fontFamily: productSans,
                              color: white,
                            ),
                          ),
                        ),
                      ],
                    ),
                    TableRow(
                      children: [SizedBox(height: 8), SizedBox(height: 8)],
                    ),
                    TableRow(
                      children: [
                        Text(
                          "PG fee:",
                          style: TextStyle(
                            fontSize: 14,
                            fontFamily: productSans,
                            color: white,
                          ),
                        ),
                        Align(
                          alignment: Alignment.centerRight,
                          child: Text(
                            "-₹pgfee",
                            style: TextStyle(
                              fontSize: 14,
                              fontFamily: productSans,
                              color: white,
                            ),
                          ),
                        ),
                      ],
                    ),
                    TableRow(
                      children: [SizedBox(height: 8), SizedBox(height: 8)],
                    ),
                    TableRow(
                      children: [
                        Text(
                          "Taxes:",
                          style: TextStyle(
                            fontSize: 14,
                            fontFamily: productSans,
                            color: white,
                          ),
                        ),
                        Align(
                          alignment: Alignment.centerRight,
                          child: Text(
                            "-₹taxes",
                            style: TextStyle(
                              fontSize: 14,
                              fontFamily: productSans,
                              color: white,
                            ),
                          ),
                        ),
                      ],
                    ),
                    TableRow(
                      children: [SizedBox(height: 8), SizedBox(height: 8)],
                    ),
                    TableRow(
                      children: [
                        Text(
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
                            "₹payable",
                            style: TextStyle(
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
