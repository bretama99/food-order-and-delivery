import 'package:dio/dio.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
//import 'package:http/http.dart' as client;
import 'package:flutter_google_places/flutter_google_places.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_maps_webservice/places.dart';
import 'package:opti_food_app/data_models/company_model.dart';
import 'package:opti_food_app/data_models/contact_address_model.dart';
import 'package:opti_food_app/data_models/contact_model.dart';
import 'package:opti_food_app/database/company_dao.dart';
import 'package:opti_food_app/database/contact_dao.dart';
import 'package:opti_food_app/widgets/appbar/app_bar_optifood.dart';
import 'package:uuid/uuid.dart';

import '../../api/company_api.dart';
import '../../api/customer_api.dart';
import '../../assets/images.dart';
import '../../main.dart';
import '../../utils/constants.dart';
import '../../widgets/app_theme.dart';
import '../../widgets/custom_field_with_no_icon.dart';
import '../MountedState.dart';
import 'delivery_info.dart';

class ClientRegister extends StatefulWidget {
  TextEditingController nameController = new TextEditingController();
  TextEditingController firstNameController = new TextEditingController();
  TextEditingController phoneNumberController = new TextEditingController();
  TextEditingController addressController = new TextEditingController();
  TextEditingController emailController = new TextEditingController();
  TextEditingController companyController = new TextEditingController();
  ContactModel? primaryContactModel;
  ContactModel? existingContactModel; //it will not null if open for edit.
  late List<CompanyModel> companyList=[];
  Function? callBack;
  bool isFromOrder=false;
  bool isToAddNewAddress=false;
  bool isContactAddressToEdit = false;
  int contactAddressId=0;
  ClientRegister({Key? key,this.primaryContactModel = null,this.existingContactModel = null, this.callBack, this.isFromOrder=false, this.isToAddNewAddress=false, this.isContactAddressToEdit=false,  this.contactAddressId=0}) : super(key: key);

  @override
  State<ClientRegister> createState(){
    if(primaryContactModel!=null){
      nameController.text = primaryContactModel!.lastName+" "+primaryContactModel!.firstName;
      //firstNameController.text = primaryContactModel!.firstName;
      phoneNumberController.text = primaryContactModel!.phoneNumber;
      emailController.text = primaryContactModel!.email;
    }
    return _ClientRegisterState();
  }
}

class _ClientRegisterState extends MountedState<ClientRegister> {
  final GlobalKey<FormState> _globalKey = GlobalKey<FormState>();
  double clientLat = 0;
  double clientLon = 0;


