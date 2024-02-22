import 'dart:io';
import 'package:dio/dio.dart';
import 'package:fbroadcast/fbroadcast.dart';
import 'package:opti_food_app/database/attribute_category_dao.dart';
import 'package:path_provider/path_provider.dart';
import '../data_models/attribute_category_model.dart';
import '../data_models/attribute_model.dart';
import '../data_models/server_sync_action_pending.dart';
import '../database/attribute_dao.dart';
import '../main.dart';
import '../utils/constants.dart';
import '../utils/utility.dart';
import 'package:path/path.dart' as path;
import 'package:http/http.dart' as http;

class AttributeApi{
  static String OPTIFOOD_DATABASE= optifoodSharedPrefrence.getString("database").toString();
  static String authorization = optifoodSharedPrefrence.getString("accessToken").toString();
  Future<void> syncAttributes() async {
    List<AttributeModel> attributeList = await AttributeDao().getUnSyncedAttributes();
    attributeList.forEach((element) {
      ServerSyncActionPending serverSyncActionPending = Utility().getServerSyncActionPending(element.syncOnServerActionPending);
      if(serverSyncActionPending.isPendingCreate){
        saveAttributeToSever(element);
      }
      else if(serverSyncActionPending.isPendingUpdate){
        saveAttributeToSever(element,isUpdate: true);
      }
    });
  }
  void saveAttributeToSever(AttributeModel attributeModel,{isUpdate = false})async{
    final dio = Dio();
    dio.options.headers['X-TenantID'] = OPTIFOOD_DATABASE;
    dio.options.headers['Authorization'] = authorization;
    var formData;
    formData = FormData.fromMap({
      'attributeCategoryId': attributeModel.catServerId,
      'name': attributeModel.name,
      'position': attributeModel.position,
      'color': attributeModel.color,
      "price":attributeModel.price,
      // 'attributePriceId': value.price,
      // 'attributePriceResponseModel': {},
      // 'description': "",
      'displayName': attributeModel.displayName,
      // 'status': "Active",
    });
    if(isUpdate){
      await dio.put(ServerData.OPTIFOOD_BASE_URL+'/api/attribute/'+attributeModel.serverId.toString(),
        data: formData,
      ).then((response) async {
        var singleData = AttributeModel.fromJsonServer(response.data);
        attributeModel.isSyncedOnServer=true;
        attributeModel.isSyncOnServerProcessing = false;
        attributeModel.syncOnServerActionPending = Utility().removeServerSyncActionPending(ConstantSyncOnServerPendingActions.ACTION_PENDING_UPDATE);
        await AttributeDao().updateAttribute(attributeModel);
        FBroadcast.instance().broadcast(
            ConstantBroadcastKeys.KEY_UPDATE_UI);
      }).catchError((onError) async {
        attributeModel.isSyncedOnServer=false;
        attributeModel.isSyncOnServerProcessing = false;
        await AttributeDao().updateAttribute(attributeModel);
        FBroadcast.instance().broadcast(
            ConstantBroadcastKeys.KEY_UPDATE_UI);
        optifoodBackgroundService.syncPendingLocalData();
      });
    }
    else{
      await dio.post(ServerData.OPTIFOOD_BASE_URL+'/api/attribute',
        data: formData,
      ).then((response) async {
        var singleData = AttributeModel.fromJsonServer(response.data);
        attributeModel.isSyncedOnServer=true;
        attributeModel.isSyncOnServerProcessing = false;
        attributeModel.serverId=singleData.serverId;
        attributeModel.syncOnServerActionPending = Utility().removeServerSyncActionPending(ConstantSyncOnServerPendingActions.ACTION_PENDING_CREATE);
        await AttributeDao().updateAttribute(attributeModel);
        FBroadcast.instance().broadcast(
            ConstantBroadcastKeys.KEY_UPDATE_UI);
      }).catchError((onError) async {
        attributeModel.isSyncedOnServer=false;
        attributeModel.isSyncOnServerProcessing = false;
        await AttributeDao().updateAttribute(attributeModel);
        FBroadcast.instance().broadcast(
            ConstantBroadcastKeys.KEY_UPDATE_UI);
        optifoodBackgroundService.syncPendingLocalData();
      });
    }
  }

