import 'package:flutter/material.dart';
import 'package:opti_food_app/database/message_dao.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sembast/sembast.dart';
import 'package:sembast/sembast_io.dart';
import 'package:path/path.dart';

import '../data_models/message_conversation_model.dart';
import '../data_models/message_model.dart';
import 'app_database.dart';

class MessageConversationDao
{
  static _Columns columns = const _Columns();
  static const String folderName = "MessageConventional";
  final _messageConversationFolder = intMapStoreFactory.store(folderName);

  //Future<MessageConversationModel> insertMessageConversation(MessageConversationModel messageConversationModel) async {
  Future insertMessageConversation(MessageConversationModel messageConversationModel) async {
    if(messageConversationModel.serverId!=0) {
      if (await isMessageExist(messageConversationModel.serverId!)) {
        return null;
      }
    }
    Database _db = await getDatabase();
    var key = await _messageConversationFolder.add(_db, messageConversationModel.toJson());
    Finder finder = Finder(filter: Filter.byKey(key));
    messageConversationModel.id = key;
    await _messageConversationFolder.update(_db, messageConversationModel.toJson(),finder: finder);
    return messageConversationModel;
  }

  Future<bool> isMessageExist(int serverID) async {
    Database _db = await getDatabase();
    List<Filter> filterList = [
      Filter.equals(MessageDao.columns.COL_SERVER_ID, serverID),
      //Filter.equals(MessageDao.columns.COL_IS_SYNCED_ON_SERVER, true)
    ];
    //Finder finder = Finder(filter: Filter.equals(OrderDao.columns.COL_SERVER_ID, serverID));
    Finder finder = Finder(filter: Filter.and(filterList));
    var recordSnapshot = await _messageConversationFolder.find(await _db,
        finder: finder
    );
    if(recordSnapshot.isNotEmpty){
      return true;
    }
    else{
      return false;
    }
  }

  Future updateMessageConversation(MessageConversationModel messageConversationModel) async {
    Database _db = await getDatabase();
    final finder = Finder(filter: Filter.equals(columns.COL_ID, messageConversationModel.id));
    await _messageConversationFolder.update(await _db, messageConversationModel.toJson(), finder: finder);
  }

  Future delete(MessageConversationModel messageConversationModel) async {
    Database _db = await getDatabase();
    final finder = Finder(filter: Filter.equals(columns.COL_ID, messageConversationModel.id));
    await _messageConversationFolder.delete(await _db, finder: finder);
  }


  Future<MessageConversationModel?> getMessageConversationByServerId(int serverId) async {
    Database _db = await getDatabase();
    List<SortOrder> sortList = [];
    final recordSnapshot = await _messageConversationFolder.find(await _db,finder: Finder(filter: Filter.equals(columns.COL_SERVER_ID, serverId)));
    if(recordSnapshot.length==0)
      return null;
    return recordSnapshot.map((snapshot) {
      final messageConversation = MessageConversationModel.fromJson(snapshot.value);
      return messageConversation;
    }).first;
  }


  Future<List<MessageConversationModel>> getAllMessageConversations() async {
    Database _db = await getDatabase();
    List<SortOrder> sortList = [];
    sortList.add(SortOrder(columns.COL_ID));
    final recordSnapshot = await _messageConversationFolder.find(await _db,finder: Finder(sortOrders: sortList));
    return recordSnapshot.map((snapshot) {
      final messages = MessageConversationModel.fromJson(snapshot.value);
      return messages;
    }).toList();
  }

  Future<List<MessageConversationModel>> getUnSyncedMessageConversations() async {
    Database _db = await getDatabase();
    List<Filter> filterList = [
      Filter.equals(columns.COL_IS_SYNCED, false),
      Filter.equals(columns.COL_IS_SYNC_ON_SERVER_PROCESSING, false)
    ];
    final recordSnapshot = await _messageConversationFolder.find(await _db,finder: Finder(filter: Filter.and(filterList),sortOrders: [SortOrder(columns.COL_ID)]));
    return recordSnapshot.map((snapshot) {
      final messages = MessageConversationModel.fromJson(snapshot.value);
      return messages;
    }).toList();
  }

  Future<MessageConversationModel> getMessageConversationById(int id) async {
    Database _db = await getDatabase();
    List<SortOrder> sortList = [];
    sortList.add(SortOrder(columns.COL_ID));
    final recordSnapshot = await _messageConversationFolder.find(await _db,finder: Finder(sortOrders: sortList,filter: Filter.equals(columns.COL_ID, id)));
    return recordSnapshot.map((snapshot) {
      final messages = MessageConversationModel.fromJson(snapshot.value);
      return messages;
    }).first;
  }

  Future<Database> getDatabase() async
  {
    final appDocumentDir = await getApplicationDocumentsDirectory();
    final dbPath = join(appDocumentDir.path, 'Optifood_nosql.db');

    final database = await databaseFactoryIo.openDatabase(dbPath);
    return database;
  }
}
class _Columns
{
  const _Columns();
  String get COL_ID => "id";
  String get COL_MESSAGE => "message";
  String get COL_MESSAGE_TYPE => "message_type";
  String get COL_SERVER_ID => "server_id";
  String get COL_USER_ID => "user_id";
  String get COL_CREATED_AT => "created_at";

  String get COL_FIRST_NAME => "first_name";
  String get COL_MIDDLE_NAME => "middle_name";
  String get COL_LAST_NAME => "last_name";
  String get COL_USER_TYPE => "user_type";

  String get COL_IS_SYNCED => "is_synced";
  String get COL_IS_SYNC_ON_SERVER_PROCESSING => "is_sync_on_server_processing";
  String get COL_SYNC_ON_SERVER_ACTION_PENDING=> "sync_on_server_action_pending";
}