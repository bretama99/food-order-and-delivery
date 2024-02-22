import 'package:fbroadcast/fbroadcast.dart';
import 'package:opti_food_app/data_models/reservation_model.dart';
import 'package:opti_food_app/data_models/restaurant_info_model.dart';
import 'package:opti_food_app/database/restaurant_info_dao.dart';
import 'package:dio/dio.dart';
import '../../utils/constants.dart';
import '../database/reservation_dao.dart';
import '../main.dart';
import '../utils/app_config.dart';

class ReservationApis {
  static String OPTIFOOD_DATABASE=optifoodSharedPrefrence.getString("database").toString();
  static String authorization = optifoodSharedPrefrence.getString("accessToken").toString();
  static saveReservationToSever(ReservationModel reservationModel,{bool isUpdate=false}) async {

  final dio = Dio();
  dio.options.headers['X-TenantID'] = OPTIFOOD_DATABASE;
  dio.options.headers['Authorization'] = authorization;
  var data={
  "name":reservationModel.name,
  "phone":reservationModel.phone,
  "comment":reservationModel.comment,
  "numberOfPersons":reservationModel.numberOfPersons,
  "reservationDate":reservationModel.reservationDate.split(
      "/")[2] + "-" + reservationModel.reservationDate.split("/")[1] + "-" +reservationModel.reservationDate.split("/")[0],
  "reservationTime":reservationModel.reservationTime+":00",
  "typeOfReservation":reservationModel.typeOfReservation,
  "status":reservationModel.status,
    "dateTimeZone":AppConfig.dateTime.timeZoneOffset.inMinutes,

  };

  if(isUpdate){
  var response = await dio.put(ServerData.OPTIFOOD_BASE_URL+"/api/reservation/"+reservationModel.serverId.toString(),
  data: data,
  ).then((response){
  var singleData = ReservationModel.fromJsonServer(response.data);
  reservationModel.isSynced=true;
  reservationModel.serverId=singleData.serverId;

  ReservationDao().updateReservation(reservationModel).then((value333) {
  print("Reservation updated");
  });

  }).catchError((onError){
  print("Reservation Error : "+onError.toString());
  });
  }else{
    var response = await dio.post(ServerData.OPTIFOOD_BASE_URL+"/api/reservation",
  data: data,
  ).then((response){
  var singleData = ReservationModel.fromJsonServer(response.data);
  reservationModel.isSynced=true;
  reservationModel.serverId=singleData.serverId;

  ReservationDao().updateReservation(reservationModel).then((value333) {
  print("Reservation updated");
  });

  }).catchError((onError){
  print("Reservation Error : "+onError.toString());
  });
  }
  }

  static getReservationFromServer({Function? callback = null}) async {
    final dio = Dio();
    dio.options.headers['X-TenantID'] = OPTIFOOD_DATABASE;
    dio.options.headers['Authorization'] = authorization;
    await dio.get(ServerData.OPTIFOOD_BASE_URL+"/api/reservation",queryParameters: {
    "dateTimeZone":AppConfig.dateTime.timeZoneOffset.inMinutes
    }).then((response) async {
      List<ReservationModel> fetchedData = [];
      if (response.statusCode == 200) {
        for (int i = 0; i < response.data.length; i++) {
          var singleItem = ReservationModel.fromJsonServer(response.data[i]);
          fetchedData.add(singleItem);
        }
        for (int i = 0; i < fetchedData.length; i++) {
          fetchedData[i].reservationDate = fetchedData[i].reservationDate.split("-")[2]
              .substring(0, 2) + "/" + fetchedData[i].reservationDate.split("-")[1] + "/" + fetchedData[i].reservationDate.split("/")[0].substring(0,4);

          fetchedData[i].reservationTime = fetchedData[i].reservationTime.split(":")[0] +":"+ fetchedData[i].reservationTime.split(":")[1];
          ReservationDao().getReservationByServerId(fetchedData[i].serverId!).then((
              value) {
            ReservationModel reservationModel = ReservationModel(
              fetchedData[i].id,
              fetchedData[i].name,
              fetchedData[i].phone,
              fetchedData[i].reservationDate,
              fetchedData[i].reservationTime,
              fetchedData[i].typeOfReservation,
              fetchedData[i].numberOfPersons,
              fetchedData[i].comment,
              fetchedData[i].status,
              serverId: fetchedData[i].serverId,
            );
            if (value!=null) {
              ReservationDao()
                    .updateReservation(reservationModel)
                    .then((res1) {
                  if (i == fetchedData.length - 1) {
                  }
                });
            }
            else {

              ReservationDao().insertReservation(reservationModel).then((
                  res2) {
                if (i == fetchedData.length - 1) {
                }
              });
            }
          });
        }
      }
      if(callback!=null){
        callback();
      }
    }).catchError((onError){
      if(callback!=null){
        callback();
      }
    });
  }

