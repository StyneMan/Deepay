import 'dart:ui';

import 'package:flutter/material.dart' hide ModalBottomSheetRoute;

import '../../constants.dart';
import '../../helper/preferences/preference_manager.dart';

class GlassCard extends StatefulWidget {
  final PreferenceManager manager;
  const GlassCard({
    Key? key,
    required this.manager,
  }) : super(key: key);

  @override
  _GlassCardState createState() => _GlassCardState();
}

class _GlassCardState extends State<GlassCard> {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        image: const DecorationImage(
          image: NetworkImage(
              'https://www.shutterstock.com/shutterstock/videos/8934685/thumb/1.jpg?ip=x480'),
          fit: BoxFit.cover,
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Center(
        child: Container(
          decoration: BoxDecoration(boxShadow: [
            BoxShadow(
              blurRadius: 16,
              spreadRadius: 16,
              color: Colors.black.withOpacity(0.1),
            )
          ]),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16.0),
            child: BackdropFilter(
              filter: ImageFilter.blur(
                sigmaX: 20.0,
                sigmaY: 20.0,
              ),
              child: Container(
                  width: 360,
                  height: 200,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(16.0),
                    border: Border.all(
                      width: 1.5,
                      color: Colors.white.withOpacity(0.2),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Image.asset("assets/images/app_logo.png"),
                            Image.asset(
                              "assets/images/card_chip.png",
                              width: 56,
                              height: 56,
                            ),
                          ],
                        ),
                        const Spacer(),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '${widget.manager.getUser()['name']}',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.75),
                              ),
                            ),
                            Text(
                              "${nairaSign(context).currencySymbol}${widget.manager.getUser()['wallet_balance']}",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: Colors.white.withOpacity(0.75),
                              ),
                            ),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '${widget.manager.getUser()['email']}',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.75),
                              ),
                            ),
                          ],
                        )
                      ],
                    ),
                  )),
            ),
          ),
        ),
      ),
    );
  }
}
