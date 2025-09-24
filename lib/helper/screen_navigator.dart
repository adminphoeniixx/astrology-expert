import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void changeScreen(BuildContext context, Widget widget) {
  Navigator.push(context, MaterialPageRoute(builder: (context) => widget));
}

void changeScreenReplacement(BuildContext context, Widget widget) {
  Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => widget));
}

void changeToNewScreen(BuildContext context, Widget widget, String routeName) {
  Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => widget),
      ModalRoute.withName(routeName));
}

void backToScreen(BuildContext context) {
  Navigator.pop(context);
}

void backToPhone() {
  SystemNavigator.pop();
}

void dismissKeyboard(BuildContext context) {
  FocusScope.of(context).requestFocus( FocusNode());
}