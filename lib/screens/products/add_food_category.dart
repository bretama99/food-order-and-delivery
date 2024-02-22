
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:flutter_svg/svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:opti_food_app/api/food_category_api.dart';
import 'package:opti_food_app/assets/images.dart';
import 'package:opti_food_app/data_models/company_model.dart';
import 'package:opti_food_app/database/company_dao.dart';
import 'package:opti_food_app/database/food_category_dao.dart';
import 'package:opti_food_app/utils/api/category.dart';
import 'package:opti_food_app/widgets/appbar/app_bar_optifood.dart';
import 'package:toast/toast.dart';
import '../../data_models/food_category_model.dart';
import '../../utils/constants.dart';
import '../../utils/utility.dart';
import '../../widgets/app_theme.dart';
import '../../widgets/custom_field_with_no_icon.dart';
import '../MountedState.dart';
class AddFoodCategory extends StatefulWidget{
  FoodCategoryModel? existingFoodCategoryModel; // having value only when edit company
  TextEditingController nameController = new TextEditingController();
  TextEditingController displayNameController = new TextEditingController();
  TextEditingController buttonColorController = new TextEditingController();
  TextEditingController rbHideInKitchenController = new TextEditingController();
  TextEditingController rbIsAttMandatoryController = new TextEditingController();
  bool swHideInKitchen = false;
  bool swIsAttributeMandatory = false;

  AddFoodCategory({this.existingFoodCategoryModel=null});

  @override
  State<StatefulWidget> createState() => _AddFoodCategoryState();

}
class _AddFoodCategoryState extends MountedState<AddFoodCategory>{
  final GlobalKey<FormState> _globalKey = GlobalKey<FormState>();
  var _image;
  var selectedImagePath = null;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    if(widget.existingFoodCategoryModel!=null){
      FoodCategoryDao().getFoodCategoryById(widget.existingFoodCategoryModel!.id).then((value) {
        widget.existingFoodCategoryModel!.serverId = value.serverId;
      });
      widget.nameController.text = widget.existingFoodCategoryModel!.name;
      widget.displayNameController.text = widget.existingFoodCategoryModel!.displayName!=null?widget.existingFoodCategoryModel!.displayName!:"";
      widget.buttonColorController.text = widget.existingFoodCategoryModel!.color!=null?widget.existingFoodCategoryModel!.color!:"#FFFFFF";
      widget.swHideInKitchen = widget.existingFoodCategoryModel!.isHideInKitchen;
      widget.swIsAttributeMandatory = widget.existingFoodCategoryModel!.isAttributeMandatory;
      if(widget.existingFoodCategoryModel!.imagePath!=null) {
        _image = File(widget.existingFoodCategoryModel!.imagePath!);
        selectedImagePath = widget.existingFoodCategoryModel!.imagePath!;
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
                              return "pleaseEnterCategoryName".tr();
                            }
                            else{
                              return null;
                            }
                          },
                          controller: widget.nameController,
                          hintText: "categoryName".tr(),
                          isObsecre: false,
                          placeholder: "lastName".tr(),
                          outerIcon: SvgPicture.asset(AppImages.productIcon, height: 35, color: AppTheme.colorDarkGrey,),
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
                        ListTile(
                          contentPadding: EdgeInsets.only(left: 10,right: 10),
                          leading: SvgPicture.asset(AppImages.eyeHiddenIcon, height: 35, color: AppTheme.colorDarkGrey,),
                          title: Text("hideInKitchen").tr(),
                          trailing: Switch(
                            activeColor: AppTheme.colorRed,
                            value: widget.swHideInKitchen, onChanged: (bool value) {
                              setState(() {
                                widget.swHideInKitchen = value;
                              });
                          },
                          ),
                        ),
                        ListTile(
                          contentPadding: EdgeInsets.only(left: 10,right: 10),
                          leading: SvgPicture.asset(AppImages.attributesIcon, height: 35, color: AppTheme.colorDarkGrey,),
                          title: Text("makeAttributesMandatory").tr(),
                          trailing: Switch(
                            activeColor: AppTheme.colorRed,
                            value: widget.swIsAttributeMandatory, onChanged: (bool value) {
                              setState(() {
                                widget.swIsAttributeMandatory = value;
                              });
                          },
                          ),
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
                                FoodCategoryModel foodCategoryModel = FoodCategoryModel(
                                    1,
                                    widget.nameController.text.trim(),
                                    widget.displayNameController.text,
                                    widget.buttonColorController.text,
                                    1,
                                    widget.swHideInKitchen,
                                    widget.swIsAttributeMandatory,
                                    selectedImagePath,
                                );
                                if(widget.existingFoodCategoryModel!=null){
                                  foodCategoryModel.id = widget.existingFoodCategoryModel!.id;
                                  foodCategoryModel.foodItemsCount = widget.existingFoodCategoryModel!.foodItemsCount;
                                  foodCategoryModel.position = widget.existingFoodCategoryModel!.position;
                                  foodCategoryModel.serverId = widget.existingFoodCategoryModel!.serverId;
                                  await FoodCategoryDao().getFoodCategoryByName(foodCategoryModel.name).then((value) async {
                                    if(value.length>0 && value.first.id!=foodCategoryModel.id){
                                      Utility().showToastMessage("itemCategoryAlreadyExists".tr());

                                      // final snackBar = SnackBar(
                                      //   duration: const Duration(milliseconds: 500),
                                      //   content: const Text('Item Category already exists',style: TextStyle(color: AppTheme.colorRed,fontSize: 18),),
                                      //   backgroundColor: (Colors.grey),
                                      // );
                                      // ScaffoldMessenger.of(context).showSnackBar(snackBar);
                                    }
                                    else{
                                      foodCategoryModel.isSyncedOnServer = false;
                                      foodCategoryModel.isSyncOnServerProcessing = true;
                                      foodCategoryModel.syncOnServerActionPending = ConstantSyncOnServerPendingActions.ACTION_PENDING_UPDATE;
                                      /*await FoodCategoryDao().updateFoodCategory(foodCategoryModel).then((value){
                                        FoodCategoryApi().saveFoodCategoryToSever(value,isUpdate: true);
                                      });*/
                                      await FoodCategoryDao().updateFoodCategory(foodCategoryModel);
                                      FoodCategoryApi().saveFoodCategoryToSever(foodCategoryModel,isUpdate: true);
                                      Navigator.pop(context,foodCategoryModel);
                                    }
                                  });


                                }
                                else {
                                  await FoodCategoryDao().getFoodCategoryByName(foodCategoryModel.name).then((value) async {
                                    if(value.length>0){
                                      Utility().showToastMessage("itemCategoryAlreadyExists".tr());
                                    }else{
                                      foodCategoryModel.isSyncedOnServer = false;
                                      foodCategoryModel.isSyncOnServerProcessing = true;
                                      foodCategoryModel.syncOnServerActionPending = ConstantSyncOnServerPendingActions.ACTION_PENDING_CREATE;
                                      await FoodCategoryDao().insertFoodCategory(foodCategoryModel).then((value){
                                        // saveFoodCategoryToSever();
                                        FoodCategoryApi().saveFoodCategoryToSever(value);
                                      });
                                      Navigator.pop(context,foodCategoryModel);
                                    }
                                  });

                                  // foodCategoryModel = await FoodCategoryDao()
                                  //     .insertFoodCategory(foodCategoryModel);
                                }
                              },
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
  late String fileName="";
  // saveFoodCategoryToSever(){
  //   print("=========brhane==============${MultipartFile.fromBytes(_image.readAsBytesSync(), filename: fileName)}==========================");
  // }
  /*saveFoodCategoryToSever()async{
    final dio = Dio();
    dio.options.headers['X-TenantID'] = ServerData.OPTIFOOD_DATABASE;
    FoodCategoryDao().getFoodCategoryLast().then((value) async{
      var formData;
      if(_image==null) {
        formData = FormData.fromMap({
          'itemCategoryName': value.name,
          'displayName': value.displayName,
          'color': value.color,
          'position': 6,
          "isAttributeRequired": value.isAttributeMandatory,
          "isShowKichen": value.isHideInKitchen
        });
      }
      else{
        formData = FormData.fromMap({
          'itemCategoryName': value.name,
          'displayName': value.displayName,
          'color': value.color,
          'position': value.position,
          'image': MultipartFile.fromBytes(_image.readAsBytesSync(), filename: fileName),
          "isAttributeRequired": value.isAttributeMandatory,
          "isShowKichen": value.isHideInKitchen
        });
      }
      var response = await dio.post(ServerData.OPTIFOOD_BASE_URL+"/api/item-category",
        data: formData,
      ).then((response){
        var singleData = FoodCategoryModel.fromJsonServer(response.data);
        value.isSynced=true;
        value.serverId=singleData.serverId;
          FoodCategoryDao().updateFoodCategory(value).then((value333) {
        });

      }).catchError((onError){
      });
    });


  }*/

