import 'package:easy_localization/easy_localization.dart';
import 'package:fbroadcast/fbroadcast.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:opti_food_app/data_models/message_conversation_model.dart';
import 'package:opti_food_app/database/user_dao.dart';
import 'package:opti_food_app/screens/message/message_list.dart';
import 'package:opti_food_app/utils/constants.dart';

import '../../api/message_api.dart';
import '../../api/message_conversation_api.dart';
import '../../assets/images.dart';
import '../../database/message_conversation_dao.dart';
import '../../main.dart';
import '../../widgets/app_theme.dart';
import '../../widgets/appbar/app_bar_optifood.dart';
import '../../widgets/option_menu/products/food_item_option_menu_popup.dart';
import '../../widgets/popup/confirmation_popup/confirmation_popup.dart';
import '../authentication/noti.dart';
import 'add_message.dart';
import 'message_option_menu_popup.dart';
import '../MountedState.dart';
class MessageConversation extends StatefulWidget{
  static String searchQuery = "";
  // bool? isFromMessageConversation;
  // Function? onCallback;
  final String payload="";
  final MessageConversationModel? existingMessageModel;
  // MessageConversation({this.isFromMessageConversation=false, this.onCallback});
  const MessageConversation({Key? key,String payload="", this.existingMessageModel=null}) : super(key: key);
  @override
  _MessageConversationState createState() => _MessageConversationState();

}

class _MessageConversationState extends MountedState<MessageConversation> with WidgetsBindingObserver{
  TextEditingController messageController= new TextEditingController();
  List<MessageConversationModel> messages = [
    // MessageModel(messageContent: "Hello, how are you?", messageType: "sender"),
    // MessageModel(messageContent: "Hello, am fine?", messageType: "receiver"),
    // MessageModel(messageContent: "Here am sending you a delivery orderqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqq?", messageType: "sender"),
    // MessageModel(messageContent: "I got it!?", messageType: "receiver"),
    // MessageModel(messageContent: "Ok, thanks?", messageType: "sender"),
    // MessageModel(messageContent: "Hello, how are you?", messageType: "sender"),
    // MessageModel(messageContent: "Hello, am fine?", messageType: "receiver"),
    // MessageModel(messageContent: "Here am sending you a delivery orderqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqq?", messageType: "sender"),
    // MessageModel(messageContent: "I got it!?", messageType: "receiver"),
    // MessageModel(messageContent: "Ok, thanks?", messageType: "sender"),
    // MessageModel(messageContent: "Hello, how are you?", messageType: "sender"),
    // MessageModel(messageContent: "Hello, am fine?", messageType: "receiver"),
    // MessageModel(messageContent: "Here am sending you a delivery orderqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqq?", messageType: "sender"),
    // MessageModel(messageContent: "I got it!?", messageType: "receiver"),
    // MessageModel(messageContent: "Ok, thanks?", messageType: "sender"),
    // MessageModel(messageContent: "Hello, how are you?", messageType: "sender"),
    // MessageModel(messageContent: "Hello, am fine?", messageType: "receiver"),
    // MessageModel(messageContent: "Here am sending you a delivery orderqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqq?", messageType: "sender"),
    // MessageModel(messageContent: "I got it!?", messageType: "receiver"),
    // MessageModel(messageContent: "Ok, thanks?", messageType: "sender"),
    // MessageModel(messageContent: "Hello, how are you?", messageType: "sender"),
    // MessageModel(messageContent: "Hello, am fine?", messageType: "receiver"),
    // MessageModel(messageContent: "Here am sending you a delivery orderqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqq?", messageType: "sender"),
    // MessageModel(messageContent: "I got it!?", messageType: "receiver"),
    // MessageModel(messageContent: "Ok, thanks?", messageType: "sender"),
  ];
  late AppBarOptifood appBarOptifood;
  FocusNode focusNode = FocusNode();
  bool newMessageCreated=false;
  void getMessageConversations({bool isPushed=false}) async {
    MessageConversationDao().getAllMessageConversations().then((value){
      setState((){
        messages = value;

      });
    });
  }
  bool isAddedNow = true;

