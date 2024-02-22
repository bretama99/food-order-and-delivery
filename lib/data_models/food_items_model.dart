import 'package:flutter/material.dart';
import 'package:opti_food_app/database/food_items_dao.dart';

import '../database/order_dao.dart';
import 'attribute_model.dart';

class FoodItemsModel{
  int id; //saved in food_item_dao
  int categoryID; //saved in food_item_dao
  String name; //saved in food_item_dao
  String displayName; //saved in food_item_dao
  String description; //saved in food_item_dao
  String allergence; //saved in food_item_dao
  bool isEnablePricePerOrderType; //saved in food_item_dao
  double price; //saved in food_item_dao
  double eatInPrice; //saved in food_item_dao
  double deliveryPrice; //saved in food_item_dao
  bool isHideInKitchen; //saved in food_item_dao
  String color; //saved in food_item_dao
  bool isAttributeMandatory; //saved in food_item_dao
  String attributeCategoryIds; //saved in food_item_dao
  //String attributeIds; //saved in food_item_dao
  String attributeIds; //saved in order_dao only
  bool isProductInStock; //saved in food_item_dao
  bool isStockManagementActivated; //saved in food_item_dao
  int dailyQuantityLimit; //saved in food_item_dao
  int dailyQuantityConsumed; //saved in food_item_dao
  int position; //saved in food_item_dao
  int quantity; //needs in order_dao only
  int discountPercentage; //saved in food_item_dao
  List<AttributeModel> selectedAttributes;
  String? imagePath;
  bool isActivated;
  int? serverId;
  bool isSyncedOnServer;
  bool isSyncOnServerProcessing;
  String syncOnServerActionPending;
  int?catServerId;
  int orderedItemId;

  FoodItemsModel(this.id,this.name,this.displayName,this.description,this.allergence, this.price,
      {this.isEnablePricePerOrderType=false,this.eatInPrice=0,this.deliveryPrice=0,this.attributeCategoryIds="",this.attributeIds="",
        this.isAttributeMandatory=true,this.isProductInStock=true,this.isStockManagementActivated=false,this.dailyQuantityLimit=30,this.dailyQuantityConsumed=0,
    this.quantity = 0,this.categoryID=0,this.color="#FFFFFF",this.position=0,this.discountPercentage=0,this.selectedAttributes=const [],
        this.imagePath,this.serverId=0, this.catServerId=0, this.isSyncedOnServer=true,this.isSyncOnServerProcessing=false,
        this.syncOnServerActionPending="", this.isHideInKitchen=false,this.isActivated=true,this.orderedItemId=0});

  FoodItemsModel.clone(FoodItemsModel foodItemsModelOriginal): this(foodItemsModelOriginal.id,
  foodItemsModelOriginal.name,
  foodItemsModelOriginal.displayName,
  foodItemsModelOriginal.description,
  foodItemsModelOriginal.allergence,
  foodItemsModelOriginal.price,
  isEnablePricePerOrderType: foodItemsModelOriginal.isEnablePricePerOrderType,
  eatInPrice: foodItemsModelOriginal.eatInPrice,
  deliveryPrice: foodItemsModelOriginal.deliveryPrice,
  attributeCategoryIds: foodItemsModelOriginal.attributeCategoryIds,
  attributeIds: foodItemsModelOriginal.attributeIds,
  isAttributeMandatory: foodItemsModelOriginal.isAttributeMandatory,
  isHideInKitchen: foodItemsModelOriginal.isHideInKitchen,
  isProductInStock: foodItemsModelOriginal.isProductInStock,
  isStockManagementActivated: foodItemsModelOriginal.isStockManagementActivated,
  dailyQuantityLimit: foodItemsModelOriginal.dailyQuantityLimit,
  dailyQuantityConsumed: foodItemsModelOriginal.dailyQuantityConsumed,
  quantity: foodItemsModelOriginal.quantity,
  categoryID: foodItemsModelOriginal.categoryID,
  color: foodItemsModelOriginal.color,
  position: foodItemsModelOriginal.position,
  discountPercentage: foodItemsModelOriginal.discountPercentage,
  selectedAttributes: foodItemsModelOriginal.selectedAttributes,
  imagePath: foodItemsModelOriginal.imagePath,
  serverId: foodItemsModelOriginal.serverId,
  catServerId: foodItemsModelOriginal.catServerId,
  isSyncedOnServer: foodItemsModelOriginal.isSyncedOnServer,
  isSyncOnServerProcessing: foodItemsModelOriginal.isSyncOnServerProcessing,
  syncOnServerActionPending: foodItemsModelOriginal.syncOnServerActionPending,
  isActivated: foodItemsModelOriginal.isActivated,
      orderedItemId:foodItemsModelOriginal.orderedItemId
  );

