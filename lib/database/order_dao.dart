import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:opti_food_app/data_models/delivery_info_model.dart';
import 'package:opti_food_app/data_models/food_items_model.dart';
import 'package:opti_food_app/data_models/order_model.dart';
import 'package:opti_food_app/data_models/restaurant_info_model.dart';
import 'package:opti_food_app/data_models/user_model.dart';
import 'package:opti_food_app/database/restaurant_info_dao.dart';
import 'package:opti_food_app/utils/constants.dart';
import 'package:opti_food_app/utils/utility.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sembast/sembast.dart';
import 'package:sembast/sembast_io.dart';
import 'package:path/path.dart';

import 'app_database.dart';

class OrderDao
{
  static _Columns columns = const _Columns();
  static _ColumnsFoodItems columnsFoodItems = const _ColumnsFoodItems();
  static _ColumnsAttribute columnsAttribute = const _ColumnsAttribute();
  static const String folderName = "Orders";
  final _orderFolder = intMapStoreFactory.store(folderName);

  Future<Database> get _db async => await AppDatabase.instance.database;


   Future insertOrder(OrderModel order) async {
    if(await isOrderExist(order.serverId!)==false) {
      String s = order.toJson().toString();
      var key = await _orderFolder.add(await _db, order.toJson());
      Finder finder = Finder(filter: Filter.byKey(key));
      order.id = key;
      await _orderFolder.update(await _db, order.toJson(), finder: finder);
    }
    else{
    }
  }

  Future<bool> isOrderExist(int serverID) async {
    List<Filter> filterList = [
      Filter.equals(OrderDao.columns.COL_SERVER_ID, serverID),
      Filter.equals(OrderDao.columns.COL_IS_SYNCED_ON_SERVER, true)
    ];
    //Finder finder = Finder(filter: Filter.equals(OrderDao.columns.COL_SERVER_ID, serverID));
    Finder finder = Finder(filter: Filter.and(filterList));
    var recordSnapshot = await _orderFolder.find(await _db,
        finder: finder
    );
    if(recordSnapshot.isNotEmpty){
      return true;
    }
    else{
      return false;
    }
  }

  Future updateOrder(OrderModel order) async {

    final finder = Finder(filter: Filter.byKey(order.id));

    await _orderFolder.update(await _db, order.toJson(), finder: finder);
  }

  Future delete(OrderModel order) async {
    //final finder = Finder(filter: Filter.byKey(order.id));
    //await _orderFolder.update(await _db, order.toJson(), finder: finder);
    // print("Delete orderrrrrrrrrrrrrr:${order.isDeleted}");
     final finder = Finder(filter: Filter.byKey(order.id));
     order.isDeleted = true;
     order.status = "canceled";
     await _orderFolder.update(await _db, order.toJson(), finder: finder);
  }

  Future removeOrder(OrderModel order) async {
    final finder = Finder(filter: Filter.equals(columns.COL_ID, order.id));
    await _orderFolder.delete(await _db, finder: finder);
  }

  Future removeAllOrders() async {
    await _orderFolder.delete(await _db);
  }

  Future restore(OrderModel order) async {
    final finder = Finder(filter: Filter.byKey(order.id));
    order.isDeleted = false;
    await _orderFolder.update(await _db, order.toJson(), finder: finder);
  }

  Future<OrderModel> getTopOrder() async {
    List<Filter> mainFilterList = [Filter.custom((record){
      bool isReturn = false;
      return true;
    }),
      Filter.equals(columns.COL_IS_DELETED, false)
    ];

    var recordSnapshot = await _orderFolder.find(await _db,finder: Finder(
        filter: Filter.and(mainFilterList)
    ));

    return recordSnapshot.map((snapshot) {
      final orders = OrderModel.fromJson(snapshot.value);
      return orders;
    }).toList()[recordSnapshot.length-1];
  }

