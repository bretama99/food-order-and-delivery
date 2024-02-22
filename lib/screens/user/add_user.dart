import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:opti_food_app/assets/images.dart';
import 'package:opti_food_app/data_models/user_model.dart';
import 'package:opti_food_app/widgets/form_widgets/select_profile_image.dart';

import '../../api/user_api.dart';
import '../../database/user_dao.dart';
import '../../utils/constants.dart';
import '../../utils/utility.dart';
import '../../widgets/app_theme.dart';
import '../../widgets/appbar/app_bar_optifood.dart';
import '../../widgets/custom_field_with_no_icon.dart';
import '../MountedState.dart';import '../MountedState.dart';
class AddUser extends StatefulWidget {
  String userRole;
  UserModel? existingUserModel;
  TextEditingController nameController = new TextEditingController();
  TextEditingController phoneNumberController = new TextEditingController();
  TextEditingController emailController = new TextEditingController();
  TextEditingController passwordController = new TextEditingController();
  TextEditingController confirmController = new TextEditingController();
  AddUser(this.userRole,{this.existingUserModel});
  @override
  State<StatefulWidget> createState() => _AddUserState();
}
class _AddUserState extends MountedState<AddUser> {
  var selectedImagePath = null;
  final GlobalKey<FormState> _globalKey = GlobalKey<FormState>();
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    if(widget.existingUserModel!=null){
      widget.nameController.text = widget.existingUserModel!.name;
      widget.phoneNumberController.text = widget.existingUserModel!.phoneNumber;
      widget.emailController.text = widget.existingUserModel!.email;
      widget.passwordController.text = widget.existingUserModel!.password;
      selectedImagePath = widget.existingUserModel!.imagePath;
      print(selectedImagePath);
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarOptifood(),
      body:Padding(
            //padding: const EdgeInsets.only(left: 7,right: 10,top: 10),
            padding: EdgeInsets.zero,
            child: Form(
              key: _globalKey,
              child: ListView(
                children: [
                  //Row(
                  //children: [
                  if(widget.existingUserModel!=null)...[
                    SelectProfileImage(selectedImagePath,(String path){
                      selectedImagePath = path;
                      print(selectedImagePath);
                    }),
                  ],
                  CustomFieldWithNoIcon(
                    // data: Icons.email,
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
                      isObsecre: false,
                      paddingParameters: PaddingParameters(10, 35, 10, 5),
                      outerIcon: SvgPicture.asset(widget.userRole==ConstantUserRole.USER_ROLE_WAITER?"assets/svg/icons/settings/waiter.svg":"assets/svg/icons/settings/delivery_boy.svg", height: 35, color: AppTheme.colorDarkGrey,)
                  ),

                  Padding(
                    padding: const EdgeInsets.only(top: 11,bottom: 11),
                    child: CustomFieldWithNoIcon(
                      // data: Icons.email,
                      controller: widget.phoneNumberController,
                      hintText: "phoneNumber".tr(),
                      isObsecre: false,
                      placeholder: "phoneNumber".tr(),
                      textInputType: TextInputType.phone,
                      outerIcon: SvgPicture.asset(AppImages.phoneClientIcon, height: 35, color: AppTheme.colorDarkGrey,),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 14),
                    child:
                    CustomFieldWithNoIcon(
                      validator: (value){
                        if(value==null || value.isEmpty) {
                          return "pleaseEnterEmail".tr();
                        }
                        else if(RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
                            .hasMatch(value)==false){
                          return "pleaseEnterValidEmail".tr();
                        }
                        else{
                          return null;
                        }
                      },
                      controller: widget.emailController,
                      hintText: "email".tr(),
                      isObsecre: false,
                      textInputType: TextInputType.emailAddress,
                      outerIcon: SvgPicture.asset(AppImages.emailIcon, height: 35, color: AppTheme.colorDarkGrey,),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 14),
                    child:
                    CustomFieldWithNoIcon(
                      validator: (value){
                        if(value==null || value.isEmpty) {
                          return "pleaseEnterPassword".tr();
                        }
                        else{
                          return null;
                        }
                      },
                      controller: widget.passwordController,
                      hintText: "password".tr(),
                      isObsecre: false,
                      obSecure: true,
                      outerIcon: SvgPicture.asset(AppImages.passwordIcon, height: 35, color: AppTheme.colorDarkGrey,),
                    ),
                  ),
                Padding(
                  padding: const EdgeInsets.only(top: 14),
                  child: CustomFieldWithNoIcon(
                    validator: (value){
                      if(value==null || value.isEmpty) {
                        return "confirmPassword".tr();
                      }
                      else{
                        return null;
                      }
                    },
                    controller: widget.confirmController,
                    hintText: "confirmPassword".tr(),
                    isObsecre: false,
                    obSecure: true,
                    outerIcon: SvgPicture.asset(AppImages.passwordIcon, height: 35, color: AppTheme.colorDarkGrey,),
                  )),
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
                          if(widget.passwordController.text!=widget.confirmController.text){
                              Utility().showToastMessage("passwordDoesNotMatch".tr());
                              return;
                          }
                          if (_globalKey.currentState!.validate()==false) {
                            return;
                          }
                          UserModel userModel = UserModel(
                              1,widget.nameController.text,widget.phoneNumberController.text,widget.emailController.text,
                              widget.passwordController.text,widget.userRole,false, imagePath: selectedImagePath, serverId: widget.existingUserModel?.serverId);
                          if(widget.existingUserModel!=null){
                            userModel.id = widget.existingUserModel!.id;
                              await UserDao().updateUser(userModel).then((value) {
                                UserApis.saveUserToSever(userModel, isUpdate: true);
                              });
                              Navigator.pop(context, userModel);
                            }
                          else {
                              await UserDao().insertUser(
                                  userModel).then((value) {
                                UserApis.saveUserToSever(userModel, isUpdate: false);
                              });
                              Navigator.pop(context, userModel);
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