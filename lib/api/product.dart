import 'dart:io';
import 'package:path/path.dart';
import 'package:dio/dio.dart';
import 'package:opti_food_app/database/food_category_dao.dart';
import 'package:path_provider/path_provider.dart';
import '../../data_models/attribute_category_model.dart';
import '../../data_models/food_category_model.dart';
import '../../database/attribute_category_dao.dart';
import '../../utils/constants.dart';
import '../data_models/attribute_model.dart';
import '../data_models/food_items_model.dart';
import '../database/attribute_dao.dart';
import '../database/food_items_dao.dart';
import '../main.dart';
import '../utils/api/category.dart';
import 'package:path_provider/path_provider.dart' as pathProvider;
import 'package:path/path.dart' as path;
import 'package:http/http.dart' as http;


class ProductApis {
  static String OPTIFOOD_DATABASE=optifoodSharedPrefrence.getString("database").toString();
  static String authorization = optifoodSharedPrefrence.getString("accessToken").toString();
  /*static getAttributeCategoryListFromServer() async{
    List<AttributeCategoryModel> fetchedData = [];
    final dio = Dio();
    dio.options.headers['X-TenantID'] = OPTIFOOD_DATABASE;
    await dio.get(ServerData.OPTIFOOD_BASE_URL+"/api/attribute-category").then((response) async {
      List<AttributeCategoryModel> fetchedData = [];
      if (response.statusCode == 200) {
        for (int i = 0; i < response.data.length; i++) {
          var singleItem = AttributeCategoryModel.fromJsonServer(response.data[i]);
          fetchedData.add(singleItem);
        }
        for(int i=0; i<fetchedData.length;i++){

          var imgUrl = ServerData.OPTIFOOD_IMAGES+"/attribute_category_images/"+fetchedData[i].imagePath.toString();
          final response1 = await http.get(Uri.parse(imgUrl));
          final imageName = path.basename(imgUrl);
          if(imageName=='null'){
            AttributeCategoryDao().getAttributeCategoryByServerId(fetchedData[i].serverId!).then((value) {
              AttributeCategoryModel attributeCategoryModel = AttributeCategoryModel(
                1,
                fetchedData[i].name,
                fetchedData[i].displayName,
                fetchedData[i].color,
                fetchedData[i].position,
                null,
                attributeCount: fetchedData[i].attributeCount,
                serverId: fetchedData[i].serverId,
              );
              if(value!=null){
                value.name=fetchedData[i].name;
              value.displayName=fetchedData[i].displayName;
              value.color=fetchedData[i].color;
              value.position=fetchedData[i].position;
              value.attributeCount=fetchedData[i].attributeCount;
              value.serverId=fetchedData[i].serverId;
                AttributeCategoryDao().updateAttributeCategory(value).then((res1) {
                  if(i==fetchedData.length-1){
                  }
                });
              }
              else{

                AttributeCategoryDao().insertAttributeCategory(attributeCategoryModel).then((res2){
                  if(i==fetchedData.length-1){
                  }
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
              AttributeCategoryDao().getAttributeCategoryByServerId(fetchedData[i].serverId!).then((value) {

                AttributeCategoryModel attributeCategoryModel = AttributeCategoryModel(
                  1,
                  fetchedData[i].name,
                  fetchedData[i].displayName,
                  fetchedData[i].color,
                  fetchedData[i].position,
                  fetchedData[i].imagePath,
                  attributeCount: fetchedData[i].attributeCount,
                  serverId: fetchedData[i].serverId,
                );
                if(value!=null){
                  value.name=fetchedData[i].name;
                  value.displayName=fetchedData[i].displayName;
                  value.color=fetchedData[i].color;
                  value.position=fetchedData[i].position;
                  value.attributeCount=fetchedData[i].attributeCount;
                  value.serverId=fetchedData[i].serverId;
                  AttributeCategoryDao().updateAttributeCategory(value).then((res1) {
                    if(i==fetchedData.length-1){
                    }
                  });
                }
                else{
                  AttributeCategoryDao().insertAttributeCategory(attributeCategoryModel).then((res2){
                    if(i==fetchedData.length-1){
                    }
                  });
                }
              });
            });
          }

        }
      }
    });
  }*/

