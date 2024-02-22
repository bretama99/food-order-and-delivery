import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:image_picker/image_picker.dart';
import 'package:opti_food_app/api/user_profile_api.dart';
import 'package:opti_food_app/assets/images.dart';
import 'package:opti_food_app/data_models/user_model.dart';
import 'package:path_provider/path_provider.dart';
import '../../data_models/user_profile.dart';
import '../../main.dart';
import '../../utils/constants.dart';
import '../../utils/utility.dart';
import '../../widgets/app_theme.dart';
import '../../widgets/appbar/app_bar_optifood.dart';
import '../../widgets/custom_field_with_no_icon.dart';
import '../../widgets/popup/input_popup/popup_widget.dart';
import 'package:flutter/services.dart';
import 'dart:io';
import 'package:opti_food_app/widgets/appbar/app_bar_optifood.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as path;

import '../MountedState.dart';
class UserProfile extends StatefulWidget {

  @override
  State<StatefulWidget> createState() => _UserProfileState();
}
class _UserProfileState extends MountedState<UserProfile> {
  var selectedImagePath = null;
  String? userRole, userStatus;
  String? userId;
  String? userProfile;
  UserModel? existingUserModel;
  TextEditingController nameController = new TextEditingController();
  TextEditingController phoneNumberController = new TextEditingController();
  TextEditingController emailController = new TextEditingController();
  TextEditingController passwordController = new TextEditingController();
  TextEditingController currentController = new TextEditingController();
  TextEditingController confirmController = new TextEditingController();
  final GlobalKey<FormState> _globalKey = GlobalKey<FormState>();
  var _image;
  late String fileName="";
  @override
  void initState() {
    nameController.text=optifoodSharedPrefrence.getString("name")!;
    phoneNumberController.text=optifoodSharedPrefrence.getString("mobilePhone")!;
    emailController.text=optifoodSharedPrefrence.getString("email")!;
    userRole=optifoodSharedPrefrence.getString("userType")!;
    userStatus=optifoodSharedPrefrence.getString("userStatus")!;
    userId=optifoodSharedPrefrence.getString("userId")!;
    // if(optifoodSharedPrefrence.getString("userProfile")==null)
    //   userProfile="";
    // else{
    //   userProfile=optifoodSharedPrefrence.getString("userProfile")!;
    // }
    _fileFromImageUrl();
    super.initState();
  }
  _fileFromImageUrl() async {
      var imgUrl = ServerData.OPTIFOOD_IMAGES+"/user_profiles/${userId}.png";
      final response1 = await http.get(Uri.parse(imgUrl));
      final imageName = path.basename(imgUrl);
      if (imageName != 'null') {
        final documentDirectory1 = await getApplicationDocumentsDirectory();
        final localPath = path.join(documentDirectory1.path, imageName);
        final imageFile = File(localPath);
        await imageFile.writeAsBytes(response1.bodyBytes).then((value222) {
          var image = imageFile.toString().substring(8, imageFile
              .toString()
              .length - 1);
          setState(() {
            _image = File(image);
            selectedImagePath = image;
          });
        });
    }
      else{
        selectedImagePath=null;
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
                  Stack(
                    children: [
                      Container(padding: EdgeInsets.only(top: 35,bottom: 35),
                        margin: EdgeInsets.only(bottom: 30),
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black12,
                              spreadRadius: 2,
                              blurRadius: 5,
                            ),
                          ],
                        ),

                        child: Container(
                          width: 65,
                          decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              boxShadow: [BoxShadow(blurRadius: 5, color: Colors.black12,spreadRadius: 2)]
                          ),
                          child: GestureDetector(
                            child: CircleAvatar(
                              backgroundColor: Colors.white,
                              radius: 55,
                              child: CircleAvatar(
                                backgroundImage: _image==null?null:FileImage(_image),
                                backgroundColor: Colors.white,
                                radius: 50,
                                child: _image!=null?null:
                                SvgPicture.asset(AppImages.addLogoIcon,
                                    height: 35),
                              ),
                            ),
                            onTap: () async {
                              //final image = await ImagePicker().getImage(source: ImageSource.gallery);
                              final image = await ImagePicker().pickImage(source: ImageSource.gallery);
                              if(image == null) return;
                              final imageTemp = File(image!.path);
                              selectedImagePath = image.path;
                              fileName = image.path.split('/').last;
                              setState(() => this._image = imageTemp);
                            },
                          ),
                        ),

                      ),
                      // if(selectedImagePath!=null)...[
                      //   GestureDetector(
                      //     child: Center(
                      //       child: Container(
                      //           padding: EdgeInsets.all(3),
                      //           margin: EdgeInsets.only(top: 40, left: 70),
                      //           child: Icon(
                      //             Icons.close, color: Colors.white,),
                      //           decoration: BoxDecoration(
                      //             color: AppTheme.colorDarkGrey,
                      //             shape: BoxShape.circle,
                      //           )
                      //       ),
                      //     ),
                      //     onTap: (){
                      //       setState((){
                      //         selectedImagePath = null;
                      //         _image = null;
                      //       });
                      //     },
                      //   )
                      // ]
                    ],
                  ),
                  CustomFieldWithNoIcon(
                      validator: (value){
                        if(value==null || value.isEmpty) {
                          return "pleaseEnterName".tr();
                        }
                        else{
                          return null;
                        }
                      },
                      controller: nameController,
                      textCapitalization: TextCapitalization.sentences,
                      hintText: "name".tr(),
                      isObsecre: false,
                      paddingParameters: PaddingParameters(10, 35, 10, 5),
                      outerIcon: SvgPicture.asset(userRole==ConstantUserRole.USER_ROLE_WAITER?"assets/svg/icons/settings/waiter.svg":"assets/svg/icons/settings/delivery_boy.svg", height: 35, color: AppTheme.colorDarkGrey,)
                  ),

                  Padding(
                    padding: const EdgeInsets.only(top: 11,bottom: 11),
                    child: CustomFieldWithNoIcon(
                      controller: phoneNumberController,
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
                      controller: emailController,
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
                      },
                      controller: passwordController,
                      hintText: "password".tr(),
                      isObsecre: false,
                      obSecure: true,
                      outerIcon: SvgPicture.asset(AppImages.passwordIcon, height: 35, color: AppTheme.colorDarkGrey,),
                      onTap: (){
                        changePassword(context);
                      },
                    ),
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

                          UserProfileModel userProfileModel = UserProfileModel(
                                        1, userId!, nameController.text.split(" ")[0],
                                        nameController.text.split(" ").length>1?nameController.text.split(" ")[1]:"",
                                        nameController.text.split(" ").length>2?nameController.text.split(" ")[2]:"",
                                        phoneNumberController.text, emailController.text, userRole!, "Active","");
                              UserProfileApis.updateProfile(userProfileModel);
                              // UserProfileApis.saveProfileImage(fileName, _image);
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

  changePassword(BuildContext context){
    return  showDialog(context: context, builder: (BuildContext context) {
      return PopupWidget(
          title: "changePassword".tr(),
          positiveButtonText: "save".tr(),
          negativeButtonText: "cancel".tr(),
          givenWidget: [
            CustomFieldWithNoIcon(
              validator: (value){
                if(value==null || value.isEmpty) {
                  return "pleaseEnterCurrentPassword".tr();
                }
                else{
                  return null;
                }
              },
              controller: currentController,
              hintText: "currentPassword".tr(),
              isObsecre: false,
              obSecure: true,
              isKeepSpaceForOuterIcon: false,
              paddingParameters: PaddingParameters(7,0,12,0),
            ),
            CustomFieldWithNoIcon(
              validator: (value){
                if(value==null || value.isEmpty) {
                  return "pleaseEnterNewPassword".tr();
                }
                else{
                  return null;
                }
              },
              controller: passwordController,
              hintText: "newPassword".tr(),
              isObsecre: false,
              obSecure: true,
              isKeepSpaceForOuterIcon: false,
              paddingParameters: PaddingParameters(7,0,12,0),
            ),
            CustomFieldWithNoIcon(
              validator: (value){
                if(value==null || value.isEmpty) {
                  return "confirmPassword".tr();
                }
                else{
                  return null;
                }
              },
              controller: confirmController,
              hintText: "confirmPassword".tr(),
              isObsecre: false,
              obSecure: true,
              isKeepSpaceForOuterIcon: false,
              paddingParameters: PaddingParameters(7,0,12,0),
            ),
          ],
          positiveButtonPressed: ()
          {
            if(passwordController.text!=confirmController.text){
              Utility().showToastMessage("passwordDoesNotMatch".tr());
              changePassword(context);
              return;
            }
            UserProfileApis.changePassword(
                emailController.text,
                currentController.text,
                passwordController.text);
          },
        );
    });
  }


}