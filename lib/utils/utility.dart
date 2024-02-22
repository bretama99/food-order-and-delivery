import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:opti_food_app/data_models/attribute_model.dart';
import 'package:opti_food_app/data_models/food_items_model.dart';
import 'package:opti_food_app/data_models/restaurant_info_model.dart';
import 'package:opti_food_app/data_models/server_sync_action_pending.dart';
import 'package:opti_food_app/database/restaurant_info_dao.dart';
import 'package:opti_food_app/utils/preference_utils.dart';
import 'package:opti_food_app/utils/constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../assets/images.dart';
import '../data_models/order_model.dart';
import '../main.dart';
import '../widgets/app_theme.dart';
import '../widgets/popup/confirmation_popup/confirmation_popup.dart';

class Utility {
  double calculateItemPrice(
      String orderType, String orderService, FoodItemsModel foodItemsModel) {
    double price = foodItemsModel.price;
    if (foodItemsModel.isEnablePricePerOrderType!=null && foodItemsModel.isEnablePricePerOrderType) {
      if (orderType == ConstantOrderType.ORDER_TYPE_RESTAURANT) {
        if (orderService ==
            ConstantRestaurantOrderType.RESTAURANT_ORDER_TYPE_EAT_IN) {
          price = foodItemsModel.eatInPrice;
        } else {
          price = foodItemsModel.price;
        }
      } else if (orderType == ConstantOrderType.ORDER_TYPE_DELIVERY) {
        price = foodItemsModel.deliveryPrice;
      }
    }
    int discountPercentage = foodItemsModel.discountPercentage;
    int quantity = foodItemsModel.quantity;
    List<AttributeModel> attributeList = foodItemsModel.selectedAttributes;
    attributeList.forEach((attribute) {
      print(attribute.toJson());
      if (attribute.price > 0) {
        price = price + (attribute.price * attribute.quantity);
      }
    });
    return (price - (price * discountPercentage / 100)) * quantity;
  }
  //Future<String> formatPrice(double price,SharedPreferences sharedPreferences) async {
  String formatPrice(double price) {
    String currency = optifoodSharedPrefrence.getString(ConstantSharedPreferenceKeys.KEY_SELECTED_CURRENCY)!=null?optifoodSharedPrefrence.getString(ConstantSharedPreferenceKeys.KEY_SELECTED_CURRENCY)!:ConstantCurrencySymbol.EURO.toString();
    String decimalSeparator = optifoodSharedPrefrence.getString(ConstantSharedPreferenceKeys.KEY_SELECTED_CURRENCY)!=null?optifoodSharedPrefrence.getString(ConstantSharedPreferenceKeys.KEY_SELECTED_DECIMAL_SEPARATOR)!:",";
    var formatter = NumberFormat('#,##,###.00');
    String formattedPrice = price.toStringAsFixed(2);
    if(optifoodSharedPrefrence.getString(ConstantSharedPreferenceKeys.KEY_SELECTED_THOUSAND_SEPARATOR)!=null&&optifoodSharedPrefrence.getString(ConstantSharedPreferenceKeys.KEY_SELECTED_THOUSAND_SEPARATOR)==","){
      formattedPrice = formatter.format(price);
    }
    if(optifoodSharedPrefrence.getString(ConstantSharedPreferenceKeys.KEY_SELECTED_SYMBOL_LEFT_RIGHT).toString()=="Left"){
      return (currency + formattedPrice.replaceAll('.', decimalSeparator)).toString();
    }
    else{
      return (formattedPrice.replaceAll('.', decimalSeparator)+currency).toString();
    }
  }

  OrderModel getOrderFromListByID(List<OrderModel> orderList, int id) {
    return orderList.where((element) => element.id == id|| element.serverId == id).first;
  }

