// ignore_for_file: avoid_print

import 'dart:convert';

import 'package:deepay/Screens/Transactions/transactions.dart';
import 'package:deepay/Screens/Wallet/fund_wallet.dart';
import 'package:deepay/Screens/Wallet/withdraw_fund.dart';
import 'package:deepay/components/background/background.dart';
import 'package:deepay/components/drawer/custom_drawer.dart';
import 'package:deepay/components/text/text_widget.dart';
import 'package:deepay/constants.dart';
import 'package:deepay/helper/database/database_handler.dart';
import 'package:deepay/helper/preferences/preference_manager.dart';
import 'package:deepay/helper/service/api_service.dart';
import 'package:deepay/helper/state/state_controller.dart';
import 'package:deepay/model/others/services/services_item_model.dart';
import 'package:deepay/model/transactions/guest_transaction_model.dart';
import 'package:deepay/model/transactions/user/user_transaction.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' hide ModalBottomSheetRoute;
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart' as MBottomSheet;
import 'package:page_transition/page_transition.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'components/service_card.dart';
import 'components/transactions.dart';

class Home extends StatefulWidget {
  final PreferenceManager? manager;
  const Home({
    Key? key,
    this.manager,
  }) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final _controller = Get.find<StateController>();
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  String _bal = "0.00";
  String _name = "Guest User";
  bool _isAuthenticated = false;
  final _refreshController = RefreshController(initialRefresh: false);

  final List<UserTransaction> _transactionList = [];
  List<GuestTransactionModel> _transactionListGuest = [];

  Widget _mWidget = const SizedBox();
  Widget _nWidget = const SizedBox();

  _init() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _isAuthenticated = prefs.getBool('loggedIn') ?? false;
      final String _token = prefs.getString('accessToken') ?? "";
      // var model = prefs.get('user');
      // if (model != null) {
      var mod = widget.manager!.getUser();
      print("APROKO:: ${mod['name']}");
      setState(() {
        _bal = mod['wallet_balance']!;
        _name = mod['name'];
      });
      // }

      if (_isAuthenticated) {
        var data = _controller.transactions.value;
        // print("MJKD::: ${data}");
        for (var v in data) {
          _transactionList.add(UserTransaction.fromJson(v));
        }
      } else {
        //Fetch from sqlite
        final resp = await DatabaseHandler().transactions();
        setState(() {
          _transactionListGuest = resp;
        });
      }
      await APIService()
          .getTransactions(_token)
          .then((value) => debugPrint("JUST Refetching: : ${value.body}"));
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  @override
  void initState() {
    super.initState();
    _init();
    // setState(() {
    _mWidget = SizedBox(
      child: FundWallet(
        manager: widget.manager!,
      ),
    );

    _nWidget = SizedBox(
      child: WithdrawFund(
        manager: widget.manager!,
      ),
    );

    // });
  }

