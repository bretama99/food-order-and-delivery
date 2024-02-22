
import '../database/attribute_category_dao.dart';
import '../database/food_category_dao.dart';

class AttributeCategoryModel{
  int id;
  int globalId;
  String name;
  String displayName;
  String color;
  int position;
  String? imagePath;
  int attributeCount;
  bool isSelected = false;
  bool isSyncedOnServer;
  bool isSyncOnServerProcessing;
  String syncOnServerActionPending;
  int? serverId;

  AttributeCategoryModel(this.id,this.name,this.displayName,this.color,this.position,this.imagePath,
      {this.serverId=0,this.attributeCount=0,this.globalId=0,this.isSyncedOnServer=true,this.isSyncOnServerProcessing=false,this.syncOnServerActionPending=""});

  factory AttributeCategoryModel.fromJson(Map<String, dynamic> json) => AttributeCategoryModel(
      json[AttributeCategoryDao.columns.COL_ID],
      json[AttributeCategoryDao.columns.COL_NAME],
      json[AttributeCategoryDao.columns.COL_DISPLAY_NAME],
      json[AttributeCategoryDao.columns.COL_COLOR],
      json[AttributeCategoryDao.columns.COL_POSITION],
      json[AttributeCategoryDao.columns.COL_IMAGE_PATH],
      serverId: json[AttributeCategoryDao.columns.COL_SERVER_ID],
      isSyncedOnServer:json[AttributeCategoryDao.columns.COL_IS_SYNCED_ON_SERVER],
      isSyncOnServerProcessing:json[AttributeCategoryDao.columns.COL_IS_SYNC_ON_SERVER_PROCESSING],
      syncOnServerActionPending:json[AttributeCategoryDao.columns.COL_SYNC_ON_SERVER_ACTION_PENDING],
      attributeCount: json[AttributeCategoryDao.columns.COL_ATTRIBUTE_COUNT],
      globalId: json[AttributeCategoryDao.columns.COL_GLOBAL_ID]!=null?json[AttributeCategoryDao.columns.COL_GLOBAL_ID]:0
  );

  factory AttributeCategoryModel.fromJsonServer(Map<String, dynamic> json) => AttributeCategoryModel(
    json['attributeCategoryId'],
    json['attributeCategoryName']!=null?json['attributeCategoryName']:"",
    json['displayName']!=null?json['displayName']:"",
    json['color'],
    json['position'],
    json['image'],
    serverId:json["attributeCategoryId"],
    attributeCount: json["foodAttributesCount"]==null?0:json["foodAttributesCount"],

  );

  Map<String, dynamic> toJson() => {
    AttributeCategoryDao.columns.COL_ID: id,
    AttributeCategoryDao.columns.COL_NAME: name,
    AttributeCategoryDao.columns.COL_DISPLAY_NAME: displayName,
    AttributeCategoryDao.columns.COL_COLOR: color,
    AttributeCategoryDao.columns.COL_POSITION: position,
    AttributeCategoryDao.columns.COL_IMAGE_PATH: imagePath,
    AttributeCategoryDao.columns.COL_SERVER_ID:serverId,
    AttributeCategoryDao.columns.COL_IS_SYNCED_ON_SERVER:isSyncedOnServer,
    AttributeCategoryDao.columns.COL_IS_SYNC_ON_SERVER_PROCESSING:isSyncOnServerProcessing,
    AttributeCategoryDao.columns.COL_SYNC_ON_SERVER_ACTION_PENDING:syncOnServerActionPending,
    AttributeCategoryDao.columns.COL_ATTRIBUTE_COUNT: attributeCount
  };
}
