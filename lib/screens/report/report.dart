import 'dart:core';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:opti_food_app/data_models/contact_model.dart';
import 'package:opti_food_app/data_models/food_items_model.dart';
import 'package:opti_food_app/database/contact_dao.dart';
import 'package:opti_food_app/database/food_items_dao.dart';
import 'package:opti_food_app/screens/report/search_form.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import '../../data_models/order_model.dart';
import '../../database/order_dao.dart';
import '../../utils/constants.dart';
import '../../utils/utility.dart';
import '../../widgets/app_theme.dart';
import '../../widgets/appbar/app_bar_optifood.dart';import '../MountedState.dart';
class Report extends StatefulWidget {
  const Report({Key? key}) : super(key: key);
  @override
  State<Report> createState() => _ReportState();
}
class _ReportState extends MountedState<Report> {

  late List<OrderData> _chartData = [];
  late List<OrderData> _chartDataPartners = [];
  late List<charts.Series<OrderData, String>> series = [];
  double totalValue = 0;
  int totalOrders = 0;
  int totalOrders1 = 0;

  int totalProducts = 0;
  int totalContacts = 0;

  late Future<List<OrderModel>> _orderList;
  late Future<List<FoodItemsModel>> _itemProductsList;
  late Future<List<ContactModel>> _contactList;

  late double takAway = 0;
  late double eatIn = 0;
  late double delivery = 0;
  late double partners = 0;
  late double collect = 0;
  late double point = 0;
  late double uber = 0;
  late double just = 0;
  late double deliveroo = 0;