  /*Future<List<OrderModel>> getAllOrders({List<String>? orderTypeFilterList,String selectedStatus="All"}) async {
    RestaurantInfoModel restaurantInfoModel = await RestaurantInfoDao().getRestaurantInfo();
    String startTime = restaurantInfoModel.startTime;
    String endTime = restaurantInfoModel.endTime;
    if(startTime==null||endTime==null){
      startTime = "09:00";
      endTime = "22:00";
    }
    List<String> dateTimeList = Utility().generateShiftTiming(startTime, endTime);
    List<Filter> mainFilterList = [Filter.custom((record){
      bool isReturn = false;
      DeliveryInfoModel deliveryInfoModel = DeliveryInfoModel.fromJson(record[columns.COL_DELIVERY_INFO]);
      String deliveryDate = deliveryInfoModel.deliveryDate.split("/")[2]+"-"+
          deliveryInfoModel.deliveryDate.split("/")[1]+"-"+
          deliveryInfoModel.deliveryDate.split("/")[0];
     DateTime deliveryDateTime;
      if(deliveryInfoModel.deliveryTime.split(":")[0].length<2)
        deliveryDateTime= DateTime.parse(deliveryDate+" 0"+deliveryInfoModel.deliveryTime);
      else
        deliveryDateTime= DateTime.parse(deliveryDate+" "+deliveryInfoModel.deliveryTime);


      DateTime startDateTime = DateTime.parse(dateTimeList[0]);
      if(deliveryDateTime.isAfter(startDateTime)){
        isReturn = true;
      }
      return isReturn;
    }),
      Filter.equals(columns.COL_IS_DELETED, false)
    ];

    var recordSnapshot = await _orderFolder.find(await _db,finder: Finder(
        filter: Filter.and(mainFilterList)
    ));

    List<OrderModel> allList= recordSnapshot.map((snapshot) {
      final orders = OrderModel.fromJson(snapshot.value);
      return orders;
    }).toList();
    if(allList.length>0 && allList[allList.length-1].orderNumber==0) {
      var item = allList.removeAt(allList.length - 1);
      allList.insert(0, item);
    }
    List<OrderModel>  sortedListByTime=[];
    allList.sort((a,b)=>a.id.compareTo(b.id));
    allList.forEach((element) {
      sortedListByTime.add(element);
    });

    allList.sort((a,b)=>b.orderNumber.compareTo(a.orderNumber));
    int n=allList.length;
    int j=0;
    for(int i=0; i<n; i++){
      if(allList[i].orderNumber==0){
        int correctIndex=getCorrectPosition(sortedListByTime, allList[i].id);
        var item = allList.removeAt(i);
        allList.insert(correctIndex, item);
      }
    }
    allList.sort((a,b) => b.orderNumber == 0 ? 1 : -1);
    return allList;
  }*/

