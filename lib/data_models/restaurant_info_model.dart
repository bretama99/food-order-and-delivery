import 'package:flutter/foundation.dart';
import 'package:opti_food_app/database/user_dao.dart';

import '../database/restaurant_info_dao.dart';

class RestaurantInfoModel{
  int id;
  String name;
  String phoneNumber;
  String address;
  String startTime;
  String endTime;
  String email;
  String? imagePath;
  double lat;
  double lon;
  bool isSynced;
  int? serverId;

  RestaurantInfoModel(this.id, this.name, this.phoneNumber,this.address,this.startTime,this.endTime,
      this.email,{this.serverId=0,this.isSynced=false, this.imagePath,this.lat=0,this.lon=0});

  factory RestaurantInfoModel.fromJson(Map<String, dynamic> json){
    return RestaurantInfoModel(
        json[RestaurantInfoDao.columns.COL_ID],
        json[RestaurantInfoDao.columns.COL_NAME],
        json[RestaurantInfoDao.columns.COL_PHONE_NUMBER],
        json[RestaurantInfoDao.columns.COL_ADDRESS],
        json[RestaurantInfoDao.columns.COL_START_TIME],
        json[RestaurantInfoDao.columns.COL_END_TIME],
        json[RestaurantInfoDao.columns.COL_EMAIL],
      serverId: json[RestaurantInfoDao.columns.COL_SERVER_ID],
      isSynced: json[RestaurantInfoDao.columns.COL_IS_SYNCED],
        imagePath: json[RestaurantInfoDao.columns.COL_IMAGE_PATH],
        lat: json[RestaurantInfoDao.columns.COL_LAT],
        lon: json[RestaurantInfoDao.columns.COL_LON],
    );
  }

  factory RestaurantInfoModel.fromJsonServer(Map<String, dynamic> json){
    return RestaurantInfoModel(
      json[RestaurantInfoDao.columns.COL_ID]!=null?json[RestaurantInfoDao.columns.COL_ID]:0,
      json["restaurantName"],
      json["phoneNumber"],
      json["address"],
      json["openingTime"],
      json["closingTime"],
      json["email"],
      serverId: json["restaurantId"],
      isSynced: json[RestaurantInfoDao.columns.COL_IS_SYNCED]!=null?json[RestaurantInfoDao.columns.COL_IS_SYNCED]:true,
      imagePath: json["image"],
      lat: json["lat"],
      lon: json["lon"],
    );
  }
  Map<String, dynamic> toJson() => {
    RestaurantInfoDao.columns.COL_ID: id,
    RestaurantInfoDao.columns.COL_NAME: name,
    RestaurantInfoDao.columns.COL_PHONE_NUMBER: phoneNumber,
    RestaurantInfoDao.columns.COL_ADDRESS: address,
    RestaurantInfoDao.columns.COL_START_TIME: startTime,
    RestaurantInfoDao.columns.COL_END_TIME: endTime,
    RestaurantInfoDao.columns.COL_EMAIL: email,
    RestaurantInfoDao.columns.COL_SERVER_ID: serverId,
    RestaurantInfoDao.columns.COL_IS_SYNCED: isSynced,
    RestaurantInfoDao.columns.COL_IMAGE_PATH: imagePath,
    RestaurantInfoDao.columns.COL_LAT: lat,
    RestaurantInfoDao.columns.COL_LON: lon

  };


}