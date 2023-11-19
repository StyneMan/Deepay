import 'dart:convert';

import 'package:deepay/Screens/Dashboard/dashboard.dart';
import 'package:deepay/components/dialog/custom_dialog.dart';
import 'package:deepay/components/dialog/info_dialog.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' hide ModalBottomSheetRoute;
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../components/background/background.dart';
import '../../../components/drawer/custom_drawer.dart';
import '../../../components/rounded_button.dart';
import '../../../components/rounded_dropdown_airtimecash.dart';
import '../../../components/rounded_input_field.dart';
import '../../../components/rounded_input_money.dart';
import '../../../components/text/text_widget.dart';
import '../../../constants.dart';
import '../../../helper/preferences/preference_manager.dart';
import '../../../helper/service/api_service.dart';
import '../../../helper/state/state_controller.dart';
import '../../Account/account.dart';

class AirtimeSwap extends StatefulWidget {
  final PreferenceManager manager;
  final String service;
  AirtimeSwap({
    Key? key,
    required this.service,
    required this.manager,
  }) : super(key: key);

  @override
  State<AirtimeSwap> createState() => _AirtimeSwapState();
}

class _AirtimeSwapState extends State<AirtimeSwap> {
  final _controller = Get.find<StateController>();

  final _scaffoldKey = GlobalKey<ScaffoldState>();

  List<dynamic> _mainList = [], _subList = [];

  var _affectedItems = [];

  var _selectedItem = "";

  final _amountController = TextEditingController();

  final _phoneController = TextEditingController();

  Future _init() async {
    // _controller.setLoading(true);
    // try {
    final prefs = await SharedPreferences.getInstance();
    final String _token = prefs.getString('accessToken') ?? "";

    // if (_token.isNotEmpty) {
    final resp = await APIService().airtimeCash(_token);
    debugPrint("AIRTIME CASH ${resp.body}");
    return resp;
    // _controller.setLoading(false);
    // if (resp.statusCode == 200) {
    //   Map<String, dynamic> map = jsonDecode(resp.body);
    //   setState(() {
    //     _mainList = map['data'];
    //     _subList = map['data']?.sublist(0, 4);
    //   });
    //   // _controller.setAirtimeCash(map['data']);
    // } else {
    //   Map<String, dynamic> error = jsonDecode(resp.body);
    //   toast(error['message']);
    // }
    // }
    // } catch (e) {
    //   debugPrint(e.toString());
    //   _controller.setLoading(false);
    // }
  }

  onSelected(String val, aff) {
    print("VAL :: >> $_mainList");
    // print(
    //     "AFFECTED :: >> ${aff.toString().replaceAll("(", "[").replaceAll(")", "]")}");
    // if (_mainList.isNotEmpty) {

    // setState(() {
    _selectedItem = val;
    // });

    final arr = _mainList
        .where(
          (element) =>
              element['key'].toString().toLowerCase().substring(0, 3) ==
              "$val".toLowerCase().substring(0, 3),
        )
        .toList();

    print("ARR :: >> ${arr}");

    // final arrRate = _mainList.where((element) =>
    //     element['key'].toString().toLowerCase() ==
    //     "${val.toLowerCase()}_percentage");

    // print("ARR RATE  :: >> $arrRate");

    // final arrNumber = arr.where((element) =>
    //     element['key'].toString().toLowerCase() ==
    //     "${val.toLowerCase()}_number");

    _controller.airtimeSwapRate.value = arr[1]['value'];
    _controller.airtimeSwapNumber.value = arr[0]['value'];

    String? amt = _amountController.text.replaceAll("₦ ", "");
    String filteredAmt = amt.replaceAll(",", "");

    int rateVal = int.parse("${arr[1]['value']}");
    double decimal = (rateVal / 100);

    print("RATEVA :: $rateVal");
    print("DECIM :: $decimal");
    print("MOUNT :: $decimal");

    var reduce = int.parse(amt.replaceAll(",", "")) * decimal;

    _controller.airtimeSwapResultantAmt.value = "$reduce";
  }

