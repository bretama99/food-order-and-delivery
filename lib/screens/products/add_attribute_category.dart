import 'dart:io';
import 'package:dio/dio.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:flutter_svg/svg.dart';
import 'package:image_picker/image_picker.dart';
import 'package:opti_food_app/api/attribute_category_api.dart';
import 'package:opti_food_app/api/product.dart';
import 'package:opti_food_app/assets/images.dart';
import 'package:opti_food_app/data_models/company_model.dart';
import 'package:opti_food_app/database/company_dao.dart';
import 'package:opti_food_app/database/food_category_dao.dart';
import 'package:opti_food_app/main.dart';
import 'package:opti_food_app/services/optifood_background_service.dart';
import 'package:opti_food_app/widgets/appbar/app_bar_optifood.dart';

import '../../data_models/attribute_category_model.dart';
import '../../data_models/food_category_model.dart';
import '../../database/attribute_category_dao.dart';
import '../../utils/constants.dart';
import '../../utils/utility.dart';
import '../../widgets/app_theme.dart';
import '../../widgets/custom_field_with_no_icon.dart';
import '../MountedState.dart';
class AddAttributeCategory extends StatefulWidget{
  AttributeCategoryModel? existingAttributeCategoryModel; // having value only when edit company
  TextEditingController nameController = new TextEditingController();
  TextEditingController displayNameController = new TextEditingController();
  TextEditingController buttonColorController = new TextEditingController();
  AddAttributeCategory({this.existingAttributeCategoryModel=null});

