import 'package:deepay/components/rounded_phone_field.dart';
import 'package:flutter/material.dart' hide ModalBottomSheetRoute;
import 'package:deepay/Screens/Login/login_screen.dart';
import 'package:deepay/Screens/Signup/components/background.dart';
import 'package:deepay/Screens/Signup/components/or_divider.dart';
import 'package:deepay/components/already_have_an_account_acheck.dart';
import 'package:deepay/components/rounded_button.dart';
import 'package:deepay/components/rounded_input_field.dart';
import 'package:deepay/components/rounded_password_field.dart';
import 'package:deepay/responsive/responsive.dart';
import 'package:flutter_svg/flutter_svg.dart';

class BodyDesktop extends StatelessWidget {
  BodyDesktop({Key? key}) : super(key: key);

  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _referalController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  _signup() {}

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Background(
      child: Form(
        key: _formKey,
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: Responsive.isDesktop(context)
                ? size.width * 0.12
                : size.width * 0.07,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                flex: Responsive.isDesktop(context) ? 2 : 1,
                child: SvgPicture.asset(
                  "assets/images/signup.svg",
                  height: size.height * 0.5,
                ),
              ),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    RoundedInputField(
                      hintText: "Email",
                      icon: Icons.email_rounded,
                      onChanged: (value) {},
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your email';
                        }
                        if (!RegExp('^[a-zA-Z0-9+_.-]+@[a-zA-Z0-9.-]+.[a-z]')
                            .hasMatch(value)) {
                          return 'Please enter a valid email';
                        }
                        return null;
                      },
                      controller: _emailController,
                      inputType: TextInputType.emailAddress,
                    ),
                    RoundedPhoneField(
                      hintText: "Phone",
                      onChanged: (value) {},
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your phone number';
                        }
                        if (!RegExp('^(?:[+0]234)?[0-9]{10}').hasMatch(value)) {
                          return 'Please enter a valid phone number';
                        }
                        if (value.length < 10) {
                          return 'Phone number not valid';
                        }
                        return null;
                      },
                      inputType: TextInputType.phone,
                      controller: _phoneController,
                    ),
                    RoundedInputField(
                      hintText: "Referral",
                      onChanged: (value) {},
                      // icon: Icons.email_rounded,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your fullname';
                        }
                        return null;
                      },
                      controller: _referalController,
                      inputType: TextInputType.name,
                    ),
                    RoundedPasswordField(
                      onChanged: (value) {},
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please type password';
                        }
                        if (value.length < 6) {
                          return 'Too short! Minimum of 6 characters.';
                        }
                        return null;
                      },
                      controller: _passwordController,
                      inputType: TextInputType.visiblePassword,
                    ),
                    RoundedButton(
                      text: "SIGNUP",
                      press: () {},
                      height: size.height * 0.07,
                    ),
                    SizedBox(height: size.height * 0.03),
                    AlreadyHaveAnAccountCheck(
                      login: false,
                      press: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) {
                              return LoginScreen();
                            },
                          ),
                        );
                      },
                    ),
                    const OrDivider(),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
