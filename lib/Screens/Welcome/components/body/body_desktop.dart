import 'package:flutter/material.dart' hide ModalBottomSheetRoute;
import 'package:deepay/Screens/Login/components/background.dart';
import 'package:deepay/Screens/Login/login_screen.dart';
import 'package:deepay/Screens/Signup/signup_screen.dart';
import 'package:deepay/components/rounded_button.dart';
import 'package:deepay/constants.dart';
import 'package:flutter_svg/flutter_svg.dart';

class BodyDesktop extends StatelessWidget {
  const BodyDesktop({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Background(
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: size.width * 0.1,
        ),
        child: Row(
          children: [
            Expanded(
              flex: 2,
              child: Image.asset(
                "assets/images/welcome_img.png",
                height: size.height * 0.65,
              ),
            ),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '',
                    style: TextStyle(
                      fontSize: size.height * 0.075,
                      fontWeight: FontWeight.bold,
                      color: kPrimaryColor,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(
                    height: size.height * 0.1,
                  ),
                  RoundedButton(
                    text: "CONTINUE",
                    press: () {},
                    height: size.height * 0.07,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
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
                      ),
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
                      )
                    ],
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
