import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:opti_food_app/data_models/attribute_category_model.dart';
import 'package:opti_food_app/data_models/food_category_model.dart';
import 'package:opti_food_app/data_models/food_items_model.dart';
import 'package:opti_food_app/data_models/order_model.dart';
import 'package:opti_food_app/database/food_category_dao.dart';
import 'package:opti_food_app/database/restaurant_info_dao.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sembast/sembast.dart';
import 'package:sembast/sembast_io.dart';
import 'package:path/path.dart';

import '../data_models/restaurant_info_model.dart';
import '../main.dart';
import '../utils/utility.dart';
import 'app_database.dart';

class FoodItemsDao
{
  static _Columns columns = const _Columns();
  static const String folderName = "FoodItems";
  final _foodItemsFolder = intMapStoreFactory.store(folderName);
  FoodCategoryDao foodCategoryDao = FoodCategoryDao();

  Future<Database> get _db async => await AppDatabase.instance.database;

  Future insertFoodItem(FoodCategoryModel foodCategoryModel,FoodItemsModel foodItemsModel) async {
    //Database _db = await getDatabase();
    // if(foodItemsModel.serverId==0)
       foodItemsModel.position = (await getFoodItemsByCategoryForDisplay(foodCategoryModel)).length+1;
    var key = await _foodItemsFolder.add(await _db, foodItemsModel.toJson());
    Finder finder = Finder(filter: Filter.byKey(key));
    foodItemsModel.id = key;
    await _foodItemsFolder.update(await _db, foodItemsModel.toJson(),finder: finder);

    foodCategoryModel.foodItemsCount = (await getFoodItemsByCategoryForDisplay(foodCategoryModel)).length;
    if(foodCategoryModel.serverId!=0)
      await foodCategoryDao.updateFoodCategory(foodCategoryModel);
    return foodItemsModel;
  }

  Future updateFoodItem(FoodItemsModel foodItemsModel) async {
    //Database _db = await getDatabase();
    //final finder = Finder(filter: Filter.byKey(order.id));
    final finder = Finder(filter: Filter.equals(columns.COL_ID, foodItemsModel.id));
    await _foodItemsFolder.update(await _db, foodItemsModel.toJson(), finder: finder);

    final recordSnapshot = await _foodItemsFolder.find(await _db,finder: finder);
    return recordSnapshot.map((snapshot) {
      final foodItemes = FoodItemsModel.fromJson(snapshot.value);
      return foodItemes;

    }).toList()[recordSnapshot.length-1];
  }

  Future delete(FoodCategoryModel foodCategoryModel,FoodItemsModel foodItemsModel) async {

    //Database _db = await getDatabase();
    final finder = Finder(filter: Filter.equals(columns.COL_ID, foodItemsModel.id));
    // final recordSnapshot = await _foodItemsFolder.find(await _db,finder: finder);
    // var aa =recordSnapshot.map((snapshot) {
    //   final foodItemes = FoodItemsModel.fromJson(snapshot.value);
    //   return foodItemes;
    // }).toList()[recordSnapshot.length-1];
    // var serverId = aa.serverId;
    // print("============nn===value=serverId${serverId}==========================");

    await _foodItemsFolder.delete(await _db, finder: finder);
    foodCategoryModel.foodItemsCount = (await getFoodItemsByCategoryForDisplay(foodCategoryModel)).length;
    await foodCategoryDao.updateFoodCategory(foodCategoryModel);
    await reArrangePosition(foodCategoryModel);
  }

  Future reArrangePosition(FoodCategoryModel foodCategoryModel) async {
    //Database _db = await getDatabase();
    List<FoodItemsModel> foodItemsList = await getFoodItemsByCategoryForDisplay(foodCategoryModel);
    int postion = 1;
    foodItemsList.forEach((element) async {
      element.position = postion;
      await updateFoodItem(element);
      postion++;
    });
  }