  Future<List<OrderModel>> getAllOrders({List<String>? orderTypeFilterList,String selectedStatus="All"}) async {
    RestaurantInfoModel restaurantInfoModel = await RestaurantInfoDao().getRestaurantInfo();
    String startTime = restaurantInfoModel.startTime;
    String endTime = restaurantInfoModel.endTime;
    if(startTime==null||endTime==null){
      startTime = "09:00";
      endTime = "22:00";
    }
    List<String> dateTimeList = Utility().generateShiftTiming(startTime, endTime);
    List<Filter> mainFilterList = [
      /*Filter.custom((record){
      bool isReturn = false;
      DeliveryInfoModel deliveryInfoModel = DeliveryInfoModel.fromJson(record[columns.COL_DELIVERY_INFO]);
      String deliveryDate = deliveryInfoModel.deliveryDate.split("/")[2]+"-"+
          deliveryInfoModel.deliveryDate.split("/")[1]+"-"+
          deliveryInfoModel.deliveryDate.split("/")[0];
      DateTime deliveryDateTime;
      if(deliveryInfoModel.deliveryTime.split(":")[0].length<2)
        deliveryDateTime= DateTime.parse(deliveryDate+" 0"+deliveryInfoModel.deliveryTime);
      else
        deliveryDateTime= DateTime.parse(deliveryDate+" "+deliveryInfoModel.deliveryTime);


      *//*DateTime startDateTime = DateTime.parse(dateTimeList[0]);
      if(deliveryDateTime.isAfter(startDateTime)){
        isReturn = true;
      }*//*
      isReturn = true;
      return isReturn;
    }),*/
      Filter.equals(columns.COL_IS_DELETED, false),
      Filter.equals(columns.COL_IS_DELAYED_ORDER, false)
    ];
    List<SortOrder> sortList = [];
    sortList.add(SortOrder(OrderDao.columns.COL_ORDER_NUMBER, false));
    var recordSnapshot = await _orderFolder.find(await _db,finder: Finder(
        filter: Filter.and(mainFilterList),
        //filter: Filter.equals(columns.COL_IS_DELETED, false),
        sortOrders: sortList
    ));
    List<OrderModel> allList= recordSnapshot.map((snapshot) {
      //debugPrint(snapshot.value.toString());
      final orders = OrderModel.fromJson(snapshot.value);
      return orders;
    }).toList();
   /* if(allList.length>0 && allList[allList.length-1].orderNumber==0) {
      var item = allList.removeAt(allList.length - 1);
      allList.insert(0, item);
    }
    List<OrderModel>  sortedListByTime=[];
    allList.sort((a,b)=>a.id.compareTo(b.id));
    allList.forEach((element) {
      sortedListByTime.add(element);
    });

    allList.sort((a,b)=>b.orderNumber.compareTo(a.orderNumber));
    int n=allList.length;
    int j=0;
    for(int i=0; i<n; i++){
      if(allList[i].orderNumber==0){
        int correctIndex=getCorrectPosition(sortedListByTime, allList[i].id);
        var item = allList.removeAt(i);
        allList.insert(correctIndex, item);
      }
    }*/
   // allList.sort((a,b) => b.orderNumber == 0 ? 1 : -1);
    allList.forEach((element) {
      print(element.orderNumber.toString()+","+element.isPrepared.toString());
    });
    return allList;
  }

  Future<List<OrderModel>> getDelayedOrders() async {
    List<SortOrder> sortList = [];
    sortList.add(SortOrder(OrderDao.columns.COL_ID));
    var recordSnapshot = await _orderFolder.find(await _db,finder: Finder(
        filter: Filter.equals(columns.COL_IS_DELAYED_ORDER, true),
        sortOrders: sortList
    ));

    List<OrderModel> allList= recordSnapshot.map((snapshot) {
      final orders = OrderModel.fromJson(snapshot.value);
      return orders;
    }).toList();
    allList.forEach((element) {
      DateTime tempDate = new DateFormat("yyyy-MM-dd HH:mm:ss").parse(element.createdAt);
      int delayInMinutes = 30;
      try {
        delayInMinutes = (int.parse(element.delayedOrderDuration.split(":")[0])*60) + int.parse(element.delayedOrderDuration.split(":")[1]);
      }
      catch(e){

      }
      tempDate = tempDate.add(Duration(minutes: delayInMinutes));
      element.createdAt = tempDate.toString();
    });
    return allList;
  }

