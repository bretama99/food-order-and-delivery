import 'package:opti_food_app/data_models/reservation_model.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sembast/sembast.dart';
import 'package:sembast/sembast_io.dart';

import 'package:path/path.dart';

import 'app_database.dart';
class ReservationDao{
  static _Columns columns = const _Columns();
  static const String folderName = "Reservation";
  final _reservationFolder = intMapStoreFactory.store(folderName);

  Future<Database> get _db async => await AppDatabase.instance.database;

  Future<ReservationModel> insertReservation(ReservationModel reservationModel) async {
    //Database _db = await getDatabase();
    var key = await _reservationFolder.add(await _db, reservationModel.toJson());
    Finder finder = Finder(filter: Filter.byKey(key));
    reservationModel.id = key;
    await _reservationFolder.update(await _db, reservationModel.toJson(),finder: finder);
    return reservationModel;
  }

  Future <List<ReservationModel>> getReservationList(String date) async {
    //Database _db = await getDatabase();
    final recordSnapshot = await _reservationFolder. find(await _db,finder: Finder(filter: Filter.equals(ReservationDao.columns.COL_RESERVATION_DATE, date)));
    return recordSnapshot.map((snapshot) {
      final restaurantInfo = ReservationModel.fromJson(snapshot.value);
      return restaurantInfo;
    }).toList();
  }

  Future delete(ReservationModel reservationModel) async {
    //Database _db = await getDatabase();
    final finder = Finder(filter: Filter.equals(columns.COL_ID, reservationModel.id));
    await _reservationFolder.delete(await _db, finder: finder);
  }

  Future updateReservation(ReservationModel reservationModel) async {
    //Database _db = await getDatabase();
    //final finder = Finder(filter: Filter.byKey(order.id));
    final finder = Finder(filter: Filter.equals(columns.COL_ID, reservationModel.id));
    await _reservationFolder.update(await _db, reservationModel.toJson(), finder: finder);
  }

  Future<ReservationModel?> getReservationByServerId(int serverId) async {
    //Database _db = await getDatabase();
    List<SortOrder> sortList = [];
    sortList.add(SortOrder(columns.COL_ID));
    final recordSnapshot = await _reservationFolder.find(await _db,finder: Finder(sortOrders: sortList,filter: Filter.equals(columns.COL_SERVER_ID, serverId)));
    if(recordSnapshot.length==0)
      return null;
    return recordSnapshot.map((snapshot) {
      final reservation = ReservationModel.fromJson(snapshot.value);
      return reservation;
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
  String get COL_RESERVATION_DATE => "reservation_date";
  String get COL_RESERVATION_TIME => "reservation_time";
  String get COL_TYPE_OF_RESERVATION => "type_of_reservation";
  String get COL_NO_OF_PERSONS => "no_of_persons";
  String get COL_COMMENT => "comment";
  String get COL_STATUS => "status";
  String get COL_SERVER_ID => "server_id";
  String get COL_IS_SYNCED => "is_synced";
}