  Future<List<FoodItemsModel>> getUnSyncedFoodItems() async {
    //Database _db = await getDatabase();
    List<Filter> filterList = [
      Filter.equals(columns.COL_IS_SYNCED_ON_SERVER, false),
      Filter.equals(columns.COL_IS_SYNC_ON_SERVER_PROCESSING, false)
    ];
    final recordSnapshot = await _foodItemsFolder.find(await _db,finder: Finder(filter: Filter.and(filterList)));
    return recordSnapshot.map((snapshot) {
      final foodItems = FoodItemsModel.fromJson(snapshot.value);
      return foodItems;
    }).toList();
  }

  Future<List<FoodItemsModel>> getAllFoodItems() async {
    //Database _db = await getDatabase();
    reloadFoodItemLimit();
    List<SortOrder> sortList = [];
    sortList.add(SortOrder(FoodItemsDao.columns.COL_POSITION));
    if((await FoodCategoryDao().getAllFoodCategories()).isNotEmpty) {
      FoodCategoryModel foodCategoryModel = (await FoodCategoryDao()
          .getAllFoodCategories()).first;
      List<Filter> filterList = [
        Filter.equals(
            FoodItemsDao.columns.COL_CAT_SERVER_ID, foodCategoryModel.serverId),
        Filter.equals(columns.COL_IS_ACTIVATED, true)
      ];
      Finder finder = Finder(
          filter: Filter.and(filterList), sortOrders: sortList);
      final recordSnapshot = await _foodItemsFolder.find(
          await _db, finder: finder);
      return recordSnapshot.map((snapshot) {
        final foodItems = FoodItemsModel.fromJson(snapshot.value);
        return foodItems;
      }).toList();
    }
    else{
      return [];
    }
  }

  Future<List<FoodItemsModel>> getAllFoodItemsForReport() async {
    List<Filter> filterList = [
      Filter.equals(columns.COL_IS_ACTIVATED, true)
    ];
    Finder finder = Finder(
        filter: Filter.and(filterList));
    final recordSnapshot = await _foodItemsFolder.find(
        await _db, finder: finder);
    return recordSnapshot.map((snapshot) {
      final foodItems = FoodItemsModel.fromJson(snapshot.value);
      return foodItems;
    }).toList();
  }

  Future<List<FoodItemsModel>> getFoodItemsByCategoryLocal(int categoryID,{bool isGetDeactivated = true}) async {
    //Database _db = await getDatabase();
    reloadFoodItemLimit();
    List<SortOrder> sortList = [];
    sortList.add(SortOrder(FoodItemsDao.columns.COL_POSITION));
    List<Filter> filterList = [
      Filter.equals(FoodItemsDao.columns.COL_CATEGORY_ID, categoryID),
      //Filter.equals(columns.COL_IS_ACTIVATED, true)
    ];
    if(!isGetDeactivated){
      filterList.add(Filter.equals(columns.COL_IS_ACTIVATED, true));
    }
    Finder finder = Finder(filter: Filter.and(filterList),sortOrders: sortList);
    final recordSnapshot = await _foodItemsFolder.find(await _db,finder: finder);
    return recordSnapshot.map((snapshot) {
      final foodItems = FoodItemsModel.fromJson(snapshot.value);
      return foodItems;
    }).toList();
  }

  Future<List<FoodItemsModel>> getFoodItemsByCategoryForDisplay(FoodCategoryModel foodCategoryModel,{bool isGetDeactivated = true}) async {
    //Database _db = await getDatabase();
    reloadFoodItemLimit();
    List<SortOrder> sortList = [];
    sortList.add(SortOrder(FoodItemsDao.columns.COL_POSITION));

    List<Filter> filterList = [
      foodCategoryModel.serverId!=0?Filter.equals(FoodItemsDao.columns.COL_CAT_SERVER_ID, foodCategoryModel.serverId):Filter.equals(FoodItemsDao.columns.COL_CATEGORY_ID, foodCategoryModel.id),
      //Filter.equals(columns.COL_IS_ACTIVATED, true)
    ];
    if(!isGetDeactivated){
      filterList.add(Filter.equals(columns.COL_IS_ACTIVATED, true));
    }
    Finder finder = Finder(filter: Filter.and(filterList),sortOrders: sortList);
    final recordSnapshot = await _foodItemsFolder.find(await _db,finder: finder);
    return recordSnapshot.map((snapshot) {
      final foodItems = FoodItemsModel.fromJson(snapshot.value);
      return foodItems;
    }).toList();
  }

