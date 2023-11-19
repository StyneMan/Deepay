import 'package:flutter/material.dart' hide ModalBottomSheetRoute;
import 'package:get/get.dart';
import 'package:page_transition/page_transition.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../constants.dart';
import '../../../helper/database/database_handler.dart';
import '../../../helper/preferences/preference_manager.dart';
import '../../../helper/state/state_controller.dart';
import '../../Transactions/components/transaction_row.dart';
import '../../Transactions/transaction_detail.dart';

class RecentTransactions extends StatefulWidget {
  final bool isAuthenticated;
  final PreferenceManager manager;
  const RecentTransactions({
    Key? key,
    required this.isAuthenticated,
    required this.manager,
  }) : super(key: key);

  @override
  State<RecentTransactions> createState() => _RecentTransactionsState();
}

class _RecentTransactionsState extends State<RecentTransactions> {
  bool _loggedIn = true;
  final _controller = Get.find<StateController>();
  List<dynamic> _transactionList = [];

  _parseState() async {
    final prefs = await SharedPreferences.getInstance();
    bool _isLoggedIn = prefs.getBool("loggedIn") ?? false;
    setState(() => _loggedIn = _isLoggedIn);
    // print("AUTHED:: $_isLoggedIn");
    if (!_isLoggedIn) {
      final resp = await DatabaseHandler().transactions();
      setState(() {
        _transactionList = resp;
      });

      // var data = _controller.transactions.value;

      // // print("MJKD::: ${data}");
      // for (var v in data) {
      //   _transactionList.add(UserTransaction.fromJson(v));
      // }
    }
  }

  @override
  void initState() {
    _parseState();
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    Future.delayed(const Duration(seconds: 2), () {
      if (_transactionList.isEmpty) {
        // _parseState();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return _controller.recentTransactions.value.isEmpty &&
            _transactionList.isEmpty
        ? SizedBox(
            width: double.infinity,
            height: 200,
            child: Center(
              child: Image.asset(
                "assets/images/no_record.png",
                width: 256,
              ),
            ),
          )
        : Obx(
            () => Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (var i = 0;
                    i < _controller.recentTransactions.value.length;
                    i++)
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        PageTransition(
                          type: PageTransitionType.rightToLeft,
                          isIos: true,
                          child: TransactionDetail(
                            model: _loggedIn
                                ? _controller.recentTransactions.value[i]
                                : null,
                            guestModel: _loggedIn ? null : _transactionList[i],
                            manager: widget.manager,
                          ),
                        ),
                      );
                    },
                    child: TransactionRow(
                      model: _loggedIn
                          ? _controller.recentTransactions.value[i]
                          : null,
                      guestModel: _loggedIn ? null : _transactionList[i],
                    ),
                    style: TextButton.styleFrom(
                      foregroundColor: kSecondaryColor,
                      padding: const EdgeInsets.symmetric(horizontal: 0.0),
                    ),
                  ),
              ],
            ),
          );
  }
}
