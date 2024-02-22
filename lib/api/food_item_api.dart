import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:fbroadcast/fbroadcast.dart';
import 'package:opti_food_app/database/food_category_dao.dart';
import 'package:path_provider/path_provider.dart';

import '../data_models/food_category_model.dart';
import '../data_models/food_items_model.dart';
import '../data_models/server_sync_action_pending.dart';
import '../database/food_items_dao.dart';
import '../main.dart';
import '../utils/constants.dart';
import '../utils/utility.dart';
import 'package:path/path.dart' as path;
import 'package:http/http.dart' as http;

class FoodItemApi{
  static String OPTIFOOD_DATABASE=optifoodSharedPrefrence.getString("database").toString();
  static String authorization = optifoodSharedPrefrence.getString("accessToken").toString();
  Future<void> syncFoodItems() async {
    List<FoodItemsModel> foodItemList = await FoodItemsDao().getUnSyncedFoodItems();
    foodItemList.forEach((element) {
      ServerSyncActionPending serverSyncActionPending = Utility().getServerSyncActionPending(element.syncOnServerActionPending);
      if(serverSyncActionPending.isPendingCreate){
        saveFoodItemToSever(element);
      }
      else if(serverSyncActionPending.isPendingUpdate){
        saveFoodItemToSever(element,isUpdate: true);
      }
    });
  }

  saveFoodItemToSever(FoodItemsModel foodItemsModel,{bool isUpdate = false}) async{
    final dio = Dio();
    dio.options.headers['X-TenantID'] = OPTIFOOD_DATABASE;
    dio.options.headers['Authorization'] = authorization;
    //FoodItemsDao().getFoodItemLast().then((foodItemsModel) async{
      var formData;
      if(foodItemsModel.catServerId!=0) {
        //if (_image == null) {
          formData = FormData.fromMap({
            'categoryId': foodItemsModel.catServerId,
            "itemPriceId": 1,
            'itemName': foodItemsModel.name,
            'displayName': foodItemsModel.displayName,
            'color': foodItemsModel.color,
            'position': foodItemsModel.position,
            // "quantity": foodItemsModel.dailyQuantityLimit,
            "quantity": foodItemsModel.dailyQuantityLimit,
            // "quantity": foodItemsModel.quantity,
            "description": foodItemsModel.description,
            "allergence": foodItemsModel.allergence,
            "attributeRequired": foodItemsModel.isAttributeMandatory,
            "enablePricePerOrderType":foodItemsModel.isEnablePricePerOrderType,
            "showKichen": foodItemsModel.isHideInKitchen,
            "eatInPrice": foodItemsModel.eatInPrice,
            "defaultPrice": foodItemsModel.price,
            "deliveryPrice": foodItemsModel.deliveryPrice,
            "eatInNightModePrice": foodItemsModel.eatInPrice,
            "eatInDefaultModePrice": foodItemsModel.eatInPrice,
            "deliveryNightModePrice": foodItemsModel.eatInPrice,
            "productInStock":foodItemsModel.isProductInStock,
            "stockManagementActivated":foodItemsModel.isStockManagementActivated,
            "attributeCategoryIds":foodItemsModel.attributeCategoryIds,
            "dailyQuantityConsumed":foodItemsModel.dailyQuantityConsumed
          });
       /* }
        else {
          formData = FormData.fromMap({
            'categoryId': value.catServerId,
            "itemPriceId": 1,
            'itemName': value.name,
            'displayName': value.displayName,
            'color': value.color,
            'position': value.position,
            "quantity": value.dailyQuantityLimit,
            "quantity": value.quantity,
            "description": value.description,
            'image': MultipartFile.fromBytes(
                _image.readAsBytesSync(), filename: fileName),
            "isAttributeRequired": value.isAttributeMandatory,
            "isShowKichen": value.isHideInKitchen,
            "allergence": value.allergence,
            "eatInPrice": value.eatInPrice,
            "defaultPrice": value.price,
            "deliveryPrice": value.deliveryPrice,
            "eatInNightModePrice": 1,
            "eatInDefaultModePrice": 5,
            "deliveryNightModePrice": 89
          });
        }*/
        if(isUpdate){
          await dio.put(
            ServerData.OPTIFOOD_BASE_URL + '/api/item/'+foodItemsModel.serverId.toString(),
            data: formData,
          ).then((response) async {
            var singleData = FoodItemsModel.fromJsonServer(response.data);
            foodItemsModel.isSyncedOnServer = true;
            foodItemsModel.serverId = singleData.serverId;
            foodItemsModel.isSyncOnServerProcessing = false;
            foodItemsModel.syncOnServerActionPending = Utility().removeServerSyncActionPending(ConstantSyncOnServerPendingActions.ACTION_PENDING_UPDATE);
            await FoodItemsDao().updateFoodItem(foodItemsModel);
            FBroadcast.instance().broadcast(
                ConstantBroadcastKeys.KEY_UPDATE_UI);
          }).catchError((onError) async {
            foodItemsModel.isSyncedOnServer=false;
            foodItemsModel.isSyncOnServerProcessing = false;
            await FoodItemsDao().updateFoodItem(foodItemsModel);
            FBroadcast.instance().broadcast(
                ConstantBroadcastKeys.KEY_UPDATE_UI);
            optifoodBackgroundService.syncPendingLocalData();
          });
        }
        else{
          await dio.post(
            ServerData.OPTIFOOD_BASE_URL + '/api/item',
            data: formData,
          ).then((response) async {
            var singleData = FoodItemsModel.fromJsonServer(response.data);
            foodItemsModel.isSyncedOnServer = true;
            foodItemsModel.serverId = singleData.serverId;
            foodItemsModel.isSyncOnServerProcessing = false;
            foodItemsModel.isActivated = true;
            foodItemsModel.syncOnServerActionPending = Utility().removeServerSyncActionPending(ConstantSyncOnServerPendingActions.ACTION_PENDING_UPDATE);
            await FoodItemsDao().updateFoodItem(foodItemsModel);
            FBroadcast.instance().broadcast(
                ConstantBroadcastKeys.KEY_UPDATE_UI);
          }).catchError((onError) async {
            foodItemsModel.isSyncedOnServer=false;
            foodItemsModel.isSyncOnServerProcessing = false;
            foodItemsModel.isActivated = false;
            await FoodItemsDao().updateFoodItem(foodItemsModel);
            FBroadcast.instance().broadcast(
                ConstantBroadcastKeys.KEY_UPDATE_UI);
            optifoodBackgroundService.syncPendingLocalData();
          });
        }
      }
    //});
  }

