import 'package:flutter/material.dart';
import 'package:opti_food_app/database/food_items_dao.dart';

import '../database/attribute_dao.dart';
import '../database/order_dao.dart';

class AttributeModel{
  int id;
  int categoryID;
  String name;
  String displayName;
  String color;
  double price;
  String? imagePath;
  int position;
  int quantity; //needs in order_dao only
  int? serverId;
  int?catServerId;
  bool isSyncedOnServer;
  bool isSyncOnServerProcessing;
  String syncOnServerActionPending;

  AttributeModel(this.id, this.name,this.displayName,this.price,{this.serverId=0, this.catServerId,this.quantity = 0,this.categoryID=0,this.color="#FFFFFF",this.position=0,this.imagePath,this.isSyncedOnServer=true,this.isSyncOnServerProcessing=false,this.syncOnServerActionPending=""});

  AttributeModel.clone(AttributeModel attributeModelOriginal): this(
      attributeModelOriginal.id,
      attributeModelOriginal.name,
      attributeModelOriginal.displayName,
      attributeModelOriginal.price,
      serverId: attributeModelOriginal.serverId,
      quantity: attributeModelOriginal.quantity,
      categoryID: attributeModelOriginal.categoryID,
      catServerId: attributeModelOriginal.catServerId,
      color: attributeModelOriginal.color,
      position: attributeModelOriginal.position,
      imagePath: attributeModelOriginal.imagePath,
      isSyncedOnServer: attributeModelOriginal.isSyncedOnServer,
      isSyncOnServerProcessing: attributeModelOriginal.isSyncOnServerProcessing,
      syncOnServerActionPending: attributeModelOriginal.syncOnServerActionPending
  );

  factory AttributeModel.fromJson(Map<String, dynamic> json) => AttributeModel(
      json[AttributeDao.columns.COL_ID],
      json[AttributeDao.columns.COL_NAME],
      json[AttributeDao.columns.COL_DISPLAY_NAME],
      json[AttributeDao.columns.COL_PRICE],
      serverId: json[AttributeDao.columns.COL_SERVER_ID],
      categoryID:json[AttributeDao.columns.COL_CATEGORY_ID],
      catServerId:json[AttributeDao.columns.COL_CAT_SERVER_ID],
      color:json[AttributeDao.columns.COL_COLOR],
      position:json[AttributeDao.columns.COL_POSITION],
      imagePath:json[AttributeDao.columns.COL_IMAGE_PATH],
      isSyncedOnServer: json[AttributeDao.columns.COL_IS_SYNCED_ON_SERVER],
      isSyncOnServerProcessing: json[AttributeDao.columns.COL_IS_SYNC_ON_SERVER_PROCESSING],
      syncOnServerActionPending: json[AttributeDao.columns.COL_SYNC_ON_SERVER_ACTION_PENDING],
  );

  factory AttributeModel.fromJsonServer(Map<String, dynamic> json) => AttributeModel(
      json["attributeId"],
      json["name"],
      json["displayName"],
      //json["attributeValue"],
      json["price"],
      serverId:json["attributeId"],
      quantity:json["quantity"]!=null?json["quantity"]:0,
      categoryID:json["attributeCategoryId"],
      catServerId:json["attributeCategoryId"],
      color:json["color"],
      position:json["position"],
      imagePath:json["image"]

  );

  factory AttributeModel.fromJsonServerOrder(Map<String, dynamic> json) => AttributeModel(
      json["attributeId"],
      json["name"],
      "",
      json["attributeValue"],
      serverId:json["attributeId"],
      quantity:json["quantity"]
  );

  factory AttributeModel.fromJsonFromOrder(Map<String, dynamic> json) => AttributeModel(
      json[AttributeDao.columns.COL_ID],
      json[AttributeDao.columns.COL_NAME],
      json[AttributeDao.columns.COL_DISPLAY_NAME],
      json[AttributeDao.columns.COL_PRICE],
      serverId:json[AttributeDao.columns.COL_SERVER_ID],
      quantity:json[OrderDao.columnsAttribute.COL_QUANTITY],
      categoryID:json[AttributeDao.columns.COL_CATEGORY_ID],
      catServerId:json[AttributeDao.columns.COL_CAT_SERVER_ID],
      color:json[AttributeDao.columns.COL_COLOR],
      position:json[AttributeDao.columns.COL_POSITION],
      isSyncedOnServer: json[AttributeDao.columns.COL_IS_SYNCED_ON_SERVER]
  );

  Map<String, dynamic> toJson() => {
    AttributeDao.columns.COL_ID: id,
    AttributeDao.columns.COL_NAME: name,
    AttributeDao.columns.COL_DISPLAY_NAME: displayName,
    AttributeDao.columns.COL_PRICE: price,
    AttributeDao.columns.COL_SERVER_ID:serverId,
    AttributeDao.columns.COL_CATEGORY_ID: categoryID,
    AttributeDao.columns.COL_CAT_SERVER_ID: catServerId,
    AttributeDao.columns.COL_COLOR: color,
    AttributeDao.columns.COL_POSITION: position,
    AttributeDao.columns.COL_IMAGE_PATH: imagePath,
    AttributeDao.columns.COL_IS_SYNCED_ON_SERVER: isSyncedOnServer,
    AttributeDao.columns.COL_IS_SYNC_ON_SERVER_PROCESSING: isSyncOnServerProcessing,
    AttributeDao.columns.COL_SYNC_ON_SERVER_ACTION_PENDING: syncOnServerActionPending,

    //"quantity": quantity,
  };
  Map<String, dynamic> toJsonForOrder() => {
    AttributeDao.columns.COL_ID: id,
    AttributeDao.columns.COL_NAME: name,
    AttributeDao.columns.COL_DISPLAY_NAME: displayName,
    AttributeDao.columns.COL_PRICE: price,
    AttributeDao.columns.COL_SERVER_ID:serverId,
    AttributeDao.columns.COL_CATEGORY_ID: categoryID,
    AttributeDao.columns.COL_CAT_SERVER_ID: catServerId,
    AttributeDao.columns.COL_COLOR: color,
    AttributeDao.columns.COL_POSITION: position,
    OrderDao.columnsAttribute.COL_QUANTITY: quantity,
    AttributeDao.columns.COL_IS_SYNCED_ON_SERVER: isSyncedOnServer,
    AttributeDao.columns.COL_IS_SYNC_ON_SERVER_PROCESSING: isSyncOnServerProcessing,
    AttributeDao.columns.COL_SYNC_ON_SERVER_ACTION_PENDING: syncOnServerActionPending
  };
}