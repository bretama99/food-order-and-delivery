import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:opti_food_app/data_models/service_activation_model.dart';
import 'package:opti_food_app/database/service_activation_dao.dart';
import 'package:opti_food_app/screens/contact/company_list.dart';
import 'package:opti_food_app/screens/contact/contact_list.dart';
import 'package:opti_food_app/screens/message/message_list.dart';
import 'package:opti_food_app/screens/products/attribute_category_list.dart';
import 'package:opti_food_app/screens/products/food_category_list.dart';
import 'package:opti_food_app/screens/settings/add_night_fee.dart';
import 'package:opti_food_app/screens/user/user_list.dart';
import 'package:opti_food_app/utils/constants.dart';
import 'package:opti_food_app/widgets/app_theme.dart';
import 'package:opti_food_app/widgets/appbar/app_bar_optifood.dart';
import 'package:opti_food_app/widgets/appbar/app_icon_model.dart';
import '../../assets/images.dart';
import '../../main.dart';
import '../order/ordered_lists.dart';
import 'add_delivery_fee.dart';
import 'optifood_menu_item.dart';
import 'package:easy_localization/easy_localization.dart';
import '../MountedState.dart';import '../MountedState.dart';
class OptifoodManagementMenu extends StatefulWidget{
  List<OptifoodMenuItem> activeMenuList = [];
  OptifoodMenuItem? parentMenu = null;
  ServiceActivationModel? serviceActivationModel=null;
  OptifoodManagementMenu({this.parentMenu = null, this.serviceActivationModel = null});
  List<String> allowedPrivileges=[];
  @override
  State<StatefulWidget> createState() => _OptifoodManagementMenuState();
}

