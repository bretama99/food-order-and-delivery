import 'dart:async';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:fbroadcast/fbroadcast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:opti_food_app/api/company_api.dart';
import 'package:opti_food_app/data_models/company_model.dart';
import 'package:opti_food_app/data_models/contact_model.dart';
import 'package:opti_food_app/database/company_dao.dart';
import 'package:opti_food_app/database/contact_dao.dart';
import 'package:opti_food_app/widgets/appbar/app_bar_optifood.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../assets/images.dart';
import '../../utils/constants.dart';
import '../../utils/utility.dart';
import '../../widgets/app_theme.dart';
import '../../widgets/option_menu/company/company_option_menu_popup.dart';
import '../../widgets/popup/confirmation_popup/confirmation_popup.dart';
import '../MountedState.dart';
import '../authentication/client_register.dart';
import '../authentication/delivery_info.dart';
import '../order/ordered_lists.dart';
import 'add_company.dart';
import 'contact_list.dart';

class CompanyList extends StatefulWidget {
  //final String delivery;
  static String searchQuery = "";
  bool showOptionMenu = false;
  //bool returnContact = false;//should true if move to create order after that, should false if return contact to previous screen.
  //ContactList({Key? key, required this.delivery,this.primaryContactModel=null,this.returnContact=false}) : super(key: key);
  //ContactList({Key? key,this.primaryContactModel=null,this.returnContact=false}) : super(key: key);
  CompanyList({this.showOptionMenu = false});
  @override
  State<CompanyList> createState() => _CompanyListState();
}
class _CompanyListState extends MountedState<CompanyList> {
  FocusNode focusNode = FocusNode();
  List<CompanyModel> companyList = [];
  void getCompanies() async {
      CompanyDao().getAllCompanies().then((value){
        setState((){
          //contacts = value;
          if(CompanyList.searchQuery.length>0){
            companyList = value.where((element) => (element.name).toLowerCase().contains(CompanyList.searchQuery.toLowerCase())).toList();
          }
          else{
            companyList = value;
          }
          /*contacts.forEach((element) {
            print(element.toString());
          });*/
        });
      });
  }
  String hintText = '';
  @override
  void initState() {
    //getOrderService();
    getCompanies();
    FBroadcast.instance().register(ConstantBroadcastKeys.KEY_UPDATE_UI, (value, callback) {
      setState(() {
        getCompanies();
      });
    });
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    final isLandscape = MediaQuery.of(context).orientation == Orientation.landscape;
    return Scaffold(
      appBar: AppBarOptifood(isShowSearchBar: true,onSearch: (search){
        CompanyList.searchQuery = search;
        setState(() {
          getCompanies();
        });
      },),
      body: companyList.length>0?Padding(
        padding: const EdgeInsets.only(top: 3),
        child: Container(
          child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(3, 0, 3, 0),
                child: ListView.builder(
                    itemCount: companyList.length,
                    itemBuilder: (context, index) => GestureDetector(
                      onHorizontalDragStart: (DragStartDetails details){
                        if(widget.showOptionMenu) {
                          setState(() {
                            showDialog(context: context,
                                builder: (BuildContext context) {
                                  return CompanyOptionMenuPopup(
                                      onSelect: (action) async {
                                        //var orderServiceID =  widget.orderType==ConstantOrderType.ORDER_TYPE_DELIVERY?ConstantCurrentOrderService.DELIVER_ORDER_TYPE:ConstantCurrentOrderService.RESTAURANT_ORDER_TYPE_EAT_IN;
                                        if (action ==
                                            CompanyOptionMenuPopup.ACTIONS
                                                .ACTION_EDIT) {
                                          await Navigator.of(context).push(
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      AddCompany(
                                                        existingCompanyModel: companyList[index],
                                                      )
                                              ));
                                          setState(() {
                                            getCompanies();
                                          });
                                        }
                                        else if (action ==
                                            CompanyOptionMenuPopup.ACTIONS
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
                                                  positiveButtonPressed: () {
                                                    ContactDao().getAllContactsByCompany(companyList[index]).then((value22){
                                                      if(value22.length==0) {
                                                        CompanyDao()
                                                            .getCompanyById(
                                                            companyList[index]
                                                                .id)
                                                            .then((
                                                            value) async {
                                                          CompanyDao()
                                                              .delete(
                                                              companyList[index])
                                                              .then((value22) {
                                                            CompanyApis().deleteCompany(value
                                                                .serverId!);
                                                            setState(() {
                                                              getCompanies();
                                                            });
                                                          });
                                                        });
                                                      }
                                                      else{
                                                        Utility().showToastMessage("theCompanyMustBeEmptyToBeDeleted".tr());
                                                      }
                                                    });
                                                  },
                                                  subTitle: 'areYouSureToDeleteCompany',
                                                );
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
                        //manageNavigator(contacts[index], SOURCE_CLICKED_LIST_ITEM);
                        Navigator.of(context).push(MaterialPageRoute(builder:
                            (context) => ContactList(returnContact: true,showAddButton: false,companyModel: companyList[index],contactListItemClickable:false,)));
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
                                  //child: SvgPicture.asset(AppImages.clientInfoIcon,
                                  child: companyList[index].imagePath==null?
                                  SvgPicture.asset(AppImages.companyIcon,
                                      height: 35):
                                    /*CircleAvatar(
                                      backgroundImage: FileImage(File(companyList[index].imagePath!)),
                                      radius: 35,
                                    )*/
                                  Image.file(File(companyList[index].imagePath!.toString()),height: 35,),
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
                                        child: Text("${companyList[index].name}",
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
                                              if(companyList[index].address!=null)...[
                                              Row(
                                                children: [
                                                  Padding(
                                                    padding: const EdgeInsets.only(right: 4),
                                                    child: SvgPicture.asset(AppImages.clientAddressIcon,
                                                        height: 15),
                                                  ),
                                                  Expanded(child: Text("${companyList[index].address}",overflow: TextOverflow.ellipsis,maxLines: 3,),),
                                                ],
                                              ),
                                              ],
                                              //if(companyList[index].phoneNo!=null)...[
                                              Padding(
                                                padding: const EdgeInsets.only(top: 6),
                                                child: Row(
                                                  children: [
                                                    Padding(
                                                      padding: const EdgeInsets.only(right: 4),
                                                      child: SvgPicture.asset(AppImages.phoneClientIcon,
                                                          height: 15),
                                                    ),
                                                    Text("${companyList[index].phoneNo==null?"":companyList[index].phoneNo}"),
                                                   //Text("${companyList[index].phoneNo}"),
                                                  ],
                                                ),
                                              ),
                                              //],
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                    //trailing:
                                    /*widget.primaryContactModel==null?InkWell(
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
                                    ):null,*/
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
      )
          :  Center(child: Text("noDataFound".tr(),style: TextStyle(fontSize: 16),)),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(top: 40),
        child: SizedBox(
          height: 65.0,
          width: 65.0,
          child: FittedBox(
            child: FloatingActionButton(
              backgroundColor: AppTheme.colorRed,
              child: SvgPicture.asset(AppImages.addWhiteIcon, height: 30,),
              onPressed: () async {
                CompanyModel companyModel = await Navigator.of(context).push(MaterialPageRoute(builder: (context)=>AddCompany()));
                //if(companyModel!=null){
                  getCompanies();
                //}
              },
            ),
          ),
        ),
      ),
    );
  }

  /*Future<void> deleteCompany(int serverId) async {
    final dio = Dio();
    dio.options.headers['X-TenantID'] = ServerData.OPTIFOOD_DATABASE.toString();
    await dio.delete(ServerData.OPTIFOOD_BASE_URL+"/api/company/${serverId}").then((value){
    });
  }*/
  /*Future<void> manageNavigator(ContactModel selectedContactModel,String sourceClicked)
  async {
    if(widget.primaryContactModel == null) //case when screen open for main contact orderServiceList
        {
      if(selectedContactModel.extraAddressList.isNotEmpty){ //if have extra address then choose from extra addresses
        ContactModel contactModel = await Navigator.of(context).push(MaterialPageRoute(builder:
            (context)=>ContactList(primaryContactModel: selectedContactModel,)));

        *//*await Navigator.of(context).push(MaterialPageRoute(builder:
            (context)=>DeliveryInfo(customer: contactModel,)));
        Navigator.pop(context);*//*
        if(contactModel!=null){
          moveToNextScreen(contactModel);
        }
      }
      else{
        if(sourceClicked == SOURCE_CLICKED_ADDRESS_ICON){
          ContactModel contactModel = await Navigator.of(context).push(MaterialPageRoute(builder:
              (context)=>ClientRegister(primaryContactModel: selectedContactModel,)));
          if(contactModel!=null){
            *//*await Navigator.of(context).push(MaterialPageRoute(builder:
                (context)=>DeliveryInfo(customer: contactModel,)));
            Navigator.pop(context);*//*
            moveToNextScreen(contactModel);
          }
        }
        else{
          *//* await Navigator.of(context).push(MaterialPageRoute(builder:
              (context)=>DeliveryInfo(customer: selectedContactModel,)));
          Navigator.pop(context);*//*
          moveToNextScreen(selectedContactModel);
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
      await Navigator.of(context).push(MaterialPageRoute(builder:
          (context) => DeliveryInfo(customer: contactModel,)));
      Navigator.pop(context);
    }
  }
*/
}
