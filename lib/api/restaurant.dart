
import 'dart:io';

import 'package:opti_food_app/data_models/restaurant_info_model.dart';
import 'package:opti_food_app/database/restaurant_info_dao.dart';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import '../../utils/constants.dart';
import 'package:path/path.dart' as path;
import 'package:http/http.dart' as http;

import '../main.dart';
import '../utils/app_config.dart';

class RestaurantApis {
  static String OPTIFOOD_MANAGEMENT_DATABASE='optifood_management';
  static String OPTIFOOD_DATABASE=optifoodSharedPrefrence.getString("database").toString();
  static String authorization = optifoodSharedPrefrence.getString("accessToken").toString();
  static getRestaurantInfoFromServer({Function? callback = null}) async {
    final dio = Dio();
    dio.options.headers['X-TenantID'] = OPTIFOOD_DATABASE;
    dio.options.headers['Authorization'] = authorization;
    await dio.get(ServerData.OPTIFOOD_BASE_URL+"/api/restaurant",queryParameters: {
      "dateTimeZone":AppConfig.dateTime.timeZoneOffset.inMinutes
    }).then((response) async {

      List<RestaurantInfoModel> fetchedData = [];
      if (response.statusCode == 200) {
        if (fetchedData.length==0) {
          //callback!();
        }
        for (int i = 0; i < response.data.length; i++) {
          var singleItem = RestaurantInfoModel.fromJsonServer(response.data[i]);
          fetchedData.add(singleItem);
        }
        for (int i = 0; i < fetchedData.length; i++) {
          optifoodSharedPrefrence.setString("hour", fetchedData[i].startTime.substring(0,2));
          optifoodSharedPrefrence.setString("minute", fetchedData[i].startTime.substring(3,5));
          if(true) {
              RestaurantInfoDao().getRestaurantInfoByServerId(
                  fetchedData[i].serverId!).then((value) {
                RestaurantInfoModel restaurantInfoModel = RestaurantInfoModel(
                  fetchedData[i].id,
                  fetchedData[i].name,
                  fetchedData[i].phoneNumber,
                  fetchedData[i].address,
                  fetchedData[i].startTime.substring(0, 5),
                  fetchedData[i].endTime.substring(0, 5),
                  fetchedData[i].email,
                  imagePath: null,
                  serverId: fetchedData[i].serverId,
                  lat: fetchedData[i].lat,
                  lon: fetchedData[i].lon
                );
                RestaurantInfoDao()
                    .updateRestaurantInfo(restaurantInfoModel)
                    .then((res1) {
                  if (i == fetchedData.length - 1) {
                    //callback!();
                  }
                });
                RestaurantInfoDao()
                    .insertRestaurantInfo(restaurantInfoModel)
                    .then((res2) {
                  if (i == fetchedData.length - 1) {
                    //callback!();
                  }
                });
              });
          }
          else{
            var imgUrl = ServerData.OPTIFOOD_IMAGES+"/restaurant/"+fetchedData[i].imagePath.toString();
            final response1 = await http.get(Uri.parse(imgUrl));
            final imageName = path.basename(imgUrl);
            final documentDirectory1 = await getApplicationDocumentsDirectory();
            final localPath = path.join(documentDirectory1.path, imageName);
            final imageFile = File(localPath);
            await imageFile.writeAsBytes(response1.bodyBytes).then((value222) {
              var image = imageFile.toString().substring(8, imageFile
                  .toString()
                  .length - 1);
              fetchedData[i].imagePath = image;
              RestaurantInfoDao().getRestaurantInfoByServerId(
                  fetchedData[i].serverId!).then((value) {
                RestaurantInfoModel restaurantInfoModel = RestaurantInfoModel(
                  fetchedData[i].id,
                  fetchedData[i].name,
                  fetchedData[i].phoneNumber,
                  fetchedData[i].address,
                  fetchedData[i].startTime.substring(0, 5),
                  fetchedData[i].endTime.substring(0, 5),
                  fetchedData[i].email,
                  imagePath: fetchedData[i].imagePath,
                  serverId: fetchedData[i].serverId,
                  lat: fetchedData[i].lat,
                  lon: fetchedData[i].lon
                );

                RestaurantInfoDao()
                    .updateRestaurantInfo(restaurantInfoModel)
                    .then((res1) {
                  if (i == fetchedData.length - 1) {}
                });
                RestaurantInfoDao()
                    .insertRestaurantInfo(restaurantInfoModel)
                    .then((res2) {
                  if (i == fetchedData.length - 1) {}

                });
              });
            });
          }
        }
      }

       if(callback!=null){
         callback();
       }
    }).catchError((onError){
      callback!();
    });
  }

}