import 'dart:io';

import 'package:deepay/components/text/text_widget.dart';
import 'package:deepay/constants.dart';
import 'package:deepay/helper/service/api_service.dart';
import 'package:deepay/helper/state/state_controller.dart';
import 'package:flutter/material.dart' hide ModalBottomSheetRoute;
import 'package:get/get.dart';

class NoInternet extends StatelessWidget {
  NoInternet({
    Key? key,
  }) : super(key: key);

  final _controller = Get.find<StateController>();

  _refresh() async {
    _controller.setLoading(true);
    try {
      final response = await APIService().getProducts();
      // print("PRODUCT RESP:: ${response.body}");
      _controller.setLoading(false);
      if (response.statusCode == 200) {
        //Kill screen
        _controller.setHasInternet(true);
      }
    } on SocketException {
      _controller.setLoading(false);
      _controller.setHasInternet(false);
      toast("No Internet Connection!");
    } on Error catch (e) {
      _controller.setLoading(false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: Colors.white,
      padding: const EdgeInsets.all(10.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Image.asset("assets/images/no_internet.png"),
          const SizedBox(height: 2.0),
          TextButton(
            child: TextSecondary(
              text: "Try Again",
              fontSize: 14,
              color: kPrimaryColor,
            ),
            onPressed: () {
              _refresh();
            },
          ),
        ],
      ),
    );
  }
}
