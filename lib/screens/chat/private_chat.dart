import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:opti_food_app/data_models/private_chat_model.dart';
import 'package:opti_food_app/data_models/user_model.dart';
import 'package:opti_food_app/database/private_chat_dao.dart';
import 'package:opti_food_app/screens/message/message_list.dart';
import 'package:opti_food_app/utils/constants.dart';
import 'package:stomp_dart_client/stomp.dart';
import 'package:stomp_dart_client/stomp_config.dart';
import 'package:stomp_dart_client/stomp_frame.dart';
import '../../assets/images.dart';
import '../../main.dart';
import '../MountedState.dart';
import '../message/message_model.dart';
import '../../widgets/app_theme.dart';
import '../../widgets/appbar/app_bar_optifood.dart';
class PrivateChat extends StatefulWidget{
  UserModel? user;
  PrivateChat({Key? key, this.user}) : super(key: key);
  @override
  _PrivateChatState createState() => _PrivateChatState();
}

class _PrivateChatState extends MountedState<PrivateChat> {
  final socketUrl = ServerData.OPTIFOOD_MANAGEMENT_BASE_URL+'/ws-message';
  String message = '';
  TextEditingController messageController= new TextEditingController();
  String userImagePlaceHolder = "assets/svg/icons/settings/delivery_boy.svg";
  List<MessageModel> messages = [];
  List<PrivateChatModel> privateChatMessages = [];
  var senderId, receiverId, name;
  var stompClient;
  @override
   initState() {
    senderId =int.parse(optifoodSharedPrefrence.getString('id').toString());
    name=widget.user!.name;
    receiverId = widget.user!.intServerId;
      getPrivateChatMessages();
    super.initState();
    /*if (stompClient == null) {
      stompClient = StompClient(
          config: StompConfig.SockJS(
            url: socketUrl,
            onConnect: onConnect,
            onWebSocketError: (dynamic error) => print(error)
          ));
      stompClient!.activate();
    }*/
  }
  @override
  void dispose() {
    super.dispose();
  }

