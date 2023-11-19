import 'dart:convert';
import 'dart:io';

import 'package:deepay/Screens/Dashboard/dashboard.dart';
import 'package:deepay/components/background/background.dart';
import 'package:deepay/constants.dart';
import 'package:deepay/helper/service/api_service.dart';
import 'package:flutter/material.dart' hide ModalBottomSheetRoute;
import 'package:otp_text_field/otp_field.dart';
import 'package:otp_text_field/otp_text_field.dart';
import 'package:otp_text_field/style.dart';
import 'package:flutter/cupertino.dart';
import 'package:deepay/helper/state/state_controller.dart';
import 'package:deepay/helper/preferences/preference_manager.dart';
import 'package:get/get.dart';
import 'package:loading_overlay_pro/loading_overlay_pro.dart';
import 'package:deepay/components/text/text_widget.dart';

class SetWalletPin extends StatefulWidget {
  final PreferenceManager manager;
  const SetWalletPin({
    Key? key,
    required this.manager,
  }) : super(key: key);

  @override
  State<SetWalletPin> createState() => _SetWalletPinState();
}

class _SetWalletPinState extends State<SetWalletPin> {
  OtpFieldController otpController = OtpFieldController();
  final _controller = Get.find<StateController>();
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
  }

  _setPIN(var pin) async {
    Map _payload = {
      "wallet_pin": pin,
      "wallet_pin_confirmation": pin,
    };
    _controller.setLoading(true);
    try {
      final resp = await APIService().setWalletPIN(
        _payload,
        widget.manager.getAccessToken(),
      );
      // debugPrint("${resp.body}");
      // debugPrint(resp.body.data);
      _controller.setLoading(false);
      if (resp.statusCode == 200) {
        Map<String, dynamic> map = jsonDecode(resp.body);
        // WalletPINResponse pin = WalletPINResponse.fromJson(map);

        // UserModel? model = pin.data;
        String userData = jsonEncode(map['data']);
        widget.manager.setUserData(userData);
        widget.manager.setIsLoggedIn(true);
        _controller.setUserData(userData);

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => Dashboard(manager: widget.manager),
          ),
        );
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
                  Container(
                    padding: const EdgeInsets.all(16.0),
                    child: Center(
                      child: TextPrimary(
                        text: "Set Wallet PIN",
                        fontSize: 21,
                        color: kPrimaryColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24.0),
                  Form(
                    key: _formKey,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        OTPTextField(
                          controller: otpController,
                          length: 4,
                          width: MediaQuery.of(context).size.width,
                          textFieldAlignment: MainAxisAlignment.spaceAround,
                          fieldWidth: 45,
                          fieldStyle: FieldStyle.box,
                          outlineBorderRadius: 15,
                          style: const TextStyle(fontSize: 17),
                          onChanged: (pin) {
                            debugPrint("Changed: " + pin);
                          },
                          onCompleted: (pin) {
                            debugPrint("Completed: " + pin);
                            _setPIN(pin);
                          },
                        ),
                        const SizedBox(height: 21.0),
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
