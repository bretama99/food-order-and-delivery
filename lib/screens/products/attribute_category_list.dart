import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:dio/dio.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:fbroadcast/fbroadcast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:opti_food_app/api/attribute_category_api.dart';
import 'package:opti_food_app/screens/products/attribute_list.dart';
import 'package:opti_food_app/screens/products/food_item_list.dart';
import 'package:opti_food_app/utils/constants.dart';
import 'package:opti_food_app/widgets/appbar/app_bar_optifood.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../assets/images.dart';
import '../../data_models/attribute_category_model.dart';
import '../../database/attribute_category_dao.dart';
import '../../database/attribute_dao.dart';
import '../../utils/utility.dart';
import '../../widgets/app_theme.dart';
import '../../widgets/option_menu/company/company_option_menu_popup.dart';
import '../../widgets/popup/confirmation_popup/confirmation_popup.dart';
import '../authentication/client_register.dart';
import '../authentication/delivery_info.dart';
import '../order/ordered_lists.dart';
import 'add_attribute_category.dart';
import '../MountedState.dart';
class AttributeCategoryList extends StatefulWidget {
  static String searchQuery = "";
  @override
  State<AttributeCategoryList> createState() => _AttributeCategoryState();
}
class _AttributeCategoryState extends MountedState<AttributeCategoryList> {
  FocusNode focusNode = FocusNode();
  List<AttributeCategoryModel> attributeCategoryList = [];
  void getAttributeCategories() async {
    AttributeCategoryDao().getAllAttributeCategories().then((value){
      setState(() {
        if(AttributeCategoryList.searchQuery.length>0){
          attributeCategoryList = value.where((element) => (element.name).toLowerCase().contains(AttributeCategoryList.searchQuery.toLowerCase())).toList();
        }
        else{
          attributeCategoryList = value;
          for(int i=0;i<attributeCategoryList.length;i++){
          print("attributeCategoryList=====${attributeCategoryList[i].serverId}==========");

            AttributeDao().getAttributeByCategory(attributeCategoryList[i].serverId!).then((value3){
              attributeCategoryList[i].attributeCount = value3!.length;
            });
          }
        }
      });
    });
  }
  @override
  void initState() {
    setState(() {
      getAttributeCategories();

    });
    // getAttributeCategoryListFromServer();
    FBroadcast.instance().register(ConstantBroadcastKeys.KEY_UPDATE_UI, (value, callback) {
      getAttributeCategories();
    });
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    final isLandscape = MediaQuery.of(context).orientation == Orientation.landscape;
    return Scaffold(
      appBar: AppBarOptifood(isShowSearchBar: true,onSearch: (search){
        AttributeCategoryList.searchQuery = search;
        setState(() {
          getAttributeCategories();
        });
      },),
      body: attributeCategoryList.length>0?Padding(
        padding: const EdgeInsets.only(top: 3),
        child: Container(
          child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(3, 0, 3, 0),
                child: ListView.builder(
                    itemCount: attributeCategoryList.length,
                    itemBuilder: (context, index) => GestureDetector(
                      onHorizontalDragStart: (DragStartDetails details){
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
                                                    AddAttributeCategory(
                                                      existingAttributeCategoryModel: attributeCategoryList[index],
                                                    )
                                            ));
                                        setState(() {
                                          getAttributeCategories();
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
                                                title: "delete".tr(),
                                                titleImagePath: AppImages.deleteIcon,
                                                positiveButtonText: "delete".tr(),
                                                negativeButtonText: "cancel".tr(),
                                                titleImageBackgroundColor: AppTheme
                                                    .colorRed,
                                                positiveButtonPressed: () async {
                                                  if(attributeCategoryList[index].attributeCount==0) {
                                                    await AttributeCategoryDao()
                                                        .delete(
                                                        attributeCategoryList[index])
                                                        .then((value) {
                                                          if(attributeCategoryList[index].serverId!=0)
                                                      AttributeCategoryApi().deleteAttributeCategory(
                                                          attributeCategoryList[index]
                                                              .serverId!);
                                                          else
                                                            AttributeCategoryApi().deleteAttributeCategory(
                                                                attributeCategoryList[index]
                                                                    .id!);

                                                    });
                                                    setState(() {
                                                      getAttributeCategories();
                                                    });
                                                  }
                                                  else{
                                                    Utility().showToastMessage("theCategoryMustBeEmptyToBeDeleted".tr());

                                                    // final snackBar = SnackBar(
                                                    //   duration: const Duration(milliseconds: 500),
                                                    //   content: const Text('attributes already exists under this category',style: TextStyle(color: AppTheme.colorRed,fontSize: 18),),
                                                    //   backgroundColor: (Colors.grey),
                                                    // );
                                                    // ScaffoldMessenger.of(context).showSnackBar(snackBar);
                                                  }
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
                        await Navigator.of(context).push(MaterialPageRoute(builder:
                            (context) => AttributeList(attributeCategoryList[index])));
                        setState(() {
                          getAttributeCategories();
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
                                padding: const EdgeInsets.only(left: 8,right: 2),
                                child: Container(
                                  width: 38,
                                  color: Colors.white,
                                  //child: SvgPicture.asset(AppImages.clientInfoIcon,
                                  child: attributeCategoryList[index].imagePath==null?SvgPicture.asset(AppImages.attributesIcon,
                                      height: 35):
                                  /*CircleAvatar(
                                    backgroundImage: FileImage(File(foodCategoryList[index].imagePath!)),
                                    radius: 35,
                                  ),*/
                                  Image.file(File(attributeCategoryList[index].imagePath!),height: 35,),
                                ),
                              ),
                              if(attributeCategoryList[index].isSyncedOnServer==false&&attributeCategoryList[index].isSyncOnServerProcessing==false)...[
                                Text("!",style: TextStyle(color: AppTheme.colorRed,fontSize: 28),),
                              ],
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
                                        child: Text("${attributeCategoryList[index].name.toUpperCase()}",
                                          style: TextStyle(fontWeight: FontWeight.bold,fontSize: 18),)),
                                    subtitle: Text(attributeCategoryList[index].attributeCount.toString()+" Attribute(s)",style: TextStyle(fontSize: 14),),
                                    /*subtitle: Padding(
                                      padding: const EdgeInsets.only(top: 4),
                                      child: Transform.translate(
                                        //offset: Offset(-20, 0),
                                        offset: Offset(0, 0),
                                        child: Container(
                                          alignment: Alignment.centerLeft,
                                          child: Column(
                                            mainAxisAlignment: MainAxisAlignment.start,
                                            children: [
                                              if(foodCategoryList[index].address!=null)...[
                                                Row(
                                                  children: [
                                                    Padding(
                                                      padding: const EdgeInsets.only(right: 4),
                                                      child: SvgPicture.asset(AppImages.clientAddressIcon,
                                                          height: 15),
                                                    ),
                                                    Expanded(child: Text("${foodCategoryList[index].address}",overflow: TextOverflow.ellipsis,maxLines: 3,),),
                                                  ],
                                                ),
                                              ],
                                              //if(foodCategoryList[index].phoneNo!=null)...[
                                              Padding(
                                                padding: const EdgeInsets.only(top: 6),
                                                child: Row(
                                                  children: [
                                                    Padding(
                                                      padding: const EdgeInsets.only(right: 4),
                                                      child: SvgPicture.asset(AppImages.phoneClientIcon,
                                                          height: 15),
                                                    ),
                                                    Text("${foodCategoryList[index].phoneNo==null?"":foodCategoryList[index].phoneNo}"),
                                                    //Text("${foodCategoryList[index].phoneNo}"),
                                                  ],
                                                ),
                                              ),
                                              //],
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),*/
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
                await Navigator.of(context).push(MaterialPageRoute(builder: (context)=>AddAttributeCategory()));
                //if(companyModel!=null){
                getAttributeCategories();
                //}
              },
            ),
          ),
        ),
      ),
    );
  }

  /*static deleteAttributeCategory(int serverId) async {
    final dio = Dio();
    dio.options.headers['X-TenantID'] = OPTIFOOD_DATABASE;
    await dio.delete(ServerData.OPTIFOOD_BASE_URL+"/api/attribute-category/${serverId}").then((value){
    }).catchError((onError){
    });
  }*/

  /*getAttributeCategoryListFromServer() async{
    List<AttributeCategoryModel> fetchedData = [];
    int j = 0;
    final dio = Dio();
    dio.options.headers['X-TenantID'] = "optifood3";
    await dio.get(ServerData.OPTIFOOD_BASE_URL+'/api/attribute-category').then((response) {
      List<AttributeCategoryModel> fetchedData = [];
      if (response.statusCode == 200) {
        for (int i = 0; i < response.data.length; i++) {
          var singleItem = AttributeCategoryModel.fromJsonServer(response.data[i]);
          fetchedData.add(singleItem);
        }

        for(int i=0; i<fetchedData.length;i++){
          AttributeCategoryDao().getAttributeCategoryByName(fetchedData[i].name).then((value) {
            if(value.length>0){
              AttributeCategoryDao().updateAttributeCategory(value[value.length-1]).then((res1) {
                if(i==fetchedData.length-1){
                  getAttributeCategories();
                }
              });
            }
            else{
              AttributeCategoryModel attributeCategoryModel = AttributeCategoryModel(
                  1,
                  fetchedData[i].name,
                  fetchedData[i].displayName,
                  fetchedData[i].color,
                  fetchedData[i].position,
                  fetchedData[i].imagePath
              );
              AttributeCategoryDao().insertAttributeCategory(attributeCategoryModel).then((res2){
                if(i==fetchedData.length-1){
                  getAttributeCategories();
                }
              });
            }
          });
        }
      }
    });
      // List<AttributeCategoryModel> data = [];
      // Map<String, dynamic> json=result.data;
      // final List<AttributeCategoryModel> result1;
      // data = json["result1"]
      //     .map<AttributeCategoryModel>((json) => AttributeCategoryModel.fromJson(json))
      //     .toList();
      // data.forEach((element) {
      //   print("Elememetsssssssssssssssssssss: ${element.name}");
      // });
      // var res=AttributeCategoryModel.fromJson(json
      //     .decode(result.data));
    // });
  }*/


}
