import 'package:custom_pop_up_menu/custom_pop_up_menu.dart';
// import 'package:persistent_bottom_nav_bar/persistent-tab-view.dart';
import 'package:deepay/model/others/services/services_item_model.dart';
import 'package:flutter/material.dart' hide ModalBottomSheetRoute;
import 'package:page_transition/page_transition.dart';

import '../../../constants.dart';
import '../../../helper/preferences/preference_manager.dart';
import '../../services/service_info.dart';
import 'airtime_swap.dart';

class ServiceCard extends StatelessWidget {
  final bool isAuthenticated;
  final ServiceItemModel model;
  final PreferenceManager manager;

  ServiceCard({
    Key? key,
    required this.model,
    required this.manager,
    required this.isAuthenticated,
  }) : super(key: key);

  final List<ServiceItemModel> _menuItems = [
    ServiceItemModel(
      name: "Airtime Swap",
      color: Colors.deepOrange,
      icon: Icons.swap_horizontal_circle_rounded,
    ),
    ServiceItemModel(
      name: "Education",
      color: Colors.deepPurple,
      icon: Icons.school_rounded,
    ),
  ];

  Widget _buildLongPressMenu() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(5),
      child: Container(
        width: 218,
        color: kPrimaryColor,
        child: GridView.count(
          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 10),
          crossAxisCount: 3,
          crossAxisSpacing: 4,
          mainAxisSpacing: 8,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          children: _menuItems
              .map(
                (item) => Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: getColorGradient(item.color),
                          ),
                          child: Icon(item.icon, color: Colors.white),
                        ),
                        Container(
                          margin: const EdgeInsets.only(top: 2),
                          child: Text(
                            item.name,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              )
              .toList(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1.1,
      shadowColor: kPrimaryLightColor,
      margin: EdgeInsets.only(
        bottom: 18.0,
        left: model.name == "Data" ? 0 : 4,
        right: model.name == "Others" ? 0 : 4,
      ),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(
          Radius.circular(12.0),
        ),
      ),
      child: model.name == "Others"
          ? CustomPopupMenu(
              child: Padding(
                padding: const EdgeInsets.all(6.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: getColorGradient(model.color),
                      ),
                      child: Icon(model.icon, color: Colors.white),
                    ),
                    const SizedBox(height: 4.0),
                    Text(model.name, style: const TextStyle(fontSize: 11)),
                  ],
                ),
              ),
              menuBuilder: () => GestureDetector(
                child: _buildLongPressMenu(),
                onLongPress: () {
                  debugPrint("onLongPress");
                },
                onTap: () {
                  debugPrint("onTap");
                },
              ),
              barrierColor: Colors.transparent,
              pressType: PressType.singleClick,
              arrowColor: kPrimaryColor,
              position: PreferredPosition.top,
            )
          : InkWell(
              onTap: model.name == "Airtime Swap"
                  ? () {
                      Future.delayed(const Duration(milliseconds: 50), () {
                        Navigator.push(
                          context,
                          PageTransition(
                            type: PageTransitionType.rightToLeft,
                            isIos: true,
                            child: AirtimeSwap(
                              service: model.name,
                              manager: manager,
                            ),
                          ),
                        );
                      });
                    }
                  : model.name == "Education"
                      ? () {
                          toast("Coming Soon!");
                        }
                      : () {
                          Future.delayed(const Duration(milliseconds: 50), () {
                            Navigator.push(
                              context,
                              PageTransition(
                                type: PageTransitionType.rightToLeft,
                                isIos: true,
                                child: ServiceInfo(
                                  service: model.name == "Cable TV"
                                      ? "Cable_TV"
                                      : model.name,
                                  isAuthenticated: isAuthenticated,
                                ),
                              ),
                            );
                            // pushNewScreen(
                            //   context,
                            //   screen: ServiceInfo(service: model.name),
                            //   withNavBar: false, // OPTIONAL VALUE. True by default.
                            //   pageTransitionAnimation: PageTransitionAnimation.cupertino,
                            // );
                          });
                        },
              child: Padding(
                padding: const EdgeInsets.all(6.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: getColorGradient(model.color),
                      ),
                      child: Icon(model.icon, color: Colors.white),
                    ),
                    const SizedBox(height: 4.0),
                    Text(
                      model.name,
                      style: const TextStyle(fontSize: 11),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
