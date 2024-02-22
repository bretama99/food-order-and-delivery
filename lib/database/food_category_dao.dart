import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:opti_food_app/data_models/food_category_model.dart';
import 'package:opti_food_app/data_models/food_items_model.dart';
import 'package:opti_food_app/data_models/order_model.dart';
import 'package:opti_food_app/database/food_items_dao.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sembast/sembast.dart';
import 'package:sembast/sembast_io.dart';
import 'package:path/path.dart';

import 'app_database.dart';

class FoodCategoryDao
{
  static _Columns columns = const _Columns();
  static const String folderName = "FoodCategory";
  final _foodCategoryFolder = intMapStoreFactory.store(folderName);

  Future<Database> get _db async => await AppDatabase.instance.database;


  Future insertFoodCategory(FoodCategoryModel foodCategoryModel) async {
    //////Database _db = await getDatabase();
    foodCategoryModel.position = (await getAllFoodCategories()).length + 1;
    var key = await _foodCategoryFolder.add(await _db, foodCategoryModel.toJson());
    Finder finder = Finder(filter: Filter.byKey(key));
    foodCategoryModel.id = key;
    // List<FoodItemsModel> aa = await FoodItemsDao().getFoodItemsByCategory(foodCategoryModel.id);
    // foodCategoryModel.foodItemsCount = aa.length;
    await _foodCategoryFolder.update(await _db, foodCategoryModel.toJson(),finder: finder);
    return foodCategoryModel;
  }

  Future updateFoodCategory(FoodCategoryModel foodCategoryModel) async {
    //////Database _db = await getDatabase();
    if((await getFoodCategoryById(foodCategoryModel.id)).isAttributeMandatory!=foodCategoryModel.isAttributeMandatory){
       //if attributemandatory change for category then need to change in all its food items
      FoodItemsDao().toggleAttributeMandatoryToAllFoodItems(foodCategoryModel);
    }
    if((await getFoodCategoryById(foodCategoryModel.id)).isHideInKitchen!=foodCategoryModel.isHideInKitchen){
      //if hideinkitchen change for category then need to change in all its food items
      FoodItemsDao().toggleHideInKitchenToAllFoodItems(foodCategoryModel);
    }
    final finder = Finder(filter: Filter.equals(columns.COL_ID, foodCategoryModel.id));
    await _foodCategoryFolder.update(await _db, foodCategoryModel.toJson(), finder: finder);

  }

   Future delete(FoodCategoryModel foodCategoryModel) async {
    //////Database _db = await getDatabase();
    final finder = Finder(filter: Filter.equals(columns.COL_ID, foodCategoryModel.id));
    await _foodCategoryFolder.delete(await _db, finder: finder);
    //on delete foodcategorymodel need to rearrange its list position.
    await reArrangePosition();
  }

  Future reArrangePosition() async {
    //////Database _db = await getDatabase();
    List<FoodCategoryModel> foodCategoryList = await getAllFoodCategories();
    int postion = 1;
    foodCategoryList.forEach((element) async {
      element.position = postion;
      await updateFoodCategory(element);
      postion++;
    });
  }

  Future<List<FoodCategoryModel>> getUnSyncedFoodCategory() async {
    //Database _db = await getDatabase();
    List<Filter> filterList = [
      Filter.equals(columns.COL_IS_SYNCED_ON_SERVER, false),
      Filter.equals(columns.COL_IS_SYNC_ON_SERVER_PROCESSING, false)
    ];
    final recordSnapshot = await _foodCategoryFolder.find(await _db,finder: Finder(filter: Filter.and(filterList)));
    return recordSnapshot.map((snapshot) {
      final foodCategories = FoodCategoryModel.fromJson(snapshot.value);
      return foodCategories;
    }).toList();
  }

  Future<List<FoodCategoryModel>> getAllFoodCategories() async {
    //////Database _db = await getDatabase();
    List<SortOrder> sortList = [];
    sortList.add(SortOrder(columns.COL_POSITION));
    final recordSnapshot = await _foodCategoryFolder.find(await _db,finder: Finder(sortOrders: sortList));
    return recordSnapshot.map((snapshot) {
      print(snapshot);
      final foodCategories = FoodCategoryModel.fromJson(snapshot.value);
      return foodCategories;
    }).toList();
  }

  Future<FoodCategoryModel> getFoodCategoryById(int id) async {
    //////Database _db = await getDatabase();
    List<SortOrder> sortList = [];
    sortList.add(SortOrder(columns.COL_POSITION));
    final recordSnapshot = await _foodCategoryFolder.find(await _db,finder: Finder(sortOrders: sortList,filter: Filter.equals(columns.COL_ID, id)));
    return recordSnapshot.map((snapshot) {
      final foodCategories = FoodCategoryModel.fromJson(snapshot.value);
      return foodCategories;
    }).first;
  }

