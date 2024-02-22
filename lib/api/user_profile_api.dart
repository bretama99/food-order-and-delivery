import 'package:dio/dio.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:fbroadcast/fbroadcast.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:opti_food_app/data_models/user_model.dart';
import 'package:opti_food_app/data_models/user_profile.dart';
import 'package:opti_food_app/database/user_dao.dart';
import '../../utils/constants.dart';
import '../main.dart';
import '../utils/utility.dart';
import '../widgets/app_theme.dart';
class UserProfileApis {
  static String OPTIFOOD_DATABASE=optifoodSharedPrefrence.getString("database").toString();
  static String authorization = optifoodSharedPrefrence.getString("accessToken").toString();
  static getUserFromServer(String userId) async{
    final dio = Dio();
    dio.options.headers['X-TenantID'] = OPTIFOOD_DATABASE;
    dio.options.headers['Authorization'] = authorization;
    await dio.get(ServerData.OPTIFOOD_BASE_URL+"/api/user/${userId}").then((response) async {
          var singleItem = UserProfileModel.fromJsonServer(response.data);
          var name=singleItem.firstName;
          if(singleItem.midddleName!="" && singleItem.midddleName!=null)
            name=name+" "+singleItem.midddleName;
          if(singleItem.lastName!="" && singleItem.lastName!=null)
            name=name+" "+singleItem.lastName;
          optifoodSharedPrefrence.setString("name", name);
          optifoodSharedPrefrence.setString("mobilePhone", singleItem.mobilePhone);
          optifoodSharedPrefrence.setString("email", singleItem.email);
          optifoodSharedPrefrence.setString("userId", singleItem.userId);
          optifoodSharedPrefrence.setInt("id", singleItem.id);
          optifoodSharedPrefrence.setString("userType", singleItem.userType);
          optifoodSharedPrefrence.setString("userStatus", singleItem.userStatus);
  });
}

 static updateProfile(UserProfileModel userProfileModel)async {
   final dio = Dio();
   dio.options.headers['X-TenantID'] = OPTIFOOD_DATABASE;
   dio.options.headers['Authorization'] = authorization;
   var data = {
      'firstName': userProfileModel.firstName,
      'middleName': userProfileModel.midddleName,
      'lastName': userProfileModel.lastName,
      'mobilePhone': userProfileModel.mobilePhone,
      'email': userProfileModel.email,
      'password': "",
      'userType': userProfileModel.userType,
      'userStatus': userProfileModel.userStatus,
      'restaurantId': 1,
    };
    dio.put(ServerData.OPTIFOOD_BASE_URL + '/api/user/${userProfileModel.userId}',
      data: data,
    ).then((response) async {


      Fluttertoast.showToast(
          msg: "savedSuccessfully".tr(),
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: AppTheme.colorGreen,
          textColor: Colors.white,
          fontSize: 16.0
      );
      var item = UserProfileModel.fromJsonServer(response.data);
      print("=================itemmmmmmmmm===============${item.firstName}================================");
      UserModel user = UserModel.fromJsonServer(response.data);
      print("=================userrrrrrrr===============${user.name}================================");

      await UserDao().updateUser(user).then((value){
        print("=================valueeeeee===============${value.name}================================");

      });
      FBroadcast.instance().broadcast(
          ConstantBroadcastKeys.KEY_UPDATE_UI);
      optifoodSharedPrefrence.setString("name", item.firstName+" "+item.midddleName+" "+item.lastName);
      optifoodSharedPrefrence.setString("mobilePhone", item.mobilePhone);
      optifoodSharedPrefrence.setString("email", item.email);
      optifoodSharedPrefrence.setString("userId", item.userId);
      optifoodSharedPrefrence.setString("userType", item.userType);
      optifoodSharedPrefrence.setString("userStatus", item.userStatus);
    }).catchError((err) async {

    });
  }

  static changePassword(String email, String oldPassword, String newPassword)async {
    final dio = Dio();
    dio.options.headers['Authorization'] = authorization;
    var data = {
      "email": email,
      "newPassword": newPassword,
      "oldPassword": oldPassword,
    };
    dio.put(ServerData.OPTIFOOD_BASE_URL + '/api/user/changepassword',
      data: data,
    ).then((response) async {
    }).catchError((err) async {
    });
  }

  static saveProfileImage(String fileName, var image)async {
    print("${ServerData.OPTIFOOD_BASE_URL}/api/user/uploadprofile");

    final dio = Dio();
    dio.options.headers['Authorization'] = authorization;
    var data = FormData.fromMap({
      "profilePicture": MultipartFile.fromBytes(
          image.readAsBytesSync(), filename: fileName),
      "userId": optifoodSharedPrefrence.getString("userId")
    });
    dio.post(ServerData.OPTIFOOD_BASE_URL + '/api/user/uploadprofile',
      data: data,
    ).then((response) async {
      print("Response: ${ServerData.OPTIFOOD_MANAGEMENT_BASE_URL}/api/user/uploadprofile");
    }).catchError((err) async {
    });
  }
}

