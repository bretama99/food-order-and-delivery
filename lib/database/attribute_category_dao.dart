import 'package:flutter/material.dart';
import 'package:opti_food_app/data_models/food_category_model.dart';
import 'package:opti_food_app/data_models/food_items_model.dart';
import 'package:opti_food_app/data_models/order_model.dart';
import 'package:opti_food_app/database/food_items_dao.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sembast/sembast.dart';
import 'package:sembast/sembast_io.dart';
import 'package:path/path.dart';

import '../data_models/attribute_category_model.dart';
import 'app_database.dart';
import 'attribute_dao.dart';

class AttributeCategoryDao
{
  static _Columns columns = const _Columns();
  static const String folderName = "AttributeCategory";
  final _attributeCategoryFolder = intMapStoreFactory.store(folderName);

  Future<Database> get _db async => await AppDatabase.instance.database;


  Future<AttributeCategoryModel> insertAttributeCategory(AttributeCategoryModel attributeCategoryModel) async {
    //Database _db = await getDatabase();
    attributeCategoryModel.position = (await getAllAttributeCategories()).length + 1;
    var key = await _attributeCategoryFolder.add(await _db, attributeCategoryModel.toJson());
    Finder finder = Finder(filter: Filter.byKey(key));
    attributeCategoryModel.id = key;
    await _attributeCategoryFolder.update(await _db, attributeCategoryModel.toJson(),finder: finder);
    await FoodItemsDao().addAttributeCategoryToAllFoodItems(attributeCategoryModel);
    return attributeCategoryModel;
  }

  Future<List<AttributeCategoryModel>> getAttributeCategoryByName(String name) async{
    //Database _db = await getDatabase();
    // List<Filter> filterList = [
    //   Filter.equals(AttributeCategoryDao.columns.COL_NAME.toUpperCase(), name.toUpperCase()),
    // ];
    //
    // Finder finder = Finder(filter: Filter.and(filterList));
    Finder finder =  Finder(filter: Filter.matchesRegExp(AttributeCategoryDao.columns.COL_NAME, RegExp(name, caseSensitive: false)));

    final recordSnapshot = await _attributeCategoryFolder.find(await _db,finder: finder);
    return recordSnapshot.map((snapshot) {
      final attributeCategoryItems = AttributeCategoryModel.fromJson(snapshot.value);
      return attributeCategoryItems;
    }).toList();
  }


  Future updateAttributeCategory(AttributeCategoryModel attributeCategoryModel) async {
    //Database _db = await getDatabase();
    //final finder = Finder(filter: Filter.byKey(order.id));
    final finder = Finder(filter: Filter.equals(columns.COL_ID, attributeCategoryModel.id));
    await _attributeCategoryFolder.update(await _db, attributeCategoryModel.toJson(), finder: finder);
  }

  Future delete(AttributeCategoryModel attributeCategoryModel) async {
    //Database _db = await getDatabase();
    final finder = Finder(filter: Filter.equals(columns.COL_ID, attributeCategoryModel.id));
    await _attributeCategoryFolder.delete(await _db, finder: finder);
    //on delete attributecategorymodel need to rearrange its list position.
    await reArrangePosition();
  }

  Future reArrangePosition() async {
    //Database _db = await getDatabase();
    List<AttributeCategoryModel> attributeCategoryList = await getAllAttributeCategories();
    int postion = 1;
    attributeCategoryList.forEach((element) async {
      element.position = postion;
      await updateAttributeCategory(element);
      postion++;
    });
  }


  //sync category Id to attribute
  Future syncCatServerIdToAttribute() async {
    //Database _db = await getDatabase();
    List<SortOrder> sortList = [];
    sortList.add(SortOrder(columns.COL_POSITION), );
    final recordSnapshot = await _attributeCategoryFolder.find(await _db,finder: Finder(sortOrders: sortList));
    recordSnapshot.map((snapshot) async {
      final attributeCategories = AttributeCategoryModel.fromJson(snapshot.value);
      await AttributeDao().syncCatServerId(attributeCategories);
      // return attributeCategories;
    }).toList();
  }



  Future<List<AttributeCategoryModel>> getAllAttributeCategories() async {
    //Database _db = await getDatabase();
    List<SortOrder> sortList = [];
    sortList.add(SortOrder(columns.COL_POSITION), );
    final recordSnapshot = await _attributeCategoryFolder.find(await _db,finder: Finder(sortOrders: sortList));
    return recordSnapshot.map((snapshot) {
      final attributeCategories = AttributeCategoryModel.fromJson(snapshot.value);
      return attributeCategories;
    }).toList();
  }

