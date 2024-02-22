import 'package:path_provider/path_provider.dart';
import 'package:sembast/sembast.dart';
import 'package:sembast/sembast_io.dart';
import 'package:path/path.dart';

import '../data_models/company_model.dart';
import 'app_database.dart';

class CompanyDao
{
  static _Columns columns = const _Columns();
  static const String folderName = "Company";
  final _companyFolder = intMapStoreFactory.store(folderName);

  Future<Database> get _db async => await AppDatabase.instance.database;


  Future<CompanyModel> insertCompany(CompanyModel companyModel) async {
    //Database _db = await getDatabase();
      var key = await _companyFolder.add(await _db, companyModel.toJson());
    Finder finder = Finder(filter: Filter.byKey(key));
    companyModel.id = key;
    await _companyFolder.update(await _db, companyModel.toJson(),finder: finder);
    return companyModel;
  }

  Future updateCompany(CompanyModel companyModel) async {
    //Database _db = await getDatabase();
    //final finder = Finder(filter: Filter.byKey(order.id));
    final finder = Finder(filter: Filter.equals(columns.COL_ID, companyModel.id));
    await _companyFolder.update(await _db, companyModel.toJson(), finder: finder);
  }

  Future updateCompanyByServerID(CompanyModel companyModel) async {
    //Database _db = await getDatabase();
    //final finder = Finder(filter: Filter.byKey(order.id));
    final finder = Finder(filter: Filter.equals(columns.COL_SERVER_ID, companyModel.serverId));
    await _companyFolder.update(await _db, companyModel.toJson(), finder: finder);
  }

   Future delete(CompanyModel companyModel) async {
    //Database _db = await getDatabase();
    //final finder = Finder(filter: Filter.byKey(order.id));
    final finder = Finder(filter: Filter.equals(columns.COL_ID, companyModel.id));
    //final finder = Finder(filter: Filter.equals(columns.COL_ID, order.id));
    await _companyFolder.delete(await _db, finder: finder);
  }

  Future<List<CompanyModel>> getAllCompanies() async {
    //Database _db = await getDatabase();
    final recordSnapshot = await _companyFolder.find(await _db);
    return recordSnapshot.map((snapshot) {
      final companies = CompanyModel.fromJson(snapshot.value);
      return companies;
    }).toList();
  }

  Future<CompanyModel> getCompanyById(int id)  async {
    //Database _db = await getDatabase();
    final recordSnapshot = await _companyFolder.find(await _db,finder: Finder(filter: Filter.equals(columns.COL_ID, id)));
    return recordSnapshot.map((snapshot) {
      final company = CompanyModel.fromJson(snapshot.value);
      return company;
    }).first;
  }

  Future<CompanyModel?> getCompanyByServerId(int serverId) async {
    List<SortOrder> sortList = [];
    sortList.add(SortOrder(columns.COL_ID));
    final recordSnapshot = await _companyFolder.find(await _db,finder: Finder(sortOrders: sortList,filter: Filter.equals(columns.COL_SERVER_ID, serverId)));
    if(recordSnapshot.length==0)
      return null;
    return recordSnapshot.map((snapshot) {
      final company = CompanyModel.fromJson(snapshot.value);
      return company;
    }).first;
  }


  Future<CompanyModel> getCompanyLast() async {
    List<SortOrder> sortList = [];
    sortList.add(SortOrder(columns.COL_ID), );
    final recordSnapshot = await _companyFolder.find(await _db,finder: Finder(sortOrders: sortList));
    return recordSnapshot.map((snapshot) {
      final company = CompanyModel.fromJson(snapshot.value);
      return company;
    }).toList()[recordSnapshot.length-1];
  }
  /*Future<Database> getDatabase() async
>>>>>>> 4955f82c23a30e44760451fc344c87ecea23e3b2
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
  String get COL_PHONE_NO => "phone_no";
  String get COL_ADDRESS => "address";
  String get COL_EMAIL => "email";
  String get COL_IMAGE_PATH => "image_path";
  String get COL_SERVER_ID => "server_id";
  String get COL_IS_SYNCED => "is_synced";
}