  static saveConsumedQuantity(var itemInfo) async{

    final dio = Dio();
    dio.options.headers['X-TenantID'] = OPTIFOOD_DATABASE;
    dio.options.headers['Authorization'] = authorization;
    await dio.put(ServerData.OPTIFOOD_BASE_URL + '/api/item/consumed-items',
      data: json.encode(itemInfo),
    ).then((value){
    }).catchError((err){
    });
  }

  
  void getFoodItemsListFromServer({Function? callback = null}) async{
    List<FoodItemsModel> fetchedData = [];
    int j = 0;
    final dio = Dio();
    var aa = ServerData.OPTIFOOD_BASE_URL+'/api/item';
    dio.options.headers['X-TenantID'] = OPTIFOOD_DATABASE;
    dio.options.headers['Authorization'] = authorization;
    await dio.get(ServerData.OPTIFOOD_BASE_URL+'/api/item').then((response) async {
      List<FoodItemsModel> fetchedData = [];
      try {
        if (response.statusCode == 200) {
          for (int i = 0; i < response.data.length; i++) {
            try {
              var singleItem = FoodItemsModel.fromJsonServer(response.data[i]);
              fetchedData.add(singleItem);
            }
            catch(error,detail){
              print(detail);
            }
          }

          for (int i = 0; i < fetchedData.length; i++) {
           /* if (fetchedData[i].deliveryPrice != 0 &&
                fetchedData[i].deliveryPrice != null &&
                fetchedData[i].eatInPrice != 0 &&
                fetchedData[i].eatInPrice != null) {
              fetchedData[i].isEnablePricePerOrderType = true;
            }
            else {
              fetchedData[i].isEnablePricePerOrderType = false;
            }*/


            //if(imageName=='null'){
            if (fetchedData[i].imagePath.toString()=='null') {
              FoodItemsDao()
                  .getFoodItemByServerId(fetchedData[i].serverId!)
                  .then((value) async {
                FoodItemsModel foodItemsModel = FoodItemsModel(
                  fetchedData[i].id,
                  fetchedData[i].name,
                  fetchedData[i].displayName,
                  fetchedData[i].description,
                  fetchedData[i].allergence,
                  fetchedData[i].price,
                  imagePath: null,
                  isEnablePricePerOrderType: fetchedData[i]
                      .isEnablePricePerOrderType,
                  //     .isEnablePricePerOrderType,
                  categoryID: fetchedData[i].categoryID,
                  eatInPrice: fetchedData[i].eatInPrice,
                  deliveryPrice: fetchedData[i].deliveryPrice,
                  isAttributeMandatory: fetchedData[i].isAttributeMandatory,
                  isProductInStock: fetchedData[i].isProductInStock,
                  isStockManagementActivated: fetchedData[i]
                      .isStockManagementActivated,
                  dailyQuantityLimit: fetchedData[i].dailyQuantityLimit,
                  color: fetchedData[i].color,
                  position: fetchedData[i].position,
                  isHideInKitchen: fetchedData[i].isHideInKitchen,
                  serverId: fetchedData[i].serverId,
                  catServerId: fetchedData[i].categoryID,
                  isActivated: fetchedData[i].isActivated,
                  dailyQuantityConsumed: fetchedData[i].dailyQuantityConsumed,
                    attributeCategoryIds: fetchedData[i].attributeCategoryIds
                );
                if (value != null) {
                  value.name = fetchedData[i].name;
                  value.serverId = fetchedData[i].serverId;
                  value.description = fetchedData[i].description;
                  value.displayName = fetchedData[i].displayName;
                  value.categoryID = fetchedData[i].categoryID;
                  value.eatInPrice = fetchedData[i].eatInPrice;
                  value.deliveryPrice = fetchedData[i].deliveryPrice;
                  value.allergence = fetchedData[i].allergence;
                  value.isEnablePricePerOrderType =
                      fetchedData[i].isEnablePricePerOrderType;

                  value.price = fetchedData[i].price;
                  value.position = fetchedData[i].position;
                  value.displayName = fetchedData[i].displayName;
                  value.catServerId = fetchedData[i].catServerId;
                  value.color = fetchedData[i].color;
                  value.isHideInKitchen = fetchedData[i].isHideInKitchen;
                  value.isAttributeMandatory =
                      fetchedData[i].isAttributeMandatory;
                  value.isActivated = fetchedData[i].isActivated;
                  value.dailyQuantityConsumed =fetchedData[i].dailyQuantityConsumed;
                  value.attributeCategoryIds= fetchedData[i].attributeCategoryIds;
                  value.isProductInStock = fetchedData[i].isProductInStock;
                  FoodItemsDao().updateFoodItem(value).then((res1) {
                    FBroadcast.instance().broadcast(
                        ConstantBroadcastKeys.KEY_UPDATE_UI);
                    if (i == fetchedData.length - 1) {}
                  });
                }
                else {
                  //FoodCategoryModel foodCategoryModel=FoodCategoryModel(0, "", "", "", 0,false,false,"");
                  FoodCategoryModel? foodCategoryModel = await FoodCategoryDao()
                      .getFoodCategoryByServerId(foodItemsModel.categoryID);
                  if (foodCategoryModel != null) {
                    FoodItemsDao().insertFoodItem(
                        foodCategoryModel!, foodItemsModel).then((res2) {
                      FBroadcast.instance().broadcast(
                          ConstantBroadcastKeys.KEY_UPDATE_UI);
                      if (i == fetchedData.length - 1) {}
                    });
                  }
                }
              });
            }
            else {
              var imgUrl = ServerData.OPTIFOOD_IMAGES + "/items/" +
                  fetchedData[i].imagePath.toString();
              final response1 = await http.get(Uri.parse(imgUrl));
              final imageName = path.basename(imgUrl);
              final documentDirectory1 = await getApplicationDocumentsDirectory();
              final localPath = path.join(documentDirectory1.path, imageName);
              final imageFile = File(localPath);
              await imageFile.writeAsBytes(response1.bodyBytes).then((
                  value222) {
                var image = imageFile.toString().substring(8, imageFile
                    .toString()
                    .length - 1);
                fetchedData[i].imagePath = image;
                FoodItemsDao()
                    .getFoodItemByServerId(fetchedData[i].serverId!)
                    .then((value) {
                  FoodItemsModel foodItemsModel = FoodItemsModel(
                    fetchedData[i].id,
                    fetchedData[i].name,
                    fetchedData[i].displayName,
                    fetchedData[i].description,
                    fetchedData[i].allergence,
                    fetchedData[i].price,
                    imagePath: fetchedData[i].imagePath,
                    isEnablePricePerOrderType: fetchedData[i]
                        .isEnablePricePerOrderType,
                    // isEnablePricePerOrderType: fetchedData[i]
                    //     .isEnablePricePerOrderType,
                    categoryID: fetchedData[i].categoryID,
                    eatInPrice: fetchedData[i].eatInPrice,
                    deliveryPrice: fetchedData[i].deliveryPrice,
                    isAttributeMandatory: fetchedData[i].isAttributeMandatory,
                    // isProductInStock: fetchedData[i].isProductInStock,
                    // isStockManagementActivated: fetchedData[i]
                    //     .isStockManagementActivated,
                    // dailyQuantityLimit: fetchedData[i].dailyQuantityLimit,
                    color: fetchedData[i].color,
                    isHideInKitchen: fetchedData[i].isHideInKitchen,
                    serverId: fetchedData[i].serverId,
                    catServerId: fetchedData[i].catServerId,
                    isActivated: fetchedData[i].isActivated,

                    // attributeCategoryIds: fetchedData[i].attributeCategoryIds
                  );
                  if (value != null) {
                    value.name = fetchedData[i].name;
                    value.serverId = fetchedData[i].serverId;
                    value.description = fetchedData[i].description;
                    value.displayName = fetchedData[i].displayName;
                    value.categoryID = fetchedData[i].categoryID;
                    value.eatInPrice = fetchedData[i].eatInPrice;
                    value.deliveryPrice = fetchedData[i].deliveryPrice;
                    value.allergence = fetchedData[i].allergence;
                    value.price = fetchedData[i].price;
                    value.isEnablePricePerOrderType =
                        fetchedData[i].isEnablePricePerOrderType;

                    value.displayName = fetchedData[i].displayName;
                    value.catServerId = fetchedData[i].catServerId;
                    value.color = fetchedData[i].color;
                    value.isHideInKitchen = fetchedData[i].isHideInKitchen;
                    value.isAttributeMandatory =
                        fetchedData[i].isAttributeMandatory;
                    value.isActivated = fetchedData[i].isActivated;
                    FoodItemsDao().updateFoodItem(value).then((res1) {
                      FBroadcast.instance().broadcast(
                          ConstantBroadcastKeys.KEY_UPDATE_UI);
                      if (i == fetchedData.length - 1) {}
                    });
                  }
                  else {
                    FoodCategoryModel foodCategoryModel = FoodCategoryModel(
                        0,
                        "",
                        "",
                        "",
                        0,
                        false,
                        false,
                        "");
                    FoodItemsDao().insertFoodItem(
                        foodCategoryModel, foodItemsModel).then((res2) {
                      FBroadcast.instance().broadcast(
                          ConstantBroadcastKeys.KEY_UPDATE_UI);
                      if (i == fetchedData.length - 1) {}
                    });
                  }
                });
              });
            }
          }
        }
        if(callback!=null){
          callback();
        }
      }
      catch(onError){
        if(callback!=null){
          callback();
        }
      }

    });
  }