  /*List<OrderModel> getAttachedSortedOrderList(List<OrderModel> orderList,int orderNumber,String orderType,
      List<OrderModel> restaurantOrders, List<OrderModel> deliveryOrders) {
      List<OrderModel> sortedList = [];
      List<OrderModel> mainOrderList = [];
      mainOrderList = orderList.where((element) => element.attachedBy == 0).toList(growable: true);
      mainOrderList.forEach((order) {
        sortedList.add(order);
        sortedList.addAll(orderList.where((element) => element.attachedBy == order.id));
      });
      if(orderType=='delivery') {
        for(int i=0;i<deliveryOrders.length;i++){
          var checkIfOrderExist = sortedList.where((element) => element.id==deliveryOrders[i].id);
          if(checkIfOrderExist.length<1 && deliveryOrders[i].orderType=='delivery' && !deliveryOrders[i].isDeleted) {
            sortedList.add(deliveryOrders[i]);
          }

          if(deliveryOrders[i].isDeleted){
            for(int j=0; j<sortedList.length; j++){
              if(sortedList[j].serverId==deliveryOrders[i].serverId)
                sortedList.removeAt(j);
            }
          }

        }
        sortedList.sort((a, b) => a.deliveryInfoModel!.deliveryTime.compareTo(b.deliveryInfoModel!.deliveryTime));
      }

      if(orderType=='restaurant') {
        for(int i=0;i<restaurantOrders.length;i++){
          var checkIfOrderExist = sortedList.where((element) => element.id==restaurantOrders[i].id);
          if(checkIfOrderExist.length<1 && orderType==restaurantOrders[i].orderType && !restaurantOrders[i].isDeleted) {
            sortedList.add(restaurantOrders[i]);
          }
          if(restaurantOrders[i].isDeleted){
            for(int j=0; j<sortedList.length; j++){
              if(sortedList[j].serverId==restaurantOrders[i].serverId)
                sortedList.removeAt(j);
            }
          }
        }
        sortedList.sort((a, b) => b.orderNumber.compareTo(a.orderNumber));
      }
      for(int i=0; i<sortedList.length; i++){
        var check = sortedList.where((element) => element.serverId==sortedList[i].serverId && sortedList[i].serverId!=0);
        if(check.length>1) {
          sortedList.removeAt(i);
        }
        if(sortedList[i].isDeleted)
          sortedList.removeAt(i);
      }
    return sortedList;
  }*/

  List<OrderModel> getAttachedSortedOrderList(List<OrderModel> orderList,int orderNumber,String orderType) {
    List<OrderModel> sortedList = [];
    List<OrderModel> mainOrderList = [];
    mainOrderList = orderList
        .where((element) => element.attachedBy == 0)
        .toList(growable: true);
    mainOrderList.forEach((order) {
      sortedList.add(order);

      if(order.serverId!=0) {
        sortedList.addAll(orderList.where((element) => element.attachedBy == order.serverId));
      }
    });
    if(orderType=='delivery') {
      orderList=orderList.where((element) => element.orderType=='delivery').toList();
      for(int i=0; i<orderList.length; i++) {
        if (orderList[i].deliveryInfoModel!.deliveryTime
            .split(":")
            .length == 2) {
          if(orderList[i].deliveryInfoModel!.deliveryTime.split(":")[0].length == 1)
            orderList[i].deliveryInfoModel!.deliveryTime ="0"+orderList[i].deliveryInfoModel!.deliveryTime+":00";
          else
            orderList[i].deliveryInfoModel!.deliveryTime =orderList[i].deliveryInfoModel!.deliveryTime+":00";
        }
      }
      sortedList.sort((a, b) =>
          a.deliveryInfoModel!.deliveryTime.compareTo(
              b.deliveryInfoModel!.deliveryTime));
    }

     /*if(orderType=='restaurant')
       sortedList.sort((a, b) =>
           b.orderNumber.compareTo(
               a.orderNumber));*/


     sortedList.forEach((element) {
       if(element.serverId==null||element.serverId==0){
         sortedList.remove(element);
         sortedList.insert(0, element);
       }
     });


    return sortedList;
  }

