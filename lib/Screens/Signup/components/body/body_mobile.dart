import 'dart:convert';

import 'package:deepay/Screens/Account/verify.dart';
import 'package:deepay/components/rounded_phone_field.dart';
import 'package:deepay/helper/service/api_service.dart';
import 'package:deepay/helper/state/state_controller.dart';
import 'package:deepay/model/auth/login_model.dart';
import 'package:flutter/material.dart' hide ModalBottomSheetRoute;
import 'package:deepay/Screens/Login/login_screen.dart';
import 'package:deepay/Screens/Signup/components/background.dart';
import 'package:deepay/components/already_have_an_account_acheck.dart';
import 'package:deepay/components/rounded_button.dart';
import 'package:deepay/components/rounded_input_field.dart';
import 'package:deepay/components/rounded_password_field.dart';
import 'package:flutter_svg/svg.dart';
import 'package:deepay/helper/preferences/preference_manager.dart';
import 'package:get/get.dart';

class BodyMobile extends StatefulWidget {
  const BodyMobile({Key? key}) : super(key: key);

  @override
  State<BodyMobile> createState() => _BodyMobileState();
}

class _BodyMobileState extends State<BodyMobile> {
  final _formKey = GlobalKey<FormState>();

  final _controller = Get.find<StateController>();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _referalController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  PreferenceManager? _manager;

  @override
  void initState() {
    super.initState();
    _manager = PreferenceManager(context);
  }

  _sendOTP(var token) async {
    try {
      final response = await APIService().resendOTP(token);
      debugPrint("FIRST OTP:RESPONSE:: ${response.body}");

      _controller.setLoading(false);

      if (response.statusCode == 200) {
        //Now navigate to next screen here
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => VerifyAccount(
              manager: _manager!,
              token: '${token}',
              email: _emailController.text,
            ),
          ),
        );
      } else {}
    } catch (e) {
      _controller.setLoading(false);
    }
  }

  _signup() async {
    Map _payload = {
      "name": _nameController.text,
      "email": _emailController.text,
      "phone": _phoneController.text,
      "password": _passwordController.text,
      "referal_code": _referalController.text,
      "password_confirmation": _passwordController.text,
    };
    _controller.setLoading(true);

    try {
      final response = await APIService().signup(_payload);
      debugPrint("REGISTER RESP:: ${response.body}");
      // _controller.setLoading(false);

      if (response.statusCode == 200) {
        Map<String, dynamic> registerMap = jsonDecode(response.body);
        LoginModel login = LoginModel.fromJson(registerMap);

        debugPrint("CHECKING::: ${login.data?.token}");

        _controller.setAccessToken('${login.data?.token}');
        _manager?.saveAccessToken('${login.data?.token}');
        _controller.setUserData('${login.data?.user}');

        //Verify account from here...
        //Send verification email first
        _sendOTP("${login.data?.token}");
      } else {}
    } catch (e) {
      _controller.setLoading(false);
      debugPrint("ERR::: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Background(
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              SizedBox(height: size.height * 0.03),

              SvgPicture.asset(
                "assets/images/signup.svg",
                height: size.height * 0.35,
              ),
              RoundedInputField(
                hintText: "Name",
                icon: Icons.person,
                onChanged: (value) {},
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Enter your fullname';
                  }
                  return null;
                },
                controller: _nameController,
                inputType: TextInputType.name,
              ),
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
              RoundedPasswordField(
                onChanged: (value) {},
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please type password';
                  }
                  if (value.length < 8) {
                    return 'Too short! Minimum of 8 characters.';
                  }
                  return null;
                },
                controller: _passwordController,
                inputType: TextInputType.visiblePassword,
              ),
              RoundedInputField(
                hintText: "Referral",
                onChanged: (value) {},
                icon: Icons.account_tree_outlined,
                validator: (value) {
                  // if (value == null || value.isEmpty) {
                  //   return 'Please enter referral code';
                  // }
                  return null;
                },
                controller: _referalController,
                inputType: TextInputType.name,
              ),
              RoundedButton(
                text: "SIGNUP",
                press: () {
                  if (_formKey.currentState!.validate()) {
                    _signup();
                  }
                },
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
              // const OrDivider(),
              // Row(
              //   mainAxisAlignment: MainAxisAlignment.center,
              //   children: <Widget>[
              //     SocalIcon(
              //       iconSrc: "assets/icons/facebook.svg",
              //       press: () {},
              //     ),
              //     SocalIcon(
              //       iconSrc: "assets/icons/twitter.svg",
              //       press: () {},
              //     ),
              //     SocalIcon(
              //       iconSrc: "assets/icons/google-plus.svg",
              //       press: () {},
              //     ),
              //   ],
              // )
            ],
          ),
        ),
      ),
    );
  }
}
