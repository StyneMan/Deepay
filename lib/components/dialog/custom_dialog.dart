import 'package:deepay/constants.dart';
import 'package:flutter/material.dart';

class CustomDialog extends StatelessWidget {
  final Widget avtrChild;
  final Color avtrBg;
  final Widget body;
  final Widget ripple;
  CustomDialog({
    required this.body,
    required this.ripple,
    required this.avtrBg,
    required this.avtrChild,
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
            padding: const EdgeInsets.only(
              left: padding,
              top: avatarRadius + padding,
              right: padding,
              bottom: padding,
            ),
            margin: const EdgeInsets.only(top: avatarRadius),
            decoration: BoxDecoration(
              shape: BoxShape.rectangle,
              color: Colors.white,
              borderRadius: BorderRadius.circular(padding),
              boxShadow: null,
              // const [
              //   BoxShadow(
              //       color: Colors.black, offset: Offset(0, 10), blurRadius: 10),
              // ],
            ),
            child: body),
        Positioned(
          left: padding,
          right: padding,
          top: avatarRadius,
          child: ripple,
        ),
        Positioned(
          left: padding,
          right: padding,
          child: CircleAvatar(
            backgroundColor: kSecondaryColor,
            radius: avatarRadius,
            child: ClipRRect(
              borderRadius: const BorderRadius.all(
                Radius.circular(avatarRadius),
              ),
              child: avtrChild,
            ),
          ),
        ),
      ],
    );
  }
}
