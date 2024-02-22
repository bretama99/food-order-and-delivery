import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/src/scheduler/ticker.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:flutter_svg/svg.dart';
import 'package:image_picker/image_picker.dart';
import 'package:opti_food_app/api/food_item_api.dart';
import 'package:opti_food_app/assets/images.dart';
import 'package:opti_food_app/data_models/attribute_category_model.dart';
import 'package:opti_food_app/data_models/company_model.dart';
import 'package:opti_food_app/data_models/food_items_model.dart';
import 'package:opti_food_app/database/attribute_category_dao.dart';
import 'package:opti_food_app/database/attribute_dao.dart';
import 'package:opti_food_app/database/company_dao.dart';
import 'package:opti_food_app/database/food_category_dao.dart';
import 'package:opti_food_app/database/food_items_dao.dart';
import 'package:opti_food_app/widgets/appbar/app_bar_optifood.dart';

import '../../data_models/food_category_model.dart';
import '../../utils/api/item.dart';
import '../../utils/api/item_price.dart';
import '../../utils/constants.dart';
import '../../utils/utility.dart';
import '../../widgets/app_theme.dart';
import '../../widgets/custom_field_with_no_icon.dart';
import '../../widgets/popup/input_popup/radio_input_popup.dart';
import '../MountedState.dart';
class AddFoodItem extends StatefulWidget{
  FoodItemsModel? existingFoodItemModel; // having value only when edit company
  FoodCategoryModel foodCategoryModel;
  TextEditingController nameController = TextEditingController();
  TextEditingController displayNameController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  TextEditingController buttonColorController = TextEditingController();
  TextEditingController allergenceController = TextEditingController();
  TextEditingController priceController = TextEditingController();
  TextEditingController eatInPriceController = TextEditingController();
  TextEditingController deliveryPriceController = TextEditingController();
  TextEditingController dailyQuantityLimit = TextEditingController();
  TextEditingController rbHideInKitchenController = TextEditingController();
  TextEditingController rbIsAttMandatoryController =TextEditingController();
  bool swHideInKitchen = false;
  bool swIsAttributeMandatory = false;
  bool swActivePricePerOrder = false;
  bool swProductInStock = true;
  bool swActivateStockManagement = false;

  AddFoodItem(this.foodCategoryModel,{this.existingFoodItemModel});

