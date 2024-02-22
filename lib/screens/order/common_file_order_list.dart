//import 'dart:html';

import 'dart:async';

import 'package:dio/dio.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:fbroadcast/fbroadcast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:opti_food_app/database/food_items_dao.dart';
import 'package:opti_food_app/screens/order/preview_order_list.dart';
import 'package:opti_food_app/screens/order/restaurant_group_order.dart';
import 'package:opti_food_app/utils/constants.dart';
import 'package:opti_food_app/utils/utility.dart';
import 'package:opti_food_app/widgets/popup/input_popup/input_popup.dart';

import '../../api/order_apis.dart';
import '../../assets/images.dart';
import '../../data_models/order_model.dart';
import '../../database/order_dao.dart';
import '../../database/restaurant_info_dao.dart';
import '../../database/user_dao.dart';
import '../../widgets/app_theme.dart';
import '../../widgets/popup/confirmation_popup/confirmation_popup.dart';
import '../contact/contact_list.dart';
import '../user/user_list.dart';
import 'order_option_menues.dart';
import 'order_taking_window.dart';
import '../MountedState.dart';
class CommonFileOrderList extends StatefulWidget {

  //int orderNumber=-1;
  //int orderId=0;
  final List<OrderModel> orders;
  final  int selectedIndex;
  final String orderType;
  final Function reloadOrders;
  Function? refresh;
  List<OrderModel> deliveryOrder=[];
  List<OrderModel> restaurantOrder=[];
  //CommonFileOrderList(this.orderType,this.orders, this.selectedIndex, this.reloadOrders, {Key? key, required this.orderId, required this.orderNumber}) : super(key: key);
  CommonFileOrderList(this.orderType,this.orders, this.selectedIndex, this.reloadOrders, {Key? key,required this.deliveryOrder, required this.restaurantOrder, this.refresh}) : super(key: key);

  @override
  State<CommonFileOrderList> createState() => _CommonFileOrderListState();
}

class _CommonFileOrderListState extends MountedState<CommonFileOrderList> {
  Utility utility = Utility();
  var ordersList=[];

  @override
  void initState(){
    super.initState();
    /*FBroadcast.instance().register(ConstantBroadcastKeys.KEY_ORDER_SENT, (value, callback) {
     // widget.reloadOrders();
      print("Pushingggggggggg");
      checkForOpeningTime();
      OrderModel o = value;

      widget.orders.forEach((element) {
        if(element.id == o.id){
          setState(() {
            element.orderNumber = o.orderNumber;
            element.isSyncedOnServer = o.isSyncedOnServer;
            element.isSyncOnServerProcessing = o.isSyncOnServerProcessing;
          });
        }
      });

    });*/

    /*for(int i=0;i<widget.orders.length;i++){
      for(int j=0;j<widget.orders[i].foodItems.length;j++){
        print( widget.orders[i].foodItems[j].toJsonForOrder());
        FoodItemsDao().getFoodItemByServerId(widget.orders[i].foodItems[j].serverId!).then((value){
          setState(() {
            widget.orders[i].foodItems[j].id = value!.id;
          });
        });
      }
    }*/ //commented for now
  }

