import 'dart:async';
import 'dart:io';
import 'package:easy_localization/easy_localization.dart';
import 'package:fbroadcast/fbroadcast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:opti_food_app/api/user_api.dart';
import 'package:opti_food_app/data_models/company_model.dart';
import 'package:opti_food_app/data_models/contact_model.dart';
import 'package:opti_food_app/data_models/user_model.dart';
import 'package:opti_food_app/database/contact_dao.dart';
import 'package:opti_food_app/database/order_dao.dart';
import 'package:opti_food_app/screens/user/add_user.dart';
import 'package:opti_food_app/widgets/appbar/app_bar_optifood.dart';
import 'package:opti_food_app/widgets/option_menu/contact/contact_option_menu_popup.dart';
import 'package:opti_food_app/widgets/option_menu/user/user_option_menu_popup.dart';
import 'package:opti_food_app/widgets/popup/confirmation_popup/confirmation_popup.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../api/order_apis.dart';
import '../../assets/images.dart';
import '../../data_models/order_model.dart';
import '../../database/user_dao.dart';
import '../../utils/constants.dart';
import '../../widgets/app_theme.dart';
import '../MountedState.dart';
import '../authentication/client_register.dart';
import '../authentication/delivery_info.dart';
import '../order/ordered_lists.dart';
import 'package:url_launcher/url_launcher.dart' as UrlLauncher;

class UserList extends StatefulWidget {
  String searchQuery = "";
  String userRole;
  bool? assign;
  OrderModel? orderToBeAssigned;
  UserModel? existingUserModel; // not null if edit order other wise it will be null
  //ContactList({Key? key, required this.delivery,this.primaryContactModel=null,this.returnContact=false}) : super(key: key);
  UserList(this.userRole, {this.existingUserModel, this.assign, this.orderToBeAssigned});

