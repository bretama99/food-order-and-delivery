import 'dart:io';

import 'package:dio/dio.dart';
import 'package:fbroadcast/fbroadcast.dart';
import 'package:path_provider/path_provider.dart';

import '../data_models/attribute_category_model.dart';
import '../data_models/server_sync_action_pending.dart';
import '../database/attribute_category_dao.dart';
import '../main.dart';
import '../utils/constants.dart';
import '../utils/utility.dart';
import 'package:path/path.dart' as path;
import 'package:http/http.dart' as http;

class AttributeCategoryApi{
  static String OPTIFOOD_DATABASE=optifoodSharedPrefrence.getString("database").toString();
  static String authorization = optifoodSharedPrefrence.getString("accessToken").toString();
  Future<void> syncAttributeCategories() async {
    List<AttributeCategoryModel> attributeCategoryList = await AttributeCategoryDao().getUnSyncedAttributeCategory();
    attributeCategoryList.forEach((element) {
      ServerSyncActionPending serverSyncActionPending = Utility().getServerSyncActionPending(element.syncOnServerActionPending);
      if(serverSyncActionPending.isPendingCreate){
        saveAttributeCategoryToSever(element);
      }
      else if(serverSyncActionPending.isPendingUpdate){
        saveAttributeCategoryToSever(element,isUpdate: true);
      }
    });
  }
  void saveAttributeCategoryToSever(AttributeCategoryModel attributeCategoryModel,{isUpdate = false})async{
    final dio = Dio();
    dio.options.headers['X-TenantID'] = OPTIFOOD_DATABASE;
    dio.options.headers['Authorization'] = authorization;
      var formData;
        formData = FormData.fromMap({
          'attributeCategoryName': attributeCategoryModel.name,
          'displayName' : attributeCategoryModel.displayName,
          'color': attributeCategoryModel.color,
          'position': attributeCategoryModel.position,
        });
      if(isUpdate){
        await dio.put(ServerData.OPTIFOOD_BASE_URL+'/api/attribute-category/'+attributeCategoryModel.serverId.toString(),
          data: formData,
        ).then((response) async {
          var singleData = AttributeCategoryModel.fromJsonServer(response.data);
          attributeCategoryModel.isSyncedOnServer=true;
          attributeCategoryModel.isSyncOnServerProcessing = false;
          attributeCategoryModel.syncOnServerActionPending = Utility().removeServerSyncActionPending(ConstantSyncOnServerPendingActions.ACTION_PENDING_UPDATE);
          await AttributeCategoryDao().updateAttributeCategory(attributeCategoryModel);
          FBroadcast.instance().broadcast(
              ConstantBroadcastKeys.KEY_UPDATE_UI);
        }).catchError((onError) async {
          attributeCategoryModel.isSyncedOnServer=false;
          attributeCategoryModel.isSyncOnServerProcessing = false;
          await AttributeCategoryDao().updateAttributeCategory(attributeCategoryModel);
          FBroadcast.instance().broadcast(
              ConstantBroadcastKeys.KEY_UPDATE_UI);
          optifoodBackgroundService.syncPendingLocalData();
        });
      }
      else{
        await dio.post(ServerData.OPTIFOOD_BASE_URL+'/api/attribute-category',
          data: formData,
        ).then((response) async {
          var singleData = AttributeCategoryModel.fromJsonServer(response.data);
          attributeCategoryModel.isSyncedOnServer=true;
          attributeCategoryModel.isSyncOnServerProcessing = false;
          attributeCategoryModel.serverId=singleData.serverId;
          attributeCategoryModel.syncOnServerActionPending = Utility().removeServerSyncActionPending(ConstantSyncOnServerPendingActions.ACTION_PENDING_CREATE);
          await AttributeCategoryDao().updateAttributeCategory(attributeCategoryModel);
          FBroadcast.instance().broadcast(
              ConstantBroadcastKeys.KEY_UPDATE_UI);
        }).catchError((onError) async {
          attributeCategoryModel.isSyncedOnServer=false;
          attributeCategoryModel.isSyncOnServerProcessing = false;
          await AttributeCategoryDao().updateAttributeCategory(attributeCategoryModel);
          FBroadcast.instance().broadcast(
              ConstantBroadcastKeys.KEY_UPDATE_UI);
          optifoodBackgroundService.syncPendingLocalData();
        });
      }
  }

