import 'package:flutter/foundation.dart';
import 'package:opti_food_app/database/user_dao.dart';

class UserProfileModel{
  int id;
  String userId;
  String firstName;
  String midddleName;
  String lastName;
  String mobilePhone;
  String email;
  String userType;
  String userStatus;
  String userProfile;


  UserProfileModel(
      this.id, this.userId, this.firstName, this.midddleName, this.lastName,
      this.mobilePhone, this.email, this.userType, this.userStatus, this.userProfile
      );


  factory UserProfileModel.fromJsonServer(Map<String, dynamic> json){
    return UserProfileModel(
        json['id'],
        json['userId'],
        json['firstName'],
        json['middleName'],
        json['lastName'],
        json['mobilePhone'],
        json['email'],
        json['userType']!=null?json['userType']:"",
        "",//json['userStatus'],
        "",//json['userProfile'],
    );
  }

}