  static deleteReservation(int serverId) async {
    final dio = Dio();
    dio.options.headers['X-TenantID'] = OPTIFOOD_DATABASE.toString();
    dio.options.headers['Authorization'] = authorization;
    await dio.delete(ServerData.OPTIFOOD_BASE_URL+"/api/reservation/${serverId}").then((value){
    });
  }

  static Future<void> changeStatusReservationServer(ReservationModel reservationList) async {
    final dio = Dio();
    dio.options.headers['X-TenantID'] = OPTIFOOD_DATABASE;
    dio.options.headers['Authorization'] = authorization;
    var data={
      "status":reservationList.status,
    };
    var response = await dio.put(ServerData.OPTIFOOD_BASE_URL+"/api/reservation/status/"+reservationList.serverId.toString(),
      data: data,
    );
  }

  static saveReservationDataFromServerToLocalDB(var responseData, {Function? callback = null}) async {
    List<ReservationModel> fetchedData = [];

    if(responseData==null)
      return;
    for (int i = 0; i < responseData.length; i++) {
      var singleItem = ReservationModel.fromJsonServer(responseData[i]);
      if(responseData[i]['deleted']) {
        print("Now check for delete reservation ${responseData[i]['deleted']}");
        ReservationDao().getReservationByServerId(singleItem.serverId!).then((value) {
          ReservationDao().delete(value!);
        });
      }
      else
        fetchedData.add(singleItem);
    }

    for (int i = 0; i < fetchedData.length; i++) {
      fetchedData[i].reservationDate = fetchedData[i].reservationDate.split("-")[2]
          .substring(0, 2) + "/" + fetchedData[i].reservationDate.split("-")[1] + "/" + fetchedData[i].reservationDate.split("/")[0].substring(0,4);

      fetchedData[i].reservationTime = fetchedData[i].reservationTime.split(":")[0] +":"+ fetchedData[i].reservationTime.split(":")[1];
      if (/*fetchedData[i].imagePath.toString() == 'null'*/true) {
        ReservationDao()
            .getReservationByServerId(fetchedData[i].serverId!)
            .then((value) async {

          ReservationModel reservationModel = ReservationModel(
            fetchedData[i].id,
            fetchedData[i].name,
            fetchedData[i].phone,
            fetchedData[i].reservationDate,
            fetchedData[i].reservationTime,
            fetchedData[i].typeOfReservation,
            fetchedData[i].numberOfPersons,
            fetchedData[i].comment,
            fetchedData[i].status,
            serverId: fetchedData[i].serverId,
          );
          if (value != null) {
            value.id = fetchedData[i].id;
            value.name = fetchedData[i].name;
            value.phone = fetchedData[i].phone;
            value.reservationDate = fetchedData[i].reservationDate;
            value.reservationTime = fetchedData[i].reservationTime;
            value.typeOfReservation = fetchedData[i].typeOfReservation;
            value.serverId = fetchedData[i].serverId;
            value.comment = fetchedData[i].comment;
            value.status = fetchedData[i].status;
            ReservationDao().updateReservation(value).then((res1) {
              FBroadcast.instance().broadcast(
                  ConstantBroadcastKeys.KEY_UPDATE_UI);
              if (i == fetchedData.length - 1) {}
            });
          }
          else {

            ReservationDao().insertReservation(
                reservationModel!).then((res2) {
                FBroadcast.instance().broadcast(
                    ConstantBroadcastKeys.KEY_UPDATE_UI);
                if (i == fetchedData.length - 1) {}
              });

          }
        });
      }
    }
  }
  
}