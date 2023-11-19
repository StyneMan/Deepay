import 'dart:convert';

import 'package:deepay/components/rounded_button.dart';
import 'package:deepay/components/rounded_input_field.dart';
import 'package:deepay/components/text/text_widget.dart';
import 'package:deepay/constants.dart';
import 'package:deepay/helper/service/api_service.dart';
import 'package:deepay/helper/state/state_controller.dart';
import 'package:deepay/model/error/error.dart';
import 'package:flutter/material.dart' hide ModalBottomSheetRoute;
import 'package:get/get.dart';

import '../Welcome/components/background.dart';

class ForgotPassword extends StatefulWidget {
  const ForgotPassword({
    Key? key,
  }) : super(key: key);

  @override
  State<ForgotPassword> createState() => _ForgotPasswordState();
}

class _ForgotPasswordState extends State<ForgotPassword> {
  final _controller = Get.find<StateController>();
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();

  _resetPass() async {
    Map _payload = {
      "email": _emailController.text,
    };
    _controller.setLoading(true);
    try {
      final response = await APIService().forgotPass(_payload);
      debugPrint("PASSWORD RESET :: ${response.body}");
      _controller.setLoading(false);
      if (response.statusCode == 200) {
        Map<String, dynamic> errorMap = jsonDecode(response.body);
        ErrorResponse error = ErrorResponse.fromJson(errorMap);
        toast("${error.message}");
        //Close bottom sheet
        Navigator.pop(context);
      } else {
        Map<String, dynamic> errorMap = jsonDecode(response.body);
        ErrorResponse error = ErrorResponse.fromJson(errorMap);
        toast("${error.message}");
      }
    } catch (e) {
      _controller.setLoading(false);
    }
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Background(
          child: ListView(
            children: [
              const SizedBox(height: 8.0),
              Image.asset(
                "assets/images/forgot_password.png",
                fit: BoxFit.contain,
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    TextPrimary(
                      text: "Forgot Password",
                      fontSize: 21,
                      fontWeight: FontWeight.w700,
                      color: kPrimaryColor,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32.0),
              Form(
                key: _formKey,
                child: Column(
                  children: <Widget>[
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
                    RoundedButton(
                      text: "Submit",
                      press: () {
                        if (_formKey.currentState!.validate()) {
                          _resetPass();
                        }
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
