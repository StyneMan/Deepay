import 'dart:convert';

import 'package:flutter/material.dart' hide ModalBottomSheetRoute;
import 'package:get/instance_manager.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../components/rounded_button.dart';
import '../../../components/rounded_dropdown_bank.dart';
import '../../../components/rounded_input_field.dart';
import '../../../components/rounded_input_money.dart';
import '../../../components/text/text_widget.dart';
import '../../../constants.dart';
import '../../../helper/banks/banks.dart';
import '../../../helper/preferences/preference_manager.dart';
import '../../../helper/service/api_service.dart';
import '../../../helper/state/state_controller.dart';

class Withdraw extends StatefulWidget {
  final PreferenceManager manager;
  const Withdraw({
    Key? key,
    required this.manager,
  }) : super(key: key);

  @override
  State<Withdraw> createState() => _WithdrawState();
}

class _WithdrawState extends State<Withdraw> {
  final _formKey = GlobalKey<FormState>();
  final _controller = Get.find<StateController>();

  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _accountNumController = TextEditingController();
  String _selectedBank = "Access Bank";
  var _bankCode;

  void onSelected(String bank) {
    var arr = banks.where((element) => element['name'] == bank);
    setState(() {
      _selectedBank = bank;
      _bankCode = arr.elementAt(0)['code'];
    });
  }

  _withdrawFunds() async {
    _controller.setLoading(true);

    String amt = _amountController.text.replaceAll("₦ ", "");

    Map _payload = {
      "account_number": _accountNumController.text,
      "amount": amt.replaceAll(",", ""),
      "bank_code": _bankCode ?? "0"
    };

    final _prefs = await SharedPreferences.getInstance();
    final _token = _prefs.getString("accessToken") ?? "";

    try {
      final resp = await APIService().withdrawWallet(_payload, _token);
      debugPrint("WITHDRAWAL RESPONSE >> ${resp.body}");
      _controller.setLoading(false);
      if (resp.statusCode == 200) {
        toast("Operation successful");
        Navigator.pop(context);
      } else {
        Map<String, dynamic> errorMap = jsonDecode(resp.body);
        toast(errorMap['message']);
      }
    } catch (e) {
      debugPrint(e.toString());
      _controller.setLoading(false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextSecondary(
          text: "Withdrawable Balance",
          fontSize: 14,
          align: TextAlign.center,
        ),
        Text(
          "${nairaSign(context).currencySymbol}${widget.manager.getUser()['withdrawable_balance']}",
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(
          height: 10.0,
        ),
        TextSecondary(
          text: "Withdraw from your withdrawable wallet",
          fontSize: 14,
          align: TextAlign.center,
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
                text: "Bank",
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
              RoundedDropdownBank(
                placeholder: "Select bank",
                onSelected: onSelected,
                items: banks,
              ),
              const SizedBox(
                height: 2.0,
              ),
              TextSecondary(
                text: "Account number",
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
              RoundedInputField(
                hintText: "Enter account number",
                onChanged: (e) {
                  debugPrint("${e.length}");
                },
                controller: _accountNumController,
                validator: (val) {
                  // print("VAK $val");
                  if (val.toString().length < 10) {
                    return "Enter a valid account number";
                  }
                  if (val.toString().contains(" ")) {
                    return "Number not valid";
                  }

                  return null;
                },
                inputType: TextInputType.number,
              ),
              const SizedBox(
                height: 2.0,
              ),
              TextSecondary(
                text: "Amount",
                fontSize: 14,
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
                height: 10.0,
              ),
              RoundedButton(
                text: "CONTINUE",
                press: () {
                  if (_formKey.currentState!.validate()) {
                    _withdrawFunds();
                  }
                },
              ),
            ],
          ),
        ),
      ],
    );
  }
}
