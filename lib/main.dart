import 'dart:ui';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:opti_food_app/screens/Order/ordered_lists.dart';
import 'package:opti_food_app/screens/authentication/envoyer.dart';
import 'package:opti_food_app/screens/authentication/login.dart';
import 'package:opti_food_app/screens/authentication/noti.dart';
import 'package:opti_food_app/screens/message/message_conversation.dart';
import 'package:opti_food_app/services/optifood_background_service.dart';
import 'package:opti_food_app/utils/constants.dart';
import 'package:opti_food_app/utils/utility.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'api/all_data_api.dart';
import 'api/login_api.dart';
import 'local_notifications.dart';
late SharedPreferences optifoodSharedPrefrence;
OptifoodBackgroundService optifoodBackgroundService = OptifoodBackgroundService();
final GlobalKey<NavigatorState> navigatorKey = new GlobalKey<NavigatorState>();

var stompClient;
late DatabaseReference databaseReference;
late DatabaseReference databaseReferenceForMessage;
late DatabaseReference databaseReferenceForUser;
//final socketUrl = "http://13.36.1.224:8092"+'/ws-message';
//MethodChannel platform = await MethodChannel('optifood.flutter.manager/print');
MethodChannel channelPrinting =  MethodChannel('optifood.flutter.manager/print');
Future<void>  main() async {

  // AwesomeNotifications().initialize(null, [
  //   NotificationChannel(
  //       channelKey: 'basic_channel',
  //       channelName: "Basic Notifications",
  //       channelDescription: "Notification channel for basic tests")
  // ], debug: true);
  var stompClient;
  WidgetsFlutterBinding.ensureInitialized();
  //LocalNotifications.init();
  await Firebase.initializeApp();
  await EasyLocalization.ensureInitialized();
  // Noti().initNotification();
  SharedPreferences.getInstance().then((value){
    optifoodSharedPrefrence = value;
    initFirebaseDatabase();
    FlutterError.onError = (errorDetails) {
      FirebaseCrashlytics.instance.recordFlutterFatalError(errorDetails);
    };
    // Pass all uncaught asynchronous errors that aren't handled by the Flutter framework to Crashlytics
    PlatformDispatcher.instance.onError = (error, stack) {
      FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
      return true;
    };
    runApp(
        EasyLocalization(
          child: MyApp(), supportedLocales: const [
      Locale("en","EN"),
      Locale("fr","FR"),
      Locale("de","DE"),
      Locale("es","ES"),
      Locale("it","IT"),
      Locale("nl","NL"),
      Locale("pt","PT")
   ],
      path: "assets/translations", saveLocale: true,
          fallbackLocale: Locale("fr","FR"),)
    );
    //channelPrinting.invokeMethod('connectPrinter', {'mac': optifoodSharedPrefrence.getString(ConstantSharedPreferenceKeys.KEY_PRINTER_MAC_ADDRESS)});
  });

  ////////////// User Notification//////////////////////////////////////////////////////////////////////////////////////////


  // databaseReferenceForMessage = FirebaseDatabase.instance.ref("message_notification");
  // databaseReferenceForMessage.onValue.listen((event) {
  //   if(optifoodSharedPrefrence.getString(ConstantSharedPreferenceKeys.KEY_FIREBASE_TIMESTAMP)==null||
  //       optifoodSharedPrefrence.getString(ConstantSharedPreferenceKeys.KEY_FIREBASE_TIMESTAMP)!=
  //           event.snapshot.value.toString()){
  //
  //     print(optifoodSharedPrefrence.getString(ConstantSharedPreferenceKeys.KEY_FIREBASE_TIMESTAMP));
  //     if(optifoodSharedPrefrence.getString(ConstantSharedPreferenceKeys.KEY_FIREBASE_TIMESTAMP)==null){
  //       optifoodSharedPrefrence.setString(ConstantSharedPreferenceKeys.KEY_FIREBASE_TIMESTAMP,event.snapshot.value.toString());
  //     }
  //     AllDataApis.getMessages(optifoodSharedPrefrence.getString(ConstantSharedPreferenceKeys.KEY_FIREBASE_TIMESTAMP));
  //     optifoodSharedPrefrence.setString(ConstantSharedPreferenceKeys.KEY_FIREBASE_TIMESTAMP, event.snapshot.value.toString());
  //
  //   }
  //   else{
  //     print("Not calling api");
  //   }
  // });


}
void initFirebaseDatabase(){
  if(optifoodSharedPrefrence.getString("database")==null){
    return;
  }
  databaseReferenceForUser = FirebaseDatabase.instance.ref("user_notification");
  databaseReferenceForUser.onValue.listen((event) {
    if(event.snapshot.value.toString().contains("message")) {
      var userId = optifoodSharedPrefrence.getString("userId");
      print("User idddddddddddddddddddddddddddddddddddddddddddd: ${userId.toString().length}");
      print(userId);print("Use id from serverrrrrrrrrrrrrrrrrrrrr: ${event.snapshot.value.toString().split("message:")[1].split("}")[0].replaceAll(' ', '').length}");
      if (userId.toString()==event.snapshot.value.toString().split("message:")[1].split("}")[0].toString().replaceAll(' ', '')){
        print(userId);print("Use id metchessssssssssssssssssssssssssssssssssss");
        LoginApi().logoutApi(callback: (){
          navigatorKey.currentState?.push(MaterialPageRoute(builder: (_) => LoginPage()));
        });
      }
    }
  });


  databaseReference = FirebaseDatabase.instance.ref(optifoodSharedPrefrence.getString("database").toString()+"/notification");
  databaseReference.onValue.listen((event) {
    print("NEW NOTIFICATION");
    Utility().showToastMessage("NEW NOTIFICATION");
    if(optifoodSharedPrefrence.getString(ConstantSharedPreferenceKeys.KEY_FIREBASE_TIMESTAMP)==null||
        optifoodSharedPrefrence.getString(ConstantSharedPreferenceKeys.KEY_FIREBASE_TIMESTAMP)!=
            event.snapshot.value.toString()){

      if(optifoodSharedPrefrence.getString(ConstantSharedPreferenceKeys.KEY_FIREBASE_TIMESTAMP)==null){
        print(optifoodSharedPrefrence.getString(ConstantSharedPreferenceKeys.KEY_FIREBASE_TIMESTAMP));

        optifoodSharedPrefrence.setString(ConstantSharedPreferenceKeys.KEY_FIREBASE_TIMESTAMP,event.snapshot.value.toString());
      }
      //AllDataApis.getAllDataFromServer(optifoodSharedPrefrence.getString(ConstantSharedPreferenceKeys.KEY_FIREBASE_TIMESTAMP),event.snapshot.value.toString());
      AllDataApis.getAllDataFromServer(optifoodSharedPrefrence.getString(ConstantSharedPreferenceKeys.KEY_FIREBASE_TIMESTAMP)!,event.snapshot.value.toString());
      optifoodSharedPrefrence.setString(ConstantSharedPreferenceKeys.KEY_FIREBASE_TIMESTAMP, event.snapshot.value.toString());
    }
    else{
      print("Not calling api");
    }
  });
}
class MyApp extends StatelessWidget  {
  @override
  Widget build(BuildContext context) {
    Map<int,Color> color = {
      50: Color.fromRGBO(136, 14, 79, 1),
      100: Color.fromRGBO(136, 14, 79, 1),
      200: Color.fromRGBO(136, 14, 79, 1),
      300: Color.fromRGBO(136, 14, 79, 1),
      400: Color.fromRGBO(136, 14, 79, 1),
      500: Color.fromRGBO(136, 14, 79, 1),
      600: Color.fromRGBO(136, 14, 79, 1),
      700: Color.fromRGBO(136, 14, 79, 1),
      800: Color.fromRGBO(136, 14, 79, 1),
      900: Color.fromRGBO(136, 14, 79, 1),
    };
    return  MaterialApp(
      navigatorKey: navigatorKey,
      localizationsDelegates: context.localizationDelegates,
      supportedLocales: context.supportedLocales,
      locale: context.locale,
      theme: ThemeData(
        useMaterial3: false,
          primarySwatch: MaterialColor(0xffdb1e24,color),

      ),
      debugShowCheckedModeBanner: false,
      initialRoute:
      optifoodSharedPrefrence.getString('accessToken')!=null?'/order-list':
      optifoodSharedPrefrence.getString('database')!=null?'/login':'/envoyer',
      routes: {
        '/envoyer': (context) => EnvoyerPage(),
        '/login': (context) => LoginPage(),
        '/order-list': (context) => OrderedList(),
        '/messages': (context) => MessageConversation(),
      },

    );

  }

}