  @override
  void dispose() {
    super.dispose();
    FBroadcast.instance().unregister(this);
  }
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
      child: ListView.builder(
        itemCount:widget.orders.length,
        itemBuilder: (context, index) {
          String orderName = "";
           if(widget.orders[index]!=null&&widget.orders[index].orderType == ConstantOrderType.ORDER_TYPE_DELIVERY){
             orderName = widget.orders[index].customer!=null?widget.orders[index].customer!.firstName+" "+widget.orders[index].customer!.lastName:"";
             /*if(widget.orders[index].customer!=null && widget.orders[index].customer!.contactAddressList.length>1 &&widget.orders[index].customer!.contactAddressList[0].name!=null){
               orderName = orderName + " / " + widget.orders[index].customer!.contactAddressList[0].name;
             }*/
             if(widget.orders[index].customer!=null && widget.orders[index].customer!.contactAddressList.length>0&&widget.orders[index].customer!.contactAddressList[0].companyModel!=null){
               orderName = orderName + " / " + widget.orders[index].customer!.contactAddressList[0].companyModel!.name;
             }
           }
           else if(widget.orders[index].orderType == ConstantOrderType.ORDER_TYPE_RESTAURANT){
             if(widget.orders[index].orderName!=null)
              orderName = widget.orders[index].orderName;
           }
          return GestureDetector(
            onHorizontalDragEnd: (details) {
              var left=details.velocity.toString().split(",")[0].split("(")[1];
              var right=details.velocity.toString().split(",")[1].split(")")[0];
              double leftInt = double.parse(left);
              double rightInt = double.parse(right);
          if(leftInt<rightInt)
              setState(() {
                showDialog(context: context,
                    builder: (BuildContext context) {
                      return OrderOptionMenues(orderModel: widget.orders[index],
                          onSelect: (action) async {
                            //var orderServiceID =  widget.orderType==ConstantOrderType.ORDER_TYPE_DELIVERY?ConstantCurrentOrderService.DELIVER_ORDER_TYPE:ConstantCurrentOrderService.RESTAURANT_ORDER_TYPE_EAT_IN;
                            if (action ==
                                OrderOptionMenuesAction
                                    .ACTION_EDIT) {
                              if(widget.orders[index].orderType == ConstantOrderType.ORDER_TYPE_DELIVERY){
                                await Navigator.of(context).push(
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            ContactList(existingOrder: widget.orders[index],)));
                              }
                              else {
                                await Navigator.of(context).push(
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            OrderTakingWindow(
                                                widget.orders[index].orderType,
                                                widget.orders[index]
                                                    .orderService,
                                                existingOrder: widget
                                                    .orders[index],
                                                isEditOrder: true,
                                              callBack: (String on){
                                                  setState(() {
                                                    //widget.orderNumber=int.parse(on);
                                                  });
                                                  // getOrderList();
                                                  },
                                            )));
                              }
                              widget.reloadOrders();
                            }
                            else if (action ==
                                OrderOptionMenuesAction.ACTION_COMMENT) {
                              showDialog(
                                  context: context, builder: (BuildContext
                              context) {
                                return InputPopup(
                                  title: "",
                                  inputBoxHint: "comment:",
                                  inputBoxDefaultValue: widget.orders[index]
                                      .comment,
                                  titleImagePath: AppImages.commentWhiteIcon,
                                  positiveButtonText: "add",
                                  negativeButtonText: "cancel",
                                  inputBoxMinLines: 2,
                                  inputBoxMaxLines: 2,
                                  titleImageBackgroundColor: AppTheme
                                      .colorGreen,
                                  positiveButtonPressed: (
                                      Map inputPopupResult) async {
                                    var comment = inputPopupResult[InputPopup
                                        .components.INPUT_TEXT];
                                    widget.orders[index].comment = comment;
                                    await OrderDao().updateOrder(
                                        widget.orders[index]);
                                    widget.reloadOrders();
                                    OrderApis.addCommentToOrder(widget.orders[index].serverId!, comment);
                                  },
                                );
                              });
                            }
                            else if (action ==
                                OrderOptionMenuesAction.ACTION_GROUP) {
                              await Navigator.of(context).push(
                                  MaterialPageRoute(builder: (context) =>
                                      RestaurantGroupOrder(primaryOrder:
                                      widget.orders[index],)));

                              widget.reloadOrders();
                            }
                            else if (action ==
                                OrderOptionMenuesAction.ACTION_TABLE_NUMBER) {
                              // code for table  number
                              //_saveOrderTable(widget.orders[index]);
                              showDialog(
                                  context: context, builder: (BuildContext
                              context) {
                                //return Comment(flag:"OrderedList");
                                return InputPopup(
                                  title: "table",
                                  inputBoxHint: "enterTableNumber:",
                                  inputBoxDefaultValue: widget.orders[index]
                                      .tableNumber,
                                  titleImagePath: AppImages.dinnerTableIcon,
                                  positiveButtonText: "add",
                                  negativeButtonText: "cancel",
                                  inputBoxMinLines: 1,
                                  inputBoxMaxLines: 1,
                                  textInputType: TextInputType.number,
                                  titleImageBackgroundColor: AppTheme.colorRed,
                                  positiveButtonPressed: (
                                      Map inputPopupResult) async {
                                    var tableNumber = inputPopupResult[InputPopup
                                        .components.INPUT_TEXT];
                                    widget.orders[index].tableNumber =
                                        tableNumber;
                                    await OrderDao().updateOrder(
                                        widget.orders[index]);
                                    widget.reloadOrders();
                                  },
                                );
                              });
                            }
                            else if (action == OrderOptionMenuesAction
                                .ACTION_ASSIGN_DELIVERYBOY) {
                              await Navigator.of(context).push(
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          UserList(ConstantUserRole.USER_ROLE_DELIVERY_BOY, assign:true, orderToBeAssigned:widget.orders[index])));

                            }
                            else if (action ==
                                OrderOptionMenuesAction.ACTION_PRINT) {
                                Utility().printTicket(widget.orders[index]);
                            }
                            else if (action == OrderOptionMenuesAction
                                .ACTION_DELETE) {
                              showDialog(context: context,
                                  builder: (BuildContext
                                  context) {
                                    //return DeleteOrder(id: widget.id);

                                    return ConfirmationPopup(
                                      title: "confirmation",
                                      subTitle: "areYouSureYouWantToDelete",
                                      titleImagePath: AppImages.deleteWhiteIcon,
                                      titleImageBackgroundColor: AppTheme.colorRed,
                                      positiveButtonText: "delete",
                                      negativeButtonText: "cancel",
                                      positiveButtonPressed: () async {
                                        await OrderDao().delete(
                                            widget.orders[index]);

                                        OrderApis.deleteOrder(widget.orders[index].serverId);

                                        widget.reloadOrders();
                                      },
                                    );
                                  });
                            }
                          });
                    });
              });
            },
            child: Card(
                color: Colors.white,
                surfaceTintColor: Colors.transparent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(
                      10), // <-- Radius
                ),
                child: Container(
                    child: Row(
                        children: <Widget>[
                          Container(
                            decoration: const BoxDecoration(
                                color: AppTheme.colorGrey,
                                borderRadius: BorderRadius
                                    .horizontal(left:
                                Radius.circular(10))),
                            width: 70,
                            height: 96,
                            alignment: Alignment.center,
                            /*child: Text(
                              "${widget.orders[index].orderNumber}",
                              style: const TextStyle(fontSize: 20,
                                  color: Color(0xffdb1e24),
                                  fontWeight: FontWeight.bold),
                              textAlign: TextAlign.left,),*/
                            child: Stack(
                              fit: StackFit.expand,
                              children: [
                                Center(
                                  child: Text(
                                    // widget.orders[index].id==widget.orderId && widget.orderNumber==-1 && widget.orders[index].orderNumber==0?"":
                                    // widget.orders[index].id==widget.orderId && widget.orderNumber>0 && widget.orders[index].orderNumber==0?
                                    // widget.orderNumber.toString():widget.orders[index].orderNumber>0?widget.orders[index].orderNumber.toString():"",
                                    // ordersList[index].orderNumber.toString(),
                                    //widget.orders[index].id==widget.orderId && widget.orderNumber==-1 && widget.orders[index].orderNumber==0?"":
                                    //widget.orders[index].id==widget.orderId && widget.orderNumber>0 && widget.orders[index].orderNumber==0?
                                    //widget.orderNumber.toString():widget.orders[index].orderNumber>0?widget.orders[index].orderNumber.toString():"",
                                    widget.orders[index].orderNumber>0?(widget.orders[index].orderNumber.toString()):"",
                                    style: const TextStyle(fontSize: 20,
                                        color: Color(0xffdb1e24),
                                        fontWeight: FontWeight.bold),
                                    textAlign: TextAlign.center,),
                                ),
                                // Text("===========${widget.orders[index].attachedOrders}"),
                                if(widget.orders[index].attachedBy!=0||widget.orders[index].attachedOrders.length>0)...[
                                  Positioned(
                                      bottom: 0,
                                      right: 0,
                                      child:
                                      Container(
                                        height: 21,
                                        //width: 20,
                                        padding: EdgeInsets.only(left: 5,right: 5,top: 3,bottom: 3),
                                        color: AppTheme.colorGreen,
                                        child: 
                                        widget.orders[index].attachedOrders.length>0?
                                        SvgPicture.asset(AppImages.groupWhiteIcon, height: 10, color: Colors.white):
                                        //Text(widget.orders[index].attachedBy.toString(),style: TextStyle(color: Colors.white),)
                                        //Text(Utility().getOrderFromListByID(widget.orders, widget.orders[index].attachedBy).orderNumber.toString(),style: TextStyle(color: Colors.white),)
                                        Center(child:
                                          Padding(
                                            padding: EdgeInsets.only(right: 2,left: 2),
                                            child: Text("${Utility().getOrderFromListByID(widget.orders, widget.orders[index].attachedBy).orderNumber.toString()}",style: TextStyle(color: Colors.white,fontSize: 12),),),
                                          )

                                      )
                                  ),
                                ]
                              ],
                            ),
                          ),
                          Container(
                            width: 70,
                            height: 96,
                            //color: widget.orders[index].isSyncedOnServer==false&&widget.orders[index].isSyncOnServerProcessing==false?AppTheme.colorRed:AppTheme.colorLightGrey,
                            color: widget.orders[index].isSyncedOnServer==false&&widget.orders[index].isSyncOnServerProcessing==false?AppTheme.colorRed:
                              widget.orders[index].isPrepared?AppTheme.colorGreen:AppTheme.colorLightGrey,
                            alignment: Alignment.center,
                            child:
                            widget.orders[index].orderType !=
                                ConstantOrderType.ORDER_TYPE_DELIVERY ?
                            Text(
                                widget.orders[index].createdAt.toString().contains('T')?widget.orders[index].createdAt.split(
                                  "T")[1].substring(
                                  0, 5):widget.orders[index].createdAt.split(
                                  " ")[1].split(".")[0].substring(
                                  0, 5)
                            , style: TextStyle(
                                fontSize: 18,
                                //color: widget.orders[index].isSyncedOnServer==true || (widget.orders[index].id==widget.orderId && (widget.orderNumber>0 || widget.orderNumber==-1))?
                                color: widget.orders[index].isSyncedOnServer==false&&widget.orders[index].isSyncOnServerProcessing==false?
                                Colors.white : Color(0xff282828),
                                fontWeight: FontWeight.bold),): Text(
                              //widget.orders[index].deliveryInfoModel.deliveryTime!=null?widget.orders[index].deliveryInfoModel!
                              widget.orders[index].deliveryInfoModel!=null?widget.orders[index].deliveryInfoModel!
                                  .deliveryTime.split(":")[0]+":"+widget.orders[index].deliveryInfoModel!
                                  .deliveryTime.split(":")[1]:"", style: TextStyle(
                                fontSize: 18,
                                //color: widget.orders[index].isSyncedOnServer==true || (widget.orders[index].id==widget.orderId && (widget.orderNumber>0 || widget.orderNumber==-1))?
                                color: widget.orders[index].isSyncedOnServer==false&&widget.orders[index].isSyncOnServerProcessing==false?
                                //Color(0xff282828): Colors.white,
                                Colors.white : Color(0xff282828),
                                fontWeight: FontWeight.bold),),
                          ),
                          Expanded(
                            child: InkWell(
                              onTap: () {
                                //UserDao().getUserByServerIntId(widget.orders[index].managerId).then((value){
                                /*UserDao().getUserByServerIntId(widget.orders[index].manager.intServerId).then((value){
                                  showDialog(context: context,
                                      builder: (BuildContext context) {
                                        return PreviewOrderList(
                                            widget.orders[index], name:value!.name);
                                      });
                                });*/
                                showDialog(context: context,
                                    builder: (BuildContext context) {
                                      return PreviewOrderList(
                                          widget.orders[index], name:widget.orders[index].manager.name);
                                    });
                              },
                              child: Column(
                                children: [
                                  Padding(padding: EdgeInsets.only(right: 5,),
                                    child: orderName != "" && orderName!=null? Transform.translate(
                                        offset: const Offset(4, 1),
                                        child: Container(
                                          alignment: Alignment
                                              .bottomLeft,
                                          child: Text("${
                                              orderName
                                                  .toUpperCase()}",
                                            textAlign: TextAlign
                                            //.end,
                                                .start,
                                            style: const TextStyle(
                                                fontWeight: FontWeight
                                                    .bold,
                                                fontSize: 11,
                                                color: Color(
                                                    0xffdb1e24)),),
                                        )

                                    ) : Transform.translate(offset: Offset(0, 0)),
                                  ),


                                  Transform.translate(
                                    offset: orderName == ""
                                        ? Offset(0, -2)
                                        : Offset(0, 0),
                                    child: Container(
                                        width: MediaQuery
                                            .of(context)
                                            .size
                                            .width * 0.5,
                                        height: orderName == "" ? 80 : 70,
                                        child: ListView.builder(
                                          itemCount: widget.orders[index]
                                              .foodItems.length,
                                          itemBuilder: (context,
                                              indexItem) {
                                            return showFoodItemsWithAttributes(index,indexItem);
                                          },
                                        )
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets
                                        .fromLTRB(8, 0, 0, 0),
                                    child: Row(
                                      children: [
                                        SvgPicture.asset(
                                            AppImages.managerIcon,
                                            height: 11,
                                            color: const Color(
                                                0xffa2a2a2)),
                                        Padding(
                                          padding: EdgeInsets
                                              .fromLTRB(
                                              4, 0, 0, 0),
                                          child: Text("manager".tr(),
                                            style: TextStyle(
                                                fontSize: 11,
                                                color: Color(
                                                    0xffa2a2a2)),),),
                                      ],
                                    ),
                                  )
                                ],
                              ),
                            ),
                          ),
                          InkWell(
                            onTap: () {
                              //widget.orderNumber=0;
                              if (widget.selectedIndex == 0) {
                                showDialog(context: context,
                                    builder: (BuildContext context) {
                                      return ConfirmationPopup(
                                          title: "service",
                                          subTitle: "eatInOrToTakeAway",
                                          titleImagePath: AppImages.phoneWithHandIcon,
                                          titleImageBackgroundColor: AppTheme.colorRed,
                                          positiveButtonText: "eatIn",
                                          negativeButtonText: "takeAway",
                                          isPositiveButtonHighlighted: widget
                                              .orders[index].orderService ==
                                              ConstantRestaurantOrderType
                                                  .RESTAURANT_ORDER_TYPE_EAT_IN
                                              ? true
                                              : false,
                                          isNegativeButtonHighlighted: widget
                                              .orders[index].orderService ==
                                              ConstantRestaurantOrderType
                                                  .RESTAURANT_ORDER_TYPE_TAKEAWAY
                                              ? true
                                              : false,
                                          positiveButtonPressed: () async {
                                            widget.orders[index].orderService =
                                                ConstantRestaurantOrderType
                                                    .RESTAURANT_ORDER_TYPE_EAT_IN;
                                            await OrderDao().updateOrder(
                                                widget.orders[index]);
                                            widget.reloadOrders();
                                            OrderApis.saveOrderToSever(widget.orders[index],isUpdate:true, oncall: (){

                                            });
                                          },
                                          negativeButtonPressed: () async {
                                            widget.orders[index].orderService =
                                                ConstantRestaurantOrderType
                                                    .RESTAURANT_ORDER_TYPE_TAKEAWAY;
                                            await OrderDao().updateOrder(
                                                widget.orders[index]);
                                            widget.reloadOrders();
                                            OrderApis.saveOrderToSever(widget.orders[index],isUpdate:true, oncall: (){

                                            });
                                          }
                                        // order:snapshot.data![index]
                                      );
                                    });
                              }
                            },
                            //child: widget.selectedIndex == 0 ? Container(
                            child: widget.orders[index].orderType == ConstantOrderType.ORDER_TYPE_RESTAURANT ? Container(
                                decoration: const BoxDecoration(
                                    color: Color(0xffdb1e24),
                                    borderRadius: BorderRadius
                                        .horizontal(right:
                                    Radius.circular(10))),
                                width: 30,
                                height: 96,
                                alignment: Alignment.center,
                                child:
                                Column(
                                  children: [
                                    //widget.orders[index].orderServiceId==1?Padding(
                                    widget.orders[index].orderService ==
                                        ConstantRestaurantOrderType
                                            .RESTAURANT_ORDER_TYPE_EAT_IN
                                        ? Padding(
                                      padding: const EdgeInsets.fromLTRB(
                                          0, 35, 0, 0),
                                      child: SvgPicture.asset(
                                          AppImages.dinnerTableIcon,
                                          height: 20,
                                          color: Colors.white),
                                    )
                                        : Padding(
                                      padding: const EdgeInsets.fromLTRB(
                                          0, 35, 0, 0),
                                      child: SvgPicture.asset(
                                          AppImages.takeawayIcon,
                                          height: 20,
                                          color: Colors.white),
                                    ),
                                    widget.orders[index].orderService ==
                                        ConstantRestaurantOrderType
                                            .RESTAURANT_ORDER_TYPE_EAT_IN ?
                                    Text(
                                      widget.orders[index].tableNumber==null?"":
                                      widget.orders[index].tableNumber
                                        .toString(), style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold),) : Text(
                                        "")
                                    // Commented for now
                                    //Text("N/A") // Above replacement for now
                                  ],
                                )
                              // SvgPicture.asset(AppImages.takeawayIcon, height: 20, color: Colors.white),
                            ) : Container(
                                decoration: const BoxDecoration(
                                    color: Color(0xffdb1e24),
                                    borderRadius: BorderRadius
                                        .horizontal(right:
                                    Radius.circular(10))),
                                width: 30,
                                height: 96,
                                alignment: Alignment.center,
                                child:
                                SvgPicture.asset(
                                    AppImages.scooterIcon,
                                    height: 20,
                                    color: Colors.white)
                              // SvgPicture.asset(AppImages.takeawayIcon, height: 20, color: Colors.white),
                            ),
                          )

                        ]
                    )
                )
            ),
          );
        }


      ),
    );
  }
  //late Future<List<Order>> orderList;
  late Future<List<OrderModel>> orderList;
  Future<List<OrderModel>> getOrderList() async {
    //Order order = Order.empty();
    //Order singleOrder = Order.empty();
    setState(() {
      //orderList = order.getOrderList();
      orderList = OrderDao().getAllOrders(selectedStatus: widget.orderType);
    });
    return orderList;
  }

  Widget showFoodItemsWithAttributes(int index,int indexItem){
    return Column(
        children: [
          Padding(
            padding: EdgeInsets.only(left: 4),
            child: Row(
              children: [
                Expanded(
                  flex:4,
                  child:
                Text(
                  widget.orders[index].foodItems[indexItem].name!=null?widget.orders[index].foodItems[indexItem].name!:
                  "",
                  style: const TextStyle(
                      color: Color(
                          0xff282828),
                      fontSize: 11,
                      fontWeight: FontWeight
                          .bold),),
                ),

                Expanded(
                    flex: 1,
                    child:
                    Text(
                      "x${widget
                          .orders[index]
                          .foodItems[indexItem]
                          .quantity}",
                      textAlign: TextAlign
                          .end,
                      style: const TextStyle(
                          color: Color(
                              0xffdb1e24)),),
                )
              ],
            ),

          ),
          if(widget.orders[index].foodItems[indexItem].selectedAttributes!=null && widget.orders[index].foodItems[indexItem].selectedAttributes.length>0)
            ...[
            Padding(padding: EdgeInsets.only(left: 4),
              child: Row(
                children: [


                  SvgPicture
                      .asset(
                      AppImages
                          .turnRightIcon,
                      height: 8,
                      color: const Color(
                          0xffa2a2a2)),
                  widget.orders[index].foodItems[indexItem].selectedAttributes.isNotEmpty?Expanded(
                    child: Padding(
                      padding: const EdgeInsets
                          .fromLTRB(3, 0, 0, 0),
                      child:
                      // Text("Spicy Sauce, Potatoas, Fanta", style: TextStyle(fontSize: 9,fontStyle: FontStyle.italic, color: Color(0xffa2a2a2)),),
                      Wrap(
                        /*children: [
                          Container(child: Text("Lengthhhhhhhhhhhhhhhhhhhhhhhhhhh${widget.orders.length}"),)
                        ]*/
                         children : List.generate(
                           widget.orders[index].foodItems[indexItem].selectedAttributes
                               .length,
                               (
                               indexAtt) {
                             return widget.orders[index].foodItems[indexItem].selectedAttributes.isNotEmpty &&
                                 widget.orders[index].foodItems[indexItem].selectedAttributes[indexAtt]!=null
                                 ? Text(
                                        (widget.orders[index].foodItems[indexItem].selectedAttributes[indexAtt].quantity>1?
                                        widget.orders[index].foodItems[indexItem].selectedAttributes[indexAtt].quantity.toString()+"x"
                                        :"") +
                                    widget.orders[index].foodItems[indexItem].selectedAttributes[indexAtt]
                                   .name.toString() +
                                   (indexAtt==widget.orders[index].foodItems[indexItem].selectedAttributes
                                   .length-1?"":", "),
                               style: const TextStyle(
                                   fontSize: 9,
                                   fontStyle: FontStyle
                                       .italic,
                                   color: Color(
                                       0xffa2a2a2)),)
                                 : const Text(
                                 "");
                           },
                         ),

                      ),
                      // Text("Spicy Sauce, Potatoas, Fanta",
                      //   style: TextStyle(fontSize: 9,
                      //       fontStyle: FontStyle.italic,
                      //       color: Color(0xffa2a2a2)),),
                    ),
                  ):Transform.translate(offset: const Offset(0,-35),),
                ],
              ),

            )
          ]
        ]
    );

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
                      child: widget
                          .orders[index]
                          .foodItems[indexItem] !=
                          null
                          ? Transform
                          .translate(
                        offset: const Offset(
                            0, 0),
                        child: Text(
                          widget
                              .orders[index]
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
                      "x${widget
                          .orders[index]
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
        Transform.translate(
          offset:indexItem>0?Offset(0,-7):Offset(
              0, -3),
          child: Padding(
            padding: const EdgeInsets
                .fromLTRB(
                4, 0, 0, 0),
            child: Row(
              children: [
                /*widget.orders[index]
                                                              .orderedItems[indexItem]
                                                              .orderedItemAttribute
                                                              .isNotEmpty*/
                widget.orders[index].foodItems[indexItem].selectedAttributes.isNotEmpty
                    ? Transform.translate(
                  offset:Offset(0,-2),
                  child: SvgPicture
                      .asset(
                      AppImages
                          .turnRightIcon,
                      height: 8,
                      color: const Color(
                          0xffa2a2a2)),
                )
                    :Transform.translate(offset: Offset(0,-35),) ,
                widget.orders[index].foodItems[indexItem].selectedAttributes.isNotEmpty?Expanded(
                  child: Padding(
                    padding: const EdgeInsets
                        .fromLTRB(3, 0, 0, 0),
                    child:
                    // Text("Spicy Sauce, Potatoas, Fanta", style: TextStyle(fontSize: 9,fontStyle: FontStyle.italic, color: Color(0xffa2a2a2)),),
                    Wrap(
                      children: List
                          .generate(
                        widget.orders[index].foodItems[indexItem].selectedAttributes
                            .length,
                            (
                            indexAtt) {
                          return widget.orders[index].foodItems[indexItem].selectedAttributes.isNotEmpty &&
                              widget.orders[index].foodItems[indexItem].selectedAttributes[indexAtt]!=null
                              ? Text(
                            "${widget.orders[index].foodItems[indexItem].selectedAttributes[indexAtt]
                                .name
                            }, ",
                            style: const TextStyle(
                                fontSize: 9,
                                fontStyle: FontStyle
                                    .italic,
                                color: Color(
                                    0xffa2a2a2)),)
                              : const Text(
                              "");
                        },
                      ),

                    ),
                    // Text("Spicy Sauce, Potatoas, Fanta",
                    //   style: TextStyle(fontSize: 9,
                    //       fontStyle: FontStyle.italic,
                    //       color: Color(0xffa2a2a2)),),
                  ),
                ):Transform.translate(offset: const Offset(0,-35),),
              ],
            ),
          ),
        ),
        //attributes commented for now
      ],
    );

  }

  checkForOpeningTime() async {
    DateTime openingTime=DateTime.now();
    RestaurantInfoDao().getRestaurantInfo().then((value) {
      String hour;
      String minutes;
        if (value!=null&&value.startTime != null&&value.startTime!='') {
          hour = value.startTime.substring(0, 2);
          minutes = value.startTime.substring(3, 5);
          openingTime;
          var newDateTime = openingTime.toLocal();
          openingTime = new DateTime(newDateTime.year, newDateTime.month, newDateTime.day, int.parse(hour), int.parse(minutes), newDateTime.second, newDateTime.millisecond, newDateTime.microsecond);
        }
      });
    await OrderDao().getAllOrders().then((value) async {
      for(int i=0; i<value.length; i++){
        if(DateTime.parse(value[i].createdAt).isBefore(openingTime) && openingTime.isBefore(DateTime.now())) {
          await OrderDao().removeOrder(value[i]);
        }
      }
    });

  }
}