  void getAttributeListFromServer({Function? callback = null}) async{
    List<AttributeModel> fetchedData = [];
    final dio = Dio();
    dio.options.headers['Authorization'] = authorization;
    dio.options.headers['X-TenantID'] = OPTIFOOD_DATABASE;
    await dio.get(ServerData.OPTIFOOD_BASE_URL+"/api/attribute").then((response) async {
      try {
        if (response.statusCode == 200) {
          saveAttributeDataFromServerToLocalDB(response.data, callback: () {
            callback!();
          });
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


  static saveAttributeDataFromServerToLocalDB(var responseData, {Function? callback = null}) async {
    List<AttributeModel> fetchedData = [];
    for (int i = 0; i < responseData.length; i++) {
      var singleItem = AttributeModel.fromJsonServer(responseData[i]);
      if(responseData[i]['deleted']) {
        print("Now check for delete food item ${responseData[i]['deleted']}");
        AttributeCategoryDao().getAttributeCategoryByServerId(singleItem.categoryID).then((value) {
          AttributeDao().getAttributeByServerId(singleItem.serverId!).then((value1) {
            AttributeDao().delete(value!, value1!);
          });
        });
      }
      else
        fetchedData.add(singleItem);
    }

    for (int i = 0; i < fetchedData.length; i++) {
      if (/*fetchedData[i].imagePath.toString() == 'null'*/true) {
        AttributeDao()
            .getAttributeByServerId(fetchedData[i].serverId!)
            .then((value) async {
          AttributeModel attributeModel = AttributeModel(
            fetchedData[i].id,
            fetchedData[i].name,
            fetchedData[i].displayName,
            fetchedData[i].price,
            categoryID: fetchedData[i].categoryID,
            catServerId: fetchedData[i].categoryID,
            color: fetchedData[i].color,
            imagePath: null,
            serverId: fetchedData[i].serverId,
            // catServerId: fetchedData[i].serverId,

          );
          if (value != null) {
            value.categoryID = fetchedData[i].categoryID;
            value.name = fetchedData[i].name;
            value.displayName = fetchedData[i].displayName;
            value.price = fetchedData[i].price;
            value.catServerId = fetchedData[i].catServerId;
            value.color = fetchedData[i].color;
            value.serverId = fetchedData[i].serverId;
            AttributeDao().updateAttribute(value).then((res1) {
              FBroadcast.instance().broadcast(
                  ConstantBroadcastKeys.KEY_UPDATE_UI);
              if (i == fetchedData.length - 1) {}
            });
          }
          else {
            AttributeCategoryModel? attributeCategoryModel = await AttributeCategoryDao().getAttributeCategoryByServerId(attributeModel.catServerId!);
            // AttributeCategoryModel attributeCategoryModel = AttributeCategoryModel(
            //     0, "", "", "", 0, "");
                if(attributeCategoryModel!=null) {
                  AttributeDao().insertAttribute(
                      attributeCategoryModel!, attributeModel).then((res2) {
                    FBroadcast.instance().broadcast(
                        ConstantBroadcastKeys.KEY_UPDATE_UI);
                    if (i == fetchedData.length - 1) {}
                  });
                }
          }
        });
      }
      else {
        var imgUrl = ServerData.OPTIFOOD_IMAGES + "/attributes/" +
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
          AttributeDao()
              .getAttributeByServerId(fetchedData[i].serverId!)
              .then((value) {
            AttributeModel attributeModel = AttributeModel(
              fetchedData[i].categoryID,
              fetchedData[i].name,
              fetchedData[i].displayName,
              fetchedData[i].price,
              categoryID: fetchedData[i].categoryID,
              catServerId: fetchedData[i].catServerId,
              color: fetchedData[i].color,
              imagePath: fetchedData[i].imagePath,
              serverId: fetchedData[i].serverId,

            );
            if (value != null) {
              value.categoryID = fetchedData[i].categoryID;
              value.name = fetchedData[i].name;
              value.displayName = fetchedData[i].displayName;
              value.price = fetchedData[i].price;
              value.categoryID = fetchedData[i].categoryID;
              value.catServerId = fetchedData[i].catServerId;
              value.color = fetchedData[i].color;
              value.serverId = fetchedData[i].serverId;
              AttributeDao().updateAttribute(value).then((res1) {
                FBroadcast.instance().broadcast(
                    ConstantBroadcastKeys.KEY_UPDATE_UI);
                if (i == fetchedData.length - 1) {}
              });
            }
            else {
              AttributeCategoryModel attributeCategoryModel = AttributeCategoryModel(
                  0, "", "", "", 0, "");
              AttributeDao().insertAttribute(
                  attributeCategoryModel, attributeModel).then((res2) {
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
   deleteAttribute(int serverId) async {
    final dio = Dio();
    dio.options.headers['X-TenantID'] = OPTIFOOD_DATABASE.toString();
    await dio.delete(ServerData.OPTIFOOD_BASE_URL+"/api/attribute/${serverId}").then((value){
    }).catchError((onError){
    });
  }
}