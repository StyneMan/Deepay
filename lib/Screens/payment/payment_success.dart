import 'package:deepay/Screens/Home/home.dart';
import 'package:deepay/components/background/background.dart';
import 'package:deepay/components/rounded_button.dart';
import 'package:deepay/components/text/text_widget.dart';
import 'package:deepay/constants.dart';
import 'package:deepay/helper/preferences/preference_manager.dart';
import 'package:flutter/material.dart' hide ModalBottomSheetRoute;
import 'package:flutter_svg/svg.dart';
import 'package:page_transition/page_transition.dart';

class PaymentSuccess extends StatelessWidget {
  final PreferenceManager manager;
  const PaymentSuccess({
    Key? key,
    required this.manager,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: Colors.white,
      child: Background(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SvgPicture.asset("assets/images/payment_success.svg"),
              const SizedBox(
                height: 10.0,
              ),
              TextPrimary(
                text: "Payment Successful",
                fontSize: 20,
                color: kPrimaryColor,
                align: TextAlign.center,
                fontWeight: FontWeight.w600,
              ),
              const SizedBox(height: 32),
              RoundedButton(
                text: "Done",
                color: kSecondaryColor,
                press: () {
                  Navigator.push(
                    context,
                    PageTransition(
                      type: PageTransitionType.rightToLeft,
                      isIos: true,
                      child: Home(
                        manager: manager,
                      ),
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
