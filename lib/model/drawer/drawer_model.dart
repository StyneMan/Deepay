import 'package:flutter/material.dart' hide ModalBottomSheetRoute;

class DrawerModel {
  dynamic icon;
  String title;
  Widget? widget;
  bool isAction;
  String? url;

  DrawerModel({
    required this.icon,
    required this.title,
    this.widget,
    this.url,
    required this.isAction,
  });
}
