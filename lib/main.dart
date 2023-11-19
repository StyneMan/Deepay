// ignore_for_file: unused_local_variable

import 'dart:async';

import 'package:deepay/Screens/Dashboard/dashboard.dart';
import 'package:deepay/constants.dart';
import 'package:deepay/helper/preferences/preference_manager.dart';
import 'package:deepay/helper/state/state_controller.dart';
import 'package:deepay/screens/Welcome/welcome_screen.dart';
import 'package:flutter/material.dart' hide ModalBottomSheetRoute;
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
      overlays: [SystemUiOverlay.bottom, SystemUiOverlay.top]);

  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    systemNavigationBarColor: kPrimaryLightColor, // navigation bar color
  ));

  await SentryFlutter.init(
    (options) {
      options.dsn =
          'https://9a011dd593764a8daf7207a5bc8c0b70@o1380824.ingest.sentry.io/6694361';
      // Set tracesSampleRate to 1.0 to capture 100% of transactions for performance monitoring.
      // We recommend adjusting this value in production.
      options.tracesSampleRate = 1.0;
    },
    appRunner: () => runApp(MyApp()),
  );
}

class MyApp extends StatefulWidget {
  MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _isLoggedIn = false;
  final _controller = Get.put(StateController());
  Widget? component;
  PreferenceManager? _manager;

  _init() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _isLoggedIn = prefs.getBool('loggedIn') ?? false;
      if (_isLoggedIn) {
        setState(() {
          component = Dashboard(manager: _manager!);
        });
        // Future.delayed(const Duration(milliseconds: 30), () {
        //   Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => Dashboard(manager: _manager),),);
        // });
      } else {
        setState(() {
          component = const WelcomeScreen();
        });
        // Future.delayed(const Duration(milliseconds: 50 ), () {
        //   Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) =>  const Login(),),);
        // });
      }
    } catch (e) {
      // print("$e");
    }
  }

  @override
  void initState() {
    _init();
    super.initState();
    _manager = PreferenceManager(context);
  }

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: Init.instance.initialize(),
      builder: (context, AsyncSnapshot snapshot) {
        // Show splash screen while waiting for app resources to load:
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const MaterialApp(
            debugShowCheckedModeBanner: false,
            home: Splash(),
          );
        } else {
          // Loading is done, return the app:
          return GetMaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'Deepay',
            theme: ThemeData(
              primaryColor: kPrimaryColor,
              scaffoldBackgroundColor: Colors.white,
            ),
            home: component,
          );
        }
      },
    );
  }
}

class Splash extends StatelessWidget {
  const Splash({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    bool lightMode =
        MediaQuery.of(context).platformBrightness == Brightness.light;
    return Container(
      color: lightMode ? kPrimaryColor : const Color(0xff042a49),
    );
  }
}

class Init {
  Init._();
  static final instance = Init._();

  Future initialize() async {
    await Future.delayed(const Duration(seconds: 5));
  }
}
