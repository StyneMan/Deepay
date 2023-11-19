import 'package:deepay/Screens/Login/login_screen.dart';
import 'package:deepay/helper/preferences/preference_manager.dart';
import 'package:deepay/helper/state/state_controller.dart';
import 'package:flutter/material.dart' hide ModalBottomSheetRoute;
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

typedef void InitCallback(bool hideNav);

class AuthController extends StatefulWidget {
  final PreferenceManager manager;
  final Widget child;
  final InitCallback? onHide;
  const AuthController({
    Key? key,
    required this.manager,
    required this.child,
    this.onHide,
  }) : super(key: key);

  @override
  State<AuthController> createState() => _AuthControllerState();
}

class _AuthControllerState extends State<AuthController> {
  Widget? component;
  bool _isLoggedIn = false;
  final _controller = Get.find<StateController>();

  _initAuth() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _isLoggedIn = prefs.getBool('loggedIn') ?? false;
      if (_isLoggedIn) {
        _controller.setHideNav(false);
        Future.delayed(const Duration(milliseconds: 4), () {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => widget.child,
            ),
          );
        });
      } else {
        _controller.setHideNav(true);
        Future.delayed(const Duration(milliseconds: 4), () {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(
              builder: (context) => LoginScreen(),
            ),
            (Route<dynamic> route) => false,
          );

          // Navigator.pushReplacement(
          //   context,
          //   MaterialPageRoute(
          //     builder: (context) => LoginScreen(),
          //   ),
          // );
        });
        widget.onHide!(true);
      }
    } catch (e) {
      debugPrint("$e");
    }
  }

  @override
  void initState() {
    _initAuth();
    super.initState();
    //  Future.delayed(const Duration(seconds: 1), () {
    //   Navigator.of(context).pushAndRemoveUntil(
    //     MaterialPageRoute(
    //       builder: (context) => const Login(),
    //     ),
    //     (Route<dynamic> route) => false,
    //   );
    // });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
    );
  }
}
