import 'package:flutter/material.dart' hide ModalBottomSheetRoute;
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart' as MBottomSheet;
import 'package:page_transition/page_transition.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timeago/timeago.dart' as timeago;

import '../../components/background/background.dart';
import '../../components/drawer/custom_drawer.dart';
import '../../components/rounded_button.dart';
import '../../components/text/text_widget.dart';
import '../../constants.dart';
import '../../helper/database/database_handler.dart';
import '../../helper/preferences/preference_manager.dart';
import '../../helper/state/state_controller.dart';
import '../../model/transactions/guest_transaction_model.dart';
import '../services/service_info.dart';
import 'complete_transaction.dart';
import 'components/wallet_log.dart';
import 'transactions.dart';

class TransactionDetail extends StatefulWidget {
  final GuestTransactionModel? guestModel;
  var model;
  final PreferenceManager manager;
  TransactionDetail({
    Key? key,
    this.guestModel,
    this.model,
    required this.manager,
  }) : super(key: key);

  @override
  State<TransactionDetail> createState() => _TransactionDetailState();
}

class _TransactionDetailState extends State<TransactionDetail> {
  final _controller = Get.find<StateController>();
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  bool _isAuthenticated = false;
  var _token = "";
  double _discount = 0.0;

  final List<dynamic> _transactionList = [];
  List<GuestTransactionModel> _transactionListGuest = [];

  String timeUntil(DateTime date) {
    return timeago.format(date, locale: "en", allowFromNow: true);
  }

  _buyAgain() async {
    _controller.setLoading(true);

    final _prefs = await SharedPreferences.getInstance();
    _token = _prefs.getString("accessToken") ?? "";

    Future.delayed(const Duration(seconds: 2), () {
      _controller.setLoading(false);
      Navigator.push(
        context,
        PageTransition(
          type: PageTransitionType.rightToLeft,
          isIos: true,
          child: ServiceInfo(
            service: "${widget.model['type'] ?? widget.guestModel?.type}" ==
                    "cable_tv"
                ? "Cable_TV"
                : "${widget.model['type'] ?? widget.guestModel?.type}",
            isAuthenticated: "$_token".isEmpty ? false : true,
          ),
        ),
      );
    });
  }

  _init() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _isAuthenticated = prefs.getBool('loggedIn') ?? false;

      if (_isAuthenticated) {
        var data = _controller.transactions.value;
        // debugPrint("MJKD::: $data");
        for (var v in data) {
          _transactionList.add(v);
        }
      } else {
        //Fetch from sqlite
        final resp = await DatabaseHandler().transactions();
        setState(() {
          _transactionListGuest = resp;
        });
      }
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  @override
  void initState() {
    super.initState();
    _init();
    debugPrint("MJKD::: ${widget.model}");
  }

