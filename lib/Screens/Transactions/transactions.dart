import "package:collection/collection.dart";
import 'package:flutter/material.dart' hide ModalBottomSheetRoute;
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:page_transition/page_transition.dart';

import '../../components/background/background.dart';
import '../../components/drawer/custom_drawer.dart';
import '../../components/text/text_widget.dart';
import '../../constants.dart';
import '../../helper/database/database_handler.dart';
import '../../helper/preferences/preference_manager.dart';
import '../../helper/state/state_controller.dart';
import '../../model/transactions/guest_transaction_model.dart';
import '../Home/home.dart';
import 'components/transaction_row.dart';
import 'transaction_detail.dart';

class Transactions extends StatefulWidget {
  final PreferenceManager? manager;
  final List<GuestTransactionModel> guestModel;
  final List<dynamic> model;
  const Transactions({
    Key? key,
    this.manager,
    required this.guestModel,
    required this.model,
  }) : super(key: key);

  @override
  State<Transactions> createState() => _TransactionsState();
}

class _TransactionsState extends State<Transactions> {
  final _controller = Get.find<StateController>();
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  late List<GuestTransactionModel> _guestList = [];
  late final List<dynamic> _list = [];

  List<Widget> _mWidgets = [];

  _init() async {
    if (_controller.transactions.value.isEmpty) {
      //Revalidate for guest user
      final resp = await DatabaseHandler().transactions();
      // for (var v in resp) {
      //   _guestList.add(v);
      // }
      setState(() {
        _guestList = resp;
      });
    } else {
      //Revalidate for auth user
      var data = _controller.transactions.value;
      print("STATE DATA LIST ==>>> $data");
      for (var v in data) {
        _list.add(v);
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _init();
  }

  List<Widget> _buildList() {
    List<Widget> _widg = [];
    Map<String?, List<dynamic>> groupByDate = groupBy(
        _controller.transactions.value,
        (dynamic obj) => obj['created_at']?.substring(0, 10));

    groupByDate.forEach((date, list) {
      // print("$date");

      // Group
      var _wid = Column(
        children: [
          Container(
            color: kPrimaryLightColor,
            padding: const EdgeInsets.all(10.0),
            width: double.infinity,
            child: TextPrimary(
              text: DateFormat.yMMMEd('en_US').format(DateTime.parse("$date")),
              fontSize: 17,
              align: TextAlign.center,
              fontWeight: FontWeight.w600,
              color: kPrimaryColor,
            ),
          ),
          const SizedBox(height: 8.0),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemBuilder: (context, i) => TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  PageTransition(
                    type: PageTransitionType.rightToLeft,
                    isIos: true,
                    child: TransactionDetail(
                      model: list[i],
                      guestModel: null,
                      manager: widget.manager!,
                    ),
                  ),
                );
              },
              child: TransactionRow(
                model: list[i],
                guestModel: null,
              ),
              style: TextButton.styleFrom(
                foregroundColor: kSecondaryColor,
                padding: const EdgeInsets.symmetric(horizontal: 0.0),
              ),
            ),
            separatorBuilder: (context, i) => const Divider(),
            itemCount: list.length,
          ),
          const SizedBox(height: 16.0),
        ],
      );

      _widg.add(_wid);
    });

    return _widg;
  }

  List<Widget> _buildGuestList() {
    List<Widget> _widg = [];

    var _wid = ListView.separated(
      shrinkWrap: true,
      reverse: true,
      itemBuilder: (context, i) => TextButton(
        onPressed: () {
          Navigator.push(
            context,
            PageTransition(
              type: PageTransitionType.rightToLeft,
              isIos: true,
              child: TransactionDetail(
                model: null,
                guestModel: _guestList[i],
                manager: widget.manager!,
              ),
            ),
          );
        },
        child: TransactionRow(
          model: null,
          guestModel: _guestList[i],
        ),
        style: TextButton.styleFrom(
          foregroundColor: kSecondaryColor,
          padding: const EdgeInsets.symmetric(horizontal: 0.0),
        ),
      ),
      separatorBuilder: (context, i) => const Divider(),
      itemCount: _guestList.length,
    );

    _widg.add(_wid);

    return _widg;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    Future.delayed(const Duration(seconds: 1), () {
      (_list.isEmpty)
          ? setState(() => _mWidgets = _buildGuestList())
          : setState(() => _mWidgets = _buildList());
    });
  }

  @override
  Widget build(BuildContext context) {
    debugPrint("TRANSACTION LIST ==>>> $_list");

    return Scaffold(
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
                _controller.selectTab(
                  Home(
                    manager: widget.manager,
                  ),
                  _controller.pageKeys[0],
                  0,
                );
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
          text: "Transactions",
          fontSize: 24,
          fontWeight: FontWeight.w700,
          color: kPrimaryColor,
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
          manager: widget.manager!,
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Background(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: ((_list.isEmpty) && (_guestList.isEmpty))
                      ? Center(
                          child: Image.asset(
                            "assets/images/no_record.png",
                            width: 256,
                          ),
                        )
                      : ListView(
                          shrinkWrap: true,
                          children: _mWidgets,
                          controller: _controller.transactionsScrollController,
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