  factory FoodItemsModel.fromJson(Map<String, dynamic> json) => FoodItemsModel(
    json[FoodItemsDao.columns.COL_ID],
    json[FoodItemsDao.columns.COL_NAME],
    json[FoodItemsDao.columns.COL_DISPLAY_NAME],
    json[FoodItemsDao.columns.COL_DESCRIPTION],
    json[FoodItemsDao.columns.COL_ALLERGENCE],
    json[FoodItemsDao.columns.COL_PRICE],
    isEnablePricePerOrderType: json[FoodItemsDao.columns.COL_IS_ENABLE_PRICE_PER_ORDER_TYPE],
    eatInPrice: json[FoodItemsDao.columns.COL_EAT_IN_PRICE],
    deliveryPrice: json[FoodItemsDao.columns.COL_DELIVERY_PRICE],
    attributeCategoryIds: json[FoodItemsDao.columns.COL_ATTRIBUTE_CATEGORY_IDS],
    //json[FoodItemsDao.columns.COL_ATTRIBUTE_IDS],
    isAttributeMandatory: json[FoodItemsDao.columns.COL_IS_ATTRIBUTE_MANDATORY],
    isHideInKitchen: json[FoodItemsDao.columns.COL_IS_HIDE_IN_KITCHEN],
    isProductInStock: json[FoodItemsDao.columns.COL_IS_PRODUCT_IN_STOCK],
    isStockManagementActivated: json[FoodItemsDao.columns.COL_IS_STOCK_MANAGEMENT_ACTIVATED],
    dailyQuantityLimit: json[FoodItemsDao.columns.COL_DAILY_QUANTITY_LIMIT],
    dailyQuantityConsumed: json[FoodItemsDao.columns.COL_DAILY_QUANTITY_CONSUMED],
    categoryID:json[FoodItemsDao.columns.COL_CATEGORY_ID],
    color:json[FoodItemsDao.columns.COL_COLOR],
    position:json[FoodItemsDao.columns.COL_POSITION],
    imagePath: json[FoodItemsDao.columns.COL_IMAGE_PATH],
    serverId: json[FoodItemsDao.columns.COL_SERVER_ID],
    catServerId: json[FoodItemsDao.columns.COL_CAT_SERVER_ID],
    isSyncedOnServer:json[FoodItemsDao.columns.COL_IS_SYNCED_ON_SERVER],
    isSyncOnServerProcessing:json[FoodItemsDao.columns.COL_IS_SYNC_ON_SERVER_PROCESSING],
    syncOnServerActionPending:json[FoodItemsDao.columns.COL_SYNC_ON_SERVER_ACTION_PENDING],
    isActivated: json[FoodItemsDao.columns.COL_IS_ACTIVATED],
      orderedItemId: json[FoodItemsDao.columns.COL_ORDERED_ITEM_ID]
  );

