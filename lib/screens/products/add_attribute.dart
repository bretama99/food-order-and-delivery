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
import 'package:opti_food_app/api/attribute_api.dart';
import 'package:opti_food_app/api/product.dart';
import 'package:opti_food_app/assets/images.dart';
import 'package:opti_food_app/database/attribute_category_dao.dart';
import 'package:opti_food_app/widgets/appbar/app_bar_optifood.dart';
import '../../data_models/attribute_category_model.dart';
import '../../data_models/attribute_model.dart';
import '../../database/attribute_dao.dart';
import '../../utils/constants.dart';
import '../../utils/utility.dart';
import '../../widgets/app_theme.dart';
import '../../widgets/custom_field_with_no_icon.dart';
import '../MountedState.dart';
class AddAttribute extends StatefulWidget{
  AttributeModel? existingAttributeModel; // having value only when edit company
  AttributeCategoryModel attributeCategoryModel;
  TextEditingController nameController = new TextEditingController();
  TextEditingController displayNameController = new TextEditingController();
  TextEditingController priceController = new TextEditingController();
  TextEditingController buttonColorController = new TextEditingController();
  TextEditingController rbHideInKitchenController = new TextEditingController();
  TextEditingController rbIsAttMandatoryController = new TextEditingController();
  bool swHideInKitchen = false;
  bool swIsAttributeMandatory = false;

  AddAttribute(this.attributeCategoryModel,{this.existingAttributeModel=null});

