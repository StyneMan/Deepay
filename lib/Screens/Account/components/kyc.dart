import 'dart:convert';

import 'package:intl/intl.dart';

import '../../../components/rounded_button.dart';
import '../../../components/rounded_date_picker.dart';
import '../../../components/rounded_dropdown_gender.dart';
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
import 'package:flutter/material.dart' hide ModalBottomSheetRoute;
import 'package:get/get.dart';

class KYC extends StatefulWidget {
  final PreferenceManager manager;
  KYC({
    Key? key,
    required this.manager,
  }) : super(key: key);

  @override
  State<KYC> createState() => _KYCState();
}

class _KYCState extends State<KYC> {
  final _controller = Get.find<StateController>();

  final _formKey = GlobalKey<FormState>();

  final TextEditingController _bvnController = TextEditingController();

  final TextEditingController _phoneController = TextEditingController();

  final TextEditingController _dateController = TextEditingController();

  String _gender = "Male", _placeholder = "Select your gender";
  String? _dob;

  void onSelected(String gender) {
    _gender = gender;
  }

  void onDateSelected(String date) {
    debugPrint("DATE SELECTED:: $date");
    _dateController.text = date;
    _dob = date;
  }

  _saveKYC() async {
    //
    // final prefs = await SharedPreferences.getInstance();
    // String _token = prefs.getString("accessToken") ?? "";

    Map _payload = {
      "bvn": _bvnController.text,
      "gender": _gender.toLowerCase(),
      "dob": _dob,
      "name": widget.manager.getUser()['name'],
      "phone": _phoneController.text,
    };

    _controller.setLoading(true);

    try {
      final response = await APIService().kyc(_payload, "_token");
      debugPrint("KYC RESP:: ${response.body}");
      debugPrint("KYC RESQ:: $_payload");

      _controller.setLoading(false);
      if (response.statusCode == 200) {
        Map<String, dynamic> map = jsonDecode(response.body);
        WalletPINResponse data = WalletPINResponse.fromJson(map);
        //Update shared preference
        UserModel? model = data.data;
        String userData = jsonEncode(model);
        widget.manager.setUserData(userData);
        widget.manager.setIsLoggedIn(true);
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
  void initState() {
    super.initState();
    _bvnController.text = widget.manager.getUser()['bvn'] ?? "";
    _dateController.text = DateFormat('dd/MM/yyyy')
        .format(DateTime.parse(
            "${widget.manager.getUser()['dob'] ?? "1900-01-01"}"))
        .toString();
    _gender = "${widget.manager.getUser()['gender']}".capitalizeFirst!;
    _placeholder =
        "${widget.manager.getUser()['gender'] ?? "Select your gender"}"
            .capitalizeFirst!;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextSecondary(
          text: "Kindly fill the form below to complete your KYC process",
          color: kPrimaryColor,
          fontSize: 16,
          align: TextAlign.center,
          fontWeight: FontWeight.w500,
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
              TextSecondary(
                text: "Gender",
                color: kPrimaryColor,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
              RoundedDropdownGender(
                placeholder: _placeholder,
                onSelected: onSelected,
                items: const ["Male", "Female"],
              ),
              const SizedBox(
                height: 5.0,
              ),
              TextSecondary(
                text: "Date of Birth",
                color: kPrimaryColor,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
              RoundedDatePicker(
                hintText: _dob ?? "dd/mm/yyyy",
                onSelected: onDateSelected,
                validator: (value) {
                  if (value.isEmpty) {
                    return 'Enter your date of birth';
                  }
                  return null;
                },
                controller: _dateController,
              ),
              const SizedBox(
                height: 5.0,
              ),
              TextSecondary(
                text: "BVN",
                color: kPrimaryColor,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
              RoundedInputField(
                hintText: "BVN",
                icon: Icons.person,
                onChanged: (value) {},
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Enter your bvn';
                  }
                  if (value.length > 11) {
                    return 'Enter a valid bvn';
                  }
                  return null;
                },
                controller: _bvnController,
                inputType: TextInputType.number,
              ),
              const SizedBox(
                height: 5.0,
              ),
              TextSecondary(
                text: "BVN Phone",
                color: kPrimaryColor,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
              RoundedPhoneField(
                hintText: "BVN Phone",
                onChanged: (value) {},
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your bvn phone number';
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
                text: "SAVE KYC",
                press: () {
                  if (_formKey.currentState!.validate() && _gender.isNotEmpty) {
                    _saveKYC();
                  } else {
                    debugPrint("JKBS;:");
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
