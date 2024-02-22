import 'package:path_provider/path_provider.dart';
import 'package:sembast/sembast.dart';
import 'package:sembast/sembast_io.dart';
import 'package:path/path.dart';

import '../data_models/restaurant_info_model.dart';
import '../data_models/user_model.dart';
import 'app_database.dart';

class RestaurantInfoDao
{
  static _Columns columns = const _Columns();
  static const String folderName = "Restaurant";
  final _restaurantInfoFolder = intMapStoreFactory.store(folderName);

  Future<Database> get _db async => await AppDatabase.instance.database;


  Future insertRestaurantInfo(RestaurantInfoModel restaurantInfoModel) async {
    //Database _db = await getDatabase();
    var key = await _restaurantInfoFolder.add(await _db, restaurantInfoModel.toJson());

    Finder finder = Finder(filter: Filter.byKey(key));
    restaurantInfoModel.id = key;
    await _restaurantInfoFolder.update(await _db, restaurantInfoModel.toJson(),finder: finder);
    return restaurantInfoModel;
  }

  Future updateRestaurantInfo(RestaurantInfoModel restaurantInfoModel) async {
    //Database _db = await getDatabase();
    final finder = Finder(filter: Filter.byKey(restaurantInfoModel.id));
    await _restaurantInfoFolder.update(await _db, restaurantInfoModel.toJson(), finder: finder);
  }

  Future <RestaurantInfoModel> getRestaurantInfo() async {
    //Database _db = await getDatabase();
    final recordSnapshot = await _restaurantInfoFolder.find(await _db);

    var restaurantInfoModelList= recordSnapshot.map((snapshot) {
      final restaurantInfo = RestaurantInfoModel.fromJson(snapshot.value);
      return restaurantInfo;
    }).toList();
    RestaurantInfoModel restaurantInfoModel=RestaurantInfoModel(0, "", "0", "", "", "", "");
    return restaurantInfoModelList.length>0?restaurantInfoModelList.first:restaurantInfoModel;
  }

  Future<RestaurantInfoModel?> getRestaurantInfoByServerId(int serverId) async {
    //Database _db = await getDatabase();
    List<SortOrder> sortList = [];
    sortList.add(SortOrder(columns.COL_ID));
    final recordSnapshot = await _restaurantInfoFolder.find(await _db,finder: Finder(sortOrders: sortList,filter: Filter.equals(columns.COL_SERVER_ID, serverId)));
    if(recordSnapshot.length==0)
      return null;
    return recordSnapshot.map((snapshot) {
      final restaurantInfos = RestaurantInfoModel.fromJson(snapshot.value);
      return restaurantInfos;
    }).first;
  }

  /*Future<Database> getDatabase() async
  {
    final appDocumentDir = await getApplicationDocumentsDirectory();
    // Path with the form: /platform-specific-directory/demo.db
    final dbPath = join(appDocumentDir.path, 'Optifood_nosql.db');

    final database = await databaseFactoryIo.openDatabase(dbPath);
    return database;
  }*/
}
class _Columns
{
  const _Columns();
  String get COL_ID => "id";
  String get COL_NAME => "name";
  String get COL_PHONE_NUMBER => "phone_number";
  String get COL_ADDRESS => "address";
  String get COL_START_TIME => "start_time";
  String get COL_END_TIME => "end_time";
  String get COL_EMAIL => "email";
  String get COL_ROLE => "role";
  String get COL_IMAGE_PATH => "image_path";
  String get COL_LAT => "lat";
  String get COL_LON => "lon";
  String get COL_SERVER_ID => "server_id";
  String get COL_IS_SYNCED => "is_synced";
}