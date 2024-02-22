import 'package:flutter/material.dart';
import 'package:opti_food_app/database/food_items_dao.dart';

import '../database/attribute_dao.dart';
import '../database/order_dao.dart';

class LoginResponseModel{
  String accessToken;
  String userId;
  String userType;
  String userStatus;
  int id;

  LoginResponseModel(this.accessToken, this.userId, this.userType, this.userStatus, this.id);

  LoginResponseModel.clone(LoginResponseModel loginModel): this(
    loginModel.accessToken,
    loginModel.userId,
    loginModel.userType,
    loginModel.userStatus,
    loginModel.id
  );
  factory LoginResponseModel.fromJson(Map<String, dynamic> json) => LoginResponseModel(
    json["accessToken"],
    json["userId"],
    json["userType"],
    json["userStatus"],
    json["id"],
  );

  Map<String, dynamic> toJson() => {
    'accessToken': accessToken,
    'userId': userId,
    'userType': userType,
    'userStatus': userStatus,
    'id':id
  };

}