  @override
  void initState() {
    // TODO: implement initState

   /* if(widget.primaryContactModel!=null){
      ContactDao().getContactById(widget.primaryContactModel!.id).then((value) {
        widget.primaryContactModel!.serverId = value.serverId;
        widget.primaryContactModel!.companyId = value.companyId;
      });
    }*/
    CompanyDao().getAllCompanies().then((value){
      widget.companyList = value;
      for(int i=0;i<widget.companyList.length;i++){
      }

    });
    if(widget.existingContactModel!=null){
      /*if(widget.existingContactModel!.companyId!=0 && widget.existingContactModel!.companyId!=null &&widget.existingContactModel!.companyModel==null){

        CompanyDao().getCompanyById(widget.existingContactModel!.companyId).then((value){
          widget.companyController.text = value.name;
        });
      }*/

      /*ContactDao().getContactById(widget.existingContactModel!.id).then((value) {
        widget.existingContactModel!.serverId = value.serverId;
      });*/
      if(widget.primaryContactModel==null) {
        widget.nameController.text = widget.existingContactModel!.lastName;
        widget.firstNameController.text = widget.existingContactModel!.firstName;
      }
      else{
        widget.nameController.text = widget.existingContactModel!.lastName+" "+widget.existingContactModel!.firstName;
      }
      /*if(widget.existingContactModel!.companyModel!=null) {
        widget.companyController.text = widget.existingContactModel!.companyModel!.name;
        print("mmmmmmmmmwidget.existingContactModel!.companyModelmmmmmmmmmmmmmmm${widget.existingContactModel!.companyModel}mmmmmmmmmmmmmmmmmmmmmmmmmmm");

      }*/
      //widget.addressController.text = widget.existingContactModel!.address;
      if(!widget.isToAddNewAddress)
        widget.addressController.text = widget.existingContactModel!.getDefaultAddress().address;
      widget.phoneNumberController.text = widget.existingContactModel!.phoneNumber;
      widget.emailController.text = widget.existingContactModel!.email;
      widget.primaryContactModel;
      if(widget.existingContactModel!.getDefaultAddress().companyModel!=null && !widget.isToAddNewAddress)
        widget.companyController.text = widget.existingContactModel!.getDefaultAddress().companyModel!.name;
    }
    else if(widget.primaryContactModel!=null&&widget.primaryContactModel!.getDefaultAddress().companyModel!=null&&!widget.isToAddNewAddress&&!widget.isContactAddressToEdit){
      widget.companyController.text = widget.primaryContactModel!.getDefaultAddress().companyModel!.name;
      widget.addressController.text = widget.primaryContactModel!.getDefaultAddress().address;
    }
    if(widget.isContactAddressToEdit){
      try { // MANISH, added because showing error on create reservation
        widget.companyController.text = widget.primaryContactModel!
            .contactAddressList
            .where((element) => element.id == widget.contactAddressId)
            .first
            .companyModel!
            .name;
        widget.addressController.text = widget.primaryContactModel!
            .contactAddressList
            .where((element) => element.id == widget.contactAddressId)
            .first
            .address;
      }
      catch(onError,stacktrace){
        print(stacktrace);
      }
    }
  }
  @override
  Widget build(BuildContext context) {
    String sessionToken = Uuid().v4();
    final isLandscape = MediaQuery.of(context).orientation == Orientation.landscape;
    return Scaffold(
      appBar: AppBarOptifood(),
      body:Padding(
        padding: const EdgeInsets.only(left: 7,right: 10,top: 10),
        child: Form(
          key: _globalKey,
          child: ListView(
            children: [
              //Row(
                //children: [
                  CustomFieldWithNoIcon(
                        // data: Icons.email,
                        validator: (value){
                          if(value==null || value.isEmpty) {
                            return "pleaseEnterLastName".tr();
                          }
                          else{
                            return null;
                          }
                        },
                        controller: widget.nameController,
                        textCapitalization: TextCapitalization.sentences,
                        hintText: "lastName".tr(),
                        isObsecre: false,
                        placeholder: "lastName".tr(),
                        paddingParameters: PaddingParameters(10, 35, 10, 5),
                        outerIcon: SvgPicture.asset(AppImages.clientInfoIcon, height: 35, color: AppTheme.colorDarkGrey,)
                      ),
                        Visibility(
                          visible: widget.primaryContactModel==null,
                          child: CustomFieldWithNoIcon(
                            // data: Icons.email,
                            controller: widget.firstNameController,
                            hintText: "firstName".tr(),
                            isObsecre: false,
                            placeholder: "firstName".tr(),
                            textCapitalization: TextCapitalization.sentences,
                          ),
                        ),

                      //),
                    //),
                  //),

                //],
              //),
              Padding(padding: EdgeInsets.only(top: 11,bottom: 11),
                child: Container(
                  padding: EdgeInsets.only(left: 10,right: 10,top: 5,bottom: 5),
                  child: Row(
                    children: [
                        //SizedBox(width: 40,),
                      SvgPicture.asset(AppImages.companyIcon, height: 35, color: AppTheme.colorDarkGrey,),
                      SizedBox(width: 5,),
                      Expanded(child:
                      Card(
                        color: Colors.white,
                        surfaceTintColor: Colors.transparent,
                        shadowColor: Colors.white38,

                        elevation: 4,
                        shape:  RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10), // <-- Radius
                        ),
                        child: Autocomplete<CompanyModel>(
                          initialValue: TextEditingValue(text: widget.companyController.text),
                          displayStringForOption: (CompanyModel option) => option.name,
                          optionsBuilder: (TextEditingValue textValue) async {
                            widget.companyList = await CompanyDao().getAllCompanies();
                            return widget.companyList.where((element) =>
                                element.name.toLowerCase().startsWith(
                                    textValue.text.toLowerCase())).toList();

                          },
                          fieldViewBuilder: ((context,textEditingController,focusNode,onSubmit){
                            widget.companyController = textEditingController;
                            return
                              TextFormField(
                              textCapitalization: TextCapitalization.sentences,
                              controller: textEditingController,

                              focusNode: focusNode,
                                onEditingComplete: onSubmit,
                              decoration: InputDecoration(
                                  contentPadding:
                                  EdgeInsets.only(left: 15, bottom: 11, top: 11, right: 15),
                                  border: InputBorder.none,
                                  focusedBorder: InputBorder.none,
                                  errorBorder: InputBorder.none,
                                  disabledBorder: InputBorder.none,
                                  hintText: "company".tr(),
                              ),
                            );
                          }),
                          onSelected: (companyModel){
                            widget.addressController.text = companyModel.address!;
                          },
                        ),
                      ),
                      )

                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 11,bottom: 11),
               // child: Row(
                //  children: [
                 //   Container(
                  //      width: MediaQuery.of(context).size.width*0.15,
                  //      child: SvgPicture.asset("assets/images/icons/phone-client.svg", height: 35, color: AppTheme.colorDarkGrey,)),
                  //  Container(
                   //   width: MediaQuery.of(context).size.width*0.8,
                   //   child:Card(
                    //    shadowColor: Colors.white38,

                   //     elevation: 4,                      shape:  RoundedRectangleBorder(
                    //    borderRadius: BorderRadius.circular(10), // <-- Radius
                    //  ),
                        child: CustomFieldWithNoIcon(
                          // data: Icons.email,
                          validator: (value){
                            if(value==null || value.isEmpty) {
                              return "pleaseEnterPhoneNumber".tr();
                            }
                            else{
                              return null;
                            }
                          },
                          readOnly: widget.primaryContactModel!=null&&!widget.isContactAddressToEdit,
                          enabled: widget.primaryContactModel==null||widget.isContactAddressToEdit,
                          controller: widget.phoneNumberController,
                          hintText: "phoneNumber".tr(),
                          isObsecre: false,
                          placeholder: "phoneNumber".tr(),
                          textInputType: TextInputType.phone,
                          outerIcon: SvgPicture.asset(AppImages.phoneClientIcon, height: 35, color: AppTheme.colorDarkGrey,),
                        ),
                      ),
                  //  ),
                 // ],
               // ),
             // ),
             // Row(
              //  children: [
              //    Container(
              //        width: MediaQuery.of(context).size.width*0.15,
              //        child: SvgPicture.asset("assets/images/icons/client-address.svg", height: 35, color: AppTheme.colorDarkGrey,)),
              //    Container(
              //      width: MediaQuery.of(context).size.width*0.8,
              //      child:Card(
              //        shadowColor: Colors.white38,

              //        elevation: 4,                    shape:  RoundedRectangleBorder(
              //        borderRadius: BorderRadius.circular(10), // <-- Radius
              //      ),
              //        child:
                CustomFieldWithNoIcon(
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
               //     ),
               //   ),
               // ],
              //),

              Padding(
                padding: const EdgeInsets.only(top: 14),
              //  child: Row(
              //    children: [
              //      Container(
              //          width: MediaQuery.of(context).size.width*0.15,
              //          child: SvgPicture.asset("assets/images/icons/email.svg", height: 35, color: AppTheme.colorDarkGrey,)),
              //      Container(
              //        width: MediaQuery.of(context).size.width*0.8,
              //        child:Card(
              //          shadowColor: Colors.white38,

              //          elevation: 4,                      shape:  RoundedRectangleBorder(
              //          borderRadius: BorderRadius.circular(10), // <-- Radius
              //        ),
                        child:
                        CustomFieldWithNoIcon(
                          // data: Icons.email,
                          validator: (value){
                            if(value==null || value.isEmpty) {
                              //return "Please enter address";
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
                          readOnly: widget.primaryContactModel!=null,
                          enabled: widget.primaryContactModel==null,
                          controller: widget.emailController,
                          hintText: "email".tr(),
                          isObsecre: false,
                          placeholder: "name".tr(),
                          textInputType: TextInputType.emailAddress,
                          outerIcon: SvgPicture.asset(AppImages.emailIcon, height: 35, color: AppTheme.colorDarkGrey,),
                        ),
                      ),
              //      ),
              //    ],
              //  ),
             // ),
              Padding(
                padding: const EdgeInsets.only(left: 60,right: 55,top: 50),
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
                     // getCompanyId();
                      /*if(await ContactDao().isPhoneNumberExist(widget.phoneNumberController.text)){
                        widget.phoneNumberController.set
                      }*/
                      if (_globalKey.currentState!.validate()==false) {
                        return;
                      }
                      CompanyModel? companyModel = null;
                      if(widget.companyController.text.isNotEmpty){
                        companyModel = await getCompany();
                      }

                          ContactModel contactModel = ContactModel(1,widget.firstNameController.text,
                              widget.nameController.text,
                              //widget.addressController.text,
                              widget.phoneNumberController.text,
                              widget.emailController.text,
                              contactAddressList: []
                              //companyId: companyModel!=null?companyModel.id:0,
                              // companyModel: companyModel,lat: clientLat,lon: clientLon
                              );
                      ContactAddressModel contactAddressModel = ContactAddressModel(
                          DateTime.now().millisecondsSinceEpoch,
                          widget.nameController.text+" "+widget.firstNameController.text,
                          widget.addressController.text,
                          clientLat,
                          clientLon,
                          companyModel!=null?companyModel.id:0,
                          companyServerId: companyModel!=null?companyModel.serverId:0,
                          companyModel: companyModel
                          //isDefaultAddress: true
                      );
                      //contactModel.contactAddressList.add(contactAddressModel);
                      if(widget.existingContactModel==null) //for update not to check mobile no.
                          {
                        if (widget.primaryContactModel == null) {
                          print("=======================================mmmmmmmmmmmmmmmmmmmmmmmmmmmmm");
                          ContactModel? cm = await ContactDao()
                              .getContactByPhoneNumber(
                              widget.phoneNumberController.text);
                          if (cm != null) {
                            showDialog(
                                context: context, builder: (BuildContext
                            context) {
                              return CustomerExistPopup(cm);
                            }).then((value) {

                              if (value ==
                                  CustomerExistPopup.ACTION_CONTINUE_EXISTING) {

                                Navigator.pop(context, cm);
                              }
                              else if (value ==
                                  CustomerExistPopup.ACTION_UPDATE_EXISTING) {
                                //contactModel.extraAddressList =
                                    //cm.extraAddressList;
                                contactModel.contactAddressList = cm.contactAddressList;
                                print("==================updateContact4=================================================");

                                ContactDao().updateContact(contactModel);
                                Navigator.pop(context, contactModel);
                              }
                              else if (value ==
                                  CustomerExistPopup.ACTION_ADD_NEW_ADDRESS) {
                                print("==================updateContact5=================================================");

                                contactModel.lastName =
                                    contactModel.lastName + " " +
                                        contactModel.firstName;
                                contactModel.firstName = "";
                                //cm.extraAddressList.add(contactModel);
                                cm.contactAddressList.add(contactModel.getDefaultAddress());
                                ContactDao().updateContact(cm);
                                Navigator.pop(context, contactModel);
                              }
                            });
                            return;
                          }
                        }
                      }
                      if(widget.existingContactModel!=null){
                        if(widget.primaryContactModel == null){

                          contactModel.id = widget.existingContactModel!.id;
                          contactModel.serverId = widget.existingContactModel!.serverId;
                          //contactModel.contactAddressList.add(contactAddressModel);
                          contactModel.contactAddressList = widget.existingContactModel!.contactAddressList;
                          if(companyModel==null && widget.companyController.text.isNotEmpty) {

                            await ContactDao()
                                .updateContact(contactModel)
                                .then((value) {
                              //saveCompanyToServer(widget.primaryContactModel, widget.existingContactModel);
                            });
                            Navigator.pop(context, contactModel);
                            /*await CompanyDao().insertCompany(CompanyModel(widget.companyController.text,
                                phoneNo: widget.phoneNumberController.text,
                                email: widget.emailController.text,
                                address: widget.addressController.text
                            )).then((value) async {

                            });*/
                          }
                          else if(companyModel==null && widget.companyController.text.isEmpty){
                            await ContactDao()
                                .updateContact(contactModel)
                                .then((value) {
                              updateContactToSever(
                                  widget.existingContactModel!.serverId, true,0);
                            });
                            Navigator.pop(context, contactModel);
                          }
                          else{
                            await ContactDao()
                                .updateContact(contactModel)
                                .then((value) {
                              updateContactToSever(
                                  widget.existingContactModel!.serverId, false,0);
                            });
                            Navigator.pop(context, contactModel);
                          }
                        }
                        else{
                          await ContactDao()
                              .getContactByPhoneNumber(
                              widget.phoneNumberController.text).then((value){
                                //contactModel.extraAddressList = value!.extraAddressList;
                                //contactModel.extraAddressList.add(widget.primaryContactModel!);
                                contactModel.contactAddressList = value!.contactAddressList;

                          });

                          Navigator.pop(context, contactModel);
                        }
                      }
                      else {
                        print("==================updateContact6=================================================");

                        if (widget.primaryContactModel == null) {
                          contactAddressModel.isDefaultAddress = true; //because on create customer first address is default address
                          contactModel.contactAddressList.add(contactAddressModel);
                         if(companyModel!=null){


                           contactAddressModel.companyId = companyModel!.id;
                           contactAddressModel.companyServerId = companyModel!.serverId;
                          await ContactDao().insertContact(
                               contactModel).then((value) async {
                             //saveContactToSever(0)
                              CustomerApis().saveContactToSever(contactModel);
                            // saveContactToSever(contactModel,isFromOrder:widget.isFromOrder);
                              if(widget.isFromOrder) {
                                await Navigator.of(context).push(
                                    MaterialPageRoute(builder:
                                        (context) =>
                                        DeliveryInfo(customer: contactModel
                                        )));
                              }
Navigator.pop(context, contactModel);
                          });

                         }
                         else{
                           print("==================updateContact7=================================================");

                           await ContactDao().insertContact(
                               contactModel).then((value) async  {
                             //saveCompanyToServer(widget.primaryContactModel, widget.existingContactModel)
                             CustomerApis().saveContactToSever(contactModel);
                             if(widget.isFromOrder) {
                               await Navigator.of(context).push(
                                   MaterialPageRoute(builder:
                                       (context) =>
                                       DeliveryInfo(customer: contactModel,
                                         // existingOrder: widget.existingOrder,
                                         // callBack: (String on) {
                                         //   widget.callBack!(on);
                                         // }
                                       )));
                             }
Navigator.pop(context, contactModel);
                             // saveContactToSever(contactModel,isFromOrder:widget.isFromOrder)
                           });
                           // Navigator.pop(context, contactModel);
                           /*(await CompanyDao().insertCompany(CompanyModel(widget.companyController.text,
                               phoneNo: widget.phoneNumberController.text,
                               email: widget.emailController.text,
                               address: widget.addressController.text
                           )).then((value) async {


                           }));*/
                         }

                          // Navigator.pop(context, contactModel);
                        }
                        /*else if(companyModel==null){
                          print("in company model null");
                          companyModel = (await CompanyDao().insertCompany(CompanyModel(widget.companyController.text,
                              phoneNo: widget.phoneNumberController.text,
                              email: widget.emailController.text,
                              address: widget.addressController.text
                          )).then((value) async {
                            contactModel.companyModel=value;
                            contactModel.companyId=value.id;
                            widget.primaryContactModel!.extraAddressList.add(
                                contactModel);
                            await ContactDao().updateContact(
                                widget.primaryContactModel!).then((value){
                            });
                            saveCompanyToServer(widget.primaryContactModel, widget.existingContactModel);
                            Navigator.pop(context, contactModel);

                          }));

                        } */
                        else if(widget.isContactAddressToEdit){
                          print("==================updateContact3=================================================");
                          //widget.primaryContactModel!.extraAddressList.add(
                            //  contactModel);
                         // List<ContactAddressModel> contactAddressModels = widget.primaryContactModel!.contactAddressList.where((element) => element.id!=widget.contactAddressId).toList();
                          widget.primaryContactModel!.contactAddressList.where((element) =>
                          element.id==widget.contactAddressId).first.companyModel=companyModel;
                          widget.primaryContactModel!.contactAddressList.where((element) =>
                          element.id==widget.contactAddressId).first.name=widget.nameController.text+" "+widget.firstNameController.text;
                          widget.primaryContactModel!.contactAddressList.where((element) =>
                          element.id==widget.contactAddressId).first.address=widget.addressController.text;
                          widget.primaryContactModel!.contactAddressList.where((element) =>
                          element.id==widget.contactAddressId).first.companyId=companyModel!.id;
                          widget.primaryContactModel!.contactAddressList.where((element) =>
                          element.id==widget.contactAddressId).first.lat=clientLat;

                          widget.primaryContactModel!.contactAddressList.where((element) =>
                          element.id==widget.contactAddressId).first.lon=clientLon;
                          await ContactDao().updateContact(
                              widget.primaryContactModel!).then((value){
                            CustomerApis().saveCustomerAddress(widget.primaryContactModel!, contactAddressModel);
                            Navigator.pop(context, widget.primaryContactModel!);

                          });
                          //

                        }
                        else {
                          print("==================updateContact6=================================================");
                          //widget.primaryContactModel!.extraAddressList.add(
                          //  contactModel);
                          widget.primaryContactModel!.contactAddressList.add(
                              contactAddressModel);
                          //contactModel.primaryContactModel = widget.primaryContactModel!; //needed to upload data on server.
                          await ContactDao().updateContact(
                              widget.primaryContactModel!).then((value){
                            //saveCustomerAddress(widget.primaryContactModel!.serverId, companyModel!.serverId);
                            CustomerApis().saveCustomerAddress(widget.primaryContactModel!, contactAddressModel);
                          });
                          //
                          Navigator.pop(context, contactModel);

                        }
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

  /*saveCompanyToServer(ContactModel? primaryContactModel, ContactModel? existingContactModel) {
    final dio = Dio();
    dio.options.headers['X-TenantID'] = ServerData.OPTIFOOD_DATABASE;
    CompanyDao().getCompanyLast().then((value) async{
      var formData;
        formData = FormData.fromMap({
          'companyName': value.name,
          'email': value.email,
          'phoneNumber': value.phoneNo,
          "address": value.address,
        });

      var response = await dio.post(ServerData.OPTIFOOD_BASE_URL+"/api/company",
        data: formData,
      ).then((response){
        var singleData = CompanyModel.fromJsonServer(response.data);
        value.isSynced=true;
        value.serverId=singleData.serverId;
        if(primaryContactModel==null){
          if(existingContactModel==null){
           // saveContactToSever(value.serverId!);
          }
          else{
            *//*updateContactToSever(
                widget.existingContactModel!.serverId,false, value.serverId);*//*
          }
        }
        else{
          //CustomerApis().saveCustomerAddress(widget.primaryContactModel!, existingContactModel!); // commented for now by Manish
        }

        CompanyDao().updateCompany(value).then((value333) {
        });

      }).catchError((onError){
      });
    });
  }*/

  /*saveContactToSever(int? companyId) {
    final dio = Dio();
    dio.options.headers['X-TenantID'] = ServerData.OPTIFOOD_DATABASE;
    ContactDao().getContactLast().then((value) async{
      var response = await dio.post(ServerData.OPTIFOOD_BASE_URL+"/api/customer",
        data: {
          "lastName":value.lastName,
          "firstName":value.firstName,
          "phoneNumber":value.phoneNumber,
          "email":value.email,
          "address":value.address,
          "companyId":companyId!=0?companyId:value.companyId,
          "latitude":clientLat,
          "longitude":clientLon,
        },
      ).then((response){
        var singleData = ContactModel.fromJsonServer(response.data);
        value.isSynced=true;
        value.serverId=singleData.serverId;
        print("Serverid saved "+value.serverId.toString());
        ContactDao().updateContact(value).then((value333) {
          print("Contact updated");
        });

      }).catchError((onError){

      });
    });
  }*/

  /*void saveCustomerAddress(int? serverId, int? companyId) {
    print("Customer server id : "+serverId!.toString());
    ContactDao().getCustomerByServerId(serverId!).then((value) async{
      final dio = Dio();
      var response = await dio.post(ServerData.OPTIFOOD_BASE_URL+"/api/customer-address",
        data: {
          "customerId":serverId,
          "companyId":companyId,
          "latitude":clientLat,
          "longitude":clientLon,
          "address":value?.extraAddressList.last!.address,
        },
      ).then((response){
        print("Address saved");
      }).catchError((onError){
        print("Address Error");
      });
    });
  }*/



  void updateContactToSever(int? serverId, bool isCompanyZero, int? companyId) {
    final dio = Dio();
    dio.options.headers['X-TenantID'] = optifoodSharedPrefrence.getString("database").toString();
    dio.options.headers['Authorization'] = optifoodSharedPrefrence.getString("accessToken").toString();
    ContactDao().getCustomerByServerId(serverId!).then((value) async{
      //var response = await dio.put(ServerData.OPTIFOOD_BASE_URL+"/api/customer/$serverId",
      print(value);
      dio.put(ServerData.OPTIFOOD_BASE_URL+"/api/customer/$serverId",
        data: {
          "lastName":value!.lastName,
          "firstName":value!.firstName,
          "phoneNumber":value!.phoneNumber,
          "email":value!.email,
          /*"address":value!.address,
          "companyId":isCompanyZero?0:companyId!=0?companyId:value!.companyId,
          "latitude":value!.lat,
          "longitude":value!.lon,*/
        },
      ).then((response){
        print(response);
      }).catchError((onError){
        print("Error");
      });
    });
  } //comment for now

  Future<CompanyModel?> getCompany() async {
    print("check companey getCompany()");
    String companyName = widget.companyController.text;
    CompanyModel? companyModel = null;
    print("===widget.companyList.length===${widget.companyList.length}======================");

    for(int i=0;i<widget.companyList.length;i++){
  print("===widget.companyList[i].name=$i===${widget.companyList[i].name}======================");
  print("===widget.companyController.text=$i===${widget.companyController.text}======================");
}
    try {
      companyModel = widget.companyList
          .where((element) => element.name == companyName)
          .first;
    }
    catch(error){

    }

    print("======companyName======${companyName}===============================");

    if(companyModel == null){

       companyModel = await CompanyDao().insertCompany(CompanyModel(widget.companyController.text,
         phoneNo: widget.phoneNumberController.text,
         email: widget.emailController.text,
         address: widget.addressController.text
          ));
       if(companyModel==null){
         print("Company model is null");
       }
       CompanyApis().saveCompanyToServer(companyModel!);
      //   // ContactModel contactModel = ContactModel(1,widget.firstNameController.text,
      //   //     widget.nameController.text, widget.addressController.text, widget.phoneNumberController.text,
      //   //     widget.emailController.text,
      //   //     companyId: value.id,companyModel: value,lat: clientLat,lon: clientLon);
      //   // widget.primaryContactModel!.extraAddressList.add(
      //   //     contactModel);
      //   // await ContactDao().updateContact(
      //   //     widget.primaryContactModel!).then((value){
      //   //   saveCustomerAddress(widget.primaryContactModel!.serverId, widget.primaryContactModel!.companyId);;
      //   // });
      //   CompanyApis.saveCompanyToServer(null, "");
      // }));
      // companyModel = (await CompanyDao().insertCompany(CompanyModel(widget.companyController.text,
      //   phoneNo: widget.phoneNumberController.text,
      //   email: widget.emailController.text,
      //   address: widget.addressController.text
      // )).then((value){
      //   CompanyApis.saveCompanyToServer(null, "");
      //   ContactDao().getContactLast().then((value){
      //     value.companyModel=companyModel;
      //     ContactDao().updateContact(value);
      //   });
      // })
      // );
    }
    // print("check companey${companyModel!.id} getCompany()");
    return companyModel;
  }


}
class CustomerExistPopup extends StatefulWidget {
  ContactModel contactModel;
  CustomerExistPopup(this.contactModel);
  static const String ACTION_CONTINUE_EXISTING = "action_continue_existing";
  static const String ACTION_UPDATE_EXISTING = "action_update_existing";
  static const String ACTION_ADD_NEW_ADDRESS = "action_add_new_address";
  @override
  State<StatefulWidget> createState() => _CustomerExistPopupState();
}
class _CustomerExistPopupState extends MountedState<CustomerExistPopup> {
  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.transparent,
          shape:
          const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(bottomLeft: Radius.circular(20), bottomRight: Radius.circular(20),
            topLeft:  Radius.circular(20), topRight:  Radius.circular(20),),
          ),
        child:
        SingleChildScrollView(
          child: Container(
            padding: EdgeInsets.all(20),
            child:
              Column(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [Container(
                  padding: EdgeInsets.all(10),
                  child: SvgPicture.asset(AppImages.warningIcon, height: 30, color: Colors.white,),
                  decoration:
                  BoxDecoration(
                      color: AppTheme.colorRed,
                      borderRadius: BorderRadius.circular(25)
                  ),
                ),
                  Image.asset(AppImages.shadowIcon,width: 50, height: 30,),
                  Container(
                    alignment: Alignment.center,
                    child: Text("confirmation",style: TextStyle(fontSize: 18,fontWeight: FontWeight.bold),).tr(),),
                  SizedBox(height: 10,),
                  Container(
                    alignment: Alignment.center,
                    child: Text("customerAlreadyExistWithFollowingDetails",style: TextStyle(fontSize: 14,color: AppTheme.colorMediumGrey),).tr(),),
                  SizedBox(height: 10,),
                  Container(
                    alignment: Alignment.centerLeft,
                    child: Text("name : "+widget.contactModel.lastName+" "+widget.contactModel.firstName,style: TextStyle(color: AppTheme.colorMediumGrey),).tr(),
                  ),
                  Container(
                    alignment: Alignment.centerLeft,
                    child: Text("address : "+widget.contactModel.getDefaultAddress().address,style: TextStyle(color: AppTheme.colorMediumGrey)).tr(),
                  ),
                  Container(
                    alignment: Alignment.centerLeft,
                    child: Text("phone : "+widget.contactModel.phoneNumber,style: TextStyle(color: AppTheme.colorMediumGrey)).tr(),
                  ),
                  Container(
                    alignment: Alignment.centerLeft,
                    child: Text("email : "+widget.contactModel.email,style: TextStyle(color: AppTheme.colorMediumGrey)).tr(),
                  ),
                  SizedBox(height: 10,),
                  Container(
                    width: double.infinity,
                    child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            surfaceTintColor: Colors.transparent,
                            primary: AppTheme.colorDarkGrey,
                            elevation: 3, shadowColor: AppTheme.colorDarkGrey),
                        child:Text('continueWithExistingContact', style: TextStyle(fontSize: 12.0, color: Colors.white),).tr(),
                        onPressed: () async {
                          Navigator.pop(context,CustomerExistPopup.ACTION_CONTINUE_EXISTING);
                        }
                    ),
                  ),
                  Container(width: double.infinity,
                  child: ElevatedButton(

                      style: ElevatedButton.styleFrom(
                          surfaceTintColor: Colors.transparent,
                          primary: AppTheme.colorDarkGrey,
                          elevation: 3, shadowColor: AppTheme.colorDarkGrey),
                      child:Text('updateExistingContact', style: TextStyle(fontSize: 12.0, color: Colors.white),).tr(),
                      onPressed: () async {
                        Navigator.pop(context,CustomerExistPopup.ACTION_UPDATE_EXISTING);
                      }
                  ),
                  ),
                  Container(width: double.infinity,
                    child: ElevatedButton(

                        style: ElevatedButton.styleFrom(
                            surfaceTintColor: Colors.transparent,
                            primary: AppTheme.colorDarkGrey,
                            elevation: 3, shadowColor: AppTheme.colorDarkGrey),
                        child:Text('addNewAddressUnderExistingContact', style: TextStyle(fontSize: 12.0, color: Colors.white,),textAlign: TextAlign.center,).tr(),
                        onPressed: () async {
                          Navigator.pop(context,CustomerExistPopup.ACTION_ADD_NEW_ADDRESS);
                        }
                    ),
                  )
                ],
              )
          ),
        ),
    );
  }
}