  factory FoodItemsModel.fromJsonServer(Map<String, dynamic> json) => FoodItemsModel(
      json["itemId"],
      json["itemName"]!=null?json["itemName"]:"Anonymous",
      json["displayName"]!=null?json["displayName"]:"",
      json["description"]!=null?json["description"]:"",
      json["allergence"]!=null?json["allergence"]:"",
      json["defaultPrice"]!=null?json["defaultPrice"]:0,
      isEnablePricePerOrderType: json["enablePricePerOrderType"]!=null?json["enablePricePerOrderType"]:false,
      eatInPrice: json["eatInPrice"]!=null?json["eatInPrice"]:0,
      deliveryPrice: json["deliveryPrice"]!=null?json["deliveryPrice"]:0,
      // attributeCategoryIds: json[FoodItemsDao.columns.COL_ATTRIBUTE_CATEGORY_IDS],
      //json[FoodItemsDao.columns.COL_ATTRIBUTE_IDS],
      isAttributeMandatory: json["isAttributeRequired"],
      isHideInKitchen: json["isShowKichen"],
      isProductInStock: json["productInStock"],
      isStockManagementActivated: json["stockManagementActivated"],
      dailyQuantityLimit: json['quantity'],
      categoryID:json["categoryId"],
      color:json[FoodItemsDao.columns.COL_COLOR],
      position:json["position"],
      imagePath: json["image"],
      serverId: json["itemId"],
      catServerId: json["categoryId"],
      isActivated: json["deactivated"],
      dailyQuantityConsumed:json["dailyQuantityConsumed"],
      attributeCategoryIds:json["attributeCategoryIds"]!=null?json["attributeCategoryIds"]:"",
      orderedItemId:json["orderedItemId"]!=null?json["orderedItemId"]:0
  );

  factory FoodItemsModel.fromJsonFromOrderServer(Map<String, dynamic> json){
    print(json['orderedItemAttributesResponseModels']);
     final attributeList = json['orderedItemAttributesResponseModels'] as List;
     //List<AttributeModel> attributes = attributeList.map((e) => AttributeModel.fromJsonFromOrder(e)).toList();
     List<AttributeModel> attributes = attributeList.map((e) => AttributeModel.fromJsonServerOrder(e)).toList();
    return FoodItemsModel(
        json[FoodItemsDao.columns.COL_ID]!=null?json[FoodItemsDao.columns.COL_ID]:0,
        json['itemName'],
        "",//json[FoodItemsDao.columns.COL_DISPLAY_NAME],
        "",//json[FoodItemsDao.columns.COL_DESCRIPTION],
        "",//json[FoodItemsDao.columns.COL_ALLERGENCE],
        json[FoodItemsDao.columns.COL_PRICE],
        isEnablePricePerOrderType: false,//json[FoodItemsDao.columns.COL_IS_ENABLE_PRICE_PER_ORDER_TYPE],
        eatInPrice: json["eatInPrice"]!=null?json["eatInPrice"]:0,
        deliveryPrice: json["deliveryPrice"]!=null?json["deliveryPrice"]:0,
        //attributeCategoryIds: json[FoodItemsDao.columns.COL_ATTRIBUTE_CATEGORY_IDS],
        //attributeIds: json[FoodItemsDao.columns.COL_ATTRIBUTE_IDS],
        quantity:json['quantity'],
        discountPercentage: json['discount']!=null?json['discount'].toInt():null,
        //isAttributeMandatory: json["isAttributeRequired"],
        //isHideInKitchen: json[FoodItemsDao.columns.COL_IS_HIDE_IN_KITCHEN],
        //isProductInStock: json[FoodItemsDao.columns.COL_IS_PRODUCT_IN_STOCK],
        //isStockManagementActivated: json[FoodItemsDao.columns.COL_IS_STOCK_MANAGEMENT_ACTIVATED],
        //dailyQuantityLimit: json[FoodItemsDao.columns.COL_DAILY_QUANTITY_LIMIT],
        categoryID:json['categoryId'],
        //color:json[FoodItemsDao.columns.COL_COLOR],
        //position:json[FoodItemsDao.columns.COL_POSITION],
        //selectedAttributes: [],
        selectedAttributes: attributes,
        //imagePath: json["image"],
        serverId: json["itemId"],
        //catServerId: json["categoryId"],
      //dailyQuantityConsumed: json[FoodItemsDao.columns.COL_DAILY_QUANTITY_CONSUMED],
       //isActivated: json["deactivate"],
        orderedItemId:json["orderedItemId"]
      //isSynced: json[FoodItemsDao.columns.COL_IS_SYNCED]

    );

  }