  Future<List<OrderModel>> getAllOrders11({List<String>? orderTypeFilterList,String selectedStatus="All"}) async {
    RestaurantInfoModel restaurantInfoModel = await RestaurantInfoDao().getRestaurantInfo();
    String startTime = restaurantInfoModel.startTime;
    String endTime = restaurantInfoModel.endTime;
    if(startTime==null||endTime==null){
      startTime = "00:00";
      endTime = "23:59";
    }
    List<String> dateTimeList = startTime!=null?Utility().generateShiftTiming(startTime, endTime):[];
    /*List<Filter> mainFilterList = [Filter.custom((record){
      bool isReturn = false;
      DeliveryInfoModel deliveryInfoModel = DeliveryInfoModel.fromJson(record[columns.COL_DELIVERY_INFO]);
      String deliveryDate = "";
        deliveryDate = deliveryInfoModel.deliveryDate.split("/")[2]+"-"+
            deliveryInfoModel.deliveryDate.split("/")[1]+"-"+
            deliveryInfoModel.deliveryDate.split("/")[0];
      DateTime deliveryDateTime = DateTime.parse(deliveryDate+" "+deliveryInfoModel.deliveryTime);
      DateTime startDateTime = DateTime.parse(dateTimeList[0]);
      DateTime endDateTime = DateTime.parse(dateTimeList[1]);
      if(deliveryDateTime.isAfter(startDateTime)&&deliveryDateTime.isBefore(endDateTime)){
        isReturn = true;
      }
      return isReturn;
    }),
      Filter.equals(columns.COL_IS_DELETED, false)
    ];*/
    List<SortOrder> sortList = [];
    sortList.add(SortOrder(OrderDao.columns.COL_ORDER_NUMBER, false));
    Finder finder = Finder( sortOrders: sortList);
    var recordSnapshot = await _orderFolder.find(await _db,
                 finder: finder
    );

    List<OrderModel> allList= recordSnapshot.map((snapshot) {

      final orders = OrderModel.fromJson(snapshot.value);
      return orders;
    }).toList();
    if(allList.length>0 && allList[allList.length-1].orderNumber==0) {
      var item = allList.removeAt(allList.length - 1);
      allList.insert(0, item);
    }
    List<OrderModel>  sortedListByTime=[];
    allList.sort((a,b)=>b.id.compareTo(a.id));
    allList.forEach((element) {
      sortedListByTime.add(element);
    });

    allList.sort((a,b)=>b.orderNumber.compareTo(a.orderNumber));
    int n=allList.length;
    int j=0;
    for(int i=0; i<n; i++){
      if(allList[i].orderNumber==0){
        int correctIndex=getCorrectPosition(sortedListByTime, allList[i].id);
        var item = allList.removeAt(i);
        allList.insert(correctIndex, item);
      }
    }
    allList.sort((a,b) => b.orderNumber == 0 ? 1 : -1);
   return allList;
  }

  int getCorrectPosition(List<OrderModel> sortedListByTime, int id){
    for(int i=0; i<sortedListByTime.length; i++) {
      if (sortedListByTime[i].id == id) {
        return i;
      }
    }
    return 0;
  }

