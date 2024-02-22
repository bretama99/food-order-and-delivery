import 'dart:async';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:fbroadcast/fbroadcast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:opti_food_app/api/food_category_api.dart';
import 'package:opti_food_app/data_models/company_model.dart';
import 'package:opti_food_app/data_models/contact_model.dart';
import 'package:opti_food_app/data_models/food_category_model.dart';
import 'package:opti_food_app/database/company_dao.dart';
import 'package:opti_food_app/database/contact_dao.dart';
import 'package:opti_food_app/database/food_category_dao.dart';
import 'package:opti_food_app/screens/products/add_food_category.dart';
import 'package:opti_food_app/screens/products/food_item_list.dart';
import 'package:opti_food_app/utils/constants.dart';
import 'package:opti_food_app/utils/utility.dart';
import 'package:opti_food_app/widgets/appbar/app_bar_optifood.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../assets/images.dart';
import '../../widgets/app_theme.dart';
import '../../widgets/option_menu/company/company_option_menu_popup.dart';
import '../../widgets/popup/confirmation_popup/confirmation_popup.dart';
import 'package:path_provider/path_provider.dart' as pathProvider;
import 'package:path/path.dart' as path;
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import '../MountedState.dart';

class FoodCategoryList extends StatefulWidget {
  static String searchQuery = "";
  @override
  State<FoodCategoryList> createState() => _FoodCategoryState();

}
class _FoodCategoryState extends MountedState<FoodCategoryList> with WidgetsBindingObserver {
  late AppBarOptifood appBarOptifood;
  FocusNode focusNode = FocusNode();
  List<FoodCategoryModel> foodCategoryList = [];
  void getFoodCategories() async {
    FoodCategoryDao().getAllFoodCategories().then((value){
      setState((){
        if(FoodCategoryList.searchQuery.length>0){
          foodCategoryList = value.where((element) => (element.name).toLowerCase().
          contains(FoodCategoryList.searchQuery.toLowerCase())).toList();
        }
        else{
          foodCategoryList = value;
        }
      });
    });
  }
  @override
  void initState() {
    appBarOptifood = AppBarOptifood(isShowSearchBar: true,onSearch: (search){
      FoodCategoryList.searchQuery = search;
      setState(() {
        getFoodCategories();
        // getFoodCategoryListFromServer();
      });
    },);
    WidgetsBinding.instance!.addObserver(this);
    getFoodCategories();
    FBroadcast.instance().register(ConstantBroadcastKeys.KEY_UPDATE_UI, (value, callback) {
      getFoodCategories();
    });
    super.initState();
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
    //Utility().showToastMessage("changed");
    //Utility().showToastMessage(state.name);
    switch(state){
      case AppLifecycleState.detached:
        break;
      case AppLifecycleState.paused:
        //Utility().showToastMessage("State changed");
        appBarOptifood.closeSearchBar();
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLandscape = MediaQuery.of(context).orientation == Orientation.landscape;
    return Scaffold(
      appBar: appBarOptifood,
      body: foodCategoryList.length>0?Padding(
        padding: const EdgeInsets.only(top: 3),
        child: Container(
          child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(3, 0, 3, 0),
                child: ListView.builder(
                    itemCount: foodCategoryList.length,
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
                                                      AddFoodCategory(
                                                        existingFoodCategoryModel: foodCategoryList[index],
                                                      )
                                              ));
                                          setState(() {
                                            getFoodCategories();
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
                                                  titleImageBackgroundColor: AppTheme.colorRed,
                                                  positiveButtonPressed: () async {
                                                    if (foodCategoryList[index].foodItemsCount == 0) {
                                                      FoodCategoryDao().getFoodCategoryById(foodCategoryList[index].id).then((value) {
                                                        FoodCategoryDao().delete(
                                                          foodCategoryList[index]).then((value11) {
                                                          FoodCategoryApi().deleteCategory(value.serverId!);
                                                          setState(() {
                                                            getFoodCategories();
                                                          });
                                                        });
                                                      });
                                                    }
                                                    else{
                                                      Utility().showToastMessage("theCategoryMustBeEmptyToBeDeleted".tr());
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
                            (context) => FoodItemList(foodCategoryList[index])));
                        setState(() {
                          getFoodCategories();
                        });
                      },
                      child:
                      Container(
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
                                  //color: foodCategoryList[index].isSyncedOnServer==false&&foodCategoryList[index].isSyncOnServerProcessing==false?AppTheme.colorRed:Colors.white,
                                  color: Colors.white,
                                  //child: SvgPicture.asset(AppImages.clientInfoIcon,
                                  child: foodCategoryList[index].imagePath==null?SvgPicture.asset(AppImages.productIcon,
                                      height: 35):
                                  /*CircleAvatar(
                                    backgroundImage: FileImage(File(foodCategoryList[index].imagePath!)),
                                    radius: 35,
                                  ),*/
                                  // Image.network(
                                  //   'http://192.168.1.101/attribute_category_images/${foodCategoryList[index].imagePath!}',
                                  //   fit:BoxFit.cover,
                                  // ),
                                  Image.file(File(foodCategoryList[index].imagePath.toString()!),height: 35,),
                                ),
                              ),
                              if(foodCategoryList[index].isSyncedOnServer==false&&foodCategoryList[index].isSyncOnServerProcessing==false)...[
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
                                        child: Text("${foodCategoryList[index].name.toUpperCase()}",
                                          style: TextStyle(fontWeight: FontWeight.bold,fontSize: 18),)),
                                    subtitle: Text(foodCategoryList[index].foodItemsCount.toString()+" product(s)".tr(),style: TextStyle(fontSize: 14),),
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
      ):  Center(child: Text("noDataFound".tr(),style: TextStyle(fontSize: 16),)),
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
                FoodCategoryModel foodCategoryModel = await Navigator.of(context).push(MaterialPageRoute(builder: (context)=>AddFoodCategory()));
                //if(companyModel!=null){
                getFoodCategories();
              },
            ),
          ),
        ),
      ),
    );
  }

  /*static deleteCategory(int serverId) async {
    final dio = Dio();
    dio.options.headers['X-TenantID'] = ServerData.OPTIFOOD_DATABASE.toString();
    await dio.delete(ServerData.OPTIFOOD_BASE_URL+"/api/item-category/${serverId}").then((value){
    });
  }
  getFoodCategoryListFromServer() async {
    final dio = Dio();
    List<FoodCategoryModel> fetchedData = [];
    dio.options.headers['X-TenantID'] = ServerData.OPTIFOOD_DATABASE;
    await dio.get(ServerData.OPTIFOOD_BASE_URL+"/api/item-category").then((response) async {
      List<FoodCategoryModel> fetchedData = [];
      if (response.statusCode == 200) {
        for (int i = 0; i < response.data.length; i++) {
          var singleItem = FoodCategoryModel.fromJsonServer(response.data[i]);
          fetchedData.add(singleItem);
        }
        for (int i = 0; i < fetchedData.length; i++) {
          var imgUrl = ServerData.OPTIFOOD_IMAGES+"/item_category_images/"+fetchedData[i].imagePath.toString();
          final response1 = await http.get(Uri.parse(imgUrl));

          final imageName = path.basename(imgUrl);

          if(imageName=='null'){
            FoodCategoryDao().getFoodCategoryByServerId(fetchedData[i].serverId!).then((
                value) {

              FoodCategoryModel foodCategoryModel = FoodCategoryModel(
                  fetchedData[i].id,
                  fetchedData[i].name,
                  fetchedData[i].displayName,
                  fetchedData[i].color,
                  1,
                  fetchedData[i].isHideInKitchen,
                  fetchedData[i].isAttributeMandatory,
                  null,
                  serverId: fetchedData[i].serverId,
                  foodItemsCount:fetchedData[i].foodItemsCount
              );
              if (value!=null) {
                setState((){
                  FoodCategoryDao()
                      .updateFoodCategory(foodCategoryModel)
                      .then((res1) {
                    if (i == fetchedData.length - 1) {
                    }
                  });
                });

              }
              else {
                 setState(() {
                   FoodCategoryDao().insertFoodCategory(foodCategoryModel).then((
                       res2) {
                     if (i == fetchedData.length - 1) {
                     }
                   });
                 });

              }
            });

          }
          else{
            final documentDirectory1 = await getApplicationDocumentsDirectory();
            final localPath = path.join(documentDirectory1.path, imageName);
            final imageFile = File(localPath);
            await imageFile.writeAsBytes(response1.bodyBytes).then((value222){
              var image = imageFile.toString().substring(8, imageFile.toString().length - 1);
              fetchedData[i].imagePath=image;
              FoodCategoryDao().getFoodCategoryByServerId(fetchedData[i].serverId!).then((
                  value) {
                FoodCategoryModel foodCategoryModel = FoodCategoryModel(
                    fetchedData[i].id,
                    fetchedData[i].name,
                    fetchedData[i].displayName,
                    fetchedData[i].color,
                    1,
                    fetchedData[i].isHideInKitchen,
                    fetchedData[i].isAttributeMandatory,
                    fetchedData[i].imagePath,
                    serverId: fetchedData[i].serverId,
                    foodItemsCount:fetchedData[i].foodItemsCount
                );
                if (value !=null) {
                  setState(() {
                    FoodCategoryDao()
                        .updateFoodCategory(foodCategoryModel)
                        .then((res1) {
                      if (i == fetchedData.length - 1) {
                      }
                    });
                  });

                }
                else {
                  setState(() {
                    FoodCategoryDao().insertFoodCategory(foodCategoryModel).then((
                        res2) {
                      if (i == fetchedData.length - 1) {
                      }
                    });
                  });

                }
              });
            });
          }
        }
      }
    }).catchError((onError){
    });
  }*/

  // getFoodCategoryListFromServer() async{
  //   List<FoodCategoryModel> fetchedData = [];
  //   dio.options.headers['X-TenantID'] = AppConfig.databaseName;
  //   await dio.get(CategoryAPI.GET_ALL_API).then((response) async {
  //   int j = 0;
  //   dio.options.headers['X-TenantID'] = AppConfig.databaseName;
  //   await dio.get(CategoryAPI.GET_ALL_API).then((response) {
  //     List<FoodCategoryModel> fetchedData = [];
  //     if (response.statusCode == 200) {
  //       for (int i = 0; i < response.data.length; i++) {
  //         var singleItem = FoodCategoryModel.fromJsonServer(response.data[i]);
  //         fetchedData.add(singleItem);
  //       }
  //       for(int i=0; i<fetchedData.length;i++){
  //         FoodCategoryDao().getFoodCategoryByName(fetchedData[i].name).then((value) {
  //           if(value.length>0){
  //             FoodCategoryDao().updateFoodCategory(value[value.length-1]).then((res1) {
  //
  //               if(i==fetchedData.length-1){
  //                 getFoodCategories();
  //               }
  //             });
  //           }
  //           else{
  //             FoodCategoryModel foodCategoryModel = FoodCategoryModel(
  //                 1,
  //                 fetchedData[i].name,
  //                 fetchedData[i].displayName,
  //                 fetchedData[i].color,
  //                 1,
  //                 fetchedData[i].isHideInKitchen,
  //                 fetchedData[i].isAttributeMandatory,
  //                 fetchedData[i].imagePath
  //             );
  //
  //             FoodCategoryDao().insertFoodCategory(foodCategoryModel).then((res2){
  //               if(i==fetchedData.length-1){
  //                 getFoodCategories();
  //               }
  //             });
  //           }
  //         });
  //       }
  //     }
  //   });
  // });
  // }
  //
  // getFoodItemsListFromServer() async{
  //   List<FoodItemsModel> fetchedData = [];
  //   int j = 0;
  //   dio.options.headers['X-TenantID'] = AppConfig.databaseName;
  //   await dio.get(ItemAPI.GET_ALL_API).then((response) {
  //     List<FoodItemsModel> fetchedData = [];
  //     if (response.statusCode == 200) {
  //       for (int i = 0; i < response.data.length; i++) {
  //         var singleItem = FoodItemsModel.fromJsonServer(response.data[i]);
  //         fetchedData.add(singleItem);
  //       }
  //       for(int i=0; i<fetchedData.length;i++){
  //         FoodItemsDao().getFoodItemByName(fetchedData[i].name).then((value) async {
  //           if(value.length>0){
  //             FoodItemsDao().updateFoodItem(value[value.length-1]).then((res1) {
  //               if(i==fetchedData.length-1){
  //                 // getFoodItems();
  //               }
  //             });
  //           }
  //           else {
  //             FoodItemsModel foodItemsModel = FoodItemsModel(
  //                 1,
  //                 fetchedData[i].name,
  //                 fetchedData[i].displayName,
  //                 fetchedData[i].description,
  //                 fetchedData[i].allergence,
  //                 fetchedData[i].price,
  //                 imagePath: fetchedData[i].imagePath,
  //                 isEnablePricePerOrderType: fetchedData[i]
  //                     .isEnablePricePerOrderType,
  //                 categoryID: fetchedData[i].categoryID,
  //             );
  //
  //             FoodCategoryDao().getFoodCategoryById(fetchedData[i].categoryID).then((values) async {
  //               FoodCategoryModel foodCategoryModel = FoodCategoryModel(
  //                   fetchedData[i].id,
  //                   values.name,
  //                   values.displayName,
  //                   values.color,
  //                   1,
  //                   values.isHideInKitchen,
  //                   values.isAttributeMandatory,
  //                   values.imagePath
  //               );
  //              await FoodItemsDao().insertFoodItem(
  //                   foodCategoryModel, foodItemsModel).then((res2) {
  //                 if (i == fetchedData.length - 1) {
  //                   getFoodCategoryListFromServer();
  //                   // getFoodItems();
  //                 }
  //               });
  //             });
  //
  //           }
  //         });
  //       }
  //     }
  //   });
  // }


}