  Future<void> printTicket(OrderModel orderModel,[bool isReprint = false]) async {
    String orderType = orderModel.orderType;
    if(!isReprint) {
      if (orderType == ConstantOrderType.ORDER_TYPE_DELIVERY) {
        if (optifoodSharedPrefrence.getBool(
            ConstantSharedPreferenceKeys.KEY_PRINTER_ACTIVATED_FOR_DELIVERY) ==
            false) {
          return;
        }
      }
      else {
        if (orderModel.orderService ==
            ConstantRestaurantOrderType.RESTAURANT_ORDER_TYPE_EAT_IN) {
          if (optifoodSharedPrefrence.getBool(
              ConstantSharedPreferenceKeys.KEY_PRINTER_ACTIVATED_FOR_EAT_IN) ==
              false) {
            return;
          }
        }
        else if (orderModel.orderService ==
            ConstantRestaurantOrderType.RESTAURANT_ORDER_TYPE_TAKEAWAY) {
          if (optifoodSharedPrefrence.getBool(ConstantSharedPreferenceKeys
              .KEY_PRINTER_ACTIVATED_FOR_TAKE_AWAY) == false) {
            return;
          }
        }
      }
    }
    RestaurantInfoModel restaurantInfoModel = await RestaurantInfoDao().getRestaurantInfo();
    List<String> headingList = [];
    List<String> addressList = [];
    List<String> foodItemList = [];
    List<String> footerList = [];

    //headingList.add("DATE : " + orderObject.getString("delivery_date"));
    headingList.add("DATE : " + orderModel.deliveryInfoModel!.deliveryDate);
    headingList.add("HEURE : " + orderModel.deliveryInfoModel!.deliveryTime);
    headingList.add(" ");
    if(orderType == ConstantOrderType.ORDER_TYPE_RESTAURANT){
      addressList.add("BON DE COMMANDE");
      if(orderModel.customer!=null){
        headingList.add("NOM : "+orderModel.customer!.firstName + " " + orderModel.customer!.lastName);
        headingList.add("TELEPHONE : " + orderModel.customer!.phoneNumber);
      }
    }
    else{
      /*addressList.add(restaurantObject.getString("name"));
      addressList.add(restaurantObject.getString("address"));
      addressList.add(restaurantObject.getString("pincode") + " " + restaurantObject.getString("city"));
      addressList.add("TEL : " + restaurantObject.getString("phone"));
      addressList.add(" ");
      addressList.add(" ");
      addressList.add("BON DE LIVRAISON");*/
      addressList.add(restaurantInfoModel.name);
      addressList.add(restaurantInfoModel.address);
      //addressList.add(restaurantInfoModel. + " " + restaurantObject.getString("city"));
      addressList.add("TEL : " + restaurantInfoModel.phoneNumber);
      addressList.add(" ");
      addressList.add(" ");
      addressList.add("BON DE LIVRAISON");


      /*JSONObject customerObject = mainObject.getJSONObject("customer");
      headingList.add("NOM : " + (customerObject.getString("first_name") + " " + customerObject.getString("last_name")).trim());
      headingList.add("ADRESSE : " + customerObject.getString("address"));
      headingList.add("VILLE : " + customerObject.getString("city"));
      headingList.add("PAYS : " + customerObject.getString("country"));
      headingList.add("TELEPHONE : " + customerObject.getString("phone_no"));*/

      headingList.add("NOM : " + orderModel.customer!.firstName + " " + orderModel.customer!.lastName);
      headingList.add("ADRESSE : " + orderModel.customer!.getDefaultAddress().address);
      //headingList.add("VILLE : " + orderModel.customer!.getDefaultAddress().);
      //headingList.add("PAYS : " + orderModel.customer!.getDefaultAddress());
      headingList.add("TELEPHONE : " + orderModel.customer!.phoneNumber);

      footerList.add(" ");
      footerList.add(" ");
      footerList.add("MODE DE PAIEMENT ATTENDU");
      footerList.add(orderModel.paymentMode!);
      footerList.add(" ");
      footerList.add("Ce bon n'est pas un justificatif de paiement.");
    }
    addressList.add(" ");
    addressList.add(" ");
    addressList.add("N° " + orderModel.orderNumber.toString());
    addressList.add(" ");
    addressList.add(" ");
    if(orderType == ConstantOrderType.ORDER_TYPE_RESTAURANT){
      //headingList.add("TYPE : " + orderModel.orderService==ConstantRestaurantOrderType.RESTAURANT_ORDER_TYPE_EAT_IN?"Sur place":"À emporter");
      headingList.add("TYPE : " + "A emporter");
    }
    /*if (orderObject.getString("restaurant_order_type").equalsIgnoreCase("Sur Place")) {
      if(orderObject.getString("table_no").equalsIgnoreCase("0")==false) {
        headingList.add("TABLE No : " + orderObject.getString("table_no"));
      }
    }*/
    if(orderModel.orderType == ConstantOrderType.ORDER_TYPE_RESTAURANT && orderModel.orderService == ConstantRestaurantOrderType.RESTAURANT_ORDER_TYPE_EAT_IN){
      if(orderModel.tableNumber!="0"&&orderModel.tableNumber.trim()!=""){
        headingList.add("N° de Table : "+orderModel.tableNumber);
      }
    }
    /*if(orderObject.getString("order_source").equalsIgnoreCase("optifood"))
    {
      String managerName = "Manager";
      if(orderObject.getString("manager_name")!=null) {
        managerName = orderObject.getString("manager_name");
      }
      //headingList.add("Prise de Commande : " + orderObject.getJSONObject("manager").getString("name"));
      headingList.add("PRISE DE COMMANDE : "+managerName);
    }
    else if(orderObject.getString("order_source").equalsIgnoreCase("justeat"))
    {
      headingList.add("PRISE DE COMMANDE : Just Eat");
    }
    else if(orderObject.getString("order_source").equalsIgnoreCase("ubereats"))
    {
      headingList.add("PRISE DE COMMANDE : Uber Eats");
    }
    else if(orderObject.getString("order_source").equalsIgnoreCase("woocommerce"))
    {
      headingList.add("PRISE DE COMMANDE : Commande en ligne");
    }*/
    //headingList.add("PRISE DE COMMANDE : "+"XXXXX XXXXX");
    headingList.add("PRISE DE COMMANDE : "+orderModel.manager.name);
    headingList.add("COMMENTAIRE : " + orderModel.comment);

    orderModel.foodItems.forEach((foodItem) {
      String foodItemString = "";
      foodItemString = foodItem.quantity.toString() + " * " + foodItem.name.toUpperCase();
      if(foodItem.discountPercentage>0){
        foodItemString = foodItemString + "(Offert " + foodItem.discountPercentage.toString() + "%)";
      }
      foodItemString = foodItemString + " : " + Utility().formatPrice(foodItem.price * foodItem.quantity).toString();
      /*if(foodItem.selectedAttributes.isNotEmpty){
        String attributeString = "";
        foodItem.selectedAttributes.forEach((attribute) {
          attributeString = attributeString + attribute.name + ",";
        });
        foodItemString = foodItemString + "(" + attributeString + ")";
      }*/
      foodItemList.add(foodItemString);
      if(foodItem.selectedAttributes.isNotEmpty){
        foodItem.selectedAttributes.forEach((element) {
          if(element.quantity>1) {
            foodItemList.add(
                "    " + element.quantity.toString() + " * " + element.name +
                    " : ");
          }
          else{
            foodItemList.add("    "+ element.name+" : ");
          }
        });
      }
      foodItemList.add(" ");
    });
    //String totalPrice = "TOTAL : " + orderModel.totalPrice.toString();
    String totalPrice = "TOTAL : " + Utility().formatPrice(orderModel.totalPrice).toString();
    String nightCharges = "NIGHT CHARGES : XX.XX";
    String deliveryCharges = "DELIVERY CHARGES : XX.XX";
      channelPrinting.invokeMethod('printTicket', {
        'mac': optifoodSharedPrefrence.getString(
            ConstantSharedPreferenceKeys.KEY_PRINTER_MAC_ADDRESS),
        'heading_list': headingList,
        'address_list': addressList,
        'fooditems_list': foodItemList,
        'night_fee': nightCharges,
        'delivery_fee': deliveryCharges,
        'total_price': totalPrice,
        'footer_list': footerList,
        'no_of_ticket' : optifoodSharedPrefrence.getInt(ConstantSharedPreferenceKeys.KEY_PRINTER_NUMBER_OF_TICKET)!=null?optifoodSharedPrefrence.getInt(ConstantSharedPreferenceKeys.KEY_PRINTER_NUMBER_OF_TICKET)!:1,
        'is_print_main_ticket' : optifoodSharedPrefrence.getBool(ConstantSharedPreferenceKeys.KEY_PRINTER_ACTIVATED_PRINCIPAL_TICKET)!=null?optifoodSharedPrefrence.getBool(ConstantSharedPreferenceKeys.KEY_PRINTER_ACTIVATED_PRINCIPAL_TICKET)!:false,
        'is_print_order_number_ticket' : optifoodSharedPrefrence.getBool(ConstantSharedPreferenceKeys.KEY_PRINTER_ACTIVATED_ORDER_NUMBER)!=null?optifoodSharedPrefrence.getBool(ConstantSharedPreferenceKeys.KEY_PRINTER_ACTIVATED_ORDER_NUMBER)!:false
      });
  }

