import 'package:path_provider/path_provider.dart';
import 'package:sembast/sembast.dart';
import 'package:sembast/sembast_io.dart';
import 'package:path/path.dart';

import '../data_models/private_chat_model.dart';

class PrivateChatDao
{
  static _Columns columns = const _Columns();
  static const String folderName = "PrivateChat";
  final _privateChatFolder = intMapStoreFactory.store(folderName);

  Future<PrivateChatModel> insertPrivateChat(PrivateChatModel privateChatModel) async {
    Database _db = await getDatabase();
    var key = await _privateChatFolder.add(_db, privateChatModel.toJson());
    Finder finder = Finder(filter: Filter.byKey(key));
    privateChatModel.id = key;
    await _privateChatFolder.update(_db, privateChatModel.toJson(),finder: finder);
    return privateChatModel;
  }

  Future updatePrivateChat(PrivateChatModel privateChatModel) async {
    Database _db = await getDatabase();
    final finder = Finder(filter: Filter.equals(columns.COL_ID, privateChatModel.id));
    await _privateChatFolder.update(await _db, privateChatModel.toJson(), finder: finder);
  }



  Future delete(PrivateChatModel privateChatModel) async {
    Database _db = await getDatabase();
    final finder = Finder(filter: Filter.equals(columns.COL_ID, privateChatModel.id));
    await _privateChatFolder.delete(await _db, finder: finder);
  }


  Future<List<PrivateChatModel>> getAllPrivateChats() async {
    Database _db = await getDatabase();
    List<SortOrder> sortList = [];
    sortList.add(SortOrder(columns.COL_ID));
    final recordSnapshot = await _privateChatFolder.find(await _db,finder: Finder(sortOrders: sortList));
    return recordSnapshot.map((snapshot) {
      final messages = PrivateChatModel.fromJson(snapshot.value);
      return messages;
    }).toList();
  }

  Future<List<PrivateChatModel>> getUnSyncedMessages() async {
    Database _db = await getDatabase();
    List<Filter> filterList = [
      Filter.equals(columns.COL_IS_SYNCED, false),
      Filter.equals(columns.COL_IS_SYNC_ON_SERVER_PROCESSING, false)
    ];
    final recordSnapshot = await _privateChatFolder.find(await _db,
        finder: Finder(filter: Filter.and(filterList),sortOrders: [SortOrder(columns.COL_ID)]));
    return recordSnapshot.map((snapshot) {
      final privateChats = PrivateChatModel.fromJson(snapshot.value);
      return privateChats;
    }).toList();
  }

  Future<PrivateChatModel> getMessageById(int id) async {
    Database _db = await getDatabase();
    List<SortOrder> sortList = [];
    sortList.add(SortOrder(columns.COL_ID));
    final recordSnapshot = await _privateChatFolder.find(await _db,finder: Finder(sortOrders: sortList,filter: Filter.equals(columns.COL_ID, id)));
    return recordSnapshot.map((snapshot) {
      final privateChats = PrivateChatModel.fromJson(snapshot.value);
      return privateChats;
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
  String get COL_SENDER_ID => "sender_id";
  String get COL_RECEIVER_ID => "receiver_id";
  String get COL_SEEN => "seen";
  String get COL_CREATED_AT => "created_at";
  String get COL_SERVER_ID => "server_id";
  String get COL_IS_SYNCED => "is_synced";
  String get COL_IS_SYNC_ON_SERVER_PROCESSING => "is_sync_on_server_processing";
  String get COL_SYNC_ON_SERVER_ACTION_PENDING=> "sync_on_server_action_pending";
}