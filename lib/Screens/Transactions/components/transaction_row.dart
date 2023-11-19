import 'package:flutter/material.dart' hide ModalBottomSheetRoute;

import '../../../components/text/text_widget.dart';
import '../../../constants.dart';
import '../../../model/transactions/guest_transaction_model.dart';

class TransactionRow extends StatefulWidget {
  final GuestTransactionModel? guestModel;
  var model;
  TransactionRow({
    Key? key,
    this.guestModel,
    this.model,
  }) : super(key: key);

  @override
  State<TransactionRow> createState() => _TransactionRowState();
}

class _TransactionRowState extends State<TransactionRow> {
  late Color _color = Colors.black;
  late IconData _icon;

  init() {
    if (widget.model != null) {
      if (widget.model['type'] == "data") {
        setState(() {
          _color = Colors.blueGrey;
          _icon = Icons.wifi;
        });
      } else if (widget.model['type'] == "electricity") {
        setState(() {
          _color = Colors.deepOrange;
          _icon = Icons.lightbulb_outline;
        });
      } else if (widget.model['type'] == "airtime") {
        setState(() {
          _color = Colors.yellow;
          _icon = Icons.sim_card;
        });
      } else if (widget.model['type'] == "cable_tv") {
        setState(() {
          _color = Colors.green;
          _icon = Icons.tv;
        });
      } else {
        setState(() {
          _color = Colors.indigo;
          _icon = Icons.wallet;
        });
      }
    } else {
      if (widget.guestModel?.type == "data") {
        setState(() {
          _color = Colors.blueGrey;
          _icon = Icons.wifi;
        });
      } else if (widget.guestModel?.type == "electricity") {
        setState(() {
          _color = Colors.deepOrange;
          _icon = Icons.lightbulb_outline;
        });
      } else if (widget.guestModel?.type == "airtime") {
        setState(() {
          _color = Colors.yellow;
          _icon = Icons.sim_card;
        });
      } else if (widget.guestModel?.type == "cable_tv") {
        setState(() {
          _color = Colors.green;
          _icon = Icons.tv;
        });
      } else {
        setState(() {
          _color = Colors.indigo;
          _icon = Icons.wallet;
        });
      }
    }
  }

  @override
  void initState() {
    init();
    super.initState();
  }

  Widget _statusWidget(String? status) {
    return ClipOval(
      child: Container(
        padding: const EdgeInsets.all(1.0),
        color: status == "success"
            ? const Color(0x684CAF4F)
            : (status == "cancelled" || status == "failed")
                ? const Color(0x928C1414)
                : const Color(0x97C06C18),
        child: Center(
          child: Icon(
            status == "success"
                ? Icons.check_circle_rounded
                : (status == "cancelled" || status == "failed")
                    ? Icons.cancel_rounded
                    : Icons.pending_sharp,
            color: status == "success"
                ? Colors.green
                : (status == "cancelled" || status == "failed")
                    ? Colors.red
                    : Colors.amber,
            size: 20,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(0.0),
      width: double.infinity,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: getColorGradient(_color),
                ),
                child: Icon(_icon, color: Colors.white),
              ),
              const SizedBox(width: 8.0),
              SizedBox(
                width: MediaQuery.of(context).size.width * 0.56,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextSecondary(
                      text: widget.model['transaction_ref'] ??
                          widget.guestModel?.transactionRef,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: kPrimaryColor,
                    ),
                    const SizedBox(height: 1.0),
                    Wrap(
                      children: [
                        Text(
                          "${widget.model['description'] ?? widget.guestModel?.description}",
                          softWrap: true,
                          style: const TextStyle(
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                    // TextSecondary(
                    //   text: widget.model?.description ??
                    //       widget.guestModel?.description,
                    //   fontSize: 11,
                    // ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(
            width: 6.0,
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                "${nairaSign(context).currencySymbol}${widget.model['amount'] ?? widget.guestModel?.amount}",
                style: const TextStyle(
                  color: Colors.black38,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 1.0),
              _statusWidget(
                widget.model['status'] ?? widget.guestModel?.status,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
