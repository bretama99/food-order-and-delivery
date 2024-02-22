import 'dart:async';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:opti_food_app/data_models/group_model.dart';
import 'package:opti_food_app/data_models/user_model.dart';
import 'package:opti_food_app/screens/chat/add_group.dart';
import 'package:opti_food_app/screens/chat/private_chat.dart';
import 'package:opti_food_app/widgets/appbar/app_bar_optifood.dart';
import '../../api/order_apis.dart';
import '../../assets/images.dart';
import '../../data_models/private_chat_model.dart';
import '../../database/group_dao.dart';
import '../../database/private_chat_dao.dart';
import '../../database/user_dao.dart';
import '../../main.dart';
import '../../widgets/app_theme.dart';
import '../MountedState.dart';
import 'chat_contact_model.dart';

class UserContactList extends StatefulWidget {
  UserContactList();
  @override
  State<UserContactList> createState() => _UserContactListState();
}
class _UserContactListState extends MountedState<UserContactList> {
  String userImagePlaceHolder = "assets/svg/icons/settings/delivery_boy.svg";
  List<UserModel> users = [];
  List<PrivateChatModel> privateChatMessages = [];
  List<GroupModel> groupModels = [];
  var userId =int.parse(optifoodSharedPrefrence.getString('id').toString());
  bool value = false;
  List<bool> listChecked = [];
  List<ChatContactModel> chatContactsUsers=[];
  var _image;
  @override
  void initState() {
    getGroups();
    getUsers();
    super.initState();
    userImagePlaceHolder = AppImages.userChat;
  }
  @override
  Widget build(BuildContext context) {
    final isLandscape = MediaQuery.of(context).orientation == Orientation.landscape;
    return Scaffold(
      appBar: AppBarOptifood(isShowSearchBar: true,onSearch: (search){
        // setState(() {
        //   getUsers();
        // });
      },),
      body: ListView(
          children: <Widget>[
            Padding(
              padding: EdgeInsets.only(left: 15, bottom: 5, top: 10),
              child: Row(
                children: [
                  Container(child: SvgPicture.asset(userImagePlaceHolder, height: 60,),),
                  Transform.translate(
                      offset: Offset(-22, 14),
                      child: Container(
                        width: 26,
                        height: 26,
                        child: Container(
                          margin: EdgeInsets.only(right: 8),
                          width: 17,
                          height: 17,
                          child:
                          InkWell(child:
                          Transform.translate(
                              offset: Offset(-1, -2),child: Icon(Icons.add, color: Colors.white, size: 30, )),
                          onTap: () async {
                            await Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => AddGroup()
                                ));
                            getGroups();
                          },
                          ),
                        ),
                        margin: EdgeInsets.all(5),
                        decoration: BoxDecoration(
                            color: AppTheme.colorDarkGrey,
                            shape: BoxShape.circle
                        ),
                      )),
                  Transform.translate(offset: Offset(-12,5),
                  child: Text("addGroup", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18.0),).tr())
                ],
              ),
            ),
      Container(
        margin: EdgeInsets.only(left: 20, top: 10),
        child: Text("groups", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20.0, color: AppTheme.colorRed),).tr(),),
      Divider(thickness: 0.3,),
      Container(
        padding: EdgeInsets.only(top: 20),
        child: ListView.builder(
          itemCount: groupModels.length,
          shrinkWrap: true,
          physics: ClampingScrollPhysics(),
          itemBuilder: (context, index) =>
              Padding(
                padding: EdgeInsets.only(bottom: 15),
                child: ListTile(
                leading: Container(child: SvgPicture.asset(userImagePlaceHolder, height: 60,),),
                title: Padding(padding: EdgeInsets.only(left: 30),child: Text(groupModels[index]!.name))),
              ),
        ),
      ),
        for(int i=0; i<chatContactsUsers.length; i++)
          Column(children: [
            Container(
              alignment: Alignment.centerLeft,
              padding: EdgeInsets.only(left: 30, top: 20),
              child: Text(chatContactsUsers[i].letter,
                textAlign: TextAlign.left,
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20.0, color: AppTheme.colorRed),),),
            Divider(thickness: 0.3,),
            Container(
              padding: EdgeInsets.only(top: 30),
              child: ListView.builder(
                itemCount: chatContactsUsers[i].users.length,
                shrinkWrap: true,
                physics: ClampingScrollPhysics(),
                itemBuilder: (context, index) =>
                    InkWell(
                      onTap: (){
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => PrivateChat(user: chatContactsUsers[i].users[index])
                            ));
                      },
                      child: Padding(
                          padding: EdgeInsets.only(bottom: 5, left: 15),
                          child: Row(children: [
                            Container(child: SvgPicture.asset(userImagePlaceHolder, height: 60,),),
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
                            Padding(padding: EdgeInsets.only(left: 15),child: Text(chatContactsUsers[i].users[index].name)),
                          ],)
                        // ListTile(
                        //     leading: Container(child: SvgPicture.asset(userImagePlaceHolder, height: 60,),),
                        //     title: Padding(
                        //         padding: EdgeInsets.only(left: 15),child: Text(users[index]!.name))),
                      ),
                    ),
              ),
            ),
          ],
          )

    ])
    );

      /*Padding(
        padding:  EdgeInsets.only(top: 3),
        child: Container(
          child: SafeArea(
              child: ListView(
                  children: <Widget>[
                  ListView.builder(
                      itemCount: users.length,
                      itemBuilder: (context, index) =>
                          Container(
                            child: Card(
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
                                                          Text(""),
                                                        ],
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          )
                  ),

                ]
              )
          ),
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
                // await Navigator.of(context).push(MaterialPageRoute(builder: (context)=>AddUser(widget.userRole)));
                // setState((){
                //   getUsers();
                // });
              },
            ),
          ),
        ),
      ),
    );*/
  }

  void getUsers() async {
    Future<List<UserModel>> userModelList = UserDao().getAllUsersWithoutRole();
    userModelList.then((value){
      setState((){
        users=[];
        chatContactsUsers=[];
        for(int i=0; i<value.length; i++){
          if(value[i].intServerId!=userId)
            users.add(value[i]);
        }
      });

      var letters=["a", "b", "c", "d", "e", "f", "g", "h", "i", "j", "k", "l", "m", "n", "o", "p",
        "q", "r", "s", "t", "u", "v", "w", "x", "y", "z"];

      for(int i=0; i<letters.length; i++){
        List<UserModel> userModels = [];
        for(int j=0; j<users.length; j++){
          if(letters[i].toUpperCase()==users[j].name.substring(0, 1).toUpperCase()){
            userModels.add(users[j]);
          }
        }
        if(userModels.length>0)
          chatContactsUsers.add(ChatContactModel(letter: letters[i].toUpperCase(), users: userModels));
      }

    });
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

  void getGroups() async {
    GroupDao().getAllGroups().then((value){
      setState(() {
        print("Nowwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwww from adddddddddddddddd");
        groupModels=value;
        getUsers();
      });
    });
  }
}
