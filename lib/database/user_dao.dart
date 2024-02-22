import 'package:path_provider/path_provider.dart';
import 'package:sembast/sembast.dart';
import 'package:sembast/sembast_io.dart';
import 'package:path/path.dart';

import '../data_models/user_model.dart';

class UserDao
{
  static _Columns columns = const _Columns();
  static const String folderName = "User";
  final _userFolder = intMapStoreFactory.store(folderName);




  Future<UserModel> insertUser(UserModel userModel) async {
    Database _db = await getDatabase();
    var key = await _userFolder.add(_db, userModel.toJson());
    Finder finder = Finder(filter: Filter.byKey(key));
    userModel.id = key;
    await _userFolder.update(_db, userModel.toJson(),finder: finder);
    return userModel;
  }

  Future<UserModel> updateUser(UserModel userModel) async {
    Database _db = await getDatabase();
    final finder = Finder(filter: Filter.byKey(userModel.id));
    await _userFolder.update(await _db, userModel.toJson(), finder: finder);
    List<SortOrder> sortList = [];
    sortList.add(SortOrder(columns.COL_ID));
    final recordSnapshot = await _userFolder.find(await _db,finder: Finder(sortOrders: sortList,filter: Filter.equals(columns.COL_SERVER_ID, userModel.serverId)));
    return recordSnapshot.map((snapshot) {
      final userInfo = UserModel.fromJson(snapshot.value);
      return userInfo;
    }).first;
  }

  Future delete(UserModel userModel) async {
    Database _db = await getDatabase();
    //final finder = Finder(filter: Filter.byKey(order.id));
    final finder = Finder(filter: Filter.equals(columns.COL_ID, userModel.id));
    //final finder = Finder(filter: Filter.equals(columns.COL_ID, order.id));
    await _userFolder.delete(await _db, finder: finder);
  }




  Future<List<UserModel>> getAllUsers(String role) async {
    Database _db = await getDatabase();
    final finder = Finder(filter: Filter.equals(columns.COL_ROLE, role));
    final recordSnapshot = await _userFolder.find(await _db,finder: finder);
    return recordSnapshot.map((snapshot) {
      final users = UserModel.fromJson(snapshot.value);
      return users;
    }).toList();
  }

  Future<List<UserModel>> getAllUsersWithoutRole() async {
    Database _db = await getDatabase();
    final recordSnapshot = await _userFolder.find(await _db);
    return recordSnapshot.map((snapshot) {
      final users = UserModel.fromJson(snapshot.value);
      return users;
    }).toList();
  }

  Future<UserModel?> getUserByServerId(String? serverId) async {
    Database _db = await getDatabase();
    List<SortOrder> sortList = [];
    sortList.add(SortOrder(columns.COL_ID));
    final recordSnapshot = await _userFolder.find(await _db,finder: Finder(sortOrders: sortList,filter: Filter.equals(columns.COL_SERVER_ID, serverId)));
    if(recordSnapshot.length==0)
      return null;
    return recordSnapshot.map((snapshot) {
      final userInfo = UserModel.fromJson(snapshot.value);
      return userInfo;
    }).first;
  }

  Future<UserModel?> getUserByServerIntId(int? serverId) async {
    Database _db = await getDatabase();
    final recordSnapshot = await _userFolder.find(await _db,finder: Finder(filter: Filter.equals(columns.COL_INT_SERVER_ID, serverId)));

   if(recordSnapshot.length==0){
     return null;
   }
   else
    return recordSnapshot.map((snapshot) {
      final userInfo = UserModel.fromJson(snapshot.value);
      return userInfo;
    }).first;
  }


  Future<Database> getDatabase() async
  {
    final appDocumentDir = await getApplicationDocumentsDirectory();
    // Path with the form: /platform-specific-directory/demo.db
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
  String get COL_PHONE_NUMBER => "phone_number";
  String get COL_EMAIL => "email";
  String get COL_PASSWORD => "password";
  String get COL_ROLE => "role";
  String get COL_IMAGE_PATH => "image_path";
  String get COL_IS_ACTIVATED => "is_activated";
  String get COL_IS_ASSIGNED => "is_assigned";
  String get COL_SERVER_ID => "server_id";
  String get COL_INT_SERVER_ID => "int_server_id";
  String get COL_IS_SYNCED => "is_synced";
  String get COL_IS_SYNC_ON_SERVER_PROCESSING => "is_sync_on_server_processing";
  String get COL_SYNC_ON_SERVER_ACTION_PENDING=> "sync_on_server_action_pending";
  String get COL_LATITUDE => "latitude";
  String get COL_LONGITUDE => "longitude";
  String get COL_IS_DELIVERY_BOY_ACTIVE => "is_delivery_boy_active";

}