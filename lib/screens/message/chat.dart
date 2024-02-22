//
// import 'dart:convert';
//
// import 'package:dio/dio.dart';
// import 'package:easy_localization/easy_localization.dart';
// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_svg/svg.dart';
// import 'package:stomp_dart_client/stomp.dart';
// import 'package:stomp_dart_client/stomp_config.dart';
// import 'package:stomp_dart_client/stomp_frame.dart';
//
// import '../../assets/images.dart';
// import '../../widgets/app_theme.dart';
//
// class Chat extends StatefulWidget {
//   Chat({ required this.title}) : super();
//
// final String title;
//
// @override
// _ChatState createState() => _ChatState();
// }
//
// class _ChatState extends MountedState<Chat> {
// StompClient? stompClient;
// final socketUrl = 'http://13.36.1.224:8092/ws-message';
// String message = '';
// TextEditingController messageController= new TextEditingController();
// void onConnect(StompClient client, StompFrame frame) {
// client.subscribe(
// destination: '/topic/message',
// callback: (StompFrame frame) {
// if (frame.body != null) {
// Map<String, dynamic> result = json.decode(frame.body);
// print(result['message']);
// setState(() => message = result['message']);
// }
// });
// }
//
// @override
// void initState() {
// super.initState();
//
// if (stompClient == null) {
// print("Creating connectionnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnn");
// stompClient = StompClient(
// config: StompConfig.SockJS(
// url: socketUrl,
// onConnect: onConnect,
// onWebSocketError: (dynamic error) => print("Creating connectionnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnn Afterrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrr"),
// ));
//
// stompClient!.activate();
// }
// }
//
// @override
// Widget build(BuildContext context) {
// return Scaffold(
// appBar: AppBar(
// title: Text(widget.title),
// ),
// body: Center(
// child: Stack(
//   children: <Widget>[
//       Container(
//         padding: EdgeInsets.only(left: 10, top: 200),
//         child: Text(
//         'Your message from server: $message',
//           style: TextStyle(fontSize: 18),
//         ),
//       ),
//       Align(
//       alignment: Alignment.bottomLeft,
//   child:
//   Container(
//   padding: EdgeInsets.only(left: 2, right: 1, bottom: 0, top: 0),
//   color: AppTheme.colorLightGrey,
//   child: Card(
//   child:
//   Container(
//   decoration: BoxDecoration(
//   color: Colors.white,
//   borderRadius: BorderRadius.circular(20),
//   ),
//   child: Row(
//   children: <Widget>[
//         GestureDetector(
//           onTap: () async{
//           },
//           child: Container(
//             padding: EdgeInsets.only(left: 10),
//             decoration: BoxDecoration(
//               borderRadius: BorderRadius.circular(0),
//             ),
//             child: Icon(Icons.add, color: AppTheme.colorRed, size: 30, ),
//           ),
//         ),
//         Container(
//           height: 55,
//           padding: EdgeInsets.only(left: 7,right: 12),
//           decoration: const BoxDecoration(
//             border: Border(right: BorderSide(color: AppTheme.colorGrey)),
//           ),
//           child: InkWell(
//               onTap: ()
//               {
//                 Navigator.pop(context);
//               },
//               child: Icon(Icons.keyboard_voice, color: AppTheme.colorRed, size: 25, )),
//         ),
//         SizedBox(width: 10,),
//         Expanded(
//             child: TextField(
//               controller: messageController,
//               decoration: InputDecoration(
//                   hintText: "writeMessage".tr()+"...",
//                   hintStyle: TextStyle(color: Colors.black54),
//                   border: InputBorder.none
//               ),
//             )
//         ),
//         SizedBox(width: 15,),
//         FloatingActionButton(
//           onPressed: (){
//             setState(() {
//               sendMessage();
//             });
//           },
//           child: SvgPicture.asset(AppImages.sendOrderIcon,
//             height: 30, color: AppTheme.colorRed,),
//           backgroundColor: Colors.white,
//           elevation: 0,
//         ),
//   ])))))
// ],
// ),
// ),
// );
// }
//
// @override
// void dispose() {
// if (stompClient != null) {
// stompClient!.deactivate();
// }
//
// super.dispose();
// }
//
// sendMessage() async {
//   final dio = Dio();
//   var data= {
//     "message": messageController.text,
//   };
//   var response = await dio.post('http://13.36.1.224:8092/send', data: data);
//   setState(() {
//     messageController.text="";
//   });
// }
// }