  /*static getAttributeListFromServer() async{
    List<AttributeModel> fetchedData = [];
    final dio = Dio();
    dio.options.headers['X-TenantID'] = OPTIFOOD_DATABASE;
    await dio.get(ServerData.OPTIFOOD_BASE_URL+"/api/attribute").then((response) async {
      if (response.statusCode == 200) {
        for (int i = 0; i < response.data.length; i++) {
          var singleItem = AttributeModel.fromJsonServer(response.data[i]);
          fetchedData.add(singleItem);
        }

        for(int i=0; i<fetchedData.length;i++){
          var imgUrl = ServerData.OPTIFOOD_IMAGES+"/attributes/"+fetchedData[i].imagePath.toString();
          final response1 = await http.get(Uri.parse(imgUrl));
          final imageName = path.basename(imgUrl);
          if(imageName=='null'){
            AttributeDao().getAttributeByServerId(fetchedData[i].serverId!).then((value) {
              AttributeModel attributeModel = AttributeModel(
                fetchedData[i].id,
                fetchedData[i].name,
                fetchedData[i].displayName,
                fetchedData[i].price,
                categoryID: fetchedData[i].categoryID,
                catServerId: fetchedData[i].categoryID,
                color: fetchedData[i].color,
                imagePath: null,
                serverId: fetchedData[i].serverId,
                // catServerId: fetchedData[i].serverId,

              );
              if(value!=null){
                value.categoryID=fetchedData[i].categoryID;
              value.name=fetchedData[i].name;
              value.displayName=fetchedData[i].displayName;
              value.price=fetchedData[i].price;
              value.catServerId=fetchedData[i].catServerId;
              value.color=fetchedData[i].color;
              value.serverId=fetchedData[i].serverId;
                AttributeDao().updateAttribute(value).then((res1) {
                  if(i==fetchedData.length-1){
                  }
                });
              }
              else{
                AttributeCategoryModel attributeCategoryModel=AttributeCategoryModel(0, "", "", "", 0, "");
                AttributeDao().insertAttribute(attributeCategoryModel,attributeModel).then((res2){
                  if(i==fetchedData.length-1){
                  }
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
              AttributeDao().getAttributeByServerId(fetchedData[i].serverId!).then((value) {
                AttributeModel attributeModel = AttributeModel(
                  fetchedData[i].categoryID,
                  fetchedData[i].name,
                  fetchedData[i].displayName,
                  fetchedData[i].price,
                  categoryID: fetchedData[i].categoryID,
                  catServerId: fetchedData[i].catServerId,
                  color: fetchedData[i].color,
                  imagePath: fetchedData[i].imagePath,
                  serverId: fetchedData[i].serverId,

                );
                if(value!=null){
                  value.categoryID=fetchedData[i].categoryID;
                  value.name=fetchedData[i].name;
                  value.displayName=fetchedData[i].displayName;
                  value.price=fetchedData[i].price;
                  value.categoryID=fetchedData[i].categoryID;
                  value.catServerId=fetchedData[i].catServerId;
                  value.color=fetchedData[i].color;
                  value.serverId=fetchedData[i].serverId;
                  AttributeDao().updateAttribute(value).then((res1) {
                    if(i==fetchedData.length-1){
                    }
                  });
                }
                else{
                  AttributeCategoryModel attributeCategoryModel=AttributeCategoryModel(0, "", "", "", 0, "");
                  AttributeDao().insertAttribute(attributeCategoryModel,attributeModel).then((res2){
                    if(i==fetchedData.length-1){
                    }
                  });
                }
              });
            });
          }
        }
      }
    });
  }*/
  /*static getFoodItemsListFromServer() async{
    List<FoodItemsModel> fetchedData = [];
    int j = 0;
    final dio = Dio();
    var aa = ServerData.OPTIFOOD_BASE_URL+'/api/item';
    print("mmmmmmmmmmServerData.OPTIFOOD_BASE_URaaLmmmmmmmmmmmm${aa}mmmmmmmmmmmmmmmmmmmmmtest in before");

    dio.options.headers['X-TenantID'] = OPTIFOOD_DATABASE;
    await dio.get(ServerData.OPTIFOOD_BASE_URL+'/api/item').then((response) async {

      print("mmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmtest in response");
      List<FoodItemsModel> fetchedData = [];
      if (response.statusCode == 200) {
        for (int i = 0; i < response.data.length; i++) {
          var singleItem = FoodItemsModel.fromJsonServer(response.data[i]);
          fetchedData.add(singleItem);
        }
        for(int i=0; i<fetchedData.length;i++){
          print("=============================${fetchedData[i].isHideInKitchen}====================================================");
          if(fetchedData[i].deliveryPrice!=0 &&fetchedData[i].deliveryPrice!=null && fetchedData[i].eatInPrice!=0 &&fetchedData[i].eatInPrice!=null){
            fetchedData[i].isEnablePricePerOrderType=true;
          }
          else{
            fetchedData[i].isEnablePricePerOrderType=false;
          }

          var imgUrl = ServerData.OPTIFOOD_IMAGES+"/items/"+fetchedData[i].imagePath.toString();
          final response1 = await http.get(Uri.parse(imgUrl));
          final imageName = path.basename(imgUrl);

          if(imageName=='null'){
            FoodItemsDao().getFoodItemByServerId(fetchedData[i].serverId!).then((value) {
              FoodItemsModel foodItemsModel = FoodItemsModel(
                fetchedData[i].id,
                fetchedData[i].name,
                fetchedData[i].displayName,
                fetchedData[i].description,
                fetchedData[i].allergence,
                fetchedData[i].price,
                imagePath: null,
                isEnablePricePerOrderType:  fetchedData[i].isEnablePricePerOrderType,
                //     .isEnablePricePerOrderType,
                categoryID: fetchedData[i].categoryID,
                eatInPrice: fetchedData[i].eatInPrice,
                deliveryPrice: fetchedData[i].deliveryPrice,
                isAttributeMandatory: fetchedData[i].isAttributeMandatory,
                // isProductInStock: fetchedData[i].isProductInStock,
                // isStockManagementActivated: fetchedData[i]
                //     .isStockManagementActivated,
                // dailyQuantityLimit: fetchedData[i].dailyQuantityLimit,
                color: fetchedData[i].color,
                position:fetchedData[i].position,
                isHideInKitchen: fetchedData[i].isHideInKitchen,
                serverId: fetchedData[i].serverId,
                catServerId: fetchedData[i].categoryID,
                isActivated: fetchedData[i].isActivated,
                // attributeCategoryIds: fetchedData[i].attributeCategoryIds
              );
              if(value!=null){
                value.name=fetchedData[i].name;
                value.serverId=fetchedData[i].serverId;
                value.description=fetchedData[i].description;
                value.displayName = fetchedData[i].displayName;
                value.categoryID=fetchedData[i].categoryID;
              value.eatInPrice=fetchedData[i].eatInPrice;
              value.deliveryPrice=fetchedData[i].deliveryPrice;
                value.allergence=fetchedData[i].allergence;
                value.isEnablePricePerOrderType=fetchedData[i].isEnablePricePerOrderType;

              value.price=fetchedData[i].price;
                value.position=fetchedData[i].position;
                value.displayName = fetchedData[i].displayName;
                value.catServerId = fetchedData[i].catServerId;
              value.color = fetchedData[i].color;
                value.isHideInKitchen=fetchedData[i].isHideInKitchen;
                value.isAttributeMandatory = fetchedData[i].isAttributeMandatory;
                value.isActivated = fetchedData[i].isActivated;
                FoodItemsDao().updateFoodItem(value).then((res1) {
                  if(i==fetchedData.length-1){
                  }
                });
              }
              else {
                FoodCategoryModel foodCategoryModel=FoodCategoryModel(0, "", "", "", 0,false,false,"");
                FoodItemsDao().insertFoodItem(
                    foodCategoryModel, foodItemsModel).then((res2) {
                  if (i == fetchedData.length - 1) {
                  }
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
              FoodItemsDao().getFoodItemByServerId(fetchedData[i].serverId!).then((value) {
                FoodItemsModel foodItemsModel = FoodItemsModel(
                  fetchedData[i].id,
                  fetchedData[i].name,
                  fetchedData[i].displayName,
                  fetchedData[i].description,
                  fetchedData[i].allergence,
                  fetchedData[i].price,
                  imagePath: fetchedData[i].imagePath,
                  isEnablePricePerOrderType:  fetchedData[i].isEnablePricePerOrderType,
                  // isEnablePricePerOrderType: fetchedData[i]
                  //     .isEnablePricePerOrderType,
                  categoryID: fetchedData[i].categoryID,
                  eatInPrice: fetchedData[i].eatInPrice,
                  deliveryPrice: fetchedData[i].deliveryPrice,
                  isAttributeMandatory: fetchedData[i].isAttributeMandatory,
                  // isProductInStock: fetchedData[i].isProductInStock,
                  // isStockManagementActivated: fetchedData[i]
                  //     .isStockManagementActivated,
                  // dailyQuantityLimit: fetchedData[i].dailyQuantityLimit,
                  color: fetchedData[i].color,
                  isHideInKitchen: fetchedData[i].isHideInKitchen,
                  serverId: fetchedData[i].serverId,
                  catServerId: fetchedData[i].catServerId,
                  isActivated: fetchedData[i].isActivated,

                  // attributeCategoryIds: fetchedData[i].attributeCategoryIds
                );
                if(value!=null){
                  value.name=fetchedData[i].name;
                  value.serverId=fetchedData[i].serverId;
                  value.description=fetchedData[i].description;
                  value.displayName = fetchedData[i].displayName;
                  value.categoryID=fetchedData[i].categoryID;
                  value.eatInPrice=fetchedData[i].eatInPrice;
                  value.deliveryPrice=fetchedData[i].deliveryPrice;
                  value.allergence=fetchedData[i].allergence;
                  value.price=fetchedData[i].price;
                  value.isEnablePricePerOrderType=fetchedData[i].isEnablePricePerOrderType;

                value.displayName = fetchedData[i].displayName;
                  value.catServerId = fetchedData[i].catServerId;
                  value.color = fetchedData[i].color;
                  value.isHideInKitchen=fetchedData[i].isHideInKitchen;
                  value.isAttributeMandatory = fetchedData[i].isAttributeMandatory;
                  value.isActivated = fetchedData[i].isActivated;
                  FoodItemsDao().updateFoodItem(value).then((res1) {
                    if(i==fetchedData.length-1){
                    }
                  });
                }
                else {
                  FoodCategoryModel foodCategoryModel=FoodCategoryModel(0, "", "", "", 0,false,false,"");
                  FoodItemsDao().insertFoodItem(
                      foodCategoryModel, foodItemsModel).then((res2) {
                    if (i == fetchedData.length - 1) {
                    }
                  });
                }
              });
            });
          }

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

  /*static getFoodCategoryListFromServer() async {
    final dio = Dio();
    List<FoodCategoryModel> fetchedData = [];
    dio.options.headers['X-TenantID'] = OPTIFOOD_DATABASE;
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
                value.name=fetchedData[i].name;
                value.serverId=fetchedData[i].serverId;
                value.foodItemsCount=fetchedData[i].foodItemsCount;
                value.displayName = fetchedData[i].displayName;
                value.color = fetchedData[i].color;
                value.isHideInKitchen=fetchedData[i].isHideInKitchen;
                value.isAttributeMandatory = fetchedData[i].isAttributeMandatory;
              FoodCategoryDao()
                    .updateFoodCategory(value)
                    .then((res1) {
                  if (i == fetchedData.length - 1) {
                  }
                });
              }
              else {

                FoodCategoryDao().insertFoodCategory(foodCategoryModel).then((
                    res2) {
                  if (i == fetchedData.length - 1) {
                  }
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
                if (value!=null) {
                  value.name=fetchedData[i].name;
                  value.serverId=fetchedData[i].serverId;
                  value.foodItemsCount=fetchedData[i].foodItemsCount;
                  value.displayName = fetchedData[i].displayName;
                  value.color = fetchedData[i].color;
                  value.isHideInKitchen=fetchedData[i].isHideInKitchen;
                  value.isAttributeMandatory = fetchedData[i].isAttributeMandatory;
                  FoodCategoryDao()
                      .updateFoodCategory(value)
                      .then((res1) {
                    if (i == fetchedData.length - 1) {
                    }
                  });
                }
                else {

                  FoodCategoryDao().insertFoodCategory(foodCategoryModel).then((
                      res2) {
                    if (i == fetchedData.length - 1) {
                    }
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

  static saveAttributeCategoryToSever(var _image, String fileName)async{
    final dio = Dio();
    dio.options.headers['X-TenantID'] = OPTIFOOD_DATABASE;

    AttributeCategoryDao().getAttributeCategory().then((value) async{
      var formData;
      if(_image==null) {
        formData = FormData.fromMap({
          'attributeCategoryName': value.name,
          'color': value.color,
          'position': value.position,
        });
      }
      else{
        formData = FormData.fromMap({
          'attributeCategoryName': value.name,
          'color': value.color,
          'position': value.position,
          'image': MultipartFile.fromBytes(_image.readAsBytesSync(), filename: fileName),
        });
      }
      var response = await dio.post(ServerData.OPTIFOOD_BASE_URL+'/api/attribute-category',
        data: formData,
      ).then((response){
        var singleData = AttributeCategoryModel.fromJsonServer(response.data);
        value.isSyncedOnServer=true;
        value.serverId=singleData.serverId;
        AttributeCategoryDao().updateAttributeCategory(value);
      }).catchError((onError){

      });
    });
  }

  static saveAttributeToSever(var _image, String fileName)async{
    final dio = Dio();
    dio.options.headers['X-TenantID'] = OPTIFOOD_DATABASE;
    AttributeDao().getAttribute().then((value) async{
      var formData;
      if(_image==null) {

        formData = FormData.fromMap({
          'attributeCategoryId': value.categoryID,
          'name': value.name,
          'position': value.position,
          'color': value.color,
          "price":value.price,
          // 'attributePriceId': value.price,
          // 'attributePriceResponseModel': {},
          // 'description': "",
          'displayName': value.displayName,
          // 'status': "Active",
        });
      }
      else{
        formData = FormData.fromMap({
          'attributeCategoryId': value.categoryID,
          'name': value.name,
          'position': value.position,
          'color': value.color,
          "price":value.price,
          'displayName': value.displayName,
          'image': MultipartFile.fromBytes(
              _image.readAsBytesSync(), filename: fileName),
        });
      }
      var response = await dio.post(ServerData.OPTIFOOD_BASE_URL+"/api/attribute",
        data: formData,
      ).then((response){
        var singleData = AttributeModel.fromJsonServer(response.data);
        //value.isSynced=true;
        value.serverId=singleData.serverId;
        AttributeDao().updateAttribute(value);
      }).catchError((onError){

      });
    });
  }
 static saveFoodCategoryToSever(var _image, String fileName)async{
   final dio = Dio();
   dio.options.headers['X-TenantID'] = OPTIFOOD_DATABASE;
   dio.options.headers['Authorization'] = authorization;
   FoodCategoryDao().getFoodCategory().then((value) async{
     var formData = FormData.fromMap({
       'itemCategoryName': value.name,
       'displayName':value.displayName,
       'color': value.color,
       'position': value.position,
       'image': MultipartFile.fromBytes(_image.readAsBytesSync(), filename: fileName),
       "isAttributeRequired":value.isAttributeMandatory,
       "isShowKichen":value.isHideInKitchen
     });
     var response = await dio.post(ServerData.OPTIFOOD_BASE_URL+"/api/item-category",
       data: formData,
     ).then((value){
     }).catchError((onError){
     });
   });
 }

  static saveFoodItemToSever(var _image, String fileName) async{
    final dio = Dio();
    dio.options.headers['X-TenantID'] = OPTIFOOD_DATABASE;
    dio.options.headers['Authorization'] = authorization;
    FoodItemsDao().getFoodItem().then((value) async{
      var formData = FormData.fromMap({
        'categoryId': value.categoryID,
        "itemPriceId":1,
        'itemName': value.name,
        'displayName':value.displayName,
        'color': "red",
        'position': value.position,
        "quantity":value.quantity,
        'image': MultipartFile.fromBytes(_image.readAsBytesSync(), filename: fileName),
        "isAttributeRequired":value.isAttributeMandatory,
        "isShowKichen":value.isHideInKitchen,
        "allergence":value.allergence,
        "eatInPrice": value.eatInPrice,
        "defaultPrice": value.price,
        "deliveryPrice": value.deliveryPrice,
        "eatInNightModePrice": 1,
        "eatInDefaultModePrice":5,
        "deliveryNightModePrice":89
      });
      var response = await dio.post(ServerData.OPTIFOOD_BASE_URL+'/api/item',
        data: formData,
      ).then((value1) async {

      }).catchError((onError){

      });
    });
  }

}