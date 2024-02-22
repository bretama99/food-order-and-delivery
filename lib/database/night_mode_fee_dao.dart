import 'package:opti_food_app/data_models/delivery_fee_model.dart';
import 'package:opti_food_app/data_models/night_mode_fee_model.dart';
import 'package:opti_food_app/data_models/service_activation_model.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sembast/sembast.dart';
import 'package:sembast/sembast_io.dart';
import 'package:path/path.dart';

import 'app_database.dart';

class NightModeFeeDao{
  static _Columns columns = const _Columns();
  static const String folderName = "NightModeFee";
  final _nightModeFeeDaoFolder = intMapStoreFactory.store(folderName);

  Future<Database> get _db async => await AppDatabase.instance.database;

  Future insertNightModeFee(NightModeFeeModel nightModeFeeModel) async {
    //Database _db = await getDatabase();
    var key = await _nightModeFeeDaoFolder.add(await _db, nightModeFeeModel.toJson());
    Finder finder = Finder(filter: Filter.byKey(key));
    nightModeFeeModel.id = key;
    await _nightModeFeeDaoFolder.update(await _db, nightModeFeeModel.toJson(),finder: finder);
    return nightModeFeeModel;
  }
  Future updateNightModeFee(NightModeFeeModel nightModeFeeModel) async {
    final finder = Finder(filter: Filter.equals(columns.COL_ID, nightModeFeeModel.id));
    await _nightModeFeeDaoFolder.update(await _db, nightModeFeeModel.toJson(), finder: finder);

  }
  // Future<int> updateNightModeFee(NightModeFeeModel nightModeFeeModel) async {
  //   //Database _db = await getDatabase();
  //   final finder = Finder(filter: Filter.equals(columns.COL_ID, nightModeFeeModel.id));
  //   int response = await _nightModeFeeDaoFolder.update(await _db, nightModeFeeModel.toJson(), finder: finder);
  //   return response;
  // }

  Future deleteNightModeFee(NightModeFeeModel nightModeFeeModel) async {
    //Database _db = await getDatabase();
    final finder = Finder(filter: Filter.equals(columns.COL_ID, nightModeFeeModel.id));
    await _nightModeFeeDaoFolder.delete(await _db, finder: finder);
  }


  Future<List<NightModeFeeModel>> getAllNightModeFee() async {
    //Database _db = await getDatabase();
    final recordSnapshot = await _nightModeFeeDaoFolder.find(await _db);
    return recordSnapshot.map((snapshot) {
      final nightModeFeeModels = NightModeFeeModel.fromJson(snapshot.value);
      return nightModeFeeModels;
    }).toList();
  }

  Future<NightModeFeeModel?> getNightModeFeeByServerId(int serverId) async {
    List<SortOrder> sortList = [];
    sortList.add(SortOrder(columns.COL_ID));
    final recordSnapshot = await _nightModeFeeDaoFolder.find(await _db,finder: Finder(sortOrders: sortList,filter: Filter.equals(columns.COL_SERVER_ID, serverId)));
    if(recordSnapshot.length==0)
      return null;
    return recordSnapshot.map((snapshot) {
      final company = NightModeFeeModel.fromJson(snapshot.value);
      return company;
    }).first;
  }

  Future<NightModeFeeModel?> getNightModeFeeLast() async {
    List<SortOrder> sortList = [];
    sortList.add(SortOrder(columns.COL_ID), );
    final recordSnapshot = await _nightModeFeeDaoFolder.find(await _db,finder: Finder(sortOrders: sortList));
    if(recordSnapshot.length==0)
      return null;
    return recordSnapshot.map((snapshot) {
      final company = NightModeFeeModel.fromJson(snapshot.value);
      return company;
    }).toList()[recordSnapshot.length-1];
  }
  /*Future<Database> getDatabase() async
  {
    final appDocumentDir = await getApplicationDocumentsDirectory();
    final dbPath = join(appDocumentDir.path, 'Optifood_nosql.db');
    final database = await databaseFactoryIo.openDatabase(dbPath);
    return database;
  }*/
}
class _Columns
{
  const _Columns();
  String get COL_ID => "id";
  String get COL_ACTIVATE_NIGHT_FEE_RESTAURANT => "activateNightFeeRestaurant";
  String get COL_ACTIVATE_NIGHT_FEE_DELIVERY => "activateNightFeeDelivery";
  String get COL_NIGHT_FEE => "nightFee";
  String get COL_START_TIME => "startTime";
  String get COL_END_TIME => "endTime";
  String get COL_SERVER_ID => "server_id";
  String get COL_IS_SYNCED => "is_synced";
}