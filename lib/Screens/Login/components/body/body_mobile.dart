import 'dart:convert';

import 'package:flutter/material.dart' hide ModalBottomSheetRoute;
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart' as MBottomSheet;

import '../../../../components/already_have_an_account_acheck.dart';
import '../../../../components/rounded_button.dart';
import '../../../../components/rounded_input_field.dart';
import '../../../../components/rounded_password_field.dart';
import '../../../../constants.dart';
import '../../../../helper/preferences/preference_manager.dart';
import '../../../../helper/service/api_service.dart';
import '../../../../helper/state/state_controller.dart';
import '../../../../model/error/error.dart';
import '../../../../model/error/validation_error.dart';
import '../../../Account/verify.dart';
import '../../../Dashboard/dashboard.dart';
import '../../../Password/forgot_password.dart';
import '../../../Signup/components/or_divider.dart';
import '../../../Signup/signup_screen.dart';
import '../../../Wallet/set_pin.dart';
import '../background.dart';

class BodyMobile extends StatefulWidget {
  const BodyMobile({
    Key? key,
  }) : super(key: key);

  @override
  State<BodyMobile> createState() => _BodyMobileState();
}

class _BodyMobileState extends State<BodyMobile> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  final _controller = Get.find<StateController>();
  PreferenceManager? _manager;

  @override
  void initState() {
    super.initState();
    _manager = PreferenceManager(context);
  }

  _login() async {
    Map _payload = {
      "email": _emailController.text,
      "password": _passwordController.text
    };
    //Perform Login here
    _controller.setLoading(true);
    try {
      final response = await APIService().login(_payload);
      debugPrint("LOGIN RESP:: ${response.body}");

      if (response.statusCode == 200) {
        Map<String, dynamic> loginMap = jsonDecode(response.body);
        // LoginModel login = LoginModel.fromJson(loginMap);
        // debugPrint('TESTTERRE:::: ${loginMap['data']['token']}');

        _controller.setAccessToken('${loginMap['data']['token']}');
        _manager?.saveAccessToken('${loginMap['data']['token']}');

        final _toks = "${loginMap['data']['token']}";

        // UserModel? model = login.data?.user;
        // _controller.setUserData('${login.data?.user}');

        if (loginMap['data']['user']['is_account_verified']) {
          //Account has been verified. Now check if wallet pin is set.
          if (loginMap['data']['user']['is_wallet_pin']) {
            //Wallet pin has been set, go to dashboard from here.
            //Save user data and preferences
            String userData = jsonEncode(loginMap['data']['user']);
            _manager?.setUserData(userData);

            // _controller.setUserData('${loginMap['data']['user']}');

            await APIService().fetchTransactions(_toks);

            _manager?.setIsLoggedIn(true);
            _controller.setLoading(false);

            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => Dashboard(manager: _manager!),
              ),
            );

            // Fetch transaction data here
            // final tresp =
            // Future.delayed(const Duration(seconds: 2), () async {
            //   debugPrint("TKOEN CHECCK:: $_toks");
            //   try {
            //     await APIService().fetchTransactions(_toks);

            //     _manager?.setIsLoggedIn(true);
            //     _controller.setLoading(false);

            //     Navigator.pushReplacement(
            //       context,
            //       MaterialPageRoute(
            //         builder: (context) => Dashboard(manager: _manager!),
            //       ),
            //     );
            //   } catch (e) {
            //     debugPrint(e.toString());
            //     _controller.setLoading(false);
            //     toast("$e");
            //     Navigator.pushReplacement(
            //       context,
            //       MaterialPageRoute(
            //         builder: (context) => Dashboard(manager: _manager!),
            //       ),
            //     );
            //   }
            // });
            // debugPrint("TRSNA RESP ${tresp.body}");
          } else {
            //Set wallet PIN from here.
            _controller.setLoading(false);
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => SetWalletPin(manager: _manager!),
              ),
            );
          }
        } else {
          //Verify account from here...
          _controller.setLoading(false);
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => VerifyAccount(
                manager: _manager!,
                token: '${loginMap['data']['token']}',
                email: _emailController.text,
              ),
            ),
          );
        }
      } else if (response.statusCode == 422) {
        _controller.setLoading(false);
        //Error occurred on login
        Map<String, dynamic> errorMap = jsonDecode(response.body);
        ValidationError error = ValidationError.fromJson(errorMap);
        toast("${error.errors?.email[0] ?? error.message}");
      } else {
        //Error occurred on login
        _controller.setLoading(false);
        Map<String, dynamic> errorMap = jsonDecode(response.body);
        ErrorResponse error = ErrorResponse.fromJson(errorMap);
        toast("${error.message}");
      }
    } catch (e) {
      _controller.setLoading(false);
      debugPrint("ERR::: $e");
      toast("$e");
    }
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Background(
      child: Form(
        key: _formKey,
        child: Column(
          children: <Widget>[
            const SizedBox(height: 16.0),
            SizedBox(height: size.height * 0.03),
            Image.asset(
              "assets/images/app_logo.png",
            ),
            SizedBox(height: size.height * 0.03),
            SvgPicture.asset(
              "assets/images/login.svg",
              height: size.height * 0.275,
            ),
            SizedBox(height: size.height * 0.03),
            RoundedInputField(
              hintText: "Your Email",
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
            RoundedButton(
              text: "LOGIN",
              press: () {
                if (_formKey.currentState!.validate()) {
                  _login();
                }
              },
            ),
            SizedBox(height: size.height * 0.03),
            AlreadyHaveAnAccountCheck(
              press: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) {
                      return SignUpScreen();
                    },
                  ),
                );
              },
            ),
            const OrDivider(),
            Center(
              child: TextButton(
                onPressed: () {
                  MBottomSheet.showBarModalBottomSheet(
                    expand: true,
                    context: context,
                    backgroundColor: Colors.transparent,
                    builder: (context) => const ForgotPassword(),
                  );
                },
                child: const Text("Forgot Password"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
