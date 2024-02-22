import 'package:opti_food_app/data_models/delivery_fee_model.dart';
import 'package:opti_food_app/data_models/service_activation_model.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sembast/sembast.dart';
import 'package:sembast/sembast_io.dart';
import 'package:path/path.dart';

import 'app_database.dart';

class DeliveryFeeDao{
  static _Columns columns = const _Columns();
  static const String folderName = "DeliveryFee";
  final _deliveryFeeDaoFolder = intMapStoreFactory.store(folderName);

  Future<Database> get _db async => await AppDatabase.instance.database;
  
  Future insertDeliveryFee(DeliveryFeeModel deliveryFeeModel) async {
    //Database _db = await getDatabase();
    var key = await _deliveryFeeDaoFolder.add(await _db, deliveryFeeModel.toJson());
    Finder finder = Finder(filter: Filter.byKey(key));
    deliveryFeeModel.id = key;
    await _deliveryFeeDaoFolder.update(await _db, deliveryFeeModel.toJson(),finder: finder);
    return deliveryFeeModel;
  }

  Future updateDeliveryFee(DeliveryFeeModel deliveryFeeModel) async {
    final finder = Finder(filter: Filter.equals(columns.COL_ID, deliveryFeeModel.id));
    await _deliveryFeeDaoFolder.update(await _db, deliveryFeeModel.toJson(), finder: finder);
  }

  Future deleteServiceActivation(DeliveryFeeModel deliveryFeeModel) async {
    //Database _db = await getDatabase();
    final finder = Finder(filter: Filter.equals(columns.COL_ID, deliveryFeeModel.id));
    await _deliveryFeeDaoFolder.delete(await _db, finder: finder);
  }


  Future<List<DeliveryFeeModel>> getAllDeliveryFees() async {
    //Database _db = await getDatabase();
    final recordSnapshot = await _deliveryFeeDaoFolder.find(await _db);
    return recordSnapshot.map((snapshot) {
      final deliveryFeeModels = DeliveryFeeModel.fromJson(snapshot.value);
      return deliveryFeeModels;
    }).toList();
  }

  Future<DeliveryFeeModel?> getDeliveryFeeByServerId(int serverId) async {
    List<SortOrder> sortList = [];
    sortList.add(SortOrder(columns.COL_ID));
    final recordSnapshot = await _deliveryFeeDaoFolder.find(await _db,finder: Finder(sortOrders: sortList,filter: Filter.equals(columns.COL_SERVER_ID, serverId)));
    if(recordSnapshot.length==0)
      return null;
    return recordSnapshot.map((snapshot) {
      final company = DeliveryFeeModel.fromJson(snapshot.value);
      return company;
    }).first;
  }


  Future<DeliveryFeeModel?> getDeliveryFeeLast() async {
    List<SortOrder> sortList = [];
    sortList.add(SortOrder(columns.COL_ID), );
    final recordSnapshot = await _deliveryFeeDaoFolder.find(await _db,finder: Finder(sortOrders: sortList));

    if(recordSnapshot.length==0)
      return null;
    return recordSnapshot.map((snapshot) {
      final company = DeliveryFeeModel.fromJson(snapshot.value);
      return company;
    }).toList()[0];
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
  String get COL_ACTIVATE_DELIVERY_FEE => "activate_delivery_fee";
  String get COL_DELIVERY_FEE => "eat_in_mode";
  String get COL_MINIMUM_ORDER_AMOUNT_TO_EXPECT_DELIVERY_FEE => "minimum_order_amount_to_expect_delivery_fee";
  String get COL_DISPLAY_NAME => "display_name";
  String get COL_SERVER_ID => "server_id";
  String get COL_IS_SYNCED => "is_synced";
}