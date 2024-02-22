import 'package:flutter/material.dart';
import 'package:opti_food_app/data_models/food_category_model.dart';
import 'package:opti_food_app/data_models/food_items_model.dart';
import 'package:opti_food_app/data_models/message_model.dart';
import 'package:opti_food_app/data_models/order_model.dart';
import 'package:opti_food_app/database/food_items_dao.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sembast/sembast.dart';
import 'package:sembast/sembast_io.dart';
import 'package:path/path.dart';

import 'app_database.dart';

class MessageDao
{
  static _Columns columns = const _Columns();
  static const String folderName = "Message";
  final _messageFolder = intMapStoreFactory.store(folderName);

  Future<MessageModel> insertMessage(MessageModel messageModel) async {
    Database _db = await getDatabase();
    var key = await _messageFolder.add(_db, messageModel.toJson());
    Finder finder = Finder(filter: Filter.byKey(key));
    messageModel.id = key;
    await _messageFolder.update(_db, messageModel.toJson(),finder: finder);
    return messageModel;
  }

  Future updateMessage(MessageModel messageModel) async {
    Database _db = await getDatabase();
    final finder = Finder(filter: Filter.equals(columns.COL_ID, messageModel.id));
    await _messageFolder.update(await _db, messageModel.toJson(), finder: finder);
  }

  Future delete(MessageModel messageModel) async {
    Database _db = await getDatabase();
    final finder = Finder(filter: Filter.equals(columns.COL_ID, messageModel.id));
    await _messageFolder.delete(await _db, finder: finder);
  }


  Future<List<MessageModel>> getAllMessages() async {
    Database _db = await getDatabase();
    List<SortOrder> sortList = [];
    sortList.add(SortOrder(columns.COL_ID));
    final recordSnapshot = await _messageFolder.find(await _db,finder: Finder(sortOrders: sortList));
    return recordSnapshot.map((snapshot) {
      final messages = MessageModel.fromJson(snapshot.value);
      return messages;
    }).toList();
  }

  Future<List<MessageModel>> getUnSyncedMessages() async {
    Database _db = await getDatabase();
    List<Filter> filterList = [
      Filter.equals(columns.COL_IS_SYNCED, false),
      Filter.equals(columns.COL_IS_SYNC_ON_SERVER_PROCESSING, false)
    ];
    final recordSnapshot = await _messageFolder.find(await _db,finder: Finder(filter: Filter.and(filterList),sortOrders: [SortOrder(columns.COL_ID)]));
    return recordSnapshot.map((snapshot) {
      final messages = MessageModel.fromJson(snapshot.value);
      return messages;
    }).toList();
  }

  Future<MessageModel> getMessageById(int id) async {
    Database _db = await getDatabase();
    List<SortOrder> sortList = [];
    sortList.add(SortOrder(columns.COL_ID));
    final recordSnapshot = await _messageFolder.find(await _db,finder: Finder(sortOrders: sortList,filter: Filter.equals(columns.COL_ID, id)));
    return recordSnapshot.map((snapshot) {
      final messages = MessageModel.fromJson(snapshot.value);
      return messages;
    }).first;
  }


  Future<MessageModel?> getMessageByServerId(int serverId) async {
    Database _db = await getDatabase();
    final recordSnapshot = await _messageFolder.find(await _db,finder: Finder(filter: Filter.equals(columns.COL_SERVER_ID, serverId)));
    if(recordSnapshot.length==0)
      return null;
    return recordSnapshot.map((snapshot) {
      final messages = MessageModel.fromJson(snapshot.value);
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
  String get COL_MESSAGE_NAME => "message_name";
  String get COL_MESSAGE => "message";
  String get COL_SHOW_IN_MAIN_APP => "show_in_main_app";
  String get COL_SHOW__IN_KITCHEN => "show_in_kitchen";
  String get COL_SERVER_ID => "server_id";
  String get COL_IS_SYNCED => "is_synced";
  String get COL_IS_SYNC_ON_SERVER_PROCESSING => "is_sync_on_server_processing";
  String get COL_SYNC_ON_SERVER_ACTION_PENDING=> "sync_on_server_action_pending";
}