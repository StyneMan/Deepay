import 'dart:convert';

import 'package:deepay/helper/preferences/preference_manager.dart';
import 'package:flutter/material.dart' hide ModalBottomSheetRoute;
import 'package:get/get.dart';
import 'package:page_transition/page_transition.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../Screens/services/confirm_transaction.dart';
import '../../components/rounded_button.dart';
import '../../components/rounded_dropdown.dart';
import '../../components/rounded_dropdown_gender.dart';
import '../../components/rounded_dropdown_product.dart';
import '../../components/rounded_input_field.dart';
import '../../components/rounded_input_meter_num.dart';
import '../../components/rounded_input_money.dart';
import '../../components/rounded_phone_field.dart';
import '../../components/text/text_widget.dart';
import '../../constants.dart';
import '../../helper/database/database_handler.dart';
import '../../helper/service/api_service.dart';
import '../../helper/state/state_controller.dart';
import '../../model/error/error.dart';
import '../../model/networks/mproducts.dart';
import '../../model/networks/network_product.dart';
import '../../model/products/product_model.dart';
import '../../model/transactions/transaction_response.dart';

class ServiceForm extends StatefulWidget {
  final bool isAuthenticated;
  final String service;
  final String token;
  final ProductModel product;
  final String? mAmount;
  final PreferenceManager manager;

  const ServiceForm({
    Key? key,
    this.mAmount,
    required this.token,
    required this.service,
    required this.product,
    required this.manager,
    required this.isAuthenticated,
  }) : super(key: key);

  @override
  State<ServiceForm> createState() => _ServiceFormState();
}

class _ServiceFormState extends State<ServiceForm> {
  String _networkValue = "";
  String _productName = "";
  final int _productAmount = 0;
  final String _countryCode = "+234";
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  final TextEditingController? _amountFixedController = TextEditingController();
  final TextEditingController? _amountController = TextEditingController();
  final TextEditingController? _emailController = TextEditingController();
  final TextEditingController _meterNumController = TextEditingController();
  final TextEditingController _smartCardNumController = TextEditingController();
  NetworkProducts? _selectedNetwork;
  MProduct? _selectedProduct;
  double _discountAmt = 0.0;
  String _discountPercent = "";
  bool _isLoggedIn = false;
  List<MProduct>? _mproducts = [];
  final _controller = Get.find<StateController>();

  String _meterType = "Prepaid";

  void onSelectedMeter(String type) {
    setState(() {
      _meterType = type;
    });
  }

  _initAuth() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      setState(() {
        _isLoggedIn =
            prefs.getString('accessToken').toString().isEmpty ? false : true;
      });
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  void setSelected(String val, NetworkProducts? network) {
    debugPrint("JUST SELECTED NOW::: ${network?.products?.length}");
    debugPrint("JUST SELECTED VALUE::: $val");

    setState(() {
      _networkValue = val;
      _selectedNetwork = network;
    });
    _mproducts = _products(network?.products);
    // _updateProductList(network);
    // _computeDiscount(network);
  }

  List<MProduct>? _products(List<MProduct>? arr) {
    List<MProduct>? roducts = <MProduct>[];
    roducts = arr;
    return roducts;
  }

  void setSelectedProd(
      int amount, String val, MProduct product, String discount) {
    if (discount.isNotEmpty) {
      double percent = double.parse(discount) / 100;
      double calc = amount * percent;
      setState(() => _discountAmt = amount - calc);

      debugPrint("DISCOUNT AMT:: $calc");
    } else {
      setState(() => _discountAmt = double.parse("$amount.0"));
    }
    setState(() {
      _amountFixedController?.text = "$amount";
      _productName = val;
      _selectedProduct = product;
      _discountPercent = discount;
    });
  }

  // void _computeDiscount(NetworkProducts? network) {
  //   double discountPercent =
  //       (double.parse("${network?.discountPercent}") / 100);
  //   double mantissa =
  //       discountPercent * double.parse("${_amountController?.text}");

  //   setState(() {
  //     _discountAmt = double.parse("${_amountController?.text}") - mantissa;
  //   });
  // }

  @override
  void initState() {
    _initAuth();
    super.initState();
    debugPrint("PRDUCT DATA: ${widget.product.createdAt}");
  }