  @override
  State<StatefulWidget> createState() => _AddFoodItemState();

}
class _AddFoodItemState extends MountedState<AddFoodItem> with SingleTickerProviderStateMixin{
  final GlobalKey<FormState> _globalKey = GlobalKey<FormState>();
  var _image;
  var selectedImagePath = null;
  late TabController _tabController;
  List<AttributeCategoryModel> attributeCategoryList = [];
  bool chSelectAll = false;
  bool _swipeIsInProgress = false;
  bool _tapIsBeingExecuted = false;
  int _selectedIndex = 0;
  int _prevIndex = 1;
  bool isAttributeCategory=true;
  String selectedAttributeCategories1 = "";

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    FoodCategoryDao().getFoodCategoryById(widget.foodCategoryModel!.id).then((value){
      setState(() {
        widget.foodCategoryModel!.serverId = value.serverId;

      });

    });
    if(widget.foodCategoryModel.isAttributeMandatory){
      widget.swIsAttributeMandatory = true;
    }
    if(widget.foodCategoryModel.isHideInKitchen){
      widget.swHideInKitchen = true;
    }
    _tabController = TabController(initialIndex: _selectedIndex,length: 2, vsync: this);
    AttributeCategoryDao().getAllAttributeCategories().then((value) => {
      setState((){
        if(value.length==0){
          isAttributeCategory=false;
        }
        attributeCategoryList = value;
        if(widget.existingFoodItemModel!=null && widget.existingFoodItemModel!.attributeCategoryIds!=null) {
          List<String> selectedAttributes = widget.existingFoodItemModel!
              .attributeCategoryIds.split(",").toList();
          attributeCategoryList.forEach((element) {
            if (selectedAttributes.contains(element.id.toString())) {
              setState(() {
                element.isSelected = true;
              });
            }
          });
        }
        else{
          attributeCategoryList.forEach((element) {
            element.isSelected = true;
          });
        }
      })
    });
    if(widget.existingFoodItemModel!=null){
      //FoodItemsDao().getFoodItemById(widget.existingFoodItemModel!.id).then((value){
        widget.nameController.text = widget.existingFoodItemModel!.name;
        widget.displayNameController.text = widget.existingFoodItemModel!.displayName!=null?widget.existingFoodItemModel!.displayName!:"";
        widget.descriptionController.text = widget.existingFoodItemModel!.description;
        widget.allergenceController.text = widget.existingFoodItemModel!.allergence;
        widget.priceController.text = widget.existingFoodItemModel!.price.toStringAsFixed(2);
        widget.swActivePricePerOrder = widget.existingFoodItemModel!.isEnablePricePerOrderType;
        widget.eatInPriceController.text = widget.existingFoodItemModel!.eatInPrice!=null&&widget.existingFoodItemModel!.eatInPrice!=0?widget.existingFoodItemModel!.eatInPrice!.toStringAsFixed(2):"";
        widget.deliveryPriceController.text = widget.existingFoodItemModel!.deliveryPrice!=null&&widget.existingFoodItemModel!.deliveryPrice!=0?widget.existingFoodItemModel!.deliveryPrice!.toStringAsFixed(2):"";
        widget.buttonColorController.text = widget.existingFoodItemModel!.color!=null?widget.existingFoodItemModel!.color!:"#FFFFFF";
        widget.swHideInKitchen = widget.existingFoodItemModel!.isHideInKitchen;
        widget.swIsAttributeMandatory = widget.existingFoodItemModel!.isAttributeMandatory;
        widget.swProductInStock = widget.existingFoodItemModel!.isProductInStock;
        widget.swActivateStockManagement = widget.existingFoodItemModel!.isStockManagementActivated;
        //widget.existingFoodItemModel!.serverId = value.serverId;
        widget.dailyQuantityLimit.text = widget.existingFoodItemModel!.dailyQuantityLimit.toString();
        if(widget.existingFoodItemModel!.imagePath!=null) {
          _image = File(widget.existingFoodItemModel!.imagePath!);
          selectedImagePath = widget.existingFoodItemModel!.imagePath!;
        }

      //});

    }
    else{
      widget.buttonColorController.text = "ffffff";
      widget.dailyQuantityLimit.text="";
    }
    _tabController.animation?.addListener(() {
      if (!_tapIsBeingExecuted &&
          !_swipeIsInProgress &&
          (_tabController.offset >= 0.5 || _tabController.offset <= -0.5)) {
        int newIndex = _tabController.offset > 0 ? _tabController.index + 1 : _tabController.index - 1;
        _swipeIsInProgress = true;
        _prevIndex = _selectedIndex;
        setState(() {
          _selectedIndex = newIndex;
        });
      } else {
        if (!_tapIsBeingExecuted &&
            _swipeIsInProgress &&
            ((_tabController.offset < 0.5 && _tabController.offset > 0) ||
                (_tabController.offset > -0.5 && _tabController.offset < 0))) {
          _swipeIsInProgress = false;
          setState(() {
            _selectedIndex = _prevIndex;
          });
        }
      }
    });
    _tabController.addListener(() {
      _swipeIsInProgress = false;
      setState(() {
        _selectedIndex = _tabController.index;
      });
      if (_tapIsBeingExecuted == true) {
        _tapIsBeingExecuted = false;
      } else {
        if (_tabController.indexIsChanging) {
          _tapIsBeingExecuted = true;
        }
      }
    });
  }
  @override
  void dispose() {
    super.dispose();
    _tabController.dispose();
  }
  @override
  Widget build(BuildContext context) {
    FocusNode defaultPriceFocusNode = FocusNode();
    FocusNode eatInPriceFocusNode = FocusNode();
    FocusNode deliveryPriceFocusNode = FocusNode();
    defaultPriceFocusNode.addListener(() {
      if(defaultPriceFocusNode.hasFocus==false){
        widget.priceController.text = int.parse(widget.priceController.text).toStringAsFixed(2);
      }
    });
    eatInPriceFocusNode.addListener(() {
      if(eatInPriceFocusNode.hasFocus==false){
        widget.eatInPriceController.text = int.parse(widget.eatInPriceController.text).toStringAsFixed(2);
      }
    });
    deliveryPriceFocusNode.addListener(() {
      if(deliveryPriceFocusNode.hasFocus==false){
        widget.deliveryPriceController.text = int.parse(widget.deliveryPriceController.text).toStringAsFixed(2);
      }
    });
    return Scaffold(
      appBar: AppBarOptifood(),
      body: Container(
          child:
          Stack(
            children: [
              SingleChildScrollView(
                  child: Form(
                    key: _globalKey,
                    child: Column(
                      children: [
                        Stack(
                          children: [
                            Container(padding: EdgeInsets.only(top: 35,bottom: 35),
                              margin: EdgeInsets.only(bottom: 30),
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black12,
                                    spreadRadius: 2,
                                    blurRadius: 5,
                                  ),
                                ],
                              ),

                              child: Container( // Container to add shaddow for circular avatar
                                width: 65,
                                decoration: BoxDecoration(
                                    color: Colors.white,
                                    shape: BoxShape.circle,
                                    boxShadow: [BoxShadow(blurRadius: 5, color: Colors.black12,spreadRadius: 2)]
                                ),
                                child: GestureDetector(
                                  child: CircleAvatar( // outer cicleavatar to add white border around actual avatar
                                    backgroundColor: Colors.white,
                                    radius: 55,
                                    child: CircleAvatar( // actual circle avatar
                                      backgroundImage: _image==null?null:FileImage(_image),
                                      backgroundColor: Colors.white,
                                      radius: 50,
                                      child: _image!=null?null:
                                      SvgPicture.asset(AppImages.addLogoIcon,
                                          height: 35),
                                    ),
                                  ),
                                  onTap: () async { // on click of circle avatar
                                    //final image = await ImagePicker().getImage(source: ImageSource.gallery);
                                    final image = await ImagePicker().pickImage(source: ImageSource.gallery);
                                    if(image == null) return;
                                    final imageTemp = File(image.path);
                                    selectedImagePath = image.path;
                                    fileName = image.path.split('/').last;
                                    setState(() => this._image = imageTemp); // setting selected image to cirlce avatar
                                  },
                                ),
                              ),

                            ),
                            if(selectedImagePath!=null)...[
                              GestureDetector(
                                child: Center(
                                  child: Container(
                                      padding: EdgeInsets.all(3),
                                      margin: EdgeInsets.only(top: 40, left: 70),
                                      child: Icon(
                                        Icons.close, color: Colors.white,),
                                      decoration: BoxDecoration(
                                        color: AppTheme.colorDarkGrey,
                                        shape: BoxShape.circle,
                                      )
                                  ),
                                ),
                                onTap: (){
                                  setState((){
                                    selectedImagePath = null;
                                    _image = null;
                                  });
                                },
                              )
                            ]
                          ],
                        ),
                        CustomFieldWithNoIcon( // name
                          // data: Icons.email,
                          validator: (value){
                            if(value==null || value.isEmpty) {
                              return "pleaseEnterCategoryName".tr();
                            }
                            else{
                              return null;
                            }
                          },
                          controller: widget.nameController,
                          hintText: "productName".tr(),
                          isObsecre: false,
                          placeholder: "productName".tr(),
                          outerIcon: SvgPicture.asset(AppImages.productIcon, height: 35, color: AppTheme.colorDarkGrey,),
                          textCapitalization: TextCapitalization.sentences,

                        ),
                        CustomFieldWithNoIcon( // display name
                          // data: Icons.email,
                          controller: widget.displayNameController,
                          hintText: "displayName".tr(),
                          isObsecre: false,
                          //outerIcon: SvgPicture.asset("assets/images/icons/phone-client.svg", height: 35, color: AppTheme.colorDarkGrey,),
                        ),

                        CustomFieldWithNoIcon( //description
                          // data: Icons.email,
                          controller: widget.descriptionController,
                          hintText: "description".tr(),
                          minLines: 3,
                          isObsecre: false,
                          outerIcon: SvgPicture.asset(AppImages.descriptionIcon, height: 35, color: AppTheme.colorDarkGrey,),
                        ),
                        CustomFieldWithNoIcon( //allergens
                          // data: Icons.email,
                          controller: widget.allergenceController,
                          hintText: "allergens".tr(),
                          isObsecre: false,
                          readOnly: true,
                          outerIcon: SvgPicture.asset(AppImages.allergenIcon, height: 35, color: AppTheme.colorDarkGrey,),
                          onTap: (){
                            showDialog(context: context,
                                builder: (BuildContext context){
                                  return RadioInputPopup(
                                    value: true,
                                    groupValue: false,
                                    toggleable: true,
                                    contentEditable: true,
                                    cancelButtonNeeded: true,
                                    beforeContent: [
                                      ListTile(
                                        contentPadding: EdgeInsets.only(left: 10,right: 10,top: 10,bottom: 5),
                                        leading: SvgPicture.asset(AppImages.allergenIcon, height: 35, color: AppTheme.colorDarkGrey,),
                                        title: Text("allergens".tr().toUpperCase(), style: TextStyle(color: AppTheme.colorMediumGrey,fontSize: 14)),
                                      ),
                                    ],
                                    foodItemModel: widget.existingFoodItemModel!=null?widget.existingFoodItemModel!:
                                      FoodItemsModel(0, "name", "displayName", "description", "allergence", 0),
                                    items: [],
                                    selectedItems: [],
                                      onSelect: (String allergence)
                                      {
                                        setState(() {
                                          widget.allergenceController.text = allergence;
                                          widget.existingFoodItemModel!.allergence=allergence;
                                        });

                                      },

                                  );

                                });
                          },
                        ),
                        ListTile(
                          contentPadding: EdgeInsets.only(left: 10,right: 10,top: 15),
                          leading: SvgPicture.asset(AppImages.euroSignIcon, height: 35, color: AppTheme.colorDarkGrey,),
                          title: Text("price€PerOrderType").tr(),
                          trailing: Switch(
                            activeColor: AppTheme.colorRed,
                            value: widget.swActivePricePerOrder, onChanged: (bool value) {
                            setState(() {
                              widget.swActivePricePerOrder = value;
                            });
                          },
                          ),
                        ),
                        Padding(padding: EdgeInsets.only(left: 45,right: 10),
                          child: Row(
                            children: [
                              Flexible(
                                  flex: 1,
                                  child: Column(
                                    children: [
                                      Center(child:SvgPicture.asset(AppImages.euroSignIcon,height: 20,),),
                                      Center(
                                        child: CustomFieldWithNoIcon(
                                          validator: (value){
                                            if(value==null || value.isEmpty) {
                                              return "${"invalid".tr()}\n ${"price".tr()}";
                                            }
                                            else{
                                              return null;
                                            }
                                          },
                                          isKeepSpaceForOuterIcon: false,
                                          textInputType: TextInputType.number,
                                          hintText: "default".tr(),
                                          controller: widget.priceController,
                                          focusNode: defaultPriceFocusNode,
                                          // placeholder: Icons.add.toString(),
                                        ),
                                      )

                                    ],
                                  )
                              ),
                              Flexible(
                                  flex: 1,
                                  child: Column(
                                    children: [
                                      SvgPicture.asset(AppImages.dinnerTableIcon,height: 20,),
                                      CustomFieldWithNoIcon(
                                        validator: (value){
                                          if((widget.swActivePricePerOrder&&value==null) || (widget.swActivePricePerOrder&&value.isEmpty)) {
                                            return "${"invalid".tr()}\n ${"price".tr()}";
                                          }
                                          else{
                                            return null;
                                          }
                                        },
                                        isKeepSpaceForOuterIcon: false,
                                        hintText: "eatIn".tr(),
                                        textInputType: TextInputType.number,
                                        controller: widget.eatInPriceController,
                                        hintStyle: widget.swActivePricePerOrder?null:TextStyle(color: AppTheme.colorLightGrey),
                                        readOnly: !widget.swActivePricePerOrder,
                                        focusNode: eatInPriceFocusNode,
                                      )
                                    ],
                                  )

                              ),
                              Flexible(
                                  flex: 1,
                                  child: Column(
                                    children: [
                                      SvgPicture.asset(AppImages.scooterIcon,height: 20,),
                                      CustomFieldWithNoIcon(
                                        validator: (value){
                                          if((widget.swActivePricePerOrder&&value==null) || (widget.swActivePricePerOrder&&value.isEmpty)) {
                                            return "${"invalid".tr()}\n ${"price".tr()}";
                                          }
                                          else{
                                            return null;
                                          }
                                        },
                                        isKeepSpaceForOuterIcon: false,
                                        hintText: "delivery".tr(),
                                        textInputType: TextInputType.number,
                                        controller: widget.deliveryPriceController,
                                        hintStyle: widget.swActivePricePerOrder?null:TextStyle(color: AppTheme.colorLightGrey),
                                        readOnly: !widget.swActivePricePerOrder,
                                        focusNode: deliveryPriceFocusNode,
                                      )
                                    ],
                                  )

                              )
                            ],
                          ),
                        ),
                        ListTile(
                            contentPadding: EdgeInsets.zero,
                            horizontalTitleGap: 0,
                            dense: true,
                            title: CustomFieldWithNoIcon(
                              controller: widget.buttonColorController,
                              hintText: "buttonBackgroundColor".tr(),
                              isObsecre: false,
                              readOnly: true,
                              suffixIcon: IconButton(icon:Icon(Icons.copy),onPressed: (){
                                Clipboard.setData(ClipboardData(text:widget.buttonColorController.text.toString()));
                                Utility().showToastMessage("Copied");
                              }),
                              onTap: (){
                                showDialog(
                                    context: context,
                                    builder: (BuildContext context){
                                      return AlertDialog(
                                        //title: Text('Pick a color!'),
                                        title: Text(''),
                                        content: SingleChildScrollView(
                                          child: ColorPicker(
                                            pickerColor: AppTheme.colorRed, //default color
                                            onColorChanged: (Color color){ //on color picked
                                              setState(() {
                                                //mycolor = color;
                                                widget.buttonColorController.text = color.value.toRadixString(16);
                                              });
                                            },
                                          ),
                                        ),
                                        actions: <Widget>[
                                          ElevatedButton(
                                            child: const Text('done').tr(),
                                            onPressed: () {
                                              Navigator.of(context).pop(); //dismiss the color picker
                                            },
                                          ),
                                        ],
                                      );
                                    }
                                );
                              },
                              outerIcon: SvgPicture.asset(AppImages.colorIcon, height: 35, color: AppTheme.colorDarkGrey,),
                            ),
                            trailing:
                            Container(height: 45,width: 45,
                                margin: EdgeInsets.only(right: 15),
                                decoration: BoxDecoration(
                                  border: Border.all(color: AppTheme.colorGrey),
                                  color: Color(int.parse("0xff"+widget.buttonColorController.text)),
                                )
                              //color: Colors.red,
                            )
                        ),
                        ListTile(
                          contentPadding: EdgeInsets.only(left: 10,right: 10,top: 10,bottom: 15),
                          leading: SvgPicture.asset(AppImages.eyeHiddenIcon, height: 35, color: AppTheme.colorDarkGrey,),
                          title: Text("hideInKitchen").tr(),
                          trailing: Switch(
                            activeColor: AppTheme.colorRed,
                            value: widget.swHideInKitchen, onChanged: (bool value) {
                            setState(() {
                              widget.swHideInKitchen = value;
                            });
                          },
                          ),
                        ),
                        //DefaultTabController(
                        //   length: 2,
                        //  child: TabBar(
                        Container(
                          color: Colors.white,
                          child: TabBar(
                            indicatorColor: AppTheme.colorRed,

                            controller: _tabController,
                            onTap: (index) {
                              setState(() {
                                _selectedIndex = index;
                              });
                            },
                            tabs: [
                              Tab(
                                child: Text("attributes",style: TextStyle(color:(_selectedIndex) == 0
                                    ? AppTheme.colorRed: Colors.black),).tr(),),
                              Tab(child: Text("stock",style: TextStyle(color: (_selectedIndex) == 1
                                  ? AppTheme.colorRed: Colors.black),).tr())
                            ],
                          ),
                        ),

                        //),
                        Container(
                          padding: EdgeInsets.only(top: 20),

                          //height: 200,
                          height: 250,
                          decoration: const BoxDecoration(
                              color: Colors.white,

                              border: Border(top: BorderSide(color: AppTheme.colorRed, width: 0.5))
                          ),
                          child: TabBarView(
                              controller: _tabController,
                              children: [
                                Container(
                                  child: attributeTabData(),
                                ),
                                stockTabData()
                              ]
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 60,right: 55,top: 20,bottom: 20),
                          child: Container(
                            height:45 ,
                            width: 300,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.all(
                                    Radius.circular(10)),
                                boxShadow: [
                                  BoxShadow(color: AppTheme.colorDarkGrey,spreadRadius:2 , blurRadius: 0,)
                                ]
                            ),
                            child: ElevatedButton(

                              style: ElevatedButton.styleFrom(
                                  surfaceTintColor: Colors.transparent,
                                  primary: AppTheme.colorDarkGrey,
                                  elevation: 10, shadowColor: AppTheme.colorDarkGrey),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,

                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(right: 15),
                                    child: SvgPicture.asset(AppImages.saveIcon,
                                      height: 25,),
                                  ),
                                  Text('save', style: TextStyle(fontSize: 18.0, color: Colors.white),).tr(),
                                ],
                              ),
                              onPressed: () async {
                                if (_globalKey.currentState!.validate()==false) {
                                  return;
                                }
                                String selectedAttributeCategories = "";
                                selectedAttributeCategories1="";
                                attributeCategoryList.where((element) => element.isSelected).forEach((el) {
                                  selectedAttributeCategories = selectedAttributeCategories+el.id.toString()+",";
                                  selectedAttributeCategories1 = selectedAttributeCategories;
                                });
                                if(selectedAttributeCategories.length>0){
                                  selectedAttributeCategories = selectedAttributeCategories.substring(0,selectedAttributeCategories.length-1);
                                  selectedAttributeCategories1 = selectedAttributeCategories;
                                }
                                FoodItemsModel foodItemsModel = FoodItemsModel(
                                    1,
                                    widget.nameController.text.trim(),
                                    widget.displayNameController.text,
                                    widget.descriptionController.text,
                                    widget.allergenceController.text,
                                    double.parse(widget.priceController.text),
                                    isEnablePricePerOrderType: widget.swActivePricePerOrder,
                                    eatInPrice: widget.eatInPriceController.text.isEmpty?0:double.parse(widget.eatInPriceController.text),
                                    deliveryPrice: widget.deliveryPriceController.text.isEmpty?0:double.parse(widget.deliveryPriceController.text),
                                    isAttributeMandatory: widget.swIsAttributeMandatory,
                                    isProductInStock: widget.swProductInStock,
                                    isStockManagementActivated: widget.swActivateStockManagement,
                                    dailyQuantityLimit: widget.dailyQuantityLimit.text.isEmpty?1:int.parse(widget.dailyQuantityLimit.text),
                                    color: widget.buttonColorController.text,
                                    isHideInKitchen: widget.swHideInKitchen,
                                    imagePath: selectedImagePath,
                                    categoryID:widget.foodCategoryModel.id,
                                    attributeCategoryIds: selectedAttributeCategories,
                                   serverId: widget.existingFoodItemModel?.serverId,
                                   catServerId: widget.foodCategoryModel.serverId,

                                );
                                if(widget.existingFoodItemModel!=null){
                                  foodItemsModel.id = widget.existingFoodItemModel!.id;
                                  foodItemsModel.isActivated=widget.existingFoodItemModel!.isActivated;
                                  await FoodItemsDao().getFoodItemByName(widget.existingFoodItemModel!.name).then((value) async {
                                    if(value!=null&&value.length>0 && value.first!.id!=widget.existingFoodItemModel!.id){
                                      Utility().showToastMessage("itemAlreadyExists".tr());
                                    }
                                    else{
                                      foodItemsModel.isSyncedOnServer = false;
                                      foodItemsModel.isSyncOnServerProcessing = true;
                                      foodItemsModel.syncOnServerActionPending = ConstantSyncOnServerPendingActions.ACTION_PENDING_UPDATE;
                                      if(double.parse(widget.priceController.text)<=0){
                                        Utility().showToastMessage("Price should be greater than 0".tr());

                                      }
                                      else if((widget.dailyQuantityLimit.text=="" || int.parse(widget.dailyQuantityLimit.text)>0)
                                      ) {
                                      await FoodItemsDao().updateFoodItem(
                                          foodItemsModel).then((value) {
                                        //updateFoodItemToSever(foodItemsModel.serverId);
                                        FoodItemApi().saveFoodItemToSever(
                                            foodItemsModel, isUpdate: true);
                                      });
                                      Navigator.pop(context, foodItemsModel);
                                    }
                                    else{
                                      Utility().showToastMessage("Daily Qauntity Limit can't be less than or equal to 0".tr());
                                    }
                                    }
                                  });
                                }
                                else {
                                  await FoodItemsDao().getFoodItemByName(foodItemsModel.name).then((value) async {
                                    if(value.length>0){
                                      Utility().showToastMessage("itemAlreadyExists".tr());
                                    }
                                    else{
                                      foodItemsModel.isSyncedOnServer = false;
                                      foodItemsModel.isProductInStock =
                                      foodItemsModel.isSyncOnServerProcessing = true;
                                      foodItemsModel.syncOnServerActionPending = ConstantSyncOnServerPendingActions.ACTION_PENDING_CREATE;

                                      if(double.parse(widget.priceController.text)<=0){
                                        Utility().showToastMessage("Price should be greater than 0".tr());

                                      }
                                      else if((widget.dailyQuantityLimit.text=="" || int.parse(widget.dailyQuantityLimit.text)!=0)) {
                                        await FoodItemsDao().insertFoodItem(
                                            widget.foodCategoryModel, foodItemsModel).then((value) =>
                                        {
                                          //saveFoodItemToSever(),
                                          FoodItemApi().saveFoodItemToSever(foodItemsModel)
                                        });
                                        Navigator.pop(context, foodItemsModel);
                                      }
                                      else{
                                        Utility().showToastMessage("Daily Qauntity Limit can't be less than or equal to 0".tr());
                                      }
                                    }
                                  });

                                  // foodItemsModel = await FoodItemsDao()
                                  //     .insertFoodItem(widget.foodCategoryModel,foodItemsModel);
                                }

                              },
                            ),
                          ),
                        ),

                      ],
                    ),
                  )
              )

              //)
            ],
          )
      ),
    );
  }

  late String fileName;
  /*saveFoodItemToSever() async{
    final dio = Dio();
    dio.options.headers['X-TenantID'] = ServerData.OPTIFOOD_DATABASE;
    FoodItemsDao().getFoodItemLast().then((value) async{
      var formData;
      if(value.catServerId!=0) {
        if (_image == null) {
          formData = FormData.fromMap({
            'categoryId': value.catServerId,
            "itemPriceId": 1,
            'itemName': value.name,
            'displayName': value.displayName,
            'color': value.color,
            'position': value.position,
            "quantity": value.dailyQuantityLimit,
            "quantity": value.dailyQuantityLimit,
            "quantity": value.quantity,
            "description": value.description,
            "allergence": value.allergence,
            "attributeRequired": value.isAttributeMandatory,
            "isEnablePricePerOrderType":value.isEnablePricePerOrderType,
            "showKichen": value.isHideInKitchen,
            "eatInPrice": value.eatInPrice,
            "defaultPrice": value.price,
            "deliveryPrice": value.deliveryPrice,
            "eatInNightModePrice": 1,
            "eatInDefaultModePrice": 5,
            "deliveryNightModePrice": 89
          });
        }
        else {
          formData = FormData.fromMap({
            'categoryId': value.catServerId,
            "itemPriceId": 1,
            'itemName': value.name,
            'displayName': value.displayName,
            'color': value.color,
            'position': value.position,
            "quantity": value.dailyQuantityLimit,
            "quantity": value.quantity,
            "description": value.description,
            'image': MultipartFile.fromBytes(
                _image.readAsBytesSync(), filename: fileName),
            "isAttributeRequired": value.isAttributeMandatory,
            "isShowKichen": value.isHideInKitchen,
            "allergence": value.allergence,
            "eatInPrice": value.eatInPrice,
            "defaultPrice": value.price,
            "deliveryPrice": value.deliveryPrice,
            "eatInNightModePrice": 1,
            "eatInDefaultModePrice": 5,
            "deliveryNightModePrice": 89
          });
        }
        var response = await dio.post(
          ServerData.OPTIFOOD_BASE_URL + '/api/item',
          data: formData,
        ).then((value1) async {
          var singleData = FoodItemsModel.fromJsonServer(value1.data);
          value.isSynced = true;
          value.serverId = singleData.serverId;
            FoodItemsDao().updateFoodItem(value).then((value333333) {
          });

        }).catchError((onError) {});
      }
    });

  }
  void updateFoodItemToSever(int? serverId) {
    final dio = Dio();
    dio.options.headers['X-TenantID'] = ServerData.OPTIFOOD_DATABASE;
    FoodItemsDao().getFoodItemByServerId(serverId!).then((value) async{
      var formData;
      if(_image==null){
        formData = FormData.fromMap({
          'categoryId': value?.catServerId,
          "itemPriceId":1,
          'itemName': value?.name,
          'displayName':value?.displayName,
          'color': value?.color,
          'position': value?.position,
          "quantity":value?.quantity,
          "description":value?.description,
          "isAttributeRequired":value?.isAttributeMandatory,
          "isShowKichen":value?.isHideInKitchen,
          "allergence":value?.allergence,
            "eatInPrice": value?.eatInPrice,
            "defaultPrice": value?.price,
            "deliveryPrice": value?.deliveryPrice,
            "eatInNightModePrice": 1,
            "eatInDefaultModePrice":5,
            "deliveryNightModePrice":89

        });}
      else{
        formData = FormData.fromMap({
          'categoryId': value?.catServerId!=0?value?.catServerId:value?.categoryID,
          "itemPriceId":1,
          'itemName': value?.name,
          'displayName':value?.displayName,
          'color': value?.color,
          'position': value?.position,
          "quantity":value?.quantity,
          "description":value?.description,
          'image': MultipartFile.fromBytes(_image.readAsBytesSync(), filename: fileName),
          "isAttributeRequired":value?.isAttributeMandatory,
          "isShowKichen":value?.isHideInKitchen,
          "allergence":value?.allergence,
            "eatInPrice": value?.eatInPrice,
            "defaultPrice": value?.price,
            "deliveryPrice": value?.deliveryPrice,
            "eatInNightModePrice": 1,
            "eatInDefaultModePrice":5,
            "deliveryNightModePrice":89

        });
      }

      var response = await dio.put(ServerData.OPTIFOOD_BASE_URL+"/api/item/${serverId}",
        data: formData,
      ).then((value){
      }).catchError((onError){

      });
    });
  }*/

  Widget attributeTabData() {
    return
      Container(
        color: Colors.white,
        child: Column(
          children: [
            ListTile(
              contentPadding: EdgeInsets.only(left: 10,right: 10),
              leading: SvgPicture.asset(AppImages.attributesIcon, height: 35, color: AppTheme.colorDarkGrey,),
              title: Text("makeAttributesMandatory").tr(),
              trailing: Switch(
                activeColor: AppTheme.colorRed,
                value: widget.swIsAttributeMandatory, onChanged: (bool value) {
                setState(() {
                  if(!isAttributeCategory ||(attributeCategoryList.where((element) => element.isSelected).length==0)){
                    widget.swIsAttributeMandatory = false;

                  }else{
                    widget.swIsAttributeMandatory = value;
                  }

                });
              },
              ),
            ),
            Container(
              alignment: Alignment.topLeft,
              padding: EdgeInsets.only(left: 15),
              child: Text("attributesCategories",style: TextStyle(fontSize: 17, color: AppTheme.colorGrey),textAlign: TextAlign.start,).tr(),
            ),
            Row(
              children: [
                Radio(
                    value: true,
                    activeColor: AppTheme.colorRed,
                    groupValue: chSelectAll,
                    toggleable: true,
                    onChanged: isAttributeCategory?(value){
                      setState(() {
                        if(chSelectAll){
                          chSelectAll = false;
                        }
                        else{
                          chSelectAll = true;
                        }
                        attributeCategoryList.forEach((element) {element.isSelected = chSelectAll;});
                      });
                    }:null),
                /*Checkbox(value: chSelectAll, onChanged: (Object? value) {
                  //Radio(value: allergenceList[index].isSelected, onChanged: (Object? value) {
                  setState(() {
                    if(chSelectAll){
                      chSelectAll = false;
                    }
                    else{
                      chSelectAll = true;
                    }
                    attributeCategoryList.forEach((element) {element.isSelected = chSelectAll;});
                  });
                }),*/
                Text("selectAll",style: TextStyle(fontWeight: FontWeight.bold,
                    color: isAttributeCategory?AppTheme.colorBlack:AppTheme.colorGrey),).tr()
              ],
            ),
            GridView.builder(

                shrinkWrap: true,
                itemCount: attributeCategoryList.length,
                physics: ScrollPhysics(),
                gridDelegate:
                SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 4,
                    crossAxisSpacing: 4,
                    childAspectRatio: 5
                ),
                itemBuilder: (context,index){
                  return SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        Radio(
                            value: true,
                            activeColor: AppTheme.colorRed,
                            groupValue: attributeCategoryList[index].isSelected,
                            toggleable: true,
                            onChanged:  (value){
                              setState(() {
                                if(attributeCategoryList[index].isSelected){
                                  attributeCategoryList[index].isSelected = false;
                                }
                                else{
                                  attributeCategoryList[index].isSelected = true;
                                }
                                if(attributeCategoryList.where((element) => element.isSelected).length==0){
                                  widget.swIsAttributeMandatory=false;

                                }


                              });
                            }),
                       /* Checkbox(
                            activeColor: AppTheme.colorRed,
                            value: attributeCategoryList[index].isSelected,
                            onChanged: (Object? value) {
                          //Radio(value: allergenceList[index].isSelected, onChanged: (Object? value) {
                          setState(() {
                            if(attributeCategoryList[index].isSelected){
                              attributeCategoryList[index].isSelected = false;
                            }
                            else{
                              attributeCategoryList[index].isSelected = true;
                            }
                          });
                        }),*/
                        Text(attributeCategoryList[index].name,style: TextStyle(fontWeight: FontWeight.bold,
                            color: AppTheme.colorBlack),)
                      ],
                    ),
                  );
                }
            )
          ],
        ),
      );
  }
  Widget stockTabData(){
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ListTile(
          contentPadding: EdgeInsets.only(left: 10,right: 10),
          leading: SvgPicture.asset(AppImages.inStockIcon, height: 35, color: AppTheme.colorDarkGrey,),
          title: Text("productInStock").tr(),
          trailing: Switch(
            activeColor: AppTheme.colorRed,
            value:widget.existingFoodItemModel!=null?widget.existingFoodItemModel!.isActivated?widget.swProductInStock:false:widget.swProductInStock,
            onChanged: (bool value) {
            setState(() {
              if((widget.existingFoodItemModel!=null&&widget.existingFoodItemModel!.isActivated)||widget.existingFoodItemModel==null){
                widget.swProductInStock =  value;
                if(widget.existingFoodItemModel!=null){
                  widget.existingFoodItemModel!.isProductInStock = value;
                  FoodItemsDao().updateFoodItem(widget.existingFoodItemModel!).then((value){
                    FoodItemApi().saveFoodItemToSever(widget.existingFoodItemModel!,isUpdate:true);
                  });
                }

              }
              else
                return;
            });
          },
          ),
        ),
        ListTile(
          contentPadding: EdgeInsets.only(left: 10,right: 10),
          leading: SvgPicture.asset(AppImages.stockManagementIcon, height: 35, color: AppTheme.colorDarkGrey,),
          title: Text("activateStockManagement").tr(),
          trailing: Switch(
            activeColor: AppTheme.colorRed,
            value:widget.existingFoodItemModel!=null?widget.existingFoodItemModel!.isActivated?widget.swActivateStockManagement:false:widget.swActivateStockManagement, onChanged: (bool value) {
            setState(() {
              if((widget.existingFoodItemModel!=null&&widget.existingFoodItemModel!.isActivated)||widget.existingFoodItemModel==null)
                widget.swActivateStockManagement = value;
              else
                return;
            });
          },
          ),
        ),
        ListTile(
            contentPadding: EdgeInsets.only(left: 15,right: 15),
            title: Container(
              padding: EdgeInsets.only(left: 45),
              child:Text("dailyQuantityLimit").tr(),
            ),
            trailing:
            Container(
              width: 100,
              child: CustomFieldWithNoIcon(
                hintText: "value".tr(),
                isKeepSpaceForOuterIcon: false,
                textInputType: TextInputType.number,
                controller: widget.dailyQuantityLimit,
                readOnly: !widget.swActivateStockManagement,

                hintStyle: widget.swActivateStockManagement?null:TextStyle(color: AppTheme.colorLightGrey),
                textStyle: widget.swActivateStockManagement?null:TextStyle(color: AppTheme.colorLightGrey),


              ),
            )
        )
      ],
    );
  }
}

