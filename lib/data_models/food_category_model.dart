import 'package:flutter/material.dart';
import 'package:opti_food_app/database/food_items_dao.dart';

import '../database/food_category_dao.dart';

class FoodCategoryModel{
  int id;
  String name;
  String displayName;
  String color;
  int position;
  String? imagePath;
  bool isHideInKitchen;
  bool isAttributeMandatory;
  int foodItemsCount;
  bool isSyncedOnServer;
  bool isSyncOnServerProcessing;
  String syncOnServerActionPending;
  int? serverId;

  FoodCategoryModel(this.id,this.name,this.displayName,this.color,this.position,this.isHideInKitchen,
      this.isAttributeMandatory,this.imagePath,{this.serverId=0,this.isSyncedOnServer=true,this.isSyncOnServerProcessing=false,this.syncOnServerActionPending="",this.foodItemsCount=0});

  factory FoodCategoryModel.fromJson(Map<String, dynamic> json) => FoodCategoryModel(
      json[FoodCategoryDao.columns.COL_ID],
      json[FoodCategoryDao.columns.COL_NAME],
      json[FoodCategoryDao.columns.COL_DISPLAY_NAME],
      json[FoodCategoryDao.columns.COL_COLOR],
      json[FoodCategoryDao.columns.COL_POSITION],
      json[FoodCategoryDao.columns.COL_IS_HIDE_IN_KITCHEN],
      json[FoodCategoryDao.columns.COL_IS_ATTRIBUTE_MANDATORY],
      json[FoodCategoryDao.columns.COL_IMAGE_PATH],
      serverId: json[FoodCategoryDao.columns.COL_SERVER_ID],
    isSyncedOnServer:json[FoodCategoryDao.columns.COL_IS_SYNCED_ON_SERVER],
    isSyncOnServerProcessing:json[FoodCategoryDao.columns.COL_IS_SYNC_ON_SERVER_PROCESSING],
    syncOnServerActionPending:json[FoodCategoryDao.columns.COL_SYNC_ON_SERVER_ACTION_PENDING],
    foodItemsCount: json[FoodCategoryDao.columns.COL_FOOD_ITEMS_COUNT],

  );

  Map<String, dynamic> toJson() => {
    FoodCategoryDao.columns.COL_ID: id,
    FoodCategoryDao.columns.COL_NAME: name,
    FoodCategoryDao.columns.COL_DISPLAY_NAME: displayName,
    FoodCategoryDao.columns.COL_COLOR: color,
    FoodCategoryDao.columns.COL_POSITION: position,
    FoodCategoryDao.columns.COL_IS_HIDE_IN_KITCHEN: isHideInKitchen,
    FoodCategoryDao.columns.COL_IS_ATTRIBUTE_MANDATORY: isAttributeMandatory,
    FoodCategoryDao.columns.COL_IMAGE_PATH: imagePath,
    FoodCategoryDao.columns.COL_SERVER_ID:serverId,
    FoodCategoryDao.columns.COL_IS_SYNCED_ON_SERVER:isSyncedOnServer,
    FoodCategoryDao.columns.COL_IS_SYNC_ON_SERVER_PROCESSING:isSyncOnServerProcessing,
    FoodCategoryDao.columns.COL_SYNC_ON_SERVER_ACTION_PENDING:syncOnServerActionPending,
    FoodCategoryDao.columns.COL_FOOD_ITEMS_COUNT: foodItemsCount,
  };
  factory FoodCategoryModel.fromJsonServer(Map<String, dynamic> json) => FoodCategoryModel(
     json["itemCategoryId"],
      json["itemCategoryName"],
      json["displayName"]!=null?json["displayName"]:"",
      json[FoodCategoryDao.columns.COL_COLOR]!=null?json[FoodCategoryDao.columns.COL_COLOR]:"FFFFFF",
      json[FoodCategoryDao.columns.COL_POSITION]!=null?json[FoodCategoryDao.columns.COL_POSITION]:0,
      json["showKichen"],
      json["attributeRequired"],
      json["image"],
      serverId:json["itemCategoryId"],
    foodItemsCount: json["foodItemsCount"]!=null?json["foodItemsCount"]:0,

  );


  @override
  String toString() {
    // TODO: implement toString
    String data = "id : ${id}, name : ${name}, color : ${color}, position : ${position}, serverId:${serverId}";
    return data;
  }
}