  _guestPayTv() async {
    _controller.setLoading(true);

    Map _payloadGuestTV = {
      "amount": "$_discountAmt",
      "network_id": _selectedNetwork?.id,
      "phone": _phoneController.text,
      "transaction_type": widget.service.toLowerCase(),
      "email": _emailController?.text,
      "isn": _smartCardNumController.text,
      "product_id": _selectedProduct?.id,
    };

    try {
      final resp = await APIService().guestBuy(_payloadGuestTV);
      debugPrint("${widget.service}:: ${resp.body}");
      _controller.setLoading(false);
      if (resp.statusCode == 200) {
        Map<String, dynamic> map = jsonDecode(resp.body);
        TransactionResponse trans = TransactionResponse.fromJson(map);

        //Save to sqlite
        await DatabaseHandler().saveTransaction(trans.data);

        toast("${trans.message}");

        Navigator.push(
          context,
          PageTransition(
            type: PageTransitionType.rightToLeft,
            isIos: true,
            child: ConfirmTransaction(
              model: trans.data,
              isLoggedIn: false,
              token: "",
              manager: widget.manager,
              phone: _phoneController.text,
            ),
          ),
        );
      } else {
        Map<String, dynamic> errorMap = jsonDecode(resp.body);
        ErrorResponse error = ErrorResponse.fromJson(errorMap);
        toast("${error.message}");
      }
    } catch (e) {
      _controller.setLoading(false);
    }
  }

  _guestPayData() async {
    _controller.setLoading(true);

    Map _payload = {
      "amount": "$_discountAmt",
      "network_id": _selectedNetwork?.id,
      "phone": _phoneController.text,
      "transaction_type": widget.service.toLowerCase(),
      "email": _emailController?.text,
      "product_id": _selectedProduct?.id,
    };

    try {
      final resp = await APIService().guestBuy(_payload);
      debugPrint("${widget.service}:: ${resp.body}");
      _controller.setLoading(false);
      if (resp.statusCode == 200) {
        Map<String, dynamic> map = jsonDecode(resp.body);
        TransactionResponse trans = TransactionResponse.fromJson(map);

        //Save to sqlite
        await DatabaseHandler().saveTransaction(trans.data);

        toast("${trans.message}");

        Navigator.push(
          context,
          PageTransition(
            type: PageTransitionType.rightToLeft,
            isIos: true,
            child: ConfirmTransaction(
              model: trans.data,
              isLoggedIn: false,
              token: "",
              manager: widget.manager,
              phone: _phoneController.text,
            ),
          ),
        );
      } else {
        Map<String, dynamic> errorMap = jsonDecode(resp.body);
        ErrorResponse error = ErrorResponse.fromJson(errorMap);
        toast("${error.message}");
      }
    } catch (e) {
      _controller.setLoading(false);
    }
  }

  _guestPayAirtime() async {
    _controller.setLoading(true);

    String? amt = _amountController?.text.replaceAll("₦ ", "");
    String filteredAmt = amt!.replaceAll(",", "");
    int price = int.parse(amt.replaceAll(",", ""));

    Map _payload = {
      "amount": amt.replaceAll(",", ""),
      "network_id": _selectedNetwork?.id,
      "phone": _phoneController.text,
      "transaction_type": widget.service.toLowerCase(),
      "email": _emailController?.text,
    };

    try {
      final resp = await APIService().guestBuy(_payload);
      debugPrint("${widget.service}:: ${resp.body}");
      _controller.setLoading(false);
      if (resp.statusCode == 200) {
        Map<String, dynamic> map = jsonDecode(resp.body);
        TransactionResponse trans = TransactionResponse.fromJson(map);

        //Save to sqlite
        await DatabaseHandler().saveTransaction(trans.data);

        toast("${trans.message}");

        Navigator.push(
          context,
          PageTransition(
            type: PageTransitionType.rightToLeft,
            isIos: true,
            child: ConfirmTransaction(
              model: trans.data,
              isLoggedIn: false,
              token: "",
              manager: widget.manager,
              phone: _phoneController.text,
            ),
          ),
        );
      } else {
        Map<String, dynamic> errorMap = jsonDecode(resp.body);
        ErrorResponse error = ErrorResponse.fromJson(errorMap);
        toast("${error.message}");
      }
    } catch (e) {
      _controller.setLoading(false);
    }
  }

