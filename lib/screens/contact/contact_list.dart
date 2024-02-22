import 'dart:async';
import 'package:dio/dio.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:fbroadcast/fbroadcast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:opti_food_app/api/customer_api.dart';
import 'package:opti_food_app/data_models/company_model.dart';
import 'package:opti_food_app/data_models/contact_model.dart';
import 'package:opti_food_app/database/contact_dao.dart';
import 'package:opti_food_app/screens/contact/contact_address_list.dart';
import 'package:opti_food_app/utils/utility.dart';
import 'package:opti_food_app/widgets/appbar/app_bar_optifood.dart';
import 'package:opti_food_app/widgets/option_menu/contact/contact_option_menu_popup.dart';
import 'package:opti_food_app/widgets/popup/confirmation_popup/confirmation_popup.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../assets/images.dart';
import '../../data_models/contact_address_model.dart';
import '../../data_models/order_model.dart';
import '../../database/company_dao.dart';
import '../../utils/constants.dart';
import '../../widgets/app_theme.dart';
import '../authentication/client_register.dart';
import '../authentication/delivery_info.dart';
import 'package:url_launcher/url_launcher.dart' as UrlLauncher;
import '../MountedState.dart';
import '../reservation/add_reservation.dart';

class ContactList extends StatefulWidget {
  //final String delivery;
  ContactModel? primaryContactModel;
  CompanyModel? companyModel;
  String searchQuery = "";
  bool returnContact = false;//should false if move to create order after that, should true if return contact to previous screen.
  bool showAddButton = true;
  bool showSkipButton = false;
  bool contactListItemClickable = true; // will false when contact list open from company
  bool showOptionMenu = false;
  OrderModel? existingOrder; // not null if edit order other wise it will be null
  Function? callBack;
  bool isFromOrder=false;
  bool isFromReservation = false;
  //ContactList({Key? key, required this.delivery,this.primaryContactModel=null,this.returnContact=false}) : super(key: key);
  ContactList({Key? key,this.primaryContactModel=null,this.returnContact=false,this.showAddButton=true,this.showSkipButton=false,this.companyModel = null,this.existingOrder=null,this.contactListItemClickable=true,this.showOptionMenu=false, this.callBack, this.isFromOrder=false, this.isFromReservation=false}) : super(key: key);

