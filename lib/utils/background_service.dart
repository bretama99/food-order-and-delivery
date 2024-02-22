import 'package:cron/cron.dart';
import 'package:flutter/material.dart';
import 'package:opti_food_app/api/product.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wifi_configuration_2/wifi_configuration_2.dart';
/*class BackgroundService {
  final cron = Cron();
  ScheduledTask? scheduledTask;
  WifiConfiguration wifiConfiguration = WifiConfiguration();
  late SharedPreferences sharedPreferences;
  @override
  void initState() {
  }


  void scheduleTask() async { */
    //scheduledTask = cron.schedule(Schedule.parse("* */1 * * * *"), () async {
     /* syncFromLocalToServer();
      syncFromServerToLocal();
      checkConnection();
    });
  }

  void scheduleTaskForSevr() async { */
    //scheduledTask = cron.schedule(Schedule.parse("* */10 * * * *"), () async {
    /*  syncFromServerToLocal();
    });
  }

  void cancelTask() {
    scheduledTask?.cancel();
  }

  void checkConnection() async {
    wifiConfiguration.isWifiEnabled().then((value) {
      bool previousValue=false;
      SharedPreferences.getInstance().then((value1){
          sharedPreferences  = value1;
          String? wifiStatus=sharedPreferences.getString('wifi')!=null?sharedPreferences.getString('wifi') : "false";
          previousValue=wifiStatus?.toLowerCase() == 'true';
          sharedPreferences.setString('wifi', value.toString());
        if(previousValue==false && value==true) {
          syncFromServerToLocal();
        }
      });
      });

  }

  syncFromLocalToServer(){
    wifiConfiguration.isWifiEnabled().then((value) {
      if(value) {
        // ProductApis.saveAttributeCategoryToSever();
        // ProductApis.saveFoodItemToSever();
        // ProductApis.saveAttributeToSever();
        // ProductApis.saveFoodCategoryToSever();
      }
    });
  }

  syncFromServerToLocal(){
    // ProductApis.getAttributeListFromServer();
    // ProductApis.getAttributeCategoryListFromServer();
    // ProductApis.getFoodItemsListFromServer();
    // ProductApis.getFoodCategoryListFromServer();
  }


  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    throw UnimplementedError();
  }
}*/
