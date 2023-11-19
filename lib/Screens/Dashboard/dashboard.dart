import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' hide ModalBottomSheetRoute;
import 'package:flutter_svg/svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:loading_overlay_pro/loading_overlay_pro.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart' as MBottomSheet;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../components/glassmorphism/glass_card.dart';
import '../../components/rounded_button.dart';
import '../../components/text/text_widget.dart';
import '../../constants.dart';
import '../../helper/database/database_handler.dart';
import '../../helper/navigator/auth_controller.dart';
import '../../helper/navigator/tab_navigator.dart';
import '../../helper/preferences/preference_manager.dart';
import '../../helper/service/api_service.dart';
import '../../helper/state/state_controller.dart';
import '../../model/transactions/guest_transaction_model.dart';
import '../../model/transactions/user/user_transaction.dart';
import '../Account/account.dart';
import '../Home/home.dart';
import '../Internet/no_internet.dart';
import '../Messages/messages.dart';
import '../Transactions/transactions.dart';

class Dashboard extends StatefulWidget {
  final PreferenceManager manager;
  const Dashboard({Key? key, required this.manager}) : super(key: key);

  @override
  _DashboardState createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  int currentPage = 0;

  final PageStorageBucket _pageStorageBucket = PageStorageBucket();
  late Widget currentScreen;
  bool _hideNav = false;
  bool _hasNetwork = true;
  List<Widget> tabs = [];
  bool _isLoggedIn = false;
  String _token = "";

  // ignore: unused_field
  final _controller = Get.find<StateController>();
  DateTime pre_backpress = DateTime.now();
  List<UserTransaction> _transactionList = [];
  List<GuestTransactionModel> _transactionListGuest = [];
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  final timegap = DateTime.now().difference(DateTime.now());

  void onHideNav(bool val) {
    setState(() {
      _hideNav = val;
    });
  }

  _parseState() async {
    final prefs = await SharedPreferences.getInstance();
    bool _isLoggedIn = prefs.getBool("loggedIn") ?? false;
    // debugPrint("AUTHED:: $_isLoggedIn");
    if (_isLoggedIn) {
      var data = _controller.transactions.value;
      for (var v in data) {
        _transactionList.add(UserTransaction.fromJson(v));
      }
    } else {
      final resp = await DatabaseHandler().transactions();
      setState(() {
        _transactionListGuest = resp;
      });
    }
  }

  _initAuth() async {
    final prefs = await SharedPreferences.getInstance();
    _isLoggedIn = prefs.getBool("loggedIn") ?? false;
    _token = prefs.getString("accessToken") ?? "";

    if (_isLoggedIn) {
      // await APIService().fetchTransactions(_token);
      _parseState();
    }
  }

  _getProducts() async {
    try {
      final response = await APIService().getProducts();
      debugPrint("PRODUCT RESP:: ${response.body}");
      _controller.setHasInternet(true);
      if (response.statusCode == 200) {
        Map<String, dynamic> map = jsonDecode(response.body);
        // ProductResponse body = ProductResponse.fromJson(map);
        _controller.setProductData(map);
      }
    } on SocketException {
      // toast("No Internet Connection!");
      // _controller.setHasInternet(false);
    } on Error catch (e) {
      debugPrint(e.toString());
    }
  }

  @override
  void initState() {
    super.initState();
    // _getProducts();
    setState(() {
      tabs = [
        Home(
          manager: widget.manager,
        ),
        Transactions(
          manager: widget.manager,
          model: _isLoggedIn ? _transactionList : [],
          guestModel: _isLoggedIn ? [] : _transactionListGuest,
        ),
        AuthController(
          manager: widget.manager,
          child: Messages(
            manager: widget.manager,
          ),
        ),
        AuthController(
          manager: widget.manager,
          child: Account(
            manager: widget.manager,
          ),
        ),
      ];
      currentScreen = const Home();
    });
  }

