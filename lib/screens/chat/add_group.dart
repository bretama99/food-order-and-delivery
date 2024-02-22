import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:opti_food_app/assets/images.dart';
import 'package:opti_food_app/data_models/group_model.dart';
import 'package:opti_food_app/data_models/user_model.dart';
import 'package:opti_food_app/widgets/form_widgets/select_profile_image.dart';

import '../../api/user_api.dart';
import '../../database/group_dao.dart';
import '../../database/user_dao.dart';
import '../../utils/constants.dart';
import '../../utils/utility.dart';
import '../../widgets/app_theme.dart';
import '../../widgets/appbar/app_bar_optifood.dart';
import '../../widgets/custom_field_with_no_icon.dart';
import '../MountedState.dart';

class AddGroup extends StatefulWidget {
  GroupModel? existingGroupModel;
  TextEditingController nameController = new TextEditingController();
  AddGroup({this.existingGroupModel});
  @override
  State<StatefulWidget> createState() => _AddGroupState();
}
class _AddGroupState extends MountedState<AddGroup> {
  var selectedImagePath = null;
  final GlobalKey<FormState> _globalKey = GlobalKey<FormState>();
  @override
  void initState() {
    super.initState();
    if(widget.existingGroupModel!=null){
      widget.nameController.text = widget.existingGroupModel!.name;
      selectedImagePath = widget.existingGroupModel!.imagePath;
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBarOptifood(),
        body:Padding(
            padding: EdgeInsets.zero,
            child: Form(
              key: _globalKey,
              child: ListView(
                children: [
                  if(widget.existingGroupModel!=null)...[
                    SelectProfileImage(selectedImagePath,(String path){
                      selectedImagePath = path;
                    }),
                  ],
                  CustomFieldWithNoIcon(
                      validator: (value){
                        if(value==null || value.isEmpty) {
                          return "pleaseEnterName".tr();
                        }
                        else{
                          return null;
                        }
                      },
                      controller: widget.nameController,
                      textCapitalization: TextCapitalization.sentences,
                      hintText: "name".tr(),
                      isKeepSpaceForOuterIcon: false,
                      isObsecre: false,

                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 60,right: 55,top: 50,bottom: 50),
                    child: Container(
                      height:45 ,
                      decoration: const BoxDecoration(
                          borderRadius: BorderRadius.all(
                              Radius.circular(10)),
                          boxShadow: [
                            BoxShadow(color: AppTheme.colorDarkGrey,spreadRadius:2 , blurRadius: 0,)
                          ]
                      ),
                      child: ElevatedButton(

                        style: ElevatedButton.styleFrom(
                            surfaceTintColor: Colors.transparent,
                            primary: AppTheme.colorDarkGrey,
                            elevation: 10, shadowColor: AppTheme.colorDarkGrey),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,

                          children: [
                            Padding(
                              padding: const EdgeInsets.only(right: 15),
                              child: SvgPicture.asset(AppImages.saveIcon,
                                height: 25,),
                            ),
                            const Text('save', style: TextStyle(fontSize: 18.0, color: Colors.white),).tr(),
                          ],
                        ),
                        onPressed: () async {
                          if (_globalKey.currentState!.validate()==false) {
                            return;
                          }
                          GroupModel groupModel = GroupModel(1, widget.nameController.text);
                          if(widget.existingGroupModel!=null){
                            groupModel.id = widget.existingGroupModel!.id;
                            await GroupDao().updateGroup(groupModel).then((value) {
                              Navigator.pop(context, groupModel);
                              // UserApis.saveUserToSever(userModel, isUpdate: true);
                            });
                          }
                          else {
                            await GroupDao().insertGroup(
                                groupModel).then((value) {
                                  Navigator.pop(context, groupModel);
                              // UserApis.saveUserToSever(groupModel, isUpdate: false);
                            });
                          }
                        },
                      ),
                    ),
                  ),
                ],
              ),
            )

        )
    );
  }

}