  // @override
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        elevation: 0.2,
        backgroundColor: Colors.white,
        automaticallyImplyLeading: false,
        leading: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(width: 10),
            InkWell(
              onTap: () {
                Navigator.pop(context);
              },
              child: const Icon(
                Icons.arrow_back_rounded,
                color: kPrimaryColor,
                size: 24,
              ),
            ),
          ],
        ),
        title: TextSecondary(
          text: widget.service,
          fontSize: 21,
          fontWeight: FontWeight.w700,
          color: kPrimaryColor,
        ),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () {
              if (!_scaffoldKey.currentState!.isEndDrawerOpen) {
                _scaffoldKey.currentState!.openEndDrawer();
              }
            },
            icon: SvgPicture.asset(
              'assets/images/menu_icon.svg',
              color: kPrimaryColor,
            ),
          ),
        ],
      ),
      endDrawer: SizedBox(
        height: MediaQuery.of(context).size.height,
        child: CustomDrawer(
          manager: widget.manager,
        ),
      ),
      body: widget.manager.getUser()['has_kyc']
          ? Background(
              child: FutureBuilder<dynamic>(
                  future: _init(),
                  builder: (context, snap) {
                    if (snap.connectionState == ConnectionState.waiting) {
                      return Container(
                        color: kPrimaryLightColor,
                        width: double.infinity,
                        height: double.infinity,
                        child: const Center(
                          child: Text("Please wait ..."),
                        ),
                      );
                    }

                    if (snap.hasError) {
                      return Container(
                        color: kPrimaryLightColor,
                        width: double.infinity,
                        height: double.infinity,
                        child: const Center(
                          child: Text(
                              "An error occurred. Check your internet connection"),
                        ),
                      );
                    }

                    if (!snap.hasData) {
                      return SizedBox(
                        width: double.infinity,
                        height: double.infinity,
                        child: Center(
                          child: Image.asset(
                            "assets/images/no_record.png",
                            width: 275,
                          ),
                        ),
                      );
                    }

                    final data = snap.requireData;
                    debugPrint("SSDS:: ? ${data.body}");
                    Map<String, dynamic> _map = jsonDecode(data.body);
                    _mainList = _map['data'];
                    _subList = _map['data']?.sublist(0, 4);

                    return Obx(
                      () => ListView(
                        padding: const EdgeInsets.all(16.0),
                        children: [
                          TextSecondary(
                            text: "Convert your airtime to cash",
                            fontSize: 16,
                            align: TextAlign.center,
                          ),
                          const SizedBox(
                            height: 21,
                          ),
                          TextSecondary(
                            text: "Network",
                            fontSize: 16,
                            color: kPrimaryColor,
                          ),
                          RoundedDropdownAirtimeCash(
                            placeholder: "Select network",
                            mainList: _mainList,
                            subList: _subList,
                            onSelected: onSelected,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              TextSecondary(
                                text:
                                    "Rate: ${_controller.airtimeSwapRate.value}%",
                                fontSize: 12,
                                color: kPrimaryColor,
                              ),
                              const SizedBox(
                                width: 5.0,
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  const Icon(
                                    CupertinoIcons.arrow_right_to_line_alt,
                                  ),
                                  const SizedBox(
                                    width: 4.0,
                                  ),
                                  TextSecondary(
                                    text:
                                        "${_controller.airtimeSwapNumber.value}",
                                    fontSize: 12,
                                    color: kSecondaryColor,
                                  )
                                ],
                              )
                            ],
                          ),
                          const SizedBox(
                            height: 21.0,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              TextSecondary(
                                text: "Amount",
                                fontSize: 16,
                                color: kPrimaryColor,
                              ),
                              Text(
                                  "${nairaSign(context).currencySymbol}${_controller.airtimeSwapResultantAmt.value}")
                            ],
                          ),
                          RoundedInputMoney(
                            hintText: "Enter amount",
                            onChanged: (val) {
                              String? amt = val.replaceAll("₦ ", "");
                              String filteredAmt = amt.replaceAll(",", "");
                              // print("SELCETD NEDWORK:: $_networkValue");
                              // print(
                              //     "SELCETED RATE:: ${_controller.airtimeSwapRate.value}");
                              // print("CURRENT AMOUNT TF:: $val");

                              //In real time here
                              if (_selectedItem.isNotEmpty) {
                                int rateVal = int.parse(
                                    _controller.airtimeSwapRate.value);
                                double decimal = (rateVal / 100);
                                var reduce =
                                    int.parse(amt.replaceAll(",", "")) *
                                        decimal;

                                _controller.airtimeSwapResultantAmt.value =
                                    "$reduce";
                              }
                            },
                            enabled: true,
                            icon: CupertinoIcons.money_dollar_circle_fill,
                            controller: _amountController,
                            validator: (newVal) {
                              if (newVal.toString().isEmpty) {
                                return "Amount is required";
                              }
                              return null;
                            },
                          ),
                          const SizedBox(
                            height: 21.0,
                          ),
                          TextSecondary(
                            text: "Phone number to debit from",
                            fontSize: 16,
                            color: kPrimaryColor,
                          ),
                          RoundedInputField(
                            hintText: "Enter phone number",
                            onChanged: (val) {},
                            icon: CupertinoIcons.phone_circle_fill,
                            controller: _phoneController,
                            inputType: TextInputType.phone,
                            validator: (newVal) {
                              if (newVal.toString().isEmpty) {
                                return "Phone number is required";
                              }
                              if (newVal.toString().length < 11) {
                                return "Phone number is not valid";
                              }
                              return null;
                            },
                          ),
                          const SizedBox(
                            height: 21,
                          ),
                          RoundedButton(
                            text: "Continue",
                            press: () {
                              _airtimeSwap();
                            },
                          )
                        ],
                      ),
                    );
                  }),
            )
          : Background(
              child: Container(
                padding: const EdgeInsets.all(16.0),
                width: double.infinity,
                height: double.infinity,
                child: Stack(
                  children: [
                    Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          TextPrimary(
                            text: "KYC Required",
                            fontSize: 21,
                            color: kPrimaryColor,
                            align: TextAlign.center,
                            fontWeight: FontWeight.bold,
                          ),
                          const SizedBox(
                            height: 4.0,
                          ),
                          TextSecondary(
                            text: "Kindly complete KYC to Continue",
                            fontSize: 15,
                            align: TextAlign.center,
                          ),
                          const SizedBox(
                            height: 16.0,
                          ),
                          RoundedButton(
                            text: "Proceed",
                            press: () {
                              _controller.selectTab(
                                Account(
                                  manager: widget.manager,
                                ),
                                _controller.pageKeys[3],
                                3,
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                    Positioned(
                      top: 10,
                      left: 10,
                      right: 10,
                      child: TextSecondary(
                        text: "Convert your airtime to cash",
                        fontSize: 16,
                        align: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  _airtimeSwap() async {
    FocusManager.instance.primaryFocus?.unfocus();
    _controller.setLoading(true);
    String? amt = _amountController.text.replaceAll("₦ ", "");
    String filteredAmt = amt.replaceAll(",", "");

    try {
      final _prefs = await SharedPreferences.getInstance();
      final _token = _prefs.getString("accessToken") ?? "";

      Map _payload = {
        "amount": amt.replaceAll(",", ""),
        "network_id": "1",
        "phone": _phoneController.text
      };

      final resp = await APIService().airtimeCashRequest(_payload, _token);
      // debugPrint("AIRTIME RESPONSE <<<>>> ${resp.body}");
      _controller.setLoading(false);
      if (resp.statusCode == 200) {
        Map<String, dynamic> map = jsonDecode(resp.body);

        // setState(() {
        _amountController.clear();
        _phoneController.clear();
        // });

        _controller.airtimeSwapData.value = [];
        _controller.airtimeSwapRate.value = "";
        _controller.airtimeSwapNumber.value = "";
        _controller.airtimeSwapResultantAmt.value = "0.0";

        _controller.onInit();

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
                      text: "${map['message']}".capitalizeFirst,
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

        _controller.onInit();
      } else if (resp.statusCode == 422) {
        Map<String, dynamic> map = jsonDecode(resp.body);
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) {
            return SizedBox(
              height: 200,
              width: MediaQuery.of(context).size.width * 0.98,
              child: InfoDialog(
                body: TextSecondary(
                  text: "${map['message']}",
                  fontSize: 14,
                  align: TextAlign.center,
                ),
              ),
            );
          },
        );
      } else {
        Map<String, dynamic> map = jsonDecode(resp.body);
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) {
            return SizedBox(
              height: 200,
              width: MediaQuery.of(context).size.width * 0.98,
              child: InfoDialog(
                body: TextSecondary(
                  text: "${map['message']}",
                  fontSize: 14,
                  align: TextAlign.center,
                ),
              ),
            );
          },
        );
      }
    } catch (e) {
      _controller.setLoading(false);
      debugPrint(e.toString());
    }
  }
}
