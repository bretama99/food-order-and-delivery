import 'package:flutter/material.dart';
import 'package:opti_food_app/database/delivery_fee_dao.dart';
import 'package:opti_food_app/database/night_mode_fee_dao.dart';
import 'package:opti_food_app/database/service_activation_dao.dart';

import '../database/food_category_dao.dart';

class NightModeFeeModel{
  late int id;
  late bool activateNightFeeRestaurant;
  late bool activateNightFeeDelivery;
  late double nightFee;
  late String startTime;
  late String endTime;
  late bool isSynced;
  int? serverId;
  NightModeFeeModel(this.id,this.activateNightFeeRestaurant,this.activateNightFeeDelivery,this.nightFee,
      this.startTime,this.endTime,{this.serverId=0,this.isSynced=false,});
  NightModeFeeModel.Empty();
  factory NightModeFeeModel.fromJsonServer(Map<String, dynamic> json){
    return NightModeFeeModel(
      json["nightModeFeeId"],
      json["activateNightFeeRestaurant"],
      json["activateNightFeeDelivery"],
      json["nightFee"],
      json["startTime"],
      json["endTime"],
      serverId:json["nightModeFeeId"],
      isSynced:json[NightModeFeeDao.columns.COL_IS_SYNCED],
    );
  }
  factory NightModeFeeModel.fromJson(Map<String, dynamic> json) => NightModeFeeModel(
    json[NightModeFeeDao.columns.COL_ID],
    json[NightModeFeeDao.columns.COL_ACTIVATE_NIGHT_FEE_RESTAURANT],
    json[NightModeFeeDao.columns.COL_ACTIVATE_NIGHT_FEE_DELIVERY],
    json[NightModeFeeDao.columns.COL_NIGHT_FEE],
    json[NightModeFeeDao.columns.COL_START_TIME],
    json[NightModeFeeDao.columns.COL_END_TIME],
    serverId: json[NightModeFeeDao.columns.COL_SERVER_ID],
    isSynced: json[NightModeFeeDao.columns.COL_IS_SYNCED],
  );

  Map<String, dynamic> toJson() => {
    NightModeFeeDao.columns.COL_ID: id,
    NightModeFeeDao.columns.COL_ACTIVATE_NIGHT_FEE_RESTAURANT: activateNightFeeRestaurant,
    NightModeFeeDao.columns.COL_ACTIVATE_NIGHT_FEE_DELIVERY: activateNightFeeDelivery,
    NightModeFeeDao.columns.COL_NIGHT_FEE:nightFee,
    NightModeFeeDao.columns.COL_START_TIME: startTime,
    NightModeFeeDao.columns.COL_END_TIME: endTime,
    NightModeFeeDao.columns.COL_SERVER_ID: serverId,
    NightModeFeeDao.columns.COL_IS_SYNCED: isSynced,
  };

  @override
  String toString() {
    // TODO: implement toString
    String data = "id : ${id}, activateNightFeeRestaurant : ${activateNightFeeRestaurant}, activateNightFeeDelivery : ${activateNightFeeDelivery}, nightFee : ${nightFee}, "
        "startTime : ${startTime}, endTime : ${endTime}";
    return data;
  }

}
