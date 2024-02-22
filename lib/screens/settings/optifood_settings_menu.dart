import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:opti_food_app/assets/images.dart';
import 'package:opti_food_app/main.dart';
import 'package:opti_food_app/screens/authentication/user_profile.dart';
import 'package:opti_food_app/screens/settings/legal_notice.dart';
import 'package:opti_food_app/screens/settings/localization.dart';
import 'package:opti_food_app/screens/user/restaurant_info.dart';
import 'package:opti_food_app/utils/constants.dart';
import 'package:opti_food_app/utils/utility.dart';
import 'package:opti_food_app/widgets/appbar/app_bar_optifood.dart';
import 'package:opti_food_app/widgets/appbar/navigation_bar_optifood.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../widgets/app_theme.dart';
import '../../widgets/appbar/app_icon_model.dart';
import '../../widgets/custom_field_with_no_icon.dart';
import '../order/ordered_lists.dart';
import 'optifood_menu_item.dart';
import 'package:easy_localization/easy_localization.dart';
import '../MountedState.dart';
class OptifoodSettingsMenu extends StatefulWidget{

  String parentMenuId;
  OptifoodSettingsMenu({this.parentMenuId = "0"});
  TextEditingController numberOfTicketEditingController = TextEditingController();
  @override
  State<StatefulWidget> createState() => _OptifoodSettingsMenuState();
}
class _OptifoodSettingsMenuState extends MountedState<OptifoodSettingsMenu>{
  List<OptifoodMenuItem> activeMenuList = [];
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    List<OptifoodMenuItem> mainMenuList = [
      OptifoodMenuItem.clone(_MainMenu.NOTIFICATIONS).addSubMenuList(
        [
          OptifoodMenuItem("1.1.1","discussions" , SvgPicture.asset(AppImages.chat, height: 30,color: AppTheme.colorRed,),isShowSwitch: true, privilegeName: ''),
        ]
      ),
      OptifoodMenuItem.clone(_MainMenu.MY_ACCOUNT).addSubMenuList(
          [
            //OptifoodMenuItem("1.2.1","Change Password" , SvgPicture.asset("assets/svg/icons/form_icons/password.svg", height: 30,color: AppTheme.colorRed,)),
            OptifoodMenuItem("1.2.2","myProfile" , SvgPicture.asset("assets/svg/icons/settings/account.svg", height: 30,color: AppTheme.colorRed,),
                      onClick: (){
                          Navigator.of(context).push(MaterialPageRoute(builder: (context) => UserProfile()));
                      },
                privilegeName: ''),
            OptifoodMenuItem("1.2.3","restaurantInfo" , SvgPicture.asset(AppImages.restaurant, height: 30,color: AppTheme.colorRed,),onClick: (){
              Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) =>
                      RestaurantInfo()));
            }, privilegeName: ''),
            OptifoodMenuItem("1.2.4","licenseKey" , SvgPicture.asset(AppImages.license_key, height: 30,color: AppTheme.colorRed,), privilegeName: ''),

          ]
      ),
      OptifoodMenuItem.clone(_MainMenu.TERMS_AND_CONDITIONS).addSubMenuList(
        [
          OptifoodMenuItem("1.3.1","cguv" , SvgPicture.asset("assets/svg/icons/settings/terms-and-conditions.svg", height: 30,color: AppTheme.colorRed,),onClick: () async {
            await launch("https://e-comunik.fr/cguv-optifood/");
          }, privilegeName: ''),
          OptifoodMenuItem("1.3.2","legalNotice" , SvgPicture.asset("assets/svg/icons/settings/terms-and-conditions.svg", height: 30,color: AppTheme.colorRed,),onClick: (){
            Navigator.of(context).push(
                MaterialPageRoute(builder: (context) =>
                    LegalNotice()));
          }, privilegeName: ''),
          OptifoodMenuItem("1.3.3","privacyPolicy" , SvgPicture.asset("assets/svg/icons/settings/terms-and-conditions.svg", height: 30,color: AppTheme.colorRed,),onClick: () async {
            await launch("https://optifood.fr/politique-de-confidentialite");
          }, privilegeName: ''),
        ]
      ),
      OptifoodMenuItem.clone(_MainMenu.LOCALIZATION,onClick: (){
        Navigator.of(context).push(
            MaterialPageRoute(builder: (context) =>
                OptifoodLocalization()));
      }),
      OptifoodMenuItem.clone(_MainMenu.PRINTING,onClick: (){
        Navigator.of(context).push(
            MaterialPageRoute(builder: (context) =>
                OptifoodSettingsMenu(parentMenuId: "1.5")));
      }),
      //OptifoodMenuItem.clone(_MainMenu.CHECK_FOR_UPDATES), // COMMENTED FOR NOW
      //OptifoodMenuItem.clone(_MainMenu.TROUBLESHOOT), // COMMENTED FOR NOW
    ];
    if(widget.parentMenuId == "0"){
     activeMenuList = mainMenuList;
    }
    else if(widget.parentMenuId == _MainMenu.PRINTING.id){
      getPrintingData();
    }

    widget.numberOfTicketEditingController.text = optifoodSharedPrefrence.getInt(ConstantSharedPreferenceKeys.KEY_PRINTER_NUMBER_OF_TICKET)!=null?optifoodSharedPrefrence.getInt(ConstantSharedPreferenceKeys.KEY_PRINTER_NUMBER_OF_TICKET).toString():"1";

  }
  void getPrintingData(){
    //setState(() {
    checkForDefaultPrinterSettings();
    activeMenuList = [
      OptifoodMenuItem("1.5.1","printerOPTI-BT80I" , SvgPicture.asset("assets/svg/icons/settings/printing.svg", height: 30,color: AppTheme.colorRed,),isSwitchOn: optifoodSharedPrefrence.getBool(ConstantSharedPreferenceKeys.KEY_PRINTER_ACTIVATED)!=null?optifoodSharedPrefrence.getBool(ConstantSharedPreferenceKeys.KEY_PRINTER_ACTIVATED)!:false,isShowSwitch:true,
          onSwitchChangeCallback: (bool data) async {

            //if(data==false) {
            if(data==true) {
              //if (30 < androidApiVersion) {
                Map<Permission, PermissionStatus> statuses = await [Permission.bluetoothScan, Permission.bluetoothAdvertise, Permission.bluetoothConnect].request();

                if (statuses[Permission.bluetoothScan] == PermissionStatus.granted && statuses[Permission.bluetoothScan] == PermissionStatus.granted) {
                  // permission granted
                }
                else {
                  return;
                }
              //}
              String result = await channelPrinting.invokeMethod('selectPrinter');
              if(result!=null){
                await optifoodSharedPrefrence.setString(ConstantSharedPreferenceKeys.KEY_PRINTER_MAC_ADDRESS, result);
                await optifoodSharedPrefrence.setBool(ConstantSharedPreferenceKeys.KEY_PRINTER_ACTIVATED, data);
              }
              else{
                //Utility().showToastMessage("Cancelled");
              }
            }
            else {
              await optifoodSharedPrefrence.setBool(ConstantSharedPreferenceKeys.KEY_PRINTER_ACTIVATED, data);
              /* optifoodSharedPrefrence.setBool(ConstantSharedPreferenceKeys
                      .KEY_PRINTER_ACTIVATED_FOR_RESTAURANT, data);*/
              await optifoodSharedPrefrence.setBool(ConstantSharedPreferenceKeys
                  .KEY_PRINTER_ACTIVATED_FOR_EAT_IN, data);
              await optifoodSharedPrefrence.setBool(ConstantSharedPreferenceKeys
                  .KEY_PRINTER_ACTIVATED_FOR_TAKE_AWAY, data);
              await optifoodSharedPrefrence.setBool(ConstantSharedPreferenceKeys
                  .KEY_PRINTER_ACTIVATED_FOR_DELIVERY, data);
              await optifoodSharedPrefrence.setBool(ConstantSharedPreferenceKeys
                  .KEY_PRINTER_ACTIVATED_PRINCIPAL_TICKET, data);
              await optifoodSharedPrefrence.setBool(ConstantSharedPreferenceKeys
                  .KEY_PRINTER_ACTIVATED_ORDER_NUMBER, data);
              //getPrintingData();
            }
            setState((){
              getPrintingData();
            });
      }, privilegeName: ''),
      /*OptifoodMenuItem("1.5.2","activateForRestaurant" ,
          SvgPicture.asset("assets/svg/icons/settings/printing.svg", height: 30,color: optifoodSharedPrefrence.getBool(ConstantSharedPreferenceKeys.KEY_PRINTER_ACTIVATED)!=null&&optifoodSharedPrefrence.getBool(ConstantSharedPreferenceKeys.KEY_PRINTER_ACTIVATED)==true?AppTheme.colorRed:AppTheme.colorGrey,),
          isShowSwitch:true,isSwitchOn: optifoodSharedPrefrence.getBool(ConstantSharedPreferenceKeys.KEY_PRINTER_ACTIVATED_FOR_RESTAURANT)!=null?optifoodSharedPrefrence.getBool(ConstantSharedPreferenceKeys.KEY_PRINTER_ACTIVATED_FOR_RESTAURANT)!:false,
          isEnabled: optifoodSharedPrefrence.getBool(ConstantSharedPreferenceKeys.KEY_PRINTER_ACTIVATED)!=null?optifoodSharedPrefrence.getBool(ConstantSharedPreferenceKeys.KEY_PRINTER_ACTIVATED)!:false,
          onSwitchChangeCallback: (bool data){
            optifoodSharedPrefrence.setBool(ConstantSharedPreferenceKeys.KEY_PRINTER_ACTIVATED_FOR_RESTAURANT, data);
          }, privilegeName: ''),*/

      OptifoodMenuItem("1.5.2","activateForTakeAway" ,
          SvgPicture.asset("assets/svg/icons/settings/printing.svg", height: 30,color: optifoodSharedPrefrence.getBool(ConstantSharedPreferenceKeys.KEY_PRINTER_ACTIVATED)!=null&&optifoodSharedPrefrence.getBool(ConstantSharedPreferenceKeys.KEY_PRINTER_ACTIVATED)==true?AppTheme.colorRed:AppTheme.colorGrey,),
          isShowSwitch:true,isSwitchOn: optifoodSharedPrefrence.getBool(ConstantSharedPreferenceKeys.KEY_PRINTER_ACTIVATED_FOR_TAKE_AWAY)!=null?optifoodSharedPrefrence.getBool(ConstantSharedPreferenceKeys.KEY_PRINTER_ACTIVATED_FOR_TAKE_AWAY)!:false,
          isEnabled: optifoodSharedPrefrence.getBool(ConstantSharedPreferenceKeys.KEY_PRINTER_ACTIVATED)!=null?optifoodSharedPrefrence.getBool(ConstantSharedPreferenceKeys.KEY_PRINTER_ACTIVATED)!:false,
          onSwitchChangeCallback: (bool data) async {
            await optifoodSharedPrefrence.setBool(ConstantSharedPreferenceKeys.KEY_PRINTER_ACTIVATED_FOR_TAKE_AWAY, data);
            //checkForDefaultPrinterSettings();
            setState((){
              getPrintingData();
            });
          }, privilegeName: ''),
      OptifoodMenuItem("1.5.3","activateForEatIn" ,
          SvgPicture.asset("assets/svg/icons/settings/printing.svg", height: 30,color: optifoodSharedPrefrence.getBool(ConstantSharedPreferenceKeys.KEY_PRINTER_ACTIVATED)!=null&&optifoodSharedPrefrence.getBool(ConstantSharedPreferenceKeys.KEY_PRINTER_ACTIVATED)==true?AppTheme.colorRed:AppTheme.colorGrey,),
          isShowSwitch:true,isSwitchOn: optifoodSharedPrefrence.getBool(ConstantSharedPreferenceKeys.KEY_PRINTER_ACTIVATED_FOR_EAT_IN)!=null?optifoodSharedPrefrence.getBool(ConstantSharedPreferenceKeys.KEY_PRINTER_ACTIVATED_FOR_EAT_IN)!:false,
          isEnabled: optifoodSharedPrefrence.getBool(ConstantSharedPreferenceKeys.KEY_PRINTER_ACTIVATED)!=null?optifoodSharedPrefrence.getBool(ConstantSharedPreferenceKeys.KEY_PRINTER_ACTIVATED)!:false,
          onSwitchChangeCallback: (bool data) async {
            await optifoodSharedPrefrence.setBool(ConstantSharedPreferenceKeys.KEY_PRINTER_ACTIVATED_FOR_EAT_IN, data);
            setState((){
              getPrintingData();
            });
          }, privilegeName: ''),
      OptifoodMenuItem("1.5.4","activateForDelivery" ,
          SvgPicture.asset("assets/svg/icons/settings/printing.svg", height: 30,color: optifoodSharedPrefrence.getBool(ConstantSharedPreferenceKeys.KEY_PRINTER_ACTIVATED)!=null&&optifoodSharedPrefrence.getBool(ConstantSharedPreferenceKeys.KEY_PRINTER_ACTIVATED)==true?AppTheme.colorRed:AppTheme.colorGrey,),
          isShowSwitch:true,isSwitchOn: optifoodSharedPrefrence.getBool(ConstantSharedPreferenceKeys.KEY_PRINTER_ACTIVATED_FOR_DELIVERY)!=null?optifoodSharedPrefrence.getBool(ConstantSharedPreferenceKeys.KEY_PRINTER_ACTIVATED_FOR_DELIVERY)!:false,
          isEnabled: optifoodSharedPrefrence.getBool(ConstantSharedPreferenceKeys.KEY_PRINTER_ACTIVATED)!=null?optifoodSharedPrefrence.getBool(ConstantSharedPreferenceKeys.KEY_PRINTER_ACTIVATED)!:false,
          onSwitchChangeCallback: (bool data) async {
            await optifoodSharedPrefrence.setBool(ConstantSharedPreferenceKeys.KEY_PRINTER_ACTIVATED_FOR_DELIVERY, data);
            setState((){
              getPrintingData();
            });
          }, privilegeName: ''),
      OptifoodMenuItem("1.5.5","principalTicket" ,
          SvgPicture.asset("assets/svg/icons/settings/printing.svg", height: 30,color: optifoodSharedPrefrence.getBool(ConstantSharedPreferenceKeys.KEY_PRINTER_ACTIVATED)!=null&&optifoodSharedPrefrence.getBool(ConstantSharedPreferenceKeys.KEY_PRINTER_ACTIVATED)==true?AppTheme.colorRed:AppTheme.colorGrey,),
          isShowSwitch:true,isSwitchOn: optifoodSharedPrefrence.getBool(ConstantSharedPreferenceKeys.KEY_PRINTER_ACTIVATED_PRINCIPAL_TICKET)!=null?optifoodSharedPrefrence.getBool(ConstantSharedPreferenceKeys.KEY_PRINTER_ACTIVATED_PRINCIPAL_TICKET)!:false,
          isEnabled: optifoodSharedPrefrence.getBool(ConstantSharedPreferenceKeys.KEY_PRINTER_ACTIVATED)!=null?optifoodSharedPrefrence.getBool(ConstantSharedPreferenceKeys.KEY_PRINTER_ACTIVATED)!:false,
          onSwitchChangeCallback: (bool data) async {
            await optifoodSharedPrefrence.setBool(ConstantSharedPreferenceKeys.KEY_PRINTER_ACTIVATED_PRINCIPAL_TICKET, data);
            setState((){
              getPrintingData();
            });
          }, privilegeName: ''),
      OptifoodMenuItem("1.5.6","orderNumberTicket" ,
          SvgPicture.asset("assets/svg/icons/settings/printing.svg", height: 30,color: optifoodSharedPrefrence.getBool(ConstantSharedPreferenceKeys.KEY_PRINTER_ACTIVATED)!=null&&optifoodSharedPrefrence.getBool(ConstantSharedPreferenceKeys.KEY_PRINTER_ACTIVATED)==true?AppTheme.colorRed:AppTheme.colorGrey,),
          isShowSwitch:true,isSwitchOn: optifoodSharedPrefrence.getBool(ConstantSharedPreferenceKeys.KEY_PRINTER_ACTIVATED_ORDER_NUMBER)!=null?optifoodSharedPrefrence.getBool(ConstantSharedPreferenceKeys.KEY_PRINTER_ACTIVATED_ORDER_NUMBER)!:false,
          isEnabled: optifoodSharedPrefrence.getBool(ConstantSharedPreferenceKeys.KEY_PRINTER_ACTIVATED)!=null?optifoodSharedPrefrence.getBool(ConstantSharedPreferenceKeys.KEY_PRINTER_ACTIVATED)!:false,
          onSwitchChangeCallback: (bool data) async {
            await optifoodSharedPrefrence.setBool(ConstantSharedPreferenceKeys.KEY_PRINTER_ACTIVATED_ORDER_NUMBER, data);
            setState((){
              getPrintingData();
            });
          }, privilegeName: ''),
      OptifoodMenuItem("1.5.7","numberOfTicket" ,
          SvgPicture.asset("assets/svg/icons/settings/printing.svg", height: 30,color: optifoodSharedPrefrence.getBool(ConstantSharedPreferenceKeys.KEY_PRINTER_ACTIVATED)!=null&&optifoodSharedPrefrence.getBool(ConstantSharedPreferenceKeys.KEY_PRINTER_ACTIVATED)==true?AppTheme.colorRed:AppTheme.colorGrey,),
          isShowTextField: true,textFieldController: widget.numberOfTicketEditingController,
          isEnabled: optifoodSharedPrefrence.getBool(ConstantSharedPreferenceKeys.KEY_PRINTER_ACTIVATED)!=null?optifoodSharedPrefrence.getBool(ConstantSharedPreferenceKeys.KEY_PRINTER_ACTIVATED)!:false,
          textFieldCallback: (String data){

            optifoodSharedPrefrence.setInt(ConstantSharedPreferenceKeys.KEY_PRINTER_NUMBER_OF_TICKET, int.parse(data));
            setState((){
              getPrintingData();
            });
          }, privilegeName: ''),
    ];
   // });
  }
  void checkForDefaultPrinterSettings(){
    if(optifoodSharedPrefrence.getBool(ConstantSharedPreferenceKeys.KEY_PRINTER_ACTIVATED)!=null && optifoodSharedPrefrence.getBool(ConstantSharedPreferenceKeys.KEY_PRINTER_ACTIVATED)!){
      if((optifoodSharedPrefrence.getBool(ConstantSharedPreferenceKeys.KEY_PRINTER_ACTIVATED_PRINCIPAL_TICKET)==null||optifoodSharedPrefrence.getBool(ConstantSharedPreferenceKeys.KEY_PRINTER_ACTIVATED_PRINCIPAL_TICKET)==false) &&
          (optifoodSharedPrefrence.getBool(ConstantSharedPreferenceKeys.KEY_PRINTER_ACTIVATED_ORDER_NUMBER)==null||optifoodSharedPrefrence.getBool(ConstantSharedPreferenceKeys.KEY_PRINTER_ACTIVATED_ORDER_NUMBER)==false)
      ){
        setState((){
          optifoodSharedPrefrence.setBool(ConstantSharedPreferenceKeys.KEY_PRINTER_ACTIVATED_PRINCIPAL_TICKET, true);
        });
      }

      if((optifoodSharedPrefrence.getBool(ConstantSharedPreferenceKeys.KEY_PRINTER_ACTIVATED_FOR_DELIVERY)==null||optifoodSharedPrefrence.getBool(ConstantSharedPreferenceKeys.KEY_PRINTER_ACTIVATED_FOR_DELIVERY)==false) &&
          (optifoodSharedPrefrence.getBool(ConstantSharedPreferenceKeys.KEY_PRINTER_ACTIVATED_FOR_EAT_IN)==null||optifoodSharedPrefrence.getBool(ConstantSharedPreferenceKeys.KEY_PRINTER_ACTIVATED_FOR_EAT_IN)==false) &&
          (optifoodSharedPrefrence.getBool(ConstantSharedPreferenceKeys.KEY_PRINTER_ACTIVATED_FOR_TAKE_AWAY)==null||optifoodSharedPrefrence.getBool(ConstantSharedPreferenceKeys.KEY_PRINTER_ACTIVATED_FOR_TAKE_AWAY)==false)
      ){
        setState((){
          optifoodSharedPrefrence.setBool(ConstantSharedPreferenceKeys.KEY_PRINTER_ACTIVATED_FOR_TAKE_AWAY, true);
        });
      }
    }
  }
  @override
  Widget build(BuildContext context) {
    /*PreferredSizeWidget appBarWidget = AppBarOptifood();
    if(widget.parentMenuId=="0"){
      appBarWidget = NavigationBarOptifood();
    }*/
    PreferredSizeWidget appBarWidget = AppBarOptifood();
    if(widget.parentMenuId!="0"){
      appBarWidget = AppBarOptifood(appIconList: [
        AppIconModel(svgPicture: SvgPicture.asset(AppImages.phoneWithHandIcon,
        //AppIconModel(svgPicture: SvgPicture.asset("assets/images/icons/phone-with-hand.svg",
          //height: 40, color: AppTheme.colorRed,), onTap: (){
          height: 30, color: AppTheme.colorRed,), onTap: (){
          Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context)=>OrderedList()));
        })
      ],);
    }
    return Scaffold(
      //appBar: widget.parentMenu==null?NavigationBarOptifood():AppBarOptifood(),
      appBar: appBarWidget,
      body: Container(
        //child: ListView.separated(
        child: ListView.builder(
          padding: EdgeInsets.only(top: 5),
          //itemCount: widget.activeMenuList.length,
          itemCount: activeMenuList.length,
          //separatorBuilder: (context,index) => Divider(),
          itemBuilder: (context,index){
            if(activeMenuList[index].subMenuList.length>0){
              return ExpansionTile(
                //title: Text("Testing title"),
                leading: activeMenuList[index].icon,
                title: Text(activeMenuList[index].text.tr(),style: TextStyle(color: AppTheme.colorDarkGrey),),
                children:
                  List.generate(activeMenuList[index].subMenuList.length, (sub_index){
                    OptifoodMenuItem element = activeMenuList[index].subMenuList[sub_index];
                    return
                      Padding(padding: EdgeInsets.only(left: 20),
                        child: getDataListTile(element,index),
                      );

                  }),
              );
            }
            else{
              return getDataListTile(activeMenuList[index], index);
            }

            /*return ListTile(
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
                          ContactList(contactListItemClickable: false,showOptionMenu: true,)));
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
                else {
                  Navigator.of(context).push(
                      MaterialPageRoute(builder: (context) =>
                          OptifoodManagementMenu(parentMenu: widget.activeMenuList[index])));
                }
              },
              leading: widget.activeMenuList[index].icon,
              title: Text(widget.activeMenuList[index].text,style: TextStyle(color: AppTheme.colorDarkGrey),),
            );*/
          },
        ),
      ),
    );
  }
  Widget getDataListTile(OptifoodMenuItem element, index){
    return
      GestureDetector(
        onTap: (){
          element.onClick!();
        },
        child: ListTile(
          leading: element.icon,
          title: element.text=="cguv"?Text(element.text.tr().toUpperCase(),style: TextStyle(color: element.isEnabled?AppTheme.colorDarkGrey:AppTheme.colorGrey),):Text(element.text.tr(),style: TextStyle(color: element.isEnabled?AppTheme.colorDarkGrey:AppTheme.colorGrey),),
          trailing: element.isShowSwitch==true?
          Switch(
              activeColor: AppTheme.colorRed,
              value: element.isSwitchOn,
              onChanged: (data) async{
                if(element.isEnabled) {
                  if (element.onSwitchChangeCallback != null) {
                    element.onSwitchChangeCallback!(data);
                  }
                  /*setState(() {
                    element.isSwitchOn = data;
                  });*/
                }
          }):
              element.isShowTextField==true?
                  Container(
                    margin: EdgeInsets.only(right: 10),
                    width: 60,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                        color: Colors.white,
                      ),
                    child: TextField(
                      textAlign: TextAlign.center,
                      keyboardType: TextInputType.number,
                      controller: element.textFieldController,
                      readOnly: !element.isEnabled,
                      decoration: InputDecoration(
                          contentPadding:
                          EdgeInsets.only(left: 10,right: 10),
                          border: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          errorBorder: InputBorder.none,
                          disabledBorder: InputBorder.none,
                      ),
                      onSubmitted: (String data){
                        element.textFieldCallback!(data);
                      },
                    )
                  ) :null
        )
      );
  }
}

