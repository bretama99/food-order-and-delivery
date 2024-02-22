import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:geolocator/geolocator.dart';
import 'package:opti_food_app/api/food_item_api.dart';
import 'package:opti_food_app/api/login_api.dart';
import 'package:opti_food_app/screens/authentication/envoyer.dart';
import 'package:opti_food_app/screens/authentication/login.dart';
import 'package:opti_food_app/screens/order/order_archive.dart';
import 'package:opti_food_app/screens/order/ordered_lists.dart';
import 'package:opti_food_app/screens/reservation/reservation_list.dart';
import 'package:opti_food_app/screens/message/message_conversation.dart';
import 'package:opti_food_app/screens/settings/optifood_management_menu.dart';
import 'package:opti_food_app/screens/settings/optifood_settings_menu.dart';
//import 'package:opti_food_app/screens/report/report.dart';
import 'package:opti_food_app/screens/splash_screen.dart';
import 'package:opti_food_app/utils/utility.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../api/all_data_api.dart';
import '../../api/customer_api.dart';
import '../../api/food_category_api.dart';
import '../../api/order_apis.dart';
import '../../api/restaurant.dart';
import '../../assets/images.dart';
import '../../data_models/order_model.dart';
import '../../data_models/reservation_model.dart';
import '../../database/order_dao.dart';
import '../../database/reservation_dao.dart';
import '../../local_notifications.dart';
import '../../main.dart';
import '../../screens/MountedState.dart';
import '../../screens/chat/user_channel_list.dart';
import '../../screens/map_optimization/delivery_boy_path_optimization.dart';
import '../../screens/map_optimization/google_map.dart';
import '../../screens/message/chat.dart';
import '../../screens/order/order_delay.dart';
//import '../../screens/report/interval_report.dart';
//import '../../screens/report/report.dart';
import '../../screens/report/report.dart';
import '../../utils/app_config.dart';
import '../../utils/constants.dart';
import '../app_theme.dart';
import 'app_icon_model.dart';

class NavigationBarOptifood extends StatefulWidget implements PreferredSizeWidget
{
  Function? onRefrontCallback;
  NavigationBarOptifood({this.onRefrontCallback});
  @override
  State<StatefulWidget> createState() => _NavigationBarOptifoodState();

  @override
  Size get preferredSize => Size.fromHeight(60);

}

class _NavigationBarOptifoodState extends MountedState<NavigationBarOptifood>
{
  String versionName = "xxx";
  var allowedPrivileges=[];
  List<OrderModel> delayedOrders = [];
  List<ReservationModel> reservationList = [];
  @override
  void initState() {
    populatePrivileges();
    PackageInfo.fromPlatform().then((PackageInfo packageInfo) {
      String appName = packageInfo.appName;
      String packageName = packageInfo.packageName;
      String version = packageInfo.version;
      String buildNumber = packageInfo.buildNumber;
      setState((){
        versionName = "Version "+version;      });
    });
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    OrderDao().getDelayedOrders().then((value){
      setState((){
        delayedOrders = value;
        print("Delayed orders length : "+delayedOrders.length.toString());
      });
    });
    ReservationDao().getReservationList(DateFormat("dd/MM/yyyy").format(DateTime.now())).then((value){
      setState((){
        print("============1st===reservationListreservationList=========${reservationList.length}====================================");

        reservationList = value.where((element) => element.status!='arrived').toList();
        print("========2nd=======reservationListreservationList=========${reservationList.length}====================================");
      });
    });
  }

  @override
  void didUpdateWidget(covariant NavigationBarOptifood oldWidget) {
    // TODO: implement didUpdateWidget
    super.didUpdateWidget(oldWidget);
    OrderDao().getDelayedOrders().then((value){
      setState((){
        delayedOrders = value;
        print("Delayed orders length : "+delayedOrders.length.toString());
      });
    });
    ReservationDao().getReservationList(DateFormat("dd/MM/yyyy").format(DateTime.now())).then((value){
      setState((){
        reservationList = value.where((element) => element.status!='arrived').toList();
      });
    });
  }

  @override
  void dispose(){
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
  }