  late double collectForLegend = 0;
  late double pointForLegend = 0;
  late double uberForLegend = 0;
  late double justForLegend = 0;
  late double deliverooForLegend = 0;
  late SharedPreferences sharedPreferences;
  // late String selectedDate;
  @override
  void initState() {

    super.initState();
    _orderList= getOrderList();

  }
  final _refreshIndicator = GlobalKey<RefreshIndicatorState>();
  @override
  Widget build(BuildContext context) {
    final isLandscape = MediaQuery.of(context).orientation == Orientation.landscape;
    return Scaffold(
      appBar: AppBarOptifood(),
      body: RefreshIndicator(
        key: _refreshIndicator,
        onRefresh: getOrderList,
        child: FutureBuilder<List<OrderModel>>(
            future: _orderList,
            builder: (context, snapshot) {
              switch (snapshot.connectionState) {
                case ConnectionState.waiting:
                  return Center(child: CircularProgressIndicator());
                  break;
                case ConnectionState.done:
                  if (snapshot.hasError) {
                    return Center(
                        child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        const Icon(
                          Icons.error,
                          size: 50,
                        ),
                        Text('Error: ${snapshot.error}'),
                      ],
                    ));
                  } else {
                    return Padding(
                      padding: const EdgeInsets.only(top: 0),
                      child: SafeArea(
                          child: Padding(
                              padding: const EdgeInsets.fromLTRB(3, 2, 3, 0),
                              child: ListView(
                                children: [
                                  // Expanded( child:( charts.BarChart(series, animate: true)),),
                                  Row(
                                    children: [
                                      Card(
                                        color: Colors.white,
                                        surfaceTintColor: Colors.transparent,
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                          BorderRadius.circular(12),
                                        ),
                                        elevation: 15,
                                        child: SizedBox(
                                          width: isLandscape?MediaQuery.of(context)
                                              .size
                                              .width *
                                              0.498:MediaQuery.of(context)
                                              .size
                                              .width *
                                              0.468,
                                          child: Column(
                                            children: [
                                              Padding(
                                                padding:
                                                const EdgeInsets.fromLTRB(
                                                    0, 6, 0, 0),
                                                child: const Text("totalProducts",
                                                    style: TextStyle(
                                                        fontSize: 16,
                                                        fontWeight:
                                                        FontWeight.bold,
                                                        color: AppTheme
                                                            .colorRed)).tr(),
                                              ),
                                              Padding(
                                                padding: const EdgeInsets
                                                    .fromLTRB(0, 0, 0, 6),
                                                child: Text("$totalProducts",
                                                    style: const TextStyle(
                                                        fontSize: 20,
                                                        fontWeight:
                                                        FontWeight.bold,
                                                        color:
                                                        Colors.black)),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      Card(
                                        color: Colors.white,
                                        surfaceTintColor: Colors.transparent,
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                          BorderRadius.circular(12),
                                        ),
                                        elevation: 15,
                                        child: SizedBox(
                                          width: MediaQuery.of(context)
                                              .size
                                              .width *
                                              0.47,
                                          child: Column(
                                            children: [
                                              Padding(
                                                  padding:
                                                  const EdgeInsets.fromLTRB(
                                                      0, 6, 0, 0),
                                                  child: const Text(
                                                    "totalCustomers",
                                                    style: TextStyle(
                                                        fontSize: 16,
                                                        fontWeight:
                                                        FontWeight.bold,
                                                        color: AppTheme
                                                            .colorRed),
                                                  ).tr()),
                                              Padding(
                                                  padding: const EdgeInsets
                                                      .fromLTRB(0, 0, 0, 6),
                                                  child: Text(
                                                      "$totalContacts",
                                                      style:
                                                      const TextStyle(
                                                          fontSize: 20,
                                                          fontWeight:
                                                          FontWeight
                                                              .bold,
                                                          color: Colors
                                                              .black))),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                    // child:( charts.BarChart(series, animate: true)),
                                  ),
                                  Row(
                                    children: [
                                      Card(
                                        color: Colors.white,
                                        surfaceTintColor: Colors.transparent,
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(12),
                                        ),
                                        elevation: 15,
                                        child: SizedBox(
                                          width: isLandscape?MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.498:MediaQuery.of(context)
                                              .size
                                              .width *
                                              0.468,
                                          child: Column(
                                            children: [
                                              Padding(
                                                padding:
                                                    const EdgeInsets.fromLTRB(
                                                        0, 6, 0, 0),
                                                child: const Text("totalOrders",
                                                    style: TextStyle(
                                                        fontSize: 16,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color: AppTheme
                                                            .colorRed)).tr(),
                                              ),
                                              Padding(
                                                padding: const EdgeInsets
                                                    .fromLTRB(0, 0, 0, 6),
                                                child: Text("$totalOrders",
                                                    style: const TextStyle(
                                                        fontSize: 20,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color:
                                                            Colors.black)),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      Card(
                                        color: Colors.white,
                                        surfaceTintColor: Colors.transparent,
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(12),
                                        ),
                                        elevation: 15,
                                        child: SizedBox(
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.47,
                                          child: Column(
                                            children: [
                                              Padding(
                                                  padding:
                                                      const EdgeInsets.fromLTRB(
                                                          0, 6, 0, 0),
                                                  child: const Text(
                                                    "totalAmount",
                                                    style: TextStyle(
                                                        fontSize: 16,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color: AppTheme
                                                            .colorRed),
                                                  ).tr()),
                                              Padding(
                                                  padding: const EdgeInsets
                                                      .fromLTRB(0, 0, 0, 6),
                                                  child: Text(
                                                      Utility().formatPrice(totalValue),
                                                      style:
                                                          const TextStyle(
                                                              fontSize: 20,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              color: Colors
                                                                  .black))),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],

                                  ),
                                 // Expanded(
                                  Container(
                                      child: Card(
                                          color: Colors.white,
                                          surfaceTintColor: Colors.transparent,
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(20),
                                          ),
                                          elevation: 15,
                                          child: Column(
                                            children: [
                                              Transform.translate(
                                                offset:Offset(0,13),
                                              child: const Text(
                                                "orderTypes",
                                                style: TextStyle(
                                                    fontSize: 18,
                                                    color:
                                                        AppTheme.colorRed,
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ).tr()),
                                              SfCircularChart(
                                                  series: <CircularSeries>[
                                                    RadialBarSeries<OrderData,
                                                        String>(

                                                      dataSource: _chartData,
                                                      xValueMapper:
                                                          (OrderData data, _) =>
                                                              data.orderType,
                                                      yValueMapper:
                                                          (OrderData data, _) =>
                                                              data.percentage,
                                                      pointColorMapper:
                                                          (OrderData data, _) =>
                                                              data.color,
                                                      gap: "8%",
                                                      cornerStyle: CornerStyle
                                                          .bothCurve,
                                                      radius: "92%",
                                                      innerRadius: "30%",
                                                    )
                                                  ]),
                                              Transform.translate(
                                                offset: Offset(0, -17),
                                                child: Row(
                                                  children: [
                                                    Padding(
                                                      padding:
                                                      isLandscape?const EdgeInsets
                                                                  .fromLTRB(
                                                              50, 0, 0, 0):const EdgeInsets
                                                          .fromLTRB(
                                                          18, 0, 0, 0),
                                                      child: SizedBox(
                                                          width: MediaQuery.of(
                                                                      context)
                                                                  .size
                                                                  .width *
                                                              0.41,
                                                          child: Column(
                                                            children: [
                                                              for (var i =
                                                                      _chartData.length -
                                                                          1;
                                                                  i >= 2;
                                                                  i--)
                                                              SingleChildScrollView(
                                                                scrollDirection: Axis.horizontal,

                                                                child: Row(
                                                                    children: [
                                                                  Padding(
                                                                    padding: const EdgeInsets.fromLTRB(0, 0, 1, 0),
                                                                    child: Container(
                                                                      height: isLandscape?MediaQuery.of(context).size.height * 0.02:
                                                                      MediaQuery.of(context).size.height * 0.01,
                                                                      width: 8,
                                                                      decoration: BoxDecoration(
                                                                        borderRadius: BorderRadius.circular(4),
                                                                        color: _chartData[i].color,
                                                                      ),
                                                                      margin: const EdgeInsets.only(right: 3.0),
                                                                    ),
                                                                  ),
                                                                  SizedBox(
                                                                    width: MediaQuery.of(context).size.width * 0.18,
                                                                    child: Text(
                                                                      '${_chartData[i].orderType} ',
                                                                      style: const TextStyle(fontSize: 12),
                                                                    ),
                                                                  ),
                                                                  Padding(
                                                                    padding: const EdgeInsets.fromLTRB(20, 0, 0, 0),
                                                                    child: totalOrders != 0
                                                                        ? Container(
                                                                            child: (_chartData[i].percentage / (totalOrders / 100)) < 10
                                                                                ? Container(
                                                                              margin: const EdgeInsets.only(left: 14),

                                                                              child: Text(
                                                                                      '${(_chartData[i].percentage / (totalOrders / 100)).round()}%',
                                                                                      style: const TextStyle(fontSize: 12),
                                                                                    ),
                                                                                )
                                                                                : Container(
                                                                                    child: (_chartData[i].percentage / (totalOrders / 100)) == 100
                                                                                        ? Text(
                                                                                            '${(_chartData[i].percentage / (totalOrders / 100)).round()}%',
                                                                                            style: const TextStyle(fontSize: 12),
                                                                                          )
                                                                                        : Container(
                                                                                      margin: const EdgeInsets.only(left: 7),

                                                                                      child: Text(
                                                                                              '${(_chartData[i].percentage / (totalOrders / 100)).round()}%',
                                                                                              style: const TextStyle(fontSize: 12),
                                                                                            ),
                                                                                        ),
                                                                                  ),
                                                                          )
                                                                        : Text("0%"),
                                                                  ),
                                                                            ],
                                                                          ),
                                                                )
                                                            ],
                                                          )),
                                                    ),
                                                    Padding(
                                                      padding:const EdgeInsets
                                                          .fromLTRB(
                                                          0, 2, 10, 0),
                                                      child: SizedBox(
                                                        height: MediaQuery.of(context).size.height*(0.017)*(_chartData.length/2).round(),
                                                        child:
                                                            const VerticalDivider(
                                                          thickness: 1,
                                                          width: 10,
                                                          color: AppTheme
                                                              .colorLightGrey,
                                                        ),
                                                      ),
                                                    ),
                                                    Padding(
                                                      padding:
                                                          const EdgeInsets
                                                                  .fromLTRB(
                                                              8, 0, 0, 0),
                                                      child: SizedBox(
                                                          width: MediaQuery.of(
                                                                      context)
                                                                  .size
                                                                  .width *
                                                              0.40,
                                                          child: Column(
                                                            children: [
                                                              for (var i =
                                                                      _chartData.length -
                                                                          3;
                                                                  i >= 0;
                                                                  i--)
                                                         Row(
                                                                          children: [

                                                                    Padding(
                                                                      padding: const EdgeInsets.fromLTRB(0, 0, 1, 0),
                                                                      child: Container(
                                                                        margin: isLandscape? const EdgeInsets.only(left: 88.0,right: 3.0):EdgeInsets.only(right: 3.0),

                                                                        height: isLandscape?MediaQuery.of(context).size.height * 0.02:MediaQuery.of(context).size.height * 0.01,
                                                                        width: 8,
                                                                        decoration: BoxDecoration(
                                                                          borderRadius: BorderRadius.circular(4),
                                                                          color: _chartData[i].color,
                                                                        ),
                                                                      ),
                                                                    ),
                                                                    SizedBox(
                                                                      width: isLandscape?MediaQuery.of(context).size.width * 0.18:MediaQuery.of(context).size.width * 0.18,
                                                                      child: Text(
                                                                        '${_chartData[i].orderType} ',
                                                                        style: const TextStyle(fontSize: 12),
                                                                      ),
                                                                    ),
                                                                    Padding(
                                                                      padding: isLandscape?const EdgeInsets.fromLTRB(30, 0, 0, 0):const EdgeInsets.fromLTRB(20, 0, 0, 0),
                                                                      child: totalOrders != 0
                                                                          ? Container(
                                                                              child: (_chartData[i].percentage / (totalOrders / 100)) < 10
                                                                                  ? Container(
                                                                                margin: const EdgeInsets.only(left: 14),
                                                                                child: Text(
                                                                                        '${(_chartData[i].percentage / (totalOrders / 100)).round()}%',
                                                                                        style: const TextStyle(fontSize: 12),
                                                                                      ),
                                                                                  )
                                                                                  : Container(
                                                                                      child: (_chartData[i].percentage / (totalOrders / 100)) == 100
                                                                                          ? Text(
                                                                                              '${(_chartData[i].percentage / (totalOrders / 100)).round()}%',
                                                                                              style: const TextStyle(fontSize: 12),
                                                                                            )
                                                                                          : Container(
                                                                                        margin: const EdgeInsets.only(left: 7),

                                                                                        child: Text(
                                                                                                '${(_chartData[i].percentage / (totalOrders / 100)).round()}%',
                                                                                                style: const TextStyle(fontSize: 12),
                                                                                              ),
                                                                                          ),
                                                                                    ),
                                                                            )
                                                                          : Text("0%"),
                                                                    ),
                                                                          ],
                                                                        )
                                                            ],
                                                          )),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ))),
                                  Card(
                                    color: Colors.white,
                                    surfaceTintColor: Colors.transparent,
                                    shape: RoundedRectangleBorder(
                                      borderRadius:
                                          BorderRadius.circular(12),
                                    ),
                                    elevation: 15,
                                    child: Padding(
                                      padding: const EdgeInsets.fromLTRB(
                                          1, 0, 0, 0),
                                      child: Column(
                                        children: [
                                          Transform.translate(
                                            offset: Offset(0, 10),
                                            child: const Text("partners",
                                                style: TextStyle(
                                                    fontSize: 16,
                                                    fontWeight:
                                                        FontWeight.bold,
                                                    color:
                                                        AppTheme.colorRed)).tr()
                                            ,
                                          ),
                                          Container(
                                            height: isLandscape?MediaQuery.of(context)
                                                    .size
                                                    .height *
                                                0.32:MediaQuery.of(context)
                                                .size
                                                .height *
                                                0.18,
                                            margin:isLandscape?EdgeInsets.only(left: 13.0):EdgeInsets.only(right: 0.0),
                                            child: totalOrders1 == 0
                                                //? Expanded(
                                                ? Container(
                                                    child: charts.BarChart(
                                                      series,
                                                      primaryMeasureAxis:
                                                          const charts
                                                              .NumericAxisSpec(
                                                        renderSpec: charts
                                                            .NoneRenderSpec(),
                                                      ),
                                                      domainAxis: const charts
                                                          .OrdinalAxisSpec(
                                                              showAxisLine:
                                                                  true,
                                                              renderSpec:
                                                                  charts
                                                                      .NoneRenderSpec()),
                                                      animate: true,
                                                      vertical: false,
                                                    ),
                                                  )
                                                //: Expanded(
                                                : Container(
                                                    child: charts.BarChart(
                                                      series,
                                                      behaviors: [
                                                        charts
                                                            .PercentInjector(
                                                          totalType: charts
                                                              .PercentInjectorTotalType
                                                              .series,
                                                        )
                                                      ],
                                                      primaryMeasureAxis:
                                                          const charts
                                                              .NumericAxisSpec(
                                                        renderSpec: charts
                                                            .NoneRenderSpec(),
                                                      ),
                                                      domainAxis: const charts
                                                          .OrdinalAxisSpec(
                                                              showAxisLine:
                                                                  true,
                                                              renderSpec:
                                                                  charts
                                                                      .NoneRenderSpec()),

                                                      animate: true,
                                                      vertical: false,
                                                    ),
                                                  ),
                                          ),
                                          Transform.translate(
                                            offset: Offset(0, -12),
                                            child: Row(
                                              children: [
                                                Padding(
                                                  padding: isLandscape?const EdgeInsets
                                                          .fromLTRB(
                                                      48, 0, 0, 0):const EdgeInsets
                                                      .fromLTRB(
                                                      25, 0, 0, 0),
                                                  child: SizedBox(
                                                      width: MediaQuery.of(
                                                                  context)
                                                              .size
                                                              .width *
                                                          0.42,
                                                      child: Column(
                                                        children: [
                                                          for (var i = 0;
                                                              i < 3;
                                                              i++) Row(
                                                                      children: [
                                                              Padding(
                                                                padding: const EdgeInsets.fromLTRB(0, 0, 1, 0),
                                                                child: Container(
                                                                  margin: EdgeInsets.only(right: 3.0),

                                                                  height: isLandscape?MediaQuery.of(context).size.height * 0.02:MediaQuery.of(context).size.height * 0.01,
                                                                  width: 8,
                                                                  decoration: BoxDecoration(
                                                                    borderRadius: BorderRadius.circular(4),
                                                                    color: _chartDataPartners[i].color,
                                                                  ),
                                                                ),
                                                              ),
                                                              SizedBox(
                                                                width: isLandscape?MediaQuery.of(context).size.width * 0.21:MediaQuery.of(context).size.width * 0.245,

                                                                // width: MediaQuery.of(context).size.width * 0.12,
                                                                child: Text(
                                                                  '${_chartDataPartners[i].orderType} ',
                                                                  style: const TextStyle(fontSize: 12),
                                                                ),
                                                              ),
                                                              Padding(
                                                                padding: const EdgeInsets.fromLTRB(2, 0, 0, 0),
                                                                child: totalOrders1 != 0
                                                                    ? Container(
                                                                        child: (_chartDataPartners[i].percentage2 / (totalOrders / 100)) < 10
                                                                            ? Container(
                                                                          margin: const EdgeInsets.only(left: 14),

                                                                          child: Text(
                                                                                  '${(_chartDataPartners[i].percentage2 / (totalOrders / 100)).round()}%',
                                                                                  style: const TextStyle(fontSize: 12),
                                                                                ),
                                                                            )
                                                                            : Container(
                                                                                child: (_chartDataPartners[i].percentage2 / (totalOrders / 100)) == 100
                                                                                    ? Text(
                                                                                        '${(_chartDataPartners[i].percentage2 / (totalOrders / 100)).round()}%',
                                                                                        style: const TextStyle(fontSize: 12),
                                                                                      )
                                                                                    : Container(
                                                                                  margin: const EdgeInsets.only(left: 7),

                                                                                  child: Text(
                                                                                          '${(_chartDataPartners[i].percentage2 / (totalOrders / 100)).round()}%',
                                                                                          style: const TextStyle(fontSize: 12),
                                                                                        ),
                                                                                    ),
                                                                              ),
                                                                      )
                                                                    : Text("0%"),
                                                              ),
                                                                      ],
                                                                    )
                                                        ],
                                                      )),
                                                ),
                                                Padding(
                                                  padding: const EdgeInsets
                                                          .fromLTRB(
                                                      0, 2, 10, 0),
                                                  child: SizedBox(
                                                    height: MediaQuery.of(context).size.height*(0.017)*(_chartDataPartners.length/2).round(),
                                                    child: const VerticalDivider(
                                                      thickness: 1,
                                                      width: 10,
                                                      color: AppTheme
                                                          .colorLightGrey,
                                                    ),
                                                  ),
                                                ),
                                                Transform.translate(
                                                  offset: const Offset(0, -8),
                                                  child: Padding(
                                                    padding:
                                                        const EdgeInsets
                                                                .fromLTRB(
                                                            8, 0, 0, 0),
                                                    child: SizedBox(
                                                        width: MediaQuery.of(
                                                                    context)
                                                                .size
                                                                .width *
                                                            0.39,
                                                        child: Column(
                                                          children: [
                                                            for (var i = 3;
                                                                i <
                                                                    _chartDataPartners
                                                                        .length;
                                                                i++)
                                                             Row(
                                                               children: [
                                                             Padding(
                                                               padding: const EdgeInsets.fromLTRB(0, 0, 1, 0),
                                                               child: Container(
                                                                 margin: isLandscape? const EdgeInsets.only(left: 92.0,right: 3.0):EdgeInsets.only(right: 3.0),

                                                                 height: isLandscape?MediaQuery.of(context).size.height * 0.02:MediaQuery.of(context).size.height * 0.01,
                                                                 width: 8,
                                                                 decoration: BoxDecoration(
                                                                   borderRadius: BorderRadius.circular(4),
                                                                   color: _chartDataPartners[i].color,
                                                                 ),
                                                               ),
                                                             ),
                                                             SizedBox(
                                                               width: isLandscape?MediaQuery.of(context).size.width * 0.22:MediaQuery.of(context).size.width * 0.22,

                                                               child: Text(
                                                                 '${_chartDataPartners[i].orderType} ',
                                                                 style: const TextStyle(fontSize: 12),
                                                               ),
                                                             ),
                                                             Padding(
                                                               padding: const EdgeInsets.fromLTRB(2, 0, 0, 0),
                                                               child: totalOrders1 != 0
                                                                   ? Container(
                                                                       child: (_chartDataPartners[i].percentage2 / (totalOrders / 100)) < 10
                                                                           ? Container(
                                                                         margin: const EdgeInsets.only(left: 14),

                                                                         child: Text(
                                                                                 '${(_chartDataPartners[i].percentage2 / (totalOrders / 100)).round()}%',
                                                                                 style: const TextStyle(fontSize: 12),
                                                                               ),
                                                                           )
                                                                           : Container(
                                                                               child: (_chartDataPartners[i].percentage2 / (totalOrders / 100)) == 100
                                                                                   ? Text(
                                                                                       '${(_chartDataPartners[i].percentage2 / (totalOrders / 100)).round()}%',
                                                                                       style: const TextStyle(fontSize: 12),
                                                                                     )
                                                                                   : Container(
                                                                                 margin: const EdgeInsets.only(left: 7),

                                                                                 child: Text(
                                                                                         ' ${(_chartDataPartners[i].percentage2 / (totalOrders / 100)).round()}%',
                                                                                         style: const TextStyle(fontSize: 12),
                                                                                       ),
                                                                                   ),
                                                                             ),
                                                                     )
                                                                   : Text("0%"),
                                                             ),
                                                                        ],
                                                                      )
                                                          ],
                                                        )),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  Row(
                                    children: [
                                      Container(
                                        height: MediaQuery.of(context).size.height*0.09,
                                        margin:const EdgeInsets.only(left: 208.0,right: 1.0,top: 6),
                                        child: Padding(
                                          padding: const EdgeInsets.fromLTRB(0, 0, 0, 24),
                                          child: ElevatedButton.icon(
                                            style: ElevatedButton.styleFrom(
                                              surfaceTintColor: Colors.transparent,
                                              primary: Colors.white,
                                            ),
                                            icon: const Text('seeMore', style: TextStyle(fontSize: 18, color:Colors.black)).tr(),
                                            label: const Icon(Icons.arrow_forward, size: 28, color: Colors.black,),
                                            onPressed: () async{
                                              //Navigator.of(context).push(MaterialPageRoute(builder: (context)=>const SearchForm()));
                                              Utility().showToastMessage("Coming soon...");
                                            },
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ))),
                    );
                  }
                default:
                  return Center(
                      child: Container(
                    child: Text('somethingWentWrongTryAgain').tr(),
                  ));
              }
            }),
      ),
    );
  }

  List<OrderData> getChartData() {
    if (collect == 0) {
      collect = 0.005;
    }
    if (point == 0) {
      point = 0.005;
    }
    if (uber == 0) {
      uber = 0.005;
    }
    if (just == 0) {
      just = 0.005;
    }
    if (deliveroo == 0) {
      deliveroo = 0.005;
    }
    _chartDataPartners = [
      OrderData("Click & Collect", collect, Color(0xff924dc1),
          charts.ColorUtil.fromDartColor(Color(0xff924dc1)), collectForLegend),
      OrderData("Point of sale", point, Color(0xff306f9a),
          charts.ColorUtil.fromDartColor(Color(0xff306f9a)), pointForLegend),
      OrderData("Uber Eats", uber, Color(0xff57bd70),
          charts.ColorUtil.fromDartColor(Color(0xff57bd70)), uberForLegend),
      OrderData("Just Eat", just, Color(0xffff6d00),
          charts.ColorUtil.fromDartColor(Color(0xffff6d00)), justForLegend),
      OrderData(
          "Deliveroo",
          deliveroo,
          Color(0xff00d2bb),
          charts.ColorUtil.fromDartColor(Color(0xff00d2bb)),
          deliverooForLegend),
    ];
    series = [
      charts.Series(
        id: "Price",
        data: _chartDataPartners,
        domainFn: (OrderData series, _) => series.orderType,
        measureFn: (OrderData series, _) => series.percentage,
        colorFn: (OrderData series, _) => series.colors,
      )
    ];

    final List<OrderData> chartData = [
      OrderData("partners".tr(), partners, const Color(0xffc56669),
          charts.ColorUtil.fromDartColor(AppTheme.colorRed), collectForLegend),
      OrderData("delivery".tr(), delivery, const Color(0xffed8e91),
          charts.ColorUtil.fromDartColor(AppTheme.colorRed), pointForLegend),
      OrderData("eatIn".tr(), eatIn, const Color(0xff9f0005),
          charts.ColorUtil.fromDartColor(AppTheme.colorRed), uberForLegend),
      OrderData("takeAway".tr(), takAway, const Color(0xffdb1e24),
          charts.ColorUtil.fromDartColor(AppTheme.colorRed), justForLegend),
    ];
    return chartData;
  }

  String? selectedDate = null;
  bool? isFilterSelectedDelivery = true;
  bool? isFilterSelectedEatIn = true;
  bool? isFilterSelectedTakeaway = true;
  String selectedOrderStatus = "All";
  String? selectedOrderStatus1="";
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

  Future<List<OrderModel>> getOrderList() async {

    // final SharedPreferences prefs = await _prefs;
    totalValue=0;
    totalOrders=0;
    totalProducts = await FoodItemsDao().getCount();
    totalContacts =  await ContactDao().getCount();

    totalValue=takAway = eatIn = delivery =  partners = collect =  point = uber = just = deliveroo = collectForLegend = 0;
    pointForLegend =  uberForLegend = justForLegend = deliverooForLegend = 0;
    // var now = DateTime.now();
    // var formatter = DateFormat('dd/MM/yyyy');
    //
    // setState(() {
    //   selectedDate = prefs.getString("selectedDate");
    //   print("====selectedDate====$selectedDate===========");
    //   selectedOrderStatus1 = prefs.getString("selectedOrderStatus");
    //   isFilterSelectedTakeaway = prefs.getBool("isFilterSelectedTakeaway");
    //   isFilterSelectedEatIn = prefs.getBool("isFilterSelectedEatIn");
    //   isFilterSelectedDelivery = prefs.getBool("isFilterSelectedDelivery");
    //   String formattedDate = formatter.format(now);
    //   List<String> filter = [];
    //   if(isFilterSelectedTakeaway==null){
    //     isFilterSelectedTakeaway=true;
    //   }
    //
    //   if(isFilterSelectedEatIn==null){
    //     isFilterSelectedEatIn=true;
    //   }
    //
    //   if(isFilterSelectedDelivery==null){
    //     isFilterSelectedDelivery=true;
    //   }
    //   print("=============${isFilterSelectedTakeaway}======================================================================");
    //   if(isFilterSelectedTakeaway!){
    //     filter.add(ConstantRestaurantOrderType.RESTAURANT_ORDER_TYPE_TAKEAWAY);
    //   }
    //   if(isFilterSelectedEatIn!){
    //     filter.add(ConstantRestaurantOrderType.RESTAURANT_ORDER_TYPE_EAT_IN);
    //   }
    //   if(isFilterSelectedDelivery!){
    //     filter.add(ConstantOrderType.ORDER_TYPE_DELIVERY);
    //   }
    //   if(selectedOrderStatus1!=null){
    //     selectedOrderStatus = selectedOrderStatus1!;
    //   }
    //
    //   String? sDate = null;
    //   if(formattedDate!=null&&formattedDate.isNotEmpty) {
    //     List<String> dateArr = formattedDate.split("/");
    //     sDate = dateArr[2] + "-" + dateArr[1] + "-" + dateArr[0];
    //   }
    //   if(selectedDate==null){
    //     selectedDate=sDate;
    //   }

      //orderList = OrderDao().getAllOrders(orderTypeFilterList: filter,selectedStatus: selectedOrderStatus);
      _orderList = OrderDao().getAllOrders();
      _orderList.then((value)  => {
        setState((){
          for (int i = 0; i < value.length; i++)
          {
            if(value[i].id!=0)
               totalOrders += 1;
          totalValue += value[i].totalPrice;
          if (value[i].orderService == "restaurant_order_type_takeaway")
          {
          takAway = takAway + 1;
          collect = collect + 0;
          collectForLegend += 0;
          }
          else if (value[i].orderService ==
          "restaurant_order_type_eat_in")
          {eatIn += 1; point += 0; pointForLegend += 0;}
          else if (value[i].orderService == "delivery")
          {delivery += 1; uber += 0; uberForLegend += 0;}
          else if (value[i].orderService == "partners")
          {
          partners += 1;
          just += 0;
          deliveroo += 0;
          justForLegend += 0;
          deliverooForLegend += 0;
          }
          }
          _chartData = getChartData();
          totalValue = totalValue / 1.00;
        }),

      });
    return _orderList;
  }
  Future<List<FoodItemsModel>> getItemList() async {
    // getContactList();
    return _itemProductsList;
  }
  Future<List<ContactModel>> getContactList() async {
    return _contactList;
  }
}

class OrderData {
  OrderData(this.orderType, this.percentage, this.color, this.colors,
      this.percentage2);
  final String orderType;
  final double percentage;
  final Color color;
  final charts.Color colors;
  final double percentage2;
}
