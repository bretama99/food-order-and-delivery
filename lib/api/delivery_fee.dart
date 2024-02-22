import 'dart:io';
import 'package:dio/dio.dart';
import 'package:opti_food_app/database/delivery_fee_dao.dart';
import '../data_models/delivery_fee_model.dart';
import '../main.dart';
import '../utils/constants.dart';

class DeliveryFeeApi{
  static String OPTIFOOD_DATABASE=optifoodSharedPrefrence.getString("database").toString();
  static String authorization = optifoodSharedPrefrence.getString("accessToken").toString();
  static saveDeliveryFeeToServer() {
    final dio = Dio();
    dio.options.headers['X-TenantID'] = OPTIFOOD_DATABASE;
    dio.options.headers['Authorization'] = authorization;
    DeliveryFeeDao().getDeliveryFeeLast().then((value) async{
       var data = {
          'activateDeliveryFee': value!.activateDeliveryFee,
          'deliveryFee': value!.deliveryFee,
          'minimumOrderAmountToExpectDeliveryFee': value.minimumOrderAmountToExpectDeliveryFee,
          "displayName": value.displayName,
        };
      var response = await dio.post(ServerData.OPTIFOOD_BASE_URL+"/api/delivery-fee",
        data: data,
      ).then((response){
        var singleData = DeliveryFeeModel.fromJsonServer(response.data);
        value.isSynced=true;
        value.serverId=singleData.serverId;
        DeliveryFeeDao().updateDeliveryFee(value).then((value333) {
        });

      }).catchError((onError){
      });
    });
  }
  static updateDeliveryFeeServer(DeliveryFeeModel value) async {
      final dio = Dio();
      dio.options.headers['X-TenantID'] = OPTIFOOD_DATABASE;
      dio.options.headers['Authorization'] = authorization;
      var data = {
          'activateDeliveryFee': value!.activateDeliveryFee,
          'deliveryFee': value.deliveryFee,
          'minimumOrderAmountToExpectDeliveryFee': value.minimumOrderAmountToExpectDeliveryFee,
          "displayName": value.displayName,
        };
      var response = await dio.put(ServerData.OPTIFOOD_BASE_URL+"/api/delivery-fee/${value.serverId!>0?value.serverId:value.id}",
        data: data,
      ).then((value1){
      }).catchError((onError){

    });
  }

  static getDeliveryFeeFromServer() async {
    final dio = Dio();
    dio.options.headers['X-TenantID'] = OPTIFOOD_DATABASE;
    dio.options.headers['Authorization'] = authorization;
    await dio.get(ServerData.OPTIFOOD_BASE_URL+"/api/delivery-fee").then((response) async {
      List<DeliveryFeeModel> fetchedData = [];
      if (response.statusCode == 200) {
        for (int i = 0; i < response.data.length; i++) {
          var singleItem = DeliveryFeeModel.fromJsonServer(response.data[i]);
          fetchedData.add(singleItem);
        }
        for (int i = 0; i < fetchedData.length; i++) {
          DeliveryFeeDao().getDeliveryFeeByServerId(fetchedData[i].serverId!).then((
              value) {
            DeliveryFeeModel deliveryFeeModel = DeliveryFeeModel(
              fetchedData[i].id,
              fetchedData[i].activateDeliveryFee,
              fetchedData[i].deliveryFee,
              fetchedData[i].minimumOrderAmountToExpectDeliveryFee,
              fetchedData[i].displayName,
              serverId: fetchedData[i].serverId,
            );
            DeliveryFeeDao().updateDeliveryFee(deliveryFeeModel).then((res1) {
              if (i == fetchedData.length - 1) {
              }
            });
            DeliveryFeeDao().insertDeliveryFee(deliveryFeeModel).then((
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