import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:opti_food_app/screens/authentication/login.dart';
import 'package:opti_food_app/screens/order/ordered_lists.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../api/delivery_fee.dart';
import '../../api/login_api.dart';
import '../../api/night_mode_fee.dart';
import '../../assets/images.dart';
import '../../main.dart';
import '../MountedState.dart';
class EnvoyerPage extends StatefulWidget {
  const EnvoyerPage({Key? key}) : super(key: key);
  @override
  State<EnvoyerPage> createState() => _EnvoyerPageState();
}

class _EnvoyerPageState extends MountedState<EnvoyerPage> {
  final GlobalKey<FormState> _globalKey = GlobalKey<FormState>();
  TextEditingController licenseController = TextEditingController();
  var accessToken="";

  @override
  void initState() {

    // AwesomeNotifications().isNotificationAllowed().then((isAllowed){
    //
    //   if(!isAllowed){
    //     AwesomeNotifications().requestPermissionToSendNotifications();
    //   }
    // });
    DeliveryFeeApi.getDeliveryFeeFromServer();
    NightModeFeeApi.getNightModeFeeFromServer();
    //CustomerApis.getCustomerFromServer();
    //ProductApis.getFoodItemsListFromServer();
    //ProductApis.getAttributeCategoryListFromServer();
    //ProductApis.getFoodCategoryListFromServer();
    //ProductApis.getAttributeListFromServer();
    //RestaurantApis.getRestaurantInfoFromServer();
    //MessageApis.getMessageListFromServer();
    //UserApis.getUserListFromServer();
    //CompanyApis.getCompanyListFromServer();
    //OrderApis.getOrderListFromServer(oncall1: (String s){
    //});
    checkIfLoggedInAndTokenNotExpired();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
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
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10)
              ),
              child: Column(
                children: [
                  Container(
                    alignment: Alignment.bottomCenter,
                    child: Image.asset(AppImages.logoIcon, height: 150),
                  ),
                  Form(
                      key: _globalKey,
                      child: Column(
                        children: [

                          Container(
                            margin: const EdgeInsets.fromLTRB(20, 8, 20, 0),
                            child: TextFormField(
                              controller: licenseController,
                              decoration: InputDecoration(
                                enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10)),
                                contentPadding: EdgeInsets.symmetric(
                                    vertical: 14, horizontal: 10),
                                labelText: "enterYourLisenceKey".tr(),
                                border: const OutlineInputBorder(
                                    borderSide: BorderSide(

                                        width: 0.1, color: Colors.black)
                                ),

                              ),

                            ),
                          ),
                          const SizedBox(height: 10),
                          Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: Container(
                              child: Text("A8:DB:03:0A:DB:C4",
                                style: TextStyle(fontSize: 18),),
                            ),
                          ),
                          ButtonTheme(
                            minWidth: 110.0,
                            height: 43.0,
                            //child: RaisedButton(onPressed: () {
                            child: ElevatedButton(onPressed: () {
                              login(context);
                              //channelPrinting.invokeMethod('updateApp');
                              },
                              child: const Text("envoyer",
                                style: TextStyle(color: Colors.white),).tr(),
                              // elevation: 10.0,
                              style: ElevatedButton.styleFrom(
                                  surfaceTintColor: Colors.transparent,
                                  backgroundColor: Colors.black,
                                  shape: RoundedRectangleBorder(
                                    borderRadius:
                                    BorderRadius.circular(8.0),
                                  )
                              ),
                              //color: Colors.black,
                              /*shape: RoundedRectangleBorder(
                                borderRadius:
                                BorderRadius.circular(8.0),
                              ),*/
                            ),
                          ),


                          const TextButton(onPressed: null,
                              child: Text("",
                                style: TextStyle(fontSize: 16),
                              )),


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

  void _updateAppFromURL() async {
    const updateURL = 'https://optifood.s3.eu-west-3.amazonaws.com/app-debug.apk';
    if (await canLaunch(updateURL)) {
      await launch(updateURL);
    } else {
      throw 'Could not launch $updateURL';
    }
  }

  checkIfLoggedInAndTokenNotExpired(){
  SharedPreferences.getInstance().then((value) {
    accessToken = value.getString("accessToken")!;
    var userType= value.getString("userType")!;
    if(accessToken!=null && accessToken!=""){
      if(userType=='Admin')
        Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => OrderedList()));
      else if(userType=='Manager')
        Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => OrderedList()));
    }
  });
}



void login(BuildContext context){
  optifoodSharedPrefrence.setString('lisenceKey', licenseController.text);
  LoginApi().getTanatInformation(licenseController.text, callback: (){
    print("Call backkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkk");
    Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => LoginPage()));
  });
}
}










