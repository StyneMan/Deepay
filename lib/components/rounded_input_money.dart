import 'package:currency_text_input_formatter/currency_text_input_formatter.dart';
import 'package:deepay/constants.dart';
import 'package:flutter/material.dart' hide ModalBottomSheetRoute;
import 'package:flutter/services.dart';

import 'text_field_money_container.dart';

class RoundedInputMoney extends StatelessWidget {
  final String hintText;
  final IconData icon;
  final bool? enabled;
  final ValueChanged<String> onChanged;
  final TextEditingController controller;
  var validator;
  RoundedInputMoney({
    Key? key,
    required this.hintText,
    this.icon = Icons.money,
    this.enabled,
    required this.onChanged,
    required this.controller,
    required this.validator,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextFieldMoneyContainer(
      child: TextFormField(
        onChanged: onChanged,
        cursorColor: kPrimaryColor,
        controller: controller,
        validator: validator,
        enabled: enabled,
        inputFormatters: <TextInputFormatter>[
          CurrencyTextInputFormatter(
            locale: 'en',
            decimalDigits: 0,
            symbol: '₦ ',
          ),
        ],
        keyboardType: TextInputType.number,
        decoration: InputDecoration(
          icon: Icon(
            icon,
            color: kPrimaryColor,
          ),
          hintText: hintText,
          border: InputBorder.none,
          isDense: true,
        ),
      ),
    );
  }
}
