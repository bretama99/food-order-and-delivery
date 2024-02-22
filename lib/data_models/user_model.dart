import 'package:flutter/foundation.dart';
import 'package:opti_food_app/data_models/private_chat_model.dart';
import 'package:opti_food_app/database/user_dao.dart';

class UserModel{
  int id;
  String name;
  String phoneNumber;
  String email;
  String password;
  String role;
  String? imagePath;
  bool isActivated;
  bool isAssigned;
  bool isSynced;
  String? serverId;
  int? intServerId;
  double latitude;
  double longitude;
  bool? isSyncOnServerProcessing;
  String syncOnServerActionPending;
  bool isDeliveryBoyActive;
  List<PrivateChatModel>? privateChats = [];

  UserModel(this.id, this.name, this.phoneNumber, this.email, this.password, this.role,this.isDeliveryBoyActive,
      {this.serverId="",this.isSynced=false,this.imagePath,this.isActivated = true, this.isAssigned=false,
        this.isSyncOnServerProcessing=false, this.syncOnServerActionPending="", this.intServerId=0, this.latitude=0,this.longitude=0, this.privateChats});


  factory UserModel.fromJson(Map<String, dynamic> json){;
    return UserModel(
        json[UserDao.columns.COL_ID],
        json[UserDao.columns.COL_NAME],
        json[UserDao.columns.COL_PHONE_NUMBER],
        json[UserDao.columns.COL_EMAIL],
        json[UserDao.columns.COL_PASSWORD],
        json[UserDao.columns.COL_ROLE],
        json[UserDao.columns.COL_IS_DELIVERY_BOY_ACTIVE],
        serverId: json[UserDao.columns.COL_SERVER_ID],
        intServerId: json[UserDao.columns.COL_INT_SERVER_ID],
        isSynced: json[UserDao.columns.COL_IS_SYNCED],
        isAssigned:json[UserDao.columns.COL_IS_ASSIGNED],
        imagePath: json[UserDao.columns.COL_IMAGE_PATH],
        //isActivated: json['userStatus']=="Active"?true:false,
        isActivated: json[UserDao.columns.COL_IS_ACTIVATED],
        latitude: json[UserDao.columns.COL_LATITUDE],
        longitude: json[UserDao.columns.COL_LONGITUDE],
        privateChats: []
    );
  }

  factory UserModel.fromJsonServer(Map<String, dynamic> json){
    return UserModel(
        json[UserDao.columns.COL_ID],
        json['firstName']+" "+json['middleName']+" "+json['lastName'],
        json['mobilePhone'],
        json['email'],
        json['email'],
        json['userType'],
        json["deliveryBoyActive"],
        serverId: json['userId'],
        intServerId: json['id'],
        isSynced: true,
        imagePath: json['profilePicture'],
        isActivated: json['userStatus']=="Active"?true:false,
        latitude: json['latitude']!=null?json['latitude']:0.0,
        longitude: json['longitude']!=null?json['longitude']:0.0
    );
  }
  // UserModel.empty();

  Map<String, dynamic> toJson() => {
    UserDao.columns.COL_ID: id,
    UserDao.columns.COL_NAME: name,
    UserDao.columns.COL_PHONE_NUMBER: phoneNumber,
    UserDao.columns.COL_EMAIL: email,
    UserDao.columns.COL_PASSWORD: password,
    UserDao.columns.COL_ROLE: role,
    UserDao.columns.COL_IS_DELIVERY_BOY_ACTIVE: isDeliveryBoyActive,
    UserDao.columns.COL_SERVER_ID: serverId,
    UserDao.columns.COL_INT_SERVER_ID: intServerId,
    UserDao.columns.COL_IS_SYNCED: isSynced,
    UserDao.columns.COL_IS_ASSIGNED: isAssigned,
    UserDao.columns.COL_IMAGE_PATH: imagePath,
    UserDao.columns.COL_IS_ACTIVATED: isActivated,
    UserDao.columns.COL_LATITUDE: latitude,
    UserDao.columns.COL_LONGITUDE: longitude
  };
}