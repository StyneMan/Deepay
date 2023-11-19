import 'package:flutter/material.dart' hide ModalBottomSheetRoute;

class TextPrimary extends StatelessWidget {
  late final String? text;
  late final double? fontSize;
  late final Color? color;
  late final TextAlign? align;
  late final FontWeight? fontWeight;

  TextPrimary(
      {required this.text,
      this.color,
      required this.fontSize,
      this.fontWeight,
      this.align});

  final fontFamily = "Market";

  @override
  Widget build(BuildContext context) {
    return Text(
      text!,
      textAlign: align,
      style: TextStyle(
        color: color,
        fontSize: fontSize,
        fontFamily: fontFamily,
        fontWeight: fontWeight,
      ),
    );
  }
}

class TextSecondary extends StatelessWidget {
  late final String? text;
  late final double? fontSize;
  late final Color? color;
  late final FontWeight? fontWeight;
  late final TextAlign? align;
  late final int? lines;
  late final TextOverflow? overflow;

  TextSecondary({
    required this.text,
    this.color,
    required this.fontSize,
    this.fontWeight,
    this.align,
    this.lines,
    this.overflow,
  });

  final fontFamily = "Roboto";

  @override
  Widget build(BuildContext context) {
    return Text(
      text!,
      textAlign: align,
      overflow: overflow,
      maxLines: lines,
      style: TextStyle(
        color: color,
        fontSize: fontSize,
        fontFamily: fontFamily,
        fontWeight: fontWeight,
      ),
    );
  }
}