class _OptifoodManagementMenuState extends MountedState<OptifoodManagementMenu>{
  @override
  void initState() {
    populatAllowedSubCategories();
    if(widget.serviceActivationModel==null)
      populateServiceActivation();
    // TODO: implement initState
    super.initState();
    if(widget.parentMenu!=null){
      if(widget.parentMenu!.id == ManagementMenu.CUSTOMER_MANAGEMENT.id){
        widget.activeMenuList = getCustomerManagement();
      }
      else if(widget.parentMenu!.id == ManagementMenu.RESTAURANT_MENU.id){
        widget.activeMenuList = getRestaurantMenu();
      }
      else if(widget.parentMenu!.id == ManagementMenu.USER_MANAGEMENT.id){
        widget.activeMenuList = getUserMenu();
      }
      else if(widget.parentMenu!.id == ManagementMenu.OPTIFOOD_MANAGEMENT.id){
        widget.activeMenuList = getOptiFoodManagementMenu();
      }
    }
    else{
      widget.activeMenuList = getManagementList();
    }
  }
  @override
  Widget build(BuildContext context) {
    PreferredSizeWidget appBarWidget = AppBarOptifood();
    if(widget.parentMenu!=null){
      appBarWidget = AppBarOptifood(appIconList: [
        AppIconModel(svgPicture: SvgPicture.asset(AppImages.phoneWithHandIcon,
          height: 30, color: AppTheme.colorRed,), onTap: (){
          Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context)=>OrderedList()));
        }),
      ],);
    }
    return Scaffold(
      appBar: appBarWidget,
      body: Container(
        child: ListView.separated(
          padding: EdgeInsets.only(top: 5),
          itemCount: widget.activeMenuList.length,
          separatorBuilder: (context,index) => Divider(),
          itemBuilder: (context,index){
            return ListTile(
              onTap: (){
                String menuItemID = widget.activeMenuList[index].id;
                if(menuItemID == RestaurantMenu.PRODUCT_MANAGEMENT.id){
                  Navigator.of(context).push(
                      MaterialPageRoute(builder: (context) =>
                          FoodCategoryList()));
                }
                else if(menuItemID == RestaurantMenu.PRODUCT_ATTRIBUTES.id){
                  Navigator.of(context).push(
                      MaterialPageRoute(builder: (context) =>
                          AttributeCategoryList()));
                }
                else if(menuItemID == CustomerManagementMenu.COMPANY_MANAGEMENT.id) {
                  Navigator.of(context).push(
                      MaterialPageRoute(builder: (context) =>
                          CompanyList(showOptionMenu: true,)));
                }
                else if(menuItemID == CustomerManagementMenu.CUSTOMER_MANAGEMENT.id){
                  Navigator.of(context).push(
                      MaterialPageRoute(builder: (context) =>
                          ContactList(contactListItemClickable: true,showOptionMenu: true,)));
                }
                else if(menuItemID == UserManagementMenu.MANAGER_MANAGEMENT.id){
                  Navigator.of(context).push(
                      MaterialPageRoute(builder: (context) =>
                          UserList(ConstantUserRole.USER_ROLE_MANAGER)));
                }

                else if(menuItemID == UserManagementMenu.MANAGER_MANAGEMENT.id){
                  Navigator.of(context).push(
                      MaterialPageRoute(builder: (context) =>
                          UserList(ConstantUserRole.USER_ROLE_MANAGER)));
                }

                else if(menuItemID == UserManagementMenu.DELIVERY_BOY_MANAGEMENT.id){
                  Navigator.of(context).push(
                      MaterialPageRoute(builder: (context) =>
                          UserList(ConstantUserRole.USER_ROLE_DELIVERY_BOY)));
                }
                else if(menuItemID == UserManagementMenu.WAITER_MANAGEMENT.id){
                  Navigator.of(context).push(
                      MaterialPageRoute(builder: (context) =>
                          UserList(ConstantUserRole.USER_ROLE_WAITER)));
                }
                else if(menuItemID==OptifoodManagementMenus.TAKE_AWAY_MODE.id || menuItemID==OptifoodManagementMenus.EAT_IN_MODE.id || menuItemID==OptifoodManagementMenus.TABLE_MANAGEMENT.id || menuItemID==OptifoodManagementMenus.DELIVERY_MODE.id){
                  return;
                }

                else if(menuItemID==OptifoodManagementMenus.TAKE_AWAY_MODE.id || menuItemID==OptifoodManagementMenus.EAT_IN_MODE.id || menuItemID==OptifoodManagementMenus.TABLE_MANAGEMENT.id || menuItemID==OptifoodManagementMenus.DELIVERY_MODE.id){
                  return;
                }

                else if(menuItemID==OptifoodManagementMenus.DELIVERY_FEE.id){
                  Navigator.of(context).push(
                      MaterialPageRoute(builder: (context) =>
                          AddDeliveryFee()));
                }

                else if(menuItemID==OptifoodManagementMenus.NIGHT_MODE.id){
                  Navigator.of(context).push(
                      MaterialPageRoute(builder: (context) =>
                          AddNightFee()));
                }

                else if(menuItemID==ManagementMenu.MESSAGE_MAMAGEMENT.id){
                  Navigator.of(context).push(
                      MaterialPageRoute(builder: (context) =>
                          MessageList()));
                }


                else {
                  Navigator.of(context).push(
                      MaterialPageRoute(builder: (context) =>
                          OptifoodManagementMenu(parentMenu: widget.activeMenuList[index],
                            serviceActivationModel: widget.serviceActivationModel,)));
                }
              },
              leading: widget.activeMenuList[index].id==OptifoodManagementMenus.TABLE_MANAGEMENT.id?
              getIcon(index):widget.activeMenuList[index].icon,
              title: Text(widget.activeMenuList[index].text.tr(),style: TextStyle(color:
                      widget.activeMenuList[index].id!=OptifoodManagementMenus.TABLE_MANAGEMENT.id?AppTheme.colorDarkGrey:
                      widget.serviceActivationModel!.eatInMode?AppTheme.colorDarkGrey:AppTheme.colorGrey),),
                trailing: widget.activeMenuList[index].isShowSwitch==false?null:
                Switch(activeColor: Color(0xffdb1e24), value:
                widget.activeMenuList[index].id==OptifoodManagementMenus.TAKE_AWAY_MODE.id ?widget.serviceActivationModel!.takeawayMode:
                widget.activeMenuList[index].id==OptifoodManagementMenus.EAT_IN_MODE.id?widget.serviceActivationModel!.eatInMode:
                widget.activeMenuList[index].id==OptifoodManagementMenus.TABLE_MANAGEMENT.id?widget.serviceActivationModel!.tableManagement:
                widget.serviceActivationModel!.deliveryMode, onChanged: (data){
                  setState(() {
                    // widget.serviceActivationModel!.tableManagement=false;
                    widget.activeMenuList[index].isSwitchOn = data;
                    updateServiceActivation(widget.activeMenuList[index].text, data);
                  });
                }),
            );
          },
        ),
      ),
    );
  }
  Widget getIcon(index){
    return SvgPicture.asset("assets/images/icons/dinner-table.svg", height: 30,
      color: widget.activeMenuList[index].id!=OptifoodManagementMenus.TABLE_MANAGEMENT.id?AppTheme.colorGrey:
      widget.serviceActivationModel!.eatInMode?AppTheme.colorRed:AppTheme.colorGrey,);

  }
  List<OptifoodMenuItem> getManagementList(){
    List<OptifoodMenuItem> list = [
      OptifoodMenuItem.clone(ManagementMenu.RESTAURANT_MENU),
      OptifoodMenuItem.clone(ManagementMenu.CUSTOMER_MANAGEMENT),
      OptifoodMenuItem.clone(ManagementMenu.USER_MANAGEMENT),
      OptifoodMenuItem.clone(ManagementMenu.MESSAGE_MAMAGEMENT),
      OptifoodMenuItem.clone(ManagementMenu.OPTIFOOD_MANAGEMENT),
      OptifoodMenuItem.clone(ManagementMenu.API_INTEGRATION),
    ];
    list=list.where((element) => widget.allowedPrivileges.contains(element.privilegeName)).toList();
    return list;
  }
  List<OptifoodMenuItem> getCustomerManagement(){
    List<OptifoodMenuItem> list = [
      OptifoodMenuItem.clone(CustomerManagementMenu.CUSTOMER_MANAGEMENT),
      OptifoodMenuItem.clone(CustomerManagementMenu.COMPANY_MANAGEMENT),
    ];
    list=list.where((element) => widget.allowedPrivileges.contains(element.privilegeName)).toList();
    return list;

  }
  List<OptifoodMenuItem> getRestaurantMenu(){
    List<OptifoodMenuItem> list = [
      //OptifoodMenuItem.clone(RestaurantMenu.FOOD_MENU_MANAGEMENT), // COMMENTED FOR NOW
      OptifoodMenuItem.clone(RestaurantMenu.PRODUCT_MANAGEMENT),
      OptifoodMenuItem.clone(RestaurantMenu.PRODUCT_ATTRIBUTES),
    ];
    list=list.where((element) => widget.allowedPrivileges.contains(element.privilegeName)).toList();
    return list;
  }
  List<OptifoodMenuItem> getUserMenu(){
    List<OptifoodMenuItem> list = [
      OptifoodMenuItem.clone(UserManagementMenu.MANAGER_MANAGEMENT),
      OptifoodMenuItem.clone(UserManagementMenu.DELIVERY_BOY_MANAGEMENT),
      OptifoodMenuItem.clone(UserManagementMenu.WAITER_MANAGEMENT),
    ];
    list=list.where((element) => widget.allowedPrivileges.contains(element.privilegeName)).toList();
    return list;
  }
  List<OptifoodMenuItem> getOptiFoodManagementMenu(){
    List<OptifoodMenuItem> list = [
      OptifoodMenuItem.clone(OptifoodManagementMenus.TAKE_AWAY_MODE),
      OptifoodMenuItem.clone(OptifoodManagementMenus.EAT_IN_MODE),
      OptifoodMenuItem.clone(OptifoodManagementMenus.TABLE_MANAGEMENT),
      OptifoodMenuItem.clone(OptifoodManagementMenus.DELIVERY_MODE),
      //OptifoodMenuItem.clone(OptifoodManagementMenus.DELIVERY_FEE),
      //OptifoodMenuItem.clone(OptifoodManagementMenus.NIGHT_MODE)
    ];
    list=list.where((element) => widget.allowedPrivileges.contains(element.privilegeName)).toList();
    return list;
  }




  populateServiceActivation() async{
    Future<List<ServiceActivationModel>> serviceActivationList = ServiceActivationDao().getAllServiceActivation();
    serviceActivationList.then((value) async{
      if(value.length>0){
        setState(() async {
          widget.serviceActivationModel = value[0];
        });
      }
      else {
        setState(() async{
          widget.serviceActivationModel = await ServiceActivationDao()
              .insertServiceActivation(ServiceActivationModel(1, true, true, false, true, true));
        });

      }
    });
  }

  checkIfAtleastOneActivated(String serviceType){
    if(widget.serviceActivationModel!.takeawayMode && serviceType!="takeawayMode")
      return true;
    else if(widget.serviceActivationModel!.eatInMode && serviceType!="eatInMode")
      return true;
    else if(widget.serviceActivationModel!.deliveryMode && serviceType!="deliveryMode")
      return true;
    else
      return false;
  }

  updateServiceActivation(String serviceType, bool value) async{

    if(serviceType=="takeawayMode") {
      if(widget.serviceActivationModel?.deliveryMode == false && widget.serviceActivationModel?.eatInMode == false && value==false)
        return;
      // if(value==false && !checkIfAtleastOneActivated(serviceType)){
      //   setState((){
      //     widget.serviceActivationModel?.takeawayMode=true;
      //   });
      //   return;
      // }
      widget.serviceActivationModel?.takeawayMode = value;
    }
    else if(serviceType=="eatInMode") {
      if(widget.serviceActivationModel?.takeawayMode==false && widget.serviceActivationModel?.deliveryMode == false && value == false){
        widget.serviceActivationModel?.takeawayMode=true;
      }
      // if(value==false){
      //   setState((){
      //     widget.serviceActivationModel?.eatInMode=true;
      //
      //   });
      //   return;
      // }
      if(value==false){
        setState((){
          widget.serviceActivationModel?.tableManagement=false;
        });
      }
      widget.serviceActivationModel?.eatInMode = value;
    }
    else if(serviceType=="tableManagement") {
      if(value==true && widget.serviceActivationModel?.eatInMode==false) {
        setState((){
          widget.serviceActivationModel?.tableManagement=false;
        });
        return;
      }
        widget.serviceActivationModel?.tableManagement = value;
    }
    else if(serviceType=="deliveryMode") {
      if(widget.serviceActivationModel?.takeawayMode==false&&widget.serviceActivationModel?.eatInMode==false && value==false){
        widget.serviceActivationModel?.takeawayMode=true;
      }
      // if(value==false){
      //   setState((){
      //     widget.serviceActivationModel?.deliveryMode=true;
      //   });
      //   return;
      // }
      widget.serviceActivationModel?.deliveryMode = value;
    }
    if(widget.serviceActivationModel?.takeawayMode==false&&widget.serviceActivationModel?.deliveryMode==false&&widget.serviceActivationModel?.eatInMode==false){
      setState((){
        widget.serviceActivationModel?.takeawayMode==true;
      });
    }
      await ServiceActivationDao()
          .updateServiceActivation(widget.serviceActivationModel!).then((response){
          setState((){
            if(value==false && serviceType=="'eatInMode") {
              updateServiceActivation("tableManagement", false);
              widget.serviceActivationModel!.tableManagement=false;
            }
            populateServiceActivation();
        });
      });
  }

  populatAllowedSubCategories(){
    String? userType=optifoodSharedPrefrence.getString('userType');
    if(userType!=null && userType=="Admin"){
      setState(() {
        widget.allowedPrivileges= Privileges.adminPrivileges;
      });
    }
    else if(userType!=null && userType=="user_role_manager"){
      setState(() {
        widget.allowedPrivileges=  Privileges.managerPrivileges;
      });
    }
  }
}
class ManagementMenu{
  static OptifoodMenuItem RESTAURANT_MENU = OptifoodMenuItem("1.1","restaurantMenu" , SvgPicture.asset("assets/svg/icons/settings/restaurant-menu.svg", height: 30,color: AppTheme.colorRed,), privilegeName: 'restaurantMenu');
  static OptifoodMenuItem CUSTOMER_MANAGEMENT = OptifoodMenuItem("1.2","customerManagement" , SvgPicture.asset("assets/svg/icons/settings/client.svg", height: 30,color: AppTheme.colorRed,), privilegeName: 'customerManagement');
  static OptifoodMenuItem USER_MANAGEMENT = OptifoodMenuItem("1.3","userManagement" , SvgPicture.asset("assets/svg/icons/settings/add-user.svg", height: 30,color: AppTheme.colorRed,), privilegeName: 'userManagement');
  static OptifoodMenuItem MESSAGE_MAMAGEMENT = OptifoodMenuItem("1.4","messageManagement" , SvgPicture.asset(AppImages.messageIcon, height: 30, color: AppTheme.colorRed,), privilegeName: 'messageManagement');
  static OptifoodMenuItem OPTIFOOD_MANAGEMENT = OptifoodMenuItem("1.5","optifoodManagement" , SvgPicture.asset("assets/svg/icons/settings/app-management.svg", height: 30,color: AppTheme.colorRed,), privilegeName: 'optifoodManagement');
  static OptifoodMenuItem API_INTEGRATION = OptifoodMenuItem("1.6","aPIIntegration" , SvgPicture.asset("assets/svg/icons/settings/api.svg", height: 30,color: AppTheme.colorRed,), privilegeName: 'aPIIntegration');

}
//ManagementMenu Tree
  //Restaurant menu tree
  class RestaurantMenu{
    static OptifoodMenuItem FOOD_MENU_MANAGEMENT = OptifoodMenuItem("1.1.1","menuManagement" , SvgPicture.asset("assets/svg/icons/settings/restaurant-menu.svg", height: 30,color: AppTheme.colorRed,), privilegeName: 'menuManagement' );
    static OptifoodMenuItem PRODUCT_MANAGEMENT = OptifoodMenuItem("1.1.2","productManagement" , SvgPicture.asset("assets/svg/icons/settings/product.svg", height: 30,color: AppTheme.colorRed,), privilegeName: 'productManagement');
    static OptifoodMenuItem PRODUCT_ATTRIBUTES = OptifoodMenuItem("1.1.3","productAttributes" , SvgPicture.asset("assets/svg/icons/settings/attributes.svg", height: 30,color: AppTheme.colorRed,), privilegeName: 'productAttributes');
  }
  //CustomerManagementmenu Tree
  class CustomerManagementMenu {
    static OptifoodMenuItem CUSTOMER_MANAGEMENT = OptifoodMenuItem("1.2.1","customerManagement" , SvgPicture.asset("assets/svg/icons/settings/client.svg", height: 30,color: AppTheme.colorRed,), privilegeName: 'customerManagement');
    static OptifoodMenuItem COMPANY_MANAGEMENT = OptifoodMenuItem("1.2.2","companyManagement" , SvgPicture.asset("assets/svg/icons/form_icons/company.svg", height: 30,color: AppTheme.colorRed,), privilegeName: 'companyManagement');
  }
  //UserManagement Tree
  class UserManagementMenu{
    static OptifoodMenuItem MANAGER_MANAGEMENT = OptifoodMenuItem("1.3.1", "managerManagement", SvgPicture.asset(AppImages.managerIcon, height: 30,color: AppTheme.colorRed,), privilegeName: 'managerManagement');
    static OptifoodMenuItem DELIVERY_BOY_MANAGEMENT = OptifoodMenuItem("1.3.2", "deliveryBoyManagement", SvgPicture.asset("assets/svg/icons/settings/delivery_boy.svg", height: 30,color: AppTheme.colorRed,), privilegeName: 'deliveryBoyManagement');
    static OptifoodMenuItem WAITER_MANAGEMENT = OptifoodMenuItem("1.3.3", "waiterManagement", SvgPicture.asset("assets/svg/icons/settings/waiter.svg", height: 30,color: AppTheme.colorRed,), privilegeName: 'waiterManagement');
  }

