import 'package:deepay/components/text_field_container.dart';
import 'package:deepay/constants.dart';
import 'package:flutter/material.dart' hide ModalBottomSheetRoute;

class RoundedPasswordField extends StatefulWidget {
  final ValueChanged<String> onChanged;
  final TextEditingController controller;
  final TextInputType inputType;
  var validator;
  final String hintText;

  RoundedPasswordField({
    Key? key,
    required this.onChanged,
    required this.controller,
    required this.inputType,
    required this.validator,
    this.hintText = "Password",
  }) : super(key: key);

  @override
  State<RoundedPasswordField> createState() => _RoundedPasswordFieldState();
}

class _RoundedPasswordFieldState extends State<RoundedPasswordField> {
  bool _obscureText = true;

  _togglePass() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }

  @override
  Widget build(BuildContext context) {
    return TextFieldContainer(
      child: TextFormField(
        obscureText: _obscureText,
        onChanged: widget.onChanged,
        cursorColor: kPrimaryColor,
        controller: widget.controller,
        validator: widget.validator,
        keyboardType: widget.inputType,
        decoration: InputDecoration(
          hintText: widget.hintText,
          isDense: true,
          icon: InkWell(
            onTap: () => _togglePass(),
            child: Icon(
              _obscureText ? Icons.lock : Icons.lock_open,
              color: kPrimaryColor,
            ),
          ),
          // suffix: InkWell(
          //   onTap: () => _togglePass(),
          //   child: Icon(
          //     _obscureText
          //         ? Icons.visibility_off_rounded
          //         : Icons.visibility_rounded,
          //     color: kPrimaryColor,
          //   ),
          // ),
          border: InputBorder.none,
        ),
      ),
    );
  }
}
