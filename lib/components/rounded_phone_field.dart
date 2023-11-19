import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' hide ModalBottomSheetRoute;

import '../constants.dart';
import 'text_field_container.dart';

class RoundedPhoneField extends StatefulWidget {
  final String hintText;
  final IconData icon;
  final ValueChanged<String> onChanged;
  final TextEditingController controller;
  final TextInputType inputType;
  var validator;

  RoundedPhoneField({
    Key? key,
    required this.hintText,
    this.icon = Icons.person,
    required this.onChanged,
    required this.controller,
    required this.validator,
    required this.inputType,
  }) : super(key: key);

  @override
  State<RoundedPhoneField> createState() => _RoundedPhoneFieldState();
}

class _RoundedPhoneFieldState extends State<RoundedPhoneField> {
  String _countryCode = "+234";
  final String _number = '';

  @override
  Widget build(BuildContext context) {
    return TextFieldContainer(
      child: TextFormField(
        onChanged: widget.onChanged,
        cursorColor: kPrimaryColor,
        controller: widget.controller,
        validator: widget.validator,
        decoration: InputDecoration(
            hintText: widget.hintText,
            border: InputBorder.none,
            isDense: true,
            icon: const Icon(
              CupertinoIcons.phone_fill,
              color: kPrimaryColor,
            )
            // CountryCodePicker(
            //   alignLeft: false,
            //   onChanged: (val) {
            //     setState(() {
            //       _countryCode = val as String;
            //     });
            //   },
            //   flagWidth: 24,
            //   initialSelection: 'NG',
            //   favorite: ['+234', 'NG'],
            //   showCountryOnly: false,
            //   showFlag: false,
            //   showOnlyCountryWhenClosed: false,
            // ),
            ),
        keyboardType: widget.inputType,
      ),
    );
  }
}
