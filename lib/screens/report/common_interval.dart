import 'dart:convert';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../data_models/order_model.dart';
import '../../database/order_dao.dart';
import '../../utils/utility.dart';
import '../../widgets/app_theme.dart';
import 'common_file_for_interval_report.dart';import '../MountedState.dart';
class CommonInterval extends StatefulWidget {
  final double takAway;
  final double eatIn;
  final double delivery;
  final double totalValue;
  const CommonInterval(this.takAway, this.eatIn, this.delivery, this.totalValue, {Key? key}) : super(key: key);

  @override
  State<CommonInterval> createState() => _CommonIntervalState();
}

class _CommonIntervalState extends MountedState<CommonInterval> {
  double totalValue = 0;
  int totalOrders = 0;
  Future<List<OrderModel>>? _orderList;
  late double takAway = 0;
  late double eatIn = 0;
  late double delivery = 0;
  late double collect = 0;
  late double point = 0;
  late double uber = 0;
  late double just = 0;
  late double deliveroo = 0;
  final _refreshIndicator = GlobalKey<RefreshIndicatorState>();
  late SharedPreferences sharedPreferences;
  List<OrderModel> fetchedData = [];
  void initState() {
    // TODO: implement initState
    super.initState();


  }
  @override
  Widget build(BuildContext context) {

    return SizedBox(
      height: MediaQuery.of(context).size.height*0.6,
      child: ListView(
        children: [
          Padding(
            // widget.isFilterActivated?MediaQuery.of(context).size.height*0.07
            padding:  EdgeInsets.fromLTRB(0, 0, 0, MediaQuery.of(context).size.height*0.07),
            child: Card(
              color: Colors.white,
              surfaceTintColor: Colors.transparent,
              shape: RoundedRectangleBorder(
                borderRadius:
                BorderRadius.circular(20),
              ),
              elevation: 15,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(0, 0, 0, 28),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(0, 15, 0, 10),
                      child: Center(
                        child: Text(
                          "saleChannels".tr(),
                          style: const TextStyle(
                              fontSize: 18,
                              color:
                              AppTheme.colorRed,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),

                    SizedBox(
                      height: MediaQuery.of(context).size.height*0.06,
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(15, 0, 13, 0),
                        child: Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.fromLTRB(0, 12, 0, 0),
                              child: Row(
                                children:  [
                                  Padding(
                                    padding: const EdgeInsets.fromLTRB(20, 0, 0, 2),
                                    child: Container(
                                        width: MediaQuery.of(context).size.width*0.66,
                                        child: Text("takeAway".tr())),
                                  ),
                                  Container(
                                    // margin: EdgeInsets.only(left: 220),
                                      child: Text(Utility().formatPrice(widget.takAway))),
                                ],
                              ),
                            ),
                            Stack(
                              children: [
                                Container(
                                  width:MediaQuery.of(context).size.width*0.90,
                                  height: 10,
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(4),
                                      color: AppTheme.colorLightGrey),
                                ),
                                AnimatedContainer(

                                    duration: const Duration(milliseconds: 400),
                                    width: widget.takAway!=0?MediaQuery.of(context).size.width*(0.90*widget.takAway/widget.totalValue):widget.takAway,
                                    height: 10,
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(6),
                                        color: Color(0xffdb1e24))),
                              ],
                            )
                          ],
                        ),
                      ),
                    ),
                    SizedBox(
                      height: MediaQuery.of(context).size.height*0.06,
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(15, 0, 13, 0),
                        child: Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.fromLTRB(0, 12, 0, 0),
                              child: Row(
                                children:  [
                                  Padding(
                                    padding: const EdgeInsets.fromLTRB(20, 0, 0, 2),
                                    child: Container(
                                        width: MediaQuery.of(context).size.width*0.66,
                                        child: Text("eatIn".tr())),
                                  ),
                                  Container(
                                    // margin: EdgeInsets.only(left: 220),
                                      child: Text(Utility().formatPrice(widget.eatIn))),
                                ],
                              ),
                            ),
                            Stack(
                              children: [
                                Container(
                                  width:MediaQuery.of(context).size.width*0.90,
                                  height: 10,
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(4),
                                      color: AppTheme.colorLightGrey),
                                ),
                                AnimatedContainer(

                                    duration: const Duration(milliseconds: 400),
                                    width: widget.eatIn!=0?MediaQuery.of(context).size.width*(0.90*widget.eatIn/widget.totalValue):widget.eatIn,
                                    height: 10,
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(6),
                                        color: Color(0xffdb1e24))),
                              ],
                            )
                          ],
                        ),
                      ),
                    ),
                    SizedBox(
                      height: MediaQuery.of(context).size.height*0.06,
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(15, 0, 13, 0),
                        child: Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.fromLTRB(0, 12, 0, 0),
                              child: Row(
                                children:  [
                                  Padding(
                                    padding: const EdgeInsets.fromLTRB(20, 0, 0, 2),
                                    child: Container(
                                        width: MediaQuery.of(context).size.width*0.66,
                                        child: Text("delivery".tr())),
                                  ),
                                  Container(
                                    // margin: EdgeInsets.only(left: 220),
                                      child: Text(Utility().formatPrice(widget.delivery))),
                                ],
                              ),
                            ),
                            Stack(
                              children: [
                                Container(
                                  width:MediaQuery.of(context).size.width*0.90,
                                  height: 10,
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(4),
                                      color: AppTheme.colorLightGrey),
                                ),
                                AnimatedContainer(

                                    duration: const Duration(milliseconds: 400),
                                    width: widget.delivery!=0?MediaQuery.of(context).size.width*(0.90*widget.delivery/widget.totalValue):widget.delivery,
                                    height: 10,
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(6),
                                        color: Color(0xffdb1e24))),
                              ],
                            )
                          ],
                        ),
                      ),
                    ),

                    CommonFileForIntervalReport(
                        totalPrice: collect,
                        color: const Color(0xff924dc1),
                        title: "clickCollect".tr(),
                        gross: totalValue),
                    CommonFileForIntervalReport(
                        totalPrice: point,
                        color: const Color(0xff306f9a),
                        title: "pointOfSale".tr(),
                        gross: totalValue),
                    CommonFileForIntervalReport(
                        totalPrice: uber,
                        color: const Color(0xff57bd70),
                        title: "uberEats".tr(),
                        gross: totalValue),
                    CommonFileForIntervalReport(
                        totalPrice: just,
                        color: const Color(0xffff6d00),
                        title: "justEat".tr(),
                        gross: totalValue),
                    CommonFileForIntervalReport(
                        totalPrice: deliveroo,
                        color: const Color(0xff00d2bb),
                        title: "deliveroo".tr(),
                        gross: totalValue),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );

  }
// Future<List<OrderModel>> getOrderList() async {
//
//   setState(() {
//     _orderList = OrderDao().getAllOrders();
//     _orderList.then((value) => {
//       for (int i = 0; i < value.length; i++)
//         {
//           totalValue += value[i].totalPrice,
//           if (value[i].orderService == "restaurant_order_type_takeaway")
//             {
//               takAway += value[i].totalPrice,
//             }
//           else if (value[i].orderService == "restaurant_order_type_eat_in")
//             {
//               eatIn += value[i].totalPrice}
//           else if (value[i].orderService == "delivery")
//               {delivery += value[i].totalPrice}
//             else if (value[i].orderService == "partners")
//                 {
//                   just += 1,
//                 },
//         },
//     });
//   });
//   return _orderList;
// }

}