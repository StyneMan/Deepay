import 'dart:convert';

import 'package:deepay/Screens/Dashboard/dashboard.dart';
import 'package:deepay/Screens/Wallet/confirm_pin_reset.dart';
import 'package:deepay/components/dialog/custom_dialog.dart';
import 'package:deepay/components/dialog/info_dialog.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:get/instance_manager.dart';
import 'package:otp_text_field/otp_text_field.dart';
import 'package:otp_text_field/style.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../components/background/background.dart';
import '../../components/divider/text_divider.dart';
import '../../components/rounded_button.dart';
import '../../components/text/text_widget.dart';
import '../../constants.dart';
import '../../helper/preferences/preference_manager.dart';
import '../../helper/service/api_service.dart';
import '../../helper/state/state_controller.dart';

class PayWallet extends StatefulWidget {
  final PreferenceManager manager;
  final String transRef;
  const PayWallet({
    Key? key,
    required this.manager,
    required this.transRef,
  }) : super(key: key);

  @override
  State<PayWallet> createState() => _PayWalletState();
}

class _PayWalletState extends State<PayWallet> {
  final _otpController = OtpFieldController();
  final _controller = Get.find<StateController>();
  String _pin = "";

  _loginPayWallet() async {
    _controller.setLoading(true);
    Map _payload = {
      "method": "wallet",
      "transaction_ref": widget.transRef,
      "wallet_pin": _pin,
    };
    try {
      final resp =
          await APIService().payment(_payload, widget.manager.getAccessToken());
      debugPrint("WALLET PAYMENT RESP>> ${resp.body}");
      _controller.setLoading(false);
      Navigator.pop(context);
      if (resp.statusCode == 200) {
        Map<String, dynamic> map = jsonDecode(resp.body);

        showDialog(
          context: context,
          builder: (BuildContext context) => SizedBox(
            height: MediaQuery.of(context).size.height * 0.4,
            width: MediaQuery.of(context).size.width * 0.98,
            child: CustomDialog(
              ripple: SvgPicture.asset(
                "assets/images/check_effect.svg",
                width: (avatarRadius + 20),
                height: (avatarRadius + 20),
              ),
              avtrBg: Colors.transparent,
              avtrChild: Image.asset(
                "assets/images/checked.png",
              ), //const Icon(CupertinoIcons.check_mark, size: 50,),
              body: Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 16.0,
                  horizontal: 12.0,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    TextSecondary(
                      text: "${map['type']} Transaction successfully completed"
                          .capitalizeFirst,
                      fontSize: 17,
                      align: TextAlign.center,
                      fontWeight: FontWeight.w600,
                    ),
                    const SizedBox(
                      height: 21,
                    ),
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.36,
                      child: RoundedButton(
                        press: () {
                          Navigator.pop(context);
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  Dashboard(manager: widget.manager),
                            ),
                          );
                        },
                        text: "Done",
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );

        _controller.onInit();
      } else {
        Map<String, dynamic> errorMap = jsonDecode(resp.body);
        toast(errorMap['message']);
      }
    } catch (e) {
      debugPrint(e.toString());
      _controller.setLoading(false);
    }
  }

  _resetPIN() async {
    _controller.setLoading(true);
    final _prefs = await SharedPreferences.getInstance();
    final _token = _prefs.getString("accessToken");

    try {
      final resp = await APIService().resetWalletPIN(_token);
      debugPrint("RESET WALLET PIN REPONSE>> ${resp.body}");
      _controller.setLoading(false);

      if (resp.statusCode == 200) {
        //Now use token sent to perform next request
        Map<String, dynamic> map = jsonDecode(resp.body);

        showDialog(
          context: context,
          builder: (BuildContext context) => SizedBox(
            height: MediaQuery.of(context).size.height * 0.4,
            width: MediaQuery.of(context).size.width * 0.98,
            child: InfoDialog(
              body: Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 16.0,
                  horizontal: 21.0,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(
                      height: 32,
                    ),
                    TextSecondary(
                      text: "${map['message']}".capitalizeFirst,
                      fontSize: 17,
                      align: TextAlign.center,
                      fontWeight: FontWeight.w600,
                    ),
                    const SizedBox(
                      height: 21,
                    ),
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.36,
                      child: RoundedButton(
                        press: () {
                          Navigator.pop(context);
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ConfirmPinReset(
                                manager: widget.manager,
                              ),
                            ),
                          );
                        },
                        text: "Done",
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );

        _controller.onInit();
      } else {
        Map<String, dynamic> _errorMap = jsonDecode(resp.body);
        toast(_errorMap['message']);
      }
    } catch (e) {
      debugPrint(e.toString());
      _controller.setLoading(false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Background(
      child: Container(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            TextPrimary(
              text: "Pay With Wallet",
              fontSize: 18,
              color: kPrimaryColor,
              fontWeight: FontWeight.w600,
            ),
            const SizedBox(
              height: 16.0,
            ),
            TextSecondary(
              text: "Wallet Balance",
              fontSize: 14,
              align: TextAlign.center,
            ),
            Text(
              "${nairaSign(context).currencySymbol}${widget.manager.getUser()['wallet_balance']}",
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: kPrimaryColor,
                fontSize: 17,
              ),
            ),
            const SizedBox(
              height: 8.0,
            ),
            TextSecondary(
              text:
                  "Enter your wallet PIN to proceed. You are advised not disclose your PIN to anybody for security reasons.",
              fontSize: 14,
              align: TextAlign.center,
            ),
            const SizedBox(
              height: 10.0,
            ),
            OTPTextField(
              length: 4,
              width: MediaQuery.of(context).size.width * 0.75,
              fieldWidth: 48,
              contentPadding: const EdgeInsets.all(8.0),
              style: const TextStyle(
                fontSize: 17,
                color: kPrimaryColor,
                fontWeight: FontWeight.w600,
              ),
              controller: _otpController,
              textFieldAlignment: MainAxisAlignment.spaceAround,
              fieldStyle: FieldStyle.box,
              onCompleted: (pin) {
                setState(() {
                  _pin = pin;
                });
                if (kDebugMode) {
                  print("Completed: " + pin);
                }
              },
              spaceBetween: 4.0,
              keyboardType: TextInputType.number,
              obscureText: true,
              outlineBorderRadius: 1.5,
            ),
            const SizedBox(
              height: 16.0,
            ),
            RoundedButton(
              text: "Continue",
              color: kSecondaryColor,
              press: () => _loginPayWallet(),
            ),
            const SizedBox(
              height: 8.0,
            ),
            const TextDivider(text: "Forgot PIN?"),
            const SizedBox(
              height: 16.0,
            ),
            RoundedButton(
              text: "Reset PIN",
              press: () => _resetPIN(),
            ),
          ],
        ),
      ),
    );
  }
}