  Future<List<FoodItemsModel>> getFoodItemsByCategory(int categoryID,{bool isGetDeactivated = true}) async {
    //Database _db = await getDatabase();
    print("Getting food items");
    reloadFoodItemLimit();
    List<SortOrder> sortList = [];
    sortList.add(SortOrder(FoodItemsDao.columns.COL_POSITION));
    List<Filter> filterList = [
      Filter.equals(FoodItemsDao.columns.COL_CAT_SERVER_ID, categoryID),
      //Filter.equals(columns.COL_IS_ACTIVATED, true)
    ];
    if(!isGetDeactivated){
      filterList.add(Filter.equals(columns.COL_IS_ACTIVATED, true));
    }
    Finder finder = Finder(filter: Filter.and(filterList),sortOrders: sortList);
    final recordSnapshot = await _foodItemsFolder.find(await _db,finder: finder);
    return recordSnapshot.map((snapshot) {
      final foodItems = FoodItemsModel.fromJson(snapshot.value);
      return foodItems;
    }).toList();
  }

  Future<void> reloadFoodItemLimit() async {
    String currentDateTime = DateFormat("yyyy-MM-dd HH:mm").format(DateTime.now());
    //Utility().showToastMessage("Current: "+currentDateTime);
    if(optifoodSharedPrefrence.getString("end_shift_date_time")!=null){
      //Utility().showToastMessage("Shift: "+optifoodSharedPrefrence.getString("end_shift_date_time")!);
      //print("Shift: "+optifoodSharedPrefrence.getString("end_shift_date_time")!);
      if(DateTime.parse(optifoodSharedPrefrence.getString("end_shift_date_time")!).isBefore(DateTime.now())){
        final recordSnapshot = await _foodItemsFolder.find(
            await _db);
        List<FoodItemsModel> allFoodItems =  recordSnapshot.map((snapshot) {
          final foodItems = FoodItemsModel.fromJson(snapshot.value);
          return foodItems;
        }).toList();
        allFoodItems.forEach((element) async {
          element.dailyQuantityConsumed = 0;
          await updateFoodItem(element);
        });
        RestaurantInfoModel restaurantInfoModel = await RestaurantInfoDao().getRestaurantInfo();
        String startTime = restaurantInfoModel.startTime;
        String endTime = restaurantInfoModel.endTime;
        if(startTime==null||endTime==null){
          startTime = "00:00";
          endTime = "23:59";
        }
        List<String> dateTimeList = startTime!=null?Utility().generateShiftTiming(startTime, endTime):[];
        optifoodSharedPrefrence.setString("end_shift_date_time", DateFormat("yyyy-MM-dd HH:mm").format(DateTime.parse(dateTimeList[1]).add(Duration(days: 1))));
      }
    }
    else{
      RestaurantInfoModel restaurantInfoModel = await RestaurantInfoDao().getRestaurantInfo();
      String startTime = restaurantInfoModel.startTime;
      String endTime = restaurantInfoModel.endTime;
      if(startTime==null||endTime==null){
        startTime = "00:00";
        endTime = "23:59";
      }
      List<String> dateTimeList = startTime!=null?Utility().generateShiftTiming(startTime, endTime):[];
      optifoodSharedPrefrence.setString("end_shift_date_time",dateTimeList[1]);
      //optifoodSharedPrefrence.commit();
    }
  }

