import 'package:opti_food_app/data_models/group_model.dart';
import 'package:opti_food_app/data_models/message_model.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sembast/sembast.dart';
import 'package:sembast/sembast_io.dart';
import 'package:path/path.dart';

class GroupDao
{
  static _Columns columns = const _Columns();
  static const String folderName = "Group";
  final _groupFolder = intMapStoreFactory.store(folderName);

  Future<GroupModel> insertGroup(GroupModel groupModel) async {
    Database _db = await getDatabase();
    var key = await _groupFolder.add(_db, groupModel.toJson());
    Finder finder = Finder(filter: Filter.byKey(key));
    groupModel.id = key;
    await _groupFolder.update(_db, groupModel.toJson(),finder: finder);
    return groupModel;
  }

  Future updateGroup(GroupModel groupModel) async {
    Database _db = await getDatabase();
    final finder = Finder(filter: Filter.equals(columns.COL_ID, groupModel.id));
    await _groupFolder.update(await _db, groupModel.toJson(), finder: finder);
  }

  Future delete(GroupModel groupModel) async {
    Database _db = await getDatabase();
    final finder = Finder(filter: Filter.equals(columns.COL_ID, groupModel.id));
    await _groupFolder.delete(await _db, finder: finder);
  }


  Future<List<GroupModel>> getAllGroups() async {
    Database _db = await getDatabase();
    List<SortOrder> sortList = [];
    sortList.add(SortOrder(columns.COL_ID));
    final recordSnapshot = await _groupFolder.find(await _db,finder: Finder(sortOrders: sortList));
    return recordSnapshot.map((snapshot) {
      final groups = GroupModel.fromJson(snapshot.value);
      return groups;
    }).toList();
  }

  Future<List<GroupModel>> getUnSyncedGroups() async {
    Database _db = await getDatabase();
    List<Filter> filterList = [
      Filter.equals(columns.COL_IS_SYNCED, false),
      Filter.equals(columns.COL_IS_SYNC_ON_SERVER_PROCESSING, false)
    ];
    final recordSnapshot = await _groupFolder.find(await _db,finder: Finder(filter: Filter.and(filterList),sortOrders: [SortOrder(columns.COL_ID)]));
    return recordSnapshot.map((snapshot) {
      final groups = GroupModel.fromJson(snapshot.value);
      return groups;
    }).toList();
  }

  Future<GroupModel> getGroupById(int id) async {
    Database _db = await getDatabase();
    List<SortOrder> sortList = [];
    sortList.add(SortOrder(columns.COL_ID));
    final recordSnapshot = await _groupFolder.find(await _db,finder: Finder(sortOrders: sortList,filter: Filter.equals(columns.COL_ID, id)));
    return recordSnapshot.map((snapshot) {
      final groups = GroupModel.fromJson(snapshot.value);
      return groups;
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
  String get COL_NAME => "name";
  String get COL_CREATED_AT => "created_at";
  String get COL_IMAGE_PATH => "image_path";
  String get COL_SERVER_ID => "server_id";
  String get COL_IS_SYNCED => "is_synced";
  String get COL_IS_SYNC_ON_SERVER_PROCESSING => "is_sync_on_server_processing";
  String get COL_SYNC_ON_SERVER_ACTION_PENDING=> "sync_on_server_action_pending";
}