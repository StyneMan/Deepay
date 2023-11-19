import 'package:deepay/components/text_field_container.dart';
import 'package:deepay/constants.dart';
import 'package:flutter/material.dart' hide ModalBottomSheetRoute;
import 'package:intl/intl.dart';

typedef void InitCallback(String value);

class RoundedDatePicker extends StatelessWidget {
  final String hintText;
  final InitCallback onSelected;
  // final ValueChanged<String> onChanged;
  final TextEditingController controller;
  var validator;
  RoundedDatePicker({
    Key? key,
    required this.hintText,
    required this.controller,
    required this.validator,
    required this.onSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextFieldContainer(
      child: TextFormField(
        cursorColor: kPrimaryColor,
        controller: controller,
        validator: validator,
        readOnly: true,
        decoration: InputDecoration(
          icon: const Icon(
            Icons.calendar_today,
            color: kPrimaryColor,
          ),
          hintText: hintText,
          border: InputBorder.none,
          isDense: true,
        ),
        onTap: () async {
          DateTime? pickedDate = await showDatePicker(
            context: context,
            initialDate: DateTime(2002),
            firstDate: DateTime(1950),
            lastDate: DateTime.now(), //- not to allow to choose after today.
            // lastDate: DateTime(2100),
            builder: (context, child) {
              return Theme(
                data: Theme.of(context).copyWith(
                  colorScheme: const ColorScheme.light(
                    primary: kPrimaryColor,
                    onPrimary: Colors.white,
                    onSurface: kPrimaryColor,
                  ),
                  textButtonTheme: TextButtonThemeData(
                    style: TextButton.styleFrom(
                      foregroundColor: kPrimaryColor, // button text color
                    ),
                  ),
                ),
                child: child!,
              );
            },
          );
          if (pickedDate != null) {
            // print(
            //     pickedDate); //pickedDate output format => 2021-03-10 00:00:00.000
            String formattedDate = DateFormat('dd-MM-yyyy').format(pickedDate);
            onSelected(
              formattedDate,
            );
          } else {}
        },
        keyboardType: TextInputType.datetime,
      ),
    );
  }
}
