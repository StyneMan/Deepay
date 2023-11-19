import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart' hide ModalBottomSheetRoute;
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/instance_manager.dart';
import 'package:monnify_flutter_sdk_plus/monnify_flutter_sdk_plus.dart';
import 'package:page_transition/page_transition.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../components/drawer/custom_drawer.dart';
import '../../../components/rounded_button.dart';
import '../../../components/text/text_widget.dart';
import '../../../components/transaction_info/card_detail.dart';
import '../../../constants.dart';
import '../../../helper/preferences/preference_manager.dart';
import '../../../helper/service/api_service.dart';
import '../../../helper/state/state_controller.dart';
import '../../Home/home.dart';
import '../../Login/components/background.dart';
import '../../payment/payment_success.dart';

class ConfirmWalletTrans extends StatefulWidget {
  final PreferenceManager manager;
  var model;
  ConfirmWalletTrans({
    Key? key,
    required this.manager,
    required this.model,
  }) : super(key: key);

  @override
  State<ConfirmWalletTrans> createState() => _ConfirmWalletTransState();
}

class _ConfirmWalletTransState extends State<ConfirmWalletTrans> {
  final _controller = Get.find<StateController>();
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  // final plugin = PaystackPlugin();

  @override
  void initState() {
    super.initState();
    MonnifyFlutterSdkPlus.initialize(korkoroh, igbagbo, ApplicationMode.LIVE);
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
      body: Background(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 3, sigmaY: 3),
          child: Container(
            margin: const EdgeInsets.all(8.0),
            padding: const EdgeInsets.all(2.0),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.white.withOpacity(0.3),
                  Colors.white.withOpacity(0.7),
                ],
                begin: AlignmentDirectional.topStart,
                end: AlignmentDirectional.bottomEnd,
              ),
              borderRadius: const BorderRadius.all(Radius.circular(10)),
              border: Border.all(
                width: 1.5,
                color: Colors.white.withOpacity(0.2),
              ),
            ),
            child: SafeArea(
              child: ListView(
                padding: const EdgeInsets.all(10.0),
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        TextSecondary(
                          text:
                              "Hi ${widget.manager.getUser()['name']}, please confirm your transaction to fund your wallet.",
                          fontSize: 16,
                          align: TextAlign.center,
                          color: kPrimaryColor,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10.0),
                  CardDetailTrans(
                    title: "Email",
                    value: widget.model['data']['email'],
                    icon: Icons.email,
                  ),
                  const SizedBox(height: 10.0),
                  CardDetailTrans(
                    title: "Amount",
                    value: "${widget.model['data']['amount']}",
                    icon: Icons.abc_rounded,
                  ),
                  const SizedBox(height: 10.0),
                  CardDetailTrans(
                    title: "Transaction Reference",
                    value: "${widget.model['data']['transaction_ref']}",
                    icon: Icons.bubble_chart_rounded,
                  ),
                  const SizedBox(height: 10.0),
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
                            text: "${widget.model['data']['description']}",
                            fontSize: 16,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 8.0),
                  const Divider(thickness: 1.5, color: kPrimaryLightColor),
                  const SizedBox(height: 8.0),
                  RoundedButton(
                    text: "Pay Now",
                    press: () {
                      _initPayment();
                    },
                  ),
                  const SizedBox(height: 10.0),
                  RoundedButton(
                    text: "Cancel Transaction",
                    press: () {
                      _cancelTransaction();
                    },
                    color: Colors.red,
                  )
                ],
              ),
            ),
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
          double.parse(widget.model['data']['amount']),
          "NGN",
          widget.manager.getUser()['name'],
          widget.model['data']['email'],
          _getRandomString(15),
          "Topup wallet",
          metaData: {
            "ip": "196.168.45.22",
            "device": "mobile_flutter"
            // any other info
          },
          paymentMethods: [PaymentMethod.CARD, PaymentMethod.ACCOUNT_TRANSFER],
        ),
      );

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
      debugPrint("Error initializing payment");
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

  _cancelTransaction() async {
    _controller.setLoading(true);
    final _prefs = await SharedPreferences.getInstance();
    final String _token = _prefs.getString("accessToken") ?? "";
    try {
      final resp = await APIService()
          .cancelTransaction(_token, widget.model['transaction_ref']);
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
}