class OptifoodManagementMenus{
       static OptifoodMenuItem TAKE_AWAY_MODE =   OptifoodMenuItem("1.4.1", "takeawayMode", SvgPicture.asset("assets/images/icons/takeaway.svg", height: 30, color: AppTheme.colorRed,), isShowSwitch: true, isSwitchOn: true, privilegeName: 'takeawayMode');
       static OptifoodMenuItem EAT_IN_MODE =   OptifoodMenuItem("1.4.2", "eatInMode", SvgPicture.asset("assets/images/icons/dinner-table.svg", height: 30, color: AppTheme.colorRed,), isShowSwitch: true, isSwitchOn: true, privilegeName: 'eatInMode');
       static OptifoodMenuItem TABLE_MANAGEMENT = OptifoodMenuItem("1.4.3", "tableManagement", SvgPicture.asset("assets/images/icons/dinner-table.svg", height: 30, color: AppTheme.colorRed,), isShowSwitch: true, isSwitchOn: false, privilegeName: 'tableManagement');
       static OptifoodMenuItem DELIVERY_MODE = OptifoodMenuItem("1.4.4", "deliveryMode", SvgPicture.asset("assets/images/icons/delivery.svg", height: 30, color: AppTheme.colorRed), isShowSwitch: true, isSwitchOn: true, privilegeName: 'deliveryMode');
       static OptifoodMenuItem DELIVERY_FEE = OptifoodMenuItem("1.4.5", "deliveryFee", SvgPicture.asset("assets/images/icons/delivery.svg", height: 30, color: AppTheme.colorRed,), privilegeName: 'deliveryFee');
       static OptifoodMenuItem NIGHT_MODE = OptifoodMenuItem("1.4.6", "nightModeManagement", SvgPicture.asset("assets/images/icons/night-mode.svg", height: 30, color: AppTheme.colorRed,), privilegeName: 'nightModeManagement');
}

class MessageManagementMenu{
  static OptifoodMenuItem TAKE_AWAY_MODE =   OptifoodMenuItem("1.4.1", "'Takeaway' mode", SvgPicture.asset("assets/images/icons/takeaway.svg", height: 30, color: AppTheme.colorRed,), isShowSwitch: true, isSwitchOn: true, privilegeName: 'takeawayMode');

}






