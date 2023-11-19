import 'package:flutter/material.dart' hide ModalBottomSheetRoute;
import 'components/body/body.dart';
import 'package:deepay/helper/preferences/preference_manager.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({
    Key? key,
  }) : super(key: key);

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  PreferenceManager? _manager;

  @override
  void initState() {
    super.initState();
    _manager = PreferenceManager(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Body(manager: _manager!),
    );
  }
}
