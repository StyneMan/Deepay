import 'dart:io';

import 'package:flutter/material.dart' hide ModalBottomSheetRoute;
import 'package:fluttertoast/fluttertoast.dart';
// import 'package:url_launcher/url_launcher.dart';
// import 'package:money_formatter/money_formatter.dart';
import "package:intl/intl.dart";
import 'package:money_formatter/money_formatter.dart';

const kPrimaryColor = Color(0xFF27296C);
const kPrimaryLightColor = Color(0xFFB8BBDB);
const kSecondaryColor = Color(0xFF67B051);

const baseURL = "https://vattax.deepay.com.ng/";
const payKey = String.fromEnvironment("PAYSTACK_PUB_KEY");

const igbagbo = "939119631689"; // "7784467686"; //
const korkoroh = "MK_PROD_9K37TXE8PK"; //  "MK_TEST_44M9YWM4L4"; //

const double padding = 20;
const double avatarRadius = 60;

nairaSign(context) {
  Locale locale = Localizations.localeOf(context);
  var format =
      NumberFormat.simpleCurrency(locale: Platform.localeName, name: 'NGN');
  return format;
}

toast(String message) {
  Fluttertoast.showToast(
    msg: "" + message,
    toastLength: Toast.LENGTH_LONG,
    gravity: ToastGravity.CENTER,
    timeInSecForIosWeb: 3,
    backgroundColor: Colors.grey[800],
    textColor: Colors.white,
    fontSize: 16.0,
  );
}

LinearGradient getColorGradient(Color color) {
  var baseColor = color as dynamic;
  Color color1 = color == Colors.black ? baseColor : baseColor[800];
  Color color2 = color == Colors.black ? baseColor : baseColor[400];
  return LinearGradient(colors: [
    color1,
    color2,
  ], begin: Alignment.bottomLeft, end: Alignment.topRight);
}

String formatMoney(int amt) {
  MoneyFormatter fmf = MoneyFormatter(
    amount: double.parse("$amt.00"),
    settings: MoneyFormatterSettings(
      symbol: 'NGN',
      thousandSeparator: ',',
      decimalSeparator: '.',
      symbolAndNumberSeparator: ' ',
      fractionDigits: 3,
      compactFormatType: CompactFormatType.short,
    ),
  );
  return fmf.output.withoutFractionDigits;
}

String formatMoneyFloat(double amt) {
  MoneyFormatter fmf = MoneyFormatter(
    amount: amt,
    settings: MoneyFormatterSettings(
      symbol: 'NGN',
      thousandSeparator: ',',
      decimalSeparator: '.',
      symbolAndNumberSeparator: ' ',
      fractionDigits: 3,
      compactFormatType: CompactFormatType.short,
    ),
  );
  return fmf.output.withoutFractionDigits;
}
