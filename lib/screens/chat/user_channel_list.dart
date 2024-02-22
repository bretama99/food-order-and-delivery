import 'dart:async';
import 'dart:io';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:opti_food_app/data_models/user_model.dart';
import 'package:opti_food_app/database/order_dao.dart';
import 'package:opti_food_app/screens/chat/private_chat.dart';
import 'package:opti_food_app/screens/message/chat.dart';
import 'package:opti_food_app/screens/user/add_user.dart';
import 'package:opti_food_app/widgets/appbar/app_bar_optifood.dart';
import 'package:opti_food_app/widgets/option_menu/user/user_option_menu_popup.dart';
import 'package:opti_food_app/widgets/popup/confirmation_popup/confirmation_popup.dart';
import '../../api/order_apis.dart';
import '../../assets/images.dart';
import '../../data_models/order_model.dart';
import '../../data_models/private_chat_model.dart';
import '../../database/private_chat_dao.dart';
import '../../database/user_dao.dart';
import '../../main.dart';
import '../../utils/constants.dart';
import '../../widgets/app_theme.dart';
import 'package:url_launcher/url_launcher.dart' as UrlLauncher;

import '../MountedState.dart';
import '../contact/contact_list.dart';
import 'contact_list.dart';

class UserChannelList extends StatefulWidget {
   UserChannelList();