  Future<List<OrderModel>> getOrderArchive(List<String> orderTypeFilterList,{String selectedStatus="All",String? selectedDate}) async {
    RestaurantInfoModel restaurantInfoModel = await RestaurantInfoDao().getRestaurantInfo();
    String startTime = restaurantInfoModel.startTime;
    String endTime = restaurantInfoModel.endTime;
    if(startTime==null||endTime==null){
      startTime = "09:00";
      endTime = "22:00";
    }
    List<String> dateTimeList = Utility().generateShiftTiming(startTime, endTime,selectedDate: selectedDate);
    /*List<Filter> filterList = [Filter.custom((record){
      bool isReturn = false;
      DeliveryInfoModel deliveryInfoModel = DeliveryInfoModel.fromJson(record[columns.COL_DELIVERY_INFO]);

      String deliveryDate = deliveryInfoModel.deliveryDate.split("/")[2]+"-"+
          deliveryInfoModel.deliveryDate.split("/")[1]+"-"+
          deliveryInfoModel.deliveryDate.split("/")[0];
      DateTime deliveryDateTime;
      if(deliveryInfoModel.deliveryTime.split(":")[0].length<2)
        deliveryDateTime= DateTime.parse(deliveryDate+" 0"+deliveryInfoModel.deliveryTime);
      else
        deliveryDateTime= DateTime.parse(deliveryDate+" "+deliveryInfoModel.deliveryTime);
      DateTime startDateTime = DateTime.parse(dateTimeList[0]);
      if(deliveryDateTime.isAfter(startDateTime)){
        isReturn = true;
      }
      return isReturn;
    }),*/
    List<Filter> filterList = [
      Filter.or([Filter.inList(
          columns.COL_ORDER_TYPE, orderTypeFilterList),
        Filter.inList(
            columns.COL_ORDER_SERVICE, orderTypeFilterList)
      ]),
    ];
      if(selectedStatus!="all"){
        if(selectedStatus == "cancelled"){
          filterList.add(Filter.equals(columns.COL_IS_DELETED, true));
        }
        else if(selectedStatus == "delayed"){
          filterList.add(Filter.equals(columns.COL_IS_DELAYED_ORDER, true));
        }
        else if(selectedStatus == "completed"){
          filterList.add(Filter.equals(columns.COL_IS_PREPARED, true));
        }

        else if(selectedStatus == "inProgress"){
          filterList.add(Filter.equals(columns.COL_STATUS, "Ordered"));
        }
        else {
          filterList.add(Filter.equals(columns.COL_IS_DELETED, false));
          filterList.add(Filter.equals(columns.COL_IS_DELAYED_ORDER, false));
        }
      }
      var recordSnapshot = await _orderFolder.find(await _db, finder: Finder(
          filter: Filter.and(filterList)));
    List<OrderModel> allList= recordSnapshot.map((snapshot) {
      final orders = OrderModel.fromJson(snapshot.value);
      return orders;
    }).toList();
    if(allList.length>0 && allList[allList.length-1].orderNumber==0) {
      var item = allList.removeAt(allList.length - 1);
      allList.insert(0, item);
    }
    List<OrderModel>  sortedListByTime=[];
    allList.sort((a,b)=>b.id.compareTo(a.id));
    allList.forEach((element) {
      sortedListByTime.add(element);
    });

    allList.sort((a,b)=>b.orderNumber.compareTo(a.orderNumber));
    int n=allList.length;
    int j=0;
    for(int i=0; i<n; i++){
      if(allList[i].orderNumber==0){
        int correctIndex=getCorrectPosition(sortedListByTime, allList[i].id);
        var item = allList.removeAt(i);
        allList.insert(correctIndex, item);
      }
    }
    allList.sort((a,b) => b.orderNumber == 0 ? 1 : -1);
    return allList;
  }

  Future<List<OrderModel>> getOrderShift({String? selectedDate}) async {
    RestaurantInfoModel restaurantInfoModel = await RestaurantInfoDao().getRestaurantInfo();
    String startTime = restaurantInfoModel.startTime;
    String selectedDate = DateFormat("yyyy-MM-dd").format(DateTime.now());
    String strCurrentTime = DateFormat("HH:mm").format(DateTime.now());
    String dateTimeShift=selectedDate+" "+strCurrentTime;
    if(startTime!=null && startTime!='')
       dateTimeShift = Utility().generateShiftTimingForOrdersShift(startTime);
    var finder = Finder(
      sortOrders: [SortOrder(columns.COL_SERVER_ID,false,false)],
    );
    var recordSnapshot = await _orderFolder.find(await _db, finder: finder);
    return recordSnapshot.map((snapshot) {
      final orders = OrderModel.fromJson(snapshot.value);
      DateTime createdAtDateTime = DateTime.parse(orders.createdAt.substring(0,16));
      DateTime startDateTime = DateTime.parse(dateTimeShift.substring(0,16));
      if(createdAtDateTime.isAfter(startDateTime)){
        return orders;
      }
      else{
        DeliveryInfoModel deliveryInfoModel = DeliveryInfoModel("0", "0", 0, "0", "0");
        List<FoodItemsModel> foodItemsModel = [];
        return OrderModel(0, 0, "l", "p", "p", "o", "p", 0, "o", "o", deliveryInfoModel,UserModel(0,"","","","","",false), foodItemsModel);
      }
    }).toList();
  }


