import 'dart:convert';
import 'dart:io';

import 'package:deepay/components/dialog/custom_dialog.dart';
import 'package:flutter/material.dart' hide ModalBottomSheetRoute;
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/instance_manager.dart';
import 'package:http/http.dart' as http;
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart' as MBottomSheet;
import 'package:shared_preferences/shared_preferences.dart';

import '../../../components/picker/img_picker.dart';
import '../../../components/rounded_button.dart';
import '../../../components/rounded_button_wrapped.dart';
import '../../../components/rounded_dropdown_gender.dart';
import '../../../components/rounded_input_field.dart';
import '../../../components/rounded_input_money.dart';
import '../../../components/text/text_widget.dart';
import '../../../constants.dart';
import '../../../helper/preferences/preference_manager.dart';
import '../../../helper/service/api_service.dart';
import '../../../helper/state/state_controller.dart';
import '../../../model/error/error.dart';

class MBT extends StatefulWidget {
  final PreferenceManager manager;
  const MBT({
    Key? key,
    required this.manager,
  }) : super(key: key);

  @override
  State<MBT> createState() => _MBTState();
}

class _MBTState extends State<MBT> {
  final _formKey = GlobalKey<FormState>();

  final _controller = Get.find<StateController>();
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();

  String _selectedBank = "GTB - 0598317536";
  bool _isImagePicked = false, _paid = false;
  var _croppedFile;

  _onImageSelected(var file) {
    setState(() {
      _isImagePicked = true;
      _croppedFile = file;
    });
    debugPrint("VALUIE::: :: $file");
  }

