import 'dart:async';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:fbroadcast/fbroadcast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:opti_food_app/api/attribute_api.dart';
import 'package:opti_food_app/data_models/company_model.dart';
import 'package:opti_food_app/data_models/contact_model.dart';
import 'package:opti_food_app/data_models/food_category_model.dart';
import 'package:opti_food_app/data_models/food_items_model.dart';
import 'package:opti_food_app/database/company_dao.dart';
import 'package:opti_food_app/database/contact_dao.dart';
import 'package:opti_food_app/database/food_category_dao.dart';
import 'package:opti_food_app/database/food_items_dao.dart';
import 'package:opti_food_app/screens/products/add_attribute.dart';
import 'package:opti_food_app/screens/products/add_food_category.dart';
import 'package:opti_food_app/screens/products/add_food_item.dart';
import 'package:opti_food_app/utils/utility.dart';
import 'package:opti_food_app/widgets/appbar/app_bar_optifood.dart';
import 'package:opti_food_app/widgets/option_menu/products/attribute_option_menu_popup.dart';
import 'package:opti_food_app/widgets/option_menu/products/food_item_option_menu_popup.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../assets/images.dart';
import '../../data_models/attribute_category_model.dart';
import '../../data_models/attribute_model.dart';
import '../../database/attribute_dao.dart';
import '../../utils/constants.dart';
import '../../widgets/app_theme.dart';
import '../../widgets/option_menu/company/company_option_menu_popup.dart';
import '../../widgets/popup/confirmation_popup/confirmation_popup.dart';
import '../authentication/client_register.dart';
import '../authentication/delivery_info.dart';
import '../order/ordered_lists.dart';
import '../MountedState.dart';
class AttributeList extends StatefulWidget {
  static String searchQuery = "";
  AttributeCategoryModel attributeCategoryModel;
  AttributeList(this.attributeCategoryModel);
  @override
  State<AttributeList> createState() => _AttributeState();
}
class _AttributeState extends MountedState<AttributeList> {
  late SharedPreferences sharedPreferences;
  FocusNode focusNode = FocusNode();
  List<AttributeModel> attributeList = [];

