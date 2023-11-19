import 'package:deepay/components/text/text_widget.dart';
import 'package:deepay/constants.dart';
import 'package:flutter/material.dart';

class WalletLog extends StatelessWidget {
  var walletData;
  WalletLog({Key? key, required this.walletData}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              TextPrimary(text: "Amount", fontSize: 14),
              Text(
                "${nairaSign(context).currencySymbol}${formatMoneyFloat(double.parse("${walletData['amount']}"))}",
              )
            ],
          ),
        ),
        const Divider(),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              TextPrimary(text: "Balance Before", fontSize: 14),
              Text(
                "${nairaSign(context).currencySymbol}${formatMoneyFloat(double.parse("${walletData['balance_before']}"))}",
              )
            ],
          ),
        ),
        const Divider(),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              TextPrimary(text: "Balance After", fontSize: 14),
              Text(
                "${nairaSign(context).currencySymbol}${formatMoneyFloat(double.parse("${walletData['balance_after']}"))}",
              ),
            ],
          ),
        ),
      ],
    );
  }
}
