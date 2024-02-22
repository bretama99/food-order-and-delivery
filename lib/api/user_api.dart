import 'package:dio/dio.dart';
import 'package:fbroadcast/fbroadcast.dart';
import 'package:opti_food_app/data_models/server_sync_action_pending.dart';
import 'package:opti_food_app/data_models/user_model.dart';
import 'package:opti_food_app/database/user_dao.dart';
import 'package:opti_food_app/utils/utility.dart';
import '../../utils/constants.dart';
import '../data_models/message_model.dart';
import '../database/message_dao.dart';
import '../main.dart';
class UserApis {

  static String OPTIFOOD_DATABASE=optifoodSharedPrefrence.getString("database").toString();
  static String authorization = optifoodSharedPrefrence.getString("accessToken").toString();
  // Future<void> syncUsers() async {
  //   List<UserModel> userModelList = await UserDao().getUnSyncedMessages();
  //   if(messageModelList.length>0){
  //     MessageModel messasgeModel = messageModelList.first;
  //     ServerSyncActionPending serverSyncActionPending = Utility().getServerSyncActionPending(messasgeModel.syncOnServerActionPending);
  //     if(serverSyncActionPending.isPendingCreate){
  //       saveUserToSever(messasgeModel, oncall: (){
  //         syncMessages();
  //       });
  //     }
  //     else if(serverSyncActionPending.isPendingUpdate){
  //       saveUserToSever(messasgeModel, oncall: (){
  //         syncMessages();
  //       },isUpdate: true);
  //     }
  //   }
  // }

  static getUserListFromServer({Function? callback = null}) async{
    List<UserModel> fetchedData = [];
    final dio = Dio();
    dio.options.headers['X-TenantID'] = OPTIFOOD_DATABASE;
    dio.options.headers['Authorization'] = authorization;
    await dio.get(ServerData.OPTIFOOD_BASE_URL+"/api/user").then((response) async {
      List<UserModel> fetchedData = [];
      if (response.statusCode == 200) {
        for (int i = 0; i < response.data.length; i++) {
          var singleItem = UserModel.fromJsonServer(response.data[i]);
          fetchedData.add(singleItem);
        }
      }
        // UserDao().getAllUsersWithoutRole().then((value){
        //   var result=null;
          for(int i=0; i<fetchedData.length; i++) {
            UserDao().getUserByServerIntId(fetchedData[i].intServerId).then((result) async {
            if (result != null) {
              result?.serverId = fetchedData[i].serverId;
              result?.name = fetchedData[i].name;
              result?.latitude = fetchedData[i].latitude;
              result?.longitude = fetchedData[i].longitude;
              result?.phoneNumber = fetchedData[i].phoneNumber;
              result?.email = fetchedData[i].email;
              result?.role = fetchedData[i].role;
              result?.isDeliveryBoyActive = fetchedData[i].isDeliveryBoyActive;
              result?.isActivated = fetchedData[i].isActivated;
              result?.isSynced = true;
              result?.intServerId = fetchedData[i].intServerId;
              // result?.isSyncOnServerProcessing = false;
              result?.isSyncOnServerProcessing = false;
              result?.isDeliveryBoyActive =fetchedData[i].isDeliveryBoyActive;
              UserDao().updateUser(result).then((value){
                FBroadcast.instance().broadcast(
                    ConstantBroadcastKeys.KEY_UPDATE_UI);
              });
            }
            else {
              UserModel userModel = UserModel(
                  fetchedData[i].id,
                  fetchedData[i].name,
                  fetchedData[i].phoneNumber,
                  fetchedData[i].email,
                  fetchedData[i].password,
                  fetchedData[i].role,
                  fetchedData[i].isDeliveryBoyActive,
                  isActivated: fetchedData[i].isActivated,
                  imagePath: fetchedData[i].imagePath,
                  latitude: fetchedData[i].latitude,
                  longitude: fetchedData[i].longitude,
                  isSynced: true,
                  isSyncOnServerProcessing: false,
                  syncOnServerActionPending: "pending",
                  serverId: fetchedData[i].serverId,
                  intServerId: fetchedData[i].intServerId
              );
              userModel.isSynced = true;
              userModel.serverId = fetchedData[i].serverId;
              userModel.intServerId = fetchedData[i].intServerId;
              userModel.latitude = fetchedData[i].latitude;
              userModel.longitude = fetchedData[i].longitude;
              userModel.isSyncOnServerProcessing = false;
              userModel.syncOnServerActionPending = Utility().removeServerSyncActionPending(ConstantSyncOnServerPendingActions.ACTION_PENDING_UPDATE);

              UserDao().getUserByServerId(fetchedData[i].serverId).then((value){
                if(value!=null){
                  UserDao().updateUser(userModel).then((value11){
                    UserDao().getUserByServerId(fetchedData[i].serverId).then((value){
                      value!.isDeliveryBoyActive = userModel.isDeliveryBoyActive;
                      UserDao().updateUser(value).then((value11) {

                      });
                    });

                  });
                }
                else{
                  UserDao().insertUser(userModel).then((value){
                  });
                }
              });
            }
          // }
        });

      }
      if(callback!=null){
        callback();
      }
    }).onError((error, stackTrace){
        if(callback!=null){
          callback();
        }
    });
  }

