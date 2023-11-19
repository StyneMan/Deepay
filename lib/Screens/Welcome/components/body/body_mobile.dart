import 'package:deepay/Screens/Dashboard/dashboard.dart';
import 'package:deepay/Screens/Signup/signup_screen.dart';
import 'package:deepay/components/text/text_widget.dart';
import 'package:flutter/material.dart' hide ModalBottomSheetRoute;
import 'package:deepay/Screens/Login/login_screen.dart';
import 'package:deepay/Screens/Welcome/components/background.dart';
import 'package:deepay/components/rounded_button.dart';
import 'package:deepay/constants.dart';
import 'package:flutter_svg/svg.dart';
import 'package:deepay/helper/preferences/preference_manager.dart';

class BodyMobile extends StatelessWidget {
  final PreferenceManager manager;
  const BodyMobile({Key? key, required this.manager}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    // This size provide us total height and width of our screen
    return Background(
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Image.asset(
              "assets/images/app_logo.png",
            ),
            SizedBox(height: size.height * 0.02),
            Image.asset(
              "assets/images/welcome_img.png",
              height: size.height * 0.45,
            ),
            SizedBox(height: size.height * 0.04),
            TextPrimary(
                text: "Welcome",
                color: kPrimaryColor,
                fontSize: 21,
                fontWeight: FontWeight.w600),
            TextSecondary(
                text:
                    "DeePay makes it easy to buy airtime, make bills payments, airtime and so much more",
                fontSize: 14,
                align: TextAlign.center),
            SizedBox(height: size.height * 0.03),
            RoundedButton(
              text: "CONTINUE",
              press: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) {
                      return Dashboard(manager: manager);
                    },
                  ),
                );
              },
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) {
                            return LoginScreen();
                          },
                        ),
                      );
                    },
                    child: const Text("Sign In"),
                    style: TextButton.styleFrom(
                      foregroundColor: kPrimaryLightColor,
                      padding: const EdgeInsets.all(16.0),
                    )),
                const SizedBox(width: 2.0),
                const Text("/"),
                const SizedBox(width: 2.0),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) {
                          return SignUpScreen();
                        },
                      ),
                    );
                  },
                  child: const Text("Sign Up"),
                  style: TextButton.styleFrom(
                    foregroundColor: kPrimaryLightColor,
                    padding: const EdgeInsets.all(16.0),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
