import 'package:astro_partner_app/constants/images_const.dart';

enum TabItem {
  sessionsTab(label: "Sessions", icon: sessionIcon),
  earnigTab(label: "Earnings", icon: erningIcon),
  reviewTab(label: "Reviews", icon: erningIcon),

  profileTab(label: "Profile", icon: profileIcon);

  const TabItem({this.label, this.icon});
  final String? label;
  final String? icon;
}
