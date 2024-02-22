// // import 'dart:html';
// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_svg/svg.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:opti_food_app/assets/images.dart';
// import '../../main.dart';
// import '../../widgets/app_theme.dart';
// import '../../widgets/appbar/app_bar_optifood.dart';
//
// class UserProfile extends StatefulWidget {
//   @override
//   State<StatefulWidget> createState() => _UserProfileState();
// }
// class _UserProfileState extends MountedState<UserProfile> {
//   late String fileName;
//   var _image;
//   var selectedImagePath = null;
//   String name="", mobilephone="", email="", userType="", userStatus="";
//   @override
//   void initState() {
//     super.initState();
//     name=optifoodSharedPrefrence.getString("name")!;
//     mobilephone=optifoodSharedPrefrence.getString("mobilePhone")!;
//     email=optifoodSharedPrefrence.getString("email")!;
//     userType=optifoodSharedPrefrence.getString("userType")!;
//     userStatus=optifoodSharedPrefrence.getString("userStatus")!;
//   }
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//         appBar: AppBarOptifood(),
//         body:Padding(
//             padding: EdgeInsets.zero,
//             child: Form(
//               child: ListView(
//                 children: [
//                   Stack(
//                     children: [
//                       Container(padding: EdgeInsets.only(top: 35,bottom: 35),
//                         margin: EdgeInsets.only(bottom: 30),
//                         width: double.infinity,
//                         decoration: BoxDecoration(
//                           color: Colors.white,
//                           boxShadow: [
//                             BoxShadow(
//                               color: Colors.black12,
//                               spreadRadius: 2,
//                               blurRadius: 5,
//                             ),
//                           ],
//                         ),
//
//                         child: Container( // Container to add shaddow for circular avatar
//                           width: 65,
//                           decoration: BoxDecoration(
//                               color: Colors.white,
//                               shape: BoxShape.circle,
//                               boxShadow: [BoxShadow(blurRadius: 5, color: Colors.black12,spreadRadius: 2)]
//                           ),
//                           child: GestureDetector(
//                             child: CircleAvatar(
//                               backgroundColor: Colors.white,
//                               radius: 55,
//                               child: CircleAvatar( // actual circle avatar
//                                 // backgroundImage: _image==null?null:FileImage(_image),
//                                 backgroundColor: Colors.white,
//                                 radius: 50,
//                                 child: _image!=null?null:
//                                 SvgPicture.asset(AppImages.profilePicture,
//                                     height: 35),
//                               ),
//                             ),
//                             onTap: () async { // on click of circle avatar
//                               // final image = await ImagePicker().getImage(source: ImageSource.gallery);
//                               // if(image == null) return;
//                               // final File imageTemp = File(image.path);
//                               // selectedImagePath = image.path;
//                               // fileName = image.path.split('/').last;
//                               // setState(() => this._image = imageTemp); // setting selected image to cirlce avatar
//                             },
//                           ),
//                         ),
//
//                       ),
//                       if(selectedImagePath!=null)...[
//                         GestureDetector(
//                           child: Center(
//                             child: Container(
//                                 padding: EdgeInsets.all(3),
//                                 margin: EdgeInsets.only(top: 40, left: 70),
//                                 child: Icon(
//                                   Icons.close, color: Colors.white,),
//                                 decoration: BoxDecoration(
//                                   color: AppTheme.colorDarkGrey,
//                                   shape: BoxShape.circle,
//                                 )
//                             ),
//                           ),
//                           onTap: (){
//                             setState((){
//                               selectedImagePath = null;
//                               _image = null;
//                             });
//                           },
//                         )
//                       ]
//                     ],
//                   ),
//                   Row(
//                     children: [
//                       Padding(padding: EdgeInsets.only(left: 5),
//                       child: SvgPicture.asset('assets/svg/icons/settings/account.svg', height: 35, color: AppTheme.colorDarkGrey,),
//                       ),
//                       Container(
//                           padding: EdgeInsets.only(left: 5),
//                           child: Text("${name}", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),))
//                     ],
//                   ),
//                   SizedBox(height: 20,),
//                   Row(
//                     children: [
//                       Padding(padding: EdgeInsets.only(left: 5),
//                         child: SvgPicture.asset(AppImages.phoneWithHandIcon, height: 35, color: AppTheme.colorDarkGrey,),
//                       ),
//                       Container(
//                           padding: EdgeInsets.only(left: 5),
//                           child: Text("${mobilephone}", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),))
//                     ],
//                   ),
//                   SizedBox(height: 20,),
//                   Row(
//                     children: [
//                       Padding(padding: EdgeInsets.only(left: 10),
//                         child: SvgPicture.asset(AppImages.emailIcon, height: 35, color: AppTheme.colorDarkGrey,),
//                       ),
//                       Container(
//                           padding: EdgeInsets.only(left: 10),
//                           child: Text("${email}", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),))
//                     ],
//                   ),
//                   SizedBox(height: 20,),
//                   Row(
//                     children: [
//                       Padding(padding: EdgeInsets.only(left: 10),
//                         child: SvgPicture.asset('assets/svg/icons/settings/account.svg', height: 35, color: AppTheme.colorDarkGrey,),
//                       ),
//                       Container(
//                           padding: EdgeInsets.only(left: 10),
//                           child: Text("${userType}", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),))
//                     ],
//                   ),
//                   SizedBox(height: 20,),
//                   Row(
//                     children: [
//                       Padding(padding: EdgeInsets.only(left: 10),
//                         child: Container(
//                           width: 30,
//                           height: 30,
//                           margin: EdgeInsets.all(5),
//                           decoration: BoxDecoration(
//                               color: AppTheme.colorGreen,
//                               shape: BoxShape.circle
//                           ),
//                         ),
//                       ),
//                       Container(
//                           padding: EdgeInsets.only(left: 10),
//                           child: Text("${userStatus}", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),))
//                     ],
//                   )
//
//                   // Padding(
//                   //   padding: const EdgeInsets.only(top: 11,bottom: 11),
//                   //   child: CustomFieldWithNoIcon(
//                   //     // data: Icons.email,
//                   //     validator: (value){
//                   //       if(value==null || value.isEmpty) {
//                   //         return "pleaseEnterAddress".tr();
//                   //       }
//                   //       else{
//                   //         return null;
//                   //       }
//                   //     },
//                   //     readOnly: true,
//                   //     onTap: () async {
//                   //       Prediction? prediction = await PlacesAutocomplete.show(
//                   //           context: context,
//                   //           //apiKey: "AIzaSyDcvjlWKsTTa7aF4twb0Yu5YxJHSXqEEUs",
//                   //           apiKey: "AIzaSyDzUrI1I9awcIGQViB8xEIzcMVLlPqmu_k",
//                   //           types: ["address"],
//                   //           components: [new Component(Component.country, "fr")],
//                   //           mode: Mode.overlay, // Mode.fullscreen
//                   //           language: "fr",
//                   //           strictbounds: false
//                   //       );
//                   //       if(prediction!=null){
//                   //         String placeAddress = prediction!.description!;
//                   //         widget.addressController.text = placeAddress;
//                   //
//                   //         GoogleMapsPlaces _places = GoogleMapsPlaces(apiKey: "AIzaSyDzUrI1I9awcIGQViB8xEIzcMVLlPqmu_k");
//                   //         PlacesDetailsResponse detail = await _places.getDetailsByPlaceId(prediction!.placeId!);
//                   //         clientLat = detail.result.geometry!.location.lat;
//                   //         clientLon = detail.result.geometry!.location.lng;
//                   //       }
//                   //     },
//                   //     controller: widget.addressController,
//                   //     hintText: "address".tr(),
//                   //     isObsecre: false,
//                   //     placeholder: "address".tr(),
//                   //     outerIcon: SvgPicture.asset(AppImages.clientAddressIcon, height: 35, color: AppTheme.colorDarkGrey,),
//                   //   ),
//                   // ),
//                   // // Padding(
//                   // //   padding: const EdgeInsets.only(top: 11,bottom: 11),
//                   // TimeFormField(
//                   //   controller: widget.startTimeController,
//                   //   isObsecre: false,
//                   //   enabled: true,
//                   //   hintText: "startTime".tr(),
//                   //   outerIcon: SvgPicture.asset(AppImages.timeIcon, height: 35, color: AppTheme.colorDarkGrey,),
//                   //   isKeepSpaceForOuterIcon: true,
//                   // ),
//                   // /*CustomFieldWithNoIcon(
//                   //     // data: Icons.email,
//                   //     controller: widget.startTimeController,
//                   //     hintText: "Start Time",
//                   //     isObsecre: false,
//                   //     readOnly: true,
//                   //     onTap: (){
//                   //       _showTimePicker(widget.startTimeController);
//                   //     },
//                   //     outerIcon: SvgPicture.asset(AppImages.timeIcon, height: 35, color: AppTheme.colorDarkGrey,),
//                   //   ),*/
//                   // // ),
//                   // TimeFormField(
//                   //   controller: widget.endTimeController,
//                   //   isObsecre: false,
//                   //   enabled: true,
//                   //   hintText: "endTime".tr(),
//                   //   outerIcon: SvgPicture.asset(AppImages.timeIcon, height: 35, color: AppTheme.colorDarkGrey,),
//                   //   isKeepSpaceForOuterIcon: true,
//                   // ),
//                   // /*Padding(
//                   //   padding: const EdgeInsets.only(top: 11,bottom: 11),
//                   //   child: CustomFieldWithNoIcon(
//                   //     // data: Icons.email,
//                   //     controller: widget.endTimeController,
//                   //     hintText: "End Time",
//                   //     isObsecre: false,
//                   //     readOnly: true,
//                   //     onTap: (){
//                   //       _showTimePicker(widget.endTimeController);
//                   //     },
//                   //     outerIcon: SvgPicture.asset(AppImages.timeIcon, height: 35, color: AppTheme.colorDarkGrey,),
//                   //   ),
//                   // ),*/
//                   // Padding(
//                   //   padding: const EdgeInsets.only(top: 14),
//                   //   child:
//                   //   CustomFieldWithNoIcon(
//                   //     validator: (value){
//                   //       if(value==null || value.isEmpty) {
//                   //         return "pleaseEnterEmail".tr();
//                   //       }
//                   //       else if(RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
//                   //           .hasMatch(value)==false){
//                   //         return "pleaseEnterValidEmail".tr();
//                   //       }
//                   //       else{
//                   //         return null;
//                   //       }
//                   //     },
//                   //     controller: widget.emailController,
//                   //     hintText: "email".tr(),
//                   //     isObsecre: false,
//                   //     textInputType: TextInputType.emailAddress,
//                   //     outerIcon: SvgPicture.asset(AppImages.emailIcon, height: 35, color: AppTheme.colorDarkGrey,),
//                   //   ),
//                   // ),
//                   // Padding(
//                   //   padding: const EdgeInsets.only(left: 60,right: 55,top: 50,bottom: 50),
//                   //   child: Container(
//                   //     height:45 ,
//                   //
//                   //     decoration: BoxDecoration(
//                   //         borderRadius: BorderRadius.all(
//                   //             Radius.circular(10)),
//                   //         boxShadow: [
//                   //           BoxShadow(color: AppTheme.colorDarkGrey,spreadRadius:2 , blurRadius: 0,)
//                   //         ]
//                   //     ),
//                   //     child: ElevatedButton(
//                   //
//                   //       style: ElevatedButton.styleFrom(
//                   //           primary: AppTheme.colorDarkGrey,
//                   //           elevation: 10, shadowColor: AppTheme.colorDarkGrey),
//                   //       child: Row(
//                   //         mainAxisSize: MainAxisSize.min,
//                   //         children: [
//                   //           Padding(
//                   //             padding: const EdgeInsets.only(right: 15),
//                   //             child: SvgPicture.asset(AppImages.saveIcon,
//                   //               height: 25,),
//                   //           ),
//                   //           Text('save', style: TextStyle(fontSize: 18.0, color: Colors.white),).tr(),
//                   //         ],
//                   //       ),
//                   //       onPressed: () async {
//                   //         print("Lat and lonnnnnnnnnnnnnnnnnnnnnnnnnnnnnn: ${clientLat} ${clientLon}");
//                   //         List<String> dateTimeList = Utility().generateShiftTiming(widget.startTimeController.text, widget.endTimeController.text);
//                   //         optifoodSharedPrefrence.setString("end_shift_date_time",dateTimeList[1]);
//                   //         //Utility().showToastMessage("Shift changed: "+optifoodSharedPrefrence.getString("end_shift_date_time")!);
//                   //         RestaurantInfoModel restaurantInfoModel = RestaurantInfoModel(1,widget.nameController.text,widget.phoneNumberController.text,
//                   //             widget.addressController.text,widget.startTimeController.text,  widget.endTimeController.text,widget.emailController.text,
//                   //             imagePath: selectedImagePath, lat: clientLat, lon: clientLon);
//                   //         if(widget.existingRestaurantInfoModel!=null){
//                   //           print("existingggggggg ${widget.existingRestaurantInfoModel!.id!} = ${widget.existingRestaurantInfoModel!.name!}=${widget.existingRestaurantInfoModel!.startTime}");
//                   //           restaurantInfoModel.id = widget.existingRestaurantInfoModel!.id;
//                   //           restaurantInfoModel.serverId = widget.existingRestaurantInfoModel!.serverId;
//                   //           await RestaurantInfoDao().updateRestaurantInfo(restaurantInfoModel).then((value){
//                   //             updateRestaurantInfoToSever(widget.existingRestaurantInfoModel!.serverId);
//                   //           });
//                   //           Navigator.pop(context, restaurantInfoModel);
//                   //         }
//                   //         else {
//                   //           print("not existingggggggg");
//                   //           await RestaurantInfoDao().insertRestaurantInfo(
//                   //               restaurantInfoModel).then((value) {
//                   //             saveRestaurantInfoToSever();
//                   //           });
//                   //           Navigator.pop(context, restaurantInfoModel);
//                   //         }
//                   //       },
//                   //     ),
//                   //   ),
//                   // ),
//                 ],
//               ),
//             )
//         )
//     );
//   }
//
//
// }