  Future<void> addAttributeCategoryToAllFoodItems(AttributeCategoryModel attributeCategoryModel) async {
    //Database _db = await getDatabase();
    final recordSnapshot = await _foodItemsFolder.find(await _db);
    List<FoodItemsModel> foodItemsList =  recordSnapshot.map((snapshot) {
      final foodItems = FoodItemsModel.fromJson(snapshot.value);
      return foodItems;
    }).toList();
    foodItemsList.forEach((foodItems) {
      if(foodItems.attributeCategoryIds!=null&&foodItems.attributeCategoryIds.isEmpty){
        foodItems.attributeCategoryIds = attributeCategoryModel.serverId!=0?attributeCategoryModel.serverId.toString():attributeCategoryModel.id.toString();
      }
      else if(foodItems.attributeCategoryIds!=null){
        foodItems.attributeCategoryIds = (foodItems.attributeCategoryIds+","+attributeCategoryModel.id.toString());
      }
      updateFoodItem(foodItems);
    });
  }

  Future<void> toggleHideInKitchenToAllFoodItems(FoodCategoryModel foodCategoryModel) async {
    //Database _db = await getDatabase();
    final recordSnapshot = await _foodItemsFolder.find(await _db);
    List<FoodItemsModel> foodItemsList = await getFoodItemsByCategoryForDisplay(foodCategoryModel);

    foodItemsList.forEach((foodItems) {
      foodItems.isHideInKitchen = foodCategoryModel.isHideInKitchen;
      updateFoodItem(foodItems);
    });
  }

  Future<void> toggleAttributeMandatoryToAllFoodItems(FoodCategoryModel foodCategoryModel) async {
    //Database _db = await getDatabase();
    final recordSnapshot = await _foodItemsFolder.find(await _db);
    List<FoodItemsModel> foodItemsList = await getFoodItemsByCategoryForDisplay(foodCategoryModel);

    foodItemsList.forEach((foodItems) {
      foodItems.isAttributeMandatory = foodCategoryModel.isAttributeMandatory;
      updateFoodItem(foodItems);
    });
  }

  Future<int> getCount() async{
    //Database _db = await getDatabase();
    final recordSnapshot = await _foodItemsFolder.find(await _db);
    return recordSnapshot.length;
  }


  Future<List<FoodItemsModel?>> getFoodItemByName(String name) async{
    //Database _db = await getDatabase();
    // List<Filter> filterList = [
    //   Filter.equals(FoodItemsDao.columns.COL_NAME.toUpperCase(), name.toUpperCase()),
    // ];
    //
    // Finder finder = Finder(filter: Filter.and(filterList));

    Finder finder =  Finder(filter: Filter.matchesRegExp(FoodItemsDao.columns.COL_NAME, RegExp(name, caseSensitive: false)));
    // Finder finder =  Finder(filter: Filter.matchesRegExp(field, regExp).equals(FoodItemsDao.columns.COL_NAME, RegExp(name, caseSensitive: false)));
    final recordSnapshot = await _foodItemsFolder.find(await _db,finder: finder);
    List<FoodItemsModel?> foodItemModel = recordSnapshot.map((snapshot) {
      final foodItems = FoodItemsModel.fromJson(snapshot.value);
      if(foodItems.name==name){
        return foodItems;
      }
    }).toList();
    foodItemModel = foodItemModel.where((element) =>element!=null&& element!.name!=null).toList();
    return foodItemModel;
  }

  Future<FoodItemsModel> getFoodItem() async {
    //Database _db = await getDatabase();
    List<SortOrder> sortList = [];
    sortList.add(SortOrder(columns.COL_POSITION), );
    final recordSnapshot = await _foodItemsFolder.find(await _db,finder: Finder(sortOrders: sortList));
    return recordSnapshot.map((snapshot) {
      final foodItemes = FoodItemsModel.fromJson(snapshot.value);
      return foodItemes;
    }).toList()[recordSnapshot.length-1];
  }

