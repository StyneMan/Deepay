import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart' hide ModalBottomSheetRoute;
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart' as MBottomSheet;
import 'package:monnify_flutter_sdk_plus/monnify_flutter_sdk_plus.dart';
import 'package:page_transition/page_transition.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../components/background/background.dart';
import '../../components/drawer/custom_drawer.dart';
import '../../components/rounded_button.dart';
import '../../components/text/text_widget.dart';
import '../../components/transaction_info/card_detail.dart';
import '../../constants.dart';
import '../../helper/preferences/preference_manager.dart';
import '../../helper/service/api_service.dart';
import '../../helper/state/state_controller.dart';
import '../../model/transactions/guest_transaction_model.dart';
import '../Home/home.dart';
import '../payment/pay_wallet.dart';
import '../payment/payment_success.dart';

class ConfirmTransaction extends StatefulWidget {
  final GuestTransactionModel model;
  final PreferenceManager manager;
  final bool isLoggedIn;
  final String token;
  final String phone;
  final double discount;

  const ConfirmTransaction({
    Key? key,
    required this.model,
    required this.token,
    required this.phone,
    required this.isLoggedIn,
    required this.manager,
    this.discount = 0.0,
  }) : super(key: key);

  @override
  State<ConfirmTransaction> createState() => _ConfirmTransactionState();
}

class _ConfirmTransactionState extends State<ConfirmTransaction> {
  final _controller = Get.find<StateController>();
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  String _paymentMethod = "Card";
  // PreferenceManager? _manager;

  void onSelected(String paymentMethod) {
    _paymentMethod = paymentMethod;
  }

  @override
  void initState() {
    super.initState();
    MonnifyFlutterSdkPlus.initialize(korkoroh, igbagbo, ApplicationMode.LIVE);
    // _manager = PreferenceManager(context);
  }

  _payWallet() async {
    MBottomSheet.showBarModalBottomSheet(
      expand: false,
      context: context,
      backgroundColor: Colors.white,
      builder: (context) => SizedBox(
        height: MediaQuery.of(context).size.height * 0.6,
        child: PayWallet(
          manager: widget.manager,
          transRef: "${widget.model.transactionRef}",
        ),
      ),
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
  }

  _cancelTransaction() async {
    _controller.setLoading(true);
    final _prefs = await SharedPreferences.getInstance();
    final String _token = _prefs.getString("accessToken") ?? "";
    try {
      final resp = await APIService()
          .cancelTransaction(_token, widget.model.transactionRef);
      debugPrint("CANCEL RESPONSE :: ${resp.body}");
      toast("Transaction cancelled successfully");
      _controller.setLoading(false);
      _controller.onInit();

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => Home(
            manager: widget.manager,
          ),
        ),
      );
    } catch (e) {
      _controller.setLoading(false);
      debugPrint(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        elevation: 0.2,
        backgroundColor: Colors.white,
        automaticallyImplyLeading: false,
        leading: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(width: 10),
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
          ],
        ),
        title: TextSecondary(
          text: "Confirm Transaction",
          fontSize: 21,
          fontWeight: FontWeight.w700,
          color: kPrimaryColor,
        ),
        centerTitle: true,
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
      body: SafeArea(
        child: Background(
          child: ListView(
            padding: const EdgeInsets.all(10.0),
            children: [
              const SizedBox(height: 10.0),
              CardDetailTrans(
                title: "Email",
                value: "${widget.model.email}",
                icon: Icons.email,
              ),
              const SizedBox(height: 10.0),
              CardDetailTrans(
                title: "Amount",
                value:
                    "${nairaSign(context).currencySymbol}${widget.discount == 0.0 ? widget.model.amount : widget.discount}",
                icon: Icons.abc_rounded,
              ),
              const SizedBox(height: 10.0),
              CardDetailTrans(
                title: "Phone Number ",
                value: "${widget.phone}",
                icon: Icons.phone,
              ),
              widget.model.type == "electricity"
                  ? Column(
                      children: [
                        const SizedBox(height: 16.0),
                        CardDetailTrans(
                          title: "Meter Number",
                          value: "${widget.model.meterNumber}",
                          icon: Icons.numbers_rounded,
                        ),
                        const SizedBox(height: 16.0),
                        CardDetailTrans(
                          title: "Address",
                          value: "",
                          icon: Icons.location_on,
                        ),
                      ],
                    )
                  : const SizedBox(),
              const SizedBox(height: 16.0),
              CardDetailTrans(
                  title: "Transaction Reference",
                  value: "${widget.model.transactionRef}",
                  icon: Icons.bubble_chart_rounded),
              const SizedBox(height: 16.0),
              Card(
                elevation: 2.0,
                child: Container(
                  padding: const EdgeInsets.all(10),
                  width: double.infinity,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextPrimary(
                        text: "Description",
                        fontWeight: FontWeight.w600,
                        fontSize: 18,
                        color: kPrimaryColor,
                      ),
                      TextSecondary(
                        text: "${widget.model.description}",
                        fontSize: 14,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 18.0),
              !widget.isLoggedIn
                  ? RoundedButton(
                      text: "Pay Now",
                      press: () {
                        _initPayment();
                      },
                    )
                  : Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        TextPrimary(
                          text: "Payment Method",
                          color: kPrimaryColor,
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                        const SizedBox(
                          height: 8.0,
                        ),
                        RoundedButton(
                          text: "Pay Wallet",
                          press: () {
                            _payWallet();
                          },
                        ),
                        RoundedButton(
                          text: "Pay Card",
                          press: () {
                            _initPayment();
                          },
                          color: kSecondaryColor,
                        )
                      ],
                    ),
              RoundedButton(
                text: "Cancel Transaction",
                color: Colors.red,
                press: () {
                  _cancelTransaction();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _initPayment() async {
    try {
      TransactionResponse _transactionResponse =
          await MonnifyFlutterSdkPlus.initializePayment(
        Transaction(
          widget.discount == 0.0 ? widget.model.amount : widget.discount,
          "NGN",
          "${widget.manager.getUser()['name']}",
          "${widget.model.email}",
          _getRandomString(15),
          "${widget.model.type} transaction",
          metaData: {
            "ip": "196.168.45.22",
            "device": "mobile_flutter"
            // any other info
          },
          paymentMethods: [PaymentMethod.CARD, PaymentMethod.ACCOUNT_TRANSFER],
        ),
      );

      debugPrint(
          "MONNIFY PAYMENT RESPONSE :: ${_transactionResponse.transactionStatus}");

      if (_transactionResponse.transactionStatus == "PAID") {
        //Now refresh user data
        if (widget.manager.getAccessToken().isNotEmpty) {
          _controller.onInit();

          Navigator.push(
            context,
            PageTransition(
              type: PageTransitionType.rightToLeft,
              isIos: true,
              child: PaymentSuccess(manager: widget.manager),
            ),
          );
        } else {
          Navigator.push(
            context,
            PageTransition(
              type: PageTransitionType.rightToLeft,
              isIos: true,
              child: PaymentSuccess(manager: widget.manager),
            ),
          );
        }
      }
    } on PlatformException catch (e, s) {
      print("Error initializing payment");
      print(e);
      print(s);
    }
  }

  String _getRandomString(int length) {
    const _chars =
        'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890';
    Random _rnd = Random();

    return String.fromCharCodes(
      Iterable.generate(
        length,
        (_) => _chars.codeUnitAt(_rnd.nextInt(_chars.length)),
      ),
    );
  }
}
