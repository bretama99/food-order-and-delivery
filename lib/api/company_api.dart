import 'dart:io';
import 'package:dio/dio.dart';
import 'package:fbroadcast/fbroadcast.dart';
import 'package:path_provider/path_provider.dart';
import '../../utils/constants.dart';
import '../data_models/company_model.dart';
import '../database/company_dao.dart';
import '../main.dart';
import 'package:path/path.dart' as path;
import 'package:http/http.dart' as http;


class CompanyApis {
  static String OPTIFOOD_DATABASE=optifoodSharedPrefrence.getString("database").toString();
  static String authorization = optifoodSharedPrefrence.getString("accessToken").toString();
  void getCompanyListFromServer({Function? callback = null}) async {
    final dio = Dio();
    List<CompanyModel> fetchedData = [];
    dio.options.headers['X-TenantID'] = OPTIFOOD_DATABASE;
    await dio.get(ServerData.OPTIFOOD_BASE_URL+"/api/company").then((response) async {
      List<CompanyModel> fetchedData = [];
      if (response.statusCode == 200) {
        saveCompanyDataFromServerToLocalDB(response.data, callback: () {
          callback!();
        });
        /*for (int i = 0; i < response.data.length; i++) {
          var singleItem = CompanyModel.fromJsonServer(response.data[i]);
          fetchedData.add(singleItem);
        }
        for (int i = 0; i < fetchedData.length; i++) {

          if(fetchedData[i].imagePath.toString()=='null'){
            CompanyDao().getCompanyByServerId(fetchedData[i].serverId!).then((
                value) {
              CompanyModel companyModel = CompanyModel(
                // fetchedData[i].id,
                  fetchedData[i].name,
                  email: fetchedData[i].email,
                  phoneNo:fetchedData[i].phoneNo,
                  address:fetchedData[i].address,
                  serverId: fetchedData[i].serverId,
                  imagePath:null
              );
              if (value!=null) {
                value.name=fetchedData[i].name;
                value.serverId=fetchedData[i].serverId;
                value.email=fetchedData[i].email;
                value.phoneNo = fetchedData[i].phoneNo;
                value.address = fetchedData[i].address;
                value.id=fetchedData[i].id;
                value.imagePath=null;
                CompanyDao()
                    .updateCompany(value)
                    .then((res1) {
                  if (i == fetchedData.length - 1) {
                  }
                });
              }
              else {

                CompanyDao().insertCompany(companyModel).then((
                    res2) {
                  if (i == fetchedData.length - 1) {
                  }
                });
              }
            });
          }else{

            var imgUrl = ServerData.OPTIFOOD_IMAGES+"/company/"+fetchedData[i].imagePath.toString();
            final response1 = await http.get(Uri.parse(imgUrl));
            final imageName = path.basename(imgUrl);
            final documentDirectory1 = await getApplicationDocumentsDirectory();
            final localPath = path.join(documentDirectory1.path, imageName);
            final imageFile = File(localPath);
            await imageFile.writeAsBytes(response1.bodyBytes).then((value222){
              var image = imageFile.toString().substring(8, imageFile.toString().length - 1);
              fetchedData[i].imagePath=image;
              CompanyDao().getCompanyByServerId(fetchedData[i].serverId!).then((
                  value) {
                CompanyModel companyModel = CompanyModel(
                  // fetchedData[i].id,
                    fetchedData[i].name,
                    email: fetchedData[i].email,
                    phoneNo:fetchedData[i].phoneNo,
                    address:fetchedData[i].address,
                    serverId: fetchedData[i].serverId,
                    imagePath:fetchedData[i].imagePath,
                );
                if (value!=null) {
                  value.name=fetchedData[i].name;
                  value.serverId=fetchedData[i].serverId;
                  value.email=fetchedData[i].email;
                  value.phoneNo = fetchedData[i].phoneNo;
                  value.address = fetchedData[i].address;
                  value.id=fetchedData[i].id;
                  value.imagePath=fetchedData[i].imagePath;
                  CompanyDao()
                      .updateCompany(value)
                      .then((res1) {
                    if (i == fetchedData.length - 1) {
                    }
                  });
                }
                else {
                  CompanyDao().insertCompany(companyModel).then((
                      res2) {
                    if (i == fetchedData.length - 1) {
                    }
                  });
                }
              });
            });
          }

          }*/
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

  Future<void> saveCompanyToServer(CompanyModel companyModel) async {
    final dio = Dio();
    dio.options.headers['X-TenantID'] = OPTIFOOD_DATABASE;
    dio.options.headers['Authorization'] = authorization;
    //CompanyDao().getCompanyLast().then((value) async{
      var formData;
        formData = FormData.fromMap({
          'companyName': companyModel.name,
          'email': companyModel.email,
          'phoneNumber': companyModel.phoneNo,
          "address": companyModel.address,
        });

        dio.post(ServerData.OPTIFOOD_BASE_URL +"/api/company",
        data: formData,
      ).then((response){
        var singleData = CompanyModel.fromJsonServer(response.data);
        companyModel.isSynced=true;
        companyModel.serverId=singleData.serverId;
        CompanyDao().updateCompany(companyModel).then((value333) {
        });

      }).catchError((onError){
      });
    //});
  }

   saveCompanyDataFromServerToLocalDB(var responseData, {Function? callback = null}) async {
    print("Checking companyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyy: ${responseData}");
    List<CompanyModel> fetchedData = [];
    for (int i = 0; i < responseData.length; i++) {
      var singleItem = CompanyModel.fromJsonServer(responseData[i]);
      if(responseData[i]['deleted']) {
        print("Now check for delete company ${responseData[i]['deleted']}");
        CompanyDao().getCompanyByServerId(singleItem.serverId!).then((value){
          if(value!=null){
            CompanyDao().delete(value!);
            }
        });
      }
      else
        fetchedData.add(singleItem);
    }
    for (int i = 0; i < fetchedData.length; i++) {

      if(fetchedData[i].imagePath.toString()=='null'){
        CompanyDao().getCompanyByServerId(fetchedData[i].serverId!).then((
            value) {
          CompanyModel companyModel = CompanyModel(
            // fetchedData[i].id,
              fetchedData[i].name,
              email: fetchedData[i].email,
              phoneNo:fetchedData[i].phoneNo,
              address:fetchedData[i].address,
              serverId: fetchedData[i].serverId,
              imagePath:null
          );
          if (value!=null) {
            value.name=fetchedData[i].name;
            value.serverId=fetchedData[i].serverId;
            value.email=fetchedData[i].email;
            value.phoneNo = fetchedData[i].phoneNo;
            value.address = fetchedData[i].address;
            value.id=fetchedData[i].id;
            value.imagePath=null;
            CompanyDao()
                //.updateCompany(value)
                .updateCompanyByServerID(value)
                .then((res1) {
              if (i == fetchedData.length - 1) {
              }
            });
          }
          else {

            CompanyDao().insertCompany(companyModel).then((
                res2) {
              if (i == fetchedData.length - 1) {
              }
            });
          }
          FBroadcast.instance().broadcast(
              ConstantBroadcastKeys.KEY_UPDATE_UI);
        });
      }else{

        var imgUrl = ServerData.OPTIFOOD_IMAGES+"/company/"+fetchedData[i].imagePath.toString();
        final response1 = await http.get(Uri.parse(imgUrl));
        final imageName = path.basename(imgUrl);
        final documentDirectory1 = await getApplicationDocumentsDirectory();
        final localPath = path.join(documentDirectory1.path, imageName);
        final imageFile = File(localPath);
        await imageFile.writeAsBytes(response1.bodyBytes).then((value222){
          var image = imageFile.toString().substring(8, imageFile.toString().length - 1);
          fetchedData[i].imagePath=image;
          CompanyDao().getCompanyByServerId(fetchedData[i].serverId!).then((
              value) {
            CompanyModel companyModel = CompanyModel(
              // fetchedData[i].id,
              fetchedData[i].name,
              email: fetchedData[i].email,
              phoneNo:fetchedData[i].phoneNo,
              address:fetchedData[i].address,
              serverId: fetchedData[i].serverId,
              imagePath:fetchedData[i].imagePath,
            );
            if (value!=null) {
              value.name=fetchedData[i].name;
              value.serverId=fetchedData[i].serverId;
              value.email=fetchedData[i].email;
              value.phoneNo = fetchedData[i].phoneNo;
              value.address = fetchedData[i].address;
              value.id=fetchedData[i].id;
              value.imagePath=fetchedData[i].imagePath;
              CompanyDao()
                  .updateCompany(value)
                  .then((res1) {
                if (i == fetchedData.length - 1) {
                }
              });
            }
            else {
              CompanyDao().insertCompany(companyModel).then((
                  res2) {
                if (i == fetchedData.length - 1) {
                }
              });
            }
          });
        });
      }

    }
  }
  Future<void> deleteCompany(int serverId) async {
    final dio = Dio();
    dio.options.headers['X-TenantID'] = OPTIFOOD_DATABASE.toString();
    await dio.delete(ServerData.OPTIFOOD_BASE_URL+"/api/company/${serverId}").then((value){
    });
  }
  void updateCompanyServer(int? serverId) {
    final dio = Dio();
    dio.options.headers['X-TenantID'] = OPTIFOOD_DATABASE;
    CompanyDao().getCompanyByServerId(serverId!).then((value) async{
      var formData;
      //if(_image==null){
        formData = FormData.fromMap({
          'companyName': value!.name,
          'email': value.email,
          'phoneNumber': value.phoneNo,
          "address": value.address,
        });
      //}
     /* else{
        formData = FormData.fromMap({
          'companyName': value!.name,
          'email': value.email,
          'phoneNumber': value.phoneNo,
          "address": value.address,
          'image': MultipartFile.fromBytes(_image.readAsBytesSync(), filename: fileName),
        });
      }*/

      var response = await dio.put(ServerData.OPTIFOOD_BASE_URL+"/api/company/${serverId}",
        data: formData,
      ).then((value1){
      }).catchError((onError){

      });
    });
  }
}