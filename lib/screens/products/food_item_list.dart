import 'dart:async';
import 'dart:io';
import 'package:autocomplete_textfield/autocomplete_textfield.dart';
import 'package:dio/dio.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:fbroadcast/fbroadcast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:opti_food_app/api/food_item_api.dart';
import 'package:opti_food_app/data_models/company_model.dart';
import 'package:opti_food_app/data_models/contact_model.dart';
import 'package:opti_food_app/data_models/food_category_model.dart';
import 'package:opti_food_app/data_models/food_items_model.dart';
import 'package:opti_food_app/database/company_dao.dart';
import 'package:opti_food_app/database/contact_dao.dart';
import 'package:opti_food_app/database/food_category_dao.dart';
import 'package:opti_food_app/database/food_items_dao.dart';
import 'package:opti_food_app/screens/products/add_food_category.dart';
import 'package:opti_food_app/screens/products/add_food_item.dart';
import 'package:opti_food_app/utils/utility.dart';
import 'package:opti_food_app/widgets/appbar/app_bar_optifood.dart';
import 'package:opti_food_app/widgets/option_menu/products/food_item_option_menu_popup.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../assets/images.dart';
import '../../data_models/attribute_category_model.dart';
import '../../database/order_dao.dart';
import '../../utils/constants.dart';
import '../../widgets/app_theme.dart';
import '../../widgets/option_menu/company/company_option_menu_popup.dart';
import '../../widgets/popup/confirmation_popup/confirmation_popup.dart';
import '../authentication/client_register.dart';
import '../authentication/delivery_info.dart';
import '../order/ordered_lists.dart';
import '../MountedState.dart';
class FoodItemList extends StatefulWidget {
  static String searchQuery = "";
  FoodCategoryModel foodCategoryModel;
  FoodItemList(this.foodCategoryModel);
  @override
  State<FoodItemList> createState() => _FoodItemState();
}
class _FoodItemState extends MountedState<FoodItemList> {
  FocusNode focusNode = FocusNode();
  List<FoodItemsModel> foodItemsList = [];
  late SharedPreferences sharedPreferences;
  void getFoodItems() async {
    FoodItemsDao().getFoodItemsByCategoryForDisplay(widget.foodCategoryModel).then((value){
      setState((){
        //contacts = value;
        if(FoodItemList.searchQuery.length>0){
          foodItemsList = value.where((element) => (element.name).toLowerCase().contains(FoodItemList.searchQuery.toLowerCase())).toList();
        }
        else{
          foodItemsList = value;
        }
      });
    });
  }
  @override
  void initState() {
    SharedPreferences.getInstance().then((value){
      sharedPreferences = value;
    });
    setState(() {
      getFoodItems();
    });
    FBroadcast.instance().register(ConstantBroadcastKeys.KEY_UPDATE_UI, (value, callback) {
      getFoodItems();
    });
    // getFoodItemsListFromServer();
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    final isLandscape = MediaQuery.of(context).orientation == Orientation.landscape;
    return Scaffold(
      appBar: AppBarOptifood(isShowSearchBar: true,onSearch: (search){
        FoodItemList.searchQuery = search;
        setState(() {
          getFoodItems();
        });
      },),
      body: foodItemsList.length>0?
              Padding(
        padding: const EdgeInsets.only(top: 3),
        child: Container(
          child: SafeArea(
            child: Padding(
                padding: const EdgeInsets.fromLTRB(3, 0, 3, 0),
                child: ListView.builder(
                  itemCount: foodItemsList.length,
                  itemBuilder: (context, index) => GestureDetector(
                    onHorizontalDragStart: (DragStartDetails details){
                      setState(() {
                        showDialog(context: context,
                            builder: (BuildContext context) {
                              return FoodItemOptionMenuPopup(
                                onSelect: (action) async {
                                  //var orderServiceID =  widget.orderType==ConstantOrderType.ORDER_TYPE_DELIVERY?ConstantCurrentOrderService.DELIVER_ORDER_TYPE:ConstantCurrentOrderService.RESTAURANT_ORDER_TYPE_EAT_IN;
                                  if (action ==
                                      FoodItemOptionMenuPopup.ACTIONS
                                          .ACTION_EDIT) {
                                    await Navigator.of(context).push(
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                AddFoodItem(
                                                  widget.foodCategoryModel,
                                                  existingFoodItemModel: foodItemsList[index],
                                                )
                                        ));
                                    setState(() {
                                      getFoodItems();
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
                                              await OrderDao().getAllOrders().then((value22) async {
                                                bool isPresent=false;
                                                for(int i=0;i<value22.length;i++){
                                                  for(int j=0;j<value22[i].foodItems.length;j++){
                                                    if(value22[i].foodItems[j].serverId==foodItemsList[index].serverId){
                                                      isPresent=true;
                                                      break;
                                                    }
                                                  }
                                                  if(isPresent){
                                                    break;
                                                  }
                                                }
                                                if(isPresent){
                                                  Utility().showToastMessage("theItemMustBeNotOrdered".tr());

                                                }
                                                else{
                                                  FoodItemsDao().getFoodItemById(foodItemsList[index]!.id).then((value){
                                                    FoodItemsDao().delete(widget.foodCategoryModel,foodItemsList[index]).then((value11){
                                                      FoodItemApi().deleteFoodItem(value.serverId!);
                                                      setState(() {
                                                        getFoodItems();
                                                      });
                                                    });
                                                  });
                                                }

                                              });

                                            },
                                            subTitle: 'areYouSureToDeleteCategory'.tr(),
                                          );
                                        });
                                  }
                                  else if(action == FoodItemOptionMenuPopup.ACTIONS.ACTION_ACTIVATE_DEACTIVATE){
                                    if(foodItemsList[index].isActivated){

                                      foodItemsList[index].isActivated = false;
                                      setState(() {
                                        foodItemsList[index].isProductInStock = false;
                                          foodItemsList[index].isStockManagementActivated = false;
                                        FoodItemsDao().updateFoodItem(foodItemsList[index]);
                                      });
                                    }
                                    else{
                                      foodItemsList[index].isActivated = true;
                                    }
                                    FoodItemsDao().getFoodItemById(foodItemsList[index]!.id).then((value) {
                                      foodItemsList[index].serverId=value.serverId;
                                      // foodItemsList[index].isProductInStock=value.isProductInStock;
                                      FoodItemsDao().updateFoodItem(foodItemsList[index]).then((value1111){
                                        FoodItemApi().deactivateFoodItem(value.serverId!, foodItemsList[index].isActivated);
                                        setState(() {
                                          getFoodItems();
                                        });
                                      });
                                    });

                                  }
                                }, foodItemsModel: foodItemsList[index],);
                            });
                      });
                    },
                    onTap: () async {
                      /*Navigator.of(context).push(MaterialPageRoute(builder:
                            (context) => ContactList(returnContact: true,showAddButton: false,companyModel: companyList[index],contactListItemClickable:false,)));*/
                      await Navigator.of(context).push(
                          MaterialPageRoute(
                              builder: (context) =>
                                  AddFoodItem(
                                    widget.foodCategoryModel,
                                    existingFoodItemModel: foodItemsList[index],
                                  )
                          ));
                      setState(() {
                        getFoodItems();
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
                              //color: foodItemsList[index].isSyncedOnServer==false&&foodItemsList[index].isSyncOnServerProcessing==false?AppTheme.colorRed:Colors.white,
                              color: Colors.white,
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  foodItemsList[index].imagePath==null?SvgPicture.asset(AppImages.productIcon,
                                      height: 35):
                                  Image.file(File(foodItemsList[index].imagePath!),height: 35,width: 35,),
                                  if(foodItemsList[index].isSyncedOnServer==false&&foodItemsList[index].isSyncOnServerProcessing==false)...[
                                    Text("!",style: TextStyle(color: AppTheme.colorRed,fontSize: 28),),
                                  ],
                                  Padding(padding: EdgeInsets.only(top: 5,bottom: 5),
                                    child: VerticalDivider(color: Colors.black54,),
                                  )
                                ],
                              ),
                            ),

                            title:
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if(foodItemsList[index].description!=null&&foodItemsList[index].description.isEmpty)...[
                                  SizedBox(height: 10,)
                                ],
                                Text("${foodItemsList[index].name.toUpperCase()}",
                                  style: TextStyle(fontSize: 16),textAlign: TextAlign.start,),
                                if(foodItemsList[index].description!=null&&foodItemsList[index].description.isNotEmpty)...[
                                  SizedBox(height: 3,),
                                  Text("${foodItemsList[index].description}",
                                    style: TextStyle(fontSize: 10),),
                                ]
                                else...[
                                  SizedBox(height: 3,),
                                ],
                                SizedBox(height: 3,),
                                Container(

child:  SingleChildScrollView(
  scrollDirection: Axis.horizontal,
  child: Row(

    children: [

      Container(
        child: foodItemsList[index].price!=null?Text("price".tr()+": ${Utility().formatPrice(foodItemsList[index].price)}",
          style: TextStyle(fontSize: 11,fontWeight: FontWeight.bold),).tr():Container(),),
      Container(
          padding: EdgeInsets.only(left: 5,right: 5),
          child:
          //VerticalDivider(color: Colors.black54,width: 1,thickness: 1,),
          Container(
            width: 1,
            height: 12,
            color: AppTheme.colorGrey,
          )
      ),
      if(foodItemsList[index].isActivated&&foodItemsList[index].isStockManagementActivated!=null&&foodItemsList[index].isStockManagementActivated)...[
        Container(
          child: Text("quantity".tr()+": ${foodItemsList[index].dailyQuantityLimit==null?
          0:foodItemsList[index].dailyQuantityLimit}".tr(),
            style: TextStyle(fontSize: 11,fontWeight: FontWeight.bold),).tr(),),

        Container(
            padding: EdgeInsets.only(left: 5,right: 5),
            child:
            //VerticalDivider(color: Colors.black54,width: 1,thickness: 1,),
            Container(
              width: 1,
              height: 12,
              color: AppTheme.colorGrey,
            )
        ),
      ],
      // else ...[


      Container(
        /*child: Text("activated",
                                                style: TextStyle(fontSize: 12,fontWeight: FontWeight.bold),).tr(),*/
        width: 10,
        height: 10,
        margin: EdgeInsets.all(5),
        decoration: BoxDecoration(
            color: foodItemsList[index].isActivated?AppTheme.colorGreen:AppTheme.colorRed,
            shape: BoxShape.circle
        ),
      ),
      if(foodItemsList[index].isActivated)...[
        Container(
          width: MediaQuery.of(context).size.width*0.1,

          child: Text("activated",
            style: TextStyle(fontSize: 11,fontWeight: FontWeight.bold),).tr(),
        ),
      ]
      else...[
        Container(
          child: Text("deactivated",
            style: TextStyle(fontSize: 11,fontWeight: FontWeight.bold),).tr(),),
      ]
      // ]
    ],
  )
),

                                ),
                                if(foodItemsList[index].description!=null &&foodItemsList[index].description.isEmpty)...[
                                  SizedBox(height: 10,)
                                ],
                              ],
                            ),
                            trailing: Container(
                              width: MediaQuery.of(context).size.width*0.067,
                              child: Switch(

                                onChanged: (bool value) {
                                  if(!foodItemsList[index].isActivated){
                                    return;
                                    setState(() {
                                      foodItemsList[index].isProductInStock = false;
                                      if(value && foodItemsList[index].isStockManagementActivated){
                                        foodItemsList[index].isStockManagementActivated = false;
                                      }
                                      FoodItemsDao().updateFoodItem(foodItemsList[index]);
                                    });
                                  }
                                  else{
                                    setState((){
                                      foodItemsList[index].isProductInStock = value;
                                    });
                                    if(value){
                                      foodItemsList[index].dailyQuantityConsumed = 0;
                                    }
                                    FoodItemsDao().updateFoodItem(foodItemsList[index]).then((value){
                                      FoodItemApi().saveFoodItemToSever(foodItemsList[index],isUpdate:true);
                                    });

                                  }
                                },
                                value: foodItemsList[index].isProductInStock,
                                activeColor: AppTheme.colorRed,
                              ),
                            ),
                          ),
                        )
                    ),
                  ),
                )
            ),
            //      )
          ),
        ),
      )
            //: const Center(child: Text('No data found. Please click the add "+" button',style: TextStyle(fontSize: 16,fontWeight: FontWeight.bold),)) ,
            :  Center(child: Text("noDataFound".tr(),style: TextStyle(fontSize: 16),)) ,
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
                FoodItemsModel foodItemsModel = await Navigator.of(context).push(MaterialPageRoute(builder: (context)=>AddFoodItem(
                    widget.foodCategoryModel
                )));
                //if(companyModel!=null){
                getFoodItems();
                //}
              },
            ),
          ),
        ),
      ),
    );
  }
  List<AttributeCategoryModel> attributeCategoryList = [];
  // String selectedAttributeCategories = "";
  // attributeCategoryList.where((element) => element.isSelected).forEach((el) {
  // selectedAttributeCategories = selectedAttributeCategories+el.id.toString()+",";
  // });
  // if(selectedAttributeCategories.length>0){
  // selectedAttributeCategories = selectedAttributeCategories.substring(0,selectedAttributeCategories.length-1);
  // }
  /*deleteFoodItem(int serverId) async {
    final dio = Dio();
    dio.options.headers['X-TenantID'] = ServerData.OPTIFOOD_DATABASE.toString();
    await dio.delete(ServerData.OPTIFOOD_BASE_URL+"/api/item/${serverId}").then((value){
    });
  }
  deactivateFoodItem(int itemId, bool isActivated) async {
    final dio = Dio();
    dio.options.headers['X-TenantID'] = ServerData.OPTIFOOD_DATABASE.toString();
    await dio.put(ServerData.OPTIFOOD_BASE_URL+"/api/item/item-deactivate/${itemId}", queryParameters: {
      "deactivate":isActivated
    }).then((value){
    });

  }*/
  /*getFoodItemsListFromServer() async{
    List<FoodItemsModel> fetchedData = [];
    int j = 0;
    final dio = Dio();
    dio.options.headers['X-TenantID'] = "optifood";
    await dio.get(ServerData.OPTIFOOD_BASE_URL+'/api/item').then((response) {
      List<FoodItemsModel> fetchedData = [];
      if (response.statusCode == 200) {
        for (int i = 0; i < response.data.length; i++) {
          var singleItem = FoodItemsModel.fromJsonServer(response.data[i]);
          fetchedData.add(singleItem);
        }
        for(int i=0; i<fetchedData.length;i++){
          FoodItemsDao().getFoodItemByName(fetchedData[i].name).then((value) {
            if(value.length>0){
              FoodItemsDao().updateFoodItem(value![value.length-1]!).then((res1) {
                if(i==fetchedData.length-1){
                }
              });
            }
            else {
              FoodItemsModel foodItemsModel = FoodItemsModel(
                1,
                fetchedData[i].name,
                fetchedData[i].displayName,
                fetchedData[i].description,
                fetchedData[i].allergence,
                fetchedData[i].price,
                imagePath: fetchedData[i].imagePath,
                // isEnablePricePerOrderType: fetchedData[i]
                //     .isEnablePricePerOrderType,
                categoryID: fetchedData[i].categoryID,
                eatInPrice: fetchedData[i].eatInPrice,
                deliveryPrice: fetchedData[i].deliveryPrice,
                isAttributeMandatory: fetchedData[i].isAttributeMandatory,
                isProductInStock: fetchedData[i].isProductInStock,
                // isStockManagementActivated: fetchedData[i]
                //     .isStockManagementActivated,
                // dailyQuantityLimit: fetchedData[i].dailyQuantityLimit,
                color: fetchedData[i].color,
                isHideInKitchen: fetchedData[i].isHideInKitchen,
                // attributeCategoryIds: fetchedData[i].attributeCategoryIds
              );
              String name;
              String displayName;
              String color;
              int position;
              String? imagePath;
              bool isHideInKitchen;
              bool isAttributeMandatory;
              int foodItemsCount;
              FoodCategoryModel foodCategoryModel=FoodCategoryModel(1, "", "", "", 0,false,false,"");
              FoodItemsDao().insertFoodItem(
                  foodCategoryModel, foodItemsModel).then((res2) {
                if (i == fetchedData.length - 1) {
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
