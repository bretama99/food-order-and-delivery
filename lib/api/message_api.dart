import 'package:dio/dio.dart';
import 'package:fbroadcast/fbroadcast.dart';
import 'package:opti_food_app/data_models/server_sync_action_pending.dart';
import 'package:opti_food_app/utils/utility.dart';
import '../../utils/constants.dart';
import '../data_models/message_model.dart';
import '../database/message_dao.dart';
import '../main.dart';
import 'package:get_it/get_it.dart';

class MessageApis {
  static GetIt locator = GetIt.instance;

  // final GlobalKey<NavigatorState> navigatorKey = new GlobalKey<NavigatorState>();
  static String OPTIFOOD_DATABASE=optifoodSharedPrefrence.getString("database").toString();
  static String authorization = optifoodSharedPrefrence.getString("accessToken").toString();
  Future<void> syncMessages() async {
    List<MessageModel> messageModelList = await MessageDao().getUnSyncedMessages();
    if(messageModelList.length>0){
      MessageModel messasgeModel = messageModelList.first;
      ServerSyncActionPending serverSyncActionPending = Utility().getServerSyncActionPending(messasgeModel.syncOnServerActionPending);
      if(serverSyncActionPending.isPendingCreate){
        saveMessageToSever(messasgeModel, oncall: (){
          syncMessages();
        });
      }
      else if(serverSyncActionPending.isPendingUpdate){
        saveMessageToSever(messasgeModel, oncall: (){
          syncMessages();
        },isUpdate: true);
      }
    }
  }