  @override
  State<UserList> createState() => _UserListState();
}
class _UserListState extends MountedState<UserList> {
  String userImagePlaceHolder = "assets/svg/icons/settings/delivery_boy.svg";
  List<UserModel> users = [];
  void getUsers() async {
      Future<List<UserModel>> userModelList = UserDao().getAllUsers(widget.userRole);
      userModelList.then((value){
        setState((){
          //contacts = value;
          if(widget.searchQuery.length>0){
            users = value.where((element) => (element.name).toLowerCase().contains(widget.searchQuery.toLowerCase())
            ).toList();
          }
          else{
            users= value;
          }
        });
      });
  }
  bool value = false;
  List<bool> listChecked = [];
  @override
  void initState() {
    super.initState();
    if(widget.userRole==ConstantUserRole.USER_ROLE_MANAGER){
      userImagePlaceHolder = AppImages.managerIcon;
    }
    else if(widget.userRole==ConstantUserRole.USER_ROLE_DELIVERY_BOY){
      userImagePlaceHolder = "assets/svg/icons/settings/delivery_boy.svg";
    }
    else if(widget.userRole==ConstantUserRole.USER_ROLE_WAITER){
      userImagePlaceHolder = "assets/svg/icons/settings/waiter.svg";
    }
    widget.searchQuery = "";
    getUsers();
    FBroadcast.instance().register(ConstantBroadcastKeys.KEY_UPDATE_UI, (value, callback) {
      getUsers();
    });
  }
  @override
  Widget build(BuildContext context) {
    final isLandscape = MediaQuery.of(context).orientation == Orientation.landscape;
    return Scaffold(
      appBar: AppBarOptifood(isShowSearchBar: true,onSearch: (search){
        widget.searchQuery = search;
        //if(sear)
        setState(() {
          getUsers();
        });
      },),
      body: users.length>0?Padding(
        padding:  EdgeInsets.only(top: 3),
        child: Container(
          child: SafeArea(
              child: Padding(
                padding:  EdgeInsets.fromLTRB(3, 0, 3, 0),
                child: ListView.builder(
                    itemCount: users.length,
                    itemBuilder: (context, index) => GestureDetector(
                      onHorizontalDragStart: (DragStartDetails details){
                        if(true) {
                          setState(() {
                            showDialog(context: context,
                                builder: (BuildContext context) {
                                  return UserOptionMenuPopup(
                                      userModel: users[index],
                                      onSelect: (action) async {
                                        if (action ==
                                            UserOptionMenuPopup.ACTIONS
                                                .ACTION_EDIT) {
                                          UserModel updatedUserModel = await Navigator.of(context).push(
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      AddUser(
                                                        widget.userRole,
                                                        existingUserModel: users[index],
                                                      )
                                              ));
                                          setState(() {
                                            getUsers();
                                          });
                                        }
                                        else if(action == UserOptionMenuPopup.ACTIONS.ACTION_CALL){
                                          //UrlLauncher.launch("tel://"+users[index].phoneNumber);
                                          UrlLauncher.launch("tel:"+users[index].phoneNumber);
                                        }
                                        else if (action ==
                                            UserOptionMenuPopup.ACTIONS
                                                .ACTION_DELETE) {
                                          showDialog(
                                              context: context,
                                              builder: (BuildContext
                                              context) {
                                                return ConfirmationPopup(
                                                  title: "delete".tr(),
                                                  titleImagePath: AppImages.deleteIcon,
                                                  positiveButtonText: "delete".tr(),
                                                  negativeButtonText: "cancel".tr(),
                                                  titleImageBackgroundColor: AppTheme
                                                      .colorRed,
                                                  positiveButtonPressed: () async {
                                                      await UserDao().delete(users[index]);
                                                      setState(() {
                                                        getUsers();
                                                      });

                                                  },
                                                  subTitle: 'areYouSureToDeleteUser'.tr(),
                                                );
                                              });
                                        }
                                      });
                                });
                          });
                        }
                      },
                      onTap: () async {
                        UserModel updatedUserModel = await Navigator.of(context).push(
                            MaterialPageRoute(
                                builder: (context) =>
                                    AddUser(
                                      widget.userRole,
                                      existingUserModel: users[index],
                                    )
                            ));
                        setState(() {
                          getUsers();
                        });
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
                                padding: EdgeInsets.only(left: 8,right: 2),
                                child: Container(
                                  width: 38,
                                  child:
                                  users[index].imagePath==null?SvgPicture.asset(userImagePlaceHolder,
                                      height: 35)
                                  : Image.file(File(users[index].imagePath!),height: 35,),
                                ),
                              ),
                              Container(height: 50, child: VerticalDivider(color: Colors.black54)),
                              Expanded(
                                child: Padding(
                                  padding: EdgeInsets.all(7.0),
                                  child: ListTile(
                                    contentPadding: EdgeInsets.all(0),
                                    dense: true,
                                    title: Transform.translate(
                                      //offset: Offset(-20,0),
                                        offset: Offset(0,0),
                                        child: Text("${users[index].name}",
                                          style: TextStyle(fontWeight: FontWeight.bold,fontSize: 18),)),
                                    subtitle: Padding(
                                      padding:  EdgeInsets.only(top: 4),
                                      child: Transform.translate(
                                        //offset: Offset(-20, 0),
                                        offset: Offset(0, 0),
                                        child: Container(
                                          alignment: Alignment.centerLeft,
                                          child: Column(
                                            mainAxisAlignment: MainAxisAlignment.start,
                                            children: [
                                              Padding(
                                                padding:  EdgeInsets.only(top: 6),
                                                child: Row(
                                                  children: [
                                                    Padding(
                                                      padding:  EdgeInsets.only(right: 4),
                                                      child: SvgPicture.asset(AppImages.phoneClientIcon,
                                                          height: 15),
                                                    ),
                                                    Text("${users[index].phoneNumber}"),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                    trailing:widget.assign==true?
                                    Checkbox(
                                      value: users[index].isAssigned==true?users[index].isAssigned:((widget.orderToBeAssigned!.deliveryInfoModel!.assignedTo==users[index].intServerId)||(widget.orderToBeAssigned!.deliveryInfoModel!.assignedTo==users[index].id))?true:false,
                                      onChanged: (bool? value) {
                                        setState(() {
                                          // this.value = value!;
                                          users[index].isAssigned = value!;
                                          if(value==false){
                                            widget.orderToBeAssigned!.deliveryInfoModel!.assignedTo=0;

                                          }
                                          else{
                                            widget.orderToBeAssigned!.deliveryInfoModel!.assignedTo=users[index].id;
                                          }
                                          OrderDao().updateOrder(widget.orderToBeAssigned!);
                                           assignOrderToDeliveryBoy(widget.orderToBeAssigned!.serverId,users[index].intServerId, users[index].isAssigned);
                                          Navigator.pop(context);

                                        });
                                      },
                                    ):
                                    Switch(
                                      onChanged: (bool value) {
                                          setState(() {
                                            users[index].isActivated = value;
                                            UserDao().updateUser(users[index]);
                                            UserApis.saveUserToSever(users[index],isUpdate: true);
                                          });
                                      },
                                      value: users[index].isActivated?users[index].isActivated:false,
                                      activeColor: AppTheme.colorRed,
                                    ),
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
      ):  Center(child: Text("noDataFound".tr(),style: TextStyle(fontSize: 16),)) ,
      floatingActionButton:Padding(
        padding:  EdgeInsets.only(top: 40),
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
                await Navigator.of(context).push(MaterialPageRoute(builder: (context)=>AddUser(widget.userRole)));
                  setState((){
                    getUsers();
                  });
              },
            ),
          ),
        ),
      ),
    );
  }

  void assignOrderToDeliveryBoy(int? orderServerId, int? deliveryBoyServerId, bool isAssigned) {
    OrderApis.assignOrderToDeliveryBoy(orderServerId,deliveryBoyServerId,isAssigned);
  }
}
