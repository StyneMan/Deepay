// import 'package:accesspro/util/preference_manager.dart';
import 'dart:convert';

import 'package:deepay/Screens/Home/home.dart';
import 'package:deepay/constants.dart';
import 'package:deepay/helper/service/api_service.dart';
import 'package:flutter/material.dart' hide ModalBottomSheetRoute;
import 'package:get/get.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StateController extends GetxController {
  var isAppClosed = false;
  var isLoading = false.obs;
  var isAuthenticated = false.obs;
  var hideNavbar = false.obs;
  var hasInternetAccess = true.obs;
  var airtimeCashData = [].obs;
  var transactions = [].obs;
  var recentTransactions = [].obs;
  var hasMoreTransactions = false.obs;
  var hasMoreNotifications = false.obs;
  var hasMoreInvites = false.obs;
  var transactionCurrentPage = 1.obs;

  Map<String, dynamic>? products;
  var unreadNotifications = 0.obs;
  var isSpinning = false.obs;

  var mynotifications = [].obs;
  var navColor = kPrimaryColor.obs;
  var userData;

  ScrollController transactionsScrollController = ScrollController();
  ScrollController messagesScrollController = ScrollController();

  var isDataProcessing = false.obs;
  var isMoreDataAvailable = true.obs;
  var accessToken = "".obs;
  String _token = "";

  var airtimeSwapData = [].obs;
  var airtimeSwapRate = "".obs;
  var airtimeSwapNumber = "".obs;
  var airtimeSwapResultantAmt = "0.0".obs;

  RxString appVersion = "2.0".obs;
  PackageInfo? packageInfo;

  @override
  void onInit() async {
    super.onInit();
    packageInfo = await PackageInfo.fromPlatform();
    appVersion.value = "${packageInfo?.version}";

    final _prefs = await SharedPreferences.getInstance();
    _token = _prefs.getString("accessToken") ?? "";
    // bool _isAuthenticated = prefs.getBool("loggedIn") ?? false;

    if (_token.isNotEmpty) {
      //Get User Profile
      APIService().getProfile(_token).then((value) {
        // debugDebugPrintdebugPrint("STATE GET PROFILE >>> ${value.body}");
        Map<String, dynamic> data = jsonDecode(value.body);
        userData.value = data['data'];
        _prefs.setString("user", jsonEncode(data['data']));

        //Update preference here
      }).catchError((onError) {
        debugPrint("STATE GET PROFILE ERROR >>> $onError");
        if (onError.toString().contains("rk is unreachable")) {
          hasInternetAccess.value = false;
        }
      });

      APIService().fetchTransactions(_token);
      paginateTransaction(_token);
    }
  }

  void paginateTransaction(String accessToken) {
    transactionsScrollController.addListener(() {
      if (transactionsScrollController.position.pixels ==
          transactionsScrollController.position.maxScrollExtent) {
        print("reached end");

        //Now load more items
        if (hasMoreTransactions.value) {
          setSpinning(true);
          transactionCurrentPage.value++;
          Future.delayed(const Duration(seconds: 3), () {
            APIService().fetchNextTransactions(
                accessToken, transactionCurrentPage.value);
          });
        } else {
          setSpinning(false);
        }
      } else {
        print("still moving to end");
      }
    });
  }

  Widget currentScreen = const Home(
      // manager: PreferenceManager.getIstance(),
      );

  var currentPage = "Home";
  List<String> pageKeys = ["Home", "Transactions", "Messages", "Account"];
  Map<String, GlobalKey<NavigatorState>> navigatorKeys = {
    "Home": GlobalKey<NavigatorState>(),
    "Transactions": GlobalKey<NavigatorState>(),
    "Messages": GlobalKey<NavigatorState>(),
    "Account": GlobalKey<NavigatorState>(),
  };

  var selectedIndex = 0.obs;

  void setAccessToken(String token) {
    accessToken.value = token;
  }

  void setUnreadNotifications(int num) {
    unreadNotifications.value = num;
  }

  void setSpinning(bool val) {
    isSpinning.value = val;
  }

  void setAuthenticated(bool state) {
    isAuthenticated.value = state;
  }

  void setHideNav(bool state) {
    hideNavbar.value = state;
  }

  void setHasInternet(bool state) {
    hasInternetAccess.value = state;
  }

  void setHasMoreTransactions(bool state) {
    hasMoreTransactions.value = state;
  }

  void selectTab(var currPage, String tabItem, int index) {
    if (tabItem == currentPage) {
      navigatorKeys[tabItem]!.currentState?.popUntil((route) => route.isFirst);
      currentScreen = currPage;
      selectedIndex.value = index;
    } else {
      currentPage = pageKeys[index];
      selectedIndex.value = index;
      currentScreen = currPage;
    }
  }

  void setUserData(var data) {
    userData = data;
  }

  void setTransactions(var list) {
    // var arr = [];
    // arr
    // // print("STATE DATA LIST ==>>> $list");
    // print("STATE LOGOMAN LIST ==>>> $arr");
    transactions.value.addAll(list);
  }

  void setAirtimeCash(var list) {
    airtimeCashData.value.addAll(list);
  }

  void setRecentTransactions(var list) {
    recentTransactions.value = list?.sublist(0, 5);
  }

  void setProductData(var data) {
    products = data;
  }

  void setLoading(bool state) {
    isLoading.value = state;
  }

  void triggerAppExit(bool state) {
    isAppClosed = state;
  }

  void resetAll() {}

  @override
  void onClose() {
    super.onClose();
    transactionsScrollController.dispose();
    messagesScrollController.dispose();
  }
}
