import 'dart:async';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:opti_food_app/api/login_api.dart';
import 'package:opti_food_app/api/product.dart';
import 'package:opti_food_app/api/user_profile_api.dart';
import 'package:opti_food_app/data_models/login_model.dart';
import 'package:opti_food_app/data_models/login_response_model.dart';
import 'package:opti_food_app/database/attribute_category_dao.dart';
import 'package:opti_food_app/database/attribute_dao.dart';
import 'package:opti_food_app/database/food_category_dao.dart';
import 'package:opti_food_app/database/food_items_dao.dart';
import 'package:opti_food_app/screens/message/message_conversation.dart';
import 'package:opti_food_app/screens/order/ordered_lists.dart';
import 'package:opti_food_app/screens/splash_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../assets/images.dart';
import '../../local_notifications.dart';
import '../../widgets/app_theme.dart';
import '../../widgets/custom_field.dart';
import 'package:wifi_configuration_2/wifi_configuration_2.dart';

import '../../widgets/popup/alert_popup/alert_popup.dart';
import '../../widgets/popup/confirmation_popup/confirmation_popup.dart';
import '../../widgets/popup/input_popup/input_popup.dart';
import '../MountedState.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends MountedState<LoginPage> {
  late ProductApis apis;
  WifiConfiguration wifiConfiguration = WifiConfiguration();
  var allowedPrivileges=[];
  @override
  void initState(){
    /*OrderApis.getOrderListFromServer(oncall1: (String s){
      UserApis.getUserListFromServer();
    });*/
    listenToNotifications();
    checkIfLoggedInAndTokenNotExpired();
  }

  //  to listen to any notification clicked or not
  listenToNotifications() {
    print("mmmmListening to notification");
    LocalNotifications.onClickNotification.stream.listen((event) {

      // Navigator.push(context,
      //     MaterialPageRoute(builder: (context) => MessageConversation(payload: event)));
      // Navigator.pop(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    final isLandscape = MediaQuery.of(context).orientation == Orientation.landscape;
    return Scaffold(
      body: Container(
        decoration:const BoxDecoration(
            image: DecorationImage(
              image: AssetImage(AppImages.orderTakingOptiFoodIcon),
              fit: BoxFit.cover,
            )
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              margin: const EdgeInsets.fromLTRB(40, 0, 40, 0),
              // const EdgeInsets.fromLTRB(40, 0, 40, 0),
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10)
              ),

              child: Column(
                children: [
                  Container(
                    margin: EdgeInsets.fromLTRB(40, 0, 40, 0),
                    color: Colors.white,
                    alignment: Alignment.bottomCenter,
                      child: Image.asset(AppImages.logoIcon, height: 150),
                  ),
              Form(
                  key: _globalKey,
                  child: Column(
                    children: [
                      CustomField(
                        data: Icons.email,
                        controller: emailController,
                        hintText: "email".tr(),
                        isObsecre: false,
                        callBack: (){
                          setState(() {
                            emailController.text=emailController.text.toLowerCase();
                            emailController.selection = TextSelection.fromPosition(TextPosition(offset: emailController.text.length));
                          });
                        },
                      ),
                      CustomField(
                        data: Icons.lock,
                        controller: passwordController,
                        hintText: "password".tr(),
                        isObsecre: true,
                      ),
                      ButtonTheme(
                        minWidth: 110.0,
                        height: 43.0,
                        //child: RaisedButton(onPressed: (){
                        child: ElevatedButton(onPressed: (){
                          login(context);
                          // _trackMe();
                        },
                          style: ElevatedButton.styleFrom(
                              surfaceTintColor: Colors.transparent,
                            backgroundColor: Colors.black,
                            shape: RoundedRectangleBorder(
                              borderRadius:
                              BorderRadius.circular(8.0),
                            )
                          ),
                          /*color: Colors.black,
                          shape: RoundedRectangleBorder(
                            borderRadius:
                            BorderRadius.circular(8.0),
                          ),*/
                          child: const Text("login", style: TextStyle(color: Colors.white),).tr(),
                        ),
                      ),
                      TextButton(onPressed: null,
                          child: Text("forgotPassword",
                            style: TextStyle(fontSize: 16),
                          ).tr())
                    ],
                  )
              ),
      ],
    ),
            ),
          ],
        ),
      ),
    );
  }

  // Future<void> _trackMe() async{
  //
  //   Timer.periodic(Duration(seconds: 3), (timer) async{
  //     Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
  //     print("=====================longitude=${position.longitude}=====================");
  //     print("=========latitude==${position.latitude}================");
  //   });
  // }
  final GlobalKey<FormState> _globalKey = GlobalKey<FormState>();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  Future<void> insertDataNosql()
  async {
    FoodCategoryDao foodCategoryDao = FoodCategoryDao();
    FoodItemsDao foodItemsDao = FoodItemsDao();
    AttributeCategoryDao attributeCategoryDao = AttributeCategoryDao();
    AttributeDao attributeDao = AttributeDao();
    List cat = await foodCategoryDao.getAllFoodCategories();
    if(cat.length>0)
      {
        return;
      }

  }

  login(BuildContext context){
    LoginModel loginModel=LoginModel(emailController.text, passwordController.text);
    /*LoginApi().checkLogInCount(emailController.text, callback: (int loginCount){
      if(loginCount>0){
        LoginApi().sendNotification(emailController.text, callback: (){
          LoginApi(callBack: (LoginResponseModel loginResponseModel) {
            UserProfileApis.getUserFromServer(loginResponseModel.userId);
            if (loginResponseModel.userType == 'Admin' ||
                loginResponseModel.userType == 'Manager' ||
                loginResponseModel.userType == 'user_role_manager')
              Navigator.of(context).push(MaterialPageRoute(builder:
                  (context) =>
                  SplashScreen()));
          }).loginFromServer(loginModel);
        });
      }
      else {
        LoginApi(callBack: (LoginResponseModel loginResponseModel) {
          UserProfileApis.getUserFromServer(loginResponseModel.userId);
          if (loginResponseModel.userType == 'Admin' ||
              loginResponseModel.userType == 'Manager' ||
              loginResponseModel.userType == 'user_role_manager')
            Navigator.of(context).push(MaterialPageRoute(builder:
                (context) =>
                SplashScreen()));
        }).loginFromServer(loginModel);
      }
    });*/
    LoginApi(callBack: (LoginResponseModel loginResponseModel) {
      UserProfileApis.getUserFromServer(loginResponseModel.userId);
      if (loginResponseModel.userType == 'Admin' ||
          loginResponseModel.userType == 'Manager' ||
          loginResponseModel.userType == 'user_role_manager')
        Navigator.of(context).push(MaterialPageRoute(builder:
            (context) =>
            SplashScreen()));
    }).loginFromServer(loginModel);

  }

  showAlertDialog(BuildContext context) {
    // set up the button
    //Widget okButton = FlatButton(
    Widget okButton = TextButton(
      child: Text("OK"),
      onPressed: () {
        LoginModel loginModel=LoginModel(emailController.text, passwordController.text);
        LoginApi(callBack: (LoginResponseModel loginResponseModel){
          UserProfileApis.getUserFromServer(loginResponseModel.userId);
          if(loginResponseModel.userType=='Admin' || loginResponseModel.userType=='Manager' || loginResponseModel.userType=='user_role_manager')
            Navigator.of(context).push(MaterialPageRoute(builder:
                (context) =>
                SplashScreen()));
        }).loginFromServer(loginModel);
      },
    );
    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text("Confirmation"),
      content: Text("You have already login on other device.\n Do you want to login?"),
      actions: [
        okButton,
      ],
    );
    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  checkIfLoggedInAndTokenNotExpired(){
    SharedPreferences.getInstance().then((value) {
      var accessToken = value.getString("accessToken");
      var userType = value.getString("userType");
      if(accessToken!=null && accessToken!="") {
        if (userType == 'Admin') {
          Navigator.of(context).push(MaterialPageRoute(builder:
              (context) =>
              OrderedList()));
        }
        else if (userType == 'Manager' || userType=='user_role_manager') {
          Navigator.of(context).push(MaterialPageRoute(builder:
              (context) =>
              OrderedList()));
        }
      }
    });
  }
}