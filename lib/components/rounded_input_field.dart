import 'text_field_container.dart';
import '../constants.dart';
import 'package:flutter/material.dart' hide ModalBottomSheetRoute;

class RoundedInputField extends StatelessWidget {
  final String hintText;
  final IconData icon;
  final ValueChanged<String> onChanged;
  final TextEditingController controller;
  final TextInputType inputType;
  final TextCapitalization capitalization;
  var validator;
  RoundedInputField({
    Key? key,
    required this.hintText,
    this.icon = Icons.person,
    this.capitalization = TextCapitalization.none,
    required this.onChanged,
    required this.controller,
    required this.validator,
    required this.inputType,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextFieldContainer(
      child: TextFormField(
        onChanged: onChanged,
        cursorColor: kPrimaryColor,
        controller: controller,
        validator: validator,
        decoration: InputDecoration(
          icon: Icon(
            icon,
            color: kPrimaryColor,
          ),
          hintText: hintText,
          border: InputBorder.none,
          isDense: true,
        ),
        keyboardType: inputType,
        textCapitalization: capitalization,
      ),
    );
  }
}
