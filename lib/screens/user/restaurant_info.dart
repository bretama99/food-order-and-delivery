
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_google_places/flutter_google_places.dart';
import 'package:flutter_svg/svg.dart';
import 'package:image_picker/image_picker.dart';
import 'package:opti_food_app/assets/images.dart';
import 'package:opti_food_app/data_models/restaurant_info_model.dart';
import 'package:opti_food_app/database/restaurant_info_dao.dart';
import 'package:opti_food_app/utils/app_config.dart';
import 'package:opti_food_app/widgets/form_widgets/select_profile_image.dart';
import '../../main.dart';
import '../../utils/constants.dart';
import '../../utils/utility.dart';
import '../../widgets/app_theme.dart';
import '../../widgets/appbar/app_bar_optifood.dart';
import '../../widgets/custom_field_with_no_icon.dart';
import 'package:google_maps_webservice/places.dart';

import '../../widgets/time_form_field.dart';
import '../MountedState.dart';
class RestaurantInfo extends StatefulWidget {
  TextEditingController nameController = new TextEditingController();
  TextEditingController phoneNumberController = new TextEditingController();
  TextEditingController addressController = new TextEditingController();
  TextEditingController startTimeController = new TextEditingController();
  TextEditingController endTimeController = new TextEditingController();
  TextEditingController emailController = new TextEditingController();

  late SelectProfileImage _selectProfileImage;

  RestaurantInfoModel? existingRestaurantInfoModel;
  @override
  State<StatefulWidget> createState() => _RestaurantInfoState();
}
class _RestaurantInfoState extends MountedState<RestaurantInfo> {
  var selectedImagePath = null;
  final GlobalKey<FormState> _globalKey = GlobalKey<FormState>();
  double clientLat = 0;
  double clientLon = 0;