  _guestPayElectricity() async {
    _controller.setLoading(true);

    String? amt = _amountController?.text.replaceAll("₦ ", "");
    String filteredAmt = amt!.replaceAll(",", "");
    int price = int.parse(amt.replaceAll(",", ""));

    Map _payload = {
      "amount": price,
      "disco_id": _selectedNetwork?.id,
      "phone": _phoneController.text,
      "transaction_type": widget.service.toLowerCase(),
      "email": _emailController?.text,
      "product_id": _selectedProduct?.id,
      "meter_number": _meterNumController.text,
      "meter_type": _meterType.toLowerCase(),
    };

    try {
      final resp = await APIService().guestBuy(_payload);
      debugPrint("${widget.service}:: ${resp.body}");
      _controller.setLoading(false);
      if (resp.statusCode == 200) {
        Map<String, dynamic> map = jsonDecode(resp.body);
        TransactionResponse trans = TransactionResponse.fromJson(map);

        //Save to sqlite
        await DatabaseHandler().saveTransaction(trans.data);

        toast("${trans.message}");

        Navigator.push(
          context,
          PageTransition(
            type: PageTransitionType.rightToLeft,
            isIos: true,
            child: ConfirmTransaction(
              model: trans.data,
              isLoggedIn: false,
              token: "",
              manager: widget.manager,
              phone: _phoneController.text,
            ),
          ),
        );
      } else {
        Map<String, dynamic> errorMap = jsonDecode(resp.body);
        ErrorResponse error = ErrorResponse.fromJson(errorMap);
        toast("${error.message}");
      }
    } catch (e) {
      _controller.setLoading(false);
    }
  }

  _buyTv() async {
    _controller.setLoading(true);

    // print("SSSASS:: $_discountAmt");

    Map _payload = {
      "amount": "$_discountAmt",
      "network_id": _selectedNetwork?.id,
      "phone": _phoneController.text,
      "transaction_type": widget.service.toLowerCase(),
      "isn": _smartCardNumController.text,
      "product_id": _selectedProduct?.id,
    };

    try {
      final resp = await APIService().transaction(_payload);
      debugPrint("${widget.service}:: ${resp.body}");
      _controller.setLoading(false);
      if (resp.statusCode == 200) {
        Map<String, dynamic> map = jsonDecode(resp.body);
        TransactionResponse trans = TransactionResponse.fromJson(map);

        toast("${trans.message}");

        Navigator.push(
          context,
          PageTransition(
            type: PageTransitionType.rightToLeft,
            isIos: true,
            child: ConfirmTransaction(
              model: trans.data,
              isLoggedIn: true,
              token: widget.token,
              discount: _discountAmt,
              manager: widget.manager,
              phone: _phoneController.text,
            ),
          ),
        );
      } else {
        Map<String, dynamic> errorMap = jsonDecode(resp.body);
        ErrorResponse error = ErrorResponse.fromJson(errorMap);
        toast("${error.message}");
      }
    } catch (e) {
      _controller.setLoading(false);
    }
  }

  _buyData() async {
    _controller.setLoading(true);

    Map _payload = {
      "amount": "$_discountAmt",
      "network_id": _selectedNetwork?.id,
      "phone": _phoneController.text,
      "transaction_type": widget.service.toLowerCase(),
      "product_id": _selectedProduct?.id,
    };

    try {
      final resp = await APIService().transaction(_payload);
      debugPrint("${widget.service}:: ${resp.body}");
      _controller.setLoading(false);
      if (resp.statusCode == 200) {
        Map<String, dynamic> map = jsonDecode(resp.body);
        TransactionResponse trans = TransactionResponse.fromJson(map);

        toast("${trans.message}");

        Navigator.push(
          context,
          PageTransition(
            type: PageTransitionType.rightToLeft,
            isIos: true,
            child: ConfirmTransaction(
              model: trans.data,
              isLoggedIn: true,
              token: widget.token,
              discount: _discountAmt,
              manager: widget.manager,
              phone: _phoneController.text,
            ),
          ),
        );
      } else {
        Map<String, dynamic> errorMap = jsonDecode(resp.body);
        ErrorResponse error = ErrorResponse.fromJson(errorMap);
        toast("${error.message}");
      }
    } catch (e) {
      _controller.setLoading(false);
    }
  }

