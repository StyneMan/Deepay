import 'package:deepay/Screens/Wallet/set_pin.dart';
import 'package:deepay/components/rounded_button.dart';
import 'package:deepay/components/text/text_widget.dart';
import 'package:deepay/helper/preferences/preference_manager.dart';
import 'package:flutter/material.dart' hide ModalBottomSheetRoute;
import 'package:deepay/components/background/background.dart';
import 'package:deepay/constants.dart';
import 'package:flutter_svg/svg.dart';

class Verified extends StatelessWidget {
  final PreferenceManager manager;
  const Verified({
    Key? key,
    required this.manager,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Background(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SvgPicture.asset(
                "assets/images/verified.svg",
                fit: BoxFit.contain,
              ),
              const SizedBox(height: 10.0),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  TextSecondary(
                    text: "Verified!",
                    fontSize: 24,
                    color: kPrimaryColor,
                    fontWeight: FontWeight.w600,
                  ),
                  const SizedBox(height: 4.0),
                  TextSecondary(
                    text: "You have successfully verified this account",
                    fontSize: 16,
                    color: kPrimaryLightColor,
                  ),
                ],
              ),
              const SizedBox(height: 10.0),
              RoundedButton(
                text: "CONTINUE",
                press: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => SetWalletPin(manager: manager),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
