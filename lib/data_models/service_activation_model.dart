import 'package:flutter/material.dart';
import 'package:opti_food_app/database/service_activation_dao.dart';

import '../database/food_category_dao.dart';

class ServiceActivationModel{
  late int id;
  late bool takeawayMode;
  late bool eatInMode;
  late bool tableManagement;
  late bool deliveryMode;
  late bool nightMode;
  late bool isSynced;
  int? serverId;

  ServiceActivationModel(this.id,this.takeawayMode,this.eatInMode,this.tableManagement,
      this.deliveryMode,this.nightMode,{this.serverId=0,this.isSynced=false});
  ServiceActivationModel.Empty();
  factory ServiceActivationModel.fromJson(Map<String, dynamic> json) => ServiceActivationModel(
      json[ServiceActivationDao.columns.COL_ID],
      json[ServiceActivationDao.columns.COL_TAKEAWAY_MODE],
      json[ServiceActivationDao.columns.COL_EAT_IN_MODE],
      json[ServiceActivationDao.columns.COL_TABLE_MANAGEMENT],
      json[ServiceActivationDao.columns.COL_DELIVERY_MODE],
      json[ServiceActivationDao.columns.COL_NIGHT_MODE],
    serverId: json[ServiceActivationDao.columns.COL_SERVER_ID],
    isSynced: json[ServiceActivationDao.columns.COL_IS_SYNCED],
  );

  Map<String, dynamic> toJson() => {
    ServiceActivationDao.columns.COL_ID: id,
    ServiceActivationDao.columns.COL_TAKEAWAY_MODE: takeawayMode,
    ServiceActivationDao.columns.COL_EAT_IN_MODE: eatInMode,
    ServiceActivationDao.columns.COL_TABLE_MANAGEMENT: tableManagement,
    ServiceActivationDao.columns.COL_DELIVERY_MODE: deliveryMode,
    ServiceActivationDao.columns.COL_NIGHT_MODE: nightMode,
    ServiceActivationDao.columns.COL_SERVER_ID: serverId,
    ServiceActivationDao.columns.COL_IS_SYNCED: isSynced,
  };

  @override
  String toString() {
    // TODO: implement toString
    String data = "id : ${id}, takeawayMode : ${takeawayMode}, eatInMode : ${eatInMode}, tableManagement : ${tableManagement}"
        ", deliveryMode : ${deliveryMode}, nightMode : ${nightMode}";
    return data;
  }

}