class AllergencePopup extends StatefulWidget{
  Function onSelect;
  String selectedAllergence;
  AllergencePopup(this.onSelect,this.selectedAllergence);
  @override
  State<StatefulWidget> createState() => _AllergencePopupState();
}
class _AllergencePopupState extends MountedState<AllergencePopup>{
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    allergenceList.forEach((element) {
      if(widget.selectedAllergence.contains(element.name)){
        element.isSelected = true;
      }
    });
  }
  @override
  Widget build(BuildContext context) {
    return Dialog(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        shape:
        const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(bottomLeft: Radius.circular(20), bottomRight: Radius.circular(20),
            topLeft:  Radius.circular(20), topRight:  Radius.circular(20),),
        ),
        child:
        Container(
            padding: EdgeInsets.only(top: 15),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Flexible(
                  //child: ListView.builder(
                  child: GridView.builder(
                    shrinkWrap: true,
                    scrollDirection: Axis.vertical,
                    itemCount: allergenceList.length,
                    itemBuilder: (BuildContext context, int index) {
                      return
                        Container(
                          height: 30,
                          padding: EdgeInsets.zero,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Radio(
                                  value: true,
                                  activeColor: AppTheme.colorRed,
                                  groupValue: allergenceList[index].isSelected,
                                  toggleable: true,
                                  onChanged: (value){
                                    setState((){
                                      allergenceList[index].isSelected=!allergenceList[index].isSelected;
                                    });
                                  }),
                              /*Checkbox(
                                  activeColor: AppTheme.colorRed,
                                  value: allergenceList[index].isSelected, onChanged: (Object? value,) {
                                //Radio(value: allergenceList[index].isSelected, onChanged: (Object? value) {
                                setState(() {
                                  if(allergenceList[index].isSelected){
                                    allergenceList[index].isSelected = false;
                                  }
                                  else{
                                    allergenceList[index].isSelected = true;
                                  }
                                });
                              }),*/
                              Text(allergenceList[index].name.tr(),style: TextStyle(fontWeight: FontWeight.bold),)
                            ],
                          ),
                        );

                    }, gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 2,
                      mainAxisSpacing: 2,
                      childAspectRatio: 8/2

                  ),
                  ),
                ),
                Container(
                  margin: EdgeInsets.only(top: 20),
                  decoration: BoxDecoration(
                    border: Border(top: BorderSide(color: AppTheme.colorMediumGrey,width:0.1,style: BorderStyle.solid)),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                          flex: 1,
                          child:
                          InkWell(
                            onTap: (){
                              String allergence = "";
                              allergenceList.where((element) => element.isSelected==true).forEach((el) {
                                allergence = allergence+el.name+", ";
                              });
                              if(allergence.isNotEmpty){
                                allergence = allergence.trim();
                                allergence = allergence.substring(0,allergence.length-1);
                              }
                              Navigator.pop(context);
                              widget.onSelect(allergence);
                            },
                            child: Container(
                              padding: EdgeInsets.all(20),
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                border: Border(right: BorderSide(color: AppTheme.colorMediumGrey,width:0.1,style: BorderStyle.solid)),
                              ),
                              child:
                              Text("ok",
                                  style: TextStyle(
                                    //color: AppTheme.colorMediumGrey,fontSize: 18,fontWeight: FontWeight.bold),
                                    color: AppTheme.colorMediumGrey,
                                    fontWeight: FontWeight.normal,
                                    fontSize: 16,
                                  )
                              ).tr(),
                            ),
                          )
                      ),

                      Expanded(
                          flex: 1,
                          child:
                          InkWell(
                            onTap: (){
                              Navigator.pop(context);
                              //widget.negativeButtonPressed();
                            },
                            child: Container(
                              padding: EdgeInsets.all(20),
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                //border: Border(right: BorderSide(color: AppTheme.colorLightGrey,width:1,style: BorderStyle.solid)),
                              ),
                              child:
                              Text("cancel",
                                  style: TextStyle(
                                    //color: AppTheme.colorMediumGrey,fontSize: 18,fontWeight: FontWeight.bold),
                                    color:  AppTheme.colorMediumGrey,
                                    fontWeight: FontWeight.normal,
                                    fontSize: 16,
                                  )
                              ).tr(),

                            ),
                          )
                      ),

                      //),
                    ],
                  ),
                )
              ],
            )
        )

    );
  }
  List<AllergenceModel> allergenceList = [
    AllergenceModel("Gluten", false),
    AllergenceModel("Peanuts", false),
    AllergenceModel("Tree nuts", false),
    AllergenceModel("Celery", false),
    AllergenceModel("Mustard", false),
    AllergenceModel("Eggs", false),
    AllergenceModel("Milk", false),
    AllergenceModel("Sesame", false),
    AllergenceModel("Fish", false),
    AllergenceModel("Crustaceans", false),
    AllergenceModel("Molluscs", false),
    AllergenceModel("Soya", false),
    AllergenceModel("Sulphites", false),
    AllergenceModel("Lupin", false),
  ];
}
class AllergenceModel{
  String name;
  bool isSelected;
  AllergenceModel(this.name,this.isSelected);
}