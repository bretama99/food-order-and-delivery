import 'dart:io';

import 'package:dio/dio.dart';
import 'package:fbroadcast/fbroadcast.dart';
import 'package:opti_food_app/database/delivery_fee_dao.dart';
import 'package:path_provider/path_provider.dart';

import '../data_models/attribute_category_model.dart';
import '../data_models/delivery_fee_model.dart';
import '../data_models/night_mode_fee_model.dart';
import '../data_models/server_sync_action_pending.dart';
import '../database/attribute_category_dao.dart';
import '../database/night_mode_fee_dao.dart';
import '../main.dart';
import '../utils/constants.dart';
import '../utils/utility.dart';
import 'package:path/path.dart' as path;
import 'package:http/http.dart' as http;

class NightModeFeeApi{
  static String OPTIFOOD_DATABASE=optifoodSharedPrefrence.getString("database").toString();
  static String authorization = optifoodSharedPrefrence.getString("accessToken").toString();
  static saveNightModeFeeToServer() {
    final dio = Dio();
    dio.options.headers['X-TenantID'] = OPTIFOOD_DATABASE;
    dio.options.headers['Authorization'] = authorization;
    NightModeFeeDao().getNightModeFeeLast().then((value) async{
       var data = {
          'activateNightFeeRestaurant': value!.activateNightFeeRestaurant,
          'activateNightFeeDelivery': value.activateNightFeeDelivery,
          'nightFee': value.nightFee,
         "startTime": value.startTime,
         "endTime": value.endTime,
        };
      var response = await dio.post(ServerData.OPTIFOOD_BASE_URL+"/api/night-mode-fee",
        data: data,
      ).then((response){
        var singleData = NightModeFeeModel.fromJsonServer(response.data);
        value.isSynced=true;
        value.serverId=singleData.serverId;
        NightModeFeeDao().updateNightModeFee(value).then((value333) {
        });

      }).catchError((onError){
      });
    });
  }
  static updateNightModeFeeServer(NightModeFeeModel value) async {
    final dio = Dio();
    dio.options.headers['X-TenantID'] = OPTIFOOD_DATABASE;
    dio.options.headers['Authorization'] = authorization;
    var data = {
      'activateNightFeeRestaurant': value.activateNightFeeRestaurant,
      'activateNightFeeDelivery': value.activateNightFeeDelivery,
      'nightFee': value.nightFee,
      "startTime": value.startTime,
      "endTime": value.endTime,
    };
      var response = await dio.put("${ServerData.OPTIFOOD_BASE_URL}/api/night-mode-fee/${value.serverId!>0?value.serverId:value.id}",
        data: data,
      ).then((value1){
      }).catchError((onError){

      });
  }

  static getNightModeFeeFromServer() async {
    final dio = Dio();
    dio.options.headers['X-TenantID'] = OPTIFOOD_DATABASE;
    dio.options.headers['Authorization'] = authorization;
    await dio.get(ServerData.OPTIFOOD_BASE_URL+"/api/night-mode-fee").then((response) async {

      List<NightModeFeeModel> fetchedData = [];
      if (response.statusCode == 200) {
        for (int i = 0; i < response.data.length; i++) {
          var singleItem = NightModeFeeModel.fromJsonServer(response.data[i]);
          fetchedData.add(singleItem);
        }
        for (int i = 0; i < fetchedData.length; i++) {
          NightModeFeeDao().getNightModeFeeByServerId(fetchedData[i].serverId!).then((
              value) {
            NightModeFeeModel nightModeFeeModel = NightModeFeeModel(
              fetchedData[i].id,
              fetchedData[i].activateNightFeeRestaurant,
              fetchedData[i].activateNightFeeDelivery,
              fetchedData[i].nightFee,
              fetchedData[i].startTime,
              fetchedData[i].endTime,
              serverId: fetchedData[i].serverId,
            );
            NightModeFeeDao().updateNightModeFee(nightModeFeeModel).then((res1) {
              if (i == fetchedData.length - 1) {
              }
            });
            NightModeFeeDao().insertNightModeFee(nightModeFeeModel).then((
                res2) {
              if (i == fetchedData.length - 1) {
              }
            });
          });
        }
      }
    }).catchError((onError){
     
    });
  }


}