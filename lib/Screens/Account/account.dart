import 'package:flutter/material.dart' hide ModalBottomSheetRoute;
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

import '../../components/background/background.dart';
import '../../components/text/text_widget.dart';
import '../../constants.dart';
import '../../helper/preferences/preference_manager.dart';
import '../../helper/service/api_service.dart';
import '../../helper/state/state_controller.dart';
import '../Home/home.dart';
import '../Welcome/welcome_screen.dart';
import 'components/kyc.dart';
import 'components/password.dart';
import 'components/profile.dart';

class Account extends StatefulWidget {
  final PreferenceManager manager;
  const Account({
    Key? key,
    required this.manager,
  }) : super(key: key);

  @override
  State<Account> createState() => _AccountState();
}

class _AccountState extends State<Account> with TickerProviderStateMixin {
  final _controller = Get.find<StateController>();
  AnimationController? _animationController;

  int _currentPage = 0;
  final PageController? _pageController = PageController(initialPage: 0);

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
  }

  @override
  void dispose() {
    super.dispose();
    _pageController!.dispose();
    _animationController!.dispose();
  }

  _onPageChanged(int index) {
    setState(() {
      _currentPage = index;
    });
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Background(
          child: Column(
            children: [
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12.0, vertical: 2.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    FloatingActionButton(
                      onPressed: () {
                        _controller.selectTab(
                          Home(manager: widget.manager),
                          _controller.pageKeys[0],
                          0,
                        );
                      },
                      mini: true,
                      elevation: 2,
                      backgroundColor: Colors.white,
                      child: const Icon(Icons.arrow_back, color: kPrimaryColor),
                    ),
                    widget.manager.getUser() == null
                        ? const SizedBox()
                        : FloatingActionButton(
                            onPressed: () {
                              _logOut();
                            },
                            mini: true,
                            elevation: 2,
                            backgroundColor: Colors.white,
                            child: const Icon(
                              Icons.logout_rounded,
                              color: kPrimaryColor,
                            ),
                          ),
                  ],
                ),
              ),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16.0, vertical: 2.0),
                  children: [
                    const SizedBox(height: 2.0),
                    Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              ClipOval(
                                child: Container(
                                  color: kPrimaryLightColor,
                                  padding: const EdgeInsets.all(24.0),
                                  child: SvgPicture.asset(
                                    "assets/images/user_avtr.svg",
                                    width: 56,
                                    height: 56,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 8.0),
                              TextPrimary(
                                text: widget.manager.getIsLoggedIn()
                                    ? widget.manager.getUser()['name']
                                    : "Guest User",
                                fontSize: 20,
                                color: kPrimaryColor,
                                fontWeight: FontWeight.w600,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        children: [
                          Expanded(
                            child: ClipRRect(
                              borderRadius:
                                  const BorderRadius.all(Radius.circular(4)),
                              child: TextButton(
                                onPressed: () {
                                  setState(() {
                                    _currentPage = 0;
                                  });
                                  _pageController!.animateToPage(
                                    _currentPage,
                                    duration: const Duration(milliseconds: 300),
                                    curve: Curves.easeIn,
                                  );
                                },
                                child: const Text(
                                  'Profile',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(fontSize: 16),
                                ),
                                style: TextButton.styleFrom(
                                  foregroundColor: _currentPage == 0
                                      ? kPrimaryColor
                                      : const Color(0xFF686868),
                                  backgroundColor: _currentPage == 0
                                      ? Colors.white
                                      : const Color(0xFFD0D0D0),
                                  disabledForegroundColor: _currentPage == 0
                                      ? kPrimaryColor
                                      : const Color(0xFF686868)
                                          .withOpacity(0.38),
                                  padding: const EdgeInsets.all(14.0),
                                  elevation: 0.0,
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            child: ClipRRect(
                              borderRadius:
                                  const BorderRadius.all(Radius.circular(4)),
                              child: TextButton(
                                onPressed: () {
                                  setState(() {
                                    _currentPage = 1;
                                  });
                                  _pageController!.animateToPage(
                                    _currentPage,
                                    duration: const Duration(milliseconds: 300),
                                    curve: Curves.easeIn,
                                  );
                                },
                                child: const Text(
                                  'KYC',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(fontSize: 16),
                                ),
                                style: TextButton.styleFrom(
                                  foregroundColor: _currentPage == 1
                                      ? kPrimaryColor
                                      : const Color(0xFF686868),
                                  backgroundColor: _currentPage == 1
                                      ? Colors.white
                                      : const Color(0xFFD0D0D0),
                                  disabledForegroundColor: _currentPage == 1
                                      ? kPrimaryColor
                                      : const Color(0xFF686868)
                                          .withOpacity(0.38),
                                  padding: const EdgeInsets.all(14.0),
                                  elevation: 0.0,
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            child: ClipRRect(
                              borderRadius:
                                  const BorderRadius.all(Radius.circular(4)),
                              child: TextButton(
                                onPressed: () {
                                  setState(() {
                                    _currentPage = 2;
                                  });
                                  _pageController!.animateToPage(
                                    _currentPage,
                                    duration: const Duration(milliseconds: 300),
                                    curve: Curves.easeIn,
                                  );
                                },
                                child: const Text(
                                  'Security',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(fontSize: 16),
                                ),
                                style: TextButton.styleFrom(
                                  foregroundColor: _currentPage == 2
                                      ? kPrimaryColor
                                      : const Color(0xFF686868),
                                  backgroundColor: _currentPage == 2
                                      ? Colors.white
                                      : const Color(0xFFD0D0D0),
                                  disabledForegroundColor: _currentPage == 2
                                      ? kPrimaryColor
                                      : const Color(0xFF686868)
                                          .withOpacity(0.38),
                                  padding: const EdgeInsets.all(14.0),
                                  elevation: 0.0,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.70,
                      child: PageView(
                        scrollDirection: Axis.horizontal,
                        onPageChanged: _onPageChanged,
                        controller: _pageController,
                        children: [
                          Profile(
                            manager: widget.manager,
                          ),
                          KYC(
                            manager: widget.manager,
                          ),
                          Password(
                            manager: widget.manager,
                          )
                        ],
                      ),
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
