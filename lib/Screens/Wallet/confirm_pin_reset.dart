import 'dart:convert';
import 'dart:io';

import 'package:deepay/Screens/Wallet/set_pin.dart';
import 'package:deepay/components/background/background.dart';
import 'package:deepay/constants.dart';
import 'package:deepay/helper/service/api_service.dart';
import 'package:deepay/model/error/error.dart';
import 'package:flutter/material.dart' hide ModalBottomSheetRoute;
import 'package:otp_text_field/otp_field.dart';
import 'package:otp_text_field/otp_text_field.dart';
import 'package:otp_text_field/style.dart';
import 'package:flutter/cupertino.dart';
import 'package:deepay/helper/state/state_controller.dart';
import 'package:get/get.dart';
import 'package:loading_overlay_pro/loading_overlay_pro.dart';
import 'package:deepay/helper/preferences/preference_manager.dart';
import 'package:deepay/components/text/text_widget.dart';
import 'package:deepay/components/rounded_button.dart';

class ConfirmPinReset extends StatefulWidget {
  final PreferenceManager manager;
  const ConfirmPinReset({
    Key? key,
    required this.manager,
  }) : super(key: key);

  @override
  State<ConfirmPinReset> createState() => _ConfirmPinResetState();
}

class _ConfirmPinResetState extends State<ConfirmPinReset> {
  OtpFieldController otpController = OtpFieldController();
  final _controller = Get.find<StateController>();
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
  }

  _resendOTP() async {
    // _controller.setLoading(true);
    try {
      // final response = await APIService().resendOTP(widget.token);
      // _controller.setLoading(false);
      // debugPrint("OTP:RESPONSE:: ${response.body}");

      // if (response.statusCode == 200) {
      //   Map<String, dynamic> map = jsonDecode(response.body);
      //   var model = OTPResend.fromJson(map);
      //   toast("${model.data}");
      // } else {}
    } catch (e) {
      // _controller.setLoading(false);
    }
  }

  _confirmPinReset(otp) async {
    Map _payload = {
      "token": otp,
    };
    _controller.setLoading(true);
    try {
      final response = await APIService()
          .confirmResetWalletPIN(_payload, widget.manager.getAccessToken());
      _controller.setLoading(false);
      debugPrint("RESPONSE:: ${response.body}");

      if (response.statusCode == 200) {
        // Request user to setup new PIN.
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => SetWalletPin(manager: widget.manager),
          ),
        );
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
  Widget build(BuildContext context) {
    return Obx(
      () => LoadingOverlayPro(
        isLoading: _controller.isLoading.value,
        progressIndicator: Platform.isAndroid
            ? const CircularProgressIndicator(
                color: Colors.white,
              )
            : const CupertinoActivityIndicator(
                animating: true,
              ),
        backgroundColor: Colors.black54,
        child: Scaffold(
          body: Background(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  const SizedBox(height: 56),
                  Image.asset(
                    "assets/images/app_logo.png",
                  ),
                  const SizedBox(height: 56),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        vertical: 8.0, horizontal: 10),
                    child: Center(
                      child: Column(
                        children: [
                          TextPrimary(
                            text: "CONFIRM WALLET RESET",
                            fontSize: 21,
                            color: kPrimaryColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ],
                      ),
                    ),
                  ),
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              vertical: 8.0, horizontal: 21),
                          child: Center(
                            child: RichText(
                              textAlign: TextAlign.center,
                              text: TextSpan(
                                text: "An email has been sent to ",
                                style: const TextStyle(
                                  color: kPrimaryLightColor,
                                ),
                                children: [
                                  TextSpan(
                                    text:
                                        "${widget.manager.getUser()['email']}",
                                    style: const TextStyle(
                                      color: kSecondaryColor,
                                      fontWeight: FontWeight.w500,
                                      decoration: TextDecoration.underline,
                                    ),
                                  ),
                                  const TextSpan(
                                    text: " Kindly check your email.",
                                    style: TextStyle(
                                      color: Colors.black38,
                                      fontWeight: FontWeight.w500,
                                      decoration: TextDecoration.underline,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 21.0),
                        Form(
                          key: _formKey,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              OTPTextField(
                                controller: otpController,
                                length: 6,
                                width: MediaQuery.of(context).size.width,
                                textFieldAlignment:
                                    MainAxisAlignment.spaceAround,
                                fieldWidth: 45,
                                fieldStyle: FieldStyle.box,
                                outlineBorderRadius: 15,
                                style: const TextStyle(fontSize: 17),
                                onChanged: (pin) {
                                  debugPrint("Changed: " + pin);
                                },
                                onCompleted: (pin) {
                                  debugPrint("Completed: " + pin);
                                  _confirmPinReset(pin);
                                },
                              ),
                              const SizedBox(height: 21.0),
                              RoundedButton(
                                text: "RESEND CODE",
                                isEnabled: false,
                                press: () {
                                  // if (_formKey.currentState!.validate()) {
                                  //   // _resendOTP();
                                  // }
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
