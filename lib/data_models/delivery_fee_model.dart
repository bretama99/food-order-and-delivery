import 'package:flutter/material.dart';
import 'package:opti_food_app/database/delivery_fee_dao.dart';
import 'package:opti_food_app/database/service_activation_dao.dart';

import '../database/food_category_dao.dart';

class DeliveryFeeModel{
  late int id;
  late bool activateDeliveryFee;
  late double deliveryFee;
  late double minimumOrderAmountToExpectDeliveryFee;
  late String displayName;
  late bool isSynced;
  int? serverId;
  DeliveryFeeModel(this.id,this.activateDeliveryFee,this.deliveryFee,this.minimumOrderAmountToExpectDeliveryFee,
      this.displayName,{this.serverId=0,this.isSynced=false});
  DeliveryFeeModel.Empty();
  factory DeliveryFeeModel.fromJson(Map<String, dynamic> json) => DeliveryFeeModel(
      json[DeliveryFeeDao.columns.COL_ID],
      json[DeliveryFeeDao.columns.COL_ACTIVATE_DELIVERY_FEE],
      json[DeliveryFeeDao.columns.COL_DELIVERY_FEE],
      json[DeliveryFeeDao.columns.COL_MINIMUM_ORDER_AMOUNT_TO_EXPECT_DELIVERY_FEE],
      json[DeliveryFeeDao.columns.COL_DISPLAY_NAME],
    serverId: json[DeliveryFeeDao.columns.COL_SERVER_ID],
    isSynced:json[DeliveryFeeDao.columns.COL_IS_SYNCED],
  );

  Map<String, dynamic> toJson() => {
    DeliveryFeeDao.columns.COL_ID: id,
    DeliveryFeeDao.columns.COL_DELIVERY_FEE: deliveryFee,
    DeliveryFeeDao.columns.COL_MINIMUM_ORDER_AMOUNT_TO_EXPECT_DELIVERY_FEE: minimumOrderAmountToExpectDeliveryFee,
    DeliveryFeeDao.columns.COL_DISPLAY_NAME:displayName,
    DeliveryFeeDao.columns.COL_ACTIVATE_DELIVERY_FEE: activateDeliveryFee,
    DeliveryFeeDao.columns.COL_SERVER_ID:serverId,
    DeliveryFeeDao.columns.COL_IS_SYNCED:isSynced,
  };

  factory DeliveryFeeModel.fromJsonServer(Map<String, dynamic> json){
    return DeliveryFeeModel(
        json["deliveryFeeId"],
        json["activateDeliveryFee"],
        json["deliveryFee"],
        json["minimumOrderAmountToExpectDeliveryFee"],
        json["displayName"],
        serverId:json["deliveryFeeId"],
        isSynced:json[DeliveryFeeDao.columns.COL_IS_SYNCED],
    );
  }

  @override
  String toString() {
    // TODO: implement toString
    String data = "id : ${id}, activateDeliveryFee : ${activateDeliveryFee}, deliveryFee : ${deliveryFee}, "
        "minimumOrderAmountToExpectDeliveryFee : ${minimumOrderAmountToExpectDeliveryFee}, displayName : ${displayName}";
    return data;
  }

}
