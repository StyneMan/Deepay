import 'package:flutter/material.dart' hide ModalBottomSheetRoute;
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

import '../../components/drawer/custom_drawer.dart';
import '../../components/text/text_widget.dart';
import '../../constants.dart';
import '../../helper/preferences/preference_manager.dart';
import '../../helper/state/state_controller.dart';
import '../Welcome/components/background.dart';
import 'components/abt.dart';
import 'components/card.dart';
import 'components/mbt.dart';

class FundWallet extends StatefulWidget {
  final PreferenceManager manager;
  const FundWallet({
    Key? key,
    required this.manager,
  }) : super(key: key);

  @override
  State<FundWallet> createState() => _FundWalletState();
}

class _FundWalletState extends State<FundWallet> with TickerProviderStateMixin {
  final _controller = Get.find<StateController>();
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  AnimationController? _animationController;

  int _currentPage = 0;
  final PageController? _pageController = PageController(initialPage: 0);

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 450),
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

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          elevation: 0.2,
          backgroundColor: Colors.white,
          automaticallyImplyLeading: false,
          leading: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(width: 10),
              InkWell(
                onTap: () {
                  Navigator.pop(context);
                },
                child: const Icon(
                  Icons.arrow_back_rounded,
                  color: kPrimaryColor,
                  size: 24,
                ),
              ),
            ],
          ),
          title: TextSecondary(
            text: "Fund Wallet",
            fontSize: 21,
            fontWeight: FontWeight.w700,
            color: kPrimaryColor,
          ),
          bottom: TabBar(
            unselectedLabelColor: kPrimaryLightColor,
            padding: const EdgeInsets.symmetric(horizontal: 10.0),
            indicator: BoxDecoration(
              borderRadius: BorderRadius.circular(50), // Creates border
              color: kPrimaryColor,
            ), //Change background color from here
            tabs: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextPrimary(
                  text: "Card",
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextPrimary(
                  text: "ABT",
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextPrimary(
                  text: "Transfer",
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          centerTitle: true,
          actions: [
            IconButton(
              onPressed: () {
                if (!_scaffoldKey.currentState!.isEndDrawerOpen) {
                  _scaffoldKey.currentState!.openEndDrawer();
                }
              },
              icon: SvgPicture.asset(
                'assets/images/menu_icon.svg',
                color: kPrimaryColor,
              ),
            ),
          ],
        ),
        endDrawer: SizedBox(
          height: MediaQuery.of(context).size.height,
          child: CustomDrawer(
            manager: widget.manager,
          ),
        ),
        body: SafeArea(
          child: Background(
            child: TabBarView(
              children: [
                CardWallet(
                  manager: widget.manager,
                ),
                ABT(
                  manager: widget.manager,
                ),
                MBT(
                  manager: widget.manager,
                )
                // SizedBox(
                //   height: MediaQuery.of(context).size.height * 0.70,
                //   child: ListView(
                //     padding: const EdgeInsets.all(16.0),
                //     children: [
                //       SizedBox(
                //         height: MediaQuery.of(context).size.height * 0.70,
                //         child: PageView(
                //           scrollDirection: Axis.horizontal,
                //           onPageChanged: _onPageChanged,
                //           controller: _pageController,
                //           children: [

                //           ],
                //         ),
                //       ),
                //     ],
                //   ),
                // ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
