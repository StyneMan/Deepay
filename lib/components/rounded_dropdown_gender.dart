import 'package:deepay/components/dropdown_container.dart';
import 'package:flutter/material.dart' hide ModalBottomSheetRoute;

typedef void InitCallback(String value);

class RoundedDropdownGender extends StatefulWidget {
  final InitCallback onSelected;
  final String placeholder;
  final List<String> items;

  RoundedDropdownGender({
    Key? key,
    required this.placeholder,
    required this.onSelected,
    required this.items,
  }) : super(key: key);

  @override
  State<RoundedDropdownGender> createState() => _RoundedDropdownState();
}

class _RoundedDropdownState extends State<RoundedDropdownGender> {
  var _modelValue;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return DropdownContainer(
      child: DropdownButton(
        hint: Text(widget.placeholder),
        items: widget.items.map((e) {
          return DropdownMenuItem(
            value: e,
            child: Text(e),
          );
        }).toList(),
        value: _modelValue,
        onChanged: (newValue) async {
          widget.onSelected(
            newValue as String,
          );
          setState(
            () {
              _modelValue = newValue;
            },
          );
        },
        icon: const Icon(Icons.keyboard_arrow_down_rounded),
        iconSize: 30,
        isExpanded: true,
        underline: const SizedBox(),
      ),
    );
  }
}
