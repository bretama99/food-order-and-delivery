import 'package:opti_food_app/data_models/service_activation_model.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sembast/sembast.dart';
import 'package:sembast/sembast_io.dart';
import 'package:path/path.dart';

import 'app_database.dart';

class ServiceActivationDao{
  static _Columns columns = const _Columns();
  static const String folderName = "ServiceActivation";
  final _serviceActivationFolder = intMapStoreFactory.store(folderName);

  Future<Database> get _db async => await AppDatabase.instance.database;

  Future insertServiceActivation(ServiceActivationModel serviceActivationModel) async {
    //Database _db = await getDatabase();
    var key = await _serviceActivationFolder.add(await _db, serviceActivationModel.toJson());
    Finder finder = Finder(filter: Filter.byKey(key));
    serviceActivationModel.id = key;
    await _serviceActivationFolder.update(await _db, serviceActivationModel.toJson(),finder: finder);
    return serviceActivationModel;
  }

  Future<int> updateServiceActivation(ServiceActivationModel serviceActivationModel) async {
    //Database _db = await getDatabase();
    final finder = Finder(filter: Filter.equals(columns.COL_ID, serviceActivationModel.id));
    int response = await _serviceActivationFolder.update(await _db, serviceActivationModel.toJson(), finder: finder);
    return response;
  }

  Future deleteServiceActivation(ServiceActivationModel serviceActivationModelel) async {
    //Database _db = await getDatabase();
    final finder = Finder(filter: Filter.equals(columns.COL_ID, serviceActivationModelel.id));
    await _serviceActivationFolder.delete(await _db, finder: finder);
  }


  Future<List<ServiceActivationModel>> getAllServiceActivation() async {
    //Database _db = await getDatabase();
    final recordSnapshot = await _serviceActivationFolder.find(await _db);
    return recordSnapshot.map((snapshot) {
      final serviceActivations = ServiceActivationModel.fromJson(snapshot.value);
      return serviceActivations;
    }).toList();
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
  String get COL_TAKEAWAY_MODE => "takeaway_mode";
  String get COL_EAT_IN_MODE => "eat_in_mode";
  String get COL_TABLE_MANAGEMENT => "table_management";
  String get COL_DELIVERY_MODE => "delivery_mode";
  String get COL_NIGHT_MODE => "night_mode";
  String get COL_SERVER_ID => "server_id";
  String get COL_IS_SYNCED => "is_synced";
}