  @override
  State<StatefulWidget> createState() => _AddAttributeCategoryState();

}
class _AddAttributeCategoryState extends MountedState<AddAttributeCategory>{
  final GlobalKey<FormState> _globalKey = GlobalKey<FormState>();
  var _image;
  var selectedImagePath = null;
  late String fileName="";
  var optifoodBackgroundService = OptifoodBackgroundService();
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    if(widget.existingAttributeCategoryModel!=null){
      AttributeCategoryDao().getAttributeCategoryById(widget.existingAttributeCategoryModel!.id).then((value){
        setState(() {
          widget.existingAttributeCategoryModel!.serverId = value.serverId;

        });
      });
      widget.nameController.text = widget.existingAttributeCategoryModel!.name;
      widget.displayNameController.text = widget.existingAttributeCategoryModel!.displayName!=null?widget.existingAttributeCategoryModel!.displayName!:"";
      widget.buttonColorController.text = widget.existingAttributeCategoryModel!.color!=null?widget.existingAttributeCategoryModel!.color!:"#FFFFFF";
      if(widget.existingAttributeCategoryModel!.imagePath!=null) {
        _image = File(widget.existingAttributeCategoryModel!.imagePath!);
        selectedImagePath = widget.existingAttributeCategoryModel!.imagePath!;
      }
    }
    else{
      widget.buttonColorController.text = "ffffff";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarOptifood(),
      body: Container(
          child: Stack(
            children: [
              SingleChildScrollView(
                  child: Form(
                    key: _globalKey,
                    child: Column(
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

                              child: Container( // Container to add shaddow for circular avatar
                                width: 65,
                                decoration: BoxDecoration(
                                    color: Colors.white,
                                    shape: BoxShape.circle,
                                    boxShadow: [BoxShadow(blurRadius: 5, color: Colors.black12,spreadRadius: 2)]
                                ),
                                child: GestureDetector(
                                  child: CircleAvatar( // outer cicleavatar to add white border around actual avatar
                                    backgroundColor: Colors.white,
                                    radius: 55,
                                    child: CircleAvatar( // actual circle avatar
                                      backgroundImage: _image==null?null:FileImage(_image),
                                      backgroundColor: Colors.white,
                                      radius: 50,
                                      child: _image!=null?null:
                                      SvgPicture.asset(AppImages.addLogoIcon,
                                          height: 35),
                                    ),
                                  ),
                                  onTap: () async { // on click of circle avatar
                                    //final image = await ImagePicker().getImage(source: ImageSource.gallery);
                                    final image = await ImagePicker().pickImage(source: ImageSource.gallery);
                                    if(image == null) return;
                                    final imageTemp = File(image.path);
                                    selectedImagePath = image.path;
                                    fileName = image.path.split('/').last;
                                    setState(() => this._image = imageTemp); // setting selected image to cirlce avatar
                                  },
                                ),
                              ),

                            ),
                            if(selectedImagePath!=null)...[
                              GestureDetector(
                                child: Center(
                                  child: Container(
                                      padding: EdgeInsets.all(3),
                                      margin: EdgeInsets.only(top: 40, left: 70),
                                      child: Icon(
                                        Icons.close, color: Colors.white,),
                                      decoration: BoxDecoration(
                                        color: AppTheme.colorDarkGrey,
                                        shape: BoxShape.circle,
                                      )
                                  ),
                                ),
                                onTap: (){
                                  setState((){
                                    selectedImagePath = null;
                                    _image = null;
                                  });
                                },
                              )
                            ]
                          ],
                        ),
                        CustomFieldWithNoIcon(
                          // data: Icons.email,
                          validator: (value){
                            if(value==null || value.isEmpty) {
                              return "pleaseEnterAttributeCategoryName".tr();
                            }
                            else{
                              return null;
                            }
                          },
                          controller: widget.nameController,
                          hintText: "attributeCategoryName".tr(),
                          isObsecre: false,
                          placeholder: "lastName".tr(),
                          outerIcon: SvgPicture.asset(AppImages.attributesIcon, height: 35, color: AppTheme.colorDarkGrey,),
                          textCapitalization: TextCapitalization.sentences,

                        ),
                        CustomFieldWithNoIcon(
                          // data: Icons.email,
                          controller: widget.displayNameController,
                          hintText: "displayName".tr(),
                          isObsecre: false,
                          //outerIcon: SvgPicture.asset("assets/images/icons/phone-client.svg", height: 35, color: AppTheme.colorDarkGrey,),
                        ),
                        ListTile(
                          //contentPadding: EdgeInsets.only(right: 15),
                            contentPadding: EdgeInsets.zero,
                            horizontalTitleGap: 0,
                            dense: true,
                            title:

                            CustomFieldWithNoIcon(
                              // data: Icons.email,
                              controller: widget.buttonColorController,
                              hintText: "buttonBackgroundColor".tr(),
                              isObsecre: false,
                              readOnly: true,
                              suffixIcon: IconButton(icon:Icon(Icons.copy),onPressed: (){
                                Clipboard.setData(ClipboardData(text:widget.buttonColorController.text.toString()));
                                Utility().showToastMessage("Copied");
                              },),
                              onTap: (){
                                showDialog(
                                    context: context,
                                    builder: (BuildContext context){
                                      return AlertDialog(
                                        //title: Text('Pick a color!'),
                                        title: Text(''),
                                        content: SingleChildScrollView(
                                          child: ColorPicker(
                                            pickerColor: AppTheme.colorRed, //default color
                                            onColorChanged: (Color color){ //on color picked
                                              setState(() {
                                                //mycolor = color;
                                                widget.buttonColorController.text = color.value.toRadixString(16);
                                              });
                                            },
                                          ),
                                        ),
                                        actions: <Widget>[
                                          ElevatedButton(
                                            child: const Text('done').tr(),
                                            onPressed: () {
                                              Navigator.of(context).pop(); //dismiss the color picker
                                            },
                                          ),
                                        ],
                                      );
                                    }
                                );
                              },
                              outerIcon: SvgPicture.asset(AppImages.colorIcon, height: 35, color: AppTheme.colorDarkGrey,),
                            ),
                            trailing: Container(height: 45,width: 45,
                                margin: EdgeInsets.only(right: 15),
                                decoration: BoxDecoration(
                                  border: Border.all(color: AppTheme
                                      .colorGrey),
                                  color: Color(int.parse("0xff"+widget.buttonColorController.text)),
                                )
                              //color: Colors.red,
                            )
                        ),

                        Padding(
                          padding: const EdgeInsets.only(left: 60,right: 55,top: 20,bottom: 20),
                          child: Container(
                            height:45 ,
                            width: 300,
                            decoration: BoxDecoration(
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
                                  Text('save', style: TextStyle(fontSize: 18.0, color: Colors.white),).tr(),
                                ],
                              ),
                              onPressed: () async {
                                if (_globalKey.currentState!.validate()==false) {
                                  return;
                                }
                                AttributeCategoryModel attributeCategoryModel = AttributeCategoryModel(
                                    1,
                                    widget.nameController.text.trim(),
                                    widget.displayNameController.text,
                                    widget.buttonColorController.text,
                                    1,
                                    selectedImagePath
                                );
                                if(widget.existingAttributeCategoryModel!=null){
                                  attributeCategoryModel.id = widget.existingAttributeCategoryModel!.id;
                                  attributeCategoryModel.attributeCount = widget.existingAttributeCategoryModel!.attributeCount;
                                  attributeCategoryModel.position = widget.existingAttributeCategoryModel!.position;
                                  attributeCategoryModel.serverId = widget.existingAttributeCategoryModel!.serverId;
                                  await AttributeCategoryDao().getAttributeCategoryByName(attributeCategoryModel.name).then((value) async {
                                    if(value.length>0 && value.first.id!=attributeCategoryModel.id){

                                      Utility().showToastMessage("attributeCategoryAlreadyExists".tr());

                                      // final snackBar = SnackBar(
                                      //   duration: const Duration(milliseconds: 500),
                                      //   content: const Text('Attribute Category already exists',style: TextStyle(color: AppTheme.colorRed,fontSize: 18),),
                                      //   backgroundColor: (Colors.grey),
                                      // );
                                      // ScaffoldMessenger.of(context).showSnackBar(snackBar);
                                    }
                                    else{
                                      attributeCategoryModel.isSyncedOnServer = false;
                                      attributeCategoryModel.isSyncOnServerProcessing = true;
                                      attributeCategoryModel.syncOnServerActionPending = ConstantSyncOnServerPendingActions.ACTION_PENDING_UPDATE;
                                      await AttributeCategoryDao().updateAttributeCategory(attributeCategoryModel).then((value){
                                        //updateAttributeCategoryToSever(attributeCategoryModel.serverId);
                                        AttributeCategoryApi().saveAttributeCategoryToSever(attributeCategoryModel,isUpdate: true);
                                      });
                                      Navigator.pop(context,attributeCategoryModel);
                                    }
                                  });


                                }
                                else {
                                  await AttributeCategoryDao().getAttributeCategoryByName(attributeCategoryModel.name).then((value) async {

                                    if(value.length>0){
                                      Utility().showToastMessage("attributeCategoryAlreadyExists".tr());

                                      // final snackBar = SnackBar(
                                      //   duration: const Duration(milliseconds: 500),
                                      //   content: const Text('Attribute Category already exists',style: TextStyle(color: AppTheme.colorRed,fontSize: 18),),
                                      //   backgroundColor: (Colors.grey),
                                      // );
                                      // ScaffoldMessenger.of(context).showSnackBar(snackBar);
                                    }
                                    else{
                                      attributeCategoryModel.isSyncedOnServer = false;
                                      attributeCategoryModel.isSyncOnServerProcessing = true;
                                      attributeCategoryModel.syncOnServerActionPending = ConstantSyncOnServerPendingActions.ACTION_PENDING_CREATE;
                                      await AttributeCategoryDao().insertAttributeCategory(attributeCategoryModel).then((value) => {
                                        //saveAttributeCategoryToSever(_image, fileName)
                                        AttributeCategoryApi().saveAttributeCategoryToSever(attributeCategoryModel)
                                      });
                                      Navigator.pop(context,attributeCategoryModel);

                                    }
                                  // attributeCategoryModel.isSyncedOnServer = false;
                                  // await AttributeCategoryDao().insertAttributeCategory(attributeCategoryModel).then((value) async {
                                  //   //ProductApis.saveAttributeCategoryToSever(_image, fileName)
                                  //   optifoodBackgroundService.syncAttributeCategory();
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
            ],
          )
      ),
    );
  }
  /*saveAttributeCategoryToSever(var _image, String fileName)async{
    final dio = Dio();
    dio.options.headers['X-TenantID'] = ServerData.OPTIFOOD_DATABASE;
    AttributeCategoryDao().getAttributeCategoryLast().then((value) async{
      var formData;
      if(_image==null) {
        formData = FormData.fromMap({
          'attributeCategoryName': value.name,
          'color': value.color,
          'position': value.position,
        });
      }
      else{
        formData = FormData.fromMap({
          'attributeCategoryName': value.name,
          'color': value.color,
          'position': value.position,
          'image': MultipartFile.fromBytes(_image.readAsBytesSync(), filename: fileName),
        });
      }
      var response = await dio.post(ServerData.OPTIFOOD_BASE_URL+'/api/attribute-category',
        data: formData,
      ).then((response){
        var singleData = AttributeCategoryModel.fromJsonServer(response.data);
        value.isSyncedOnServer=true;
        value.serverId=singleData.serverId;
        AttributeCategoryDao().updateAttributeCategory(value).then((value2222222){

        });
      }).catchError((onError){

      });
    });

  }*/

  /*void updateAttributeCategoryToSever(int? serverId) {
    final dio = Dio();
    dio.options.headers['X-TenantID'] = ServerData.OPTIFOOD_DATABASE;
    AttributeCategoryDao().getAttributeCategoryByServerId(serverId!).then((value) async{
      var formData;

      if(_image==null || _image.toString().length<=9) {
        formData = FormData.fromMap({
          'attributeCategoryName': value?.name,
          'color': value?.color,
          'position': value?.position,
        });
      }
      else{
        formData = FormData.fromMap({
          'attributeCategoryName': value?.name,
          'color': value?.color,
          'position': value?.position,
          'image': MultipartFile.fromBytes(_image.readAsBytesSync(), filename: fileName),
        });
      }
      var response = await dio.put(ServerData.OPTIFOOD_BASE_URL+"/api/attribute-category/${serverId}",
        data: formData,
      ).then((value33333){
        // Navigator.pop(context,value);

      }).catchError((onError){
        // Navigator.pop(context,value);

      });
    });
  }*/




}