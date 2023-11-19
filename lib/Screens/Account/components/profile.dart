import 'dart:convert';

import 'package:flutter/material.dart' hide ModalBottomSheetRoute;
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../components/rounded_button.dart';
import '../../../components/rounded_input_disabled.dart';
import '../../../components/rounded_input_field.dart';
import '../../../components/rounded_phone_field.dart';
import '../../../components/text/text_widget.dart';
import '../../../constants.dart';
import '../../../helper/preferences/preference_manager.dart';
import '../../../helper/service/api_service.dart';
import '../../../helper/state/state_controller.dart';
import '../../../model/auth/wallet_pin.dart';
import '../../../model/error/error.dart';
import '../../../model/user/user_model.dart';

class Profile extends StatelessWidget {
  final PreferenceManager manager;
  Profile({
    Key? key,
    required this.manager,
  }) : super(key: key);

  final _controller = Get.find<StateController>();
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  _updateProfile() async {
    _controller.setLoading(true);
    final prefs = await SharedPreferences.getInstance();
    String _token = prefs.getString("accessToken") ?? "";

    Map _payload = {
      "name": _nameController.text,
      "phone": _phoneController.text
    };

    try {
      final response = await APIService().updateProfile(_payload, _token);
      debugPrint("UPDTE RESP:: ${response.body}");
      debugPrint("UPDTE RESQ:: $_payload");
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
    _nameController.text = manager.getUser()['name'];
    _phoneController.text = manager.getUser()['phone'] ?? "";

    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextSecondary(
          text: "Account ID",
          color: kPrimaryColor,
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
        RoundedInputDisabledField(
          value: "${manager.getUser()['ref']}",
        ),
        const SizedBox(
          height: 5.0,
        ),
        TextSecondary(
          text: "Referral code",
          color: kPrimaryColor,
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
        RoundedInputDisabledField(
          value: "${manager.getUser()['referral_code']}",
          suffix: InkWell(
            onTap: () {
              Clipboard.setData(
                  ClipboardData(text: "${manager.getUser()['referral_code']}"));
              toast("Referral code copied to clipboard!");
            },
            child: const Icon(Icons.copy, size: 21.0),
          ),
        ),
        const SizedBox(
          height: 5.0,
        ),
        TextSecondary(
          text: "Email",
          color: kPrimaryColor,
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
        RoundedInputDisabledField(
          value: manager.getUser()['email'],
        ),
        const SizedBox(height: 8.0),
        const Divider(
          thickness: 1.0,
        ),
        const SizedBox(
          height: 8.0,
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
                text: "Name",
                color: kPrimaryColor,
                fontSize: 16,
                fontWeight: FontWeight.w600,
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
              const SizedBox(
                height: 5.0,
              ),
              TextSecondary(
                text: "Phone number",
                color: kPrimaryColor,
                fontSize: 16,
                fontWeight: FontWeight.w600,
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
              const SizedBox(
                height: 8.0,
              ),
              RoundedButton(
                text: "SAVE PROFILE",
                press: () {
                  if (_formKey.currentState!.validate()) {
                    _updateProfile();
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
