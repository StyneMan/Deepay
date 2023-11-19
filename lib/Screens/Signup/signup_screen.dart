import 'dart:io';

import 'package:deepay/Screens/Signup/components/body/body.dart';
import 'package:flutter/material.dart' hide ModalBottomSheetRoute;
import 'package:flutter/cupertino.dart';
import 'package:deepay/helper/state/state_controller.dart';
import 'package:get/get.dart';
import 'package:loading_overlay_pro/loading_overlay_pro.dart';

class SignUpScreen extends StatelessWidget {
  SignUpScreen({Key? key}) : super(key: key);

  final _controller = Get.find<StateController>();

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
        child: const Scaffold(
          body: Body(),
        ),
      ),
    );
  }
}
