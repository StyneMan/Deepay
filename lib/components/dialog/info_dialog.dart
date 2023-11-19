import 'package:deepay/constants.dart';
import 'package:flutter/material.dart';

class InfoDialog extends StatelessWidget {
  final Widget body;
  // final String title;
  InfoDialog({
    required this.body,
    // required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(36),
      ),
      elevation: 0.0,
      backgroundColor: Colors.transparent,
      child: dialogContent(context),
    );
  }

  dialogContent(BuildContext context) {
    return Stack(
      children: <Widget>[
        Container(
          decoration: BoxDecoration(
            shape: BoxShape.rectangle,
            color: Colors.white,
            borderRadius: BorderRadius.circular(padding),
            boxShadow: null,
          ),
          child: body,
        ),
      ],
    );
  }
}
