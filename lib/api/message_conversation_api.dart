import 'package:dio/dio.dart';
import 'package:fbroadcast/fbroadcast.dart';
import 'package:opti_food_app/api/user_api.dart';
import 'package:opti_food_app/data_models/server_sync_action_pending.dart';
import 'package:opti_food_app/utils/utility.dart';
import '../../utils/constants.dart';
import '../data_models/message_conversation_model.dart';
import '../data_models/message_model.dart';
import '../database/message_conversation_dao.dart';
import '../database/message_dao.dart';
import '../database/user_dao.dart';
import '../local_notifications.dart';
import '../main.dart';
import '../screens/authentication/noti.dart';
import '../utils/app_config.dart';
class MessageConversationApis {
  static String OPTIFOOD_DATABASE='optifood';
  static String authorization = optifoodSharedPrefrence.getString("accessToken").toString();
  Future<void> syncMessageConversations() async {
    List<MessageConversationModel> messageModelList = await MessageConversationDao().getUnSyncedMessageConversations();
    if(messageModelList.length>0){
      MessageConversationModel messasgeModel = messageModelList.first;
      ServerSyncActionPending serverSyncActionPending = Utility().getServerSyncActionPending(messasgeModel.syncOnServerActionPending);
      if(serverSyncActionPending.isPendingCreate){
        saveMessageConversationToSever(messasgeModel, oncall: (){
          syncMessageConversations();
        });
      }
      else if(serverSyncActionPending.isPendingUpdate){
        saveMessageConversationToSever(messasgeModel, oncall: (){
          syncMessageConversations();
        },isUpdate: true);
      }
    }
  }


  static deleteMessageConversation(int? id){
    final dio = Dio();
    dio.options.headers['X-TenantID'] = OPTIFOOD_DATABASE;
    dio.options.headers['Authorization'] = authorization;
    dio.delete(ServerData.OPTIFOOD_BASE_URL + '/api/message-chat/${id}',
    ).then((response) async {
    });

  }

  static saveMessageConversationToSever(MessageConversationModel messageConversationModel, {required Function oncall,isUpdate=false})async {
    final dio = Dio();
    dio.options.headers['X-TenantID'] = OPTIFOOD_DATABASE;
    dio.options.headers['Authorization'] = authorization;
    var data = {
      'message': messageConversationModel.message,
      //'userId':int.parse(optifoodSharedPrefrence.getString('id').toString())
      'userId':optifoodSharedPrefrence.getInt('id')
    };
    if (isUpdate) {
      dio.put(ServerData.OPTIFOOD_BASE_URL + '/api/message-chat/${messageConversationModel.serverId}',
        data: data,
      ).then((response) async {
        messageConversationModel.isSynced = true;
        messageConversationModel.isSyncOnServerProcessing = false;
        messageConversationModel.syncOnServerActionPending = Utility().removeServerSyncActionPending(ConstantSyncOnServerPendingActions.ACTION_PENDING_UPDATE);
        await MessageConversationDao().updateMessageConversation(messageConversationModel);

        FBroadcast.instance().broadcast(
            ConstantBroadcastKeys.KEY_UPDATE_UI);
      }).catchError((err) async {
        messageConversationModel.isSynced = false;
        messageConversationModel.isSyncOnServerProcessing = false;
        await MessageConversationDao().updateMessageConversation(messageConversationModel);
        // FBroadcast.instance().broadcast(
        //     ConstantBroadcastKeys.KEY_UPDATE_UI);
        //optifoodBackgroundService.syncPendingLocalData();
        try{
        }
        catch(error){
        }
      });
    }
    else {
      var response = await dio.post(ServerData.OPTIFOOD_BASE_URL + '/api/message-chat',
        data: data,
      ).then((response) async {
        //var mappedMessageModel = MessageConversationModel.fromJsonServer(response.data);
        messageConversationModel.isSynced = true;
        messageConversationModel.isSyncOnServerProcessing = false;
        //messageConversationModel.serverId = mappedMessageModel.serverId;
        messageConversationModel.serverId = response.data['messageChatId'];

        // if(mappedMessageModel.senderId!=0)
        //   await UserDao().getUserByServerIntId(mappedMessageModel.senderId).then((value) {
        //     messageConversationModel.senderFirstName = value!.name;
        //   });
        //
        // if(mappedMessageModel.kitchenId!=0)
        //   await UserDao().getUserByServerIntId(mappedMessageModel.kitchenId).then((value) {
        //     messageConversationModel.kitchenFirstName = value!.name;
        //   });
        messageConversationModel.syncOnServerActionPending = Utility().removeServerSyncActionPending(ConstantSyncOnServerPendingActions.ACTION_PENDING_CREATE);
        await MessageConversationDao().updateMessageConversation(messageConversationModel);

        // FBroadcast.instance().broadcast(
        //     ConstantBroadcastKeys.KEY_UPDATE_UI);
        try{
          print("hi");
        }
        catch(error){
        }
      }).catchError((err) async {
        messageConversationModel.isSynced = false;
        messageConversationModel.isSyncOnServerProcessing = false;
        await MessageConversationDao().updateMessageConversation(messageConversationModel);
        // FBroadcast.instance().broadcast(
        //     ConstantBroadcastKeys.KEY_UPDATE_UI);
        //optifoodBackgroundService.syncPendingLocalData();
      });
    }
  }

