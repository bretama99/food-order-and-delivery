import 'dart:ffi';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:opti_food_app/screens/report/common_for_category_user.dart';
import '../../utils/utility.dart';
import '../../data_models/order_model.dart';
import '../../widgets/app_theme.dart';import '../MountedState.dart';
class UserOrdersReport extends StatefulWidget {
  // final bool isFilterActivated;
  // final Future<List<OrderModel>> orderList;
  const UserOrdersReport({Key? key}) : super(key: key);

  @override
  State<UserOrdersReport> createState() => _UserOrdersReportState();
}

class _UserOrdersReportState extends MountedState<UserOrdersReport> {

  int totalSales = 6000;
  late List<OrderData> _chartData = [];
  late List<OrderData> _chartDataDeliveryBoy = [];

  late List<charts.Series<OrderData, String>> series = [];
  late List<charts.Series<OrderData, String>> seriesForDeliveryBoy = [];

  double totalValue = 0;
  int totalOrders = 0;
  int totalProducts = 0;
  int totalContacts = 0;

  late Future<List<OrderModel>> _orderList=[] as Future<List<OrderModel>>;

  @override
  void initState() {
    super.initState();
    getChartData();
  }

  @override
  Widget build(BuildContext context) {
    final isLandscape = MediaQuery.of(context).orientation == Orientation.landscape;
    return Scaffold(
      // appBar: AppBarOptifood(),
      body: SafeArea(
        child: ListView(
          children: [
            SizedBox(
              height: MediaQuery.of(context).size.height*0.56,
              child: Card(
                color: Colors.white,
                surfaceTintColor: Colors.transparent,
                shape: RoundedRectangleBorder(
                  borderRadius:
                  BorderRadius.circular(20),
                ),
                elevation: 15,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(0, 0, 0, 15),
                  child: Column(
                    children: [
                      Transform.translate(
                          offset:Offset(0,MediaQuery.of(context).size.height*0.015),
                          child: Center(
                            child: Text(
                              "saleUsers".tr(),
                              style: const TextStyle(
                                  fontSize: 18,
                                  color:
                                  AppTheme.colorRed,
                                  fontWeight: FontWeight.bold),
                            ),
                          )),
                      Expanded(
                        child: Stack(
                          children: [

                            SizedBox(
                                height: MediaQuery.of(context).size.height*0.4,
                                // child: CommonCategoryUser(title:"saleUsers", series:series)
                            ),
                            Column(
                              children: [
                                Row(
                                  children: [
                                    Padding(
                                      padding:  EdgeInsets
                                          .fromLTRB(
                                          18, MediaQuery.of(context).size.height*0.41,0, 0),
                                      child: SizedBox(
                                          width: MediaQuery.of(
                                              context)
                                              .size
                                              .width *
                                              0.40,
                                          child: Column(
                                            children: [
                                              for (var i = 0; i < _chartData.length/2;
                                              i++) Row(
                                                children: [
                                                  Padding(
                                                    padding: const EdgeInsets.fromLTRB(0, 0, 1, 0),
                                                    child: Container(
                                                      margin: const EdgeInsets.only(right: 3.0),

                                                      height: isLandscape?MediaQuery.of(context).size.height * 0.02:MediaQuery.of(context).size.height * 0.01,
                                                      width: 8,
                                                      decoration: BoxDecoration(
                                                        borderRadius: BorderRadius.circular(4),
                                                        color: _chartData[i].color,
                                                      ),
                                                    ),
                                                  ),
                                                  SizedBox(
                                                    width: isLandscape?MediaQuery.of(context).size.width * 0.21:MediaQuery.of(context).size.width * 0.245,

                                                    // width: MediaQuery.of(context).size.width * 0.12,
                                                    child: Text(
                                                      '${_chartData[i].user} ',
                                                      style: const TextStyle(fontSize: 12),
                                                    ),
                                                  ),
                                                  Padding(
                                                    padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
                                                    child:Text(
                                                      Utility().formatPrice(_chartData[i].percentage),
                                                      style: const TextStyle(fontSize: 12),
                                                    ),
                                                  ),
                                                ],
                                              )
                                            ],
                                          )
                                      ),
                                    ),
                                    Padding(
                                      padding:  EdgeInsets
                                          .fromLTRB(
                                          10, MediaQuery.of(context).size.height*0.41, 10, 0),
                                      child: SizedBox(
                                        height: MediaQuery.of(context).size.height*(0.017)*(_chartData.length/2).round(),
                                        child: const VerticalDivider(
                                          thickness: 1,
                                          width: 10,
                                          color: AppTheme
                                              .colorLightGrey,
                                        ),
                                      ),
                                    ),
                                    Padding(
                                      padding: EdgeInsets
                                          .fromLTRB(
                                          5, MediaQuery.of(context).size.height*0.41, 0, 0),
                                      child: SizedBox(
                                          width: MediaQuery.of(
                                              context)
                                              .size
                                              .width *
                                              0.40,
                                          child: Column(
                                            children: [
                                              for (var i = (_chartData
                                                  .length/2).round();
                                              i <
                                                  _chartData
                                                      .length;
                                              i++)
                                                Row(
                                                  children: [
                                                    Padding(
                                                      padding: const EdgeInsets.fromLTRB(0, 0, 1, 0),
                                                      child: Container(
                                                        margin: isLandscape? const EdgeInsets.only(left: 92.0,right: 3.0):const EdgeInsets.only(right: 3.0),

                                                        height: isLandscape?MediaQuery.of(context).size.height * 0.02:MediaQuery.of(context).size.height * 0.01,
                                                        width: 8,
                                                        decoration: BoxDecoration(
                                                          borderRadius: BorderRadius.circular(4),
                                                          color: _chartData[i].color,
                                                        ),
                                                      ),
                                                    ),
                                                    SizedBox(
                                                      width: isLandscape?MediaQuery.of(context).size.width * 0.22:MediaQuery.of(context).size.width * 0.22,

                                                      child: Text(
                                                        '${_chartData[i].user} ',
                                                        style: const TextStyle(fontSize: 12),
                                                      ),
                                                    ),
                                                    Padding(
                                                      padding: const EdgeInsets.fromLTRB(2, 0, 0, 0),
                                                      child: Text(
                                                        Utility().formatPrice(_chartData[i].percentage),
                                                        style: const TextStyle(fontSize: 12),
                                                      ),
                                                    ),
                                                  ],
                                                )
                                            ],
                                          )
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),

                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),


            Padding(
              padding: const EdgeInsets.fromLTRB(0, 0, 0, 30),
              child: SizedBox(
                height: MediaQuery.of(context).size.height*0.53,
                child: Card(
                  color: Colors.white,
                  surfaceTintColor: Colors.transparent,
                  shape: RoundedRectangleBorder(
                    borderRadius:
                    BorderRadius.circular(20),
                  ),
                  elevation: 15,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(0, 0, 0, 15),
                    child: Column(
                      children: [
                        Transform.translate(
                            offset:Offset(0,MediaQuery.of(context).size.height*0.015),
                            child: Center(
                              child: Text(
                                "deliveriesDeliveryMan".tr(),
                                style: const TextStyle(
                                    fontSize: 18,
                                    color:
                                    AppTheme.colorRed,
                                    fontWeight: FontWeight.bold),
                              ),
                            )),
                        Expanded(
                          child: Stack(
                            children: [
                              SizedBox(
                              height:MediaQuery.of(context).size.height*0.4,
                                  // child: CommonCategoryUser(title:"deliveriesDeliveryMan", series:seriesForDeliveryBoy)
                              ),
                              Column(
                                children: [
                                  Row(
                                    children: [
                                      Padding(
                                        padding: EdgeInsets
                                            .fromLTRB(
                                            18, MediaQuery.of(context).size.height*0.41, 0, 0),
                                        child: SizedBox(
                                            width: MediaQuery.of(
                                                context)
                                                .size
                                                .width *
                                                0.40,
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.end,

                                              children: [
                                                for (var i = 0; i < _chartDataDeliveryBoy.length/2;
                                                i++) Row(
                                                  children: [
                                                    Padding(
                                                      padding: const EdgeInsets.fromLTRB(0, 0, 1, 0),
                                                      child: Container(
                                                        margin: const EdgeInsets.only(right: 3.0),

                                                        height: isLandscape?MediaQuery.of(context).size.height * 0.02:MediaQuery.of(context).size.height * 0.01,
                                                        width: 8,
                                                        decoration: BoxDecoration(
                                                          borderRadius: BorderRadius.circular(4),
                                                          color: _chartDataDeliveryBoy[i].color,
                                                        ),
                                                      ),
                                                    ),
                                                    SizedBox(
                                                      width: MediaQuery.of(context).size.width * 0.31,

                                                      // width: MediaQuery.of(context).size.width * 0.12,
                                                      child: Text(
                                                        '${_chartDataDeliveryBoy[i].user} ',
                                                        style: const TextStyle(fontSize: 12),
                                                      ),
                                                    ),
                                                    Padding(
                                                      padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
                                                      child:Text(
                                                        _chartDataDeliveryBoy[i].percentage.toStringAsFixed(0),
                                                        style: const TextStyle(fontSize: 12),
                                                      ),
                                                    ),
                                                  ],
                                                )
                                              ],
                                            )
                                        ),
                                      ),
                                      Padding(
                                        padding:  EdgeInsets
                                            .fromLTRB(
                                            6, MediaQuery.of(context).size.height*0.41, 10, 0),
                                        child: SizedBox(
                                          height: MediaQuery.of(context).size.height*(0.017)*(_chartDataDeliveryBoy.length/2).round(),
                                          child: const VerticalDivider(
                                            thickness: 1,
                                            width: 10,
                                            color: AppTheme
                                                .colorLightGrey,
                                          ),
                                        ),
                                      ),
                                      Padding(
                                        padding:
                                         EdgeInsets
                                            .fromLTRB(
                                            5, MediaQuery.of(context).size.height*0.41, 0, 0),
                                        child: SizedBox(
                                            width: MediaQuery.of(
                                                context)
                                                .size
                                                .width *
                                                0.40,
                                            child: Column(
                                              children: [
                                                for (var i = (_chartDataDeliveryBoy
                                                    .length/2).round();
                                                i <
                                                    _chartDataDeliveryBoy
                                                        .length;
                                                i++)
                                                  Row(
                                                    children: [
                                                      Padding(
                                                        padding: const EdgeInsets.fromLTRB(0, 0, 1, 0),
                                                        child: Container(
                                                          margin: const EdgeInsets.only(right: 3.0),

                                                          height: isLandscape?MediaQuery.of(context).size.height * 0.02:MediaQuery.of(context).size.height * 0.01,
                                                          width: 8,
                                                          decoration: BoxDecoration(
                                                            borderRadius: BorderRadius.circular(4),
                                                            color: _chartDataDeliveryBoy[i].color,
                                                          ),
                                                        ),
                                                      ),
                                                      SizedBox(
                                                        width: MediaQuery.of(context).size.width * 0.28,
                                                        child: Text(
                                                          '${_chartDataDeliveryBoy[i].user} ',
                                                          style: const TextStyle(fontSize: 12),
                                                        ),
                                                      ),
                                                      Padding(
                                                        padding: const EdgeInsets.fromLTRB(10, 0, 0, 0),
                                                        child: Text(
                                                          _chartDataDeliveryBoy[i].percentage.toStringAsFixed(0),
                                                          style: const TextStyle(fontSize: 12),
                                                        ),
                                                      ),
                                                    ],
                                                  )
                                              ],
                                            )
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),

                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  List<OrderData> getChartData() {
    _chartData = [
      OrderData("Brhane T",750, const Color(0xffff6d00),charts.ColorUtil.fromDartColor(const Color(0xffff6d00)), 6000),
      OrderData("Ashebir T",750, const Color(0xff924dc1),charts.ColorUtil.fromDartColor(const Color(0xff924dc1)), 6000),
      OrderData("Abdellah A",750, const Color(0xff57bd70),charts.ColorUtil.fromDartColor(const Color(0xff57bd70)), 6000),
      OrderData("Brhane Tt",750, const Color(0xff306f9a),charts.ColorUtil.fromDartColor(const Color(0xff306f9a)), 6000),
      OrderData("Ashebir Tt",750, const Color(0xffdb1e24),charts.ColorUtil.fromDartColor(const Color(0xffdb1e24)), 6000),
      OrderData("Abdellah",750, const Color(0xff57bd70),charts.ColorUtil.fromDartColor(const Color(0xff57bd70)), 6000),
      OrderData("Brhane",750, const Color(0xffe6e6e6),charts.ColorUtil.fromDartColor(const Color(0xffe6e6e6)), 6000),
      OrderData("Ashebir",750, const Color(0xff00d2bb),charts.ColorUtil.fromDartColor(const Color(0xff00d2bb)), 6000),

      ];
      series = [
        charts.Series(
          id: "Category",
          data: _chartData,
          labelAccessorFn: (OrderData row, _) => '${((row.percentage*100/row.total)).round()}%',
          domainFn: (OrderData series, _) => series.user,
          measureFn: (OrderData series, _) => series.percentage,
          colorFn: (OrderData series, _) => series.colors,
          radiusPxFn:(OrderData series, _) => series.total,

        )
      ];

    _chartDataDeliveryBoy = [
      OrderData("Delivery Boy 1",10, const Color(0xffff6d00),charts.ColorUtil.fromDartColor(const Color(0xffff6d00)), 20),
      OrderData("Delivery Boy 2",5, const Color(0xff924dc1),charts.ColorUtil.fromDartColor(const Color(0xff924dc1)), 20),
      OrderData("Delivery Boy 3",5, const Color(0xff57bd70),charts.ColorUtil.fromDartColor(const Color(0xff57bd70)), 20),
    ];
    seriesForDeliveryBoy = [
      charts.Series(
        id: "Category",
        data: _chartDataDeliveryBoy,
        labelAccessorFn: (OrderData row, _) => '${((row.percentage*100/row.total)).round()}%',
        domainFn: (OrderData series, _) => series.user,
        measureFn: (OrderData series, _) => series.percentage,
        colorFn: (OrderData series, _) => series.colors,
        radiusPxFn:(OrderData series, _) => series.total,

      )
    ];

    return _chartData;
  }
}
class OrderData {
  OrderData(this.user, this.percentage, this.color, this.colors, this.total);
  final String user;
  final double percentage;
  final Color color;
  final charts.Color colors;
  final double total;
}

