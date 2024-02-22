import 'dart:async';
import 'dart:io';
import 'package:opti_food_app/api/attribute_api.dart';
import 'package:opti_food_app/api/attribute_category_api.dart';
import 'package:opti_food_app/api/food_category_api.dart';
import 'package:opti_food_app/api/order_apis.dart';
import 'package:stomp_dart_client/stomp.dart';
import 'package:stomp_dart_client/stomp_config.dart';
import 'package:stomp_dart_client/stomp_frame.dart';
import '../api/all_data_api.dart';
import '../api/food_item_api.dart';
import '../main.dart';
class OptifoodBackgroundService{
  bool isSyncing = false;
  void syncPendingLocalData({bool isByRecurrsion = false}) async {
    if(!isByRecurrsion) {
      if (isSyncing) {
        return;
      }
      else {
        isSyncing = true;
      }
    }
    if(await isInternetConnected()){
      await AttributeCategoryApi().syncAttributeCategories();
      await AttributeApi().syncAttributes();
      await FoodCategoryApi().syncFoodCategories();
      await FoodItemApi().syncFoodItems();
      await OrderApis().syncOrders();
      isSyncing = false;
    }
    else{
      await Future.delayed(Duration(seconds: 10));
      syncPendingLocalData(isByRecurrsion:true);
      // if (stompClient == null) {
      //   stompClient = StompClient(
      //       config: StompConfig.SockJS(
      //           url: socketUrl,
      //           onConnect: onConnect,
      //           onWebSocketError: (dynamic error) => print(error)
      //       ));
      //   stompClient!.activate();
      // }
    }
  }

  void onConnect(StompClient client, StompFrame frame) {
    client.subscribe(
        destination: '/topic/order',
        callback: (StompFrame frame) {
          if (frame.body != null) {
            print("Push notification called on order background service");
            //AllDataApis.getAllDataFromServer();
          }
        });
  }

  Future<bool> isInternetConnected() async {
    bool isInternetConnect = false;
    try {
      final result = await InternetAddress.lookup('google.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        isInternetConnect = true;
      }
    } on SocketException catch (_) {
      isInternetConnect = false;
    }
    return isInternetConnect;
  }
}