  // @override
  // void setState(fn) {
  //   if(mounted) {
  //     super.setState(fn);
  //   }
  // }

static aa(){}
  @override
  Widget build(BuildContext context) {
    PreferredSizeWidget appBarWidget = AppBarOptifood(content: [
      SizedBox(width: 10,),
      CircleAvatar(
        backgroundImage: NetworkImage("http://13.36.1.224/user_profiles/wkBRTmVQp8n2XTc9e7gDH4GPJVTLMu."),
          backgroundColor: Colors.grey,
          radius: 22,
      ),
      Transform.translate(
          offset: Offset(-18, 14),
          child: Container(
          width: 10,
          height: 10,
          margin: EdgeInsets.all(5),
          decoration: BoxDecoration(
          color: AppTheme.colorGreen,
          shape: BoxShape.circle),)),
          Text(name.toUpperCase(), style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),)
    ],);
    return Scaffold(
      appBar: appBarWidget,
      body: Stack(
        children: <Widget>[
          Padding(
            padding: EdgeInsets.only(bottom: 45),
            child: SingleChildScrollView(
              scrollDirection: Axis.vertical,
              reverse: true,
              child:
              ListView.builder(
                itemCount: privateChatMessages.length,
                shrinkWrap: true,
                padding: EdgeInsets.only(top: 0,bottom: 10),
                physics: NeverScrollableScrollPhysics(),
                itemBuilder: (context, index){
                  return
                    Column(
                        children:[
                          if(index==0 || (index>0 && privateChatMessages[index].createdAt.split(" ")[0]!=privateChatMessages[index-1].createdAt.split(" ")[0]))
                            Row(
                              children: [
                                Container(
                                  padding: EdgeInsets.only(left: 20, right: 20, top: 10, bottom: 10),
                                  width: MediaQuery.of(context).size.width*0.37,
                                  child: Divider(
                                    color: AppTheme.colorGrey,
                                    thickness: 0.5,
                                  ),
                                ),
                                Container(
                                  width: MediaQuery.of(context).size.width*0.25,
                                  padding: EdgeInsets.only(top: 10, bottom: 10),
                                  child:
                                  Align(
                                    alignment: Alignment.center,
                                    child: Text("${privateChatMessages[index].createdAt.split(" ")[0]}"),
                                  ),
                                ),
                                Container(
                                  padding: EdgeInsets.only(left: 20, right: 20, top: 10, bottom: 10),
                                  width: MediaQuery.of(context).size.width*0.37,
                                  child: Divider(
                                    color: AppTheme.colorGrey,
                                    thickness: 0.5,
                                  ),
                                )
                              ],
                            ),

                          Container(
                            padding: EdgeInsets.only(
                                left: (privateChatMessages[index].createdAt != senderId ? 30:14),
                                right: (privateChatMessages[index].senderId == senderId?14:30),
                                top: 10,bottom: 10),
                            child: Align(
                              alignment: (privateChatMessages[index].senderId !=senderId ?Alignment.topLeft:Alignment.topRight),
                              child: Container(
                                width: MediaQuery.of(context).size.width*0.80,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8),
                                  color: (privateChatMessages[index].senderId !=senderId ?AppTheme.colorLightGrey:AppTheme.colorDarkGrey),
                                ),
                                padding: EdgeInsets.all(8),
                                child:
                                Column(
                                    children: [
                                      Align(
                                        alignment: Alignment.centerLeft,
                                        child: Text(privateChatMessages[index].message,textAlign: TextAlign.left , style: TextStyle(fontSize: 15,
                                            color: privateChatMessages[index].senderId !=senderId ?Colors.black:Colors.white),),
                                      ),
                                      Align(
                                        alignment: Alignment.bottomRight,
                                        child: Text(privateChatMessages[index].createdAt.split(" ")[1].substring(0,5), style: TextStyle(
                                            color: privateChatMessages[index].senderId != 1?Colors.black:Colors.white
                                        ),),
                                      )
                                    ]),
                              ),
                            ),
                          ),

                        ]
                    );
                },
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomLeft,
            child:
            Container(
              padding: EdgeInsets.only(left: 2, right: 1, bottom: 0, top: 0),
              color: AppTheme.colorLightGrey,
              child: Card(
                color: Colors.white,
                surfaceTintColor: Colors.transparent,
                child:
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: <Widget>[
                      GestureDetector(
                        onTap: () async{
                          await Navigator.of(context).push(MaterialPageRoute(builder:
                              (context)=>MessageList(
                            isFromMessageConversation: true,
                            onCallback: (String message){
                              this.messageController.text=message;
                            },
                          )));
                        },
                        child: Container(
                          padding: EdgeInsets.only(left: 10),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(0),
                          ),
                          child: Icon(Icons.add, color: AppTheme.colorRed, size: 30, ),
                        ),
                      ),
                      Container(
                        height: 55,
                        padding: EdgeInsets.only(left: 7,right: 12),
                        decoration: const BoxDecoration(
                          border: Border(right: BorderSide(color: AppTheme.colorGrey)),
                        ),
                        child: InkWell(
                            onTap: ()
                            {
                              Navigator.pop(context);
                            },
                            child: Icon(Icons.keyboard_voice, color: AppTheme.colorRed, size: 25, )),
                      ),
                      SizedBox(width: 10,),
                      Expanded(
                          child: TextField(
                            controller: messageController,
                            decoration: InputDecoration(
                                hintText: "writeMessage".tr()+"...",
                                hintStyle: TextStyle(color: Colors.black54),
                                border: InputBorder.none
                            ),
                          )
                      ),
                      SizedBox(width: 15,),
                      FloatingActionButton(
                        onPressed: (){
                          setState(() {
                            sendMessage();
                          });
                        },
                        child: SvgPicture.asset(AppImages.sendOrderIcon,
                          height: 30, color: AppTheme.colorRed,),
                        backgroundColor: Colors.white,
                        elevation: 0,
                      ),
                    ],

                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /*void onConnect(StompClient client, StompFrame frame) {
    client.subscribe(
        destination: '/topic/message',
        callback: (StompFrame frame) {
          if (frame.body != null) {
            Map<String, dynamic> result = json.decode(frame.body);
            message = result['message'];
            int serverSenderId=result['senderId'];
            int serverReceiverId=result['receiverId'];
            String createdAt=result['createdAt'].toString();
            PrivateChatModel privateChatModel=PrivateChatModel(1, message, serverSenderId, serverReceiverId, false, createdAt);
            PrivateChatDao().insertPrivateChat(privateChatModel).then((value) {
              setState(() {
                getPrivateChatMessages();
              });
            });
          }
        });
  }*/

  sendMessage() async {
    if(messageController.text!="") {
      final dio = Dio();
      var data = {
        "message": messageController.text,
        "senderId": senderId,
        "receiverId": receiverId,
        "seen": false
      };
      await dio.post(
          ServerData.OPTIFOOD_MANAGEMENT_BASE_URL + "/api/private-chat",
          data: data);
      setState(() {
        messageController.text = "";
      });
    }
  }


  void getPrivateChatMessages() async {
    print("CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC");
    PrivateChatDao().getAllPrivateChats().then((value){
        privateChatMessages=value;
        setState(() {
          for(int i=0; i<value.length; i++) {
            if((value[i].senderId==senderId || value[i].senderId==receiverId) && (value[i].receiverId==senderId || value[i].receiverId==receiverId)) {
              privateChatMessages.add(value[i]);
            }
          }
        });
      });

  }



}