import 'dart:ffi';
import 'package:dio/dio.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:fbroadcast/fbroadcast.dart';
import 'package:flutter/material.dart';
import 'package:opti_food_app/api/attribute_category_api.dart';
import 'package:opti_food_app/api/company_api.dart';
import 'package:opti_food_app/api/message_api.dart';
import 'package:opti_food_app/api/message_conversation_api.dart';
import 'package:opti_food_app/api/reservation_api.dart';
import 'package:opti_food_app/api/user_api.dart';
import 'package:opti_food_app/database/order_dao.dart';
import 'package:opti_food_app/utils/utility.dart';
import '../data_models/message_conversation_model.dart';
import '../data_models/restaurant_info_model.dart';
import '../database/restaurant_info_dao.dart';
import '../local_notifications.dart';
import '../main.dart';
import '../screens/authentication/noti.dart';
import '../utils/app_config.dart';
import '../utils/constants.dart';
import 'attribute_api.dart';
import 'customer_api.dart';
import 'food_category_api.dart';
import 'food_item_api.dart';
import 'order_apis.dart';
class AllDataApis {
    Function? callBack;
    AllDataApis({this.callBack});

    static getMessages(String timeStamp) async {

        String OPTIFOOD_DATABASE=optifoodSharedPrefrence.getString("database").toString();
        final dio = Dio();

        dio.options.headers['X-TenantID'] = OPTIFOOD_DATABASE;
        dio.options.headers['Authorization'] = optifoodSharedPrefrence.getString("accessToken").toString();
        RestaurantInfoModel restaurantInfoModel = await RestaurantInfoDao().getRestaurantInfo();
        String startTime = restaurantInfoModel.startTime;
        if(startTime==null){
            startTime = "09:00:00";
        }
        DateFormat formatter = DateFormat('yyyy-MM-dd HH:mm:ss');
        String dateString = formatter.format(new DateTime.fromMillisecondsSinceEpoch(int.parse(timeStamp)));

           var messageIds = [];
        await dio.get(ServerData.OPTIFOOD_BASE_URL+"/api/message-chat/notification-messages",queryParameters: {
            "dateTimeZone": AppConfig.dateTime.timeZoneOffset.inMinutes,
            "userId":int.parse(optifoodSharedPrefrence.getString('id').toString())
        }).then((response) async {
            List<MessageConversationModel> fetchedData = [];
            if (response.statusCode == 200) {
                for (int i = 0; i < response.data.length; i++) {
                    var singleItem = MessageConversationModel.fromJsonServer(response.data[i]);
                    if(singleItem.userId!=int.parse(optifoodSharedPrefrence.getString('id').toString())) {
                        fetchedData.add(singleItem);
                    }
                    //}
                }
                for(int i=0;i<fetchedData.length;i++){
                    //LocalNotifications.showSimpleNotification(id: fetchedData[i].id, title: fetchedData[i].firstName+" "+fetchedData[i].lastName, body: fetchedData[i].message, payload: "payload"); //commented for now
                    }
                // optifoodSharedPrefrence.setStringList('messageIds', messageIds);
                // fetchedData.add(singleItem);
            }
        });
    }