  void getMessageConversationListFromServer({Function? callback = null}) async{
    List<MessageModel> fetchedData = [];
    final dio = Dio();
    dio.options.headers['X-TenantID'] = OPTIFOOD_DATABASE;
    dio.options.headers['Authorization'] = authorization;
    await dio.get(ServerData.OPTIFOOD_BASE_URL+"/api/message-chat",queryParameters: {
      "dateTimeZone": AppConfig.dateTime.timeZoneOffset.inMinutes,

    }).then((response) async {
      List<MessageConversationModel> fetchedData = [];
      if (response.statusCode == 200) {
        for (int i = 0; i < response.data.length; i++) {
          var singleItem = MessageConversationModel.fromJsonServer(response.data[i]);
          fetchedData.add(singleItem);
          //}
        }

        for(int i=0; i<fetchedData.length; i++) {
          MessageConversationDao().getMessageConversationByServerId(
              fetchedData[i]!.serverId!).then((result) async {

            // if (fetchedData[i].senderId == int.parse(
            //     optifoodSharedPrefrence.getString('id').toString())) {
            //
            //   fetchedData[i].messageType = "sender";
            // }
            // else {
            //   fetchedData[i].messageType = "receiver";
            // }

            if (result != null) {
              result?.serverId = fetchedData[i].serverId;
              result?.message = fetchedData[i].message;
              result?.createdAt = fetchedData[i].createdAt;
              result?.messageType = fetchedData[i].messageType;
              result?.isSynced = true;
              result?.isSyncOnServerProcessing = true;
              result?.isSyncOnServerProcessing = false;
              result?.userId = fetchedData[i].userId;
              result.firstName = fetchedData[i].firstName;
              result.middleName=fetchedData[i].middleName;
              result.lastName=fetchedData[i].lastName;
              result.userType=fetchedData[i].userType;
              if (fetchedData[i].userId != 0)
                await UserDao()
                    .getUserByServerIntId(fetchedData[i].userId)
                    .then((value) {
                  result?.firstName = value!.name;
                });

              MessageConversationDao().updateMessageConversation(result!);
            }
            else {
              MessageConversationModel messageModel = MessageConversationModel(
                fetchedData[i].id,
                fetchedData[i].message,
                fetchedData[i].createdAt,
                messageType:fetchedData[i].messageType,
                serverId: fetchedData[i].serverId,
                userId: fetchedData[i].userId,
                  firstName: fetchedData[i].firstName,
                  middleName: fetchedData[i].middleName,
                lastName: fetchedData[i].lastName,
                userType: fetchedData[i].userType,

              );
              messageModel.isSynced = true;
              messageModel.serverId = fetchedData[i].serverId;
              messageModel.isSyncOnServerProcessing = false;

              if (fetchedData[i].userId != 0) {
                await UserDao()
                    .getUserByServerIntId(fetchedData[i].userId)
                    .then((value) {
                  messageModel.firstName = value!.name;
                });
              }

              messageModel.syncOnServerActionPending =
                  Utility().removeServerSyncActionPending(
                      ConstantSyncOnServerPendingActions
                          .ACTION_PENDING_UPDATE);
              MessageConversationDao()
                  .insertMessageConversation(messageModel)
                  .then((value) {

                // FBroadcast.instance().broadcast(
                //     ConstantBroadcastKeys.KEY_ORDER_SENT,
                //     value: messageModel);
              });
            }
          });
        }
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

  static saveMessageChatDataFromServerToLocalDB(var responseData, {Function? callback = null}){
    // UserApis.getUserListFromServer();
    List<MessageConversationModel> fetchedData = [];
    for (int i = 0; i < responseData.length; i++) {
      var singleItem = MessageConversationModel.fromJsonServer(responseData[i]);
      fetchedData.add(singleItem);
    }


    // MessageConversationDao().getAllMessageConversations().then((value2) async {
    //   var value=null;
    //   for(int i=0; i<fetchedData.length; i++) {
    //     if (value2.length > 0) {
    //       if (fetchedData[i].senderId != 0)
    //         await UserDao()
    //             .getUserByServerIntId(fetchedData[i].senderId)
    //             .then((value1) {
    //           value?.senderFirstName = value1!.name;
    //         });
    //
    //       if (fetchedData[i].kitchenId != 0)
    //         await UserDao()
    //             .getUserByServerIntId(fetchedData[i].kitchenId)
    //             .then((value1) {
    //           value?.kitchenFirstName = value1!.name;
    //         });
    //       MessageConversationDao()
    //           .updateMessageConversation(value)
    //           .then((res1) {
    //         // FBroadcast.instance().broadcast(
    //         //     ConstantBroadcastKeys.KEY_UPDATE_UI);
    //         if (i == fetchedData.length - 1) {
    //         }
    //       });
    //       value = value2.firstWhere((element) =>
    //       element.serverId ==
    //           fetchedData[i].serverId);
    //     }
    //
    //   }
    // });
    for (int i = 0; i < fetchedData.length; i++) {
      MessageConversationDao().getMessageConversationByServerId(fetchedData[i].serverId!).then((
          value) async {

        MessageConversationModel messageModel = MessageConversationModel(
          fetchedData[i].id,
          fetchedData[i].message,
          fetchedData[i].createdAt,
          messageType:fetchedData[i].messageType,
          serverId: fetchedData[i].serverId,
          userId: fetchedData[i].userId,

            firstName: fetchedData[i].firstName,
          middleName: fetchedData[i].middleName,
          lastName: fetchedData[i].lastName,
        );
        messageModel.isSynced = true;
        messageModel.serverId = fetchedData[i].serverId;
        messageModel.isSyncOnServerProcessing = false;

        if (value!=null) {
          value.id =  fetchedData[i].id;
          value.message = fetchedData[i].message;
          value.createdAt = fetchedData[i].createdAt;
          value.messageType = fetchedData[i].messageType;
          value.serverId = fetchedData[i].serverId;
          value.userId = fetchedData[i].userId;
          value.firstName = fetchedData[i].firstName;
        value.middleName=fetchedData[i].middleName;
          value.lastName=fetchedData[i].lastName;
          value.userType=fetchedData[i].userType;

          value.isSynced = true;
          value.isSyncOnServerProcessing = false;
          if (fetchedData[i].userId != 0)
            await UserDao()
              .getUserByServerIntId(fetchedData[i].userId)
              .then((value1) {
                if(value1!=null){
                }
            value?.firstName = value1!.name;
          });

          MessageConversationDao()
              .updateMessageConversation(value)
              .then((res1) {
            FBroadcast.instance().broadcast(
                ConstantBroadcastKeys.KEY_UPDATE_UI);
            if (i == fetchedData.length - 1) {
            }
          });
        }
        else {
          if (fetchedData[i].userId != 0)
            await UserDao()
              .getUserByServerIntId(fetchedData[i].userId)
              .then((value) {
              messageModel?.firstName = value!.name;
          });

          MessageConversationDao().insertMessageConversation(messageModel).then((
              res2) {
            print("======singleItem.userType===${res2.userType}========================");

            //if(messageModel.userId!=int.parse(optifoodSharedPrefrence.getString('id').toString()))
              //LocalNotifications.showSimpleNotification(id: messageModel.id, title: messageModel.firstName+" "+messageModel.lastName, body: messageModel.message, payload: "payload"); //commented for now
            if(messageModel!=null) {
              LocalNotifications.showSimpleNotification(id: messageModel.id,
                  title: messageModel.firstName + " " + messageModel.lastName,
                  body: messageModel.message,
                  payload: "payload"); //commented for now
              FBroadcast.instance().broadcast(
                  ConstantBroadcastKeys.KEY_UPDATE_UI);
              if (i == fetchedData.length - 1) {}
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