  void getAttributeCategoryListFromServer({Function? callback = null}) async{
    List<AttributeCategoryModel> fetchedData = [];
    final dio = Dio();
    dio.options.headers['X-TenantID'] = OPTIFOOD_DATABASE;
    dio.options.headers['Authorization'] = authorization;
    await dio.get(ServerData.OPTIFOOD_BASE_URL+"/api/attribute-category").then((response) async {
      List<AttributeCategoryModel> fetchedData = [];
      try {
        if (response.statusCode == 200) {
          saveAttributCategoryDataFromServerToLocalDB(response.data, callback: () {
            callback!();
          });
          /*for (int i = 0; i < response.data.length; i++) {
            var singleItem = AttributeCategoryModel.fromJsonServer(
                response.data[i]);
            print("Print items lengthhhhhhhhhhhh: ${response.data[i]}");
            fetchedData.add(singleItem);
          }
          for (int i = 0; i < fetchedData.length; i++) {

            if (fetchedData[i].imagePath.toString() == 'null') {
              AttributeCategoryDao().getAttributeCategoryByServerId(
                  fetchedData[i].serverId!).then((value) {
                AttributeCategoryModel attributeCategoryModel = AttributeCategoryModel(
                  1,
                  fetchedData[i].name,
                  fetchedData[i].displayName,
                  fetchedData[i].color,
                  fetchedData[i].position,
                  null,
                  attributeCount: fetchedData[i].attributeCount,
                  serverId: fetchedData[i].serverId,
                );
                if (value != null) {
                  value.name = fetchedData[i].name;
                  value.displayName = fetchedData[i].displayName;
                  value.color = fetchedData[i].color;
                  value.position = fetchedData[i].position;
                  value.attributeCount = fetchedData[i].attributeCount;
                  value.serverId = fetchedData[i].serverId;
                  AttributeCategoryDao().updateAttributeCategory(value).then((
                      res1) {
                    if (i == fetchedData.length - 1) {}
                  });
                }
                else {
                  AttributeCategoryDao().insertAttributeCategory(
                      attributeCategoryModel).then((res2) {
                    if (i == fetchedData.length - 1) {}
                  });
                }
              });
            }
            else {
              var imgUrl = ServerData.OPTIFOOD_IMAGES +
                  "/attribute_category_images/" +
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
                AttributeCategoryDao().getAttributeCategoryByServerId(
                    fetchedData[i].serverId!).then((value) {
                  AttributeCategoryModel attributeCategoryModel = AttributeCategoryModel(
                    1,
                    fetchedData[i].name,
                    fetchedData[i].displayName,
                    fetchedData[i].color,
                    fetchedData[i].position,
                    fetchedData[i].imagePath,
                    attributeCount: fetchedData[i].attributeCount,
                    serverId: fetchedData[i].serverId,
                  );
                  if (value != null) {
                    value.name = fetchedData[i].name;
                    value.displayName = fetchedData[i].displayName;
                    value.color = fetchedData[i].color;
                    value.position = fetchedData[i].position;
                    value.attributeCount = fetchedData[i].attributeCount;
                    value.serverId = fetchedData[i].serverId;
                    AttributeCategoryDao().updateAttributeCategory(value).then((
                        res1) {
                      if (i == fetchedData.length - 1) {}
                    });
                  }
                  else {
                    AttributeCategoryDao().insertAttributeCategory(
                        attributeCategoryModel).then((res2) {
                      if (i == fetchedData.length - 1) {}
                    });
                  }
                });
              });
            }
          }*/
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

  static saveAttributCategoryDataFromServerToLocalDB(var responseData, {Function? callback = null}) async {

    print("======fetchedData.attributeCount========pppppppppppppppppppppppppppppppppppppppp}============");

    List<AttributeCategoryModel> fetchedData = [];
    for (int i = 0; i < responseData.length; i++) {
      var singleItem = AttributeCategoryModel.fromJsonServer(
          responseData[i]);
      if(responseData[i]['deleted']) {
        print("Now check for delete food item ${responseData[i]['deleted']}");
        AttributeCategoryDao().getAttributeCategoryByServerId(singleItem.serverId!).then((value) {
          //FoodCategoryDao().delete(singleItem);
          if(value!=null) {
            AttributeCategoryDao().delete(value);
          }
        });

      }
      else
        fetchedData.add(singleItem);
    }
    print("======fetchedData.fetchedData.length========${fetchedData.length}============");
    for (int i = 0; i < fetchedData.length; i++) {
      print("======fetchedData.attributeCount========${fetchedData[i].attributeCount}============");
      if (fetchedData[i].imagePath.toString() == 'null') {
        AttributeCategoryDao().getAttributeCategoryByServerId(
            fetchedData[i].serverId!).then((value) {
          AttributeCategoryModel attributeCategoryModel = AttributeCategoryModel(
            1,
            fetchedData[i].name,
            fetchedData[i].displayName,
            fetchedData[i].color,
            fetchedData[i].position,
            null,
            attributeCount: fetchedData[i].attributeCount,
            serverId: fetchedData[i].serverId,
          );
          if (value != null) {
            value.name = fetchedData[i].name;
            value.displayName = fetchedData[i].displayName;
            value.color = fetchedData[i].color;
            value.position = fetchedData[i].position;
            value.attributeCount = fetchedData[i].attributeCount;
            value.serverId = fetchedData[i].serverId;
            AttributeCategoryDao().updateAttributeCategory(value).then((
                res1) {
              FBroadcast.instance().broadcast(
                  ConstantBroadcastKeys.KEY_UPDATE_UI);
              if (i == fetchedData.length - 1) {}
            });
          }
          else {
            AttributeCategoryDao().insertAttributeCategory(
                attributeCategoryModel).then((res2) {
              FBroadcast.instance().broadcast(
                  ConstantBroadcastKeys.KEY_UPDATE_UI);
              if (i == fetchedData.length - 1) {}
            });
          }
        });
      }
      else {
        var imgUrl = ServerData.OPTIFOOD_IMAGES +
            "/attribute_category_images/" +
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
          AttributeCategoryDao().getAttributeCategoryByServerId(
              fetchedData[i].serverId!).then((value) {
            AttributeCategoryModel attributeCategoryModel = AttributeCategoryModel(
              1,
              fetchedData[i].name,
              fetchedData[i].displayName,
              fetchedData[i].color,
              fetchedData[i].position,
              fetchedData[i].imagePath,
              attributeCount: fetchedData[i].attributeCount,
              serverId: fetchedData[i].serverId,
            );
            if (value != null) {
              value.name = fetchedData[i].name;
              value.displayName = fetchedData[i].displayName;
              value.color = fetchedData[i].color;
              value.position = fetchedData[i].position;
              value.attributeCount = fetchedData[i].attributeCount;
              value.serverId = fetchedData[i].serverId;
              AttributeCategoryDao().updateAttributeCategory(value).then((
                  res1) {
                FBroadcast.instance().broadcast(
                    ConstantBroadcastKeys.KEY_UPDATE_UI);
                if (i == fetchedData.length - 1) {}
              });
            }
            else {
              AttributeCategoryDao().insertAttributeCategory(
                  attributeCategoryModel).then((res2) {
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

   deleteAttributeCategory(int serverId) async {
    final dio = Dio();
    dio.options.headers['X-TenantID'] = OPTIFOOD_DATABASE;
    await dio.delete(ServerData.OPTIFOOD_BASE_URL+"/api/attribute-category/${serverId}").then((value){
    }).catchError((onError){
    });
  }
}