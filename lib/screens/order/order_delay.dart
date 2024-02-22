import 'package:fbroadcast/fbroadcast.dart';
import 'package:flutter/material.dart';
import 'package:opti_food_app/database/order_dao.dart';

import '../../data_models/order_model.dart';
import '../../utils/constants.dart';
import '../../widgets/appbar/app_bar_optifood.dart';
import 'common_file_order_list.dart';
import '../MountedState.dart';
class OrderDelay extends StatefulWidget{
  @override
  State<StatefulWidget> createState() => _OrderDelayState();

}
class _OrderDelayState extends MountedState<OrderDelay>{
  List<OrderModel> delayOrders = [];
  List<OrderModel> emptyOrders = [];
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    OrderDao().getDelayedOrders().then((value){
    //OrderDao().getAllOrders().then((value){
      setState((){
        delayOrders = value;
      });

    });
    FBroadcast.instance().register(ConstantBroadcastKeys.KEY_ORDER_SENT, (value, callback) async {
      OrderDao().getDelayedOrders().then((value){
        setState((){
          delayOrders = value;
        });

      });
    });
  }
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
        appBar: AppBarOptifood(),
        body: Container(
          child: SafeArea(
            child:CommonFileOrderList(ConstantOrderType.ORDER_TYPE_RESTAURANT, delayOrders,
                0,() {
                  //getOrderList();
                  setState(() {
                  });
                }, deliveryOrder: emptyOrders, restaurantOrder: emptyOrders)
          )
        )
    );
  }

}