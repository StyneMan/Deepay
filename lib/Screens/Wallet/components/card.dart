import 'dart:convert';

import 'package:flutter/material.dart' hide ModalBottomSheetRoute;
import 'package:get/instance_manager.dart';
import 'package:page_transition/page_transition.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../components/rounded_button.dart';
import '../../../components/rounded_input_money.dart';
import '../../../components/text/text_widget.dart';
import '../../../constants.dart';
import '../../../helper/preferences/preference_manager.dart';
import '../../../helper/service/api_service.dart';
import '../../../helper/state/state_controller.dart';
import '../../../model/error/error.dart';
import 'confirm_wallet_transaction.dart';

class CardWallet extends StatefulWidget {
  final PreferenceManager manager;
  const CardWallet({
    Key? key,
    required this.manager,
  }) : super(key: key);

  @override
  State<CardWallet> createState() => _CardWalletState();
}

class _CardWalletState extends State<CardWallet> {
  final _formKey = GlobalKey<FormState>();
  final _controller = Get.find<StateController>();
  final TextEditingController _amountController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        TextSecondary(
          text: "Fund your wallet using your ATM card",
          fontSize: 18,
          align: TextAlign.center,
          fontWeight: FontWeight.w600,
        ),
        const SizedBox(
          height: 32.0,
        ),
        Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextSecondary(
                text: "Amount",
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
              RoundedInputMoney(
                hintText: "Enter amount",
                onChanged: (val) {
                  // _computeDiscount(_selectedNetwork);
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter amount';
                  }
                  return null;
                },
                controller: _amountController,
              ),
              const SizedBox(
                height: 8.0,
              ),
              RoundedButton(
                text: "CONTINUE",
                press: () {
                  if (_formKey.currentState!.validate()) {
                    _submit();
                  }
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  _submit() async {
    _controller.setLoading(true);

    String amt = _amountController.text.replaceAll("₦ ", "");
    // String filteredAmt = amt!.replaceAll(",", "");
    // int price = int.parse(amt.replaceAll(",", ""));

    Map _payload = {
      "amount": amt.replaceAll(",", ""),
      "transaction_type": "fund_wallet",
    };

    try {
      final _prefs = await SharedPreferences.getInstance();
      final _token = _prefs.getString("accessToken");
      final resp = await APIService().transactionWallet(_payload, "$_token");
      debugPrint("RESP WALLEEET : ${resp.body}");

      _controller.setLoading(false);
      if (resp.statusCode == 200) {
        Map<String, dynamic> _respMap = jsonDecode(resp.body);
        Navigator.pop(context);
        toast("${_respMap['message']}");

        Navigator.push(
          context,
          PageTransition(
            type: PageTransitionType.rightToLeft,
            isIos: true,
            child: ConfirmWalletTrans(
              model: _respMap,
              manager: widget.manager,
            ),
          ),
        );
      } else {
        //Error occurred on login
        Map<String, dynamic> errorMap = jsonDecode(resp.body);
        ErrorResponse error = ErrorResponse.fromJson(errorMap);
        toast("${error.message}");
      }
    } catch (e) {
      _controller.setLoading(false);
      debugPrint(e.toString());
    }
  }
}
