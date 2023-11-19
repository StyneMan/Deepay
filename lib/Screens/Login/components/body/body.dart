import 'package:flutter/material.dart' hide ModalBottomSheetRoute;
import 'package:deepay/responsive/responsive.dart';
import 'package:deepay/Screens/Login/components/body/body_mobile.dart';
import 'package:deepay/Screens/Login/components/body/body_desktop.dart';

class Body extends StatelessWidget {
  const Body({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView(children: const [
      Responsive(
        mobile: BodyMobile(),
        tablet: BodyDesktop(),
        desktop: BodyDesktop(),
      )
    ]);
  }
}