  Future<void> _launchInBrowser(String url) async {
    if (await canLaunch(url)) {
      await launch(
        url,
        forceSafariVC: false,
        forceWebView: false,
        headers: <String, String>{'my_header_key': 'my_header_value'},
      );
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _getProducts();
    _initAuth();
  }

  @override
  Widget build(BuildContext context) {
    bool keyboardIsOpened = MediaQuery.of(context).viewInsets.bottom != 0.0;

    return WillPopScope(
      onWillPop: () async {
        final timegap = DateTime.now().difference(pre_backpress);
        final cantExit = timegap >= const Duration(seconds: 4);
        pre_backpress = DateTime.now();
        if (cantExit) {
          Fluttertoast.showToast(
            msg: "Press again to exit",
            toastLength: Toast.LENGTH_LONG,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 3,
            backgroundColor: Colors.grey[800],
            textColor: Colors.white,
            fontSize: 16.0,
          );

          return false; // false will do nothing when back press
        } else {
          // _controller.triggerAppExit(true);
          if (Platform.isAndroid) {
            exit(0);
          } else if (Platform.isIOS) {
            // Navigator.pushReplacement(
            //   context,
            //   MaterialPageRoute(
            //     builder: (context) => Onboarding(
            //       shouldClose: true,
            //     ),
            //   ),
            // );
          }
          return true;
        }
      },
      child: Obx(
        () => LoadingOverlayPro(
          isLoading: _controller.isLoading.value,
          progressIndicator: const CircularProgressIndicator.adaptive(),
          backgroundColor: Colors.black54,
          child: !_controller.hasInternetAccess.value
              ? NoInternet()
              : Scaffold(
                  body: Scaffold(
                    key: _scaffoldKey,
                    body: TabNavigator(
                      navigatorKey:
                          _controller.navigatorKeys[_controller.currentPage]!,
                      tabItem: _controller.currentPage,
                      manager: widget.manager,
                      model: _isLoggedIn ? _transactionList : [],
                      guestModel: _isLoggedIn ? [] : _transactionListGuest,
                    ),
                  ),
                  floatingActionButton: (keyboardIsOpened ||
                          _controller.hideNavbar.value ||
                          !widget.manager.getIsLoggedIn())
                      ? null
                      : FloatingActionButton(
                          heroTag: "btn1",
                          onPressed: () {
                            MBottomSheet.showBarModalBottomSheet(
                              expand: true,
                              context: _scaffoldKey.currentState!.context,
                              backgroundColor: Colors.transparent,
                              builder: (context) => SizedBox(
                                  child: Container(
                                color: kPrimaryColor,
                                padding: const EdgeInsets.all(16.0),
                                child: Stack(
                                  children: [
                                    Image.asset("assets/images/pattern.png",
                                        fit: BoxFit.cover),
                                    Positioned(
                                      top: 1,
                                      bottom: 1,
                                      right: 1,
                                      left: 1,
                                      child: Column(
                                        children: [
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            children: [
                                              TextPrimary(
                                                text: "Deepay",
                                                fontSize: 22,
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                              ),
                                              const SizedBox(
                                                width: 5.0,
                                              ),
                                              TextPrimary(
                                                text: "Enterprise",
                                                fontSize: 22,
                                                color: kSecondaryColor,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ],
                                          ),
                                          const SizedBox(
                                            height: 21.0,
                                          ),
                                          GlassCard(
                                            manager: widget.manager,
                                          ),
                                          const SizedBox(
                                            height: 16.0,
                                          ),
                                          TextSecondary(
                                            text:
                                                "An online bill payement platform that allows users to remotely pay for value added services online. A platform for all your Telecom needs. Use more, Pay less.",
                                            fontSize: 14,
                                            color: Colors.white,
                                            align: TextAlign.justify,
                                          ),
                                          const SizedBox(
                                            height: 8.0,
                                          ),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            children: [
                                              const Icon(
                                                CupertinoIcons
                                                    .check_mark_circled_solid,
                                                color: Colors.white38,
                                              ),
                                              const SizedBox(
                                                width: 8.0,
                                              ),
                                              TextSecondary(
                                                text: "Cheap and Reliable",
                                                fontSize: 14,
                                                color: Colors.white,
                                              )
                                            ],
                                          ),
                                          const SizedBox(
                                            height: 5.0,
                                          ),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            children: [
                                              const Icon(
                                                CupertinoIcons
                                                    .check_mark_circled_solid,
                                                color: Colors.white38,
                                              ),
                                              const SizedBox(
                                                width: 8.0,
                                              ),
                                              TextSecondary(
                                                text: "Data Security",
                                                fontSize: 14,
                                                color: Colors.white,
                                              )
                                            ],
                                          ),
                                          const SizedBox(
                                            height: 5.0,
                                          ),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            children: [
                                              const Icon(
                                                CupertinoIcons
                                                    .check_mark_circled_solid,
                                                color: Colors.white38,
                                              ),
                                              const SizedBox(
                                                width: 8.0,
                                              ),
                                              TextSecondary(
                                                text: "24/7 support",
                                                fontSize: 14,
                                                color: Colors.white,
                                              )
                                            ],
                                          ),
                                          const SizedBox(
                                            height: 5.0,
                                          ),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            children: [
                                              const Icon(
                                                CupertinoIcons
                                                    .check_mark_circled_solid,
                                                color: Colors.white38,
                                              ),
                                              const SizedBox(
                                                width: 8.0,
                                              ),
                                              TextSecondary(
                                                text:
                                                    "Affordable and Flexible payment options",
                                                fontSize: 14,
                                                color: Colors.white,
                                              )
                                            ],
                                          ),
                                          const SizedBox(
                                            height: 16.0,
                                          ),
                                          RoundedButton(
                                            text: "Visit Site",
                                            press: () {
                                              Navigator.of(context).pop();
                                              _launchInBrowser(
                                                  "https://deepay.com.ng/");
                                            },
                                            color: kSecondaryColor,
                                          )
                                        ],
                                      ),
                                    )
                                  ],
                                ),
                              )),
                              topControl: ClipOval(
                                child: GestureDetector(
                                  onTap: () {
                                    Navigator.of(context).pop();
                                  },
                                  child: Container(
                                    width: 32,
                                    height: 32,
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(
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
                          child: const Icon(
                            CupertinoIcons
                                .line_horizontal_3_decrease_circle_fill,
                            color: Colors.white,
                          ),
                          backgroundColor: kPrimaryColor,
                        ),
                  floatingActionButtonLocation:
                      FloatingActionButtonLocation.centerDocked,
                  bottomNavigationBar: _controller.hideNavbar.value
                      ? null
                      : BottomAppBar(
                          shape: !widget.manager.getIsLoggedIn()
                              ? null
                              : const CircularNotchedRectangle(),
                          notchMargin: !widget.manager.getIsLoggedIn() ? 0 : 18,
                          child: Container(
                            height: 60,
                            child: !widget.manager.getIsLoggedIn()
                                ? Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      MaterialButton(
                                        onPressed: () {
                                          _controller.selectTab(
                                            Home(
                                              manager: widget.manager,
                                            ),
                                            _controller.pageKeys[0],
                                            0,
                                          );
                                        },
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            SvgPicture.asset(
                                              _controller.selectedIndex.value ==
                                                      0
                                                  ? "assets/images/home.svg"
                                                  : "assets/images/home_outline.svg",
                                              height: 21,
                                              width: 21,
                                              color: _controller.selectedIndex
                                                          .value ==
                                                      0
                                                  ? kPrimaryColor
                                                  : kPrimaryLightColor,
                                            ),
                                            const SizedBox(height: 1.0),
                                            TextSecondary(
                                              text: 'Home',
                                              color: _controller.selectedIndex
                                                          .value ==
                                                      0
                                                  ? kPrimaryColor
                                                  : kPrimaryLightColor,
                                              fontSize: 10,
                                            ),
                                          ],
                                        ),
                                        minWidth: 40,
                                      ),
                                      MaterialButton(
                                        onPressed: () {
                                          _controller.selectTab(
                                            Transactions(
                                              manager: widget.manager,
                                              model: _isLoggedIn
                                                  ? _transactionList
                                                  : [],
                                              guestModel: _isLoggedIn
                                                  ? []
                                                  : _transactionListGuest,
                                            ),
                                            _controller.pageKeys[1],
                                            1,
                                          );
                                        },
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            SvgPicture.asset(
                                              _controller.selectedIndex.value ==
                                                      1
                                                  ? "assets/images/receipt.svg"
                                                  : "assets/images/receipt_outline.svg",
                                              height: 21,
                                              width: 21,
                                              color: _controller.selectedIndex
                                                          .value ==
                                                      1
                                                  ? kPrimaryColor
                                                  : kPrimaryLightColor,
                                            ),
                                            const SizedBox(height: 1.0),
                                            TextSecondary(
                                              text: 'Transactions',
                                              color: _controller.selectedIndex
                                                          .value ==
                                                      1
                                                  ? kPrimaryColor
                                                  : kPrimaryLightColor,
                                              fontSize: 10,
                                            ),
                                          ],
                                        ),
                                        minWidth: 40,
                                      ),
                                      MaterialButton(
                                        onPressed: () {
                                          _controller.selectTab(
                                            AuthController(
                                              manager: widget.manager,
                                              child: Messages(
                                                manager: widget.manager,
                                              ),
                                              onHide: onHideNav,
                                            ),
                                            _controller.pageKeys[2],
                                            2,
                                          );
                                        },
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Stack(
                                              children: [
                                                SvgPicture.asset(
                                                  _controller.selectedIndex
                                                              .value ==
                                                          2
                                                      ? "assets/images/envelope.svg"
                                                      : "assets/images/envelope_outline.svg",
                                                  height: 21,
                                                  width: 21,
                                                  color: _controller
                                                              .selectedIndex
                                                              .value ==
                                                          2
                                                      ? kPrimaryColor
                                                      : kPrimaryLightColor,
                                                ),
                                                const SizedBox(height: 1.0),
                                                Positioned(
                                                  top: 1,
                                                  right: 4,
                                                  child: ClipOval(
                                                    child: _controller
                                                                .unreadNotifications
                                                                .value >
                                                            0
                                                        ? Container(
                                                            padding:
                                                                const EdgeInsets
                                                                    .all(2.5),
                                                            color: Colors.red,
                                                          )
                                                        : const SizedBox(),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            TextSecondary(
                                              text: 'Messages',
                                              color: _controller.selectedIndex
                                                          .value ==
                                                      2
                                                  ? kPrimaryColor
                                                  : kPrimaryLightColor,
                                              fontSize: 10,
                                            ),
                                          ],
                                        ),
                                        minWidth: 40,
                                      ),
                                      MaterialButton(
                                        onPressed: () {
                                          _controller.selectTab(
                                            AuthController(
                                              manager: widget.manager,
                                              child: Account(
                                                  manager: widget.manager),
                                              onHide: onHideNav,
                                            ),
                                            _controller.pageKeys[3],
                                            3,
                                          );
                                        },
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            SvgPicture.asset(
                                              _controller.selectedIndex.value ==
                                                      3
                                                  ? "assets/images/portrait.svg"
                                                  : "assets/images/portrait_outline.svg",
                                              height: 21,
                                              width: 21,
                                              color: _controller.selectedIndex
                                                          .value ==
                                                      3
                                                  ? kPrimaryColor
                                                  : kPrimaryLightColor,
                                            ),
                                            const SizedBox(height: 1.0),
                                            TextSecondary(
                                              text: 'Account',
                                              color: _controller.selectedIndex
                                                          .value ==
                                                      3
                                                  ? kPrimaryColor
                                                  : kPrimaryLightColor,
                                              fontSize: 10,
                                            ),
                                          ],
                                        ),
                                        minWidth: 40,
                                      ),
                                    ],
                                  )
                                : Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          MaterialButton(
                                            onPressed: () {
                                              _controller.selectTab(
                                                Home(
                                                  manager: widget.manager,
                                                ),
                                                _controller.pageKeys[0],
                                                0,
                                              );
                                            },
                                            child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                SvgPicture.asset(
                                                  _controller.selectedIndex
                                                              .value ==
                                                          0
                                                      ? "assets/images/home.svg"
                                                      : "assets/images/home_outline.svg",
                                                  height: 21,
                                                  width: 21,
                                                  color: _controller
                                                              .selectedIndex
                                                              .value ==
                                                          0
                                                      ? kPrimaryColor
                                                      : kPrimaryLightColor,
                                                ),
                                                const SizedBox(height: 1.0),
                                                TextSecondary(
                                                  text: 'Home',
                                                  color: _controller
                                                              .selectedIndex
                                                              .value ==
                                                          0
                                                      ? kPrimaryColor
                                                      : kPrimaryLightColor,
                                                  fontSize: 10,
                                                ),
                                              ],
                                            ),
                                            minWidth: 40,
                                          ),
                                          MaterialButton(
                                            onPressed: () {
                                              _controller.selectTab(
                                                Transactions(
                                                  manager: widget.manager,
                                                  model: _isLoggedIn
                                                      ? _transactionList
                                                      : [],
                                                  guestModel: _isLoggedIn
                                                      ? []
                                                      : _transactionListGuest,
                                                ),
                                                _controller.pageKeys[1],
                                                1,
                                              );
                                            },
                                            child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                SvgPicture.asset(
                                                  _controller.selectedIndex
                                                              .value ==
                                                          1
                                                      ? "assets/images/receipt.svg"
                                                      : "assets/images/receipt_outline.svg",
                                                  height: 21,
                                                  width: 21,
                                                  color: _controller
                                                              .selectedIndex
                                                              .value ==
                                                          1
                                                      ? kPrimaryColor
                                                      : kPrimaryLightColor,
                                                ),
                                                const SizedBox(height: 1.0),
                                                TextSecondary(
                                                  text: 'Transactions',
                                                  color: _controller
                                                              .selectedIndex
                                                              .value ==
                                                          1
                                                      ? kPrimaryColor
                                                      : kPrimaryLightColor,
                                                  fontSize: 10,
                                                ),
                                              ],
                                            ),
                                            minWidth: 40,
                                          )
                                        ],
                                      ),
                                      //Right side of tab
                                      Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          MaterialButton(
                                            onPressed: () {
                                              _controller.selectTab(
                                                AuthController(
                                                  manager: widget.manager,
                                                  child: Messages(
                                                    manager: widget.manager,
                                                  ),
                                                  onHide: onHideNav,
                                                ),
                                                _controller.pageKeys[2],
                                                2,
                                              );
                                            },
                                            child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Stack(
                                                  children: [
                                                    SvgPicture.asset(
                                                      _controller.selectedIndex
                                                                  .value ==
                                                              2
                                                          ? "assets/images/envelope.svg"
                                                          : "assets/images/envelope_outline.svg",
                                                      height: 21,
                                                      width: 21,
                                                      color: _controller
                                                                  .selectedIndex
                                                                  .value ==
                                                              2
                                                          ? kPrimaryColor
                                                          : kPrimaryLightColor,
                                                    ),
                                                    const SizedBox(height: 1.0),
                                                    Positioned(
                                                      top: 1,
                                                      right: 4,
                                                      child: ClipOval(
                                                        child: _controller
                                                                    .unreadNotifications
                                                                    .value >
                                                                0
                                                            ? Container(
                                                                padding:
                                                                    const EdgeInsets
                                                                            .all(
                                                                        2.5),
                                                                color:
                                                                    Colors.red,
                                                              )
                                                            : const SizedBox(),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                TextSecondary(
                                                  text: 'Messages',
                                                  color: _controller
                                                              .selectedIndex
                                                              .value ==
                                                          2
                                                      ? kPrimaryColor
                                                      : kPrimaryLightColor,
                                                  fontSize: 10,
                                                ),
                                              ],
                                            ),
                                            minWidth: 40,
                                          ),
                                          MaterialButton(
                                            onPressed: () {
                                              _controller.selectTab(
                                                AuthController(
                                                  manager: widget.manager,
                                                  child: Account(
                                                      manager: widget.manager),
                                                  onHide: onHideNav,
                                                ),
                                                _controller.pageKeys[3],
                                                3,
                                              );
                                            },
                                            child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                SvgPicture.asset(
                                                  _controller.selectedIndex
                                                              .value ==
                                                          3
                                                      ? "assets/images/portrait.svg"
                                                      : "assets/images/portrait_outline.svg",
                                                  height: 21,
                                                  width: 21,
                                                  color: _controller
                                                              .selectedIndex
                                                              .value ==
                                                          3
                                                      ? kPrimaryColor
                                                      : kPrimaryLightColor,
                                                ),
                                                const SizedBox(height: 1.0),
                                                TextSecondary(
                                                  text: 'Account',
                                                  color: _controller
                                                              .selectedIndex
                                                              .value ==
                                                          3
                                                      ? kPrimaryColor
                                                      : kPrimaryLightColor,
                                                  fontSize: 10,
                                                ),
                                              ],
                                            ),
                                            minWidth: 40,
                                          )
                                        ],
                                      )
                                    ],
                                  ),
                          ),
                        ),
                ),
        ),
      ),
    );
  }
}
