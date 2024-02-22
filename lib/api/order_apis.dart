

import 'package:dio/dio.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:fbroadcast/fbroadcast.dart';
import 'package:opti_food_app/api/delivery_fee.dart';
import 'package:opti_food_app/data_models/delivery_fee_model.dart';
import 'package:opti_food_app/database/delivery_fee_dao.dart';
import 'package:opti_food_app/utils/app_config.dart';

import '../data_models/delivery_info_model.dart';
import '../data_models/order_model.dart';
import '../data_models/restaurant_info_model.dart';
import '../data_models/server_sync_action_pending.dart';
import '../database/night_mode_fee_dao.dart';
import '../database/order_dao.dart';
import '../database/restaurant_info_dao.dart';
import '../main.dart';
import '../utils/constants.dart';
import '../utils/utility.dart';
import 'delivery_fee.dart';

class OrderApis {
  Function? callBack;
  OrderApis({this.callBack});
  static String OPTIFOOD_DATABASE=optifoodSharedPrefrence.getString("database").toString();
  static String authorization = optifoodSharedPrefrence.getString("accessToken").toString();
  Future<void> syncOrders() async {
    List<OrderModel> orderModelList = await OrderDao().getUnSyncedOrders();
    if(orderModelList.length>0){
      OrderModel orderModel = orderModelList.first;
      ServerSyncActionPending serverSyncActionPending = Utility().getServerSyncActionPending(orderModel.syncOnServerActionPending);
      if(serverSyncActionPending.isPendingCreate){
        saveOrderToSever(orderModel, oncall: (){
          syncOrders();
        });
      }
      else if(serverSyncActionPending.isPendingUpdate){
        saveOrderToSever(orderModel, oncall: (){
          syncOrders();
        },isUpdate: true);
      }
    }
  }

  void getOrderListFromServer({required Function localCallback}) async{
    RestaurantInfoDao().getRestaurantInfo().then((value) async {
      String startTime = value.startTime;
      if(startTime==null || startTime=="" || startTime==''){
        startTime = "00:00";
      }
      List<OrderModel> fetchedData = [];
      final dio = Dio();
      dio.options.headers['X-TenantID'] = OPTIFOOD_DATABASE;
      dio.options.headers['Authorization'] = authorization;
      await dio.get(ServerData.OPTIFOOD_BASE_URL+"/api/order",queryParameters: {
        "dateTimeZone": AppConfig.dateTime.timeZoneOffset.inMinutes,
        "startTime": startTime+":00",
        //"dateTimeZone": 330,
        //"startTime": "08:00:00",
        //"limit":10000000
      }).then((response) async {
        if(response.data.length==0)
          localCallback();
        localCallback();
        if (response.statusCode == 200 && response.data.length>0) {
          saveOrderDataFromServerToLocalDB(response.data, localCallback: (){
            // localCallback();
          });
        }
      }).onError((error, stackTrace){
        localCallback();
      });
    });

  }

