import 'dart:async';
import 'dart:developer';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:opti_food_app/api/order_apis.dart';
import 'package:opti_food_app/assets/images.dart';
import 'package:opti_food_app/database/order_dao.dart';
import 'package:opti_food_app/widgets/appbar/app_bar_optifood.dart';
import 'package:roundcheckbox/roundcheckbox.dart';
import '../../data_models/order_model.dart';
import '../../utils/constants.dart';
import '../../widgets/app_theme.dart';
import 'order_option_menues.dart';import '../MountedState.dart';
class RestaurantGroupOrder extends StatefulWidget {
  OrderModel primaryOrder;
  List<OrderModel> updatebleOrders = [];
  RestaurantGroupOrder({Key? key, required this.primaryOrder}) : super(key: key);
  @override
  State<RestaurantGroupOrder> createState() => _RestaurantGroupOrderState();
}

class _RestaurantGroupOrderState extends MountedState<RestaurantGroupOrder>{
  List<OrderModel> _orders = [];
  OrderDao _orderDao = OrderDao();
  @override
  void initState() {
    super.initState();
    getOrders();

  }
  getOrders()
  {
    OrderDao().getAttachableOrders(widget.primaryOrder).then((value){
      setState(() {
        _orders = value;
        print("======getAttachableOrders in restaurant group=======${_orders.length}===========================");
        _orders.forEach((element) {
        });
      });
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarOptifood(),
      body: Padding(
          padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(

                child: ListView.builder(
                    itemCount: _orders.length,
                    itemBuilder: (context, index) => Card(
                      color: Colors.white,
                      surfaceTintColor: Colors.transparent,
                      shape:  RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10), // <-- Radius
                      ),
                      child: Container(
                        child: Row(
                          children: <Widget>[
                            Container(
                              width:70,
                              height: 96,
                              decoration: const BoxDecoration(
                                  color:AppTheme.colorGrey,
                                  borderRadius: BorderRadius.horizontal(left:
                                  Radius.circular(10))),
                              alignment: Alignment.center,
                              child: Column(
                                children: [
                                  Container(
                                      height: 68,
                                      child: Padding(
                                        padding: const EdgeInsets.only(top: 30),
                                        child: Text("${_orders[index].orderNumber}", textAlign: TextAlign.center, style: TextStyle(fontSize: 20,color: AppTheme.colorRed,fontWeight: FontWeight.bold),),
                                      )),
                                  Padding(
                                    padding: const EdgeInsets.only(right: 35,),
                                    child: RoundCheckBox(
                                      isChecked: _orders[index].attachedBy!=0,
                                      checkedColor: Color(0xff30ce00),
                                      onTap: (selected){
                                        if(selected==true){
                                          // print()
                                          //OrderDao().attachOrder(widget.primaryOrder, _orders[index]);
                                          if(!widget.primaryOrder.attachedOrders.contains(_orders[index].serverId!))
                                               widget.primaryOrder.attachedOrders.add(_orders[index].serverId!);
                                          _orders[index].attachedBy = widget.primaryOrder.serverId!;
                                          if(widget.updatebleOrders.contains(_orders[index])==false) {
                                            widget.updatebleOrders.add(
                                                _orders[index]);
                                          }
                                        }
                                        else{
                                          //OrderDao().deAttachOrder(widget.primaryOrder, _orders[index]);
                                          widget.primaryOrder.attachedOrders.remove(_orders[index].serverId);
                                          _orders[index].attachedBy = 0;
                                          if(widget.updatebleOrders.contains(_orders[index])==false) {
                                            widget.updatebleOrders.add(
                                                _orders[index]);
                                          }
                                        }
                                      },
                                      size:24,
                                      checkedWidget: Container(
                                          padding: EdgeInsets.all(3),
                                          child: SvgPicture.asset("assets/images/icons/check.svg", height: 0.1, width: 0.1, )
                                        // ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              width:70,
                              height: 96,
                              color: AppTheme.colorLightGrey,
                              alignment: Alignment.center,
                              child: Text(_orders[index].orderType==ConstantOrderType.ORDER_TYPE_DELIVERY?_orders[index].deliveryInfoModel!.deliveryTime:
                              _orders[index].createdAt.split(
                                  " ")[1].split(".")[0].substring(
                                  0, 5),
                                style: TextStyle(fontSize: 18,color: AppTheme.colorDarkGrey, fontWeight: FontWeight.bold),),
                            ),
                            Expanded(
                              child: Container(
                                  width:MediaQuery.of(context).size.width*0.5,
                                  height: 85,
                                  child: ListView.builder(
                                    itemCount: _orders[index]
                                        .foodItems.length,
                                    itemBuilder: (context,
                                        indexItem) {
                                      String attribute = _orders[index].foodItems[indexItem].selectedAttributes.map((e) => e.name).join(",");
                                      return Column(
                                        children: [
                                          Transform.translate(
                                            offset: Offset(
                                                0, 0),
                                            child: Padding(
                                              padding: const EdgeInsets
                                                  .fromLTRB(
                                                  4, 0, 0, 0),
                                              child: Row(
                                                children: [
                                                  Transform.translate(
                                                    offset: Offset(0,
                                                        -(indexItem
                                                            .floorToDouble())),
                                                    child: SizedBox(
                                                        width: MediaQuery
                                                            .of(context)
                                                            .size
                                                            .width * 0.43,
                                                        child: _orders[index]
                                                            .foodItems[indexItem] !=
                                                            null
                                                            ? Transform
                                                            .translate(
                                                          offset: const Offset(
                                                              0, 0),
                                                          child: Text(
                                                            _orders[index]
                                                                .foodItems[indexItem]
                                                                .name,
                                                            style: const TextStyle(
                                                                color: Color(
                                                                    0xff282828),
                                                                fontSize: 11,
                                                                fontWeight: FontWeight
                                                                    .bold),),
                                                        )
                                                            : Text("")),
                                                  ),
                                                  Padding(
                                                    padding: const EdgeInsets
                                                        .fromLTRB(
                                                        0, 0,
                                                        0, 0),
                                                    child: Transform
                                                        .translate(
                                                      offset: Offset(
                                                          0, 0),
                                                      child: Text(
                                                        "x${_orders[index]
                                                            .foodItems[indexItem]
                                                            .quantity}",
                                                        textAlign: TextAlign
                                                            .end,
                                                        style: const TextStyle(
                                                            color: Color(
                                                                0xffdb1e24)),),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                          if(attribute.isNotEmpty)...[
                                            Transform.translate(
                                              offset: Offset(0,-4),
                                              child: Padding(
                                                padding: const EdgeInsets.fromLTRB(16, 0, 0, 0),
                                                child: Row(
                                                  children: [
                                                    SvgPicture.asset("assets/images/icons/turn-right.svg", height: 8, color: AppTheme.colorMediumGrey),
                                                    Padding(
                                                      padding: EdgeInsets.fromLTRB(3, 0, 0, 0),
                                                      //child: Text("Spicy Sauce, Potatoas, Fanta", style: TextStyle(fontSize: 9,fontStyle: FontStyle.italic, color: AppTheme.colorMediumGrey),),
                                                      child: Text(attribute, style: TextStyle(fontSize: 9,fontStyle: FontStyle.italic, color: AppTheme.colorMediumGrey),),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ]
                                        ],
                                      );
                                    },
                                  )
                              ),
                            ),
                            InkWell(
                              onTap: (){
                              },
                              child: Container(
                                decoration: const BoxDecoration(
                                  color: AppTheme.colorRed,
                                  borderRadius: BorderRadius.horizontal(right:
                                  Radius.circular(10),
                                  ),
                                ),
                                width:30,
                                height: 96,
                                alignment: Alignment.center,
                                child: SvgPicture.asset(_orders[index].orderType==ConstantOrderType.ORDER_TYPE_DELIVERY?AppImages.scooterIcon:
                                _orders[index].orderService==ConstantRestaurantOrderType.RESTAURANT_ORDER_TYPE_TAKEAWAY?AppImages.takeawayIcon:AppImages.dinnerTableIcon, height: 20, color: Colors.white),
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                ),
              ),
              Container(
                child: Padding(
                  padding: const EdgeInsets.only(left: 60,right: 55,top: 20,bottom: 20),
                  child: Container(
                    height:45 ,
                    width: 300,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.all(
                            Radius.circular(10)),
                        boxShadow: [
                          BoxShadow(color: AppTheme.colorDarkGrey,spreadRadius:2, blurRadius: 0,)
                        ]
                    ),
                    child: ElevatedButton(

                      style: ElevatedButton.styleFrom(
                          surfaceTintColor: Colors.transparent,
                          primary: AppTheme.colorDarkGrey,
                          elevation: 10, shadowColor: AppTheme.colorDarkGrey),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,

                        children: [
                          Padding(
                            padding: const EdgeInsets.only(right: 15),
                            child: SvgPicture.asset("assets/images/icons/save-red.svg",
                              height: 25,),
                          ),
                          Text('save', style: const TextStyle(fontSize: 18.0, color: Colors.white),).tr(),
                        ],
                      ),
                      onPressed: () async {
                        if(widget.updatebleOrders.isNotEmpty){
                          List<int> attachedOrders = [];
                          widget.updatebleOrders.forEach((element) async {
                            await _orderDao.updateOrder(element);
                            attachedOrders.add(element.serverId!);
                          });
                          widget.primaryOrder.attachedOrders = widget.primaryOrder.attachedOrders.toSet().toList();
                          print("=====widget.primaryOrderppp=========${widget.primaryOrder.attachedOrders}========================");
                          await _orderDao.updateOrder(widget.primaryOrder);

                          OrderApis.groupOrder(widget.primaryOrder, widget.primaryOrder.attachedOrders);
                        }
                        Navigator.of(context).pop();
                      },
                    ),
                  ),
                ),
              )
            ],
          )
      ),
    );
  }
}