    static getAllDataFromServer(String timeStamp,String newTimeStamp) async {
        print(optifoodSharedPrefrence.getString("accessToken").toString());
        String OPTIFOOD_DATABASE=optifoodSharedPrefrence.getString("database").toString();
    final dio = Dio();
    // dio.options.headers['X-TenantID'] = OPTIFOOD_DATABASE;
    RestaurantInfoModel restaurantInfoModel = await RestaurantInfoDao().getRestaurantInfo();
    String startTime = restaurantInfoModel.startTime;
    if(startTime==null){
      startTime = "09:00:00";
    }
        dio.options.headers['Authorization'] = optifoodSharedPrefrence.getString("accessToken").toString();
        dio.options.headers['X-TenantID'] = OPTIFOOD_DATABASE;
    DateFormat formatter = DateFormat('yyyy-MM-dd HH:mm:ss');
    //String dateString = formatter.format(new DateTime.fromMillisecondsSinceEpoch(int.parse(timeStamp)).toUtc());
    String dateString = formatter.format(new DateTime.fromMillisecondsSinceEpoch(int.parse(timeStamp)).subtract(Duration(minutes: 30)).toUtc());

    print("===========dateStringdateStringdateStringdateString=====${dateString}===================");
    print(optifoodSharedPrefrence.getString("accessToken").toString());
     await dio.get(ServerData.OPTIFOOD_BASE_URL+"/api/all-data",queryParameters: {
          //"fromDateTime": DateTime.now().toString().split(" ")[0]+" 00:00:00",
          "fromDateTime": dateString,
          "dateTimeZone": AppConfig.dateTime.timeZoneOffset.inMinutes,
          "inWhichAppToDisplay": "mainApp"
         }).then((response) async {
             String openingDateTime = response.data["openingDateTime"];
             if(optifoodSharedPrefrence.getString(ConstantSharedPreferenceKeys.KEY_CURRENT_SHIFT_OPENING_DATE_TIME)==null){
                 optifoodSharedPrefrence.setString(ConstantSharedPreferenceKeys.KEY_CURRENT_SHIFT_OPENING_DATE_TIME, openingDateTime);
             }
             else{
                 DateFormat dateFormat = DateFormat("yyyy-MM-dd HH:mm:ss");
                 if(dateFormat.parse(optifoodSharedPrefrence.getString(ConstantSharedPreferenceKeys.KEY_CURRENT_SHIFT_OPENING_DATE_TIME)!).isBefore(dateFormat.parse(openingDateTime))){
                    await OrderDao().removeAllOrders();
                    optifoodSharedPrefrence.setString(ConstantSharedPreferenceKeys.KEY_CURRENT_SHIFT_OPENING_DATE_TIME, openingDateTime);
                    Utility().showToastMessage("Shift changed, All order moved to archive!");
                    FBroadcast.instance().broadcast(
                        ConstantBroadcastKeys.KEY_ORDER_SENT);
                 }
             }
             //Utility().checkVersionUpdate(navigatorKey.currentContext!);
         OrderApis.saveOrderDataFromServerToLocalDB(response.data['orderResponseModels'], localCallback: (){}, push: true);
         FoodCategoryApi.saveFoodCategoryItemDataFromServerToLocalDB(response.data['itemCategoryResponseModels'], callback: (){});
         FoodItemApi.saveFoodItemsDataFromServerToLocalDB(response.data['itemResponseModels'], callback: (){});
         CustomerApis.saveCustomerDataFromServerToLocalDB(response.data['customerResponseModels'], callback: (){});
         CompanyApis().saveCompanyDataFromServerToLocalDB(response.data['companyResponseModels'], callback: (){});
         AttributeApi.saveAttributeDataFromServerToLocalDB(response.data['attributeResponseModels'], callback: (){});
         AttributeCategoryApi.saveAttributCategoryDataFromServerToLocalDB(response.data['attributeCategoryResponseModels'], callback: (){});
         MessageApis.saveMessageDataFromServerToLocalDB(response.data['messageResponseModels'], callback: (){});
         MessageConversationApis.saveMessageChatDataFromServerToLocalDB(response.data['messageChatResponseModels'], callback: (){});
         UserApis.saveUserDataFromServerToLocalDB(response.data['userResponseModels'], callback: (){});

             ReservationApis.saveReservationDataFromServerToLocalDB(response.data['reservationResponseModels'], callback: (){});

         optifoodSharedPrefrence.setString(ConstantSharedPreferenceKeys.KEY_FIREBASE_TIMESTAMP, newTimeStamp);

         }).onError((error, stackTrace){
            print("error");
     });
    }
}