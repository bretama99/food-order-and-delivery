import 'package:flutter/material.dart';
import 'package:opti_food_app/data_models/user_model.dart';
import 'package:opti_food_app/database/contact_dao.dart';
import 'package:opti_food_app/database/order_dao.dart';

import 'contact_model.dart';
import 'delivery_info_model.dart';
import 'food_items_model.dart';
import 'order_fee_model.dart';

class OrderModel{
  int id;
  //int managerId;
  String status;
  UserModel manager;
  int orderNumber;
  String orderName;
  String orderType;
  String orderService;
  String tableNumber;
  String comment;
  String? paymentMode;
  double totalPrice;
  String createdAt;
  String createdBy;
  int attachedBy = 0;
  bool isDeleted = false;
  List<int> attachedOrders = [];
  List<FoodItemsModel> foodItems;
  DeliveryInfoModel? deliveryInfoModel;
  ContactModel? customer;
  ContactModel? customerExtraAddress;
  bool isSyncedOnServer;
  bool isSyncOnServerProcessing;
  String syncOnServerActionPending;
  int? serverId;
  bool isDelayedOrder = false;
  String delayedOrderDuration = "0:0:00";
  bool isPrepared = false;
  OrderfeeModel? orderfeeModel;
  OrderModel(
      this.id,
      this.orderNumber,
      this.orderName,
      this.orderType,
      this.orderService,
      this.tableNumber,
      this.comment,
      this.totalPrice,
      this.createdAt,
      this.createdBy,
      this.deliveryInfoModel,
      //this.managerId,
      this.manager,
      this.foodItems,
      {
        this.serverId=0,
        this.isSyncedOnServer=true,this.isSyncOnServerProcessing=false,this.syncOnServerActionPending="",
        this.customer=null,
        this.attachedBy = 0,
        this.attachedOrders = const [],
        this.paymentMode = null,
        this.isDeleted = false,
        this.isDelayedOrder = false,
        this.delayedOrderDuration = "0:0:00",
        this.orderfeeModel,
        this.isPrepared = false,
        this.status="Ordered"
      });

  factory OrderModel.fromJson(Map<String, dynamic> json)
  {
    final foodItemsList = json[OrderDao.columns.COL_FOOD_ITEMS] as List;
    List<FoodItemsModel> foodItems = foodItemsList.map((e) => FoodItemsModel.fromJsonFromOrder(e)).toList();

    return OrderModel(
        json[OrderDao.columns.COL_ID],
        json[OrderDao.columns.COL_ORDER_NUMBER],
        json[OrderDao.columns.COL_ORDER_NAME],
        json[OrderDao.columns.COL_ORDER_TYPE],
        json[OrderDao.columns.COL_ORDER_SERVICE],
        json[OrderDao.columns.COL_TABLE_NUMBER],
        json[OrderDao.columns.COL_COMMENT],
        json[OrderDao.columns.COL_TOTAL_PRICE],
        json[OrderDao.columns.COL_CREATED_AT],
        json[OrderDao.columns.COL_CREATED_BY],
        //json[OrderDao.columns.COL_CUSTOMER]!=""?DeliveryInfoModel.fromJson(json[OrderDao.columns.COL_DELIVERY_INFO]):null,
        DeliveryInfoModel.fromJson(json[OrderDao.columns.COL_DELIVERY_INFO]),
        //json[OrderDao.columns.COL_MANAGER_ID],
        UserModel.fromJson(json[OrderDao.columns.COL_MANAGER]),
        foodItems,
        orderfeeModel: OrderfeeModel.fromJson(json),
        serverId: json[OrderDao.columns.COL_SERVER_ID],
        isSyncedOnServer:json[OrderDao.columns.COL_IS_SYNCED_ON_SERVER],
        isSyncOnServerProcessing:json[OrderDao.columns.COL_IS_SYNC_ON_SERVER_PROCESSING],
        syncOnServerActionPending:json[OrderDao.columns.COL_SYNC_ON_SERVER_ACTION_PENDING],
        isDeleted:json[OrderDao.columns.COL_IS_DELETED],
        paymentMode:json[OrderDao.columns.COL_PAYMENT_MODE],
        customer: json[OrderDao.columns.COL_CUSTOMER]!=""?ContactModel.fromJsonForOrder(json[OrderDao.columns.COL_CUSTOMER]!):null,
        attachedBy: json[OrderDao.columns.COL_ATTACHED_BY],
        status: json[OrderDao.columns.COL_STATUS],
        attachedOrders: List<int>.from(json[OrderDao.columns.COL_ATTACHED_ORDERS]),
        isDelayedOrder: json[OrderDao.columns.COL_IS_DELAYED_ORDER],
        delayedOrderDuration: json[OrderDao.columns.COL_DELAYED_DURATION],
        isPrepared: json[OrderDao.columns.COL_IS_PREPARED]
    );
  }