  _buyAirtime() async {
    _controller.setLoading(true);

    String? amt = _amountController?.text.replaceAll("₦ ", "");
    String filteredAmt = amt!.replaceAll(",", "");
    int price = int.parse(amt.replaceAll(",", ""));

    Map _payload = {
      "amount": amt.replaceAll(",", ""),
      "network_id": _selectedNetwork?.id,
      "phone": _phoneController.text,
      "transaction_type": widget.service.toLowerCase(),
    };

    try {
      final resp = await APIService().transaction(_payload);
      debugPrint("${widget.service}:: ${resp.body}");
      _controller.setLoading(false);
      if (resp.statusCode == 200) {
        Map<String, dynamic> map = jsonDecode(resp.body);
        TransactionResponse trans = TransactionResponse.fromJson(map);

        toast("${trans.message}");

        Navigator.push(
          context,
          PageTransition(
            type: PageTransitionType.rightToLeft,
            isIos: true,
            child: ConfirmTransaction(
              model: trans.data,
              isLoggedIn: true,
              token: widget.token,
              discount: _discountAmt,
              manager: widget.manager,
              phone: _phoneController.text,
            ),
          ),
        );
      } else {
        Map<String, dynamic> errorMap = jsonDecode(resp.body);
        ErrorResponse error = ErrorResponse.fromJson(errorMap);
        toast("${error.message}");
      }
    } catch (e) {
      _controller.setLoading(false);
    }
  }

  _buyElectricity() async {
    _controller.setLoading(true);

    String? amt = _amountController?.text.replaceAll("₦ ", "");
    String filteredAmt = amt!.replaceAll(",", "");
    int price = int.parse(amt.replaceAll(",", ""));

    Map _payload = {
      "amount": amt.replaceAll(",", ""),
      "disco_id": _selectedNetwork?.id,
      "phone": _phoneController.text,
      "transaction_type": widget.service,
      "meter_number": _meterNumController.text,
      "meter_type": _meterType.toLowerCase(),
    };

    try {
      final resp = await APIService().transaction(_payload);
      debugPrint("${widget.service}:: ${resp.body}");
      _controller.setLoading(false);
      if (resp.statusCode == 200) {
        Map<String, dynamic> map = jsonDecode(resp.body);
        TransactionResponse trans = TransactionResponse.fromJson(map);

        toast("${trans.message}");

        Navigator.push(
          context,
          PageTransition(
            type: PageTransitionType.rightToLeft,
            isIos: true,
            child: ConfirmTransaction(
              model: trans.data,
              isLoggedIn: true,
              token: widget.token,
              discount: _discountAmt,
              manager: widget.manager,
              phone: _phoneController.text,
            ),
          ),
        );
      } else {
        Map<String, dynamic> errorMap = jsonDecode(resp.body);
        ErrorResponse error = ErrorResponse.fromJson(errorMap);
        toast("${error.message}");
      }
    } catch (e) {
      _controller.setLoading(false);
    }
  }

