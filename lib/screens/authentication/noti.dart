import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:opti_food_app/screens/message/message_conversation.dart';

class Noti{
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  Future<void> initNotification() async {
    AndroidInitializationSettings androidInitialize = const AndroidInitializationSettings('mipmap/ic_launcher');
    // var iOSInitialize = new IOSInitializationSettings();
    DarwinInitializationSettings initializationIos = DarwinInitializationSettings(
requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
        onDidReceiveLocalNotification: (id,title,body,payload){

    }
    );
    InitializationSettings initializationSettings = InitializationSettings(
      android:androidInitialize,
      iOS: initializationIos
    );

    await flutterLocalNotificationsPlugin.initialize(initializationSettings, onDidReceiveNotificationResponse:
    onSelectNotification);
    var initializationsSettings = new InitializationSettings(android: androidInitialize);

    await flutterLocalNotificationsPlugin.initialize(initializationsSettings );
  }

  onSelectNotification(NotificationResponse notificationResponse) async {
print("on clik notificatioooooooooooooooooooooooooooooon");
    // var payloadData = jsonDecode(notificationResponse.payload);
    // print("payload $payload");
      Navigator.of(navigatorKey.currentContext!).push(
          MaterialPageRoute(
              builder: (context) =>
                  MessageConversation()));

  }
  Future<void> simpleNotificationShow(var username, var message, var id) async {
    AndroidNotificationDetails androidNotificationDetails = AndroidNotificationDetails(
      'channel_id',
      'channel_title',
      priority: Priority.high,
      importance: Importance.max,
      icon:'mipmap/ic_launcher',
      channelShowBadge: true,
      largeIcon: DrawableResourceAndroidBitmap('mipmap/ic_launcher')
    );
    NotificationDetails notificationDetails = NotificationDetails(android: androidNotificationDetails);
    await flutterLocalNotificationsPlugin.show(id, "Optifood App Notification", "$username  $message", notificationDetails);

  }
  // static Future showBigTextNotification({var id =0,required String title, required String body,
  //   var payload, required FlutterLocalNotificationsPlugin fln
  // } ) async {
  //   AndroidNotificationDetails androidPlatformChannelSpecifics =
  //   new AndroidNotificationDetails(
  //     'you_can_name_it_whatever1',
  //     'channel_name',
  //
  //     playSound: true,
  //     sound: RawResourceAndroidNotificationSound('notification'),
  //     importance: Importance.max,
  //     priority: Priority.high,
  //   );
  //
  //   var not= NotificationDetails(android: androidPlatformChannelSpecifics
  //   );
  //   await fln.show(0, title, body,not );
  // }

}