  logout(){
    LoginApi().logoutApi(callback: (){
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => LoginPage()));
      });
  }



  @override
  Widget build(BuildContext context) {

    return  AppBar(
      automaticallyImplyLeading: false,
      elevation: 0,
      titleSpacing: 0,
      backgroundColor: AppTheme.colorLightGrey,
      title: Container(
        child: Card(
          color: Colors.white,
          surfaceTintColor: Colors.transparent,
          child: ListTile(
            minVerticalPadding: 0,
            horizontalTitleGap: 0,
            contentPadding: EdgeInsets.all(0),
            dense: true,
            leading:
            Container(
                padding: EdgeInsets.only(left: 12,right: 12,top: 5,bottom: 5),
                decoration: const BoxDecoration(
                  border: Border(right: BorderSide(color: AppTheme.colorLightGrey)),

                ),
                child: InkWell(
                    onTap: ()
                    {
                      /*Timer(const Duration(milliseconds: 0), () {
                      setState(() {
                        showDialog(context: context,
                            builder: (BuildContext context) {
                              return SimpleCustomAlert(
                                  "Simple Custom Alert");
                            });
                      });
                    });*/
                      showGeneralDialog(context: context,
                          barrierLabel: "label".tr(),
                          barrierDismissible: true,
                          transitionDuration: Duration(milliseconds: 350),
                          transitionBuilder: (context,anim1,anim2,child){
                            return SlideTransition(
                              position:
                              //Tween(begin: Offset(0, 1),end: Offset(0,0),
                              Tween(begin: Offset(0, -1),end: Offset(0,0),
                              ).animate(anim1),
                              child: child,
                            );
                          },
                          pageBuilder: (context,anim1,anim2){
                            /*return Dismissible(key: Key("test"),
                          direction: DismissDirection.vertical,
                          onDismissed: (_) {
                            Navigator.of(context).pop();
                          },
                          child: getMenu());*/
                            return getMenu();
                          });
                    },
                    child: SvgPicture.asset(
                      AppImages.menuIcon, height: 40,
                      color: AppTheme.colorRed,))
            ),

            title: Container(
              child: Row(
                children: [
                  Container(
                    //height: 100,

                      padding: EdgeInsets.only(left: 12,right: 12,top: 5,bottom: 5),
                      decoration: const BoxDecoration(
                        border: Border(right: BorderSide(color: AppTheme.colorLightGrey)),

                      ),
                      child: InkWell(
                          onTap: ()
                          {
                            /*Navigator.of(context).push(MaterialPageRoute(
                                builder: (context) => GoogleMapOptifood()));*/
                            Utility().showToastMessage("Coming Soon...");
                          },
                          child: SvgPicture.asset(
                            AppImages.mapsRedIcon, height: 40,
                            color: AppTheme.colorRed,))
                  ),

                  Container(
                    //height: 100,

                      padding: EdgeInsets.only(left: 12,right: 12,top: 5,bottom: 5),
                      decoration: const BoxDecoration(
                        border: Border(right: BorderSide(color: AppTheme.colorLightGrey)),

                      ),
                      child: InkWell(
                          onTap: ()
                          {
                            /*Navigator.of(context).push(
                                MaterialPageRoute(builder: (context) =>
                                    DeliveryBoyPathOptimization())
                            );*/
                            Utility().showToastMessage("Coming Soon...");
                          },
                          child: SvgPicture.asset(
                            AppImages.optimisationIcon, height: 40,
                            color: AppTheme.colorRed,))
                  ),
                  if( delayedOrders.length>0) ...[
                    Container(
                      //height: 100,

                        padding: EdgeInsets.only(left: 12,right: 12,top: 5,bottom: 5),
                        decoration: const BoxDecoration(
                          border: Border(right: BorderSide(color: AppTheme.colorLightGrey)),

                        ),
                        child: InkWell(
                            onTap: ()
                            {
                              Navigator.of(context).push(
                                  MaterialPageRoute(builder: (context) =>
                                      OrderDelay())
                              );
                            },
                            child: Container(
                              child: Stack(
                                children: [
                                  Positioned.fill(
                                      child: Align(
                                        alignment: Alignment.bottomLeft,
                                        child:Container(
                                          margin: EdgeInsets.only(bottom: 5),
                                          child: SvgPicture.asset(
                                            //AppImages.delayedOrder, height: 40,
                                            AppImages.delayedOrder, height: 35,
                                            color: AppTheme.colorRed,),
                                        )

                                      ),
                                  ),
                                  Positioned(
                                      child:Align(
                                          alignment: Alignment.center,
                                          child: Container(
                                              //margin: EdgeInsets.only(bottom: 70,left: 35),
                                              margin: EdgeInsets.only(bottom: 20,left: 20),
                                              height: 25,
                                              width: 25,
                                              decoration: BoxDecoration(
                                                  color: AppTheme.colorDarkGrey,
                                                  //borderRadius: BorderRadius.circular(30)
                                                  borderRadius: BorderRadius.circular(20)
                                              ),
                                              child:
                                              Center(
                                                child: Text(delayedOrders.length.toString(),style: TextStyle(color: Colors.white,fontSize: 12,fontWeight: FontWeight.bold),),
                                              )
                                          )
                                      )
                                  )
                                ],
                              ),
                            )
                            /*child: SvgPicture.asset(
                              AppImages.delayedOrder, height: 40,
                              color: AppTheme.colorRed,))*/
                        )
                    ),
                  ],
                  if( reservationList.length>0) ...[
                    Container(
                      //height: 100,

                        padding: EdgeInsets.only(left: 12,right: 12,top: 5,bottom: 5),
                        decoration: const BoxDecoration(
                          border: Border(right: BorderSide(color: AppTheme.colorLightGrey)),

                        ),
                        child: InkWell(
                            onTap: ()
                            async {
                              await Navigator.of(context).push(
                                   MaterialPageRoute(builder: (context) =>
                                      ReservationList())
                              );
                              if(widget.onRefrontCallback!=null){
                                widget.onRefrontCallback!();
                              }
                            },
                            child: Container(
                              child: Stack(
                                children: [
                                  Positioned.fill(
                                    child: Align(
                                        alignment: Alignment.bottomLeft,
                                        child:Container(
                                          margin: EdgeInsets.only(bottom: 5),
                                          child: SvgPicture.asset(
                                            //AppImages.delayedOrder, height: 40,
                                            AppImages.menuReservationIcon, height: 35,
                                            color: AppTheme.colorRed,),
                                        )

                                    ),
                                  ),
                                  Positioned(
                                      child:Align(
                                          alignment: Alignment.center,
                                          child: Container(
                                            //margin: EdgeInsets.only(bottom: 70,left: 35),
                                              margin: EdgeInsets.only(bottom: 20,left: 20),
                                              height: 25,
                                              width: 25,
                                              decoration: BoxDecoration(
                                                  color: AppTheme.colorDarkGrey,
                                                  //borderRadius: BorderRadius.circular(30)
                                                  borderRadius: BorderRadius.circular(20)
                                              ),
                                              child:
                                              Center(
                                                child: Text(reservationList.length.toString(),style: TextStyle(color: Colors.white,fontSize: 12,fontWeight: FontWeight.bold),),
                                              )
                                          )
                                      )
                                  )
                                ],
                              ),
                            )
                          /*child: SvgPicture.asset(
                              AppImages.delayedOrder, height: 40,
                              color: AppTheme.colorRed,))*/
                        )
                    ),
                  ]

                  else ...[
                    Container(
                      //height: 100,

                        // padding: EdgeInsets.only(left: 12,right: 12,top: 5,bottom: 5),
                        // decoration: const BoxDecoration(
                        //   border: Border(right: BorderSide(color: AppTheme.colorLightGrey)),
                        //
                        // ),
                        // child: InkWell(
                        //     onTap: ()
                        //     async {
                        //       await Navigator.of(context).push(
                        //           MaterialPageRoute(builder: (context) =>
                        //               ReservationList())
                        //       );
                        //       if(widget.onRefrontCallback!=null){
                        //         widget.onRefrontCallback!();
                        //       }
                        //     },
                        //     child: Container(
                        //       child: Stack(
                        //         children: [
                        //           Positioned.fill(
                        //             child: Align(
                        //                 alignment: Alignment.bottomLeft,
                        //                 child:Container(
                        //                   margin: EdgeInsets.only(bottom: 5),
                        //                   child: SvgPicture.asset(
                        //                     //AppImages.delayedOrder, height: 40,
                        //                     AppImages.menuReservationIcon, height: 35,
                        //                     color: AppTheme.colorRed,),
                        //                 )
                        //
                        //             ),
                        //           ),
                        //           Positioned(
                        //               child:Align(
                        //                   alignment: Alignment.center,
                        //                   child: Container(
                        //                     //margin: EdgeInsets.only(bottom: 70,left: 35),
                        //                       margin: EdgeInsets.only(bottom: 20,left: 20),
                        //                       height: 25,
                        //                       width: 25,
                        //                       // decoration: BoxDecoration(
                        //                       //     color: AppTheme.colorDarkGrey,
                        //                       //     //borderRadius: BorderRadius.circular(30)
                        //                       //     borderRadius: BorderRadius.circular(20)
                        //                       // ),
                        //                       // child:
                        //                       // Center(
                        //                       //   child: Text(reservationList.length.toString(),style: TextStyle(color: Colors.white,fontSize: 12,fontWeight: FontWeight.bold),),
                        //                       // )
                        //                   )
                        //               )
                        //           )
                        //         ],
                        //       ),
                        //     )
                        //   /*child: SvgPicture.asset(
                        //       AppImages.delayedOrder, height: 40,
                        //       color: AppTheme.colorRed,))*/
                        // )
                    ),
                  ]
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
  Widget getMenu(){

    //return SingleChildScrollView(
      //child:
      return Padding(

        padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
        child: Dialog(

            insetAnimationDuration:const Duration(seconds: 10),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.only(bottomLeft: Radius.circular(10), bottomRight: Radius.circular(10)),
            ),

            alignment: Alignment.topCenter,
            elevation: 100,
            backgroundColor: Colors.black54,
            insetPadding: EdgeInsets.all(0),
            child: SingleChildScrollView(
                child: Stack(

                  alignment: Alignment.center,
                  children: <Widget>[

                    Container(
                        width: double.infinity,
                        //height: MediaQuery.of(context).size.height*0.76,
                        padding: EdgeInsets.only(top: 40),
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.rectangle,
                          borderRadius: BorderRadius.only(
                              bottomLeft: Radius.circular(10), bottomRight: Radius.circular(10)),
                        ),
                       // child: SingleChildScrollView(
                            child:Padding(
                              padding: const EdgeInsets.fromLTRB(8, 240, 8, 8),
                              child: Column(
                                children: [
                                  Row(
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.fromLTRB(10, 0, 5, 0),
                                        child: Container(
                                          width:100,
                                          height: 96,
                                          alignment: Alignment.center,
                                          child:InkWell(
                                            splashColor: Colors.green,
                                            onTap: () async {
                                              Navigator.pop(context);
                                              //Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context)=>OrderedList()));
                                              await Navigator.of(context).push(MaterialPageRoute(builder: (context)=>OrderArchive()));
                                              if(widget.onRefrontCallback!=null){
                                                widget.onRefrontCallback!();
                                              }
                                            },
                                            child: Column(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              children: <Widget>[
                                                SvgPicture.asset(AppImages.menuOrdersIcon,
                                                  height: 40, color: Colors.black54,),
                                                 Padding(
                                                  padding: const EdgeInsets.only(top: 8),
                                                  child: Text("orders",style: TextStyle(fontSize: 14,color: Colors.black),).tr(),
                                           ),// <-- Text
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.fromLTRB(10, 0, 5, 0),
                                        child: Container(
                                          width:100,
                                          height: 96,
                                          alignment: Alignment.center,
                                          child:InkWell(
                                            splashColor: Colors.green,
                                            onTap: () async {
                                              Navigator.pop(context);

                                              await Navigator.of(context).push(MaterialPageRoute(builder: (context)=>ReservationList()));
                                              if(widget.onRefrontCallback!=null){
                                                widget.onRefrontCallback!();
                                              }
                                            },
                                            child: Column(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              children: <Widget>[
                                                SvgPicture.asset(AppImages.menuReservationIcon, height: 40, color: Colors.black54,), // <-- Icon
                                                // <-- Icon
                                                Padding(
                                                  padding: const EdgeInsets.only(top: 8),
                                                  child: Text("booking",style: TextStyle(fontSize: 14,color: Colors.black),).tr(),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.fromLTRB(10, 0, 1, 0),
                                        child: Container(
                                          width:100,
                                          height: 96,
                                          alignment: Alignment.center,
                                          child:InkWell(
                                            splashColor: Colors.green,
                                            onTap: () async {
                                             await Navigator.of(context).pushReplacement(MaterialPageRoute(
                                                  builder: (context) => GoogleMapOptifood()));
                                             if(widget.onRefrontCallback!=null){
                                               widget.onRefrontCallback!();
                                             }
                                            },
                                            child: Column(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              children: <Widget>[
                                                SvgPicture.asset(AppImages.menuMapIcon, height: 40, color: Colors.black54,), // <-- Icon
                                                 Padding(
                                                  padding: EdgeInsets.only(top: 8),
                                                  child: Text("maps",style: TextStyle(fontSize: 14,color: Colors.black),).tr(),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),

                                  Row(
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.fromLTRB(10, 0, 5, 0),
                                        child: Container(
                                          width:100,
                                          height: 96,
                                          alignment: Alignment.center,
                                          child:InkWell(
                                            splashColor: Colors.green,
                                            onTap: () async {
                                             await Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context)=>const MessageConversation()
                                              ));
                                             if(widget.onRefrontCallback!=null){
                                               widget.onRefrontCallback!();
                                             }
                                            }
                                            ,
                                            child: Column(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              children: <Widget>[
                                                SvgPicture.asset(AppImages.menuMessageIcon, height: 40, color: Colors.black54,), // <-- Icon
                                                 Padding(
                                                  padding: EdgeInsets.only(top: 8),
                                                  child: Text("message".tr().toUpperCase(),style: TextStyle(fontSize: 14,color: Colors.black),),
                                                ),// <-- Text
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.fromLTRB(10, 0, 5, 0),
                                        child: Container(
                                          width:100,
                                          height: 96,
                                          alignment: Alignment.center,
                                          child:InkWell(
                                            splashColor: Colors.green,
                                            onTap: () async {
                                              Utility().showToastMessage("Coming Soon...");
                                            },
                                            child: Column(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              children: <Widget>[
                                                SvgPicture.asset(AppImages.menuChatIcon, height: 40, color: Colors.black54,), // <-- Icon
                                                 Padding(
                                                  padding: EdgeInsets.only(top: 8),
                                                  child: Text("chat",style: TextStyle(fontSize: 14,color: Colors.black),).tr(),
                                                ),
                                              ],
                                            ),
                                          ),  
                                        ),
                                      ),//CHAT COMMENTED FOR NOW
                                      if(allowedPrivileges!=null && allowedPrivileges.contains('report')==true)
                                      Padding(
                                        padding: const EdgeInsets.fromLTRB(10, 0, 1, 0),
                                        child: Container(
                                          width:100,
                                          height: 96,
                                          alignment: Alignment.center,
                                          child:InkWell(
                                            splashColor: Colors.green,
                                            onTap: () async {
                                              await Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context)=>const Report()
                                              ));
                                              //LocalNotifications.showSimpleNotification(id: 1, title: "User name", body: "Test Message", payload: "payload");
                                            },
                                            child: Column(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              children: <Widget>[
                                                SvgPicture.asset(AppImages.menuReceiptIcon, height: 40, color: Colors.black54,), // <-- Icon
                                                 Padding(
                                                  padding: EdgeInsets.only(top: 8),
                                                  child: Text("report",style: TextStyle(fontSize: 14,color: Colors.black),).tr(),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                      if(allowedPrivileges!=null && allowedPrivileges.contains('report')==false)
                                      Padding(
                                        padding: const EdgeInsets.fromLTRB(3, 0, 5, 0),
                                        child: Container(
                                          width:100,
                                          height: 96,
                                          alignment: Alignment.center,
                                          child:InkWell(
                                            splashColor: Colors.green,
                                            onTap: () async {
                                              await Navigator.of(context).pushReplacement(MaterialPageRoute(builder:
                                                  (context)=>OptifoodManagementMenu()
                                              ));
                                              if(widget.onRefrontCallback!=null){
                                                widget.onRefrontCallback!();
                                              }
                                            },
                                            child: Column(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              children: <Widget>[
                                                SvgPicture.asset(AppImages.menuManagementIcon,
                                                  height: 40, color: Colors.black54,), // <-- Icon
                                                Padding(
                                                  padding: const EdgeInsets.only(top: 8),
                                                  child: const Text("management",style:
                                                  TextStyle(fontSize: 14,color: Colors.black),).tr(),
                                                ),// <-- Text
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),

                                  Row(
                                    children: [
                                      if(allowedPrivileges!=null && allowedPrivileges.contains('report')==true)
                                      Padding(
                                        padding: const EdgeInsets.fromLTRB(3, 0, 5, 0),
                                        child: Container(
                                          width:112,
                                          height: 96,
                                          alignment: Alignment.center,
                                          child:InkWell(
                                            splashColor: Colors.green,
                                            onTap: () async {
                                              await Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context)=>OptifoodManagementMenu()
                                              ));
                                              if(widget.onRefrontCallback!=null){
                                                widget.onRefrontCallback!();
                                              }
                                            },
                                            child: Column(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              children: <Widget>[
                                                SvgPicture.asset(AppImages.menuManagementIcon,
                                                  height: 40, color: Colors.black54,), // <-- Icon
                                                 Padding(
                                                  padding: const EdgeInsets.only(top: 8),
                                                  child: const Text("management",style:
                                                  TextStyle(fontSize: 14,color: Colors.black),).tr(),
                                                ),// <-- Text
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.fromLTRB(10, 0, 5, 0),
                                        child: Container(
                                          width:96,
                                          height: 96,
                                          alignment: Alignment.center,
                                          child:InkWell(
                                            splashColor: Colors.green,
                                            onTap: () async {
                                              await Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context)=>OptifoodSettingsMenu()
                                              ));
                                              if(widget.onRefrontCallback!=null){
                                                widget.onRefrontCallback!();
                                              }
                                            },
                                            child: Column(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              children: <Widget>[
                                                SvgPicture.asset(AppImages.menuSettingsIcon, height: 40, color: Colors.black54,), // <-- Icon
                                                 Padding(
                                                  padding: const EdgeInsets.only(top: 8),
                                                  child: const Text("settings",style: TextStyle(color: Colors.black, fontSize: 14),).tr(),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.fromLTRB(10, 0, 1, 0),
                                        child: Container(
                                          width:100,
                                          height: 96,
                                          alignment: Alignment.center,
                                          child:InkWell(
                                            splashColor: Colors.green,
                                            onTap: () {
                                              logout();
                                            },
                                            child: Column(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              children: <Widget>[
                                                SvgPicture.asset(AppImages.menuLogoutIcon, height: 40, color: Colors.black54,), // <-- Icon
                                                 Padding(
                                                  padding: const EdgeInsets.only(top: 8),
                                                  child: Text("logout",style: const TextStyle(color: Colors.black, fontSize: 14),).tr(),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            )
                       // )
                    ),
                    Positioned(
                        top: 5,
                        child: Container(
                            decoration: const BoxDecoration(
                                shape: BoxShape.rectangle,
                                color:Color(0xfffafafa),
                                borderRadius: BorderRadius.only(
                                    bottomLeft: Radius.circular(280), bottomRight: Radius.circular(280))
                            ),
                            child: Column(
                              children: [
                                Row(
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
                                      //padding: const EdgeInsets.fromLTRB(10, 30, 0, 30),
                                      padding: const EdgeInsets.fromLTRB(10, 30, 0, 30),
                                      child: Transform.translate(
                                          offset: Offset(-50,0),
                                          child: Image.asset(AppImages.optiFoodLogoIcon,height: 180,width: 360,)),
                                    ),
                                  ],
                                ),
                                Transform.translate(offset: Offset(0,-20),
                                child: Text(versionName,style: TextStyle(color: AppTheme.colorDarkGrey,fontSize: 12),).tr(),
                                )

                              ],
                            )
                            /*child: Row(
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
                                      child: Image.asset(AppImages.optiFoodLogoIcon,height: 180,width: 360,)),
                                ),
                              ],
                            )*/
                        )
                    ),
                  ],
                )
            )

        ),
      );

  }

  populatePrivileges(){
    var accessToken = optifoodSharedPrefrence.getString("accessToken");
    var userType = optifoodSharedPrefrence.getString("userType");
    if(accessToken!=null && accessToken!="") {
      if (userType == 'Admin') {
        setState(() {
          allowedPrivileges= Privileges.adminPrivileges;
        });
      }
      else if (userType == 'Manager') {
        setState(() {
          allowedPrivileges= Privileges.managerPrivileges;
        });
      }
    }
  }
}