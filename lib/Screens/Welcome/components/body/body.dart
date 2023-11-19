import 'package:flutter/material.dart' hide ModalBottomSheetRoute;

import '../../../../helper/preferences/preference_manager.dart';
import '../../../../responsive/responsive.dart';
import 'body_desktop.dart';
import 'body_mobile.dart';

class Body extends StatelessWidget {
  final PreferenceManager manager;
  const Body({Key? key, required this.manager}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Responsive(
      mobile: BodyMobile(manager: manager),
      tablet: const BodyDesktop(),
      desktop: const BodyDesktop(),
    );
  }
}