  @override
  State<StatefulWidget> createState() => _AddAttributeState();

}
class _AddAttributeState extends MountedState<AddAttribute>{
  final GlobalKey<FormState> _globalKey = GlobalKey<FormState>();
  var _image;
  var selectedImagePath = null;
  late String fileName="";
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    AttributeCategoryDao().getAttributeCategoryById(widget.attributeCategoryModel!.id).then((value){
     setState(() {
       widget.attributeCategoryModel!.serverId = value.serverId;
     });
    });
    testApi();
    if(widget.existingAttributeModel!=null){
      AttributeDao().getAttributeById(widget.existingAttributeModel!.id).then((value) {
        setState(() {
          widget.existingAttributeModel!.serverId = value.serverId;

        });

      });
      widget.nameController.text = widget.existingAttributeModel!.name;
      widget.displayNameController.text = widget.existingAttributeModel!.displayName!=null?widget.existingAttributeModel!.displayName!:"";
      widget.buttonColorController.text = widget.existingAttributeModel!.color!=null?widget.existingAttributeModel!.color!:"#FFFFFF";
      widget.priceController.text = widget.existingAttributeModel!.price!=null?widget.existingAttributeModel!.price.toString():"0.00";
      if(widget.existingAttributeModel!.imagePath!=null) {
        _image = File(widget.existingAttributeModel!.imagePath!);
        selectedImagePath = widget.existingAttributeModel!.imagePath!;
      }
    }
    else{
      widget.buttonColorController.text = "ffffff";
    }
  }

  testApi()async{

    final dio = Dio();
    dio.options.headers['X-TenantID'] = 'optifood';
    var formData = FormData.fromMap({
      'attributeCategoryName': 'ATT CAT333',
      'color': "white",
      'position': 1,
      'image': ""
    });
    var response = await dio.get('http://13.36.1.224:8092/api/attribute-category'
    ).then((value) => {
    });
    // var response = await dio.post('http://13.36.1.224:8092/api/attribute-category',
    //     data: formData,
    //     options: Options(
    //       headers: {"X-TenantID": "optifood"},
    //     )
    // );

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarOptifood(),
      body: Container(
          child: Stack(
            children: [
              SingleChildScrollView(
                  child:
                  Form(
                    key: _globalKey,
                    child: Column(
                      children: [
                        Stack(
                          children: [
                            Container(
                              padding: EdgeInsets.only(top: 35,bottom: 35),
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
                              return "pleaseEnterAttributeName".tr();
                            }
                            else{
                              return null;
                            }
                          },
                          controller: widget.nameController,
                          hintText: "attributeName".tr(),
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
                            contentPadding: EdgeInsets.only(left: 10,right: 10,top: 15),
                            //contentPadding: EdgeInsets.zero,
                            leading: SvgPicture.asset(AppImages.euroSignIcon, height: 35, color: AppTheme.colorDarkGrey,),
                            title: Text("enterPrice").tr(),
                            trailing: Container(
                              width: 90,
                              child: CustomFieldWithNoIcon(
                                hintText: "price".tr(),
                                controller: widget.priceController,
                                isKeepSpaceForOuterIcon: false,
                                textInputType: TextInputType.number,
                              ),
                            )
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
                                  Text('save', style: const TextStyle(fontSize: 18.0, color: Colors.white),).tr(),
                                ],
                              ),
                              onPressed: () async {
                                if (_globalKey.currentState!.validate()==false) {
                                  return;
                                }
                                AttributeModel attributeModel = AttributeModel(
                                    1,
                                    widget.nameController.text.trim(),
                                    widget.displayNameController.text,
                                    widget.priceController.text.isEmpty?0:double.parse(widget.priceController.text),
                                    categoryID: widget.attributeCategoryModel.id,
                                    catServerId: widget.attributeCategoryModel.serverId,
                                    color:widget.buttonColorController.text,
                                    imagePath: selectedImagePath,

                                );
                                if(widget.existingAttributeModel!=null){
                                  attributeModel.serverId=widget.existingAttributeModel?.serverId;

                                  attributeModel.id = widget.existingAttributeModel!.id;
                                  attributeModel.position = widget.existingAttributeModel!.position;
                                  await AttributeDao().getAttributeByName(attributeModel.name).then((value) async {
                                    if(value.length>0 && value.first.id!=attributeModel.id){
                                      Utility().showToastMessage("attributeAlreadyExists".tr());

                                      // final snackBar = SnackBar(
                                      //   duration: const Duration(milliseconds: 500),
                                      //   content: const Text('Attribute already exists',style: TextStyle(color: AppTheme.colorRed,fontSize: 18),),
                                      //   backgroundColor: (Colors.grey),
                                      // );
                                      // ScaffoldMessenger.of(context).showSnackBar(snackBar);
                                    }
                                    else{
                                      attributeModel.isSyncedOnServer = false;
                                      attributeModel.isSyncOnServerProcessing = true;
                                      attributeModel.syncOnServerActionPending = ConstantSyncOnServerPendingActions.ACTION_PENDING_CREATE;
                                      await AttributeDao().updateAttribute(attributeModel).then((value){
                                        //updateAttributeToSever(attributeModel.serverId);
                                        AttributeApi().saveAttributeToSever(attributeModel,isUpdate: true);
                                      });
                                      Navigator.pop(context,attributeModel);
                                    }
                                  });
                                }
                                else {
                                  await AttributeDao().getAttributeByName(attributeModel.name).then((value) async {
                                    if(value.length>0){
                                      Utility().showToastMessage("attributeAlreadyExists".tr());
                                      // final snackBar = SnackBar(
                                      //   duration: const Duration(milliseconds: 500),
                                      //   content: const Text('Attribute already exists',style: TextStyle(color: AppTheme.colorRed,fontSize: 18),),
                                      //   backgroundColor: (Colors.grey),
                                      // );
                                      // ScaffoldMessenger.of(context).showSnackBar(snackBar);
                                    }
                                    else{
                                      attributeModel.isSyncedOnServer = false;
                                      attributeModel.isSyncOnServerProcessing = true;
                                      attributeModel.syncOnServerActionPending = ConstantSyncOnServerPendingActions.ACTION_PENDING_CREATE;
                                      await AttributeDao()
                                          .insertAttribute(widget.attributeCategoryModel,attributeModel).then((value) {
                                        //saveAttributeToSever(_image, fileName);
                                        AttributeApi().saveAttributeToSever(attributeModel);
                                      });
                                      Navigator.pop(context,attributeModel);

                                    }
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

              //)
            ],
          )
      ),
    );
  }

  /* saveAttributeToSever(var _image, String fileName)async{
    final dio = Dio();
    dio.options.headers['X-TenantID'] = ServerData.OPTIFOOD_DATABASE;
    AttributeDao().getAttributeLast().then((value) async{
      var formData;
      if(_image==null) {
        formData = FormData.fromMap({
          'attributeCategoryId': value.catServerId,
          'name': value.name,
          'position': value.position,
          'color': value.color,
          "price":value.price,
          // 'attributePriceId': value.price,
          // 'attributePriceResponseModel': {},
          // 'description': "",
          'displayName': value.displayName,
          // 'status': "Active",
        });
      }
      else{
        formData = FormData.fromMap({
          'attributeCategoryId': value.catServerId,
          'name': value.name,
          'position': value.position,
          'color': value.color,
          "price":value.price,
          'displayName': value.displayName,
          'image': MultipartFile.fromBytes(
              _image.readAsBytesSync(), filename: fileName),
        });
      }
      var response = await dio.post(ServerData.OPTIFOOD_BASE_URL+"/api/attribute",
        data: formData,
      ).then((response){
        print("=====================hh=======================mmm");

        var singleData = AttributeModel.fromJsonServer(response.data);
        value.isSynced=true;
        value.serverId=singleData.serverId;
          AttributeDao().updateAttribute(value).then((value22222){
        });
      }).catchError((onError){

      });
    });
  }*/


 /* void updateAttributeToSever(int? serverId) {
    final dio = Dio();
    dio.options.headers['X-TenantID'] = ServerData.OPTIFOOD_DATABASE;
    AttributeDao().getAttributeByServerId(serverId!).then((value) async{

      var formData;
      if(_image==null) {
        formData = FormData.fromMap({
          'attributeCategoryId': value?.catServerId,
          'name': value?.name,
          'position': value?.position,
          'color': value?.color,
          "price":value?.price,
          'displayName': value?.displayName,
          // 'status': "Active",
        });
      }
      else{
        formData = FormData.fromMap({
          'attributeCategoryId': value?.catServerId,
          'name': value?.name,
          'position': value?.position,
          'color': value?.color,
          'displayName': value?.displayName,
          "price":value?.price,
          'image': MultipartFile.fromBytes(
              _image.readAsBytesSync(), filename: fileName),
        });
      }
      var response = await dio.put(ServerData.OPTIFOOD_BASE_URL+"/api/attribute/${serverId}",
        data: formData,
      ).then((value){
        print("=============================================");
      }).catchError((onError){
        print("===================${onError}==========================");

      });
    });
  }*/

}