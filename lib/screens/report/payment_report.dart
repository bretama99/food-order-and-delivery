import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../data_models/order_model.dart';
import '../../database/order_dao.dart';
import '../../widgets/app_theme.dart';
import 'common_file_for_interval_report.dart';
import '../MountedState.dart';
class PaymentReport extends StatefulWidget {
  // final bool isFilterActivated;
  // final Future<List<OrderModel>> orderList;
  const PaymentReport({Key? key}) : super(key: key);

  @override
  State<PaymentReport> createState() => _PaymentReportState();
}

class _PaymentReportState extends MountedState<PaymentReport> {

  double totalValue = 0;
  int totalOrders = 0;
  late Future<List<OrderModel>> _orderList;
  late double cash = 0;
  late double creditCard = 0;
  late double mealVoucher = 0;
  late double cheque = 0;
  late double platform = 0;
  late SharedPreferences sharedPreferences;

  @override
  void initState() {
    // TODO: implement initState

    super.initState();
    SharedPreferences.getInstance().then((value) {
      sharedPreferences = value;
      setState(() {
        totalValue = sharedPreferences.getDouble("totalValue")!;
        cash = sharedPreferences.getDouble("cash")!;
        creditCard = sharedPreferences.getDouble("creditCard")!;
        mealVoucher = sharedPreferences.getDouble("mealVoucher")!;
        cheque = sharedPreferences.getDouble("cheque")!;
        platform = sharedPreferences.getDouble("platform")!;

      });
    });
    // getOrderList();
  }

  final _refreshIndicator = GlobalKey<RefreshIndicatorState>();
  @override
  Widget build(BuildContext context) {
    return SizedBox(
                  height: MediaQuery.of(context).size.height*0.6,
                  child: ListView(
                    children: [
                      Card(
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
                              CommonFileForIntervalReport(
                                  totalPrice: cash,
                                  color: const Color(0xffdb1e24),
                                  title: "cash".tr(),
                                  gross: totalValue),
                              CommonFileForIntervalReport(
                                  totalPrice: creditCard,
                                  color: const Color(0xff9f0005),
                                  title: "creditCard".tr(),
                                  gross: totalValue),
                              CommonFileForIntervalReport(
                                  totalPrice: mealVoucher,
                                  color: const Color(0xffed8e91),
                                  title: "mealVoucher".tr(),
                                  gross: totalValue),
                              CommonFileForIntervalReport(
                                  totalPrice: cheque,
                                  color: const Color(0xff924dc1),
                                  title: "cheque".tr(),
                                  gross: totalValue),
                              CommonFileForIntervalReport(
                                  totalPrice: platform,
                                  color: const Color(0xff306f9a),
                                  title: "platform".tr(),
                                  gross: totalValue),
                            ],
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
      // _orderList = OrderDao().getAllOrders();
      // widget.orderList.then((value) => {
      //   for (int i = 0; i < value.length; i++)
      //     {
      //       print("==========rrrrrr======================${value[i].paymentMode}============================================="),
      //
      //       totalValue += value[i].totalPrice,
      //       if (value[i].paymentMode == "Cash")
      //         {
      //           cash += value[i].totalPrice,
      //         }
      //       else if (value[i].paymentMode == "Credit Card")
      //         {
      //           creditCard += value[i].totalPrice}
      //       else if (value[i].paymentMode == "Cheque")
      //           {
      //             cheque += value[i].totalPrice}
      //         else if (value[i].paymentMode == "Platform")
      //             {
      //               platform += value[i].totalPrice}
      //       else if (value[i].paymentMode == "Meal Voucher")
      //           {mealVoucher += value[i].totalPrice}
      //     },
      // });
  //   });
  //   // return widget.orderList;
  // }

}
