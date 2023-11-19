// ignore_for_file: curly_braces_in_flow_control_structures

import 'package:deepay/Screens/Account/account.dart';
import 'package:deepay/Screens/Home/home.dart';
import 'package:deepay/Screens/Messages/messages.dart';
import 'package:deepay/Screens/Transactions/transactions.dart';
import 'package:deepay/helper/preferences/preference_manager.dart';
import 'package:deepay/model/transactions/guest_transaction_model.dart';
import 'package:deepay/model/transactions/user/user_transaction.dart';
import 'package:flutter/material.dart' hide ModalBottomSheetRoute;

import 'auth_controller.dart';

class TabNavigatorRoutes {
  static const String root = '/';
  static const String detail = '/detail';
}

class TabNavigator extends StatefulWidget {
  final PreferenceManager manager;
  final List<GuestTransactionModel> guestModel;
  final List<UserTransaction> model;

  const TabNavigator({
    required this.navigatorKey,
    required this.tabItem,
    required this.manager,
    required this.guestModel,
    required this.model,
  });
  final GlobalKey<NavigatorState> navigatorKey;
  final String tabItem;

  @override
  State<TabNavigator> createState() => _TabNavigatorState();
}

class _TabNavigatorState extends State<TabNavigator> {
  @override
  Widget build(BuildContext context) {
    Widget child = const Home();
    if (widget.tabItem == "Home")
      child = Home(
        manager: widget.manager,
      );
    else if (widget.tabItem == "Transactions")
      child = Transactions(
          manager: widget.manager,
          guestModel: widget.guestModel,
          model: widget.model);
    else if (widget.tabItem == "Messages")
      child = AuthController(
        manager: widget.manager,
        child: Messages(
          manager: widget.manager,
        ),
      );
    else if (widget.tabItem == "Account")
      child = AuthController(
        manager: widget.manager,
        child: Account(
          manager: widget.manager,
        ),
      );

    return Navigator(
      key: widget.navigatorKey,
      onGenerateRoute: (routeSettings) {
        return MaterialPageRoute(builder: (context) => child);
      },
    );
  }
}
