import 'package:flutter/material.dart' hide ModalBottomSheetRoute;
import 'package:deepay/Screens/Signup/components/body/body_mobile.dart';
import 'package:deepay/Screens/Signup/components/body/body_desktop.dart';
import 'package:deepay/responsive/responsive.dart';

class Body extends StatelessWidget {
  const Body({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Responsive(
      mobile: const BodyMobile(),
      tablet: BodyDesktop(),
      desktop: BodyDesktop(),
    );
  }
}
