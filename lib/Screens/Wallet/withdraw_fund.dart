import 'package:flutter/material.dart' hide ModalBottomSheetRoute;
import 'package:get/get.dart';

import '../../components/text/text_widget.dart';
import '../../constants.dart';
import '../../helper/preferences/preference_manager.dart';
import '../../helper/state/state_controller.dart';
import '../Welcome/components/background.dart';
import 'components/withdraw.dart';

class WithdrawFund extends StatefulWidget {
  final PreferenceManager manager;
  const WithdrawFund({
    Key? key,
    required this.manager,
  }) : super(key: key);

  @override
  State<WithdrawFund> createState() => _WithdrawFundState();
}

class _WithdrawFundState extends State<WithdrawFund> {
  final _controller = Get.find<StateController>();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Background(
          child: ListView(
            children: [
              const SizedBox(height: 8.0),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    TextPrimary(
                      text: "Withdraw Fund",
                      fontSize: 21,
                      fontWeight: FontWeight.w700,
                      color: kPrimaryColor,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10.0),
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.60,
                child: ListView(
                  padding: const EdgeInsets.all(16.0),
                  children: [
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.60,
                      child: Withdraw(manager: widget.manager),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
