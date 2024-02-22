
import 'package:opti_food_app/database/private_chat_dao.dart';

class PrivateChatModel{
  int id;
  String message;
  int senderId;
  int receiverId;
  bool seen;
  String createdAt;
  bool? isSynced;
  int? serverId;
  bool? isSyncOnServerProcessing;
  String? syncOnServerActionPending;

  PrivateChatModel(
      this.id,this.message,this.senderId,this.receiverId,this.seen,this.createdAt,
      {this.serverId=0,this.isSynced=false,this.isSyncOnServerProcessing=false, this.syncOnServerActionPending="",});

  PrivateChatModel.clone(PrivateChatModel messageModelOriginal):
        this(messageModelOriginal.id,
          messageModelOriginal.message,
          messageModelOriginal.senderId,
          messageModelOriginal.receiverId,
          messageModelOriginal.seen,
          messageModelOriginal.createdAt,
          serverId: messageModelOriginal.serverId,
          isSynced: messageModelOriginal.isSynced,
          isSyncOnServerProcessing: messageModelOriginal.isSyncOnServerProcessing,
          syncOnServerActionPending: messageModelOriginal.syncOnServerActionPending

      );

  factory PrivateChatModel.fromJson(Map<String, dynamic> json) => PrivateChatModel(
    json[PrivateChatDao.columns.COL_ID],
    json[PrivateChatDao.columns.COL_MESSAGE],
    json[PrivateChatDao.columns.COL_SENDER_ID],
    json[PrivateChatDao.columns.COL_RECEIVER_ID],
    json[PrivateChatDao.columns.COL_SEEN],
    json[PrivateChatDao.columns.COL_CREATED_AT],
    serverId: json[PrivateChatDao.columns.COL_SERVER_ID],
    isSynced: json[PrivateChatDao.columns.COL_IS_SYNCED],
    isSyncOnServerProcessing: json[PrivateChatDao.columns.COL_IS_SYNC_ON_SERVER_PROCESSING],
    syncOnServerActionPending: json[PrivateChatDao.columns.COL_SYNC_ON_SERVER_ACTION_PENDING],
  );

  factory PrivateChatModel.fromJsonServer(Map<String, dynamic> json) => PrivateChatModel(
    json[PrivateChatDao.columns.COL_ID],
    json[PrivateChatDao.columns.COL_MESSAGE],
    json[PrivateChatDao.columns.COL_SENDER_ID],
    json[PrivateChatDao.columns.COL_RECEIVER_ID],
    json[PrivateChatDao.columns.COL_SEEN],
    json[PrivateChatDao.columns.COL_CREATED_AT],
    serverId: json[PrivateChatDao.columns.COL_ID],
    isSynced: json[PrivateChatDao.columns.COL_IS_SYNCED],
    isSyncOnServerProcessing: json[PrivateChatDao.columns.COL_IS_SYNC_ON_SERVER_PROCESSING],
    syncOnServerActionPending: json[PrivateChatDao.columns.COL_SYNC_ON_SERVER_ACTION_PENDING],
  );


  Map<String, dynamic> toJson() => {
    PrivateChatDao.columns.COL_ID: id,
    PrivateChatDao.columns.COL_MESSAGE: message,
    PrivateChatDao.columns.COL_SENDER_ID: senderId,
    PrivateChatDao.columns.COL_RECEIVER_ID: receiverId,
    PrivateChatDao.columns.COL_SEEN: seen,
    PrivateChatDao.columns.COL_CREATED_AT: createdAt,
    PrivateChatDao.columns.COL_SERVER_ID: serverId,
    PrivateChatDao.columns.COL_IS_SYNCED: isSynced,
    PrivateChatDao.columns.COL_IS_SYNC_ON_SERVER_PROCESSING: isSyncOnServerProcessing,
    PrivateChatDao.columns.COL_SYNC_ON_SERVER_ACTION_PENDING: syncOnServerActionPending,
  };

}