  factory FoodItemsModel.fromJsonFromOrder(Map<String, dynamic> json){
    final attributeList = json[OrderDao.columnsAttribute.COL_SELECTED_ATTRIBUTES] as List;
    List<AttributeModel> attributes = attributeList.map((e) => AttributeModel.fromJsonFromOrder(e)).toList();
    return FoodItemsModel(
        json[FoodItemsDao.columns.COL_ID],
        json[FoodItemsDao.columns.COL_NAME],
        json[FoodItemsDao.columns.COL_DISPLAY_NAME],
        json[FoodItemsDao.columns.COL_DESCRIPTION]!=null?json[FoodItemsDao.columns.COL_DESCRIPTION]:"",
        json[FoodItemsDao.columns.COL_ALLERGENCE],
        json[FoodItemsDao.columns.COL_PRICE],
        isEnablePricePerOrderType: json[FoodItemsDao.columns.COL_IS_ENABLE_PRICE_PER_ORDER_TYPE],
        eatInPrice: json[FoodItemsDao.columns.COL_EAT_IN_PRICE],
        deliveryPrice: json[FoodItemsDao.columns.COL_DELIVERY_PRICE],
        attributeCategoryIds: json[FoodItemsDao.columns.COL_ATTRIBUTE_CATEGORY_IDS],
        attributeIds: json[FoodItemsDao.columns.COL_ATTRIBUTE_IDS],
        quantity:json[OrderDao.columnsFoodItems.COL_QUANTITY],
        discountPercentage:json[OrderDao.columnsFoodItems.COL_DISCOUNT],
        isAttributeMandatory: json[FoodItemsDao.columns.COL_IS_ATTRIBUTE_MANDATORY],
        isHideInKitchen: json[FoodItemsDao.columns.COL_IS_HIDE_IN_KITCHEN],
        isProductInStock: json[FoodItemsDao.columns.COL_IS_PRODUCT_IN_STOCK],
        isStockManagementActivated: json[FoodItemsDao.columns.COL_IS_STOCK_MANAGEMENT_ACTIVATED],
        dailyQuantityLimit: json[FoodItemsDao.columns.COL_DAILY_QUANTITY_LIMIT],
        categoryID:json[FoodItemsDao.columns.COL_CATEGORY_ID],
        catServerId:json[FoodItemsDao.columns.COL_CAT_SERVER_ID],
        color:json[FoodItemsDao.columns.COL_COLOR],
        position:json[FoodItemsDao.columns.COL_POSITION],
        selectedAttributes: attributes,
        imagePath: json[FoodItemsDao.columns.COL_IMAGE_PATH],
        serverId: json[FoodItemsDao.columns.COL_SERVER_ID],
      dailyQuantityConsumed: json[FoodItemsDao.columns.COL_DAILY_QUANTITY_CONSUMED]!=null?json[FoodItemsDao.columns.COL_DAILY_QUANTITY_CONSUMED]:0,
     isActivated: json[FoodItemsDao.columns.COL_IS_ACTIVATED]!=null?json[FoodItemsDao.columns.COL_IS_ACTIVATED]:true,
        orderedItemId:json[FoodItemsDao.columns.COL_ORDERED_ITEM_ID]
      //isSynced: json[FoodItemsDao.columns.COL_IS_SYNCED]

    );

  }

