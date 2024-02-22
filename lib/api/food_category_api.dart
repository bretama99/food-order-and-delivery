import 'dart:io';
import 'package:dio/dio.dart';
import 'package:fbroadcast/fbroadcast.dart';
import 'package:path_provider/path_provider.dart';
import '../data_models/food_category_model.dart';
import '../data_models/server_sync_action_pending.dart';
import '../database/food_category_dao.dart';
import '../main.dart';
import '../utils/constants.dart';
import '../utils/utility.dart';
import 'package:path/path.dart' as path;
import 'package:http/http.dart' as http;

class FoodCategoryApi{
  static String OPTIFOOD_DATABASE=optifoodSharedPrefrence.getString("database").toString();
  static String authorization = optifoodSharedPrefrence.getString("accessToken").toString();
  Future<void> syncFoodCategories() async {
    List<FoodCategoryModel> foodCategoryList = await FoodCategoryDao().getUnSyncedFoodCategory();
    foodCategoryList.forEach((element) {
      ServerSyncActionPending serverSyncActionPending = Utility().getServerSyncActionPending(element.syncOnServerActionPending);
      if(serverSyncActionPending.isPendingCreate){
        saveFoodCategoryToSever(element);
      }
      else if(serverSyncActionPending.isPendingUpdate){
        saveFoodCategoryToSever(element,isUpdate: true);
      }
    });
  }

  saveFoodCategoryToSever(FoodCategoryModel foodCategoryModel,{bool isUpdate=false})async{
    final dio = Dio();
    dio.options.headers['X-TenantID'] = OPTIFOOD_DATABASE;
    dio.options.headers['Authorization'] = authorization;
    //FoodCategoryDao().getFoodCategoryLast().then((value) async{
      var formData;
      //if(_image==null) {

        formData = FormData.fromMap({
          'itemCategoryName': foodCategoryModel.name,
          'displayName': foodCategoryModel.displayName,
          'color': foodCategoryModel.color,
          'position': foodCategoryModel.position,
          "attributeRequired": foodCategoryModel.isAttributeMandatory,
          "showKichen": foodCategoryModel.isHideInKitchen
        });
      /*}
      else{
        formData = FormData.fromMap({
          'itemCategoryName': value.name,
          'displayName': value.displayName,
          'color': value.color,
          'position': value.position,
          'image': MultipartFile.fromBytes(_image.readAsBytesSync(), filename: fileName),
          "isAttributeRequired": value.isAttributeMandatory,
          "isShowKichen": value.isHideInKitchen
        });
      }*/
      //var response = await dio.post(ServerData.OPTIFOOD_BASE_URL+"/api/item-category",
      if(isUpdate){
        //await dio.put(ServerData.OPTIFOOD_BASE_URL + "/api/item-category"+foodCategoryModel.serverId.toString(),
        dio.put(ServerData.OPTIFOOD_BASE_URL + "/api/item-category/"+foodCategoryModel.serverId.toString(),
          data: formData,
        ).then((response) async {
          print("success");
          var singleData = FoodCategoryModel.fromJsonServer(response.data);
          foodCategoryModel.isSyncedOnServer = true;
          foodCategoryModel.isSyncOnServerProcessing = false;
          foodCategoryModel.syncOnServerActionPending = Utility().removeServerSyncActionPending(ConstantSyncOnServerPendingActions.ACTION_PENDING_UPDATE);
          await FoodCategoryDao().updateFoodCategory(foodCategoryModel);
          FBroadcast.instance().broadcast(
              ConstantBroadcastKeys.KEY_UPDATE_UI);
        }).catchError((onError) async {
          foodCategoryModel.isSyncedOnServer=false;
          foodCategoryModel.isSyncOnServerProcessing = false;
          await FoodCategoryDao().updateFoodCategory(foodCategoryModel);
          FBroadcast.instance().broadcast(
              ConstantBroadcastKeys.KEY_UPDATE_UI);
          optifoodBackgroundService.syncPendingLocalData();
        });
      }
      else {
        await dio.post(ServerData.OPTIFOOD_BASE_URL + "/api/item-category",
          data: formData,
        ).then((response) async {
          print("success");
          var singleData = FoodCategoryModel.fromJsonServer(response.data);
          foodCategoryModel.isSyncedOnServer = true;
          foodCategoryModel.serverId = singleData.serverId;
          foodCategoryModel.isSyncOnServerProcessing = false;
          foodCategoryModel.syncOnServerActionPending = Utility().removeServerSyncActionPending(ConstantSyncOnServerPendingActions.ACTION_PENDING_UPDATE);
          await FoodCategoryDao().updateFoodCategory(foodCategoryModel);
          FBroadcast.instance().broadcast(
              ConstantBroadcastKeys.KEY_UPDATE_UI);
        }).catchError((onError) async {
          foodCategoryModel.isSyncedOnServer=false;
          foodCategoryModel.isSyncOnServerProcessing = false;
          await FoodCategoryDao().updateFoodCategory(foodCategoryModel);
          FBroadcast.instance().broadcast(
              ConstantBroadcastKeys.KEY_UPDATE_UI);
          optifoodBackgroundService.syncPendingLocalData();
        });
      }
    //});
  }