 /* void updateFoodCategoryToSever(int? serverId) {
    final dio = Dio();
    dio.options.headers['X-TenantID'] = ServerData.OPTIFOOD_DATABASE;
    FoodCategoryDao().getFoodCategoryByServerId(serverId!).then((value) async{
      var formData;
      if(_image==null) {
        formData = FormData.fromMap({
          'itemCategoryName': value?.name,
          'displayName': value?.displayName,
          'color': value?.color,
          'position': value?.position,
          "isAttributeRequired": value?.isAttributeMandatory,
          "isShowKichen": value?.isHideInKitchen
        });
      }
      else{
        formData = FormData.fromMap({
          'itemCategoryName': value?.name,
          'displayName': value?.displayName,
          'color': value?.color,
          'position': value?.position,
          'image': MultipartFile.fromBytes(_image.readAsBytesSync(), filename: fileName),
          "isAttributeRequired": value?.isAttributeMandatory,
          "isShowKichen": value?.isHideInKitchen
        });
      }
      var response = await dio.put(ServerData.OPTIFOOD_BASE_URL+"/api/item-category/${serverId}",
        data: formData,
      ).then((value1){
      }).catchError((onError){

      });
    });
  }*/
  // insertFoodCategory() async {
  //
  //   final dio = Dio();
  //   print("selectedImagePath");
  //   print(fileName);
  //   FormData formData = FormData.fromMap({
  //     "itemCategoryName": "widget.nameController.text",
  //     "displayName": "widget.displayNameController.text",
  //     "image":MultipartFile.fromBytes(_image.readAsBytesSync(), filename: fileName),
  //     "color":"red",
  //     "position":1,
  //   "isAttributeRequired":true,
  //   "isShowKichen":true
  //
  //   });
  //   print("response.statusCode");
  //   dio.options.headers['X-TenantID'] = "optifood";
  //   var response= await dio.post("http://13.36.1.224:8092/api/item-category",
  //       data: formData);
  //
  //   print("response.statusCode");
  //   print(response.statusCode);
  //   print("response.statusCode");
  //
  //   if (response.statusCode == 200) {
  //     Scaffold.of(context).showSnackBar(SnackBar(content: Text("Welcome"),));
  //     Navigator.pop(context, true);
  //   }
  // }
}