  void showToastMessage(String message,{double? fontSize=16}) {
    Fluttertoast.showToast(
        msg: message,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: AppTheme.colorRed,
        textColor: Colors.white,
        fontSize: fontSize==null?16.0:fontSize
        );
  }

  String convertDateFormat(String date) {
    final DateFormat formatter = DateFormat('dd/MM/yyyy');
    final String formatted = formatter.format(DateTime.parse(date));
    return formatted;
  }
  String convertTimeFormat(String time) {
    final DateTime formatter = DateFormat.jm().parse(time);
    return DateFormat("HH:mm").format(formatter).toString();
  }
  Future<String> pickDate(BuildContext context,{String selectedDateFormat="dd/MM/yyyy"}) async {
    String formattedDate = "";
    DateTime?pickedDate=await showDatePicker(
      locale : Localizations.localeOf(context),
      context: context,
      helpText: DateFormat(selectedDateFormat).format(DateTime.now()).toString(),
      initialDate: DateTime.now(),
      firstDate: DateTime.now().subtract(Duration(days: 0)),
      lastDate: DateTime(2101),
      builder: (context, child) {
        return Padding(
          //padding: const EdgeInsets.only(top: 100,bottom: 100,left: 15,right: 15),
          padding: const EdgeInsets.only(top: 10,bottom: 10,left: 15,right: 15),
          child: Theme(
              data: Theme.of(context).copyWith(
                shadowColor: Colors.black,
                appBarTheme: const AppBarTheme(actionsIconTheme: IconThemeData(color: Colors.amber),
                    centerTitle: true,
                    elevation: 60,
                    titleTextStyle: TextStyle(color: Colors.lightBlueAccent, fontSize: 22)),
                colorScheme: const ColorScheme.light(
                  primary: AppTheme.colorRed,
                ),
                textButtonTheme: TextButtonThemeData(
                  style: TextButton.styleFrom(
                    primary: AppTheme.colorRed, // button text color
                  ),
                ),
              ),
              child: child!
          ),
        );
      },
    );
    if(pickedDate!=null){
      formattedDate = DateFormat(selectedDateFormat).format(pickedDate);
    }
    return formattedDate;
  }
  Future<String?> pickTime(BuildContext context) async {
    TimeOfDay? timeOfDay = await showTimePicker(
        helpText: "",
        hourLabelText: "",
        builder: (context, child) {
          return Theme(
            child: MediaQuery(data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
              child:  Container(
                height: 100,
                width: 320,
                child: child,
              ),),
            data: ThemeData(
              useMaterial3: false,
              textButtonTheme: TextButtonThemeData(
                style: TextButton.styleFrom(
                  primary: AppTheme.colorRed, // button text color
                ),
              ),
              colorScheme: const ColorScheme.light(
                primary: AppTheme.colorRed, // <-- SEE HERE
                background:  AppTheme.colorRed,
              ),
              timePickerTheme: TimePickerThemeData(
                dialHandColor:  AppTheme.colorRed,
              ),
            ),
          );
        },
        context: context,  initialTime: TimeOfDay.now());
    return await timeOfDay?.format(context)!;
  }