  Map<String, dynamic> toJson() => {
    FoodItemsDao.columns.COL_ID: id,
    FoodItemsDao.columns.COL_NAME: name,
    FoodItemsDao.columns.COL_DISPLAY_NAME: displayName,
    FoodItemsDao.columns.COL_DESCRIPTION: description,
    FoodItemsDao.columns.COL_ALLERGENCE: allergence,
    FoodItemsDao.columns.COL_PRICE: price,
    FoodItemsDao.columns.COL_IS_ENABLE_PRICE_PER_ORDER_TYPE: isEnablePricePerOrderType,
    FoodItemsDao.columns.COL_EAT_IN_PRICE: eatInPrice,
    FoodItemsDao.columns.COL_DELIVERY_PRICE: deliveryPrice,
    FoodItemsDao.columns.COL_ATTRIBUTE_CATEGORY_IDS: attributeCategoryIds,
    //FoodItemsDao.columns.COL_ATTRIBUTE_IDS: attributeIds,
    FoodItemsDao.columns.COL_IS_ATTRIBUTE_MANDATORY: isAttributeMandatory,
    FoodItemsDao.columns.COL_IS_HIDE_IN_KITCHEN: isHideInKitchen,
    FoodItemsDao.columns.COL_IS_PRODUCT_IN_STOCK: isProductInStock,
    FoodItemsDao.columns.COL_IS_STOCK_MANAGEMENT_ACTIVATED: isStockManagementActivated,
    FoodItemsDao.columns.COL_DAILY_QUANTITY_LIMIT: dailyQuantityLimit,
    FoodItemsDao.columns.COL_DAILY_QUANTITY_CONSUMED: dailyQuantityConsumed,
    FoodItemsDao.columns.COL_CATEGORY_ID: categoryID,
    FoodItemsDao.columns.COL_COLOR: color,
    FoodItemsDao.columns.COL_POSITION: position,
    FoodItemsDao.columns.COL_IMAGE_PATH: imagePath,
    FoodItemsDao.columns.COL_SERVER_ID: serverId,
    FoodItemsDao.columns.COL_CAT_SERVER_ID: catServerId,
    FoodItemsDao.columns.COL_IS_SYNCED_ON_SERVER:isSyncedOnServer,
    FoodItemsDao.columns.COL_IS_SYNC_ON_SERVER_PROCESSING:isSyncOnServerProcessing,
    FoodItemsDao.columns.COL_SYNC_ON_SERVER_ACTION_PENDING:syncOnServerActionPending,
    FoodItemsDao.columns.COL_IS_ACTIVATED: isActivated,
    FoodItemsDao.columns.COL_ORDERED_ITEM_ID:orderedItemId

    //"quantity": quantity,
  };
  Map<String, dynamic> toJsonForOrder() => {
    FoodItemsDao.columns.COL_ID: id,
    FoodItemsDao.columns.COL_NAME: name,
    FoodItemsDao.columns.COL_DISPLAY_NAME: displayName,
    FoodItemsDao.columns.COL_DISPLAY_NAME: description,
    FoodItemsDao.columns.COL_ALLERGENCE: allergence,
    FoodItemsDao.columns.COL_PRICE: price,
    FoodItemsDao.columns.COL_IS_ENABLE_PRICE_PER_ORDER_TYPE: isEnablePricePerOrderType,
    FoodItemsDao.columns.COL_EAT_IN_PRICE: eatInPrice,
    FoodItemsDao.columns.COL_DELIVERY_PRICE: deliveryPrice,
    FoodItemsDao.columns.COL_ATTRIBUTE_CATEGORY_IDS: attributeCategoryIds,
    FoodItemsDao.columns.COL_ATTRIBUTE_IDS: attributeIds,
    FoodItemsDao.columns.COL_IS_ATTRIBUTE_MANDATORY: isAttributeMandatory,
    FoodItemsDao.columns.COL_IS_HIDE_IN_KITCHEN: isHideInKitchen,
    FoodItemsDao.columns.COL_IS_PRODUCT_IN_STOCK: isProductInStock,
    FoodItemsDao.columns.COL_IS_STOCK_MANAGEMENT_ACTIVATED: isStockManagementActivated,
    FoodItemsDao.columns.COL_DAILY_QUANTITY_LIMIT: dailyQuantityLimit,
    FoodItemsDao.columns.COL_CATEGORY_ID: categoryID,
    FoodItemsDao.columns.COL_CAT_SERVER_ID: catServerId,
    FoodItemsDao.columns.COL_COLOR: color,
    FoodItemsDao.columns.COL_POSITION: position,
    FoodItemsDao.columns.COL_IMAGE_PATH: imagePath,
    FoodItemsDao.columns.COL_SERVER_ID: serverId,
    FoodItemsDao.columns.COL_ORDERED_ITEM_ID:orderedItemId,
    //FoodItemsDao.columns.COL_IS_SYNCED: isSynced,
    OrderDao.columnsFoodItems.COL_QUANTITY: quantity,
    OrderDao.columnsFoodItems.COL_DISCOUNT: discountPercentage,

    OrderDao.columnsAttribute.COL_SELECTED_ATTRIBUTES: selectedAttributes.map((e) => e.toJsonForOrder()).toList(growable: true)
  };
}