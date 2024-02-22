import 'package:flutter/material.dart';
import 'package:opti_food_app/database/food_items_dao.dart';
import 'package:opti_food_app/database/message_dao.dart';

import '../database/order_dao.dart';
import 'attribute_model.dart';

class MessageModel{
  int id;
  String messageName;
  String message;
  bool showInMainApp;
  bool showInKitchen;
  bool? isSynced;
  int? serverId;
  bool? isSyncOnServerProcessing;
  String syncOnServerActionPending;

  MessageModel(
      this.id,this.messageName,this.message,this.showInMainApp,this.showInKitchen,
      {this.serverId=0,this.isSynced=false,this.isSyncOnServerProcessing=false, this.syncOnServerActionPending="",});

  MessageModel.clone(MessageModel messageModelOriginal):
        this(messageModelOriginal.id,
          messageModelOriginal.messageName,
          messageModelOriginal.message,
          messageModelOriginal.showInMainApp,
          messageModelOriginal.showInKitchen,
          serverId: messageModelOriginal.serverId,
          isSynced: messageModelOriginal.isSynced,
          isSyncOnServerProcessing: messageModelOriginal.isSyncOnServerProcessing,
          syncOnServerActionPending: messageModelOriginal.syncOnServerActionPending

      );

  factory MessageModel.fromJson(Map<String, dynamic> json) => MessageModel(
    json[MessageDao.columns.COL_ID],
    json[MessageDao.columns.COL_MESSAGE_NAME],
    json[MessageDao.columns.COL_MESSAGE],
    json[MessageDao.columns.COL_SHOW_IN_MAIN_APP],
    json[MessageDao.columns.COL_SHOW__IN_KITCHEN],
    serverId: json[MessageDao.columns.COL_SERVER_ID],
    isSynced: json[MessageDao.columns.COL_IS_SYNCED],
    isSyncOnServerProcessing: json[MessageDao.columns.COL_IS_SYNC_ON_SERVER_PROCESSING],
    syncOnServerActionPending: json[MessageDao.columns.COL_SYNC_ON_SERVER_ACTION_PENDING],
  );

  factory MessageModel.fromJsonServer(Map<String, dynamic> json) => MessageModel(
    json['id'],
    json['messageName'],
    json['message'],
    json['showInMainApp'],
    json['showInKitchen'],
    serverId: json['id'],
    isSynced: json['MessageDao.columns.COL_IS_SYNCED'],
    isSyncOnServerProcessing: json[MessageDao.columns.COL_IS_SYNC_ON_SERVER_PROCESSING],
    syncOnServerActionPending: json[MessageDao.columns.COL_SYNC_ON_SERVER_ACTION_PENDING],
  );



  Map<String, dynamic> toJson() => {
    MessageDao.columns.COL_ID: id,
    MessageDao.columns.COL_MESSAGE_NAME: messageName,
    MessageDao.columns.COL_MESSAGE: message,
    MessageDao.columns.COL_SHOW_IN_MAIN_APP: showInMainApp,
    MessageDao.columns.COL_SHOW__IN_KITCHEN: showInKitchen,
    MessageDao.columns.COL_SERVER_ID: serverId,
    MessageDao.columns.COL_IS_SYNCED: isSynced,
    MessageDao.columns.COL_IS_SYNC_ON_SERVER_PROCESSING: isSyncOnServerProcessing,
    MessageDao.columns.COL_SYNC_ON_SERVER_ACTION_PENDING: syncOnServerActionPending,
  };

}