  String getCountryCode(){
    var selectedLanguage =  optifoodSharedPrefrence.getString(ConstantSharedPreferenceKeys.KEY_SELECTED_LANGUAGE)!=null?optifoodSharedPrefrence.getString(ConstantSharedPreferenceKeys.KEY_SELECTED_LANGUAGE)!:ConstantSharedPreferenceKeys.KEY_SELECTED_LANGUAGE;
    if(selectedLanguage == "English"){
      return "en";
    }
    else if(selectedLanguage == "Nederlands"){
      return "nl";
    }
    else if(selectedLanguage == "Deutsh"){
      return "de";
    }
    else if(selectedLanguage == "Español"){
      return "es";
    }
    else if(selectedLanguage == "Português"){
      return "pt";
    }
    else if(selectedLanguage == "Italiano"){
      return "it";
    }
    else if(selectedLanguage == "Canada"){
      return "ca";
    }

    else{
      return "fr";
    }
  }

  String _showTimePicker(BuildContext context){
    var selectedTime="";
    var selectedLanguage =  optifoodSharedPrefrence.getString(ConstantSharedPreferenceKeys.KEY_SELECTED_LANGUAGE)!=null?optifoodSharedPrefrence.getString(ConstantSharedPreferenceKeys.KEY_SELECTED_LANGUAGE)!:ConstantSharedPreferenceKeys.KEY_SELECTED_LANGUAGE;
    var groupTimeFormat =  optifoodSharedPrefrence.getString(ConstantSharedPreferenceKeys.KEY_SELECTED_TIME_FORMAT)!=null?optifoodSharedPrefrence.getString(ConstantSharedPreferenceKeys.KEY_SELECTED_TIME_FORMAT)!:ConstantSharedPreferenceKeys.KEY_SELECTED_TIME_FORMAT;
    showTimePicker(
        helpText: "",
        hourLabelText: "",
        cancelText: "cancel".tr(),
        confirmText: "ok".tr(),
        minuteLabelText: "minute".tr(),
        builder: (context, child) {
          final Widget mediaQueryWrapper = MediaQuery(
            data: MediaQuery.of(context).copyWith(
              alwaysUse24HourFormat: false,
            ),
            child: MediaQuery(
              data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: false),
              child:  Container(
                height: 100,
                width: 320,
                child: child,
              ),),
          );
          return Theme(
            child: (selectedLanguage != "English" && groupTimeFormat=="12H")?
            Localizations.override(
              context: context,
              locale: Locale('es', 'US'),
              child: mediaQueryWrapper,
            ):MediaQuery(data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: groupTimeFormat=="24H"?true:false),
              child:  Container(
                height: 100,
                width: 320,
                child: child,
              ),),
            data: ThemeData(
              textButtonTheme: TextButtonThemeData(
                style: TextButton.styleFrom(
                  primary: AppTheme.colorRed, // button text color
                ),
              ),
              colorScheme: const ColorScheme.light(
                primary: AppTheme.colorRed, // <-- SEE HERE
                background:  AppTheme.colorRed,
              ),
              timePickerTheme: TimePickerThemeData(
                dialHandColor:  AppTheme.colorRed,
              ),
            ),
          );
        },
        context: context,
        initialTime: TimeOfDay.now()).then((value){
      var time=value.toString().split("(")[1].split(")")[0];
      if(selectedLanguage != "English" && groupTimeFormat=="12H" && int.parse(time.split(":")[0])>12){
        selectedTime=(int.parse(time.split(":")[0])-12).toString()+":${time.split(":")[1]}"+" PM";
      }
      else if(selectedLanguage != "English" && groupTimeFormat=="12H" && int.parse(time.split(":")[0])<12){
        selectedTime=time+" AM";
      }
      else if(selectedLanguage == "English" && groupTimeFormat=="24H"){
        selectedTime=time;
      }
      else {
        selectedTime= value?.format(context) as String;
      }
      var aa=Localizations.override(
          context: context,
          locale: Locale('fr', 'US'));
    });

    return selectedTime;
  }
  List<String> generateShiftTiming(String start,String end,{String? selectedDate}){

    if(start=='')
      return [''];
    int startMin = int.parse(start.split(":")[0])*60+int.parse(start.split(":")[1]);
    // int endMin = int.parse(end.split(":")[0])*60+int.parse(end.split(":")[1]);
    String strCurrentTime = DateFormat("HH:mm").format(DateTime.now());
    int endMin = int.parse(strCurrentTime.split(":")[0])*60+int.parse(strCurrentTime.split(":")[1]);
    int diff = startMin-endMin;
    String startDateTime = "";
    String endDateTime = "";
    if(selectedDate==null||selectedDate==''){
      selectedDate = DateFormat("yyyy-MM-dd").format(DateTime.now());
    }
    if(diff<0){
      //same day
      startDateTime = selectedDate+" "+start;
      //endDateTime = DateFormat("yyyy-MM-dd").format(DateTime.now())+" "+end;
      endDateTime = selectedDate+" "+end;
    }
    else{
      //start in prev day or end in next day
      //String strCurrentTime = DateFormat("HH:mm").format(DateTime.now());
      // String strCurrentTime = DateFormat("HH:mm").format(DateTime.parse(selectedDate));
      int currentMin = int.parse(strCurrentTime.split(":")[0])*60+int.parse(strCurrentTime.split(":")[1]);
      if(currentMin>startMin){
        //add 1 day in end date
        startDateTime = selectedDate+" "+start;
        endDateTime = DateFormat("yyyy-MM-dd").format(DateTime.parse(selectedDate).add(Duration(days: 1)))+" "+end;
      }
      else{
        //subtract 1 day from start date
        //startDateTime = DateFormat("yyyy-MM-dd").format(DateTime.now().subtract(Duration(days: 1)))+" "+start;

        startDateTime = DateFormat("yyyy-MM-dd").format(DateTime.parse(selectedDate).subtract(Duration(days: 1)))+" "+start;
        endDateTime = DateFormat("yyyy-MM-dd").format(DateTime.parse(selectedDate))+" "+end;
      }
    }
    //print(startDateTime);
    //print(endDateTime);
    List<String> times = [startDateTime,endDateTime];
    // print("Satrt dateeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee: ${startDateTime} ${endDateTime}");
    return times;
  }


  String generateShiftTimingForOrdersShift(String start){
    if(start.length>6){
      if(start.substring(6,8)=='PM'){
        if(int.parse(start.split(":")[0])!=12) {
          int startTime = int.parse(start.split(":")[0]) + 12;
          start = "${startTime}:${start.split(":")[1].split(" ")[0]}";
        }
        else{
          start = "${start.split(":")[0]}:${start.split(":")[1].split(" ")[0]}";
        }
      }
      else{
        start = "${start.split(":")[0]}:${start.split(":")[1].split(" ")[0]}";
      }
    }
    int startMin = int.parse(start.split(":")[0])*60+int.parse(start.split(":")[1]);
    String selectedDate = DateFormat("yyyy-MM-dd").format(DateTime.now());
    String strCurrentTime = DateFormat("HH:mm").format(DateTime.now());

    int endMin = int.parse(strCurrentTime.split(":")[0])*60+int.parse(strCurrentTime.split(":")[1]);

    int diff = startMin-endMin;
    String startDateTime = "";
    if(diff<0){

      //same day
      startDateTime = selectedDate+" "+start;

    }
    else{
      startDateTime = DateFormat("yyyy-MM-dd").format(DateTime.parse(selectedDate).subtract(Duration(days: 1)))+" "+start;
      }
    String times = startDateTime;
    return times;
  }

  ServerSyncActionPending getServerSyncActionPending(String actionPendingServer){
    List<String> list = actionPendingServer.split(",");
    ServerSyncActionPending serverSyncActionPending = new ServerSyncActionPending();
    list.forEach((element) {
      if(element == ConstantSyncOnServerPendingActions.ACTION_PENDING_CREATE){
        serverSyncActionPending.isPendingCreate = true;
      }
      else if(element == ConstantSyncOnServerPendingActions.ACTION_PENDING_UPDATE){
        serverSyncActionPending.isPendingUpdate = true;
      }
    });

    return serverSyncActionPending;
  }
  String addServerSyncActionPending(String currentActionPendings,String actionPendingServer){
        if(currentActionPendings.trim().length>0){
          currentActionPendings = currentActionPendings + ",";
        }
    currentActionPendings = currentActionPendings + actionPendingServer;
    return currentActionPendings;
  }
  String removeServerSyncActionPending(String actionPendingServer){
    String returnActionPending = "";
    List<String> list = actionPendingServer.split(",");
    list.forEach((element) {
      if(element != actionPendingServer){
        if(returnActionPending.trim().length>0){
          returnActionPending = returnActionPending + ",";
        }
        returnActionPending = returnActionPending + element;
      }
    });
    return returnActionPending;
  }

  void checkVersionUpdate(BuildContext context){
    showDialog(context: context,
        builder: (BuildContext context) {
          return ConfirmationPopup(
              title: "New Update",
              subTitle: "New Update Available",
              titleImagePath: AppImages.phoneWithHandIcon,
              titleImageBackgroundColor: AppTheme.colorRed,
              positiveButtonText: "Update",
              negativeButtonText: "Cancel",
              positiveButtonPressed: () async {

              },
              negativeButtonPressed: () async {

              }
            // order:snapshot.data![index]
          );
        });
  }

}
