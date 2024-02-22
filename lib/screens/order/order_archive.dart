import 'package:dio/dio.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:opti_food_app/api/order_apis.dart';
import 'package:opti_food_app/assets/images.dart';
import 'package:opti_food_app/data_models/delivery_info_model.dart';
import 'package:opti_food_app/data_models/food_items_model.dart';
import 'package:opti_food_app/database/food_items_dao.dart';
import 'package:opti_food_app/screens/order/preview_order_list.dart';
import 'package:opti_food_app/utils/constants.dart';
import 'package:opti_food_app/widgets/custom_drop_down.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../data_models/order_model.dart';
import '../../data_models/restaurant_info_model.dart';
import '../../database/order_dao.dart';
import '../../database/restaurant_info_dao.dart';
import '../../main.dart';
import '../../utils/app_config.dart';
import '../../utils/utility.dart';
import '../../widgets/app_theme.dart';
import '../../widgets/appbar/app_bar_optifood.dart';
import '../../widgets/appbar/navigation_bar_optifood.dart';
import '../../widgets/datetime_form_field.dart';
import '../../widgets/option_menu/order/order_archive_option_menu_popup.dart';
import '../../widgets/popup/filter_popup/filter_popup.dart';
import '../MountedState.dart';
class OrderArchive extends StatefulWidget{
  TextEditingController selectedDateController = TextEditingController();
  @override
  State<StatefulWidget> createState() => _OrderArchiveState();
}
class _OrderArchiveState extends MountedState<OrderArchive>{
  String? selectedDate = DateFormat("dd/MM/yyyy").format(DateTime.now());
  bool isFilterSelectedDelivery = true;
  bool isFilterSelectedEatIn = true;
  bool isFilterSelectedTakeaway = true;
  String selectedOrderStatus = "all";
  List<String> orderStatusList
  = ["all","inProgress","delayed","completed","cancelled","delivered"];
  late Future<List<OrderModel>> orderList;
  List<String> filter = [];
  Future<List<OrderModel>> getOrderList() async {
    String? sDate = null;
    filter = [];
    setState(() {
      if(isFilterSelectedTakeaway){
        filter.add(ConstantRestaurantOrderType.RESTAURANT_ORDER_TYPE_TAKEAWAY);
      }
      if(isFilterSelectedEatIn){
        filter.add(ConstantRestaurantOrderType.RESTAURANT_ORDER_TYPE_EAT_IN);
      }
      if(isFilterSelectedDelivery){
        filter.add(ConstantOrderType.ORDER_TYPE_DELIVERY);
      }
      //orderList = OrderDao().getAllOrders(orderTypeFilterList: filter,selectedStatus: selectedOrderStatus);
      if(widget.selectedDateController.text!=null&&widget.selectedDateController.text.isNotEmpty) {
        List<String> dateArr = widget.selectedDateController.text.split("/");
        sDate = dateArr[2] + "-" + dateArr[1] + "-" + dateArr[0];
      }

      orderList = OrderDao().getOrderArchive(filter,selectedStatus: selectedOrderStatus,selectedDate: sDate);
      OrderDao().getOrderArchive(filter,selectedStatus: selectedOrderStatus,selectedDate: sDate).then((value) {

      });

    });

    return orderList;
  }
  late SharedPreferences sharedPreferences;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getOrderList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarOptifood(),
      body: Container(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(3, 0, 3, 0),
            child: Column(
                children: [
                  FilterPopup(
                    isFilterActivated: false,
                    child: Container(
                        padding: const EdgeInsets.only(top: 22,bottom: 35),
                        margin: EdgeInsets.only(bottom: 10),
                        width: double.infinity,
                        decoration: const BoxDecoration(
                          color: Colors.white70,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black12,
                              spreadRadius: 2,
                              blurRadius: 5,
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            ListTile(
                              dense: true,
                              contentPadding: EdgeInsets.only(left: 5,right: 20),
                              trailing:
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Radio(
                                    value: true,
                                    groupValue: isFilterSelectedDelivery,
                                    toggleable: true,
                                    onChanged: (Object? value){
                                      setState(() {
                                        if(isFilterSelectedDelivery){
                                          isFilterSelectedDelivery = false;
                                        }
                                        else{
                                          isFilterSelectedDelivery = true;
                                        }
                                        setState(() {
                                          orderList=getOrderList();

                                        });
                                      });
                                    },
                                    activeColor: AppTheme.colorRed,),
                                  SvgPicture.asset(AppImages.scooterIcon,height: 35,color: AppTheme.colorBlack,),

                                ],
                              ),
                              leading:
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Radio(
                                    value: true,
                                    groupValue: isFilterSelectedEatIn,
                                    toggleable: true,
                                    onChanged: (Object? value){
                                      setState(() {
                                        if(isFilterSelectedEatIn){
                                          isFilterSelectedEatIn = false;
                                        }
                                        else{
                                          isFilterSelectedEatIn = true;
                                        }
                                        getOrderList();
                                      });
                                    },
                                    activeColor: AppTheme.colorRed,),
                                  SvgPicture.asset(AppImages.dinnerTableIcon,height: 35,color: AppTheme.colorBlack,),
                                ],
                              ),
                              title:
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Radio(
                                    value: true,
                                    groupValue: isFilterSelectedTakeaway,
                                    toggleable: true,
                                    onChanged: (Object? value){
                                      setState(() {
                                        if(isFilterSelectedTakeaway){
                                          isFilterSelectedTakeaway = false;
                                        }
                                        else{
                                          isFilterSelectedTakeaway = true;
                                        }
                                        orderList=getOrderList();
                                      });
                                    },
                                    activeColor: AppTheme.colorRed,),
                                  SvgPicture.asset(AppImages.takeawayIcon,height: 30,color: AppTheme.colorBlack,),
                                ],
                              ),
                            ),
                            DateTimeFormField(
                              dateTimeController: widget.selectedDateController,
                              initialDate: DateTime.now(),
                              //firstDate: DateTime.now(),
                              firstDate: DateTime(2000),
                              lastDate: 2100,
                              initialTime: TimeOfDay.now(),
                              isKeepSpaceForOuterIcon: false,
                              //selectDate: DateFormat("dd/MM/yyyy").format(DateTime.now()),
                              selectDate: selectedDate!=null?selectedDate:DateFormat("dd/MM/yyyy").format(DateTime.now()),
                              showTimePicker: false,
                              endDateTime: widget.selectedDateController,
                              startDateTime: widget.selectedDateController,
                              outerIcon: SvgPicture.asset(AppImages.calendarIcon, height: 35,),
                              onDateSelected: (date){
                                setState(() {

                                  selectedDate = widget.selectedDateController.text;
                                  if(selectedDate!=null)
                                    orderList= getOrderListFromAPI(date);
                                  else
                                    getOrderList();

                                });
                              },
                            ),
                            //Padding(padding: EdgeInsets.only(right: 5),
                            //child:
                            CustomDropDown(
                              dropDownItems: orderStatusList,
                              selectedItem: selectedOrderStatus,
                              outerIcon: SvgPicture.asset(AppImages.statusFilter, height: 35,),
                              onItemChange: (String selected){
                                setState((){

                                  print("============================================");
                                  selectedOrderStatus = selected;
                                  // if(selectedDate==null)
                                    getOrderList();
                                  // else
                                  //   orderList = getOrderListFromAPI(selectedDate);
                                });
                              },
                            ),
                            //)
                          ],
                        )
                    ),
                  ),

                  Expanded(
                    child: RefreshIndicator(
                      onRefresh: getOrderList,
                      child: FutureBuilder<List<OrderModel>>(
                        //future: orderList,
                          future: orderList,
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
                                      )
                                  );
                                }
                                else
                                {
                                  return ListView.builder(
                                    itemCount: snapshot.data!.length,
                                    itemBuilder: (context, index) {
                                      String orderName = "";
                                      if(snapshot.data![index]!=null&&snapshot.data![index].orderType == ConstantOrderType.ORDER_TYPE_DELIVERY){
                                        orderName = snapshot.data![index].customer!=null?snapshot.data![index].customer!.firstName+" "+snapshot.data![index].customer!.lastName:"";
                                        if(snapshot.data![index].customer!=null && snapshot.data![index].customer!.contactAddressList.length>0 &&snapshot.data![index].customer!.contactAddressList[0].name!=null){
                                          orderName = orderName + " / " + snapshot.data![index].customer!.contactAddressList[0].name;
                                        }
                                      }
                                      else if(snapshot.data![index].orderType == ConstantOrderType.ORDER_TYPE_RESTAURANT){
                                        if(snapshot.data![index].orderName!=null)
                                          orderName = snapshot.data![index].orderName;
                                      }
                                      return GestureDetector(
                                        onHorizontalDragStart: (
                                            DragStartDetails details) {
                                          if (!(snapshot.data![index]
                                              .isDeleted)) {
                                            return;
                                          }
                                          setState(() {
                                            showDialog(context: context,
                                                builder: (
                                                    BuildContext context) {
                                                  //return OrderOptionMenues(
                                                  //  id: widget.orders[index].orderName);
                                                  return OrderArchiveOptionMenuPopup(
                                                      onSelect: (action) async {
                                                        //var orderServiceID =  widget.orderType==ConstantOrderType.ORDER_TYPE_DELIVERY?ConstantCurrentOrderService.DELIVER_ORDER_TYPE:ConstantCurrentOrderService.RESTAURANT_ORDER_TYPE_EAT_IN;
                                                        if (action ==
                                                            OrderArchiveOptionMenuPopup
                                                                .ACTIONS
                                                                .ACTION_RESTORE) {
                                                          await OrderDao()
                                                              .restore(snapshot
                                                              .data![index]);
                                                          setState(() {
                                                            getOrderList();
                                                          });
                                                          OrderApis
                                                              .restoreOrder(
                                                              snapshot
                                                                  .data![index]
                                                                  .serverId);
                                                        }
                                                      });
                                                });
                                          });
                                        },
                                        onTap: () {
                                          showDialog(context: context,
                                              builder: (BuildContext context) {
                                                return PreviewOrderList(
                                                    snapshot.data![index]);
                                              });
                                        },
                                        child: Container(
                                            child: Card(
                                              color: Colors.white,
                                              surfaceTintColor: Colors.transparent,
                                              shadowColor: Colors.white38,
                                              elevation: 4,
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius
                                                    .circular(10), // <-- Radius
                                              ),
                                              child: ListTile(
                                                  contentPadding: EdgeInsets
                                                      .only(left: 15,
                                                      right: 15,
                                                      top: 10,
                                                      bottom: 10),
                                                  dense: true,
                                                  leading:
                                                  Row(
                                                    mainAxisSize: MainAxisSize
                                                        .min,
                                                    children: [
                                                      Text(
                                                        "${snapshot.data![index]
                                                            .orderNumber != 0
                                                            ? snapshot
                                                            .data![index]
                                                            .orderNumber
                                                            : ""}",
                                                        style: const TextStyle(
                                                            fontSize: 20,
                                                            fontWeight: FontWeight
                                                                .bold),
                                                        textAlign: TextAlign
                                                            .center,),
                                                      Padding(
                                                        padding: EdgeInsets
                                                            .only(top: 5,
                                                            bottom: 5,
                                                            left: 5,
                                                            right: 5),
                                                        child: VerticalDivider(
                                                          color: Colors
                                                              .black54,),
                                                      ),
                                                      if(snapshot.data![index]
                                                          .orderType ==
                                                          ConstantOrderType
                                                              .ORDER_TYPE_DELIVERY) ...[
                                                        SvgPicture.asset(
                                                          AppImages.scooterIcon,
                                                          height: 35,),
                                                      ]
                                                      else
                                                        ...[
                                                          if(snapshot
                                                              .data![index]
                                                              .orderService ==
                                                              ConstantRestaurantOrderType
                                                                  .RESTAURANT_ORDER_TYPE_EAT_IN) ...[
                                                            SvgPicture.asset(
                                                              AppImages
                                                                  .dinnerTableIcon,
                                                              height: 35,),
                                                          ]
                                                          else
                                                            ...[
                                                              SvgPicture.asset(
                                                                AppImages
                                                                    .takeawayIcon,
                                                                height: 30,),
                                                            ]
                                                        ],
                                                      Padding(
                                                        padding: EdgeInsets
                                                            .only(top: 5,
                                                            bottom: 5,
                                                            left: 5),
                                                        child: VerticalDivider(
                                                          color: Colors
                                                              .black54,),
                                                      )
                                                    ],
                                                  ),
                                                  title:
                                                  Column(
                                                    crossAxisAlignment: CrossAxisAlignment
                                                        .start,
                                                    children: [
                                                      /*Text("Burger",
                                                      style: TextStyle(fontSize: 16),textAlign: TextAlign.start,),*/
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
                                                      /*Transform.translate(
                                                        offset: orderName == ""
                                                            ? Offset(0, -2)
                                                            : Offset(0, 0),
                                                        child: Container(
                                                            width: MediaQuery
                                                                .of(context)
                                                                .size
                                                                .width * 0.5,
                                                            height: orderName ==
                                                                "" ? 80 : 70,
                                                            child: ListView
                                                                .builder(
                                                              itemCount: snapshot
                                                                  .data![index]
                                                                  .foodItems
                                                                  .length,
                                                              itemBuilder: (
                                                                  context,
                                                                  indexItem) {
                                                                return showFoodItemsWithAttributes(
                                                                    snapshot
                                                                        .data![index],
                                                                    indexItem);
                                                              },
                                                            )
                                                        ),
                                                      ),*/
                                                      SizedBox(height: 10,),
                                                      Container(
                                                          child: Row(
                                                            children: [
                                                              Container(
                                                                  child:
                                                                  Row(
                                                                      children: [
                                                                        SvgPicture
                                                                            .asset(
                                                                          AppImages
                                                                              .euroSign,
                                                                          height: 14,),
                                                                        SizedBox(
                                                                          width: 5,),
                                                                        Text(
                                                                          "${Utility()
                                                                              .formatPrice(
                                                                              snapshot
                                                                                  .data![index]
                                                                                  .totalPrice)}",
                                                                          style: TextStyle(
                                                                              fontSize: 12,
                                                                              fontWeight: FontWeight
                                                                                  .bold),),
                                                                      ]
                                                                  )
                                                              ),
                                                              Container(
                                                                  padding: EdgeInsets
                                                                      .only(
                                                                      left: 5,
                                                                      right: 5),
                                                                  child:
                                                                  Container(
                                                                    width: 1,
                                                                    height: 12,
                                                                    color: AppTheme
                                                                        .colorGrey,
                                                                  )
                                                              ),
                                                              Container(
                                                                //child: Text("12:30",
                                                                  child: Row(
                                                                    children: [
                                                                      SvgPicture
                                                                          .asset(
                                                                        AppImages
                                                                            .timeIcon2,
                                                                        height: 14,),
                                                                      SizedBox(
                                                                        width: 5,),
                                                                      Text(
                                                                        snapshot
                                                                            .data![index]
                                                                            .orderType ==
                                                                            ConstantOrderType
                                                                                .ORDER_TYPE_DELIVERY
                                                                            ?
                                                                        snapshot
                                                                            .data![index]
                                                                            .deliveryInfoModel!
                                                                            .deliveryTime
                                                                            :
                                                                        snapshot
                                                                            .data![index]
                                                                            .createdAt
                                                                            .toString()
                                                                            .contains(
                                                                            'T')
                                                                            ?
                                                                        snapshot
                                                                            .data![index]
                                                                            .createdAt
                                                                            .split(
                                                                            "T")[1]
                                                                            .substring(
                                                                            0,
                                                                            5)
                                                                            :
                                                                        snapshot
                                                                            .data![index]
                                                                            .createdAt
                                                                            .split(
                                                                            " ")[1]
                                                                            .split(
                                                                            ".")[0]
                                                                            .substring(
                                                                            0,
                                                                            5),
                                                                        style: TextStyle(
                                                                            fontSize: 12,
                                                                            fontWeight: FontWeight
                                                                                .bold),)
                                                                          .tr(),
                                                                    ],
                                                                  )
                                                              ),
                                                            ],
                                                          )
                                                      ),
                                                    ],
                                                  ),
                                                  trailing:
                                                  //SvgPicture.asset(snapshot.data![index].isDeleted?AppImages.statusCancel:AppImages.statusInprogress,height: 35,color: snapshot.data![index].isDeleted?AppTheme.colorRed:AppTheme.colorGreen,)
                                                  Wrap(
                                                    children: [
                                                      //SvgPicture.asset(snapshot.data![index].isDeleted?AppImages.statusCancel:AppImages.statusInprogress,height: 35,color: snapshot.data![index].isDeleted?AppTheme.colorRed:AppTheme.colorGreen,)
                                                      if(snapshot.data![index]
                                                          .isDeleted) ...[
                                                        SvgPicture.asset(
                                                            AppImages
                                                                .statusCancel,
                                                            height: 35,
                                                            color: AppTheme
                                                                .colorRed)
                                                      ]
                                                      else
                                                        if(snapshot.data![index]
                                                            .isDelayedOrder) ...[
                                                          SvgPicture.asset(
                                                              AppImages
                                                                  .delayedOrderArchive,
                                                              height: 35,
                                                              color: AppTheme
                                                                  .colorOrange)
                                                        ]

                                                        else
                                                          if(snapshot
                                                              .data![index]
                                                              .isPrepared) ...[
                                                            SvgPicture.asset(
                                                                AppImages
                                                                    .checkMarks,
                                                                height: 35,
                                                                color: AppTheme
                                                                    .colorGreen)
                                                          ]
                                                          else
                                                            ...[
                                                              SvgPicture.asset(
                                                                  AppImages
                                                                      .statusInprogress,
                                                                  height: 35,
                                                                  color: AppTheme
                                                                      .colorGreen)
                                                            ]
                                                    ],
                                                  )
                                              ),
                                            )
                                        ),
                                      );
                                    }
                                  );
                                }
                              default:
                                return Center(
                                    child: Container(
                                      child: Text('somethingWentWrongTryAgain').tr(),
                                    )
                                );
                            }
                          }),
                    ),

                  ),
                ]
            ),
          ),
        ),
      ),
    );
  }
  Future<List<OrderModel>> getOrderListFromAPI(String? selectedDate) async {

    print("00000000000000000000000000000000000000000000000000000000000000000000000");
    List<String> filter1 = [];
    RestaurantInfoModel restaurantInfoModel = await RestaurantInfoDao().getRestaurantInfo();
    String startTime = restaurantInfoModel.startTime;
    String endTime = restaurantInfoModel.endTime;
    // List<String> dateTimeList = Utility().generateShiftTiming(
    //     startTime, endTime, selectedDate: selectedDate);

    var finalStartDate = "";
    var finalEndDate = "";
    final DateFormat formatter = DateFormat('yyyy-MM-dd');
    final dio = Dio();
    List<OrderModel> fetchedData = [];
    dio.options.headers['X-TenantID'] = optifoodSharedPrefrence.getString("database").toString();
    for(int i=0;i<filter.length;i++){
      if(filter[i]=="restaurant_order_type_takeaway"){
        filter1.add("takeaway");
      }
      else if(filter[i]=="restaurant_order_type_eat_in"){
        filter1.add("restaurant");
      }
      else{
        filter1.add("delivery");
      }
    }
    // if(selectedOrderStatus=='inProgress')
    //   selectedOrderStatus='Ordered';
    String? aa = selectedDate?.split("/")[2];
    String? bb = selectedDate?.split("/")[1];
    String? cc = selectedDate?.split("/")[0];
    String? date = aa! +"-"+ bb!+"-"+cc!;
    await dio.get(
        ServerData.OPTIFOOD_BASE_URL+"/api/order/archive", queryParameters: {
      "selectedDate": date,
      "startTime": startTime+":00",
      "endTime":endTime+":00",
      "status":selectedOrderStatus,
      "orderTypes":filter1,
      "dateTimeZone":AppConfig.dateTime.timeZoneOffset.inMinutes,
      "limit":10000000
    }).then((response) {
      setState(() {
        if (response.statusCode == 200) {

          for (int i = 0; i < response.data.length; i++) {
            print("==brhane=====================");

             var singleItem = OrderModel.fromJsonServer(response.data[i]);
             print("===========${singleItem.orderNumber}=============");
             fetchedData.add(singleItem);
          }
          // orderList = fetchedData as Future<List<OrderModel>>;

        }
      });
    }).catchError((onError){
      print("error");
    });
    print("======fetchedData.length=======${fetchedData.length}====================");
    return fetchedData;
  }

  //Widget showFoodItemsWithAttributes(int index,int indexItem){
  Widget showFoodItemsWithAttributes(OrderModel orderModel,int indexItem){
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
                    orderModel.foodItems[indexItem].name!=null?orderModel.foodItems[indexItem].name!:
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
                    "x${orderModel
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
          if(orderModel.foodItems[indexItem].selectedAttributes!=null && orderModel.foodItems[indexItem].selectedAttributes.length>0)
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
                    orderModel.foodItems[indexItem].selectedAttributes.isNotEmpty?Expanded(
                      child: Padding(
                        padding: const EdgeInsets
                            .fromLTRB(3, 0, 0, 0),
                        child:
                        // Text("Spicy Sauce, Potatoas, Fanta", style: TextStyle(fontSize: 9,fontStyle: FontStyle.italic, color: Color(0xffa2a2a2)),),
                        Wrap(
                          children : List.generate(
                            orderModel.foodItems[indexItem].selectedAttributes
                                .length,
                                (
                                indexAtt) {
                              return orderModel.foodItems[indexItem].selectedAttributes.isNotEmpty &&
                                  orderModel.foodItems[indexItem].selectedAttributes[indexAtt]!=null
                                  ? Text(
                                "${orderModel.foodItems[indexItem].selectedAttributes[indexAtt]
                                    .name.toString() +
                                    (indexAtt==orderModel.foodItems[indexItem].selectedAttributes
                                        .length-1?"":", ")
                                //}, ",
                                }",
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
  }

}