  static resetDailyQuantityConsumed() async {
    FoodItemsDao().getAllFoodItems().then((value) {
      for (int i = 0; i < value.length; i++) {
        value[i].dailyQuantityConsumed = 0;
        value[i].isProductInStock = true;
        FoodItemsDao().updateFoodItem(value[i]).then((value333333) {});
      }
    });
    final dio = Dio();
    dio.options.headers['X-TenantID'] = OPTIFOOD_DATABASE;
    dio.options.headers['Authorization'] = authorization;
    await dio.put(ServerData.OPTIFOOD_BASE_URL+'/api/item/reset-consumed');
  }




  static saveFoodItemsDataFromServerToLocalDB(var responseData, {Function? callback = null}) async {
    List<FoodItemsModel> fetchedData = [];
    int j = 0;
    for (int i = 0; i < responseData.length; i++) {
      try{
        var singleItem = FoodItemsModel.fromJsonServer(
            responseData[i]);
      }
      catch(e,d){
        print(d);
      }
      var singleItem = FoodItemsModel.fromJsonServer(
          responseData[i]);
      if(responseData[i]['deleted']) {
        print("Now check for delete food item ${responseData[i]['deleted']}");
        FoodCategoryDao().getFoodCategoryByServerId(singleItem.categoryID).then((value) {
          FoodItemsDao().getFoodItemByServerId(singleItem.serverId!).then((value1) {
            FoodItemsDao().delete(value!,value1!);
          });
        });

      }
      else
        fetchedData.add(singleItem);
    }

    for (int i = 0; i < fetchedData.length; i++) {
      /*if (fetchedData[i].deliveryPrice != 0 &&
          fetchedData[i].deliveryPrice != null &&
          fetchedData[i].eatInPrice != 0 &&
          fetchedData[i].eatInPrice != null) {
        fetchedData[i].isEnablePricePerOrderType = true;
      }
      else {
        fetchedData[i].isEnablePricePerOrderType = false;
      }*/

      var imgUrl = ServerData.OPTIFOOD_IMAGES + "/items/" +
          fetchedData[i].imagePath.toString();
      final response1 = await http.get(Uri.parse(imgUrl));
      final imageName = path.basename(imgUrl);
      if (true) {
        FoodItemsDao()
            .getFoodItemByServerId(fetchedData[i].serverId!)
            .then((value) async {
          FoodItemsModel foodItemsModel = FoodItemsModel(
              fetchedData[i].id,
              fetchedData[i].name,
              fetchedData[i].displayName,
              fetchedData[i].description,
              fetchedData[i].allergence,
              fetchedData[i].price,
              imagePath: null,
              isEnablePricePerOrderType: fetchedData[i]
                  .isEnablePricePerOrderType,
              categoryID: fetchedData[i].categoryID,
              eatInPrice: fetchedData[i].eatInPrice,
              deliveryPrice: fetchedData[i].deliveryPrice,
              isAttributeMandatory: fetchedData[i].isAttributeMandatory,
              isProductInStock: fetchedData[i].isProductInStock,
              isStockManagementActivated: fetchedData[i]
                  .isStockManagementActivated,
              dailyQuantityLimit: fetchedData[i].dailyQuantityLimit,
              color: fetchedData[i].color,
              position: fetchedData[i].position,
              isHideInKitchen: fetchedData[i].isHideInKitchen,
              serverId: fetchedData[i].serverId,
              catServerId: fetchedData[i].categoryID,
              isActivated: fetchedData[i].isActivated,
              dailyQuantityConsumed: fetchedData[i].dailyQuantityConsumed
          );
          if (value != null) {
            value.name = fetchedData[i].name;
            value.serverId = fetchedData[i].serverId;
            value.description = fetchedData[i].description;
            value.displayName = fetchedData[i].displayName;
            value.categoryID = fetchedData[i].categoryID;
            value.eatInPrice = fetchedData[i].eatInPrice;
            value.deliveryPrice = fetchedData[i].deliveryPrice;
            value.allergence = fetchedData[i].allergence;
            value.isEnablePricePerOrderType =
                fetchedData[i].isEnablePricePerOrderType;

            value.price = fetchedData[i].price;
            value.position = fetchedData[i].position;
            value.displayName = fetchedData[i].displayName;
            value.catServerId = fetchedData[i].catServerId;
            value.color = fetchedData[i].color;
            value.isHideInKitchen = fetchedData[i].isHideInKitchen;
            value.isAttributeMandatory =
                fetchedData[i].isAttributeMandatory;
            value.isActivated = fetchedData[i].isActivated;
            value.isStockManagementActivated = fetchedData[i].isStockManagementActivated;
            value.dailyQuantityLimit = fetchedData[i].dailyQuantityLimit;
            value.dailyQuantityConsumed =
                fetchedData[i].dailyQuantityConsumed;
            /*if(value.dailyQuantityLimit>value.dailyQuantityConsumed){
              value.isProductInStock = true;
            }*/
            value.isProductInStock = fetchedData[i].isProductInStock;
            FoodItemsDao().updateFoodItem(value).then((res1) {
              FBroadcast.instance().broadcast(
                  ConstantBroadcastKeys.KEY_UPDATE_UI);
              if (i == fetchedData.length - 1) {}
            });
          }
          else {
            FoodCategoryModel? foodCategoryModel = await FoodCategoryDao()
                .getFoodCategoryByServerId(foodItemsModel.categoryID);

            if (foodCategoryModel != null) {
              FoodItemsDao().insertFoodItem(
                  foodCategoryModel!, foodItemsModel).then((res2) {
                FBroadcast.instance().broadcast(
                    ConstantBroadcastKeys.KEY_UPDATE_UI);
                if (i == fetchedData.length - 1) {}
              });
            }
          }
        });
      }
    }
  }
  deleteFoodItem(int serverId) async {
    final dio = Dio();
    dio.options.headers['X-TenantID'] = OPTIFOOD_DATABASE.toString();
    await dio.delete(ServerData.OPTIFOOD_BASE_URL+"/api/item/${serverId}").then((value){
    });
  }
  deactivateFoodItem(int itemId, bool isActivated) async {
    final dio = Dio();
    dio.options.headers['X-TenantID'] = OPTIFOOD_DATABASE.toString();
    await dio.put(ServerData.OPTIFOOD_BASE_URL+"/api/item/item-deactivate/${itemId}", queryParameters: {
      "deactivate":isActivated
    }).then((value){
    });

  }
}