  @override
  State<UserChannelList> createState() => _UserChannelListState();
}
class _UserChannelListState extends MountedState<UserChannelList> {
  String userImagePlaceHolder = "assets/svg/icons/settings/delivery_boy.svg";
  List<UserModel> users = [];
  List<PrivateChatModel> privateChatMessages = [];
  var id;
  var userId =int.parse(optifoodSharedPrefrence.getString('id').toString());
  void getUsers() async {
    Future<List<UserModel>> userModelList = UserDao().getAllUsersWithoutRole();
    userModelList.then((value){
      setState((){
          users=[];
          for(int i=0; i<value.length;i++){
            if(value[i].intServerId!=userId)
              users.add(value[i]);
          }
          for(int i=0; i<users.length;i++){
            print("Userssssssssssssssssssssssssssssssssssssssssssss: ${value.length}");
            for(int j=0; j<privateChatMessages.length; j++){
              print("Server ID: ${users[i].intServerId} Receiver ID:  ${privateChatMessages[j].senderId} Sender ID: ${privateChatMessages[j].senderId}");
              if(users[i].intServerId==privateChatMessages[j].senderId || users[i].intServerId==privateChatMessages[j].receiverId)
                users[i].privateChats!.add(privateChatMessages[j]);
            }
          }
          var temp=users;
          users=[];
          for(int i=0; i<temp.length;i++){
            if(temp[i].privateChats!.length>0){
              users.add(temp[i]);
            }
          }
      });
    });
  }
  bool value = false;
  List<bool> listChecked = [];
  var _image;
  @override
  void initState() {
    id=int.parse(optifoodSharedPrefrence.getString('id').toString());
    getPrivateChatMessages();
    getUsers();
    super.initState();
      userImagePlaceHolder = AppImages.userChat;
  }
  @override
  Widget build(BuildContext context) {
    final isLandscape = MediaQuery.of(context).orientation == Orientation.landscape;
    return Scaffold(
      appBar: AppBarOptifood(isShowSearchBar: true,onSearch: (search){
      },),
      body: Padding(
        padding:  EdgeInsets.only(top: 3),
        child: Container(
          child: SafeArea(
              child: Padding(
                padding:  EdgeInsets.fromLTRB(3, 0, 3, 0),
                child: ListView.builder(
                    itemCount: users.length,
                    itemBuilder: (context, index) =>
                        Container(
                          child: Card(
                            color: Colors.white,
                            surfaceTintColor: Colors.transparent,
                            shadowColor: Colors.white38,
                            elevation:4,
                            shape:  RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child:
                            InkWell(
                              onTap: (){
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => PrivateChat(user: users[index])
                                        ));
                              },
                              child: Row(
                                children: [
                                  Container(
                                    width: 103,
                                    padding: EdgeInsets.only(left: 10,right: index%2==0?0:0),
                                    child:
                                    Row(
                                      children: [
                                        // CircleAvatar(
                                        //   // backgroundImage: users[index].imagePath==''?null:NetworkImage("http://13.36.1.224/user_profiles/wkBRTmVQp8n2XTc9e7gDH4GPJVTLMu."),
                                        //   backgroundColor: Colors.grey,
                                        //   radius: 30,
                                        //   child:
                                          // users[index].imagePath=='' || users[index].imagePath==null?null:
                                          Container(child: SvgPicture.asset(userImagePlaceHolder, height: 60,),),
                                        // ),
                                        if(index%2==0)
                                            Transform.translate(
                                                offset: Offset(-22, 14),
                                                child: Container(
                                                    width: 23,
                                                    height: 23,
                                                    child: Container(
                                                      width: 20,
                                                      height: 20,
                                                      margin: EdgeInsets.all(3),
                                                      decoration: BoxDecoration(
                                                          color: AppTheme.colorGreen,
                                                          shape: BoxShape.circle
                                                      ),
                                                    ),
                                                    margin: EdgeInsets.all(5),
                                                    decoration: BoxDecoration(
                                                        color: Colors.white,
                                                        shape: BoxShape.circle
                                                    ),
                                                  )),
                                        if(index%2==1)
                                            Transform.translate(
                                                offset: Offset(-22, 14),
                                                child: Container(
                                                  width: 23,
                                                  height: 23,
                                                  child: Container(
                                                    width: 20,
                                                    height: 20,
                                                    margin: EdgeInsets.all(3),
                                                    decoration: BoxDecoration(
                                                        color: AppTheme.colorGrey,
                                                        shape: BoxShape.circle
                                                    ),
                                                  ),
                                                  margin: EdgeInsets.all(5),
                                                  decoration: BoxDecoration(
                                                      color: Colors.white,
                                                      shape: BoxShape.circle
                                                  ),
                                                )),
                                    ]
                                    ),
                                  ),
                                  Transform.translate(
                                      offset: Offset(-16, 0),child: Container(width: 3, height: 50, child: VerticalDivider(color: Colors.black54))),
                                  Expanded(
                                    child: Padding(
                                      padding: EdgeInsets.only(left: 20, top: 7.0, right: 7.0, bottom: 7.0),
                                      child: ListTile(
                                        contentPadding: EdgeInsets.all(0),
                                        dense: true,
                                        title: Transform.translate(
                                            offset: Offset(0,0),
                                            child: Text("${users[index].name}",
                                              style: TextStyle(fontWeight: FontWeight.bold,fontSize: 18),)),
                                        subtitle: Padding(
                                          padding:  EdgeInsets.only(top: 4),
                                          child: Transform.translate(
                                            offset: Offset(0, 0),
                                            child: Container(
                                              alignment: Alignment.centerLeft,
                                              child: Column(
                                                mainAxisAlignment: MainAxisAlignment.start,
                                                children: [
                                                  Padding(
                                                    padding:  EdgeInsets.only(top: 6),
                                                    child: Row(
                                                      children: [
                                                        Text("testMessage").tr(),
                                                      ],
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                        trailing: Column(
                                          children: [
                                            // Padding(
                                            //   padding: EdgeInsets.only(bottom: 2),
                                            //   child: Text("${users[index].privateChats![index].createdAt.split(" ")[1].substring(0,5)}",
                                            //   style: TextStyle(color: Colors.red),),
                                            // ),
                                            if(users[index].privateChats!.length>0)
                                            Container(
                                              width: 25,
                                              height: 23,
                                              child: Transform.translate(
                                                offset: Offset(9, 4),child:Text("${users[index].privateChats!.where((e) => e.seen==false && e.senderId==id)!.length}",
                                              style: TextStyle(color: Colors.white),)),
                                              margin: EdgeInsets.all(3),
                                              decoration: BoxDecoration(
                                                  color: AppTheme.colorGreen,
                                                  shape: BoxShape.circle
                                              ),
                                            ),
                                          ],
                                        )
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        )
                ),
              )),
        ),
      ),
      floatingActionButton:Padding(
        padding:  EdgeInsets.only(top: 40),
        child: SizedBox(
          height: 65.0,
          width: 65.0,
          child: FittedBox(
            child: FloatingActionButton(
              backgroundColor: AppTheme.colorRed,
              child: SvgPicture.asset(AppImages.addWhiteIcon, height: 30,),
              onPressed: () async {
                await Navigator.of(context).push(MaterialPageRoute(builder: (context)=>UserContactList()));
              },
            ),
          ),
        ),
      ),
    );
  }

  void assignOrderToDeliveryBoy(int? orderServerId, int? deliveryBoyServerId, bool isAssigned) {
    OrderApis.assignOrderToDeliveryBoy(orderServerId,deliveryBoyServerId,isAssigned);
  }

  void getPrivateChatMessages() async {
    PrivateChatDao().getAllPrivateChats().then((value){
      setState(() {
        privateChatMessages=value;
        getUsers();
      });
    });
  }
}
