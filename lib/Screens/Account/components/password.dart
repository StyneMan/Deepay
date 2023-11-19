import 'dart:convert';

import 'package:flutter/material.dart' hide ModalBottomSheetRoute;
import 'package:get/get.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart' as MBottomSheet;
import 'package:shared_preferences/shared_preferences.dart';

import '../../../components/rounded_button.dart';
import '../../../components/rounded_password_field.dart';
import '../../../components/text/text_widget.dart';
import '../../../constants.dart';
import '../../../helper/preferences/preference_manager.dart';
import '../../../helper/service/api_service.dart';
import '../../../helper/state/state_controller.dart';
import '../../../model/auth/wallet_pin.dart';
import '../../../model/error/error.dart';
import '../../../model/user/user_model.dart';
import 'change_pin.dart';

class Password extends StatelessWidget {
  final PreferenceManager manager;
  Password({
    Key? key,
    required this.manager,
  }) : super(key: key);

  final _controller = Get.find<StateController>();

  final _formKey = GlobalKey<FormState>();

  final TextEditingController _currPassController = TextEditingController();
  final TextEditingController _newPassController = TextEditingController();
  final TextEditingController _confirmNewPassController =
      TextEditingController();

  _updatePassword() async {
    _controller.setLoading(true);
    final prefs = await SharedPreferences.getInstance();
    String _token = prefs.getString("accessToken") ?? "";

    Map _payload = {
      "current_password": _currPassController.text,
      "password": _newPassController.text,
      "password_confirmation": _confirmNewPassController.text,
    };

    try {
      final response = await APIService().updatePassword(_payload, _token);
      debugPrint("PASS RESP:: ${response.body}");
      debugPrint("PASS RESQ:: $_payload");
      _controller.setLoading(false);
      if (response.statusCode == 200) {
        Map<String, dynamic> map = jsonDecode(response.body);
        WalletPINResponse data = WalletPINResponse.fromJson(map);
        //Update shared preference
        UserModel? model = data.data;
        String userData = jsonEncode(model);
        manager.setUserData(userData);
        manager.setIsLoggedIn(true);
        _controller.setUserData('${data.data}');

        toast("${data.message}");
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
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(
          height: 5.0,
        ),
        Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(
                height: 5.0,
              ),
              TextSecondary(
                text: "Current Password",
                color: kPrimaryColor,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
              RoundedPasswordField(
                onChanged: (value) {},
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please type current password';
                  }
                  if (value.length < 8) {
                    return 'Too short! Minimum of 8 characters.';
                  }
                  return null;
                },
                controller: _currPassController,
                inputType: TextInputType.visiblePassword,
              ),
              TextSecondary(
                text: "New Password",
                color: kPrimaryColor,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
              RoundedPasswordField(
                onChanged: (value) {},
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please type new password';
                  }
                  if (value.length < 8) {
                    return 'Too short! Minimum of 8 characters.';
                  }
                  return null;
                },
                controller: _newPassController,
                inputType: TextInputType.visiblePassword,
              ),
              TextSecondary(
                text: "Confirm Password",
                color: kPrimaryColor,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
              RoundedPasswordField(
                onChanged: (value) {},
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please confirm new password';
                  }
                  if (value.length < 8) {
                    return 'Too short! Minimum of 8 characters.';
                  } else if (value != _newPassController.text) {
                    return 'Password mismatch!';
                  }
                  return null;
                },
                controller: _confirmNewPassController,
                inputType: TextInputType.visiblePassword,
              ),
              const SizedBox(
                height: 8.0,
              ),
              const Divider(
                color: kPrimaryLightColor,
              ),
              TextButton.icon(
                onPressed: () {
                  MBottomSheet.showBarModalBottomSheet(
                    expand: false,
                    context: context,
                    backgroundColor: Colors.white,
                    builder: (context) => Container(
                      height: MediaQuery.of(context).size.height * 0.6,
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          TextPrimary(
                            text: "Change Wallet PIN",
                            fontSize: 18,
                            color: kPrimaryColor,
                            fontWeight: FontWeight.bold,
                            align: TextAlign.center,
                          ),
                          const SizedBox(
                            height: 18,
                          ),
                          const ChangeWalletPIN()
                        ],
                      ),
                    ),
                    topControl: ClipOval(
                      child: GestureDetector(
                        onTap: () {
                          Navigator.of(context).pop();
                        },
                        child: Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(
                              16,
                            ),
                          ),
                          child: const Center(
                            child: Icon(
                              Icons.close,
                              size: 24,
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
                icon: Image.asset(
                  "assets/images/lock_icon.png",
                  width: 36,
                  height: 36,
                ),
                label: TextSecondary(
                  text: "Change Wallet PIN",
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: kPrimaryColor,
                ),
              ),
              const SizedBox(
                height: 8.0,
              ),
              RoundedButton(
                text: "UPDATE PASSWORD",
                press: () {
                  if (_formKey.currentState!.validate()) {
                    _updatePassword();
                  }
                },
              ),
            ],
          ),
        ),
      ],
    );
  }
}
