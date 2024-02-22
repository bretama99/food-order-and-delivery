
import 'package:opti_food_app/database/private_chat_dao.dart';

import '../database/group_dao.dart';

class GroupModel{
  int id;
  String name;
  String? createdAt;
  String? imagePath;
  bool? isSynced;
  int? serverId;
  bool? isSyncOnServerProcessing;
  String? syncOnServerActionPending;

  GroupModel(
      this.id,this.name,
      {this.serverId=0,this.isSynced=false,this.isSyncOnServerProcessing=false, this.syncOnServerActionPending="", this.createdAt, this.imagePath});

  GroupModel.clone(GroupModel groupModelOriginal):
        this(groupModelOriginal.id,
          groupModelOriginal.name,
          createdAt: groupModelOriginal.createdAt,
          imagePath: groupModelOriginal.imagePath,
          serverId: groupModelOriginal.serverId,
          isSynced: groupModelOriginal.isSynced,
          isSyncOnServerProcessing: groupModelOriginal.isSyncOnServerProcessing,
          syncOnServerActionPending: groupModelOriginal.syncOnServerActionPending

      );

  factory GroupModel.fromJson(Map<String, dynamic> json) => GroupModel(
    json[GroupDao.columns.COL_ID],
    json[GroupDao.columns.COL_NAME],
    createdAt: json[GroupDao.columns.COL_CREATED_AT],
    imagePath: json[GroupDao.columns.COL_IMAGE_PATH],
    serverId: json[GroupDao.columns.COL_SERVER_ID],
    isSynced: json[GroupDao.columns.COL_IS_SYNCED],
    isSyncOnServerProcessing: json[GroupDao.columns.COL_IS_SYNC_ON_SERVER_PROCESSING],
    syncOnServerActionPending: json[GroupDao.columns.COL_SYNC_ON_SERVER_ACTION_PENDING],
  );

  factory GroupModel.fromJsonServer(Map<String, dynamic> json) => GroupModel(
    json[GroupDao.columns.COL_ID],
    json[GroupDao.columns.COL_NAME],
    createdAt: json[GroupDao.columns.COL_CREATED_AT],
    imagePath: json[GroupDao.columns.COL_IMAGE_PATH],
    serverId: json[GroupDao.columns.COL_SERVER_ID],
    isSynced: json[GroupDao.columns.COL_IS_SYNCED],
    isSyncOnServerProcessing: json[GroupDao.columns.COL_IS_SYNC_ON_SERVER_PROCESSING],
    syncOnServerActionPending: json[GroupDao.columns.COL_SYNC_ON_SERVER_ACTION_PENDING],
  );


  Map<String, dynamic> toJson() => {
    GroupDao.columns.COL_ID: id,
    GroupDao.columns.COL_NAME: name,
    GroupDao.columns.COL_CREATED_AT: createdAt,
    GroupDao.columns.COL_IMAGE_PATH: imagePath,
    GroupDao.columns.COL_SERVER_ID: serverId,
    GroupDao.columns.COL_IS_SYNCED: isSynced,
    GroupDao.columns.COL_IS_SYNC_ON_SERVER_PROCESSING: isSyncOnServerProcessing,
    GroupDao.columns.COL_SYNC_ON_SERVER_ACTION_PENDING: syncOnServerActionPending,
  };

}