  _beginTransaction() async {
    if (_isLoggedIn) {
      //Auth user
      if (widget.service.toLowerCase() == "airtime") {
        _buyAirtime();
      } else if (widget.service.toLowerCase() == "data") {
        _buyData();
      } else if (widget.service.toLowerCase() == "electricity") {
        _buyElectricity();
      } else {
        _buyTv();
      }
    } else {
      //Guest user
      if (widget.service.toLowerCase() == "airtime") {
        _guestPayAirtime();
      } else if (widget.service.toLowerCase() == "data") {
        _guestPayData();
      } else if (widget.service.toLowerCase() == "electricity") {
        _guestPayElectricity();
      } else {
        _guestPayTv();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          !widget.isAuthenticated
              ? Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextSecondary(
                      text: "Email Address",
                      color: kPrimaryColor,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                    RoundedInputField(
                      hintText: "Enter your email",
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
                      controller: _emailController!,
                      inputType: TextInputType.emailAddress,
                    ),
                    const SizedBox(
                      height: 5.0,
                    ),
                  ],
                )
              : const SizedBox(),
          TextSecondary(
            text: "Phone Number",
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
              if (value.length < 11) {
                return 'Phone number not valid';
              }
              return null;
            },
            inputType: TextInputType.phone,
            controller: _phoneController,
          ),
          widget.service.toLowerCase() == "electricity"
              ? Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextSecondary(
                      text: "Meter Number",
                      color: kPrimaryColor,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                    RoundedInputMeterNumber(
                      hintText: "Enter meter number",
                      icon: Icons.numbers,
                      onChanged: (value) {},
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your meter number';
                        }
                        return null;
                      },
                      controller: _meterNumController,
                    ),
                    const SizedBox(
                      height: 5.0,
                    ),
                    TextSecondary(
                      text: "Meter Type",
                      color: kPrimaryColor,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                    RoundedDropdownGender(
                      placeholder: "Select meter type",
                      onSelected: onSelectedMeter,
                      items: const ["Prepaid", "Postpaid"],
                    ),
                  ],
                )
              : widget.service.toLowerCase() == "cable_tv"
                  ? Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        TextSecondary(
                          text: "Smartcard/IUC No",
                          color: kPrimaryColor,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                        RoundedInputMeterNumber(
                          hintText: "Enter Smartcard/IUC number",
                          icon: Icons.numbers,
                          onChanged: (value) {},
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your smartcard number';
                            }
                            return null;
                          },
                          controller: _smartCardNumController,
                        ),
                        const SizedBox(
                          height: 5.0,
                        ),
                      ],
                    )
                  : const SizedBox(),
          const SizedBox(
            height: 5.0,
          ),
          TextSecondary(
            text: "Network",
            color: kPrimaryColor,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
          RoundedDropdown(
            type: widget.service,
            placeholder: "Select network",
            networks: widget.product.networks,
            onSelected: setSelected,
          ),
          const SizedBox(
            height: 5.0,
          ),
          (widget.service.toLowerCase() == "data" ||
                  widget.service.toLowerCase() == "cable_tv")
              ? Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextSecondary(
                      text: widget.service.toLowerCase() == "data"
                          ? "Data Bundles"
                          : "Bouquets",
                      color: kPrimaryColor,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                    RoundedDropdownProduct(
                      placeholder: "Select plan",
                      products: _mproducts ?? [],
                      product: _selectedProduct,
                      onSelected: setSelectedProd,
                      value: _productName,
                    ),
                  ],
                )
              : const SizedBox(),
          (widget.service.toLowerCase() == "data" ||
                  widget.service.toLowerCase() == "cable_tv")
              ? Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        TextSecondary(
                          text: "Amount",
                          color: kPrimaryColor,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                        TextSecondary(
                          text:
                              '${nairaSign(context).currencySymbol} ${formatMoneyFloat(_discountAmt)}',
                          color: kPrimaryColor,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ],
                    ),
                    RoundedInputMoney(
                      hintText: "Enter amount",
                      onChanged: (val) {},
                      enabled: false,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter amount';
                        }
                        return null;
                      },
                      controller: _amountFixedController!,
                    ),
                    TextSecondary(
                      text: _selectedNetwork == null
                          ? ""
                          : "${_discountPercent.length < 3 ? _discountPercent : _discountPercent.substring(0, 4)}% Discount",
                      color: kPrimaryColor,
                      fontSize: 13,
                    ),
                  ],
                )
              : Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        TextSecondary(
                          text: "Amount",
                          color: kPrimaryColor,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                        TextSecondary(
                          text:
                              '${nairaSign(context).currencySymbol} ${formatMoneyFloat(_discountAmt)}',
                          color: kPrimaryColor,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ],
                    ),
                    RoundedInputMoney(
                      hintText: "Enter amount",
                      onChanged: (val) {
                        // debugPrint("CHANGED::: $val");
                        if (_selectedNetwork != null) {
                          String filtered =
                              val.replaceAll("₦ ", "").replaceAll(",", "");
                          double _dolomite = double.parse(filtered);

                          if (_selectedNetwork!.discountPercent!.isNotEmpty) {
                            double percent = double.parse(
                                    _selectedNetwork!.discountPercent!) /
                                100;
                            double calc = _dolomite * percent;

                            setState(() => _discountAmt = _dolomite - calc);

                            debugPrint("DISCOUNT AMT:: $calc");
                          } else {
                            setState(() => _discountAmt = _dolomite);
                          }
                        }
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter amount';
                        }
                        return null;
                      },
                      controller: _amountController!,
                    ),
                    TextSecondary(
                      text: _selectedNetwork == null
                          ? ""
                          : "${_selectedNetwork?.discountPercent}% Discount",
                      color: kPrimaryColor,
                      fontSize: 13,
                    ),
                  ],
                ),
          const SizedBox(
            height: 5.0,
          ),
          RoundedButton(
            text: "CONTINUE",
            press: () {
              if (_formKey.currentState!.validate()) {
                _beginTransaction();
              }
            },
          ),
        ],
      ),
    );
  }
}