  static saveOrderDataFromServerToLocalDB(var serverResponseModel, {bool push=false, required Function localCallback}) async{
    List<OrderModel> fetchedData = [];
    for (int i = 0; i < serverResponseModel.length; i++) {
      /*try{
        OrderModel.fromJsonServer(serverResponseModel[i]);
      }
      catch(er,de){
        print(de);
      }*/
      var singleItem = OrderModel.fromJsonServer(serverResponseModel[i]);
      /*if(serverResponseModel[i]['deleted']) {
        print("Now check for delete orderrrrrrrr ${serverResponseModel[i]['deleted']}");
        OrderDao().delete(singleItem).then((value) {
          if(push)
            FBroadcast.instance().broadcast(
                ConstantBroadcastKeys.KEY_ORDER_SENT, value: singleItem);
        });

      }
      else*/
      //print("First food item");
      //print(singleItem.foodItems.first.toJsonForOrder());
      if(singleItem.createdAt!=serverResponseModel[i]["shiftDateTime"]){
        if(singleItem.orderNumber == 0) {
          singleItem.isDelayedOrder = true;
        }
        else{
          singleItem.isDelayedOrder = false;
        }
        singleItem.createdAt = serverResponseModel[i]["shiftDateTime"];
      }
        fetchedData.add(singleItem);
    }

    if(fetchedData.length==0)
      localCallback();
    for(int i=0; i<fetchedData.length;i++){

      fetchedData[i].attachedOrders = fetchedData[i].attachedOrders.toSet().toList();

      if(fetchedData[i].deliveryInfoModel!.deliveryDate!=null) {
        fetchedData[i].deliveryInfoModel!.deliveryTime =
            fetchedData[i].deliveryInfoModel!.deliveryTime.split(":")[0] +":"+
                fetchedData[i].deliveryInfoModel!.deliveryTime.split(":")[1];

        fetchedData[i].deliveryInfoModel!.deliveryDate =
            fetchedData[i].deliveryInfoModel!.deliveryDate.split("-")[2]
                .substring(0, 2) + "/" +
                fetchedData[i].deliveryInfoModel!.deliveryDate.split(
                    "-")[1] + "/" +
                fetchedData[i].deliveryInfoModel!.deliveryDate.split("/")[0].substring(0,4);
      }
      else{
        fetchedData[i].deliveryInfoModel = DeliveryInfoModel(
            DateFormat("dd/MM/yyyy").format(DateTime.parse(fetchedData[i].createdAt)),
            DateFormat("kk:mm").format(DateTime.parse(fetchedData[i].createdAt)),
            0, "0.0", "0.0");
      }
      await OrderDao().getOrderByServerId(fetchedData[i].serverId!).then((value) async {
        var result=null;
        if(value.length>0) {
          var checker = value.where((element) =>
          element.serverId == fetchedData[i].serverId).toList();
          if(checker.length>0)
            result=checker[0];
        }
        if(result!=null){
          result?.serverId=fetchedData[i].serverId;
          result?.orderNumber=fetchedData[i].orderNumber;
          result?.orderName=fetchedData[i].orderName;
          result?.orderType=fetchedData[i].orderType;
          result?.orderService=fetchedData[i].orderService;
          result?.comment=fetchedData[i].comment;
          result?.totalPrice=fetchedData[i].totalPrice;
          result?.createdAt=fetchedData[i].createdAt;
          result?.createdBy=fetchedData[i].createdBy;
          result?.deliveryInfoModel=fetchedData[i].deliveryInfoModel;
          //result?.managerId=fetchedData[i].managerId;
          result?.foodItems=fetchedData[i].foodItems;
          result?.isSyncedOnServer=true;
          result?.serverId=fetchedData[i].serverId;
          result?.paymentMode=fetchedData[i].paymentMode;
          result?.isDeleted=fetchedData[i].isDeleted;
          result?.attachedOrders = fetchedData[i].attachedOrders;
          result?.attachedBy = fetchedData[i].attachedBy;


          result?.isDelayedOrder=fetchedData[i].isDelayedOrder;
          result?.isPrepared = fetchedData[i].isPrepared;
          result?.status = fetchedData[i].status;
          /*int delayInMinutes = 0;
          try {
            delayInMinutes = (int.parse(fetchedData[i].delayedOrderDuration.split(":")[0])*60) + int.parse(fetchedData[i].delayedOrderDuration.split(":")[1]);
          }
          catch(e){
          }
          if(delayInMinutes>0){
            if(fetchedData[i].orderNumber == 0) {
              result?.isDelayedOrder = true;
            }
            else{
              result?.isDelayedOrder = false;
            }
          }
          }*/


          OrderDao().updateOrder(result!).then((value){
            //if(push)
              FBroadcast.instance().broadcast(
                  ConstantBroadcastKeys.KEY_ORDER_SENT, value: result);
            if(i==fetchedData.length-1)
              localCallback();
          });
        }
        else{
          OrderModel orderModel = OrderModel(
              fetchedData[i].id, fetchedData[i].orderNumber, fetchedData[i].orderName, fetchedData[i].orderType,
              fetchedData[i].orderService, fetchedData[i].tableNumber, fetchedData[i].comment, fetchedData[i].totalPrice,
              fetchedData[i].createdAt, fetchedData[i].createdBy, fetchedData[i].deliveryInfoModel,
              //fetchedData[i].managerId,
              fetchedData[i].manager,
              fetchedData[i].foodItems);
          orderModel.isSyncedOnServer=true;
          orderModel.serverId=fetchedData[i].serverId;

          orderModel.paymentMode=fetchedData[i].paymentMode;
          orderModel.customer = fetchedData[i].customer;
          orderModel.isDeleted=fetchedData[i].isDeleted;
          orderModel.delayedOrderDuration = fetchedData[i].delayedOrderDuration;
          orderModel.attachedOrders = fetchedData[i].attachedOrders;
          orderModel.attachedBy = fetchedData[i].attachedBy;
          orderModel.status = fetchedData[i].status;

          int delayInMinutes = 0;
         /* int delayInMinutes = 0;
          try {
            delayInMinutes = (int.parse(orderModel.delayedOrderDuration.split(":")[0])*60) + int.parse(orderModel.delayedOrderDuration.split(":")[1]);
          }
          catch(e){
          }
          if(delayInMinutes>0 && orderModel.orderNumber == 0){
            orderModel.isDelayedOrder = true;
          }*/
          orderModel.isDelayedOrder=fetchedData[i].isDelayedOrder;
          orderModel.isPrepared = fetchedData[i].isPrepared;
          //await OrderDao().insertOrder(orderModel).then((value){

          await OrderDao().insertOrder(orderModel).then((value){

          });
            //if(push)

          FBroadcast.instance().broadcast(
                  ConstantBroadcastKeys.KEY_ORDER_SENT, value: orderModel);
            if(i==fetchedData.length-1) {
              localCallback();
            }
        }
      });

    }

   /* OrderDao().getAllOrders().then((value){

      print("=====getAllOrders==value.length======${value.length}=============================");
    });*/
  }

