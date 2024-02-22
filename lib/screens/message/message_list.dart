import 'dart:async';
import 'dart:io';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:opti_food_app/data_models/company_model.dart';
import 'package:opti_food_app/data_models/contact_model.dart';
import 'package:opti_food_app/data_models/food_category_model.dart';
import 'package:opti_food_app/database/company_dao.dart';
import 'package:opti_food_app/database/contact_dao.dart';
import 'package:opti_food_app/database/food_category_dao.dart';
import 'package:opti_food_app/database/message_dao.dart';
import 'package:opti_food_app/screens/message/add_message.dart';
import 'package:opti_food_app/screens/message/message_conversation.dart';
import 'package:opti_food_app/screens/message/message_option_menu_popup.dart';
import 'package:opti_food_app/screens/products/add_food_category.dart';
import 'package:opti_food_app/screens/products/food_item_list.dart';
import 'package:opti_food_app/utils/utility.dart';
import 'package:opti_food_app/widgets/appbar/app_bar_optifood.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../api/message_api.dart';
import '../../assets/images.dart';
import '../../data_models/message_model.dart';
import '../../widgets/app_theme.dart';
import '../../widgets/option_menu/company/company_option_menu_popup.dart';
import '../../widgets/option_menu/products/food_item_option_menu_popup.dart';
import '../../widgets/popup/confirmation_popup/confirmation_popup.dart';
import '../authentication/client_register.dart';
import '../authentication/delivery_info.dart';
import '../order/ordered_lists.dart';
import '../MountedState.dart';
class MessageList extends StatefulWidget {
  static String searchQuery = "";
  bool? isFromMessageConversation;
  Function? onCallback;
  MessageList({this.isFromMessageConversation=false, this.onCallback});
  @override
  State<MessageList> createState() => _MessageListState();
}
class _MessageListState extends MountedState<MessageList> with WidgetsBindingObserver {
  late AppBarOptifood appBarOptifood;
  FocusNode focusNode = FocusNode();
  List<MessageModel> messageList = [];
  bool newMessageCreated=false;
  void getMessages() async {
    MessageDao().getAllMessages().then((value){
      setState((){
        if(newMessageCreated && widget.isFromMessageConversation==true){
          Navigator.pop(context);

          widget.onCallback!(value[value.length-1].message);
        }
        if(MessageList.searchQuery.length>0){
          messageList = value.where((element) => (element.messageName).toLowerCase().contains(MessageList.searchQuery.toLowerCase())).toList();
        }
        else{
          messageList = value;
        }
      });
    });
  }
  @override
  void initState() {
    appBarOptifood = AppBarOptifood(isShowSearchBar: true,onSearch: (search){
      MessageList.searchQuery = search;
      setState(() {
        getMessages();
      });
    },);
    WidgetsBinding.instance!.addObserver(this);
    getMessages();
    super.initState();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    WidgetsBinding.instance!.removeObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // TODO: implement didChangeAppLifecycleState
    super.didChangeAppLifecycleState(state);
    switch(state){
      case AppLifecycleState.detached:
        break;
      case AppLifecycleState.paused:
        appBarOptifood.closeSearchBar();
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLandscape = MediaQuery.of(context).orientation == Orientation.landscape;
    return Scaffold(
      appBar: AppBarOptifood(isShowSearchBar: true,onSearch: (search){
        FoodItemList.searchQuery = search;
        setState(() {
          getMessages();
        });
      },),
      body: Padding(
        padding: const EdgeInsets.only(top: 3),
        child: Container(
          child: SafeArea(
            child: Padding(
                padding: const EdgeInsets.fromLTRB(3, 0, 3, 0),
                child: ListView.builder(
                  itemCount: messageList.length,
                  itemBuilder: (context, index) => GestureDetector(
                    onHorizontalDragStart: (DragStartDetails details){
                      setState(() {
                        showDialog(context: context,
                            builder: (BuildContext context) {
                              return MessageMenuPopup(
                                  onSelect: (action) async {
                                    if (action ==
                                        FoodItemOptionMenuPopup.ACTIONS
                                            .ACTION_EDIT) {
                                      await Navigator.of(context).push(
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  AddMessage(
                                                    existingMessageModel: messageList[index],
                                                  )
                                          ));
                                      setState(() {
                                        newMessageCreated=true;
                                        getMessages();
                                      });
                                    }
                                    else if (action ==
                                        FoodItemOptionMenuPopup.ACTIONS
                                            .ACTION_DELETE) {
                                      showDialog(
                                          context: context,
                                          builder: (BuildContext
                                          context) {
                                            return ConfirmationPopup(
                                              title: "delete".tr(),
                                              titleImagePath: AppImages.deleteIcon,
                                              positiveButtonText: "delete".tr(),
                                              negativeButtonText: "cancel".tr(),
                                              titleImageBackgroundColor: AppTheme
                                                  .colorRed,
                                              positiveButtonPressed: () async {
                                                await MessageDao().delete(messageList[index]).then((value) {
                                                  MessageApis.deleteMessage(messageList[index]!.serverId);
                                                });
                                                setState(() {
                                                  getMessages();
                                                });
                                              },
                                              subTitle: 'areYouSureToDeleteCategory'.tr(),
                                            );
                                          });
                                    }
                                  });
                            });
                      });
                    },
                    onTap: () async {
                      if(!widget.isFromMessageConversation!) {
                        await Navigator.of(context).push(
                            MaterialPageRoute(
                                builder: (context) =>
                                    AddMessage(
                                      existingMessageModel: messageList[index],
                                    )
                            ));
                      }
                      else{
                        Navigator.pop(context);
                        widget.onCallback!(messageList[index].message);
                      }
                      setState(() {
                        getMessages();
                      });
                    },
                    child:
                    Container(
                      //height: 88,
                      child: Card(
                        color: Colors.white,
                        surfaceTintColor: Colors.transparent,
                        shadowColor: Colors.white38,
                        elevation:4,
                        shape:  RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10), // <-- Radius
                        ),
                        child: Row(
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(left: 8,right: 2),
                              child: Container(
                                  width: 38,
                                  child: SvgPicture.asset(AppImages.messageIcon,
                                      height: 35)
                              ),
                            ),
                            Container(height: 50, child: VerticalDivider(color: Colors.black54)),
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.all(7.0),
                                child: ListTile(
                                  contentPadding: EdgeInsets.all(0),
                                  dense: true,
                                  title: Transform.translate(
                                    //offset: Offset(-20,0),
                                      offset: Offset(0,0),
                                      child: Text("${messageList[index].messageName}",
                                        style: TextStyle(fontWeight: FontWeight.bold,fontSize: 18),)),
                                  subtitle: Text(messageList[index].message,style: TextStyle(fontSize: 14),),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    /*Container(
                      height: 88,
                        child: Card(
                          shadowColor: Colors.white38,
                          elevation:4,
                          shape:  RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10), // <-- Radius
                          ),
                          child: ListTile(
                            contentPadding: EdgeInsets.only(left: 15,right: 15),
                            dense: true,
                            leading:
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                SvgPicture.asset(AppImages.messageIcon,
                                    height: 35),
                                Padding(padding: EdgeInsets.only(top: 5,bottom: 5),
                                  child: VerticalDivider(color: Colors.black54,),
                                )
                              ],
                            ),
                            title:
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if(messageList[index].messageName.isEmpty)...[
                                  SizedBox(height: 10,)
                                ],
                                Text("${messageList[index].messageName.toUpperCase()}",
                                  style: TextStyle(fontSize: 16),textAlign: TextAlign.start,),
                                if(messageList[index].message!=null&&messageList[index].message.isNotEmpty)...[
                                  SizedBox(height: 3,),
                                  Text("${messageList[index].message}",
                                    style: TextStyle(fontSize: 10),),
                                ]

                              ],
                            ),
                          ),
                        )
                    ),*/
                  ),
                )
            ),
            //      )
          ),
        ),
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(top: 40),
        child: SizedBox(
          height: 65.0,
          width: 65.0,
          child: FittedBox(
            child: FloatingActionButton(
              backgroundColor: AppTheme.colorRed,
              child: SvgPicture.asset(AppImages.addWhiteIcon, height: 30,),
              onPressed: () async {
                MessageModel messageModel =
                await Navigator.of(context).push(MaterialPageRoute(builder: (context)=>AddMessage(

                )));
                //if(companyModel!=null){
                newMessageCreated=true;
                getMessages();
                //}
              },
            ),
          ),
        ),
      ),
    );

  }
}