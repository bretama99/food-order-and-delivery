import 'package:flutter/material.dart';
import 'package:opti_food_app/database/food_items_dao.dart';

import '../database/attribute_dao.dart';
import '../database/order_dao.dart';

class LoginModel{
  String email;
  String password;

  LoginModel(this.email,this.password);

  LoginModel.clone(LoginModel loginModel): this(
    loginModel.email,
    loginModel.password,
  );
  factory LoginModel.fromJson(Map<String, dynamic> json) => LoginModel(
      json["email"],
      json["password"],

  );

  Map<String, dynamic> toJson() => {
    'username': email,
    'password': password,
  };

}