  @override
  void initState() {



    if(widget.existingMessageModel!=null){
      messageController.text = widget.existingMessageModel!.message;
    }
    appBarOptifood = AppBarOptifood(isShowSearchBar: true,onSearch: (search){
      MessageList.searchQuery = search;
      setState(() {
        getMessageConversations();
      });
    },);

      getMessageConversations();
    FBroadcast.instance().register(ConstantBroadcastKeys.KEY_UPDATE_UI, (value, callback) {
      getMessageConversations(isPushed:true);

    });

    // TODO: implement initState
    super.initState();
  }
  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    // WidgetsBinding.instance!.removeObserver(this);
  }
  @override
  Widget build(BuildContext context) {
    PreferredSizeWidget appBarWidget = AppBarOptifood();
    return Scaffold(
        appBar: appBarWidget,
        body: Stack(
          children: <Widget>[
            Padding(
              padding: EdgeInsets.only(bottom: 65),
              child: SingleChildScrollView(
                scrollDirection: Axis.vertical,
                reverse: true,
                child:
                ListView.builder(
                  itemCount: messages.length,
                  shrinkWrap: true,
                  padding: EdgeInsets.only(top: 0,bottom: 10),
                  physics: NeverScrollableScrollPhysics(),
                  itemBuilder: (context, index){
                    return
                      GestureDetector(
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
                                                      MessageConversation(
                                                        existingMessageModel: messages![index],
                                                      )
                                              )
                                          );
                                          setState(() {
                                            newMessageCreated=true;
                                            getMessageConversations();
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
                                                    await MessageConversationDao().delete(messages[index]).then((value) {
                                                      MessageConversationApis.deleteMessageConversation(messages[index]!.serverId);
                                                    });
                                                    setState(() {
                                                      getMessageConversations();
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
                        child: Column(
                          children:[
                            if(index==0)
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
                                        child: Text(DateFormat("dd/MM/yyyy").format(DateTime.parse(messages[index].createdAt))),
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

                            if(index>0 &&(DateTime.parse(messages[index].createdAt.split(" ")[0]).isAfter(DateTime.parse(messages[index-1].createdAt.split(" ")[0]))))
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
                                      child: Text(DateFormat("dd/MM/yyyy").format(DateTime.parse(messages[index].createdAt))),
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
                                  left: (messages[index].messageType == "receiver"?30:14),
                                  right: (messages[index].messageType == "receiver"?14:30),
                                  top: 10,bottom: 10),
                              child: Align(
                                alignment: (messages[index].messageType == "receiver"?Alignment.topLeft:Alignment.topRight),
                                child: Container(
                                  width: MediaQuery.of(context).size.width*0.80,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(8),
                                    color: (messages[index].messageType  == "receiver"?(messages[index].userType=='kitchen'?AppTheme.colorRed:AppTheme.colorLightGrey):AppTheme.colorDarkGrey),
                                  ),
                                  padding: EdgeInsets.all(8),
                                  child:
                                  Column(
                                      children: [
                                        messages[index].messageType  == "receiver"?Align(
                                          alignment: Alignment.centerLeft,
                                          child: Text((messages[index].firstName!=null&&messages[index].firstName!="")?messages[index].firstName:"",textAlign: TextAlign.left , style: TextStyle(fontSize: 16,
                                              color: messages[index].userType=='kitchen'?Colors.white:AppTheme.colorRed, fontWeight: FontWeight.bold),),
                                        ):Container(),
                                        Align(
                                          alignment: Alignment.centerLeft,
                                          child: Text(messages[index].message,textAlign: TextAlign.left , style: TextStyle(fontSize: 15,
                                              color: messages[index].messageType  == "receiver"?Colors.black:Colors.white),),
                                        ),
                                        Align(
                                          alignment: Alignment.bottomRight,
                                          child: Text(messages[index].createdAt.substring(11,16), style: TextStyle(
                                            fontSize: 11,
                                              color: messages[index].messageType  == "receiver" &&messages[index].userType!='kitchen'?Colors.black:Colors.white
                                          ),),
                                        )
                                      ]),
                                ),
                              ),
                            ),

                          ]
                        ),
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
                            //setState(() {
                              addMessage();
                           // });
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

  //Future<void> addMessage() async {
  void addMessage(){
    optifoodSharedPrefrence.setString("message",messageController.text);

    if(messageController.text!="") {

      if(widget.existingMessageModel!=null){
        messages.where((element) => element.id==widget.existingMessageModel!.id).first.message=messageController.text;
      }
      else
      messages.add(MessageConversationModel(1,this.messageController.text,
          //DateFormat("yyyy-MM-dd").format(DateTime.now())+" "+DateFormat("HH:mm").format(DateTime.now()), messageType:"sender",serverId: int.parse(optifoodSharedPrefrence.getString('id').toString())));
          DateFormat("yyyy-MM-dd").format(DateTime.now())+" "+DateFormat("HH:mm").format(DateTime.now()), messageType:"sender",serverId: optifoodSharedPrefrence.getInt('id')));
      MessageConversationModel messageConversationModel =  MessageConversationModel(
          1,messageController.text,DateFormat("yyyy-MM-dd").format(DateTime.now())+" "+DateFormat("HH:mm").format(DateTime.now()), messageType:"sender"
          //,serverId: int.parse(optifoodSharedPrefrence.getString('id').toString())
          //,serverId: optifoodSharedPrefrence.getInt('id')
          ,userId: optifoodSharedPrefrence.getInt('id')!
      );

      if(widget.existingMessageModel!=null){
        widget.existingMessageModel!.message = messageController.text;
        MessageConversationDao().updateMessageConversation(widget.existingMessageModel!).then((value){
        MessageConversationApis.saveMessageConversationToSever(
            widget.existingMessageModel!, isUpdate: true,
        oncall: (){});
        });
      }
      else
      MessageConversationDao().insertMessageConversation(messageConversationModel)
          .then((value){
        MessageConversationApis.saveMessageConversationToSever(messageConversationModel,
            oncall: (){});
      });
      setState(() {
        messageController.text = "";
      });
    }

    // print("==================yyyyyyyyyyyy===================================");
    // setState(() {
    //   messages.add(MessageModel(messageContent: this.messageController.text, messageType: "sender"));
    //   messageController.text="";
    // });
  }

}