  Future<FoodItemsModel?> getFoodItemByServerId(int serverId) async {
    //Database _db = await getDatabase();
    List<SortOrder> sortList = [];
    sortList.add(SortOrder(columns.COL_POSITION));
    final recordSnapshot = await _foodItemsFolder.find(await _db,finder: Finder(sortOrders: sortList,
        filter: Filter.equals(columns.COL_SERVER_ID, serverId)));
    if(recordSnapshot.length==0)
      return null;
    return recordSnapshot.map((snapshot) {
      final foodItemes = FoodItemsModel.fromJson(snapshot.value);
      return foodItemes;
    }).first;
  }

  Future<FoodItemsModel> getFoodItemLast() async {
    //Database _db = await getDatabase();
    List<SortOrder> sortList = [];
    sortList.add(SortOrder(columns.COL_ID), );
    final recordSnapshot = await _foodItemsFolder.find(await _db,finder: Finder(sortOrders: sortList));
    return recordSnapshot.map((snapshot) {
      final foodItemes = FoodItemsModel.fromJson(snapshot.value);
      return foodItemes;
    }).toList()[recordSnapshot.length-1];
  }
  Future<FoodItemsModel> getFoodItemById(int id) async {
    //Database _db = await getDatabase();
    List<SortOrder> sortList = [];
    sortList.add(SortOrder(columns.COL_POSITION));
    final recordSnapshot = await _foodItemsFolder.find(await _db,finder: Finder(sortOrders: sortList,filter: Filter.equals(columns.COL_ID, id)));
    return recordSnapshot.map((snapshot) {
      final foodItemes = FoodItemsModel.fromJson(snapshot.value);
      return foodItemes;
    }).first;
  }

  //sync category id to item
  Future syncCatServerId (FoodCategoryModel foodCategoryModel) async {
    //Database _db = await getDatabase();
    List<FoodItemsModel> foodItemList = await getFoodItemsByCategoryForDisplay(foodCategoryModel);
    foodItemList.forEach((element) async {
      if(element.catServerId==0){
        element.catServerId = foodCategoryModel.serverId;
        await updateFoodItem(element);
      }
    });
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
  String get COL_NAME => "name";
  String get COL_DISPLAY_NAME => "display_name";
  String get COL_DESCRIPTION => "description";
  String get COL_ALLERGENCE => "allergence";
  String get COL_IS_ENABLE_PRICE_PER_ORDER_TYPE => "is_price_per_order_type";
  String get COL_PRICE => "price";
  String get COL_EAT_IN_PRICE => "eat_it_price";
  String get COL_DELIVERY_PRICE => "delivery_price";
  String get COL_IS_HIDE_IN_KITCHEN => "is_hide_in_kitchen";
  String get COL_COLOR => "color";
  String get COL_IS_ATTRIBUTE_MANDATORY => "is_attribute_mandatory";
  String get COL_ATTRIBUTE_CATEGORY_IDS => "attribute_category_ids"; //Needs in product management
  String get COL_ATTRIBUTE_IDS => "attribute_ids"; //Needs in order management
  String get COL_IS_PRODUCT_IN_STOCK => "is_product_in_stock";
  String get COL_IS_STOCK_MANAGEMENT_ACTIVATED => "is_stock_management_activated";
  String get COL_DAILY_QUANTITY_LIMIT => "daily_quantity_limit";
  String get COL_DAILY_QUANTITY_CONSUMED => "daily_quantity_consumed";
  String get COL_POSITION => "position";
  String get COL_IMAGE_PATH => "image_path";
  String get COL_IS_ACTIVATED => "is_activated";
  String get COL_SERVER_ID => "server_id";
  String get COL_CAT_SERVER_ID => "cat_server_id";
  String get COL_IS_SYNCED_ON_SERVER => "is_synced_on_server";
  String get COL_IS_SYNC_ON_SERVER_PROCESSING => "is_syn_on_server_processing";
  String get COL_SYNC_ON_SERVER_ACTION_PENDING => "sync_on_server_action_pending";
  String get COL_ORDERED_ITEM_ID => "ordered_item_id";


}