  double clientLatFromDatabase = 0;
  double clientLonFromDatabase = 0;
  var _image;
  TextEditingController startTimeController1 = new TextEditingController();
  @override
  void initState() {
    super.initState();
    widget._selectProfileImage = SelectProfileImage(selectedImagePath, (String path){
      selectedImagePath = path;
    });
    RestaurantInfoDao().getRestaurantInfo().then((value){
      print("Data fetched");

      print(value.name);
      setState(() {
      if(value.id==0){
        widget.existingRestaurantInfoModel = null;
      }
      else{
        widget.existingRestaurantInfoModel = value;
      }
      if(widget.existingRestaurantInfoModel!=null){
        widget.nameController.text = widget.existingRestaurantInfoModel!.name;
        widget.phoneNumberController.text = widget.existingRestaurantInfoModel!.phoneNumber;
        widget.addressController.text = widget.existingRestaurantInfoModel!.address;
        widget.startTimeController.text = widget.existingRestaurantInfoModel!.startTime;
        widget.endTimeController.text = widget.existingRestaurantInfoModel!.endTime;
        widget.emailController.text = widget.existingRestaurantInfoModel!.email;
        clientLatFromDatabase = widget.existingRestaurantInfoModel!.lat;
        clientLonFromDatabase = widget.existingRestaurantInfoModel!.lon;
        if(widget.existingRestaurantInfoModel!.imagePath!=null) {
          _image = File(widget.existingRestaurantInfoModel!.imagePath!);
          selectedImagePath = widget.existingRestaurantInfoModel!.imagePath!;
        }


          // if(widget.existingRestaurantInfoModel!.imagePath!=null) {
          //   selectedImagePath = widget.existingRestaurantInfoModel!.imagePath;
          //   //widget._selectProfileImage.selectedImagePath = widget.existingRestaurantInfoModel!.imagePath;
          //   widget._selectProfileImage.updateImage(widget.existingRestaurantInfoModel!.imagePath!);
          //   print(selectedImagePath);
          // }

      }
            });
    });
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

                  /*SelectProfileImage(selectedImagePath,(String path){
                      selectedImagePath = path;
                      print(selectedImagePath);
                    }),*/
                  // widget._selectProfileImage,
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
                      //outerIcon: SvgPicture.asset(widget.userRole==ConstantUserRole.USER_ROLE_WAITER?"assets/svg/icons/settings/waiter.svg":"assets/svg/icons/settings/delivery_boy.svg", height: 35, color: AppTheme.colorDarkGrey,)
                      outerIcon: SvgPicture.asset(AppImages.restaurant, height: 35, color: AppTheme.colorDarkGrey,)
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
                    padding: const EdgeInsets.only(top: 11,bottom: 11),
                    child: CustomFieldWithNoIcon(
                      // data: Icons.email,
                      validator: (value){
                        if(value==null || value.isEmpty) {
                          return "pleaseEnterAddress".tr();
                        }
                        else{
                          return null;
                        }
                      },
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

                          GoogleMapsPlaces _places = GoogleMapsPlaces(apiKey: "AIzaSyDzUrI1I9awcIGQViB8xEIzcMVLlPqmu_k");
                          PlacesDetailsResponse detail = await _places.getDetailsByPlaceId(prediction!.placeId!);
                          clientLat = detail.result.geometry!.location.lat;
                          clientLon = detail.result.geometry!.location.lng;
                        }
                      },
                      controller: widget.addressController,
                      hintText: "address".tr(),
                      isObsecre: false,
                      placeholder: "address".tr(),
                      outerIcon: SvgPicture.asset(AppImages.clientAddressIcon, height: 35, color: AppTheme.colorDarkGrey,),
                    ),
                  ),
                  // Padding(
                  //   padding: const EdgeInsets.only(top: 11,bottom: 11),
                  TimeFormField(
                    controller: widget.startTimeController,
                    isObsecre: false,
                    enabled: true,
                    hintText: "startTime".tr(),
                    outerIcon: SvgPicture.asset(AppImages.timeIcon, height: 35, color: AppTheme.colorDarkGrey,),
                    isKeepSpaceForOuterIcon: true,
                  ),
                  /*CustomFieldWithNoIcon(
                      // data: Icons.email,
                      controller: widget.startTimeController,
                      hintText: "Start Time",
                      isObsecre: false,
                      readOnly: true,
                      onTap: (){
                        _showTimePicker(widget.startTimeController);
                      },
                      outerIcon: SvgPicture.asset(AppImages.timeIcon, height: 35, color: AppTheme.colorDarkGrey,),
                    ),*/
                  // ),
                  TimeFormField(
                    controller: widget.endTimeController,
                    isObsecre: false,
                    enabled: true,
                    hintText: "endTime".tr(),
                    outerIcon: SvgPicture.asset(AppImages.timeIcon, height: 35, color: AppTheme.colorDarkGrey,),
                    isKeepSpaceForOuterIcon: true,
                  ),
                  /*Padding(
                    padding: const EdgeInsets.only(top: 11,bottom: 11),
                    child: CustomFieldWithNoIcon(
                      // data: Icons.email,
                      controller: widget.endTimeController,
                      hintText: "End Time",
                      isObsecre: false,
                      readOnly: true,
                      onTap: (){
                        _showTimePicker(widget.endTimeController);
                      },
                      outerIcon: SvgPicture.asset(AppImages.timeIcon, height: 35, color: AppTheme.colorDarkGrey,),
                    ),
                  ),*/
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
                    padding: const EdgeInsets.only(left: 60,right: 55,top: 50,bottom: 50),
                    child: Container(
                      height:45 ,

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
                          RestaurantInfoModel restaurantInfoModel1 = await RestaurantInfoDao().getRestaurantInfo();
                          String startTime = restaurantInfoModel1.startTime;
                          String closeTime = restaurantInfoModel1.endTime;
                          TimeOfDay _time = TimeOfDay.now();
                          int minutes=(AppConfig.dateTime.timeZoneOffset.inMinutes%60) as int;
                          int hours=((AppConfig.dateTime.timeZoneOffset.inMinutes/60).toInt())+(((_time.minute+minutes)/60).toInt());
                          TimeOfDay newTime = _time.replacing(
                              hour: (_time.hour+(hours))%23,
                              minute: (_time.minute+minutes)%60
                          );
                          if(startTime!=null && startTime!="" && startTime!=''){
                             int startTomeInMin=(int.parse(startTime.split(":")[0])*60+int.parse(startTime.split(":")[0]));
                             int closeTimeInMin=(int.parse(closeTime.split(":")[0])*60+int.parse(closeTime.split(":")[0]));
                                // if(startTomeInMin<closeTimeInMin){
                                //   if((newTime.hour*60+newTime.minute)>startTomeInMin && (newTime.hour*60+newTime.minute)<closeTimeInMin){
                                //     Utility().showToastMessage(
                                //       "validationForChangingOpeingAndClosingTime".tr(),
                                //       fontSize: 12
                                //     );
                                //     return;
                                //   }
                                //
                                // }

                             // if(startTomeInMin>closeTimeInMin){
                             //   if((newTime.hour*60+newTime.minute)>startTomeInMin && (newTime.hour*60+newTime.minute)<(23*60+60
                             //   ) || ((newTime.hour*60+newTime.minute)>0 && (newTime.hour*60+newTime.minute)<closeTimeInMin)){
                             //     Utility().showToastMessage("validationForChangingOpeingAndClosingTime".tr());
                             //     return;
                             //   }
                             //
                             // }
                          }


                          List<String> dateTimeList = Utility().generateShiftTiming(widget.startTimeController.text, widget.endTimeController.text);
                          optifoodSharedPrefrence.setString("end_shift_date_time",dateTimeList[1]);
                          RestaurantInfoModel restaurantInfoModel = RestaurantInfoModel(1,widget.nameController.text,widget.phoneNumberController.text,
                              widget.addressController.text,widget.startTimeController.text,  widget.endTimeController.text,widget.emailController.text,
                              imagePath: selectedImagePath, lat: clientLat!=0?clientLat:clientLatFromDatabase, lon: clientLon!=0?clientLon:clientLonFromDatabase);
                          if(widget.existingRestaurantInfoModel!=null){
                            print("existingggggggg ${widget.existingRestaurantInfoModel!.id!} = ${widget.existingRestaurantInfoModel!.name!}=${widget.existingRestaurantInfoModel!.startTime}");
                            restaurantInfoModel.id = widget.existingRestaurantInfoModel!.id;
                            restaurantInfoModel.serverId = widget.existingRestaurantInfoModel!.serverId;
                            await RestaurantInfoDao().updateRestaurantInfo(restaurantInfoModel).then((value){
                              optifoodSharedPrefrence.setString("hour", restaurantInfoModel.startTime.substring(0,2));
                              optifoodSharedPrefrence.setString("minute", restaurantInfoModel.startTime.substring(3,5));
                              updateRestaurantInfoToSever(widget.existingRestaurantInfoModel!.serverId);
                            });
                            Navigator.pop(context, restaurantInfoModel);
                          }
                          else {
                            await RestaurantInfoDao().insertRestaurantInfo(
                                restaurantInfoModel).then((value) {
                              optifoodSharedPrefrence.setString("hour", restaurantInfoModel.startTime.substring(0,2));
                              optifoodSharedPrefrence.setString("minute", restaurantInfoModel.startTime.substring(3,5));
                              saveRestaurantInfoToSever();
                            });
                            Navigator.pop(context, restaurantInfoModel);
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

  saveRestaurantInfoToSever()async{
    final dio = Dio();
    dio.options.headers['X-TenantID'] = optifoodSharedPrefrence.getString("database").toString();
    dio.options.headers['Authorization'] = optifoodSharedPrefrence.getString("accessToken").toString();
    RestaurantInfoDao().getRestaurantInfo().then((value) async{
      var formData;
      if(_image!=null) {
        formData = FormData.fromMap({
          "restaurantName": value!.name,
          "companyId": 1,
          "openingTime": value!.startTime,
          "closingTime": value!.endTime,
          "address": value!.address,
          "cityName": "Adwa",
          "email": value!.email,
          "phoneNumber": value!.phoneNumber,
          "websiteLink": "https://medcoanalytics.com",
          "contactId": 0,
          "chainId": 0,
          "dateTimeZone":AppConfig.dateTime.timeZoneOffset.inMinutes,
          'image': MultipartFile.fromBytes(
              _image.readAsBytesSync(), filename: fileName),
          "database": "restaurantOne",
          "url": "url",
          "username": "bre",
          "password": "123456",
          "lat": value.lat,
          "lon": value.lon,
        });
      }
      else{
        print("====name==${value.name}==startTime=${value.startTime}==endtime=${value.endTime}=email==${value.email}=address==${value.address}=phone=${value.phoneNumber}====================");
        print("====name==${value.lat}==startTime=${value.lon}==endtime==endddddddddddd===================");
        formData = FormData.fromMap({
          "restaurantName": value!.name,
          "companyId": 0,
          "openingTime": value!.startTime,
          "closingTime": value!.endTime,
          "address": value!.address,
          "cityName": "Adwa",
          "email": value!.email,
          "phoneNumber": value!.phoneNumber,
          "websiteLink": "https://add.com",
          "contactId": 0,
          "chainId": 0,
          "database": "restaurantOne",
          "url": "url",
          "dateTimeZone":AppConfig.dateTime.timeZoneOffset.inMinutes,
          "username": "bre",
          "password": "123456",
          "lat": value.lat,
          "lon": value.lon,
        });
      }
      var response = await dio.post(ServerData.OPTIFOOD_BASE_URL+"/api/restaurant",
          data: formData
      ).then((response){
        print("==================widget._selectProfileImageooooooooooooo======${response.data}=====================================");

        var singleData = RestaurantInfoModel.fromJsonServer(response.data);
        value.isSynced=true;
        value.serverId=singleData.serverId;
        RestaurantInfoDao().updateRestaurantInfo(value).then((value333) {
        });

      }).catchError((onError){
      });
    });

  }
  late String fileName="";

  void updateRestaurantInfoToSever(int? serverId) {
    final dio = Dio();
    final fiftyDaysFromNow = AppConfig.dateTime.subtract(Duration(minutes: AppConfig.dateTime.timeZoneOffset.inMinutes));
    dio.options.headers['X-TenantID'] = optifoodSharedPrefrence.getString("database").toString();
    dio.options.headers['Authorization'] = optifoodSharedPrefrence.getString("accessToken").toString();
    if(serverId==0)
      this.saveRestaurantInfoToSever();
    else
      RestaurantInfoDao().getRestaurantInfoByServerId(serverId!).then((value) async{
        var startTime="${value!.startTime.substring(0,5)}:00";
        var endTime="${value!.endTime.substring(0,5)}:00";
        var formData;
        if(_image!=null) {
          formData = FormData.fromMap({
            "restaurantName": value!.name,
            "companyId": 0,
            "openingTime": startTime,
            "closingTime": endTime,
            "address": value!.address,
            "cityName": "Adwa",
            "email": value!.email,
            "phoneNumber": value!.phoneNumber,
            "websiteLink": "https://medcoanalytics.com",
            "contactId": 0,
            "chainId": 0,
            'image': MultipartFile.fromBytes(
                _image.readAsBytesSync(), filename: fileName),
            "database": "restaurantOne",
            "url": "url",
            "username": "bre",
            "password": "123456",
            "dateTimeZone":AppConfig.dateTime.timeZoneOffset.inMinutes,
            "lat": value.lat,
            "lon": value.lon,
          });
        }
        else{
          formData = FormData.fromMap({
            "restaurantName": value!.name,
            "companyId": 0,
            "openingTime": startTime,
            "closingTime": endTime,
            "address": value!.address,
            "cityName": "Adwa",
            "email": value!.email,
            "phoneNumber": value!.phoneNumber,
            "websiteLink": "https://add.com",
            "contactId": 0,
            "chainId": 0,
            "database": "restaurantOne",
            "url": "url",
            "username": "bre",
            "password": "123456",
            "dateTimeZone":AppConfig.dateTime.timeZoneOffset.inMinutes,
            "lat": value.lat,
            "lon": value.lon,
          });
        }
        var response = await dio.put(ServerData.OPTIFOOD_BASE_URL+"/api/restaurant/${serverId}",
          data: formData,
        ).then((value1){
        }).catchError((onError){
        });
      });
  }
  void _showTimePicker(TextEditingController textEditingController){
    showTimePicker(
        helpText: "",
        hourLabelText: "",
        builder: (context, child) {
          return Theme(
            child: MediaQuery(data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
              child:  Container(
                height: 100,
                width: 320,
                child: child,
              ),),
            data: ThemeData(
              textButtonTheme: TextButtonThemeData(
                style: TextButton.styleFrom(
                  primary: AppTheme.colorRed, // button text color
                ),
              ),
              colorScheme: const ColorScheme.light(
                primary: AppTheme.colorRed, // <-- SEE HERE
                background:  AppTheme.colorRed,
              ),
              timePickerTheme: TimePickerThemeData(
                dialHandColor:  AppTheme.colorRed,
              ),
            ),
          );
        },
        context: context,  initialTime: TimeOfDay.now()).then((value) =>
    {
      setState((){
        textEditingController.text=value?.format(context) as String;
      })
    });
  }

}