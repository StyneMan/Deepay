import 'package:deepay/Screens/Home/home.dart';
import 'package:deepay/helper/preferences/preference_manager.dart';
import 'package:deepay/helper/state/state_controller.dart';
import 'package:flutter/material.dart' hide ModalBottomSheetRoute;
import 'package:deepay/constants.dart';
import 'package:deepay/components/background/background.dart';
import 'package:deepay/components/text/text_widget.dart';
import 'package:get/get.dart';

class Messages extends StatelessWidget {
  PreferenceManager? manager;
  Messages({
    Key? key,
    this.manager,
  }) : super(key: key);

  final _controller = Get.find<StateController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Background(
          child: ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              const SizedBox(height: 8.0),
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Center(
                    child: TextSecondary(
                      text: 'Messages',
                      fontSize: 24,
                      color: kPrimaryColor,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Positioned(
                    top: -12,
                    left: 0.0,
                    child: FloatingActionButton(
                      onPressed: () {
                        _controller.selectTab(
                          Home(manager: manager),
                          _controller.pageKeys[0],
                          0,
                        );
                      },
                      mini: true,
                      elevation: 2,
                      backgroundColor: Colors.white,
                      child: const Icon(Icons.arrow_back, color: kPrimaryColor),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10.0),
            ],
          ),
        ),
      ),
    );
  }
}