  factory OrderModel.fromJsonServer(Map<String, dynamic> json)
  {
    final foodItemsList = json['orderedItemReponseModels'] as List;
    List<FoodItemsModel> foodItems = foodItemsList.map((e) => FoodItemsModel.fromJsonFromOrderServer(e)).toList();

    final attachedOrdersFromServer = json["attachedOrders"]!=null?json["attachedOrders"] as List:[];
    List<int> attachedOrdersFromServers = [];
    if(attachedOrdersFromServer!=null&&attachedOrdersFromServer!=[])
    for(int i=0; i<attachedOrdersFromServer.length;i++){
      attachedOrdersFromServers.add(attachedOrdersFromServer[i]);
    }

    return OrderModel(
        json['orderId'],
        json['orderNumber'],
        json['orderName']!=null?json['orderName']:"",
        json['orderType'],
        json['orderService'],
        json['tableNumber']!=null?json['tableNumber']:"",
        json['comment'],
        json['totalPrice'],
        json["createdAt"],
        "",//json["createdBy"],
        /*DeliveryInfoModel.fromJson((json['orderDeliveryDataResponseModel']==null
            || json['orderDeliveryDataResponseModel'])==""?
        {}:json['orderDeliveryDataResponseModel']),*/
        json['orderDeliveryDataResponseModel']!=null?DeliveryInfoModel.fromJson(json['orderDeliveryDataResponseModel']):null,
        //json["managerId"],
        UserModel(json['managerResponseModel']['id']==null?0:json['managerResponseModel']['id'],
            json['managerResponseModel']['firstName']+" "+json['managerResponseModel']['middleName']+" "+json['managerResponseModel']['lastName'],
            json['managerResponseModel']['mobilePhone'],
            json['managerResponseModel']['email'],
            "",
            "",
            false,
            intServerId: json['managerResponseModel']['id']
        ),
        foodItems,
        serverId: json["orderId"],
        isDeleted: json["deleted"],
        paymentMode: json["paymentMode"],
        customer: json["customerResponseModel"]!=null&&json["customerResponseModel"]!=""?
                  ContactModel.fromJsonServer(json["customerResponseModel"]):null,
        attachedBy: json["attachedBy"]==null?0:json["attachedBy"],
        status: json["status"]==null?"":json["status"],
        attachedOrders: attachedOrdersFromServers==null?[]:attachedOrdersFromServers,
        delayedOrderDuration: json["delayTime"]!=null?json["delayTime"]:"0:0:00",
        orderfeeModel:json['orderFeeResponseModel']!=null? OrderfeeModel.fromJson(json['orderFeeResponseModel']):null,
        isPrepared:json['prepared']
    );
  }


  Map<String, dynamic> toJson() => {
    OrderDao.columns.COL_ID: id,
    OrderDao.columns.COL_ORDER_NUMBER: orderNumber,
    OrderDao.columns.COL_ORDER_NAME: orderName,
    OrderDao.columns.COL_ORDER_TYPE: orderType,
    OrderDao.columns.COL_ORDER_SERVICE: orderService,
    OrderDao.columns.COL_TABLE_NUMBER: tableNumber,
    OrderDao.columns.COL_COMMENT: comment,
    OrderDao.columns.COL_PAYMENT_MODE: paymentMode,
    OrderDao.columns.COL_TOTAL_PRICE: totalPrice,
    OrderDao.columns.COL_CREATED_AT: createdAt,
    OrderDao.columns.COL_CREATED_BY: createdBy,
    OrderDao.columns.COL_DELIVERY_INFO : deliveryInfoModel!=null?deliveryInfoModel!.toJson():"",
    OrderDao.columns.COL_SERVER_ID: serverId,
    //OrderDao.columns.COL_MANAGER_ID: managerId,
    OrderDao.columns.COL_MANAGER: manager.toJson(),
    OrderDao.columns.COL_IS_SYNCED_ON_SERVER:isSyncedOnServer,
    OrderDao.columns.COL_IS_SYNC_ON_SERVER_PROCESSING:isSyncOnServerProcessing,
    OrderDao.columns.COL_SYNC_ON_SERVER_ACTION_PENDING:syncOnServerActionPending,
    //OrderDao.columns.COL_FOOD_ITEMS: foodItems.map((e) => e.toJson()).toList(growable: true)
    OrderDao.columns.COL_FOOD_ITEMS: foodItems.map((e) => e.toJsonForOrder()).toList(growable: true),
    OrderDao.columns.COL_CUSTOMER: customer!=null?customer!.toJsonForOrder():"",
    OrderDao.columns.COL_ATTACHED_BY: attachedBy,
    OrderDao.columns.COL_STATUS: status,
    OrderDao.columns.COL_ATTACHED_ORDERS: attachedOrders,
    OrderDao.columns.COL_IS_DELETED: isDeleted,
    OrderDao.columns.COL_IS_DELAYED_ORDER: isDelayedOrder,
    OrderDao.columns.COL_DELAYED_DURATION: delayedOrderDuration,
    OrderDao.columns.COL_IS_PREPARED: isPrepared,
    OrderDao.columns.COL_ORDER_FEE : orderfeeModel!=null?orderfeeModel!.toJson():"",
  };

}