  Future<int> generateOrderNumber() async
  {
    int orderNumber = 0;
    var finder = Finder(
      sortOrders: [SortOrder(columns.COL_ORDER_NUMBER,false,false)],limit: 1,
    );
    final recordSnapshot = await _orderFolder.find(await _db,finder: finder);
    if(recordSnapshot.isNotEmpty) {
      orderNumber = OrderModel
          .fromJson(recordSnapshot.single.value)
          .orderNumber;
      return orderNumber == 0 ? 1 : orderNumber + 1;
    }
    else
      {
        return 1;
      }
  }
  Future<List<OrderModel>> getAttachableOrders(OrderModel primaryOrder) async {
    List<Filter> filterList = [Filter.notEquals(columns.COL_ID, primaryOrder.id),
      Filter.equals(columns.COL_ORDER_TYPE, primaryOrder.orderType),
      Filter.equals(columns.COL_ATTACHED_ORDERS, []),
      //Filter.custom((record) => record.value[columns.COL_ATTACHED_ORDERS].toString()=="[]"),
      //Filter.custom((record) => record.value[columns.COL_ATTACHED_ORDERS].toString()=="[]"),
                                Filter.equals(columns.COL_IS_DELETED, false),
                                Filter.or(
                                    [
                                      Filter.equals(columns.COL_ATTACHED_BY, 0),
                                  Filter.equals(columns.COL_ATTACHED_BY, primaryOrder.serverId)
                                    ]),
                                // Filter.custom((record){
                                //   var fieldValue = record[columns.COL_ATTACHED_ORDERS];
                                //   if(fieldValue is Iterable){
                                //     if(fieldValue.isEmpty){
                                //       return true;
                                //     }
                                //     else{
                                //       return false;
                                //     }
                                //   }
                                //   else{
                                //     return false;
                                //   }
                                // })
                              ];
    Finder finder = Finder(filter: Filter.and(filterList));
    final recordSnapshot = await _orderFolder.find(await _db,finder: finder);
    return recordSnapshot.map((snapshot) {
      final orders = OrderModel.fromJson(snapshot.value);
      return orders;
    }).toList();
  }

  Future attachOrder(OrderModel primaryOrder,OrderModel attachedOrder) async {
    primaryOrder.attachedOrders.add(attachedOrder.id);
    attachedOrder.attachedBy = primaryOrder.id;
    await _orderFolder.update(await _db, primaryOrder.toJson(),finder: Finder(filter: Filter.byKey(primaryOrder.id)));
    await _orderFolder.update(await _db, attachedOrder.toJson(),finder: Finder(filter: Filter.byKey(attachedOrder.id)));
  }

  Future deAttachOrder(OrderModel primaryOrder,OrderModel attachedOrder) async{
    primaryOrder.attachedOrders.remove(attachedOrder.id);
    attachedOrder.attachedBy = 0;
    await _orderFolder.update(await _db, primaryOrder.toJson(),finder: Finder(filter: Filter.byKey(primaryOrder.id)));
    await _orderFolder.update(await _db, attachedOrder.toJson(),finder: Finder(filter: Filter.byKey(attachedOrder.id)));
  }




  Future<List<OrderModel>> getOrderByOrderNumber(String orderNumber) async{
    List<Filter> filterList = [
      Filter.equals(OrderDao.columns.COL_ORDER_NUMBER, orderNumber),
    ];

    Finder finder = Finder(filter: Filter.and(filterList));
    final recordSnapshot = await _orderFolder.find(await _db,finder: finder);
    return recordSnapshot.map((snapshot) {
      final orders = OrderModel.fromJson(snapshot.value);
      return orders;
    }).toList();
  }

  Future<List<OrderModel>> getOrderByServerId(int serverId) async{
    List<SortOrder> sortList = [];
    sortList.add(SortOrder(columns.COL_ID));
    //final recordSnapshot = await _orderFolder.find(await _db,finder: Finder(sortOrders: sortList));
    final recordSnapshot = await _orderFolder.find(await _db,finder: Finder(filter:Filter.equals(columns.COL_SERVER_ID, serverId),sortOrders: sortList));
    return recordSnapshot.map((snapshot) {
      final orders = OrderModel.fromJson(snapshot.value);
      return orders;
    }).toList();
  }

