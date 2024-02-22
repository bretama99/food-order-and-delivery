import 'dart:io';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/src/scheduler/ticker.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:flutter_svg/svg.dart';
import 'package:image_picker/image_picker.dart';
import 'package:opti_food_app/assets/images.dart';
import 'package:opti_food_app/data_models/attribute_category_model.dart';
import 'package:opti_food_app/data_models/company_model.dart';
import 'package:opti_food_app/data_models/food_items_model.dart';
import 'package:opti_food_app/data_models/message_model.dart';
import 'package:opti_food_app/database/attribute_category_dao.dart';
import 'package:opti_food_app/database/company_dao.dart';
import 'package:opti_food_app/database/food_category_dao.dart';
import 'package:opti_food_app/database/food_items_dao.dart';
import 'package:opti_food_app/database/message_dao.dart';
import 'package:opti_food_app/widgets/appbar/app_bar_optifood.dart';

import '../../api/message_api.dart';
import '../../data_models/food_category_model.dart';
import '../../utils/utility.dart';
import '../../widgets/app_theme.dart';
import '../../widgets/custom_field_with_no_icon.dart';
import '../../widgets/popup/input_popup/radio_input_popup.dart';
import '../MountedState.dart';
class AddMessage extends StatefulWidget{
  MessageModel? existingMessageModel;
  TextEditingController messageNameController = TextEditingController();
  TextEditingController messageController = TextEditingController();
  bool showInMainApp = true;
  bool showInKitchen = true;

  AddMessage({this.existingMessageModel=null});

  @override
  State<StatefulWidget> createState() => _AddMessageState();

}
class _AddMessageState extends MountedState<AddMessage> with SingleTickerProviderStateMixin {
  final GlobalKey<FormState> _globalKey = GlobalKey<FormState>();
  bool scrollToend=true;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    if (widget.existingMessageModel != null) {
      widget.messageNameController.text =
          widget.existingMessageModel!.messageName;
      widget.messageController.text =
      widget.existingMessageModel!.message != null ? widget
          .existingMessageModel!.message! : "";
      widget.showInMainApp = widget.existingMessageModel!.showInMainApp;
      widget.showInKitchen = widget.existingMessageModel!.showInKitchen;
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarOptifood(),
      body: Container(
          child: Stack(
            children: [
              SingleChildScrollView(
                  reverse: scrollToend,
                  scrollDirection:Axis.vertical,
                  child: Form(
                    key: _globalKey,
                    child: Column(
                      children: [
                        CustomFieldWithNoIcon( // name
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return "pleaseEnterMessageName".tr();
                            }
                            else {
                              return null;
                            }
                          },
                          controller: widget.messageNameController,
                          hintText: "messageName".tr(),
                          isObsecre: false,
                          placeholder: "messageName".tr(),
                          paddingParameters: PaddingParameters(10, 35, 10, 5),
                          outerIcon: SvgPicture.asset(
                            AppImages.messageIcon, height: 35,
                            color: AppTheme.colorDarkGrey,),
                          textCapitalization: TextCapitalization.sentences,

                        ),

                        CustomFieldWithNoIcon(
                          validator: (value){
                            if(value==null || value.isEmpty) {
                              return "pleaseEnterMessage".tr();
                            }
                            else{
                              return null;
                            }
                          },
                          controller: widget.messageController,
                          hintText: "message".tr(),
                          minLines: 3,
                          isObsecre: false,
                        ),
                        ListTile(
                          contentPadding: EdgeInsets.only(
                              left: 10, right: 10, top: 10, bottom: 15),
                          leading: SvgPicture.asset(
                            AppImages.eyeHiddenIcon, height: 35,
                            color: AppTheme.colorDarkGrey,),
                          title: Text("showInMainApp").tr(),
                          trailing: Switch(
                            activeColor: AppTheme.colorRed,
                            value: widget.showInMainApp,
                            onChanged: (bool value) {
                              setState(() {
                                widget.showInMainApp = value;
                              });
                            },
                          ),
                        ),

                        ListTile(
                          contentPadding: EdgeInsets.only(
                              left: 10, right: 10, top: 10, bottom: 15),
                          leading: SvgPicture.asset(
                            AppImages.eyeHiddenIcon, height: 35,
                            color: AppTheme.colorDarkGrey,),
                          title: Text("showInKitchen").tr(),
                          trailing: Switch(
                            activeColor: AppTheme.colorRed,
                            value: widget.showInKitchen,
                            onChanged: (bool value) {
                              setState(() {
                                widget.showInKitchen = !widget.showInKitchen;
                                print("showInKitchen valueeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee: ${widget.showInKitchen} ${widget.showInMainApp}");

                              });

                            },
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(
                              left: 60, right: 55, top: 20, bottom: 20),
                          child: Container(
                            height: 45,
                            width: 300,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.all(
                                    Radius.circular(10)),
                                boxShadow: [
                                  BoxShadow(color: AppTheme.colorDarkGrey,
                                    spreadRadius: 2,
                                    blurRadius: 0,)
                                ]
                            ),
                            child: ElevatedButton(

                              style: ElevatedButton.styleFrom(
                                  surfaceTintColor: Colors.transparent,
                                  primary: AppTheme.colorDarkGrey,
                                  elevation: 10,
                                  shadowColor: AppTheme.colorDarkGrey),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,

                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(right: 15),
                                    child: SvgPicture.asset(AppImages.saveIcon,
                                      height: 25,),
                                  ),
                                  Text('save', style: TextStyle(
                                      fontSize: 18.0, color: Colors.white),)
                                      .tr(),
                                ],
                              ),
                              onPressed: () async {
                                if (_globalKey.currentState!.validate() ==
                                    false) {
                                  return;
                                }
                                MessageModel messageModel = MessageModel(
                                    1,
                                    widget.messageNameController.text,
                                    widget.messageController.text,
                                    widget.showInMainApp,
                                    widget.showInKitchen
                                );
                                if (!widget.showInKitchen &&
                                    !widget.showInMainApp) {
                                  Utility().showToastMessage(
                                      "You have to select 1 option minimum".tr());
                                  return;
                                }
                                else {
                                  if (widget.existingMessageModel != null) {
                                    messageModel.id =
                                        widget.existingMessageModel!.id;
                                    messageModel.serverId =
                                        widget.existingMessageModel!.serverId;
                                    messageModel.isSynced =
                                        widget.existingMessageModel!.isSynced;
                                    await MessageDao().updateMessage(
                                        messageModel).then((value) {
                                      MessageApis.saveMessageToSever(
                                          messageModel, isUpdate: true,
                                          oncall: () {});
                                    });
                                  }
                                  else {
                                    await MessageDao()
                                        .insertMessage(messageModel).then((
                                        value) {

                                      MessageApis.saveMessageToSever(
                                          messageModel, oncall: () {});
                                    });
                                  }

                                  Navigator.pop(context, messageModel);
                                }

                              }
                            ),
                          ),
                        ),

                      ],
                    ),
                  )
              )

              //)
            ],
          )
      ),
    );
  }
}