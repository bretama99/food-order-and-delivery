import 'package:dio/dio.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:opti_food_app/data_models/login_response_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../data_models/login_model.dart';
import '../database/order_dao.dart';
import '../main.dart';
import '../utils/constants.dart';
import '../utils/utility.dart';

class LoginApi{
  static String OPTIFOOD_MANAGEMENT_DATABASE='optifood_management';
  String OPTIFOOD_DATABASE=optifoodSharedPrefrence.getString("database").toString();
  Function? callBack;
  LoginApi({this.callBack});
  void loginFromServer(LoginModel loginModel)async{
    final dio = Dio();
    dio.options.headers['X-TenantID'] = OPTIFOOD_DATABASE;
    var data= {
      "email": loginModel.email,
      "password": loginModel.password
    };
    print(OPTIFOOD_DATABASE);
    print(data);
    var response = await dio.post(ServerData.OPTIFOOD_BASE_URL+'/api/user/login',
      data: data,
    ).then((response) {
        var loginResponseModel = LoginResponseModel.fromJson(response.data);
        optifoodSharedPrefrence.setString("accessToken", loginResponseModel.accessToken);
        optifoodSharedPrefrence.setString("userId", loginResponseModel.userId);
        optifoodSharedPrefrence.setString("userType", loginResponseModel.userType);
        optifoodSharedPrefrence.setString("userStatus", loginResponseModel.userStatus);
        optifoodSharedPrefrence.setInt("id", loginResponseModel.id);
        callBack!(loginResponseModel);
    }).catchError((e){
      Utility().showToastMessage("Check your email and password".tr());
    });
  }



  void getTanatInformation(String licenseKey, {Function? callback = null})async{
    final dio = Dio();
    dio.options.headers['X-TenantID'] = OPTIFOOD_MANAGEMENT_DATABASE;
    var response = await dio.get(ServerData.OPTIFOOD_MANAGEMENT_BASE_URL+'/api/restaurant/get-by-license-key/'+licenseKey,
    ).then((response) {
      optifoodSharedPrefrence.setString("database", response.data['database']);
      initFirebaseDatabase();
      if(callback!=null){
        callback();
      }
    }).catchError((e){
      Utility().showToastMessage("Check your license key".tr());
    });
  }


  void logoutApi({Function? callback = null})async{
    final dio = Dio();
    dio.options.headers['Authorization'] = optifoodSharedPrefrence.getString("accessToken").toString();
    dio.options.headers['X-TenantID'] = OPTIFOOD_DATABASE;
    var response = await dio.post("${ServerData.OPTIFOOD_BASE_URL}/api/user/logout",
    ).then((response) {
      SharedPreferences.getInstance().then((value) {
        value.remove("accessToken");
        value.remove("userId");
        value.remove("userType");
        value.remove("userStatus");
        value.remove("name");
        value.remove("email");
        value.remove("mobilePhone");
        OrderDao().getAllOrders().then((value1){
          for(int i=0; i<value1.length; i++){
            OrderDao().delete(value1[i]);
          }
        });
        callback!();
      });
    }).catchError((e){
    });
  }

  checkLogInCount(String email, {Function? callback = null})async{
    final dio = Dio();
    dio.options.headers['X-TenantID'] = OPTIFOOD_DATABASE;
    print("${ServerData.OPTIFOOD_BASE_URL}/api/user/check-if-alreardy-logi?email="+email);
    var response = await dio.get("${ServerData.OPTIFOOD_BASE_URL}/api/user/check-if-alreardy-login?email="+email).then((response) {
      callback!(int.parse(response.toString()));
    }).catchError((e){
      Utility().showToastMessage("Something went wrongaaaaaaaaaaaaa!".tr());
    });
  }


  sendNotification(String email, {Function? callback = null})async{
    final dio = Dio();
    dio.options.headers['X-TenantID'] = OPTIFOOD_DATABASE;
    var response = await dio.get("${ServerData.OPTIFOOD_BASE_URL}/api/user/send-notification?email="+email).then((response) {
      callback!();
    }).catchError((e){
      Utility().showToastMessage("Something went wrongaaaaaaaaaaaaa!".tr());
    });
  }
}