  void onSelected(String value) {
    _selectedBank = value;
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        TextSecondary(
          text: "Fund your wallet via Manual Bank Transfer",
          fontSize: 18,
          align: TextAlign.center,
          fontWeight: FontWeight.w600,
        ),
        TextSecondary(
          text:
              "Only submit request, after successful transfer to the company's account.",
          fontSize: 13,
          color: kPrimaryLightColor,
          align: TextAlign.center,
          fontWeight: FontWeight.w400,
        ),
        const SizedBox(
          height: 18.0,
        ),
        Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextSecondary(
                text: "Amount",
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
              RoundedInputMoney(
                hintText: "Enter amount",
                onChanged: (val) {
                  // _computeDiscount(_selectedNetwork);
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter amount';
                  }
                  return null;
                },
                controller: _amountController,
              ),
              const SizedBox(
                height: 10.0,
              ),
              RoundedDropdownGender(
                placeholder: "Select account",
                onSelected: onSelected,
                items: const ["GTB - 0598317536", "Paycom(Opay) - 8148337436"],
              ),
              const SizedBox(
                height: 4.0,
              ),
              RoundedInputField(
                hintText: "Enter sender's name",
                onChanged: (val) {},
                controller: _nameController,
                capitalization: TextCapitalization.words,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter sender\'s name';
                  }
                  return null;
                },
                inputType: TextInputType.name,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Checkbox(
                        value: _paid,
                        onChanged: (checked) {
                          setState(() {
                            _paid = checked!;
                          });
                        },
                      ),
                      TextSecondary(
                        text: "I have paid",
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ],
                  ),
                  // const SizedBox(
                  //   width: 10.0,
                  // ),
                  // RoundedButtonWrapped(
                  //   text: "Upload proof",
                  //   press: () {
                  //     MBottomSheet.showBarModalBottomSheet(
                  //       expand: false,
                  //       context: context,
                  //       topControl: ClipOval(
                  //         child: GestureDetector(
                  //           onTap: () {
                  //             Navigator.of(context).pop();
                  //           },
                  //           child: Container(
                  //             width: 32,
                  //             height: 32,
                  //             decoration: BoxDecoration(
                  //               color: Colors.white,
                  //               borderRadius: BorderRadius.circular(
                  //                 16,
                  //               ),
                  //             ),
                  //             child: const Center(
                  //               child: Icon(
                  //                 Icons.close,
                  //                 size: 24,
                  //               ),
                  //             ),
                  //           ),
                  //         ),
                  //       ),
                  //       backgroundColor: Colors.white,
                  //       builder: (context) => SizedBox(
                  //         height: 144,
                  //         child: ImgPicker(
                  //           onCropped: _onImageSelected,
                  //         ),
                  //       ),
                  //     );
                  //   },
                  // ),
                ],
              ),
              // ClipRRect(
              //   borderRadius: BorderRadius.circular(10.0),
              //   child: _isImagePicked
              //       ? SizedBox(
              //           height: 120,
              //           width: double.infinity,
              //           child: Image.file(
              //             File(_croppedFile),
              //             errorBuilder: (context, error, stackTrace) =>
              //                 ClipOval(
              //               child: Image.asset(
              //                 "assets/images/placeholder.png",
              //                 fit: BoxFit.cover,
              //               ),
              //             ),
              //             fit: BoxFit.cover,
              //           ),
              //         )
              //       : GestureDetector(
              //           onTap: () {
              //             MBottomSheet.showBarModalBottomSheet(
              //               expand: false,
              //               context: context,
              //               topControl: ClipOval(
              //                 child: GestureDetector(
              //                   onTap: () {
              //                     Navigator.of(context).pop();
              //                   },
              //                   child: Container(
              //                     width: 32,
              //                     height: 32,
              //                     decoration: BoxDecoration(
              //                       color: Colors.white,
              //                       borderRadius: BorderRadius.circular(
              //                         16,
              //                       ),
              //                     ),
              //                     child: const Center(
              //                       child: Icon(
              //                         Icons.close,
              //                         size: 24,
              //                       ),
              //                     ),
              //                   ),
              //                 ),
              //               ),
              //               backgroundColor: Colors.white,
              //               builder: (context) => SizedBox(
              //                 height: 144,
              //                 child: ImgPicker(
              //                   onCropped: _onImageSelected,
              //                 ),
              //               ),
              //             );
              //           },
              //           child: Container(
              //             color: kPrimaryLightColor,
              //             height: 120,
              //             width: double.infinity,
              //             child: Center(
              //               child: TextSecondary(
              //                 text:
              //                     "Proof of paymet not selected. Select to continue",
              //                 fontSize: 14,
              //                 align: TextAlign.center,
              //               ),
              //             ),
              //           ),
              //         ),
              // ),
              const SizedBox(height: 21.0),
              RoundedButton(
                text: "Submit Request",
                press: _paid
                    ? () {
                        if (_formKey.currentState!.validate()) {
                          _submitRequest();
                        }
                      }
                    : null,
              ),
              const SizedBox(height: 75.0),
            ],
          ),
        ),
      ],
    );
  }

  _uploadToServer() async {
    _controller.setLoading(true);
    String amt = _amountController.text.replaceAll("₦ ", "");

    try {
      final _prefs = await SharedPreferences.getInstance();
      final _token = _prefs.getString("accessToken") ?? "";

      final req = await APIService().fundWalletRequest2(accessToken: _token);

      req.fields['amount'] = amt.replaceAll(",", "");
      req.fields['designated_bank'] = _selectedBank;
      req.fields['payee_name'] = _nameController.text;

      req.files.add(await http.MultipartFile.fromPath('image', _croppedFile));
      req.send().then((value) {
        http.Response.fromStream(value).then((resp) {
          try {
            // resp.body
            debugPrint("UPLOAD RESPNOSE::: :: ${resp.body}");
            _controller.setLoading(false);
            if (resp.statusCode == 200) {
              Map<String, dynamic> map = jsonDecode(resp.body);
              toast("${map['message']}");
            } else {
              Map<String, dynamic> errorMap = jsonDecode(resp.body);
              ErrorResponse error = ErrorResponse.fromJson(errorMap);
              toast("${error.message}");
            }
          } catch (e) {
            _controller.setLoading(false);
            debugPrint(e.toString());
          }
        });
      });
    } catch (e) {
      _controller.setLoading(false);
      debugPrint(e.toString());
    }
  }

  _submitRequest() async {
    _controller.setLoading(true);
    String amt = _amountController.text.replaceAll("₦ ", "");

    Map _payload = {
      "amount": amt.replaceAll(",", ""),
      "designated_bank": _selectedBank,
      "payee_name": _nameController.text,
    };

    try {
      final _prefs = await SharedPreferences.getInstance();
      final _token = _prefs.getString("accessToken") ?? "";

      final resp = await APIService().fundWalletRequest(_payload, _token);
      _controller.setLoading(false);
      debugPrint("FUND MBT RESP :: ${resp.body}");

      if (resp.statusCode == 200) {
        Map<String, dynamic> _respMap = jsonDecode(resp.body);
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
                          "Hi ${_respMap['data']['payee_name']}, ${_respMap['message']}",
                      fontSize: 17,
                      align: TextAlign.center,
                      fontWeight: FontWeight.w600,
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
        //Error occurred on login
        Map<String, dynamic> errorMap = jsonDecode(resp.body);
        ErrorResponse error = ErrorResponse.fromJson(errorMap);
        toast("${error.message}");
      }
    } catch (e) {
      _controller.setLoading(false);
      debugPrint(e.toString());
    }
  }
}
