import 'package:deepay/components/text_field_container.dart';
import 'package:flutter/material.dart' hide ModalBottomSheetRoute;

class RoundedInputDisabledField extends StatelessWidget {
  final String value;
  final Widget? suffix;
  const RoundedInputDisabledField({
    Key? key,
    required this.value,
    this.suffix,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextFieldContainer(
      child: TextFormField(
        enabled: false,
        initialValue: value,
        decoration: InputDecoration(
          border: InputBorder.none,
          isDense: true,
          suffix: suffix,
        ),
      ),
    );
  }
}
