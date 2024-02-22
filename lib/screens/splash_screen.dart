import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:opti_food_app/api/attribute_api.dart';
import 'package:opti_food_app/api/attribute_category_api.dart';
import 'package:opti_food_app/api/company_api.dart';
import 'package:opti_food_app/api/customer_api.dart';
import 'package:opti_food_app/api/food_category_api.dart';
import 'package:opti_food_app/api/food_item_api.dart';
import 'package:opti_food_app/api/message_conversation_api.dart';
import 'package:opti_food_app/api/night_mode_fee.dart';
import 'package:opti_food_app/api/restaurant.dart';
import 'package:opti_food_app/api/user_api.dart';
import 'package:opti_food_app/assets/images.dart';
import 'package:stomp_dart_client/stomp.dart';
import 'package:stomp_dart_client/stomp_config.dart';
import 'package:stomp_dart_client/stomp_frame.dart';

import '../api/all_data_api.dart';
import '../api/delivery_fee.dart';
import '../api/message_api.dart';
import '../api/order_apis.dart';
import '../api/reservation_api.dart';
import '../main.dart';
import 'MountedState.dart';
import 'Order/ordered_lists.dart';
class SplashScreen extends StatefulWidget{
  @override
  State<StatefulWidget> createState() => _SplashScreenState();
}
class _SplashScreenState extends MountedState<SplashScreen>{
  String caption = "Please Wait...";
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    downloadAttributeCategories();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
              child: Align(
                  alignment: Alignment.center,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Image.asset(AppImages.optifood_logo_full_grey,width: 350,height: 220,),
                      Text(caption,style: TextStyle(fontWeight: FontWeight.bold),)
                    ],
                  )
              )
          )
        ],
      ),
    );
  }
  void downloadData(){
    /*ProductApis.getFoodItemsListFromServer();
    ProductApis.getAttributeCategoryListFromServer();
    ProductApis.getFoodCategoryListFromServer();
    ProductApis.getAttributeListFromServer();
    MessageApis.getMessageListFromServer();
    UserApis.getUserListFromServer();
    OrderApis.getOrderListFromServer();*/
  }
  void downloadAttributeCategories(){
    setState(() {
      caption = "Downloading Attribute Categories...";
    });
    AttributeCategoryApi().getAttributeCategoryListFromServer(callback: (){
      downloadAttributes();
    });
  }
  downloadAttributes(){
    setState(() {
      caption = "Downloading Attributes...";
    });
    AttributeApi().getAttributeListFromServer(callback: (){
      downloadFoodCategories();
    });
  }
  void downloadFoodCategories(){
    setState(() {
      caption = "Downloading Food Categories...";
    });
    FoodCategoryApi().getFoodCategoryListFromServer(callback: (){
      downloadFoodItems();
    });
  }
  void downloadFoodItems(){
    setState(() {
      caption = "Downloading Food Items...";
    });
    FoodItemApi().getFoodItemsListFromServer(callback: (){
      downloadCompanies();
    });
  }
  void downloadCompanies(){
    setState(() {
      caption = "Downloading Companies...";
    });
    CompanyApis().getCompanyListFromServer(callback: (){
      downloadCustomers();
    });
  }
  void downloadCustomers(){
    setState(() {
      caption = "Downloading Customers...";
    });
    CustomerApis().getCustomerFromServer(callback: (){
      downloadUsers();
      // downloadMessageConversation();
    });
  }

  void downloadMessageConversation(){
    setState(() {
      caption = "Downloading Message Conversations...";
    });
    MessageConversationApis().getMessageConversationListFromServer(callback: (){
      downloadRestaurantInfo();
    });
  }
  void downloadRestaurantInfo(){
    setState(() {
      caption = "Downloading Restaurant Info...";
    });
    RestaurantApis.getRestaurantInfoFromServer(callback: (){
      // downloadMessages();
      // downloadUsers();
      downloadOrders();
    });
  }
  void downloadOrders(){
    setState(() {
      caption = "Downloading Orders...";
    });
    OrderApis().getOrderListFromServer(localCallback: (){
      downloadMessages();
    });
  }
  void downloadMessages(){
    setState(() {
      caption = "Downloading Messages...";
    });
    DeliveryFeeApi.getDeliveryFeeFromServer();
    NightModeFeeApi.getNightModeFeeFromServer();
    MessageApis().getMessageListFromServer(callback: (){
        Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => OrderedList()));
      });
  }


  void downloadUsers(){
    setState(() {
      caption = "Downloading Users...";
    });
    UserApis.getUserListFromServer(callback: ()
    {
      downloadReservations();
    });
  }



  void downloadReservations(){
    setState(() {
      caption = "Downloading Reservation...";
    });
    ReservationApis.getReservationFromServer(callback: ()
    {
      downloadMessageConversation();
    });
  }

  void onConnect(StompClient client, StompFrame frame) {
    client.subscribe(
        destination: '/topic/order',
        callback: (StompFrame frame) {
          if (frame.body != null) {
          }
        });
  }
}