  Future<FoodCategoryModel?> getFoodCategoryByServerId(int serverId) async {
    //////Database _db = await getDatabase();
    List<SortOrder> sortList = [];
    sortList.add(SortOrder(columns.COL_POSITION));
    final recordSnapshot = await _foodCategoryFolder.find(await _db,finder: Finder(sortOrders: sortList,filter: Filter.equals(columns.COL_SERVER_ID, serverId)));
    if(recordSnapshot.length==0)
      return null;
    return recordSnapshot.map((snapshot) {
      final foodCategories = FoodCategoryModel.fromJson(snapshot.value);
      return foodCategories;
    }).first;
  }

  Future<List<FoodCategoryModel>> getFoodCategoryByName(String name) async{
    //////Database _db = await getDatabase();
    // List<Filter> filterList = [
    //   Filter.equals(FoodCategoryDao.columns.COL_NAME.toUpperCase(), name.toUpperCase()),
    // ];

   Finder finder =  Finder(filter: Filter.matchesRegExp(FoodCategoryDao.columns.COL_NAME, RegExp(name, caseSensitive: false)));
    // Finder finder = Finder(filter: Filter.and(filterList));
    final recordSnapshot = await _foodCategoryFolder.find(await _db,finder: finder);
    return recordSnapshot.map((snapshot) {
      final foodCategoryItems = FoodCategoryModel.fromJson(snapshot.value);
      return foodCategoryItems;
    }).toList();
  }


  Future<FoodCategoryModel> getFoodCategory() async {
    //////Database _db = await getDatabase();
    List<SortOrder> sortList = [];
    sortList.add(SortOrder(columns.COL_POSITION), );
    final recordSnapshot = await _foodCategoryFolder.find(await _db,finder: Finder(sortOrders: sortList));
    return recordSnapshot.map((snapshot) {
      final foodCategories = FoodCategoryModel.fromJson(snapshot.value);
      return foodCategories;
    }).toList()[recordSnapshot.length-1];
  }


  Future<FoodCategoryModel> getFoodCategoryLast() async {
    //////Database _db = await getDatabase();
    List<SortOrder> sortList = [];
    sortList.add(SortOrder(columns.COL_ID), );
    final recordSnapshot = await _foodCategoryFolder.find(await _db,finder: Finder(sortOrders: sortList));
    return recordSnapshot.map((snapshot) {
      final foodCategories = FoodCategoryModel.fromJson(snapshot.value);
      return foodCategories;
    }).toList()[recordSnapshot.length-1];
  }

  //sync category Id to attribute
  Future syncCatServerIdToItem() async {
    //////Database _db = await getDatabase();
    List<SortOrder> sortList = [];
    sortList.add(SortOrder(columns.COL_POSITION), );
    final recordSnapshot = await _foodCategoryFolder.find(await _db,finder: Finder(sortOrders: sortList));
    recordSnapshot.map((snapshot) async {
      final itemCategories = FoodCategoryModel.fromJson(snapshot.value);
      await FoodItemsDao().syncCatServerId(itemCategories);
    }).toList();
  }

 /* Future<Database> getDatabase() async
  {
    final appDocumentDir = await getApplicationDocumentsDirectory();
    // Path with the form: /platform-specific-directory/demo.db
    final dbPath = join(appDocumentDir.path, 'Optifood_nosql.db');

    final database = await databaseFactoryIo.openDatabase(dbPath);
    return database;
  }*/

  // Future<List<FoodCategoryModel>> queryAllRows() async {
  //   List<FoodCategoryModel> fetchedData = [];
  //   int j = 0;
  //   await dio.get('/post').then((response) {
  //     if (response.statusCode == 200) {
  //       for (int i = 0; i < response.data.length; i++) {
  //         var singlePost = FoodCategoryModel.fromMap(response.data[i]);
  //         fetchedData.add(singlePost);
  //       }
  //     }
  //   });
  //   print(fetchedData);
  //   return fetchedData;
  // }
}
class _Columns
{
  const _Columns();
  String get COL_ID => "id";
  String get COL_NAME => "itemCategoryName";
  String get COL_DISPLAY_NAME => "display_name";
  String get COL_COLOR => "color";
  String get COL_POSITION => "position";
  String get COL_IMAGE_PATH => "image_path";
  String get COL_IS_HIDE_IN_KITCHEN => "is_hide_in_kitchen";
  String get COL_IS_ATTRIBUTE_MANDATORY => "is_attribute_mandatory";
  String get COL_FOOD_ITEMS_COUNT => "food_items_count";
  String get COL_SERVER_ID => "server_id";
  String get COL_IS_SYNCED_ON_SERVER => "is_synced_on_server";
  String get COL_IS_SYNC_ON_SERVER_PROCESSING => "is_syn_on_server_processing";
  String get COL_SYNC_ON_SERVER_ACTION_PENDING => "sync_on_server_action_pending";
}