  static saveOrderToSever(OrderModel orderModel, {required Function oncall,bool isUpdate=false})async {
    int customerID = 0;
    int customerAddressID = 0;
    if(orderModel.customer!=null){
      customerID = orderModel.customer!.serverId!;
      customerAddressID = orderModel.customer!.getDefaultAddress().serverId;
    }
    RestaurantInfoModel restaurantInfoModel = await RestaurantInfoDao().getRestaurantInfo();
    String startTime = restaurantInfoModel.startTime;
    String selectedDate = DateFormat("yyyy-MM-dd").format(DateTime.now());
    String strCurrentTime = DateFormat("HH:mm").format(DateTime.now());
    String dateTimeShift=selectedDate+" "+strCurrentTime;
    if(startTime!=null && startTime!='') {
      dateTimeShift = Utility().generateShiftTimingForOrdersShift(startTime);
    }

    if(startTime==null){
      startTime = "09:00:00";
    }

    final dio = Dio();
    dio.options.headers['X-TenantID'] = OPTIFOOD_DATABASE;
    dio.options.headers['Authorization'] = authorization;
    var orderedItems = [];
    var deliverInfo = {};
    String currency = optifoodSharedPrefrence.getString(ConstantSharedPreferenceKeys.KEY_SELECTED_CURRENCY)!=null?optifoodSharedPrefrence.getString(ConstantSharedPreferenceKeys.KEY_SELECTED_CURRENCY)!:ConstantCurrencySymbol.EURO.toString();
    String decimalSeparator = optifoodSharedPrefrence.getString(ConstantSharedPreferenceKeys.KEY_SELECTED_CURRENCY)!=null?optifoodSharedPrefrence.getString(ConstantSharedPreferenceKeys.KEY_SELECTED_DECIMAL_SEPARATOR)!:",";

    for (int i = 0; i < orderModel.foodItems.length; i++) {
      var orderedItemAttributes=[];
      for (int j = 0; j < orderModel.foodItems[i].selectedAttributes.length; j++) {
        print("ATTRIBUTE");
        print(orderModel.foodItems[i].selectedAttributes[j].toJson());
        var orderedItemAttribute={
          "orderedItemId": orderModel.foodItems[i].serverId,
          "orderedItemAttributeId": 0,
          "attributeId": orderModel.foodItems[i].selectedAttributes[j].serverId,
          "quantity": orderModel.foodItems[i].selectedAttributes[j].quantity,
          "attributeValue": orderModel.foodItems[i].selectedAttributes[j].price
        };
        orderedItemAttributes.add(orderedItemAttribute);
      }
      double itemPrice = orderModel.foodItems[i].price;
      if (orderModel.foodItems[i].isEnablePricePerOrderType!=null && orderModel.foodItems[i].isEnablePricePerOrderType) {
        if (orderModel.orderType == ConstantOrderType.ORDER_TYPE_RESTAURANT) {
          if (orderModel.orderService ==
              ConstantRestaurantOrderType.RESTAURANT_ORDER_TYPE_EAT_IN) {
            itemPrice = orderModel.foodItems[i].eatInPrice;
          } else {
            itemPrice = orderModel.foodItems[i].price;
          }
        } else if (orderModel.orderType == ConstantOrderType.ORDER_TYPE_DELIVERY) {
          itemPrice = orderModel.foodItems[i].deliveryPrice;
        }
      }
      var item = {
        'orderId': orderModel.serverId,
        'orderedItemId': orderModel.foodItems[i].orderedItemId,
        'discount': orderModel.foodItems[i].discountPercentage,
        'menuPrice': 0,
        'itemId': orderModel.foodItems[i].serverId,
        //'price': orderModel.foodItems[i].price,
        'price': itemPrice,
        'quantity': orderModel.foodItems[i].quantity,
        'orderedItemAttributeRequestModels': orderedItemAttributes
      };
      orderedItems.add(item);

    }
    var data = {
      'customerId': customerID,
      'orderSourceId': 0,
      'orderNumber': orderModel.orderNumber,
      'orderName' : orderModel.orderName,
      'status': "Ordered",
      'paymentMode': orderModel.paymentMode,
      'orderService': orderModel.orderService,
      'isPrepared': false,
      'tableNumber': orderModel.tableNumber,
      //'managerId': optifoodSharedPrefrence.getString("id"),
      'managerId': optifoodSharedPrefrence.getInt("id"),
      'waiterId': 0,
      //'waiterId': optifoodSharedPrefrence.getInt("id"),
      'kitchenId': 0,
      //'kitchenId': optifoodSharedPrefrence.getInt("id"),
      'totalPrice': orderModel.totalPrice,
      'comment': orderModel.comment,
      'arrivedTime': "00:00:00",
      'delayTime': orderModel.isDelayedOrder?orderModel.delayedOrderDuration:null,
      'orderType': orderModel.orderType,
      'orderedItemRequestModels': orderedItems,
      'openingTime': startTime+":00",
      "dateTimeZone":AppConfig.dateTime.timeZoneOffset.inMinutes,
      "currency":currency,
      "decimalSeparator":decimalSeparator,
      'orderDeliveryDataRequestModel': orderModel.orderType == 'delivery' ?
      {
        'orderId': 0,
        "customerAddressId": customerAddressID,
        'companyId': 0,
        'assignedTo': orderModel.deliveryInfoModel!.assignedTo,
        'deliveryDate': orderModel.deliveryInfoModel!.deliveryDate.split(
            "/")[2] + "-" +
            orderModel.deliveryInfoModel!.deliveryDate.split("/")[1] + "-" +
            orderModel.deliveryInfoModel!.deliveryDate.split("/")[0],
        'deliveryTime': orderModel.deliveryInfoModel!.deliveryTime + ":00"
      }
          : null,
      "orderFeeRequestModel": (orderModel.orderfeeModel?.feeDelivery!=null || orderModel.orderfeeModel?.feeNightMode!=null) ?
                              {"feeDelivery":orderModel.orderfeeModel?.feeDelivery,"feeNightMode":10}:null
    };

    if (isUpdate) {
      dio.put(ServerData.OPTIFOOD_BASE_URL + '/api/order/'+orderModel.serverId.toString(),
        data: data,
      ).then((response) async {
        orderModel.isSyncedOnServer = true;
        orderModel.isSyncOnServerProcessing = false;
        orderModel.syncOnServerActionPending = Utility().removeServerSyncActionPending(ConstantSyncOnServerPendingActions.ACTION_PENDING_UPDATE);
        await OrderDao().updateOrder(orderModel);
        try{
          oncall();
        }
        catch(error){
        }
        FBroadcast.instance().broadcast(
            ConstantBroadcastKeys.KEY_ORDER_SENT, value: orderModel);
      }).catchError((err) async {
        orderModel.isSyncedOnServer = false;
        orderModel.isSyncOnServerProcessing = false;
        await OrderDao().updateOrder(orderModel);
        FBroadcast.instance().broadcast(
            ConstantBroadcastKeys.KEY_ORDER_SENT, value: orderModel);
        optifoodBackgroundService.syncPendingLocalData();
        try{
        }
        catch(error){
        }
      });
    }
    else {
      var response = await dio.post(ServerData.OPTIFOOD_BASE_URL + '/api/order',
        data: data,
      ).then((response) async {
        var mappedOrderModel = OrderModel.fromJsonServer(response.data);
        orderModel.isSyncedOnServer = true;
        orderModel.isSyncOnServerProcessing = false;
        orderModel.serverId = mappedOrderModel.id;
        orderModel.orderNumber = mappedOrderModel.orderNumber;
        for(int i=0;i<orderModel.foodItems.length;i++){
          orderModel.foodItems[i].orderedItemId=mappedOrderModel.foodItems[i].orderedItemId;
        }
        orderModel.syncOnServerActionPending ='';
        Utility().printTicket(orderModel);
        await OrderDao().updateOrder(orderModel);
        FBroadcast.instance().broadcast(
            ConstantBroadcastKeys.KEY_ORDER_SENT, value: orderModel);
        try{
          oncall();
        }
        catch(error){
        }
      }).catchError((err,detail) async {
        orderModel.isSyncedOnServer = false;
        orderModel.isSyncOnServerProcessing = false;
        await OrderDao().updateOrder(orderModel);
        try{
        }
        catch(error){

        }
        FBroadcast.instance().broadcast(
            ConstantBroadcastKeys.KEY_ORDER_SENT, value: orderModel);
        optifoodBackgroundService.syncPendingLocalData();
      });
    }
  }
  static Future<void> addCommentToOrder(int orderServerId, String comment) async {
    final dio = Dio();
    dio.options.headers['X-TenantID'] = OPTIFOOD_DATABASE;
    dio.options.headers['Authorization'] = authorization;
    var formData = FormData.fromMap({
      'comment': comment
    });
    var response = await dio.put(ServerData.OPTIFOOD_BASE_URL+"/api/order/comment/${orderServerId}",
    //data: formData
      queryParameters: {
        'comment': comment
      }
    );
  }
  static Future<void> assignOrderToDeliveryBoy(int? orderServerId, int? deliveryBoyServerId, bool isAssigned) async {
    final dio = Dio();
    dio.options.headers['X-TenantID'] = OPTIFOOD_DATABASE;
    dio.options.headers['Authorization'] = authorization;
    var response = await dio.get(ServerData.OPTIFOOD_BASE_URL+"/api/order/assign/${orderServerId}", queryParameters: {
      "deliveryBoyId": deliveryBoyServerId,
      "status": isAssigned
    });
  }
  static Future<void> groupOrder(OrderModel primaryOrder, List<int> attachedOrders) async {

    final dio = Dio();
    dio.options.headers['X-TenantID'] = OPTIFOOD_DATABASE;
    dio.options.headers['Authorization'] = authorization;
    var data = {
      "attachedBy":primaryOrder.serverId,
      "attachedOrders":attachedOrders
    };
    var response = await dio.post(ServerData.OPTIFOOD_BASE_URL + '/api/order/attached-orders',
      data: data);
  }

  static deleteOrder(int? serverId) async {
    print("SERVER IDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDD: ${serverId}");
    final dio = Dio();
    dio.options.headers['X-TenantID'] = OPTIFOOD_DATABASE.toString();
    await dio.delete(ServerData.OPTIFOOD_BASE_URL+"/api/order/${serverId}").then((value){
    }).catchError((onError){
    });
  }
  static restoreOrder(int? serverId) async {
    print("SERVER IDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDD: ${serverId}");
    final dio = Dio();
    dio.options.headers['X-TenantID'] = OPTIFOOD_DATABASE.toString();
    await dio.put(ServerData.OPTIFOOD_BASE_URL+"/api/order/restore/${serverId}").then((value){
    }).catchError((onError){
    });
  }

}