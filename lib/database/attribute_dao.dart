import 'package:opti_food_app/data_models/attribute_category_model.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sembast/sembast.dart';
import 'package:sembast/sembast_io.dart';
import 'package:path/path.dart';

import '../data_models/attribute_model.dart';
import 'app_database.dart';
import 'attribute_category_dao.dart';

class AttributeDao
{
  static _Columns columns = const _Columns();
  static const String folderName = "Attributes";
  final _attributeFolder = intMapStoreFactory.store(folderName);
  AttributeCategoryDao attributeCategoryDao = AttributeCategoryDao();

  Future<Database> get _db async => await AppDatabase.instance.database;

  Future<AttributeModel> insertAttribute(AttributeCategoryModel attributeCategoryModel,AttributeModel attributeModel) async {
    //Database _db = await getDatabase();
    attributeModel.position = (await getAttributeByCategoryDisplay(attributeCategoryModel)).length + 1;
    var key = await _attributeFolder.add(await _db, attributeModel.toJson());
    Finder finder = Finder(filter: Filter.byKey(key));
    attributeModel.id = key;
    await _attributeFolder.update(await _db, attributeModel.toJson(),finder: finder);

    attributeCategoryModel.attributeCount = (await getAttributeByCategoryDisplay(attributeCategoryModel)).length;

    if(attributeCategoryModel.serverId!=0)
       await AttributeCategoryDao().updateAttributeCategory(attributeCategoryModel);
    return attributeModel;
  }


  Future updateAttribute(AttributeModel attributeModel) async {
    //Database _db = await getDatabase();
    //final finder = Finder(filter: Filter.byKey(order.id));
    final finder = Finder(filter: Filter.equals(columns.COL_ID, attributeModel.id));
    await _attributeFolder.update(await _db, attributeModel.toJson(), finder: finder);
  }

  Future<List<AttributeModel>> getAttributeByName(String name) async{
    //Database _db = await getDatabase();

    // List<Filter> filterList = [
    //   Filter.equals(AttributeDao.columns.COL_NAME.toUpperCase(), name.toUpperCase()),
    // ];
    // Finder finder = Finder(filter: Filter.and(filterList));
    Finder finder =  Finder(filter: Filter.matchesRegExp(AttributeDao.columns.COL_NAME, RegExp(name, caseSensitive: false)));

    final recordSnapshot = await _attributeFolder.find(await _db,finder: finder);
    return recordSnapshot.map((snapshot) {
      final attributeItems = AttributeModel.fromJson(snapshot.value);
      return attributeItems;
    }).toList();
  }

  Future delete(AttributeCategoryModel attributeCategoryModel,AttributeModel attributeModel) async {
    //Database _db = await getDatabase();
    final finder = Finder(filter: Filter.equals(columns.COL_ID, attributeModel.id));
    await _attributeFolder.delete(await _db, finder: finder);

    attributeCategoryModel.attributeCount = (await getAttributeByCategoryDisplay(attributeCategoryModel)).length;
    await attributeCategoryDao.updateAttributeCategory(attributeCategoryModel);
    await reArrangePosition(attributeCategoryModel);
  }


  Future syncCatServerId (AttributeCategoryModel attributeCategoryModel) async {
    //Database _db = await getDatabase();
    List<AttributeModel> attributeList = await getAttributeByCategoryDisplay(attributeCategoryModel);
    attributeList.forEach((element) async {
      if(element.catServerId==0){
        element.catServerId = attributeCategoryModel.serverId;
        await updateAttribute(element);
      }
    });
  }

  Future<List<AttributeModel>> getUnSyncedAttributes() async {
    //Database _db = await getDatabase();
    List<Filter> filterList = [
      Filter.equals(columns.COL_IS_SYNCED_ON_SERVER, false),
      Filter.equals(columns.COL_IS_SYNC_ON_SERVER_PROCESSING, false)
    ];
    final recordSnapshot = await _attributeFolder.find(await _db,finder: Finder(filter: Filter.and(filterList)));
    return recordSnapshot.map((snapshot) {
      final attributes = AttributeModel.fromJson(snapshot.value);
      return attributes;
    }).toList();
  }


  Future reArrangePosition(AttributeCategoryModel attributeCategoryModel) async {
    //Database _db = await getDatabase();
    List<AttributeModel> attributeList = await getAttributeByCategoryDisplay(attributeCategoryModel);
    int postion = 1;
    attributeList.forEach((element) async {
      element.position = postion;
      await updateAttribute(element);
      postion++;
    });
  }

