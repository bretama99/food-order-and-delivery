import 'dart:io';
import 'package:dio/dio.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:image_picker/image_picker.dart';
import 'package:opti_food_app/api/company_api.dart';
import 'package:opti_food_app/assets/images.dart';
import 'package:opti_food_app/data_models/company_model.dart';
import 'package:opti_food_app/database/company_dao.dart';
import 'package:opti_food_app/widgets/appbar/app_bar_optifood.dart';

import '../../utils/constants.dart';
import '../../widgets/app_theme.dart';
import '../../widgets/custom_field_with_no_icon.dart';
import 'package:flutter_google_places/flutter_google_places.dart';
import 'package:google_maps_webservice/places.dart';

import '../MountedState.dart';

class AddCompany extends StatefulWidget{
  CompanyModel? existingCompanyModel; // having value only when edit company
  TextEditingController nameController = new TextEditingController();
  TextEditingController phoneController = new TextEditingController();
  TextEditingController addressController = new TextEditingController();
  TextEditingController emailController = new TextEditingController();

  AddCompany({this.existingCompanyModel=null});

  @override
  State<StatefulWidget> createState() => _AddCompanyState();

}
class _AddCompanyState extends MountedState<AddCompany>{
  final GlobalKey<FormState> _globalKey = GlobalKey<FormState>();
  var _image;
  var selectedImagePath = null;
  late String fileName="";

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    if(widget.existingCompanyModel!=null){
      CompanyDao().getCompanyById(widget.existingCompanyModel!.id).then((value) {
        // print("==============CompanyDao().getCompanyById======${value.}===================================");
        widget.existingCompanyModel!.serverId = value.serverId;
      });
      widget.nameController.text = widget.existingCompanyModel!.name;
      widget.addressController.text = widget.existingCompanyModel!.address!;
      widget.phoneController.text = widget.existingCompanyModel!.phoneNo!;
      widget.emailController.text = widget.existingCompanyModel!.email!;
      if(widget.existingCompanyModel!.imagePath!=null) {
        _image = File(widget.existingCompanyModel!.imagePath!);
      }
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarOptifood(),
      body: Container(
          child: Stack(
            children: [
              // Positioned(
              //top: 5,
              /*child: Container(
                    decoration: const BoxDecoration(
                        shape: BoxShape.rectangle,
                        color:Color(0xfffafafa),
                        borderRadius: BorderRadius.only(
                            bottomLeft: Radius.circular(280), bottomRight: Radius.circular(280))
                    ),
                    child: Row(
                      children: [
                        Transform.translate(
                          offset:Offset(0,-70),
                          child: GestureDetector(
                            onTap: (){
                              // Navigator.of(context).pop();
                            },
                            child: const Padding(
                              padding: EdgeInsets.only(left: 55),
                              child: Align(
                                alignment: Alignment.topLeft,
                                child: CircleAvatar(
                                  radius: 20.0,
                                  backgroundColor: Color(0xfffafafa),
                                  // child: Icon(Icons.close, color: Colors.black),
                                ),
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(10, 30, 0, 30),
                          child: Transform.translate(
                              offset: Offset(-50,0),
                              //child: Image.asset(AppImages.optiFoodLogoIcon,height: 180,width: 360,)
                          ),
                        ),
                      ],
                    ))*/
              // ),
              //Positioned(
              //top: 250,

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
                                    //offset: Offset(0, 1), // changs position of shadow
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
                        /*Container(margin: EdgeInsets.only(bottom: 20),
                      child: Container(
                        height: 0,
                        decoration: BoxDecoration(
                          color: AppTheme.colorLightGrey,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black12,
                              spreadRadius: 2,
                              blurRadius: 5,
                              //offset: Offset(0, 1), // changs position of shadow
                            ),
                          ],
                        ),
                      )
                    ),*/
                        CustomFieldWithNoIcon(
                          // data: Icons.email,
                          validator: (value){
                            if(value==null || value.isEmpty) {
                              return "pleaseEnterCompanyName".tr();
                            }
                            else{
                              return null;
                            }
                          },
                          controller: widget.nameController,
                          hintText: "companyName".tr(),
                          isObsecre: false,
                          placeholder: "lastName".tr(),
                          outerIcon: SvgPicture.asset(AppImages.companyIcon, height: 35, color: AppTheme.colorDarkGrey,),
                          textCapitalization: TextCapitalization.sentences,

                        ),
                        CustomFieldWithNoIcon(
                          // data: Icons.email,
                          controller: widget.phoneController,
                          hintText: "phone".tr(),
                          isObsecre: false,
                          placeholder: "lastName".tr(),
                          textInputType: TextInputType.phone,
                          outerIcon: SvgPicture.asset(AppImages.phoneClientIcon, height: 35, color: AppTheme.colorDarkGrey,),
                        ),
                        CustomFieldWithNoIcon(
                          // data: Icons.email,

                          controller: widget.addressController,
                          hintText: "address".tr(),
                          readOnly: true,
                          onTap: () async {
                            Prediction? prediction = await PlacesAutocomplete.show(
                                context: context,
                                //apiKey: "AIzaSyDcvjlWKsTTa7aF4twb0Yu5YxJHSXqEEUs",
                                apiKey: "AIzaSyDzUrI1I9awcIGQViB8xEIzcMVLlPqmu_k",
                                types: ["address"],
                                components: [new Component(Component.country, "fr")],
                                mode: Mode.overlay, // Mode.fullscreen
                                language: "fr",
                                strictbounds: false
                            );
                            if(prediction!=null){
                              String placeAddress = prediction!.description!;
                              widget.addressController.text = placeAddress;
                            }
                          },
                          isObsecre: false,
                          placeholder: "lastName".tr(),
                          outerIcon: SvgPicture.asset(AppImages.clientAddressIcon, height: 35, color: AppTheme.colorDarkGrey,),
                        ),
                        CustomFieldWithNoIcon(
                          // data: Icons.email,
                          validator: (value){
                            if(value==null || value.isEmpty) {
                              return null;
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
                          placeholder: "lastName".tr(),
                          outerIcon: SvgPicture.asset(AppImages.emailIcon, height: 35, color: AppTheme.colorDarkGrey,),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 60,right: 55,top: 50),
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
                                CompanyModel companyModel = CompanyModel(widget.nameController.text,
                                    phoneNo: widget.phoneController.text,
                                    address: widget.addressController.text,
                                    email: widget.emailController.text,
                                    imagePath: selectedImagePath
                                );
                                if(widget.existingCompanyModel!=null){
                                  companyModel.id = widget.existingCompanyModel!.id;
                                  companyModel.serverId = widget.existingCompanyModel!.serverId;
                                  await CompanyDao().updateCompany(companyModel).then((value){
                                    CompanyApis().updateCompanyServer(companyModel.serverId);
                                  });
                                }
                                else {
                                  await CompanyDao()
                                      .insertCompany(companyModel).then((value){
                                        // saveCompanyToServer();
                                        //CompanyApis.saveCompanyToServer(_image, fileName);
                                        CompanyApis().saveCompanyToServer(companyModel);

                                  });
                                }
                                Navigator.pop(context,companyModel);
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

  /*void saveCompanyToServer() {
    final dio = Dio();
    dio.options.headers['X-TenantID'] = ServerData.OPTIFOOD_DATABASE;
    CompanyDao().getCompanyLast().then((value) async{
      var formData;
      if(_image==null){
        formData = FormData.fromMap({
          'companyName': value.name,
          'email': value.email,
          'phoneNumber': value.phoneNo,
          "address": value.address,
        });
      }
      else{
        formData = FormData.fromMap({
          'companyName': value.name,
          'email': value.email,
          'phoneNumber': value.phoneNo,
          "address": value.address,
          'image': MultipartFile.fromBytes(_image.readAsBytesSync(), filename: fileName),
        });
      }

      var response = await dio.post(ServerData.OPTIFOOD_BASE_URL+"/api/company",
        data: formData,
      ).then((response){
        var singleData = CompanyModel.fromJsonServer(response.data);
        value.isSynced=true;
        value.serverId=singleData.serverId;
        CompanyDao().updateCompany(value).then((value333) {
        });

      }).catchError((onError){
      });
    });
  }*/

  /*void updateCompanyServer(int? serverId) {
    final dio = Dio();
    dio.options.headers['X-TenantID'] = ServerData.OPTIFOOD_DATABASE;
    CompanyDao().getCompanyByServerId(serverId!).then((value) async{
      var formData;
      if(_image==null){
        formData = FormData.fromMap({
          'companyName': value!.name,
          'email': value.email,
          'phoneNumber': value.phoneNo,
          "address": value.address,
        });
      }
      else{
        formData = FormData.fromMap({
          'companyName': value!.name,
          'email': value.email,
          'phoneNumber': value.phoneNo,
          "address": value.address,
          'image': MultipartFile.fromBytes(_image.readAsBytesSync(), filename: fileName),
        });
      }

      var response = await dio.put(ServerData.OPTIFOOD_BASE_URL+"/api/company/${serverId}",
        data: formData,
      ).then((value1){
      }).catchError((onError){

      });
    });
  }*/

}