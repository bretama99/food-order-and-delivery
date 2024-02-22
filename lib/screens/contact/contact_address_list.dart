import 'package:fbroadcast/fbroadcast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:opti_food_app/data_models/contact_address_model.dart';
import 'package:opti_food_app/database/contact_dao.dart';

import '../../assets/images.dart';
import '../../data_models/company_model.dart';
import '../../data_models/contact_model.dart';
import '../../database/company_dao.dart';
import '../../utils/constants.dart';
import '../../widgets/app_theme.dart';
import '../../widgets/appbar/app_bar_optifood.dart';
import '../../widgets/option_menu/contact/contact_option_menu_popup.dart';
import '../authentication/client_register.dart';
import 'add_company.dart';
import '../MountedState.dart';

class ContactAddressList extends StatefulWidget{
  ContactModel primaryContactModel;
  String searchQuery = "";
  bool returnContact = false;//should false if move to create order after that, should true if return contact to previous screen.
  bool showAddButton = true;
  bool showSkipButton = false;
  bool contactListItemClickable = true; // will false when contact list open from company
  bool showOptionMenu = false;
  bool isFromOrder=false;
  ContactAddressList(this.primaryContactModel, {this.isFromOrder=false});
  @override
  State<StatefulWidget> createState() => _ContactAddressState();
}

class _ContactAddressState extends MountedState<ContactAddressList> with WidgetsBindingObserver{
  List<ContactAddressModel> contactAddresses = [];
  List<CompanyModel> companies = [];
  @override
  void initState() {
    super.initState();
    CompanyDao().getAllCompanies().then((value){
      companies = value;
    });
    WidgetsBinding.instance!.addObserver(this);
    widget.searchQuery = "";
    getContactAddresses();
    FBroadcast.instance().register(ConstantBroadcastKeys.KEY_UPDATE_UI, (value, callback) {
      setState(() {
        getContactAddresses();
      });
    });
  }
  @override
  void getContactAddresses() async {
      if(widget.searchQuery.length>0){
        contactAddresses = List.from(widget.primaryContactModel!.contactAddressList.where((element) =>
            (element.name).toLowerCase().contains(widget.searchQuery.toLowerCase())));
      }
      else{
        // await ContactDao().getAllContacts().then((value){
        //   print("================value==${value.length}=================================");
        //   contactAddresses = widget.primaryContactModel!=null?List.from(value.where((element) =>
        //   element.id==widget.primaryContactModel!.id).first.contactAddressList):[];
        //   print("================value==${contactAddresses.length}=================================");
        //
        // });
        contactAddresses = widget.primaryContactModel!=null?List.from(widget.primaryContactModel!.contactAddressList):[];
      }
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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarOptifood(isShowSearchBar: true,onSearch: (search){
        widget.searchQuery = search;
        //if(sear)
        setState(() {
          getContactAddresses();
        });
      },),
      body: Padding(
        padding: const EdgeInsets.only(top: 3),
        child: Container(
          child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(3, 0, 3, 0),
                child: ListView.builder(
                    itemCount: contactAddresses.length,
                    itemBuilder: (context, index) => GestureDetector(
                      onTap: () async {

                        if(widget.contactListItemClickable && widget.isFromOrder) {
                          print("====================nottt==========brhane iffffffffffffffffff..${contactAddresses[index].name}..................");
                          Navigator.pop(context,contactAddresses[index]);
                          //}
                        }
                        else{
                          print("====================nottt==========brhane else.....${contactAddresses[index].name}...............");

                          await Navigator.of(context).push(MaterialPageRoute(builder:
                              (context)=>
                                  ClientRegister(primaryContactModel:widget.primaryContactModel,
                                      contactAddressId: contactAddresses[index].id,
                                      isContactAddressToEdit:true)));
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
                                  SvgPicture.asset(contactAddresses[index].companyModel!=null?AppImages.companyIcon:AppImages.clientAddressIcon,
                                      height: 35,color: Colors.black,),
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
                                        //child: Text("${widget.primaryContactModel.lastName+" "+widget.primaryContactModel.firstName}"+
                                        child: Text("${contactAddresses[index].name==""?widget.primaryContactModel.lastName+" "+widget.primaryContactModel.firstName:contactAddresses[index].name}"+
                                                "${contactAddresses[index].companyModel!=null?" / "+contactAddresses[index].companyModel!.name:""}",
                                        // Text("${contactAddresses[index].name==null?widget.primaryContactModel.lastName+" "
                                        //     ""+widget.primaryContactModel.firstName:contactAddresses[index].name} "+
                                        //     "${contactAddresses[index].companyModel!=null?" / "+contactAddresses[index].companyModel!.name:""}",
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
                                              Row(
                                                children: [
                                                  Padding(
                                                    padding: const EdgeInsets.only(right: 4),
                                                    child: SvgPicture.asset(AppImages.clientAddressIcon,
                                                        height: 15),
                                                  ),
                                                  Expanded(child: Text("${contactAddresses[index].address}",overflow: TextOverflow.ellipsis,maxLines: 3,),),
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
                                                    //Text("${contacts[index].phoneNumber}"),
                                                    Text("${widget.primaryContactModel.phoneNumber}"),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                    trailing:
                                    (widget.primaryContactModel==null)?InkWell( //show option menu will work only is settings and in setting not to show address icon
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
                                        //manageNavigator(contacts[index], SOURCE_CLICKED_ADDRESS_ICON);
                                      },
                                    ):null,

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
      ),
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
                Navigator.pop(context);
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
                ContactModel contactModel = await Navigator.of(context).push(MaterialPageRoute(builder: (context)=>
                    ClientRegister(primaryContactModel: widget.primaryContactModel,isToAddNewAddress:true)));
                if(contactModel!=null){ // if user press back button then there will no contatc selected
                  setState((){
                    //getContacts();
                    getContactAddresses();
                  });
                  if(!widget.showOptionMenu) {
                    //temp
                    if (widget.primaryContactModel == null) {
                      //moveToNextScreen(contactModel);
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

}