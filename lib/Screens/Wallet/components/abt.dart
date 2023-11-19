import 'package:flutter/material.dart' hide ModalBottomSheetRoute;

import '../../../components/rounded_button.dart';
import '../../../components/text/text_widget.dart';
import '../../../constants.dart';
import '../../../helper/preferences/preference_manager.dart';

class ABT extends StatelessWidget {
  final PreferenceManager manager;
  const ABT({
    Key? key,
    required this.manager,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView(
      shrinkWrap: true,
      padding: const EdgeInsets.all(16.0),
      children: [
        TextSecondary(
          text: "Fund your wallet using Automated Bank Transfer",
          fontSize: 18,
          align: TextAlign.center,
          fontWeight: FontWeight.w600,
        ),
        const SizedBox(
          height: 32.0,
        ),
        manager.getUser() != null
            ? manager.getUser()['has_virtual_account'] ||
                    manager.getUser()['accounts']?.isNotEmpty
                ? ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemBuilder: (context, i) => Container(
                      padding: const EdgeInsets.all(4.0),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              TextSecondary(
                                text: "Bank Name",
                                fontSize: 16,
                                color: kPrimaryColor,
                              ),
                              TextSecondary(
                                text:
                                    "${manager.getUser()['accounts'][i]['bank_name']}",
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ],
                          ),
                          const SizedBox(
                            height: 2.0,
                          ),
                          const Divider(),
                          const SizedBox(
                            height: 2.0,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              TextSecondary(
                                text: "Bank Code",
                                fontSize: 16,
                                color: kPrimaryColor,
                              ),
                              TextSecondary(
                                text:
                                    "${manager.getUser()['accounts'][i]['bank_code']}",
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ],
                          ),
                          const SizedBox(
                            height: 2.0,
                          ),
                          const Divider(),
                          const SizedBox(
                            height: 2.0,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              TextSecondary(
                                text: "Account Name",
                                fontSize: 16,
                                color: kPrimaryColor,
                              ),
                              TextSecondary(
                                text:
                                    "${manager.getUser()['accounts'][i]['account_name']}",
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ],
                          ),
                          const SizedBox(
                            height: 2.0,
                          ),
                          const Divider(),
                          const SizedBox(
                            height: 2.0,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              TextSecondary(
                                text: "Account Number",
                                fontSize: 16,
                                color: kPrimaryColor,
                              ),
                              TextSecondary(
                                text:
                                    "${manager.getUser()['accounts'][i]['account_number']}",
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ],
                          ),
                          const SizedBox(
                            height: 2.0,
                          ),
                          const Divider(),
                          const SizedBox(
                            height: 2.0,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              TextSecondary(
                                text: "Status",
                                fontSize: 16,
                                color: kPrimaryColor,
                              ),
                              TextSecondary(
                                text:
                                    "${manager.getUser()['accounts'][i]['status']}",
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ],
                          ),
                          const SizedBox(
                            height: 2.0,
                          ),
                          const Divider(),
                          const SizedBox(
                            height: 2.0,
                          ),
                        ],
                      ),
                    ),
                    separatorBuilder: (context, i) => const SizedBox(
                      height: 24.0,
                    ),
                    itemCount: manager.getUser()['accounts']?.length,
                  )
                : Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      manager.getUser()['kyc_completed_at'] == null
                          ? Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                TextSecondary(
                                  text:
                                      "Kindly complete your KYC before proceeding with Automated Bank Transfer",
                                  fontSize: 16,
                                  align: TextAlign.center,
                                  fontWeight: FontWeight.w500,
                                ),
                                const SizedBox(height: 16),
                                RoundedButton(
                                  text: "Generate Virtual Account",
                                  press: () {
                                    toast("Complete your KYC first!");
                                  },
                                ),
                              ],
                            )
                          : Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                TextSecondary(
                                  text:
                                      "Generate your virtual account to proceed with Automated Bank Transfer",
                                  fontSize: 18,
                                  fontWeight: FontWeight.w500,
                                ),
                                const SizedBox(height: 16),
                                RoundedButton(
                                  text: "Generate Virtual Account",
                                  press: () {},
                                ),
                              ],
                            ),
                    ],
                  )
            : const SizedBox(),
        const SizedBox(
          height: 128,
        ),
      ],
    );
  }
}
