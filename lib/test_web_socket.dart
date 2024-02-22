import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:stomp_dart_client/stomp.dart';
import 'package:stomp_dart_client/stomp_config.dart';
import 'package:stomp_dart_client/stomp_frame.dart';
import '../../assets/images.dart';
import '../../main.dart';
/*class TestWebSocket extends StatefulWidget {
  const TestWebSocket({Key? key}) : super(key: key);
  @override
  State<TestWebSocket> createState() => _TestWebSocketState();
}

class _TestWebSocketState extends MountedState<TestWebSocket> {
  TextEditingController licenseController = TextEditingController();
  var accessToken="";
  String message="tttttttttttttttttt";
  var stompClient=null;
  @override
  void initState() {
    if (stompClient == null) {
      print("Connectedddddddddd");
      stompClient = StompClient(
          config: StompConfig.SockJS(
              url: socketUrl,
              onConnect: onConnect,
              onWebSocketError: (dynamic error) => print(error)
          ));
      stompClient!.activate();
    }
  }

  void onConnect(StompFrame frame) {
    stompClient.subscribe(
      destination: '/topic/hello',
      callback: (frame) {
        print("SSSSSSSSSSXXXXXXXXXXXXXXXXXXXXXX");
        var result = json.decode(frame.body!);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body:
      Padding(padding: EdgeInsets.only(top: 50),child: Text(message)));
  }



}*/