  @override
  State<ContactList> createState() => _ContactListState();
}
class _ContactListState extends MountedState<ContactList> with WidgetsBindingObserver {
  FocusNode focusNode = FocusNode();
  String SOURCE_CLICKED_ADDRESS_ICON = "address_icon";
  String SOURCE_CLICKED_LIST_ITEM = "list_item";
  List<ContactModel> contacts = [];
  List<CompanyModel> companies = [];
  void getContacts() async {

    if(widget.primaryContactModel==null){
      Future<List<ContactModel>> fContactList = ContactDao().getAllContacts();
      fContactList.then((value){
        setState((){
          if(widget.searchQuery.length>0){
            contacts = value.where((element) => (element.lastName+" "+element.firstName).toLowerCase().contains(widget.searchQuery.toLowerCase())
            ).toList();
          }
          else{
            contacts = value;
          }
          if(!widget.contactListItemClickable){
            //contacts =  contacts.where((element) => (element.contactAddressList.first.companyId==widget.companyModel!.id)).toList();
            contacts =  contacts.where((element) => (widget.companyModel!.serverId!=0&&element.contactAddressList.first.companyId==widget.companyModel!.serverId)).toList();
          }
          contacts.forEach((element) {
            print(element.toString());
          });
        });
      });
    }
    else{
      /*if(widget.searchQuery.length>0){
          contacts = widget.primaryContactModel!=null?List.from(widget.primaryContactModel!.contactAddressList.where((element) => (element.name).toLowerCase().contains(widget.searchQuery.toLowerCase()))):[];
          if((widget.primaryContactModel!.lastName+" "+widget.primaryContactModel!.firstName).toLowerCase().contains(widget.searchQuery.toLowerCase())){
            widget.primaryContactModel!=null?contacts.insert(0, widget.primaryContactModel!):[];
          }
        }
        else{
          contacts = widget.primaryContactModel!=null?List.from(widget.primaryContactModel!.contactAddressList):[];
          widget.primaryContactModel!=null?contacts.insert(0, widget.primaryContactModel!):[];
        }*/
    }

  }
  String hintText = '';
  @override
  void initState() {
    super.initState();
    CompanyDao().getAllCompanies().then((value){
      companies = value;
    });
    WidgetsBinding.instance!.addObserver(this);
    widget.searchQuery = "";
    // CompanyDao().getAllCompanies().then((valueee) {
    //   companies=valueee;
    getContacts();
    // });
    FBroadcast.instance().register(ConstantBroadcastKeys.KEY_UPDATE_UI, (value, callback) {
      /*ContactModel c = value;
      contacts.forEach((element) {
        if(element.id == c.id){
          setState(() {
            element.serverId = c.serverId;
            element.isSynced = c.isSynced;
          });
        }
      });*/
      setState(() {
        getContacts();
      });
    });


  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    WidgetsBinding.instance!.removeObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // TODO: implement didChangeAppLifecycleState
    super.didChangeAppLifecycleState(state);
    switch(state){
      case AppLifecycleState.detached:
        print("Detached");
        break;
      case AppLifecycleState.paused:
        print("Paused");
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLandscape = MediaQuery.of(context).orientation == Orientation.landscape;
    return Scaffold(
      appBar: AppBarOptifood(isShowSearchBar: true,onSearch: (search){
        widget.searchQuery = search;
        //if(sear)
        setState(() {
          getContacts();
        });
      },),
      body: contacts.length>0?Padding(
        padding: const EdgeInsets.only(top: 3),
        child: Container(
          child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(3, 0, 3, 0),
                child: ListView.builder(
                    itemCount: contacts.length,
                    itemBuilder: (context, index) => GestureDetector(
                      onHorizontalDragStart: (DragStartDetails details){
                        if(widget.showOptionMenu) {
                          if(widget.primaryContactModel!=null&&index==0){ //in extra address on index 0 it show main contact
                            return;
                          }
                          setState(() {
                            showDialog(context: context,
                                builder: (BuildContext context) {
                                  return ContactOptionMenuPopup(
                                      isShowAddressOption: widget
                                          .primaryContactModel == null,
                                      onSelect: (action) async {
                                        if (action ==
                                            ContactOptionMenuPopup.ACTIONS
                                                .ACTION_EDIT) {
                                          ContactModel updatedContactModel = await Navigator.of(context).push(
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      ClientRegister(primaryContactModel: widget.primaryContactModel,
                                                        existingContactModel: contacts[index],
                                                      )
                                              ));
                                          if(widget.primaryContactModel!=null){
                                            /*widget.primaryContactModel!.extraAddressList.removeAt(index-1);
                                                widget.primaryContactModel!.extraAddressList.insert(index-1, updatedContactModel);*/
                                            widget.primaryContactModel!.contactAddressList.removeAt(index);
                                            widget.primaryContactModel!.contactAddressList.insert(index, updatedContactModel.getDefaultAddress());
                                            ContactDao().updateContact(widget.primaryContactModel!);
                                          }
                                          setState(() {
                                            getContacts();
                                          });
                                        }
                                        else if (action ==
                                            ContactOptionMenuPopup.ACTIONS
                                                .ACTION_DELETE) {
                                          showDialog(
                                              context: context,
                                              builder: (BuildContext
                                              context) {
                                                return ConfirmationPopup(
                                                  title: "delete",
                                                  titleImagePath: AppImages.deleteIcon,
                                                  positiveButtonText: "delete",
                                                  negativeButtonText: "cancel",
                                                  titleImageBackgroundColor: AppTheme
                                                      .colorRed,
                                                  positiveButtonPressed: () async {
                                                    if (widget
                                                        .primaryContactModel !=
                                                        null) {
                                                      widget
                                                          .primaryContactModel!
                                                          .contactAddressList
                                                      //.removeAt(index-1); // because 0 index is main contact address
                                                          .removeAt(index); // because 0 index is main contact address changed
                                                      await ContactDao()
                                                          .updateContact(
                                                          widget
                                                              .primaryContactModel!);
                                                      setState(() {
                                                        getContacts();
                                                      });

                                                    }
                                                    else {
                                                      ContactDao().getContactById(contacts[index].id).then((value){
                                                        ContactDao().delete(contacts[index]).then((value22){
                                                          CustomerApis().deleteContact(value.serverId!);
                                                          setState(() {
                                                            getContacts();
                                                          });
                                                        });
                                                      });


                                                    }
                                                  },
                                                  subTitle: 'areYouSureToDeleteContact',
                                                );
                                              });
                                        }
                                        else if(action == ContactOptionMenuPopup.ACTIONS.ACTION_CALL){
                                          UrlLauncher.launch("tel:"+contacts[index].phoneNumber);
                                        }
                                        else if (action ==
                                            ContactOptionMenuPopup.ACTIONS
                                                .ACTION_ADDRESSES) {
                                          /*await Navigator.of(context).push(
                                                  MaterialPageRoute(
                                                      builder: (context) =>
                                                          ContactList(
                                                            primaryContactModel: contacts[index],showOptionMenu: true,)));*/
                                          print("===============contacts[index].getDefaultAddress().serverId[index]==========${contacts[index].getDefaultAddress().serverId}============================");
                                          await Navigator.of(context).push(
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      ContactAddressList(
                                                        contacts[index],
                                                        // showOptionMenu: true,
                                                      )));
                                          setState(() {

                                          });
                                        }
                                      });
                                });
                          });
                        }
                      },
                      onTap: () async {
                        //_chekOrderService(widget.delivery);
                        /*await Navigator.of(context).push(MaterialPageRoute(builder:
                                //(context)=>DeliveryInfo(s: '${contacts[index].firstName+" "+contacts[index].lastName}',)));
                                (context)=>DeliveryInfo(customer: contacts[index],)));

                            Navigator.pop(context);*/

                        if(widget.contactListItemClickable) {
                          if(widget.showOptionMenu){
                            print("===============================================brhanse smreeeeeeeeeeeeeeeeeeee");
                            ContactModel updatedContactModel = await Navigator.of(context).push(
                                MaterialPageRoute(
                                    builder: (context) =>
                                        ClientRegister(primaryContactModel: widget.primaryContactModel,
                                            existingContactModel: contacts[index],
                                            callBack:(String on){
                                              print("Call back nowwwwwwwwww: ${on}");
                                              setState(() {
                                                widget.callBack!(on);
                                              });
                                            }
                                        )
                                ));
                            if(widget.primaryContactModel!=null){
                              //contacts.removeAt(index+1);
                              //contacts.insert(index+1, updatedContactModel);
                              if(widget.primaryContactModel!.contactAddressList.length!=0) {
                                widget.primaryContactModel!.contactAddressList
                                //.removeAt(index - 1);
                                    .removeAt(index);
                              }
                              //widget.primaryContactModel!.extraAddressList.insert(index-1, updatedContactModel);
                              widget.primaryContactModel!.contactAddressList.insert(index, updatedContactModel.getDefaultAddress());
                              ContactDao().updateContact(widget.primaryContactModel!);
                            }
                            setState(() {
                              getContacts();
                            });
                          }
                          else {
                            manageNavigator(
                                contacts[index], SOURCE_CLICKED_LIST_ITEM);
                          }
                        }
                      },
                      child: Container(
                        //height: 88,
                        child: Card(
                          color: Colors.white,
                          surfaceTintColor: Colors.transparent,
                          shadowColor: Colors.white38,
                          elevation:4,
                          shape:  RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10), // <-- Radius
                          ),
                          child: Row(
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(left: 8,right: 2),
                                child: Container(
                                  width: 38,
                                  child:
                                  widget.primaryContactModel==null?
                                  widget.existingOrder!=null && widget.existingOrder!.customer!=null&& widget.existingOrder!.customer!.serverId==contacts[index].serverId?SvgPicture.asset(AppImages.checkmarkIcon,
                                      height: 35, color: AppTheme.colorGreen,):SvgPicture.asset(AppImages.clientInfoIcon,
                                    height: 35,):
                                  // contacts[index].companyModel==null?
                                  // SvgPicture.asset(AppImages.clientInfoIcon,
                                  //       height: 35)
                                  //     :
                                  SvgPicture.asset(AppImages.companyIcon,
                                      height: 35,color: widget.existingOrder!.customer!.serverId==contacts[index].serverId?
                                      AppTheme.colorDarkGrey:null),
                                ),
                              ),
                              Container(height: 50, child: VerticalDivider(color: Colors.black54)),
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.all(7.0),
                                  child: ListTile(
                                    contentPadding: EdgeInsets.all(0),
                                    dense: true,
                                    title: Transform.translate(
                                      //offset: Offset(-20,0),
                                        offset: Offset(0,0),
                                        child: Text("${contacts[index].lastName} "+"${contacts[index].firstName}"+"${widget.primaryContactModel!=null&&contacts[index].getDefaultAddress().companyModel!=null?" / "+contacts[index].getDefaultAddress().companyModel!.name:""}",
                                          style: TextStyle(fontWeight: FontWeight.bold,fontSize: 18),)),
                                    subtitle: Padding(
                                      padding: const EdgeInsets.only(top: 4),
                                      child: Transform.translate(
                                        //offset: Offset(-20, 0),
                                        offset: Offset(0, 0),
                                        child: Container(
                                          alignment: Alignment.centerLeft,
                                          child: Column(
                                            mainAxisAlignment: MainAxisAlignment.start,
                                            children: [
                                              if(widget.primaryContactModel==null&&contacts[index].getDefaultAddress()!=null&&contacts[index].getDefaultAddress().companyModel!=null)...[
                                                Padding(
                                                  padding: const EdgeInsets.only(bottom: 6),
                                                  child: Row(
                                                    children: [
                                                      Padding(
                                                        padding: const EdgeInsets.only(right: 4),
                                                        child: SvgPicture.asset(AppImages.companyIcon,
                                                          height: 15,color: AppTheme.colorMediumGrey,),
                                                      ),
                                                      Expanded(child: Text("${contacts[index].getDefaultAddress().companyModel!.name}",overflow: TextOverflow.ellipsis,maxLines: 3,),),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                              Row(
                                                children: [
                                                  Padding(
                                                    padding: const EdgeInsets.only(right: 4),
                                                    child: SvgPicture.asset(AppImages.clientAddressIcon,
                                                        height: 15),
                                                  ),
                                                  Expanded(child: Text("${contacts[index].getDefaultAddress().address}",overflow: TextOverflow.ellipsis,maxLines: 3,),),
                                                ],
                                              ),
                                              Padding(
                                                padding: const EdgeInsets.only(top: 6),
                                                child: Row(
                                                  children: [
                                                    Padding(
                                                      padding: const EdgeInsets.only(right: 4),
                                                      child: SvgPicture.asset(AppImages.phoneClientIcon,
                                                          height: 15),
                                                    ),
                                                    Text("${contacts[index].phoneNumber}"),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                    trailing:
                                    (widget.primaryContactModel==null)&&widget.contactListItemClickable?InkWell( //show option menu will work only is settings and in setting not to show address icon
                                      child:
                                      Container(
                                        alignment: Alignment.centerLeft,
                                        width: 35,
                                        //child: SvgPicture.asset(AppImages.editDarkIcon,
                                        //  height: 25,),
                                        child: SvgPicture.asset(AppImages.clientAddressIcon,
                                          height: 45,color: AppTheme.colorRed,),
                                      ),
                                      onTap: (){
                                        manageNavigator(contacts[index], SOURCE_CLICKED_ADDRESS_ICON);
                                      },
                                    ):null,
                                    // (widget.primaryContactModel==null&&widget.showOptionMenu==false)?InkWell( //show option menu will work only is settings and in setting not to show address icon
                                    //   child:
                                    //   Container(
                                    //     alignment: Alignment.centerLeft,
                                    //     width: 35,
                                    //     //child: SvgPicture.asset(AppImages.editDarkIcon,
                                    //     //  height: 25,),
                                    //     child: SvgPicture.asset(AppImages.clientAddressIcon,
                                    //       height: 45,color: AppTheme.colorRed,),
                                    //   ),
                                    //   onTap: (){
                                    //     manageNavigator(contacts[index], SOURCE_CLICKED_ADDRESS_ICON);
                                    //   },
                                    // ):null,
                                    // (widget.primaryContactModel==null&&widget.showOptionMenu==false)?InkWell( //show option menu will work only is settings and in setting not to show address icon
                                    //   child:
                                    //   Container(
                                    //     alignment: Alignment.centerLeft,
                                    //     width: 35,
                                    //     //child: SvgPicture.asset(AppImages.editDarkIcon,
                                    //       //  height: 25,),
                                    //     child: SvgPicture.asset(AppImages.clientAddressIcon,
                                    //       height: 45,color: AppTheme.colorRed,),
                                    //   ),
                                    //   onTap: (){
                                    //     manageNavigator(contacts[index], SOURCE_CLICKED_ADDRESS_ICON);
                                    //   },
                                    // ):null,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    )
                ),
              )),
        ),
      ):  Center(child: Text(widget.companyModel!=null?"noCustomerInCompany".tr():"noDataFound".tr(),style: TextStyle(fontSize: 16),)) ,
      floatingActionButton: widget.showAddButton==false?
      widget.showSkipButton==false?null:Padding(
        padding: const EdgeInsets.only(top: 40),
        child: SizedBox(
          height: 65.0,
          width: 65.0,
          child: FittedBox(
            child: FloatingActionButton(
              backgroundColor: AppTheme.colorRed,
              //child: SvgPicture.asset(AppImages.nextIcon, height: 30,),
              child: Icon(Icons.skip_next,color: Colors.white,),
              onPressed: () async {
                //Navigator.pop(context);
                await Navigator.of(context).push(MaterialPageRoute(builder:
                    (context) => AddReservation(
                )));
              },
            ),
          ),
        ),
      )

          :Padding(
        padding: const EdgeInsets.only(top: 40),
        child: SizedBox(
          height: 65.0,
          width: 65.0,
          child: FittedBox(
            child: FloatingActionButton(
              backgroundColor: AppTheme.colorRed,
              child: SvgPicture.asset(AppImages.addWhiteIcon, height: 30,),
              onPressed: () async {
                //_chekOrderService(widget.delivery);
                //ContactModel contactModel = await Navigator.of(context).push(MaterialPageRoute(builder: (context)=>ClientRegister()));
                ContactModel contactModel = await Navigator.of(context).push(MaterialPageRoute(builder:
                    (context)=>ClientRegister(primaryContactModel: widget.primaryContactModel!=null?
                    widget.primaryContactModel!:null,isFromOrder:widget.isFromOrder)));
                if(widget.isFromOrder){
                  Navigator.pop(context);
                }
                if(contactModel!=null){ // if user press back button then there will no contatc selected
                  setState((){
                    getContacts();
                  });
                  /*await Navigator.of(context).push(MaterialPageRoute(builder:
                      (context)=>DeliveryInfo(customer: contactModel,)));
                  Navigator.pop(context);*/
                  if(!widget.showOptionMenu) {
                    //temp
                    if (widget.primaryContactModel == null) {
                      moveToNextScreen(contactModel);
                    }
                    else {
                      Navigator.pop(context,
                          contactModel); // if screen open for multiple address then it should close first and delivery info should call from main contents to maintain lifecycle
                    }
                  }
                }
              },
            ),
          ),
        ),
      ),
    );
  }
  /*Future<void> deleteContact(int serverId) async {
    final dio = Dio();
    dio.options.headers['X-TenantID'] = ServerData.OPTIFOOD_DATABASE.toString();
    await dio.delete(ServerData.OPTIFOOD_BASE_URL+"/api/customer/${serverId}").then((value){
    });
  }*/
  Future<void> manageNavigator(ContactModel selectedContactModel,String sourceClicked)
  async {
    if(widget.primaryContactModel == null) //case when screen open for main contact orderServiceList
        {
      if(selectedContactModel.contactAddressList.length>1&& !widget.isFromReservation){
        ContactAddressModel contactAddressModel = await Navigator.of(context).push(MaterialPageRoute(builder:
            (context)=>ContactAddressList(selectedContactModel,isFromOrder:widget.isFromOrder)));

        if(contactAddressModel==null){
          //Navigator.pop(context,contactModel);
          Navigator.pop(context);
        }
        else{

          selectedContactModel.contactAddressList = [contactAddressModel];
          print("=========contactAddressModel.serverIdoooooooooooooommmmmmmm========="
              "${selectedContactModel.contactAddressList!.first.serverId}========================");

          await Navigator.of(context).push(MaterialPageRoute(builder:
              (context) => DeliveryInfo(customer: selectedContactModel,
              existingOrder: widget.existingOrder,
              callBack:(String on){
                widget.callBack!(on);

              }
          )));
          Navigator.pop(context);
        }
      }
      else{
        if(sourceClicked == SOURCE_CLICKED_ADDRESS_ICON){
          ContactModel contactModel = await Navigator.of(context).push(MaterialPageRoute(builder:
              (context)=>ClientRegister(primaryContactModel: selectedContactModel,isToAddNewAddress:true)));
          if(contactModel!=null){
            moveToNextScreen(contactModel);
          }
        }
        else if(widget.showAddButton==false&&widget.showSkipButton==true){
          await Navigator.of(context).push(MaterialPageRoute(builder:
              (context) => AddReservation(contactModel: selectedContactModel,
          )));
          Navigator.pop(context);
        }
        else{
          await Navigator.of(context).push(MaterialPageRoute(builder:
              (context) => DeliveryInfo(customer: selectedContactModel,
              existingOrder: widget.existingOrder,
              callBack:(String on){
                widget.callBack!(on);

              }
          )));
          Navigator.pop(context);
        }
      }
    }
    else{

      Navigator.pop(context,selectedContactModel);
    }
  }
  Future<void> moveToNextScreen(ContactModel contactModel) async {
    if(widget.returnContact){
      Navigator.pop(context,contactModel);
    }
    else {
      print(contactModel.id.toString()+","+contactModel.serverId!.toString());
      /*await Navigator.of(context).push(MaterialPageRoute(builder:
          (context) => DeliveryInfo(customer: contactModel,
            existingOrder: widget.existingOrder,
              callBack:(String on){
                widget.callBack!(on);

              }
          )));
      Navigator.pop(context);*/
    }
  }

}