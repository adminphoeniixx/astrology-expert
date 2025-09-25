import 'package:astro_partner_app/Screens/item_payment_view.dart';
import 'package:astro_partner_app/constants/images_const.dart';
import 'package:flutter/material.dart';

class EarningTab extends StatefulWidget {
  const EarningTab({super.key});

  @override
  State<EarningTab> createState() => _EarningTabState();
}

class _EarningTabState extends State<EarningTab> {

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
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: ListView.separated(
              padding: const EdgeInsets.only(top: 20),
              itemCount: 5,
              separatorBuilder: (context, index) {
                return const SizedBox(height: 20);
              },
              itemBuilder: (BuildContext context, int index) {
                return const ItemPaymentView();
              },
            ),
          ),
        ],
      ),
    );
  }
}