  Future<List<AttributeCategoryModel>> getAttributeCategoriesByIds(String ids) async {
    List<int> idList = [];
    ids.split(",").forEach((element) {
      idList.add(int.parse(element));
    });
    //Database _db = await getDatabase();
    List<SortOrder> sortList = [];
    sortList.add(SortOrder(columns.COL_POSITION));
    final recordSnapshot = await _attributeCategoryFolder.find(await _db,finder: Finder(sortOrders: sortList,filter: Filter.inList(columns.COL_ID, idList)));
    return recordSnapshot.map((snapshot) {
      final attributeCategories = AttributeCategoryModel.fromJson(snapshot.value);
      return attributeCategories;
    }).toList();
  }

  Future<AttributeCategoryModel> getAttributeCategory() async {
    //Database _db = await getDatabase();
    List<SortOrder> sortList = [];
    sortList.add(SortOrder(columns.COL_POSITION), );
    final recordSnapshot = await _attributeCategoryFolder.find(await _db,finder: Finder(sortOrders: sortList));
    return recordSnapshot.map((snapshot) {
      final attributeCategories = AttributeCategoryModel.fromJson(snapshot.value);
      return attributeCategories;
    }).toList()[recordSnapshot.length-1];
  }

  Future<AttributeCategoryModel> getAttributeCategoryLast() async {
    //Database _db = await getDatabase();
    List<SortOrder> sortList = [];
    sortList.add(SortOrder(columns.COL_ID), );
    final recordSnapshot = await _attributeCategoryFolder.find(await _db,finder: Finder(sortOrders: sortList));
    return recordSnapshot.map((snapshot) {
      final attributeCategories = AttributeCategoryModel.fromJson(snapshot.value);
      return attributeCategories;
    }).toList()[recordSnapshot.length-1];
  }


  Future<AttributeCategoryModel?> getAttributeCategoryByServerId(int serverId) async {
    //Database _db = await getDatabase();
    List<SortOrder> sortList = [];
    sortList.add(SortOrder(columns.COL_POSITION));
    final recordSnapshot = await _attributeCategoryFolder.find(await _db,finder: Finder(sortOrders: sortList,filter: Filter.equals(columns.COL_SERVER_ID, serverId)));
    if(recordSnapshot.length==0)
      return null;
    return recordSnapshot.map((snapshot) {
      final attributeCategories = AttributeCategoryModel.fromJson(snapshot.value);
      return attributeCategories;
    }).first;
  }

  Future<AttributeCategoryModel> getAttributeCategoryById(int id) async {
    //Database _db = await getDatabase();
    List<SortOrder> sortList = [];
    sortList.add(SortOrder(columns.COL_POSITION));
    final recordSnapshot = await _attributeCategoryFolder.find(await _db,finder: Finder(sortOrders: sortList,filter: Filter.equals(columns.COL_ID, id)));
    return recordSnapshot.map((snapshot) {
      final attributeCategories = AttributeCategoryModel.fromJson(snapshot.value);
      return attributeCategories;
    }).first;
  }

  Future<List<AttributeCategoryModel>> getUnSyncedAttributeCategory() async {
    //Database _db = await getDatabase();
    List<Filter> filterList = [
      Filter.equals(columns.COL_IS_SYNCED_ON_SERVER, false),
      Filter.equals(columns.COL_IS_SYNC_ON_SERVER_PROCESSING, false)
    ];
    final recordSnapshot = await _attributeCategoryFolder.find(await _db,finder: Finder(filter: Filter.and(filterList)));
    return recordSnapshot.map((snapshot) {
      final attributeCategories = AttributeCategoryModel.fromJson(snapshot.value);
      return attributeCategories;
    }).toList();
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
  String get COL_GLOBAL_ID => "global_id";
  String get COL_NAME => "name";
  String get COL_DISPLAY_NAME => "display_name";
  String get COL_COLOR => "color";
  String get COL_POSITION => "position";
  String get COL_IMAGE_PATH => "image_path";
  String get COL_ATTRIBUTE_COUNT => "attribute_count";
  String get COL_SERVER_ID => "server_id";
  String get COL_IS_SYNCED_ON_SERVER => "is_synced_on_server";
  String get COL_IS_SYNC_ON_SERVER_PROCESSING => "is_syn_on_server_processing";
  String get COL_SYNC_ON_SERVER_ACTION_PENDING => "sync_on_server_action_pending";
}