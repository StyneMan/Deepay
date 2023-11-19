import 'package:flutter/material.dart' hide ModalBottomSheetRoute;
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../components/drawer/custom_drawer.dart';
import '../../components/text/text_widget.dart';
import '../../constants.dart';
import '../../forms/service/service_form.dart';
import '../../helper/preferences/preference_manager.dart';
import '../../helper/state/state_controller.dart';
import '../../model/products/product_model.dart';
import '../../model/products/product_response.dart';

class ServiceInfo extends StatefulWidget {
  final String service;
  final bool isAuthenticated;
  final String? mAmount;

  const ServiceInfo({
    Key? key,
    this.mAmount,
    required this.service,
    required this.isAuthenticated,
  }) : super(key: key);

  @override
  State<ServiceInfo> createState() => _ServiceInfoState();
}

class _ServiceInfoState extends State<ServiceInfo> {
  final _controller = Get.find<StateController>();
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  ProductModel? product;
  PreferenceManager? _manager;
  String _token = "";

  _init() async {
    final _prefs = await SharedPreferences.getInstance();
    _token = _prefs.getString("accessToken") ?? "";
  }

  _filterProduct() {
    try {
      List<ProductModel>? products = [];
      if (_controller.products != null) {
        ProductResponse body = ProductResponse.fromJson(_controller.products!);
        products = body.data;
        // var resp = products?.map((e) => e.name == widget.service);
        products?.forEach((element) {
          if (element.name == widget.service.toLowerCase()) {
            setState(() {
              product = element;
            });
          }
        });
        // resp[0].
      }
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  @override
  void initState() {
    _filterProduct();
    _init();
    _manager = PreferenceManager(context);
    super.initState();
  }

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
          text: widget.service == "Cable_TV"
              ? widget.service.replaceAll("_", " ")
              : widget.service,
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
          manager: _manager!,
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 12),
        children: [
          SizedBox(
            height: (widget.service.toLowerCase() == "electricity" ||
                    widget.service.toLowerCase() == "cable_tv")
                ? 8.0
                : 12.0,
          ),
          ServiceForm(
            service: widget.service,
            product: product!,
            isAuthenticated: widget.isAuthenticated,
            token: _token,
            mAmount: widget.mAmount,
            manager: _manager!,
          ),
        ],
      ),
    );
  }
}