  Widget _statusWidget(String? status) {
    return ClipRRect(
      borderRadius: const BorderRadius.all(Radius.circular(6.0)),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.33,
        padding: const EdgeInsets.all(2.0),
        color: status == "success"
            ? const Color(0x684CAF4F)
            : (status == "cancelled" || status == "failed")
                ? const Color(0x928C1414)
                : const Color(0x97C06C18),
        child: Center(
          child: TextSecondary(
            text: status?.capitalize,
            color: status == "success"
                ? Colors.green
                : (status == "cancelled" || status == "failed")
                    ? Colors.red
                    : Colors.amber,
            fontSize: 20,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: kPrimaryColor,
      appBar: AppBar(
        elevation: 0.2,
        backgroundColor: Colors.white,
        automaticallyImplyLeading: false,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            InkWell(
              onTap: () {
                Navigator.pop(context);
              },
              child: const Icon(
                Icons.arrow_back_rounded,
                color: kPrimaryColor,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            TextSecondary(
              text: (widget.model['type'].toLowerCase() == "cable_tv" ||
                      widget.guestModel?.type?.toLowerCase() == "cable_tv")
                  ? "Cable TV Transaction"
                  : (widget.model['type'].toLowerCase() == "fund_wallet" ||
                          widget.guestModel?.type?.toLowerCase() ==
                              "fund_wallet")
                      ? "Wallet Transaction"
                      : (widget.model['type'].toLowerCase())
                              .startsWith("system")
                          ? "System Transaction"
                          : "${widget.model['type'] ?? widget.guestModel?.type} Transaction"
                              .capitalize,
              fontSize: 21,
              fontWeight: FontWeight.w700,
              color: kPrimaryColor,
            ),
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
          manager: widget.manager,
        ),
      ),
      body: Stack(
        children: [
          Image.asset("assets/images/pattern.png"),
          SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 4.0),
                Expanded(
                  flex: 2,
                  child: Column(
                    children: [
                      const SizedBox(height: 36.0),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          TextSecondary(
                            text:
                                "${widget.model['transaction_ref'] ?? widget.guestModel?.transactionRef}",
                            fontSize: 18,
                            color: Colors.white,
                          ),
                          const SizedBox(height: 10.0),
                          _statusWidget(
                            "${widget.model['status'] ?? widget.guestModel?.status}",
                          )
                        ],
                      ),
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16.0,
                                vertical: 4.0,
                              ),
                              child: (widget.model['type'].toLowerCase())
                                      .startsWith("system")
                                  ? const SizedBox()
                                  : Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceAround,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        "${widget.model['type'] ?? widget.guestModel?.type}" ==
                                                "fund_wallet"
                                            ? const SizedBox()
                                            : Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.center,
                                                children: [
                                                  ClipOval(
                                                    child: TextButton(
                                                      onPressed: () {
                                                        _buyAgain();
                                                      },
                                                      child: Container(
                                                        width: 48,
                                                        height: 48,
                                                        decoration:
                                                            BoxDecoration(
                                                          borderRadius:
                                                              const BorderRadius
                                                                  .all(
                                                            Radius.circular(24),
                                                          ),
                                                          border: Border.all(
                                                            color: Colors.white,
                                                            width: 1.0,
                                                          ),
                                                        ),
                                                        child: const Center(
                                                          child: Icon(
                                                            Icons
                                                                .repeat_one_rounded,
                                                            color: Colors.white,
                                                            size: 28,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                  TextSecondary(
                                                    text: "Buy Again",
                                                    fontSize: 12,
                                                    color: Colors.white,
                                                  ),
                                                ],
                                              ),
                                        const SizedBox(width: 1.0),
                                        "${widget.model['status'] ?? widget.guestModel?.status}"
                                                    .toLowerCase() !=
                                                "success"
                                            ? const SizedBox()
                                            : Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.center,
                                                children: [
                                                  ClipOval(
                                                    child: TextButton(
                                                      onPressed: () {
                                                        MBottomSheet
                                                            .showBarModalBottomSheet(
                                                          expand: false,
                                                          context: context,
                                                          backgroundColor:
                                                              Colors.white,
                                                          builder: (context) =>
                                                              SizedBox(
                                                            height: 300,
                                                            child: ListView(
                                                              padding:
                                                                  const EdgeInsets
                                                                      .all(
                                                                16.0,
                                                              ),
                                                              children: [
                                                                const SizedBox(
                                                                  height: 10.0,
                                                                ),
                                                                TextPrimary(
                                                                  text:
                                                                      "Wallet Log",
                                                                  fontSize: 21,
                                                                  color:
                                                                      kPrimaryColor,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                  align: TextAlign
                                                                      .center,
                                                                ),
                                                                const SizedBox(
                                                                  height: 48,
                                                                ),
                                                                WalletLog(
                                                                  walletData: widget
                                                                          .model[
                                                                      'wallet_log'],
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                          topControl: ClipOval(
                                                            child:
                                                                GestureDetector(
                                                              onTap: () {
                                                                Navigator.of(
                                                                        context)
                                                                    .pop();
                                                              },
                                                              child: Container(
                                                                width: 32,
                                                                height: 32,
                                                                decoration:
                                                                    BoxDecoration(
                                                                  color: Colors
                                                                      .white,
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                    16,
                                                                  ),
                                                                ),
                                                                child:
                                                                    const Center(
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
                                                      child: Container(
                                                        width: 48,
                                                        height: 48,
                                                        decoration:
                                                            BoxDecoration(
                                                          borderRadius:
                                                              const BorderRadius
                                                                  .all(
                                                            Radius.circular(24),
                                                          ),
                                                          border: Border.all(
                                                            color: Colors.white,
                                                            width: 1.0,
                                                          ),
                                                        ),
                                                        child: const Center(
                                                          child: Icon(
                                                            Icons
                                                                .watch_later_outlined,
                                                            color: Colors.white,
                                                            size: 28,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                  TextSecondary(
                                                    text: "Wallet Log",
                                                    fontSize: 12,
                                                    color: Colors.white,
                                                  ),
                                                ],
                                              ),
                                        const SizedBox(width: 1.0),
                                        Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                            ClipOval(
                                              child: TextButton(
                                                onPressed: () {
                                                  _controller.selectTab(
                                                    Transactions(
                                                      manager: widget.manager,
                                                      model: _isAuthenticated
                                                          ? _transactionList
                                                          : [],
                                                      guestModel: _isAuthenticated
                                                          ? []
                                                          : _transactionListGuest,
                                                    ),
                                                    _controller.pageKeys[1],
                                                    1,
                                                  );
                                                },
                                                child: Container(
                                                  width: 48,
                                                  height: 48,
                                                  decoration: BoxDecoration(
                                                    borderRadius:
                                                        const BorderRadius.all(
                                                      Radius.circular(24),
                                                    ),
                                                    border: Border.all(
                                                      color: Colors.white,
                                                      width: 1.0,
                                                    ),
                                                  ),
                                                  child: const Center(
                                                    child: Icon(
                                                      Icons.business,
                                                      color: Colors.white,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                            TextSecondary(
                                              text: "Transactions",
                                              fontSize: 12,
                                              color: Colors.white,
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                            ),
                            const SizedBox(height: 8.0),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: Container(
                    color: Colors.white,
                    child: Background(
                      child: ListView(
                        children: [
                          const SizedBox(height: 16.0),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16.0,
                              vertical: 10.0,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                TextSecondary(
                                  text: "Email",
                                  fontSize: 16,
                                  color: kPrimaryColor,
                                  fontWeight: FontWeight.w600,
                                ),
                                TextSecondary(
                                  text:
                                      "${widget.model['email'] ?? widget.guestModel?.email}",
                                  fontSize: 14,
                                ),
                              ],
                            ),
                          ),
                          const Divider(),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16.0,
                              vertical: 10.0,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                TextSecondary(
                                  text: "Amount",
                                  fontSize: 16,
                                  color: kPrimaryColor,
                                  fontWeight: FontWeight.w600,
                                ),
                                TextSecondary(
                                  text:
                                      "${nairaSign(context).currencySymbol}${widget.model['amount'] ?? widget.guestModel?.amount}",
                                  fontSize: 14,
                                ),
                              ],
                            ),
                          ),
                          Column(
                            children: ((widget.model['amount_paid'] ??
                                        widget.guestModel?.amountPaid) ==
                                    null)
                                ? [const SizedBox()]
                                : [
                                    const Divider(),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 16.0,
                                        vertical: 10.0,
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          TextSecondary(
                                            text: "Amount paid",
                                            fontSize: 16,
                                            color: kPrimaryColor,
                                            fontWeight: FontWeight.w600,
                                          ),
                                          TextSecondary(
                                            text:
                                                "${nairaSign(context).currencySymbol}${widget.model['amount_paid'] ?? widget.guestModel?.amountPaid}",
                                            fontSize: 14,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                          ),
                          const Divider(),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16.0,
                              vertical: 10.0,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                TextSecondary(
                                  text: "Discount(%)",
                                  fontSize: 16,
                                  color: kPrimaryColor,
                                  fontWeight: FontWeight.w600,
                                ),
                                TextSecondary(
                                  text:
                                      "${widget.model['discount_text'] ?? widget.guestModel?.discountText}",
                                  fontSize: 14,
                                ),
                              ],
                            ),
                          ),
                          Column(
                            children: ((widget.model['payment_method'] ??
                                        widget.guestModel?.paymentMethod) ==
                                    null)
                                ? [const SizedBox()]
                                : [
                                    const Divider(),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 16.0,
                                        vertical: 10.0,
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          TextSecondary(
                                            text: "Payment method",
                                            fontSize: 16,
                                            color: kPrimaryColor,
                                            fontWeight: FontWeight.w600,
                                          ),
                                          TextSecondary(
                                            text:
                                                "${widget.model['payment_method'] ?? widget.guestModel?.paymentMethod}",
                                            fontSize: 14,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                          ),
                          const Divider(),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16.0,
                              vertical: 10.0,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                TextSecondary(
                                  text: "Date",
                                  fontSize: 16,
                                  color: kPrimaryColor,
                                  fontWeight: FontWeight.w600,
                                ),
                                TextSecondary(
                                  text:
                                      "${DateFormat('E,d MMM yyyy HH:mm:ss').format(DateTime.parse("${widget.model['created_at'] ?? widget.guestModel?.createdAt}"))} (${timeUntil(DateTime.parse("${widget.model['created_at'] ?? widget.guestModel?.createdAt}"))})",
                                  fontSize: 14,
                                ),
                              ],
                            ),
                          ),
                          const Divider(),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16.0,
                              vertical: 10.0,
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                TextSecondary(
                                  text: "Description",
                                  fontSize: 16,
                                  color: kPrimaryColor,
                                  fontWeight: FontWeight.w600,
                                ),
                                TextSecondary(
                                  text:
                                      "${widget.model['description'] ?? widget.guestModel?.description}",
                                  fontSize: 14,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16.0),
                          (widget.model['status'] ?? widget.guestModel?.status)
                                      ?.toLowerCase() ==
                                  "initiated"
                              ? Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16.0,
                                    vertical: 10.0,
                                  ),
                                  child: RoundedButton(
                                    text: "Complete Transaction",
                                    press: () async {
                                      final _prefs =
                                          await SharedPreferences.getInstance();
                                      _token =
                                          _prefs.getString("accessToken") ?? "";

                                      if (double.parse(
                                                  "${widget.model['discount_percent'] ?? 0.0}") >
                                              0.0 ||
                                          double.parse(
                                                  "${widget.guestModel?.discountPercent ?? 0.0}") >
                                              0.0) {
                                        if (widget.model != null) {
                                          // setState(() {
                                          var _rem = (double.parse(
                                                      "${widget.model['discount_percent']}") /
                                                  100) *
                                              double.parse(
                                                  "${widget.model['amount']}");
                                          // });
                                          _discount = double.parse(
                                                  "${widget.model['amount']}") -
                                              _rem;
                                          // print(
                                          //     "NOT EMPTY OH! ${double.parse("${widget.model['discount_percent']}")}");
                                          // print("NOT EMPTY OH! ${_discount}");
                                        } else {
                                          print("EMPTY OH!");
                                          _discount = double.parse(
                                                  "${widget.guestModel?.discountPercent}") *
                                              widget.guestModel?.amount;
                                        }
                                      } else {
                                        print("DO THIS NOW !");
                                      }

                                      Navigator.push(
                                        context,
                                        PageTransition(
                                          type: PageTransitionType.rightToLeft,
                                          isIos: true,
                                          child: CompleteTransaction(
                                            model: widget.model,
                                            guestModel: widget.guestModel,
                                            token: _token,
                                            discount: _discount,
                                            manager: widget.manager,
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                )
                              : const SizedBox(),
                          const SizedBox(height: 36.0),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
