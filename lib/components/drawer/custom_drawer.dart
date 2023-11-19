import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' hide ModalBottomSheetRoute;
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/instance_manager.dart';
import 'package:persistent_bottom_nav_bar/persistent-tab-view.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../Screens/About/about.dart';
import '../../constants.dart';
import '../../helper/preferences/preference_manager.dart';
import '../../helper/service/api_service.dart';
import '../../helper/state/state_controller.dart';
import '../../model/drawer/drawer_model.dart';
import '../../screens/Welcome/welcome_screen.dart';
import '../text/text_widget.dart';

class CustomDrawer extends StatefulWidget {
  final PreferenceManager manager;
  const CustomDrawer({
    Key? key,
    required this.manager,
  }) : super(key: key);

  @override
  State<CustomDrawer> createState() => _CustomDrawerState();
}

class _CustomDrawerState extends State<CustomDrawer> {
  List<DrawerModel> drawerList = [];

  final _controller = Get.find<StateController>();
  bool _isLoggedIn = false;

  _initAuth() async {
    final prefs = await SharedPreferences.getInstance();
    _isLoggedIn = prefs.getBool('loggedIn') ?? false;

    setState(() {
      drawerList = [
        DrawerModel(
          icon: 'assets/images/faq_drawer.svg',
          title: 'FAQs',
          isAction: true,
          url: "https://deepay.com.ng/faqs",
        ),
        DrawerModel(
          icon: CupertinoIcons.info,
          title: 'About us',
          isAction: true,
          url: "https://deepay.com.ng/about",
        ),
        DrawerModel(
          icon: 'assets/images/contact_drawer.svg',
          title: 'Contact us',
          isAction: true,
          url: "https://deepay.com.ng/contact",
        ),
      ];
    });
  }

  @override
  void initState() {
    super.initState();
    _initAuth();
  }

  _logOut() async {
    _controller.setLoading(true);
    try {
      final resp = await APIService().logout(widget.manager.getAccessToken());
      debugPrint("JKS:: ${resp.body}");
      _controller.setLoading(false);
      if (resp.statusCode == 200) {
        _controller.setHideNav(true);
        toast("Logged out successfully");
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
            builder: (context) => const WelcomeScreen(),
          ),
          (Route<dynamic> route) => false,
        );
        widget.manager.clearProfile();
      } else {}
    } catch (e) {
      _controller.setLoading(false);
    }
  }

  // _logout() async {
  //   _controller.setLoading(true);
  //   try {
  //     await FirebaseAuth.instance.signOut();
  //     _controller.setLoading(false);

  //     if (mounted) {
  //       pushNewScreen(
  //         context,
  //         screen: const LogoutLoader(),
  //         withNavBar: false, // OPTIONAL VALUE. True by default.
  //         pageTransitionAnimation: PageTransitionAnimation.cupertino,
  //       );
  //     }
  //     // Navigator.of(context).pushReplacement(
  //     //   PageTransition(
  //     //     type: PageTransitionType.size,
  //     //     alignment: Alignment.bottomCenter,
  //     //     child: const Welcome(),
  //     //   ),
  //     // );
  //   } on FirebaseAuthException catch (e) {
  //     Constants.toast("${e.message}");
  //     _controller.setLoading(false);
  //   }
  // }

  Future<void> _launchInBrowser(String url) async {
    if (await canLaunch(url)) {
      await launch(
        url,
        forceSafariVC: false,
        forceWebView: false,
        headers: <String, String>{'my_header_key': 'my_header_value'},
      );
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      padding: EdgeInsets.only(left: MediaQuery.of(context).size.width * 0.33),
      child: Container(
        color: Colors.white,
        height: double.infinity,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.only(
                      top: 32.0,
                      left: 24,
                      right: 24,
                      bottom: 1,
                    ),
                    width: double.infinity,
                    color: Colors.white,
                    height: MediaQuery.of(context).size.height * 0.164,
                    child: Center(
                        child: Image.asset("assets/images/app_logo.png")),
                  ),
                  Container(
                    color: Colors.white,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ListView.separated(
                          padding: const EdgeInsets.all(16.0),
                          shrinkWrap: true,
                          itemBuilder: (context, i) {
                            return ListTile(
                              dense: true,
                              title: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  drawerList[i].title == "About us"
                                      ? Icon(
                                          drawerList[i].icon,
                                          color: kPrimaryColor,
                                        )
                                      : SvgPicture.asset(
                                          drawerList[i].icon,
                                          width: 22,
                                          color: kPrimaryColor,
                                        ),
                                  const SizedBox(
                                    width: 21.0,
                                  ),
                                  TextSecondary(
                                    text: drawerList[i].title,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w400,
                                    color: const Color(0xFF272121),
                                  ),
                                ],
                              ),
                              onTap: () {
                                // if (i == 1) {
                                //   Navigator.of(context).pop();
                                //   _controller.jumpTo(3);
                                // } else {
                                if (drawerList[i].isAction) {
                                  Navigator.of(context).pop();
                                  _launchInBrowser("${drawerList[i].url}");
                                } else {
                                  Navigator.of(context).pop();
                                  pushNewScreen(
                                    context,
                                    screen: const About(),
                                    withNavBar:
                                        false, // OPTIONAL VALUE. True by default.
                                    pageTransitionAnimation:
                                        PageTransitionAnimation.cupertino,
                                  );
                                }
                                // }
                              },
                            );
                          },
                          separatorBuilder: (BuildContext context, int index) =>
                              const Divider(),
                          itemCount: drawerList.length,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(
              height: 16,
            ),
            Container(
              padding: const EdgeInsets.all(16.0),
              width: MediaQuery.of(context).size.width * 0.45,
              child: !_isLoggedIn
                  ? const SizedBox()
                  : Center(
                      child: TextButton.icon(
                        onPressed: () {
                          Navigator.of(context).pop();
                          _logOut();
                        },
                        label: TextPrimary(
                          text: "Log Out",
                          fontSize: 14,
                          align: TextAlign.center,
                          color: Colors.black,
                        ),
                        icon: const Icon(
                          CupertinoIcons.power,
                          color: Colors.red,
                        ),
                      ),
                    ),
            ),
            const SizedBox(
              height: 21,
            ),
          ],
        ),
      ),
    );
  }
}