  void getMessageListFromServer({Function? callback = null}) async{

    List<MessageModel> fetchedData = [];
    final dio = Dio();
    dio.options.headers['X-TenantID'] = OPTIFOOD_DATABASE;
    dio.options.headers['Authorization'] = authorization;
    await dio.get(ServerData.OPTIFOOD_BASE_URL+"/api/message", queryParameters: {
      "inWhichAppToDisplay":"mainApp"
    }).then((response) async {
      List<MessageModel> fetchedData = [];
      if (response.statusCode == 200) {
        for (int i = 0; i < response.data.length; i++) {
          var singleItem = MessageModel.fromJsonServer(response.data[i]);
          fetchedData.add(singleItem);
        }

        // MessageDao().getAllMessages().then((value){
        //   var result=null;
          for(int i=0; i<fetchedData.length; i++) {
            MessageDao().getMessageByServerId(fetchedData[i].serverId!).then((result){
              if (result != null) {
                result?.serverId = fetchedData[i].serverId;
                result?.messageName = fetchedData[i].messageName;
                result?.message = fetchedData[i].message;
                result?.showInKitchen = fetchedData[i].showInKitchen;
                result?.showInMainApp = fetchedData[i].showInMainApp;
                result?.isSynced = true;
                result?.isSyncOnServerProcessing = true;
                result?.isSyncOnServerProcessing = false;


                MessageDao().updateMessage(result!);
              }
              else {
                MessageModel messageModel = MessageModel(
                  fetchedData[i].id,
                  fetchedData[i].messageName,
                  fetchedData[i].message,
                  fetchedData[i].showInMainApp,
                  fetchedData[i].showInKitchen,
                  serverId: fetchedData[i].serverId,
                );
                messageModel.isSynced = true;
                messageModel.serverId = fetchedData[i].serverId;
                messageModel.isSyncOnServerProcessing = false;
                messageModel.syncOnServerActionPending = Utility().removeServerSyncActionPending(ConstantSyncOnServerPendingActions.ACTION_PENDING_UPDATE);
                MessageDao().insertMessage(messageModel);
                // FBroadcast.instance().broadcast(
                //     ConstantBroadcastKeys.KEY_ORDER_SENT, value: messageModel);
              }
            });
            // if (value.length > 0)
            //   result = value.firstWhere((element) => element.serverId ==
            //       fetchedData[i].serverId);

          }
        // });

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

  static saveMessageToSever(MessageModel messageModel, {required Function oncall, isUpdate=false})async {
    final dio = Dio();
    dio.options.headers['X-TenantID'] = OPTIFOOD_DATABASE;
    dio.options.headers['Authorization'] = authorization;
    var data = {
      'messageName': messageModel.messageName,
      'message': messageModel.message,
      'showInMainApp': messageModel.showInMainApp,
      'showInKitchen': messageModel.showInKitchen,
    };
    if (isUpdate) {
      dio.put(ServerData.OPTIFOOD_BASE_URL + '/api/message/${messageModel.serverId}',
        data: data,
      ).then((response) async {
        messageModel.isSynced = true;
        messageModel.isSyncOnServerProcessing = false;
        messageModel.syncOnServerActionPending = Utility().removeServerSyncActionPending(ConstantSyncOnServerPendingActions.ACTION_PENDING_UPDATE);
        await MessageDao().updateMessage(messageModel);
        FBroadcast.instance().broadcast(
            ConstantBroadcastKeys.KEY_UPDATE_UI);
      }).catchError((err) async {
        messageModel.isSynced = false;
        messageModel.isSyncOnServerProcessing = false;
        await MessageDao().updateMessage(messageModel);
        FBroadcast.instance().broadcast(
            ConstantBroadcastKeys.KEY_ORDER_SENT);
        optifoodBackgroundService.syncPendingLocalData();

      });
    }

    else {
      var response = await dio.post(ServerData.OPTIFOOD_BASE_URL + '/api/message',
        data: data,
      ).then((response) async {
        var mappedMessageModel = MessageModel.fromJsonServer(response.data);
        messageModel.isSynced = true;
        messageModel.isSyncOnServerProcessing = false;
        messageModel.serverId = mappedMessageModel.serverId;

        print("==========messageModel.serverId iddddddddentify====================${messageModel.serverId}==============================");
        messageModel.syncOnServerActionPending = Utility().removeServerSyncActionPending(ConstantSyncOnServerPendingActions.ACTION_PENDING_CREATE);
        await MessageDao().updateMessage(messageModel);
        // FBroadcast.instance().broadcast(
        //     ConstantBroadcastKeys.KEY_ORDER_SENT);
      }).catchError((err) async {
        messageModel.isSynced = false;
        messageModel.isSyncOnServerProcessing = false;
        await MessageDao().updateMessage(messageModel);
        // FBroadcast.instance().broadcast(
        //     ConstantBroadcastKeys.KEY_ORDER_SENT);
        optifoodBackgroundService.syncPendingLocalData();
      });
    }
  }

  static deleteMessage(int? id){
    final dio = Dio();
    dio.options.headers['X-TenantID'] = OPTIFOOD_DATABASE;
    dio.options.headers['Authorization'] = authorization;
    dio.delete(ServerData.OPTIFOOD_BASE_URL + '/api/message/${id}',
    ).then((response) async {

    });

  }


  void redirectToMessage(int messageId) async {
   // navigatorKey.currentState?.pushReplacement(MaterialPageRoute(builder: (_) => const MessageConversation()));
   // locator.registerLazySingleton(() =>  OrderArchive());
   // NavigationService().navigateToScreen(Ord());
   // NavigationService().replaceScreen(MessageConversation());
   //  var response = await dio.post(ServerData.OPTIFOOD_BASE_URL + '/api/message',
   //    data: data,
   //  )

    navigatorKey.currentState?.pushNamed('/someRoute');
   // service.routeTo('/messages', arguments: 'just a test');
   final dio = Dio();
   List<int> attachedOrders = [];
   dio.options.headers['X-TenantID'] = OPTIFOOD_DATABASE;
   dio.options.headers['Authorization'] = optifoodSharedPrefrence.getString("accessToken").toString();
   attachedOrders.add(messageId!);
      var data = {
        "userId":int.parse(optifoodSharedPrefrence.getString('id').toString()),
        "messageChatIds":attachedOrders
      };
       await dio.post(ServerData.OPTIFOOD_BASE_URL+"/api/message-chat/message-notification",
          data: data
       ).then((response) async {

     });

 }
  static saveMessageDataFromServerToLocalDB(var responseData, {Function? callback = null}){
    List<MessageModel> fetchedData = [];
    for (int i = 0; i < responseData.length; i++) {
      var singleItem = MessageModel.fromJsonServer(responseData[i]);

      fetchedData.add(singleItem);
    }


    print("=============fetchedData==mmmmmmmmmmm========${fetchedData.length}==============================================");
    for (int i = 0; i < fetchedData.length; i++) {
      MessageDao().getMessageByServerId(fetchedData[i].serverId!).then((
          value) {
        MessageModel messageModel = MessageModel(
          fetchedData[i].id,
          fetchedData[i].messageName,
          fetchedData[i].message,
          fetchedData[i].showInMainApp,
          fetchedData[i].showInKitchen,
          serverId: fetchedData[i].serverId,
        );
        messageModel.isSynced = true;
        messageModel.serverId = fetchedData[i].serverId;
        messageModel.isSyncOnServerProcessing = false;

        if (value!=null) {
          value.id = fetchedData[i].id;
          value.messageName = fetchedData[i].messageName;
        value.message=fetchedData[i].message;
        value.showInMainApp = fetchedData[i].showInMainApp;
        value.showInKitchen=fetchedData[i].showInKitchen;
        value.serverId = fetchedData[i].serverId;
          value.isSynced = true;
          value.serverId = fetchedData[i].serverId;
          value.isSyncOnServerProcessing = false;
          MessageDao()
              .updateMessage(value)
              .then((res1) {
            FBroadcast.instance().broadcast(
                ConstantBroadcastKeys.KEY_UPDATE_UI);
            if (i == fetchedData.length - 1) {
            }
          });
        }
        else {
          MessageDao().insertMessage(messageModel).then((
              res2) {
            FBroadcast.instance().broadcast(
                ConstantBroadcastKeys.KEY_UPDATE_UI);
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