   void getFoodCategoryListFromServer({Function? callback = null}) async {
    final dio = Dio();
    List<FoodCategoryModel> fetchedData = [];
    dio.options.headers['X-TenantID'] = OPTIFOOD_DATABASE;
    dio.options.headers['Authorization'] = authorization;
    await dio.get(ServerData.OPTIFOOD_BASE_URL+"/api/item-category").then((response) async {
      List<FoodCategoryModel> fetchedData = [];
      if (response.statusCode == 200) {
        for (int i = 0; i < response.data.length; i++) {
         /* try{
            var singleItem = FoodCategoryModel.fromJsonServer(response.data[i]);
          }
          catch(e,d){
            print(d);
          }*/
          var singleItem = FoodCategoryModel.fromJsonServer(response.data[i]);
          fetchedData.add(singleItem);
        }

        for (int i = 0; i < fetchedData.length; i++) {

          if(fetchedData[i].imagePath.toString()=='null'){
            FoodCategoryDao().getFoodCategoryByServerId(fetchedData[i].serverId!).then((
                value) {
              FoodCategoryModel foodCategoryModel = FoodCategoryModel(
                  fetchedData[i].id,
                  fetchedData[i].name,
                  fetchedData[i].displayName,
                  fetchedData[i].color,
                  1,
                  fetchedData[i].isHideInKitchen,
                  fetchedData[i].isAttributeMandatory,
                  null,
                  serverId: fetchedData[i].serverId,
                  foodItemsCount:fetchedData[i].foodItemsCount
              );
              if (value!=null) {
                value.name=fetchedData[i].name;
                value.serverId=fetchedData[i].serverId;
                value.foodItemsCount=fetchedData[i].foodItemsCount;
                value.displayName = fetchedData[i].displayName;
                value.color = fetchedData[i].color;
                value.isHideInKitchen=fetchedData[i].isHideInKitchen;
                value.isAttributeMandatory = fetchedData[i].isAttributeMandatory;
                FoodCategoryDao()
                    .updateFoodCategory(value)
                    .then((res1) {
                  FBroadcast.instance().broadcast(
                      ConstantBroadcastKeys.KEY_UPDATE_UI);
                  if (i == fetchedData.length - 1) {
                  }
                });
              }
              else {
                FoodCategoryDao().insertFoodCategory(foodCategoryModel).then((
                    res2) {
                  FBroadcast.instance().broadcast(
                      ConstantBroadcastKeys.KEY_UPDATE_UI);
                  if (i == fetchedData.length - 1) {
                  }
                });
              }
            });

          }
          else{
            var imgUrl = ServerData.OPTIFOOD_IMAGES+"/item_category_images/"+fetchedData[i].imagePath.toString();

            final response1 = await http.get(Uri.parse(imgUrl));
            final imageName = path.basename(imgUrl);
            final documentDirectory1 = await getApplicationDocumentsDirectory();
            final localPath = path.join(documentDirectory1.path, imageName);
            final imageFile = File(localPath);
            await imageFile.writeAsBytes(response1.bodyBytes).then((value222){
              var image = imageFile.toString().substring(8, imageFile.toString().length - 1);
              fetchedData[i].imagePath=image;
              FoodCategoryDao().getFoodCategoryByServerId(fetchedData[i].serverId!).then((
                  value) {
                FoodCategoryModel foodCategoryModel = FoodCategoryModel(
                    fetchedData[i].id,
                    fetchedData[i].name,
                    fetchedData[i].displayName,
                    fetchedData[i].color,
                    1,
                    fetchedData[i].isHideInKitchen,
                    fetchedData[i].isAttributeMandatory,
                    fetchedData[i].imagePath,
                    serverId: fetchedData[i].serverId,
                    foodItemsCount:fetchedData[i].foodItemsCount
                );
                if (value!=null) {
                  value.name=fetchedData[i].name;
                  value.serverId=fetchedData[i].serverId;
                  value.foodItemsCount=fetchedData[i].foodItemsCount;
                  value.displayName = fetchedData[i].displayName;
                  value.color = fetchedData[i].color;
                  value.isHideInKitchen=fetchedData[i].isHideInKitchen;
                  value.isAttributeMandatory = fetchedData[i].isAttributeMandatory;
                  FoodCategoryDao()
                      .updateFoodCategory(value)
                      .then((res1) {
                    FBroadcast.instance().broadcast(
                        ConstantBroadcastKeys.KEY_UPDATE_UI);
                    if (i == fetchedData.length - 1) {
                    }
                  });
                }
                else {

                  FoodCategoryDao().insertFoodCategory(foodCategoryModel).then((
                      res2) {
                    FBroadcast.instance().broadcast(
                        ConstantBroadcastKeys.KEY_UPDATE_UI);
                    if (i == fetchedData.length - 1) {
                    }
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
    }).catchError((onError){
      if(callback!=null){
        callback();
      }
    });
  }

  static saveFoodCategoryItemDataFromServerToLocalDB(var responseData, {Function? callback = null}) async {
    List<FoodCategoryModel> fetchedData = [];
    for (int i = 0; i < responseData.length; i++) {
      var singleItem = FoodCategoryModel.fromJsonServer(responseData[i]);
      if(responseData[i]['deleted']) {
          print("Now check for delete food item ${responseData[i]['deleted']}");
          FoodCategoryDao().getFoodCategoryByServerId(singleItem.serverId!).then((value) {
            //FoodCategoryDao().delete(singleItem);
            if(value!=null) {
              FoodCategoryDao().delete(value!);
            }
          });
      }
      else
        fetchedData.add(singleItem);
    }
    for (int i = 0; i < fetchedData.length; i++) {
      var imgUrl = ServerData.OPTIFOOD_IMAGES+"/item_category_images/"+fetchedData[i].imagePath.toString();
      final response1 = await http.get(Uri.parse(imgUrl));
      final imageName = path.basename(imgUrl);
      if(imageName=='null'){
        FoodCategoryDao().getFoodCategoryByServerId(fetchedData[i].serverId!).then((
            value) {
          FoodCategoryModel foodCategoryModel = FoodCategoryModel(
              fetchedData[i].id,
              fetchedData[i].name,
              fetchedData[i].displayName,
              fetchedData[i].color,
              1,
              fetchedData[i].isHideInKitchen,
              fetchedData[i].isAttributeMandatory,
              null,
              serverId: fetchedData[i].serverId,
              foodItemsCount:fetchedData[i].foodItemsCount
          );
          if (value!=null) {
            value.name=fetchedData[i].name;
            value.serverId=fetchedData[i].serverId;
            value.foodItemsCount=fetchedData[i].foodItemsCount;
            value.displayName = fetchedData[i].displayName;
            value.color = fetchedData[i].color;
            value.isHideInKitchen=fetchedData[i].isHideInKitchen;
            value.isAttributeMandatory = fetchedData[i].isAttributeMandatory;
            print("Updatinggggggggggggggggggggggggggggggggggggggggg");
            FoodCategoryDao()
                .updateFoodCategory(value)
                .then((res1) {
              FBroadcast.instance().broadcast(
                  ConstantBroadcastKeys.KEY_UPDATE_UI);
              if (i == fetchedData.length - 1) {
              }
            });
          }
          else {

            FoodCategoryDao().insertFoodCategory(foodCategoryModel).then((
                res2) {
              FBroadcast.instance().broadcast(
                  ConstantBroadcastKeys.KEY_UPDATE_UI);
              if (i == fetchedData.length - 1) {
              }
            });
          }
        });

      }
      else{
        final documentDirectory1 = await getApplicationDocumentsDirectory();
        final localPath = path.join(documentDirectory1.path, imageName);
        final imageFile = File(localPath);
        await imageFile.writeAsBytes(response1.bodyBytes).then((value222){
          var image = imageFile.toString().substring(8, imageFile.toString().length - 1);
          fetchedData[i].imagePath=image;
          FoodCategoryDao().getFoodCategoryByServerId(fetchedData[i].serverId!).then((
              value) {
            FoodCategoryModel foodCategoryModel = FoodCategoryModel(
                fetchedData[i].id,
                fetchedData[i].name,
                fetchedData[i].displayName,
                fetchedData[i].color,
                1,
                fetchedData[i].isHideInKitchen,
                fetchedData[i].isAttributeMandatory,
                fetchedData[i].imagePath,
                serverId: fetchedData[i].serverId,
                foodItemsCount:fetchedData[i].foodItemsCount
            );
            if (value!=null) {
              value.name=fetchedData[i].name;
              value.serverId=fetchedData[i].serverId;
              value.foodItemsCount=fetchedData[i].foodItemsCount;
              value.displayName = fetchedData[i].displayName;
              value.color = fetchedData[i].color;
              value.isHideInKitchen=fetchedData[i].isHideInKitchen;
              value.isAttributeMandatory = fetchedData[i].isAttributeMandatory;
              FoodCategoryDao()
                  .updateFoodCategory(value)
                  .then((res1) {
                FBroadcast.instance().broadcast(
                    ConstantBroadcastKeys.KEY_UPDATE_UI);
                if (i == fetchedData.length - 1) {
                }
              });
            }
            else {

              FoodCategoryDao().insertFoodCategory(foodCategoryModel).then((
                  res2) {
                FBroadcast.instance().broadcast(
                    ConstantBroadcastKeys.KEY_UPDATE_UI);
                if (i == fetchedData.length - 1) {
                }
              });
            }
          });
        });
      }
    }
    if(callback!=null){
      callback();
    }

  }
  deleteCategory(int serverId) async {
    final dio = Dio();
    dio.options.headers['X-TenantID'] = OPTIFOOD_DATABASE.toString();
    await dio.delete(ServerData.OPTIFOOD_BASE_URL+"/api/item-category/${serverId}").then((value){
    });
  }
}