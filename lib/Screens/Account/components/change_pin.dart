import 'dart:convert';

import 'package:deepay/components/dialog/custom_dialog.dart';
import 'package:flutter/material.dart' hide ModalBottomSheetRoute;
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/instance_manager.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../components/rounded_button.dart';
import '../../../components/rounded_password_field.dart';
import '../../../components/text/text_widget.dart';
import '../../../constants.dart';
import '../../../helper/service/api_service.dart';
import '../../../helper/state/state_controller.dart';

class ChangeWalletPIN extends StatefulWidget {
  const ChangeWalletPIN({Key? key}) : super(key: key);

  @override
  State<ChangeWalletPIN> createState() => _ChangeWalletPINState();
}

class _ChangeWalletPINState extends State<ChangeWalletPIN> {
  final _controller = Get.find<StateController>();

  final _formKey = GlobalKey<FormState>();

  final _currPassController = TextEditingController();
  final _newPassController = TextEditingController();
  final _confirmNewPassController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(
            height: 5.0,
          ),
          TextSecondary(
            text: "Current PIN",
            color: kPrimaryColor,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
          RoundedPasswordField(
            onChanged: (value) {},
            hintText: "PIN",
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please type current wallet pin';
              }
              if (value.length < 4) {
                return 'Too short! Minimum of 4 characters.';
              }
              return null;
            },
            controller: _currPassController,
            inputType: TextInputType.visiblePassword,
          ),
          TextSecondary(
            text: "New PIN",
            color: kPrimaryColor,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
          RoundedPasswordField(
            onChanged: (value) {},
            hintText: "PIN",
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please type new wallet PIN';
              }
              if (value.length < 4) {
                return 'Too short! Minimum of 4 characters.';
              }
              return null;
            },
            controller: _newPassController,
            inputType: TextInputType.visiblePassword,
          ),
          TextSecondary(
            text: "Confirm PIN",
            color: kPrimaryColor,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
          RoundedPasswordField(
            hintText: "PIN",
            onChanged: (value) {},
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please confirm new wallet PIN';
              }
              if (value.length < 4) {
                return 'Too short! Minimum of 4 characters.';
              } else if (value != _newPassController.text) {
                return 'Wallet PIN mismatch!';
              }
              return null;
            },
            controller: _confirmNewPassController,
            inputType: TextInputType.visiblePassword,
          ),
          const SizedBox(
            height: 8.0,
          ),
          RoundedButton(
            text: "Update Wallet PIN",
            press: () {
              if (_formKey.currentState!.validate()) {
                _updatePIN();
              }
            },
          ),
        ],
      ),
    );
  }

  _updatePIN() async {
    _controller.setLoading(true);
    final _prefs = await SharedPreferences.getInstance();
    final _token = _prefs.getString("accessToken");

    Map _payload = {
      "old_wallet_pin": _currPassController.text,
      "wallet_pin": _newPassController.text,
      "wallet_pin_confirmation": _confirmNewPassController.text,
    };

    try {
      final resp = await APIService().changeWalletPIN(_payload, _token);
      debugPrint("CHANGE PIN >> >> ${resp.body}");
      _controller.setLoading(false);

      if (resp.statusCode == 200) {
        Map<String, dynamic> map = jsonDecode(resp.body);

        showDialog(
          context: context,
          builder: (BuildContext context) => SizedBox(
            height: MediaQuery.of(context).size.height * 0.4,
            width: MediaQuery.of(context).size.width * 0.98,
            child: CustomDialog(
              ripple: SvgPicture.asset(
                "assets/images/check_effect.svg",
                width: (avatarRadius + 20),
                height: (avatarRadius + 20),
              ),
              avtrBg: Colors.transparent,
              avtrChild: Image.asset(
                "assets/images/checked.png",
              ), //const Icon(CupertinoIcons.check_mark, size: 50,),
              body: Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 16.0,
                  horizontal: 12.0,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    TextSecondary(
                      text:
                          "${map['message'] ?? "Wallet PIN changed successfully!"} ",
                      fontSize: 17,
                      align: TextAlign.center,
                      fontWeight: FontWeight.w500,
                    ),
                    const SizedBox(
                      height: 21,
                    ),
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.36,
                      child: RoundedButton(
                        press: () {
                          Navigator.pop(context);
                        },
                        text: "Done",
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      } else {
        Map<String, dynamic> errorMap = jsonDecode(resp.body);
        toast(errorMap['message'] ?? "Error occurred");
      }
    } catch (e) {
      debugPrint(e.toString());
      _controller.setLoading(false);
    }
  }
}
