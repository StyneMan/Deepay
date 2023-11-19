import 'package:flutter/material.dart' hide ModalBottomSheetRoute;

import '../../constants.dart';
import '../text/text_widget.dart';

class CardDetailTrans extends StatelessWidget {
  var value;
  final String title;
  final IconData icon;
  CardDetailTrans({
    Key? key,
    required this.title,
    required this.value,
    required this.icon,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1.0,
      child: Container(
        padding: const EdgeInsets.all(10),
        width: double.infinity,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            ClipOval(
              child: Container(
                color: kPrimaryLightColor,
                padding: const EdgeInsets.all(8.0),
                child: Center(
                  child: Icon(
                    icon,
                    color: kPrimaryColor,
                    size: 32.0,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10.0),
            Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextPrimary(
                  text: title,
                  fontWeight: FontWeight.w600,
                  fontSize: 18,
                  color: kPrimaryColor,
                ),
                Text(
                  "$value",
                  style: const TextStyle(fontSize: 14),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