  String _currentMonth() {
    List<String> _months = [
      "January",
      "February",
      "March",
      "April",
      "May",
      "June",
      "July",
      "August",
      "September",
      "October",
      "November",
      "December"
    ];
    var now = DateTime.now();
    return _months[now.month - 1];
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    final double itemHeight = (size.height - kToolbarHeight - 18) / 2.60;
    final double itemWidth = size.width / 5;

    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        elevation: 0.2,
        backgroundColor: Colors.white,
        automaticallyImplyLeading: false,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipOval(
                  child: Container(
                    height: 44,
                    width: 44,
                    decoration: const BoxDecoration(
                      color: kPrimaryLightColor,
                      borderRadius: BorderRadius.all(Radius.circular(26)),
                    ),
                    padding: const EdgeInsets.all(8.0),
                    child: Center(
                      child: SvgPicture.asset(
                        'assets/images/avatar_drawer.svg',
                        color: kPrimaryColor,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10.0),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextSecondary(
                      text: _name,
                      fontSize: 14,
                      color: kPrimaryColor,
                      fontWeight: FontWeight.w500,
                    ),
                    const SizedBox(height: 2.0),
                    TextPrimary(
                      text: "Welcome Back",
                      fontSize: 21,
                      color: kPrimaryColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(width: 2.0),
          ],
        ),
        centerTitle: false,
        actions: [
          IconButton(
            onPressed: () {
              if (!_scaffoldKey.currentState!.isEndDrawerOpen) {
                _scaffoldKey.currentState!.openEndDrawer();
              }
            },
            icon: SvgPicture.asset(
              'assets/images/menu_icon.svg',
              color: kPrimaryColor,
            ),
          ),
        ],
      ),
      endDrawer: SizedBox(
        height: MediaQuery.of(context).size.height,
        child: CustomDrawer(
          manager: widget.manager!,
        ),
      ),
      body: SafeArea(
        child: Background(
          child: SmartRefresher(
            controller: _refreshController,
            onRefresh: _refreshHome,
            enablePullDown: true,
            enablePullUp: false,
            header: const WaterDropMaterialHeader(
              color: kSecondaryColor,
              backgroundColor: kPrimaryColor,
            ),
            child: ListView(
              padding: const EdgeInsets.all(10.0),
              children: [
                const SizedBox(height: 8.0),
                SizedBox(
                  width: double.infinity,
                  child: Card(
                    elevation: 2.0,
                    color: kPrimaryColor,
                    margin:
                        const EdgeInsets.only(bottom: 18.0, left: 0, right: 0),
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(
                        Radius.circular(12.0),
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Wallet Balance',
                                    style: TextStyle(
                                      color: Colors.white,
                                    ),
                                  ),
                                  Text(
                                    "${nairaSign(context).currencySymbol}$_bal",
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(
                                width: 10.0,
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  ClipRRect(
                                    borderRadius: const BorderRadius.all(
                                      Radius.circular(12.0),
                                    ),
                                    child: ElevatedButton(
                                      onPressed: _name == "Guest User"
                                          ? null
                                          : () {
                                              Navigator.push(
                                                context,
                                                PageTransition(
                                                  type: PageTransitionType
                                                      .rightToLeft,
                                                  isIos: true,
                                                  child: _mWidget,
                                                ),
                                              );
                                            },
                                      child: const Text(
                                        "Top up",
                                        style: TextStyle(
                                            color: kPrimaryColor, fontSize: 13),
                                      ),
                                      style: ElevatedButton.styleFrom(
                                        elevation: 4.0,
                                        backgroundColor: Colors.white,
                                        shape: const RoundedRectangleBorder(
                                          borderRadius: BorderRadius.all(
                                            Radius.circular(18.0),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(
                                    width: 5.0,
                                  ),
                                  ClipRRect(
                                    borderRadius: const BorderRadius.all(
                                      Radius.circular(12.0),
                                    ),
                                    child: ElevatedButton(
                                      onPressed: _name == "Guest User"
                                          ? null
                                          : () {
                                              MBottomSheet
                                                  .showBarModalBottomSheet(
                                                expand: true,
                                                context: context,
                                                backgroundColor:
                                                    Colors.transparent,
                                                builder: (context) => _nWidget,
                                                topControl: ClipOval(
                                                  child: GestureDetector(
                                                    onTap: () {
                                                      Navigator.of(context)
                                                          .pop();
                                                    },
                                                    child: Container(
                                                      width: 32,
                                                      height: 32,
                                                      decoration: BoxDecoration(
                                                        color: Colors.white,
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(
                                                          16,
                                                        ),
                                                      ),
                                                      child: const Center(
                                                        child: Icon(
                                                          Icons.close,
                                                          size: 24,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              );
                                            },
                                      child: const Text(
                                        "Withdraw",
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 13,
                                        ),
                                      ),
                                      style: ElevatedButton.styleFrom(
                                        elevation: 4.0,
                                        backgroundColor: kSecondaryColor,
                                        shape: const RoundedRectangleBorder(
                                          borderRadius: BorderRadius.all(
                                            Radius.circular(18.0),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(
                            height: 12.0,
                          ),
                          const Divider(
                            color: kSecondaryColor,
                          ),
                          const SizedBox(
                            height: 12.0,
                          ),
                          _name == "Guest User"
                              ? const SizedBox()
                              : Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          '${_currentMonth()} Expense',
                                          style: const TextStyle(
                                            fontSize: 13,
                                            color: Colors.white,
                                          ),
                                        ),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                            const Icon(
                                              CupertinoIcons.creditcard_fill,
                                              color: Colors.white,
                                            ),
                                            const SizedBox(
                                              width: 4.0,
                                            ),
                                            Text(
                                              "${nairaSign(context).currencySymbol}${widget.manager!.getUser()['month_amount_spent']}",
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                    const SizedBox(
                                      width: 16.0,
                                    ),
                                    Column(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.end,
                                      children: [
                                        const Text(
                                          'Transactions',
                                          style: TextStyle(
                                            fontSize: 13,
                                            color: Colors.white,
                                          ),
                                        ),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                            const Icon(
                                              CupertinoIcons
                                                  .chart_bar_square_fill,
                                              color: Colors.white,
                                            ),
                                            Text(
                                              "${widget.manager!.getUser()['month_transaction_count']}",
                                              style: const TextStyle(
                                                fontSize: 16,
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10.0),
                TextSecondary(
                  text: 'Services',
                  fontSize: 18,
                  color: kPrimaryColor,
                  fontWeight: FontWeight.w700,
                ),
                const SizedBox(height: 5.0),
                GridView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 4,
                    mainAxisSpacing: 2.0,
                    crossAxisSpacing: 2.0,
                    childAspectRatio: (itemWidth / (itemWidth + 16)),
                  ),
                  shrinkWrap: true,
                  itemBuilder: (context, index) => ServiceCard(
                    model: serviceList[index],
                    manager: widget.manager!,
                    isAuthenticated: _isAuthenticated,
                  ),
                  itemCount: serviceList.length,
                ),
                const SizedBox(height: 10.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    TextSecondary(
                      text: 'Transactions',
                      fontSize: 18,
                      color: kPrimaryColor,
                      fontWeight: FontWeight.w700,
                    ),
                    InkWell(
                      onTap: () {
                        _controller.selectTab(
                          Transactions(
                            manager: widget.manager,
                            model: _isAuthenticated ? _transactionList : [],
                            guestModel:
                                _isAuthenticated ? [] : _transactionListGuest,
                          ),
                          _controller.pageKeys[1],
                          1,
                        );
                      },
                      child: Padding(
                        padding: const EdgeInsets.only(
                          left: 8.0,
                          top: 8.0,
                          bottom: 8.0,
                        ),
                        child: TextSecondary(
                          text: 'View all',
                          fontSize: 14,
                          color: kPrimaryColor,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8.0),
                RecentTransactions(
                  isAuthenticated: _isAuthenticated,
                  manager: widget.manager!,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  _refreshHome() async {
    _controller.setLoading(true);
    _refreshController.requestRefresh();

    //Update user data
    try {
      final _prefs = await SharedPreferences.getInstance();
      final _token = _prefs.getString("accessToken") ?? "";

      if (_token.isNotEmpty) {
        final userResp = await APIService().getProfile(_token);
        debugPrint("USER PROFILE ::: ${userResp.body}");

        if (userResp.statusCode == 200) {
          Map<String, dynamic> userMap = jsonDecode(userResp.body);

          String userData = jsonEncode(userMap['data']);
          _prefs.setString("user", userData);
          // widget.manager?.updateUserData(userData);
        } else {}

        // _controller.setRecentTransactions([]);
        _controller.recentTransactions.value = [];
        _controller.transactions.value = [];

        await Future.delayed(
          const Duration(seconds: 2),
          () {
            APIService().fetchTransactions(_token);
          },
        );

        Future.delayed(
          const Duration(seconds: 3),
          () {
            _controller.setLoading(false);
            _refreshController.refreshCompleted();
          },
        );
      }
    } catch (e) {
      debugPrint(e.toString());
      _controller.setLoading(false);
      _refreshController.refreshFailed();
    }
  }
}