  Future<List<AttributeModel>> getAllAttributes() async {
    //Database _db = await getDatabase();
    List<SortOrder> sortList = [];
    sortList.add(SortOrder(columns.COL_POSITION));
    AttributeCategoryModel attributeCategoryModel = (await AttributeCategoryDao().getAllAttributeCategories()).first;
    Finder finder = Finder(filter: Filter.equals(AttributeDao.columns.COL_CAT_SERVER_ID, attributeCategoryModel.serverId),sortOrders: sortList);
    final recordSnapshot = await _attributeFolder.find(await _db,finder: finder);
    return recordSnapshot.map((snapshot) {
      final attributes = AttributeModel.fromJson(snapshot.value);
      return attributes;
    }).toList();
  }

  Future<List<AttributeModel>> getAttributeByCategoryDisplay(AttributeCategoryModel attributeCategoryModel) async {
    //Database _db = await getDatabase();
    List<SortOrder> sortList = [];
    sortList.add(SortOrder(columns.COL_POSITION));
    Finder finder = Finder(filter: attributeCategoryModel.serverId!=0?Filter.equals(
        AttributeDao.columns.COL_CAT_SERVER_ID, attributeCategoryModel.serverId):Filter.equals(AttributeDao.columns.COL_CATEGORY_ID, attributeCategoryModel.id),sortOrders: sortList);
    final recordSnapshot = await _attributeFolder.find(await _db,finder: finder);
    return recordSnapshot.map((snapshot) {
      print(snapshot.value);
      final attributes = AttributeModel.fromJson(snapshot.value);
      return attributes;
    }).toList();
  }



  Future<List<AttributeModel>> getAttributeByCategory(int categoryID) async {
    //Database _db = await getDatabase();
    List<SortOrder> sortList = [];
    sortList.add(SortOrder(columns.COL_POSITION));
    Finder finder = Finder(filter: Filter.equals(AttributeDao.columns.COL_CAT_SERVER_ID, categoryID),sortOrders: sortList);
    final recordSnapshot = await _attributeFolder.find(await _db,finder: finder);
    return recordSnapshot.map((snapshot) {
      print(snapshot.value);
      final attributes = AttributeModel.fromJson(snapshot.value);
      return attributes;
    }).toList();
  }

  Future<AttributeModel> getAttribute() async {
    //Database _db = await getDatabase();
    List<SortOrder> sortList = [];
    final recordSnapshot = await _attributeFolder.find(await _db,finder: Finder(sortOrders: sortList));
    return recordSnapshot.map((snapshot) {
      final attributeCategories = AttributeModel.fromJson(snapshot.value);
      return attributeCategories;
    }).toList()[recordSnapshot.length-1];
  }



  Future<AttributeModel> getAttributeLast() async {
    //Database _db = await getDatabase();
    List<SortOrder> sortList = [];
    sortList.add(SortOrder(columns.COL_ID), );
    final recordSnapshot = await _attributeFolder.find(await _db,finder: Finder(sortOrders: sortList));
    return recordSnapshot.map((snapshot) {
      final attributeCategories = AttributeModel.fromJson(snapshot.value);
      return attributeCategories;
    }).toList()[recordSnapshot.length-1];
  }

  Future<AttributeModel?> getAttributeByServerId(int serverId) async {
    //Database _db = await getDatabase();
    List<SortOrder> sortList = [];
    sortList.add(SortOrder(columns.COL_POSITION));
    final recordSnapshot = await _attributeFolder.find(await _db,finder: Finder(sortOrders: sortList,filter: Filter.equals(columns.COL_SERVER_ID, serverId)));
    if(recordSnapshot.length==0)
      return null;
    return recordSnapshot.map((snapshot) {
      final attributes = AttributeModel.fromJson(snapshot.value);
      return attributes;
    }).first;
  }


  Future<AttributeModel> getAttributeById(int id) async {
    //Database _db = await getDatabase();
    List<SortOrder> sortList = [];
    sortList.add(SortOrder(columns.COL_POSITION));
    final recordSnapshot = await _attributeFolder.find(await _db,finder: Finder(sortOrders: sortList,filter: Filter.equals(columns.COL_ID, id)));

    return recordSnapshot.map((snapshot) {
      final attributes = AttributeModel.fromJson(snapshot.value);
      return attributes;
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
  String get COL_CATEGORY_ID => "category_id";
  String get COL_CAT_SERVER_ID => "cat_server_id";
  String get COL_NAME => "name";
  String get COL_DISPLAY_NAME => "display_name";
  String get COL_COLOR => "color";
  String get COL_PRICE => "price";
  String get COL_ATTRIBUTE_IDS => "attribute_ids";
  String get COL_POSITION => "position";
  String get COL_IMAGE_PATH => "image_path";
  String get COL_SERVER_ID => "server_id";
  String get COL_IS_SYNCED_ON_SERVER => "is_synced_on_server";
  String get COL_IS_SYNC_ON_SERVER_PROCESSING => "is_sync_on_server_processing";
  String get COL_SYNC_ON_SERVER_ACTION_PENDING => "sync_on_server_action_pending";

}