  Future<OrderModel> getOrderById(int id) async {
    //Database _db = await getDatabase();
    List<SortOrder> sortList = [];
    final recordSnapshot = await _orderFolder.find(await _db,finder: Finder(sortOrders: sortList,filter: Filter.equals(columns.COL_ID, id)));
    return recordSnapshot.map((snapshot) {
      final orders = OrderModel.fromJson(snapshot.value);
      return orders;
    }).first;
  }

  Future<OrderModel> getOrder() async {
    List<SortOrder> sortList = [];
    sortList.add(SortOrder(columns.COL_ID), );
    final recordSnapshot = await _orderFolder.find(await _db,finder: Finder(sortOrders: sortList));
    return recordSnapshot.map((snapshot) {
      final orders = OrderModel.fromJson(snapshot.value);
      return orders;
    }).toList()[recordSnapshot.length-1];
  }

  Future<List<OrderModel>> getUnSyncedOrders() async {
    List<Filter> filterList = [
      Filter.equals(columns.COL_IS_SYNCED_ON_SERVER, false),
      Filter.equals(columns.COL_IS_SYNC_ON_SERVER_PROCESSING, false),
      Filter.equals(columns.COL_IS_DELAYED_ORDER, false),
    ];
    final recordSnapshot = await _orderFolder.find(await _db,finder: Finder(filter: Filter.and(filterList),sortOrders: [SortOrder(columns.COL_ID)]));
    return recordSnapshot.map((snapshot) {
      final attributeCategories = OrderModel.fromJson(snapshot.value);
      return attributeCategories;
    }).toList();
  }
}
class _Columns
{
  const _Columns();
  String get COL_ID => "id";
  String get COL_ORDER_NUMBER => "order_number";
  String get COL_ORDER_NAME => "order_name";
  String get COL_ORDER_TYPE => "order_type";
  String get COL_ORDER_SERVICE => "order_service";
  String get COL_TABLE_NUMBER => "table_number";
  String get COL_COMMENT => "comment";
  String get COL_PAYMENT_MODE => "payment_mode";
  String get COL_TOTAL_PRICE => "total_price";
  String get COL_CREATED_AT => "created_at";
  String get COL_CREATED_BY => "created_by";
  String get COL_ATTACHED_BY => "attached_by";
  String get COL_ATTACHED_ORDERS => "attached_orders";
  String get COL_IS_DELETED => "is_deleted";
  String get COL_DELIVERY_INFO => "delivery_info";
  String get COL_FOOD_ITEMS => "food_items";
  String get COL_ORDER_FEE => "order_fee";
  String get COL_CUSTOMER => "customer";
  String get COL_SERVER_ID => "server_id";
  String get COL_STATUS => "status";
  String get COL_CATEGORY_ID => "category_id";
  //String get COL_MANAGER_ID => "manager_id";
  String get COL_MANAGER => "manager";
  String get COL_IS_DELAYED_ORDER => "is_delayed_order";
  String get COL_DELAYED_DURATION => "delayed_duration";
  String get COL_IS_PREPARED => "is_prepared";
  String get COL_IS_SYNCED_ON_SERVER => "is_synced_on_server";
  String get COL_IS_SYNC_ON_SERVER_PROCESSING => "is_syn_on_server_processing";
  String get COL_SYNC_ON_SERVER_ACTION_PENDING => "sync_on_server_action_pending";
}

class _ColumnsFoodItems
{
  const _ColumnsFoodItems();
  String get COL_QUANTITY => "quantity";
  String get COL_DISCOUNT => "discount";
}

class _ColumnsAttribute
{
  const _ColumnsAttribute();
  String get COL_QUANTITY => "quantity";
  String get COL_SELECTED_ATTRIBUTES => "selected_attributes";
}