class _MainMenu{
  static OptifoodMenuItem NOTIFICATIONS = OptifoodMenuItem("1.1","notifications" , SvgPicture.asset("assets/svg/icons/settings/notification.svg", height: 30,color: AppTheme.colorRed,), privilegeName: '');
  static OptifoodMenuItem MY_ACCOUNT = OptifoodMenuItem("1.2","myAccount" , SvgPicture.asset("assets/svg/icons/settings/account.svg", height: 30,color: AppTheme.colorRed,), privilegeName: '');
  static OptifoodMenuItem TERMS_AND_CONDITIONS = OptifoodMenuItem("1.3","termsAndConditions" , SvgPicture.asset("assets/svg/icons/settings/terms-and-conditions.svg", height: 30,color: AppTheme.colorRed,), privilegeName: '');
  static OptifoodMenuItem LOCALIZATION = OptifoodMenuItem("1.4","localization" , SvgPicture.asset("assets/svg/icons/settings/language.svg", height: 30,color: AppTheme.colorRed,), privilegeName: '');
  static OptifoodMenuItem PRINTING = OptifoodMenuItem("1.5","printing" , SvgPicture.asset("assets/svg/icons/settings/printing.svg", height: 30,color: AppTheme.colorRed,), privilegeName: '');
  static OptifoodMenuItem CHECK_FOR_UPDATES = OptifoodMenuItem("1.6","checkForUpdates" , SvgPicture.asset("assets/svg/icons/settings/check-update.svg", height: 30,color: AppTheme.colorRed,), privilegeName: '');
  static OptifoodMenuItem MANAGE_LICENSE_KEY = OptifoodMenuItem("1.7","licenseKey" , SvgPicture.asset(AppImages.license_key, height: 30,color: AppTheme.colorRed,), privilegeName: '');
  static OptifoodMenuItem TROUBLESHOOT = OptifoodMenuItem("1.8","troubleshoot" , SvgPicture.asset("assets/svg/icons/settings/troubleshoot.svg", height: 30,color: AppTheme.colorRed,), privilegeName: '');
}