  void getAttributes() async {
    AttributeDao().getAttributeByCategoryDisplay(widget.attributeCategoryModel).then((value){
      setState((){
        //contacts = value;
        if(AttributeList.searchQuery.length>0){
          attributeList = value.where((element) => (element.name).toLowerCase().contains(AttributeList.searchQuery.toLowerCase())).toList();
        }
        else{
          attributeList = value;
        }
      });
    });
  }
  @override
  void initState() {
    SharedPreferences.getInstance().then((value){
      sharedPreferences = value;
    });
    getAttributes();
    FBroadcast.instance().register(ConstantBroadcastKeys.KEY_UPDATE_UI, (value, callback) {
      getAttributes();
    });
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    final isLandscape = MediaQuery.of(context).orientation == Orientation.landscape;
    return Scaffold(
      appBar: AppBarOptifood(isShowSearchBar: true,onSearch: (search){
        AttributeList.searchQuery = search;
        setState(() {
          getAttributes();
        });
      },),
      body: Padding(
        padding: const EdgeInsets.only(top: 3),
        child: Container(
          child: SafeArea(
            child: attributeList.length>0?Padding(
                padding: const EdgeInsets.fromLTRB(3, 0, 3, 0),
                child: ListView.builder(
                  itemCount: attributeList.length,
                  itemBuilder: (context, index) => GestureDetector(
                    onHorizontalDragStart: (DragStartDetails details){
                      setState(() {
                        showDialog(context: context,
                            builder: (BuildContext context) {
                              return AttributeOptionMenuPopup(
                                onSelect: (action) async {
                                  //var orderServiceID =  widget.orderType==ConstantOrderType.ORDER_TYPE_DELIVERY?ConstantCurrentOrderService.DELIVER_ORDER_TYPE:ConstantCurrentOrderService.RESTAURANT_ORDER_TYPE_EAT_IN;
                                  if (action ==
                                      FoodItemOptionMenuPopup.ACTIONS
                                          .ACTION_EDIT) {
                                    await Navigator.of(context).push(
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                AddAttribute(
                                                  widget.attributeCategoryModel,
                                                  existingAttributeModel: attributeList[index],
                                                )
                                        ));
                                    setState(() {
                                      getAttributes();
                                    });
                                  }
                                  else if (action ==
                                      FoodItemOptionMenuPopup.ACTIONS
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
                                              await AttributeDao().delete(widget.attributeCategoryModel,attributeList[index]).then((value){
                                                AttributeApi().deleteAttribute(attributeList[index].serverId!);
                                              });
                                              setState(() {
                                                getAttributes();
                                              });
                                            },
                                            subTitle: 'areYouSureToDeleteCategory'.tr(),
                                          );
                                        });
                                  }
                                });
                            });
                      });
                    },
                    onTap: () async {
                      await Navigator.of(context).push(
                          MaterialPageRoute(
                              builder: (context) =>
                                  AddAttribute(
                                    widget.attributeCategoryModel,
                                    existingAttributeModel: attributeList[index],
                                  )
                          ));
                      setState(() {
                        getAttributes();
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
                          child: ListTile(
                            contentPadding: EdgeInsets.only(left: 15,right: 15),
                            dense: true,
                            leading:
                                Container(
                                  color: Colors.white,
                                  //color: AppTheme.colorRed,
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      attributeList[index].imagePath==null?SvgPicture.asset(AppImages.attributesIcon,
                                          height: 35):
                                      // SvgPicture.asset(AppImages.attributesIcon,
                                      //     height: 35),
                                      Image.file(File(attributeList[index].imagePath!),height: 35,width: 35,),
                                      if(attributeList[index].isSyncedOnServer==false&&attributeList[index].isSyncOnServerProcessing==false)...[
                                        Text("!",style: TextStyle(color: AppTheme.colorRed,fontSize: 28),),
                                      ],
                                      Padding(padding: EdgeInsets.only(top: 5,bottom: 5),
                                        child: VerticalDivider(color: Colors.black54,),
                                      )
                                    ],
                                  ),
                                ),

                            title:
                            /*Text("${attributeList[index].name.toUpperCase()}",
                              style: TextStyle(fontSize: 16),textAlign: TextAlign.start,),*/
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                  SizedBox(height: 10,),
                                Text("${attributeList[index].name.toUpperCase()}",
                                  style: TextStyle(fontSize: 16),textAlign: TextAlign.start,),
                                  SizedBox(height: 6,),
                                Container(
                                    child: Row(
                                      children: [
                                        Container(
                                          //child: Text("Price: ${attributeList[index].price.toStringAsFixed(2).replaceAll(".", ",")}€",
                                          child: attributeList[index].price!=null ?Text("Price: ${Utility().formatPrice(attributeList[index].price)}",
                                            style: TextStyle(fontSize: 12,fontWeight: FontWeight.bold),):Text("")
                                          ,),
                                      ],
                                    )
                                ),
                                  SizedBox(height: 10,)
                              ],
                            ),
                            /*trailing: Switch(
                              onChanged: (bool value) {
                                if(attributeList[index].isActivated){
                                  setState(() {
                                    attributeList[index].isProductInStock = value;
                                    FoodItemsDao().updateFoodItem(attributeList[index]);
                                  });
                                }
                              },
                              value: attributeList[index].isActivated?attributeList[index].isProductInStock:false,
                              activeColor: AppTheme.colorRed,
                            ),*/
                          ),
                        )
                    ),
                  ),
                )
            ):  Center(child: Text("noDataFound".tr(),style: TextStyle(fontSize: 16),)),
            //      )
          ),
        ),
      ),
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
                /*FoodItemsModel foodItemsModel = await Navigator.of(context).push(MaterialPageRoute(builder: (context)=>AddFoodItem(
                    widget.attributeCategoryModel*/
                await Navigator.of(context).push(MaterialPageRoute(builder: (context)=>AddAttribute(
                    widget.attributeCategoryModel
                )));
                //if(companyModel!=null){
                getAttributes();
              },
            ),
          ),
        ),
      ),
    );
  }

  /*static deleteAttribute(int serverId) async {
    final dio = Dio();
    dio.options.headers['X-TenantID'] = ServerData.OPTIFOOD_DATABASE.toString();
    await dio.delete(ServerData.OPTIFOOD_BASE_URL+"/api/attribute/${serverId}").then((value){
    }).catchError((onError){
    });
  }*/


}