  static saveUserToSever(UserModel userModel, {isUpdate=false})async {
    final dio = Dio();
    dio.options.headers['X-TenantID'] = OPTIFOOD_DATABASE;
    dio.options.headers['Authorization'] = authorization;
    var data = {
      'firstName': userModel.name.split(" ")[0],
      'middleName': userModel.name.split(" ").length>1?userModel.name.split(" ")[1]:"",
      'lastName': userModel.name.split(" ").length>2?userModel.name.split(" ")[2]:"",
      'mobilePhone': userModel.phoneNumber,
      'email': userModel.email,
      'password': userModel.password,
      'userType': userModel.role,
      //'userStatus': userModel.isActivated,
      'userStatus': userModel.isActivated?"Active":"Disabled",
      'restaurantId': 1,

    };

    if (isUpdate) {
      dio.put(ServerData.OPTIFOOD_BASE_URL + '/api/user/${userModel.serverId}',
        data: data,
      ).then((response) async {
        userModel.isSynced = true;
        userModel.isSyncOnServerProcessing = false;
        userModel.syncOnServerActionPending = Utility().removeServerSyncActionPending(ConstantSyncOnServerPendingActions.ACTION_PENDING_UPDATE);
        await UserDao().updateUser(userModel);
        try{
        }
        catch(error){
        }
        FBroadcast.instance().broadcast(
            ConstantBroadcastKeys.KEY_ORDER_SENT, value: userModel);
      }).catchError((err) async {
        userModel.isSynced = false;
        userModel.isSyncOnServerProcessing = false;
        await UserDao().updateUser(userModel);
        FBroadcast.instance().broadcast(
            ConstantBroadcastKeys.KEY_ORDER_SENT, value: userModel);
        optifoodBackgroundService.syncPendingLocalData();
        try{
        }
        catch(error){
        }
      });
    }
    else {
      var response = dio.post(ServerData.OPTIFOOD_BASE_URL + '/api/user',
        data: data,
      );
      response.then((response) async {
        var mappedModel = UserModel.fromJsonServer(response.data);
        userModel.isSynced = true;
        userModel.isSyncOnServerProcessing = false;
        userModel.serverId = mappedModel.serverId;
        userModel.syncOnServerActionPending = Utility().removeServerSyncActionPending(ConstantSyncOnServerPendingActions.ACTION_PENDING_CREATE);
        await UserDao().updateUser(userModel).then((value) {
        });
        FBroadcast.instance().broadcast(
            ConstantBroadcastKeys.KEY_ORDER_SENT, value: userModel);
        try{
        }
        catch(error){
        }
      }).catchError((err) async {
        userModel.isSynced = false;
        userModel.isSyncOnServerProcessing = false;
        await UserDao().updateUser(userModel);
        try{
        }
        catch(error){
        }
        FBroadcast.instance().broadcast(
            ConstantBroadcastKeys.KEY_ORDER_SENT, value: userModel);
        optifoodBackgroundService.syncPendingLocalData();
      });
    }
  }

  static deleteUser(int? id){
    final dio = Dio();
    dio.options.headers['X-TenantID'] = OPTIFOOD_DATABASE;
    dio.options.headers['Authorization'] = authorization;
    dio.delete(ServerData.OPTIFOOD_BASE_URL + '/api/user/${id}',
    ).then((response) async {

    });

  }

  static saveUserDataFromServerToLocalDB(var responseData, {Function? callback = null}) async {
    List<UserModel> fetchedData = [];

    try {
      if(responseData!=null) {
        for (int i = 0; i < responseData.length; i++) {
          var singleItem = UserModel.fromJsonServer(responseData[i]);
            fetchedData.add(singleItem);
        }
      }
    }
    catch(onError,stacktrace){
      print(stacktrace);
    }

    for (int i = 0; i < fetchedData.length; i++) {
      UserDao().getUserByServerIntId(fetchedData[i].intServerId!).then((
            value) {
        UserModel userModel = UserModel(
            fetchedData[i].id,
            fetchedData[i].name,
            fetchedData[i].phoneNumber,
            fetchedData[i].email,
            fetchedData[i].password,
            fetchedData[i].role,
            fetchedData[i].isDeliveryBoyActive,
            isActivated: fetchedData[i].isActivated,
            imagePath: fetchedData[i].imagePath,
            latitude: fetchedData[i].latitude,
            longitude: fetchedData[i].longitude,
            isSynced: true,
            isSyncOnServerProcessing: false,
            syncOnServerActionPending: "pending",
            serverId: fetchedData[i].serverId,
            intServerId: fetchedData[i].intServerId
        );
        if (value!=null) {
            value.name=fetchedData[i].name;
            value.serverId=fetchedData[i].serverId;
            value.intServerId=fetchedData[i].intServerId;
            value.phoneNumber = fetchedData[i].phoneNumber;
            value.email = fetchedData[i].email;
            value.role=fetchedData[i].role;
            value.latitude = fetchedData[i].latitude;
            value.longitude = fetchedData[i].longitude;
            value.isActivated = fetchedData[i].isActivated;
            value.isSynced = true;
            UserDao().updateUser(value).then((res1) {
              FBroadcast.instance().broadcast(ConstantBroadcastKeys.KEY_UPDATE_UI);
              if (i == fetchedData.length - 1) {
              }
            });
          }
          else {
            UserDao().insertUser(userModel).then((
                res2) {
              FBroadcast.instance().broadcast(ConstantBroadcastKeys.KEY_UPDATE_UI);

              if (i == fetchedData.length - 1) {
              }
            });
          }
        });
      }
    if(callback!=null){
      callback();
    }

  }
}

