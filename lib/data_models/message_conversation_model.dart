import 'package:flutter/material.dart';


import '../database/message_conversation_dao.dart';
import '../database/message_dao.dart';
import '../database/order_dao.dart';
import '../main.dart';
import 'attribute_model.dart';

class MessageConversationModel{
  int id;
  String message;
  bool? isSynced;
  String messageType;
  int? serverId;
  int userId;
  String createdAt;

  String firstName;
  String middleName;
  String lastName;
  String userType;

  bool? isSyncOnServerProcessing;
  String syncOnServerActionPending;

  MessageConversationModel(
      this.id,this.message,
  this.createdAt,
      {this.serverId=0,this.isSynced=false,this.isSyncOnServerProcessing=false, this.syncOnServerActionPending="",
        this.userId=0, this.firstName="",this.middleName="",
      this.lastName="", this.messageType="",this.userType=''});

  MessageConversationModel.clone(MessageConversationModel messageModelOriginal):
        this(messageModelOriginal.id,
          messageModelOriginal.message,
          messageModelOriginal.createdAt,
          messageType:messageModelOriginal.messageType,
          serverId: messageModelOriginal.serverId,
          isSynced: messageModelOriginal.isSynced,
          userId: messageModelOriginal.userId,
          firstName: messageModelOriginal.firstName,
          middleName: messageModelOriginal.middleName,
          lastName: messageModelOriginal.lastName,
          userType: messageModelOriginal.userType,
          isSyncOnServerProcessing: messageModelOriginal.isSyncOnServerProcessing,
          syncOnServerActionPending: messageModelOriginal.syncOnServerActionPending

      );

  factory MessageConversationModel.fromJson(Map<String, dynamic> json) => MessageConversationModel(
    json[MessageConversationDao.columns.COL_ID],
    json[MessageConversationDao.columns.COL_MESSAGE],
    json[MessageConversationDao.columns.COL_CREATED_AT],
    messageType:json[MessageConversationDao.columns.COL_MESSAGE_TYPE],
    serverId: json[MessageConversationDao.columns.COL_SERVER_ID],
    isSynced: json[MessageConversationDao.columns.COL_IS_SYNCED],
    userId: json[MessageConversationDao.columns.COL_USER_ID],
    firstName: json[MessageConversationDao.columns.COL_FIRST_NAME],
    middleName: json[MessageConversationDao.columns.COL_MIDDLE_NAME],
    lastName: json[MessageConversationDao.columns.COL_LAST_NAME],
    userType: json[MessageConversationDao.columns.COL_USER_TYPE],
    isSyncOnServerProcessing: json[MessageConversationDao.columns.COL_IS_SYNC_ON_SERVER_PROCESSING],
    syncOnServerActionPending: json[MessageConversationDao.columns.COL_SYNC_ON_SERVER_ACTION_PENDING],
  );

  factory MessageConversationModel.fromJsonServer(Map<String, dynamic> json) => MessageConversationModel(
    json['messageChatId'],
    json['message'],
    json['createdAt'],
    //messageType:int.parse(optifoodSharedPrefrence.getString('id').toString())==json['userId']?"sender":"receiver",
    messageType:optifoodSharedPrefrence.getInt('id')==json['userId']?"sender":"receiver",
    serverId: json['messageChatId'],
    userId: json['userId'],
    firstName: json["firstName"]!=null?json["firstName"]:"",
    middleName: json["middleName"]!=null?json["middleName"]:"",
    lastName: json["lastName"]!=null?json["lastName"]:"",
      userType: json["userType"]==null?"":json["userType"]

  );


  Map<String, dynamic> toJson() => {
    MessageConversationDao.columns.COL_ID: id,
    MessageConversationDao.columns.COL_MESSAGE: message,
    MessageConversationDao.columns.COL_MESSAGE_TYPE: messageType,
    MessageConversationDao.columns.COL_SERVER_ID: serverId,
    MessageConversationDao.columns.COL_USER_ID: userId,
    MessageConversationDao.columns.COL_IS_SYNCED: isSynced,
    MessageConversationDao.columns.COL_CREATED_AT: createdAt,

    MessageConversationDao.columns.COL_FIRST_NAME: firstName,
    MessageConversationDao.columns.COL_MIDDLE_NAME: middleName,
    MessageConversationDao.columns.COL_LAST_NAME: lastName,
    MessageConversationDao.columns.COL_USER_TYPE: userType,

    MessageConversationDao.columns.COL_IS_SYNC_ON_SERVER_PROCESSING: isSyncOnServerProcessing,
    MessageConversationDao.columns.COL_SYNC_ON_SERVER_ACTION_PENDING: syncOnServerActionPending,
  };

}