
import 'package:astro_partner_app/constants/images_const.dart';

enum TabItem {
  // homeTab(label: "Home", icon:  homeIcon),
  sessionsTab(label: "Sessions", icon: sessionIcon),
  earnigTab(label: "Earning", icon: erningIcon),
  profileTab(label: "Profile", icon: profileIcon);


  const TabItem({this.label, this.icon});
  final String? label;
  final String? icon;
}
