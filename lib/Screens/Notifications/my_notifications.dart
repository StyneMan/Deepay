import 'package:flutter/material.dart' hide ModalBottomSheetRoute;
import 'package:get/instance_manager.dart';

import '../../components/background/background.dart';
import '../../components/text/text_widget.dart';
import '../../constants.dart';
import '../../helper/preferences/preference_manager.dart';
import '../../helper/state/state_controller.dart';
import '../Home/home.dart';

class MyNotifications extends StatefulWidget {
  final PreferenceManager? manager;
  const MyNotifications({
    Key? key,
    required this.manager,
  }) : super(key: key);

  @override
  State<MyNotifications> createState() => _MyNotificationsState();
}

class _MyNotificationsState extends State<MyNotifications> {
  final _controller = Get.find<StateController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  FloatingActionButton(
                    onPressed: () {
                      _controller.selectTab(
                        Home(
                          manager: widget.manager,
                        ),
                        _controller.pageKeys[0],
                        0,
                      );
                    },
                    mini: true,
                    elevation: 2.0,
                    backgroundColor: Colors.white,
                    child: const Icon(
                      Icons.arrow_back_rounded,
                      color: kPrimaryColor,
                      size: 24,
                    ),
                  ),
                  TextSecondary(
                    text: "My Notifications",
                    fontSize: 21,
                    fontWeight: FontWeight.w700,
                    color: kPrimaryColor,
                  ),
                  FloatingActionButton(
                    onPressed: () {},
                    mini: true,
                    elevation: 0.0,
                    backgroundColor: Colors.white,
                    child: Stack(
                      children: [
                        const Icon(
                          Icons.notifications,
                          color: Colors.transparent,
                          size: 24,
                        ),
                        Positioned(
                          top: 1,
                          right: 4,
                          child: ClipOval(
                            child: 2 > 0
                                ? Container(
                                    padding: const EdgeInsets.all(2.5),
                                    color: Colors.transparent,
                                  )
                                : const SizedBox(
                                    height: 1.0,
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Background(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      const SizedBox(height: 10.0),
                      Expanded(
                        child: Center(
                          child: Image.asset(
                            "assets/images/no_record.png",
                            width: 256,
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
