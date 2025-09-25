import 'dart:async';
import 'package:astro_partner_app/Screens/home_screen.dart';
import 'package:flutter/material.dart';

class MessageBean {
  MessageBean({required this.itemId});
  final String itemId;

  final StreamController<MessageBean> _controller =
  StreamController<MessageBean>.broadcast();
  Stream<MessageBean> get onChanged => _controller.stream;

  late String _status;
  String get status => _status;
  set status(String value) {
    _status = value;
    _controller.add(this);
  }

  static final Map<String, Route<void>> routes = <String, Route<void>>{};
  Route<void> get route {
    final String routeName = '/detail/$itemId';
    if (itemId == "1") {
      return routes.putIfAbsent(
        routeName,
            () => MaterialPageRoute<void>(
          settings: RouteSettings(name: routeName),
          builder: (BuildContext context) => const MyHomePage(),
        ),
      );
    } else if (itemId == "2") {
      return routes.putIfAbsent(
        routeName,
            () => MaterialPageRoute<void>(
          settings: RouteSettings(name: routeName),
          builder: (BuildContext context) => const MyHomePage(),
        ),
      );
    } else if (itemId == "3") {
      return routes.putIfAbsent(
        routeName,
            () => MaterialPageRoute<void>(
          settings: RouteSettings(name: routeName),
          builder: (BuildContext context) => const MyHomePage(),
        ),
      );
    } else if (itemId == "4") {
      return routes.putIfAbsent(
        routeName,
            () => MaterialPageRoute<void>(
          settings: RouteSettings(name: routeName),
          builder: (BuildContext context) => const MyHomePage(),
        ),
      );
    } else if (itemId == "5") {
      return routes.putIfAbsent(
        routeName,
            () => MaterialPageRoute<void>(
          settings: RouteSettings(name: routeName),
          builder: (BuildContext context) => const MyHomePage(),
        ),
      );
    } else if (itemId == "6") {
      return routes.putIfAbsent(
        routeName,
            () => MaterialPageRoute<void>(
          settings: RouteSettings(name: routeName),
          builder: (BuildContext context) => const MyHomePage(),
        ),
      );
    } else {
      return routes.putIfAbsent(
        routeName,
            () => MaterialPageRoute<void>(
          settings: RouteSettings(name: routeName),
          builder: (BuildContext context) => const MyHomePage(),
        ),
      );
    }
  }
}