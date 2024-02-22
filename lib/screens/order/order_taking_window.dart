import 'dart:io';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:opti_food_app/api/order_apis.dart';
import 'package:opti_food_app/assets/images.dart';
import 'package:opti_food_app/data_models/delivery_info_model.dart';
import 'package:opti_food_app/data_models/food_category_model.dart';
import 'package:opti_food_app/data_models/food_items_model.dart';
import 'package:opti_food_app/data_models/order_fee_model.dart';
import 'package:opti_food_app/data_models/order_model.dart';
import 'package:opti_food_app/data_models/user_model.dart';
import 'package:opti_food_app/database/food_category_dao.dart';
import 'package:opti_food_app/database/food_items_dao.dart';
import 'package:opti_food_app/database/order_dao.dart';

import 'package:opti_food_app/screens/contact/contact_list.dart';
import 'package:opti_food_app/screens/order/add_item_attributes.dart';
import 'package:opti_food_app/utils/constants.dart';
import 'package:opti_food_app/utils/utility.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../data_models/attribute_model.dart';
import '../../data_models/contact_model.dart';
import '../../data_models/food_items_model.dart';
import '../../database/contact_dao.dart';
import '../../database/delivery_fee_dao.dart';
import '../../database/night_mode_fee_dao.dart';
import '../../main.dart';
import '../../widgets/app_theme.dart';
import '../../widgets/custom_field_with_no_icon.dart';
import '../../widgets/popup/confirmation_popup/confirmation_popup.dart';
import '../../widgets/popup/input_popup/input_popup.dart';
//import 'package:drag_and_drop_gridview/devdrag.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/cupertino.dart';
import 'package:opti_food_app/screens/order/discount_window.dart';

import '../../widgets/popup/input_popup/radio_input_popup.dart';
import '../MountedState.dart';
class OrderTakingWindow extends  StatefulWidget {
  Function? callBack;
  final String orderType;
  final String orderService;
  String tableNumber;
  String comment = "";
  String orderName = "";
  String? deliveryDate;
  String? deliveryTime;
  bool isEditOrder;
  OrderModel? existingOrder;
  ContactModel? customer;
  String? paymentMode;
  Map dailyConsumptionUpdateMap = {}; //need to update and manage daily consumption during add and remove food items to order.
  OrderTakingWindow(this.orderType,this.orderService,{Key? key,this.tableNumber = "",
    this.isEditOrder = false,this.existingOrder,this.comment="",this.customer=null,
    this.paymentMode=null,this.deliveryTime=null,this.deliveryDate=null, this.callBack}) : super(key: key);


  @override
  State<OrderTakingWindow> createState() => _OrderTakingWindowState();

}

class _OrderTakingWindowState extends MountedState<OrderTakingWindow> {

  FoodCategoryDao foodCategoryDao = FoodCategoryDao();
  FoodItemsDao foodItemsDao = FoodItemsDao();
  TextEditingController timeController = new TextEditingController();
  late Future<List<FoodCategoryModel>>  itemCategoryList;
  late Future<List<FoodItemsModel>>  itemsList;
  List<FoodItemsModel>  itemsListTemp=[];
  List<FoodCategoryModel> itemCategoryListTemp=[];
  late List<FoodItemsModel>  noSQLorderedItemsList = List.empty(growable: true);
  var _refreshIndicator = GlobalKey<RefreshIndicatorState>();
  var _refreshIndicatorItems = GlobalKey<RefreshIndicatorState>();
  var _refreshIndicatorOrderedItems = GlobalKey<RefreshIndicatorState>();
  int selectedIndex=0;
  int selectedItemId=1; // remove in future
  bool isMenuOptionActive=true;
  bool hideOrderList=false;
  bool hideOrderCategory=false;

  bool isDelayedOrder=false;
  String delayedDuration = "0:0:00";

  ScrollController? _scrollController;
  bool drop_drag_mode=false;
  TimeOfDay? timeOfDay = TimeOfDay.now();

  double totalPrice = 0;
  Utility utility = Utility();
  int selectedFoodCategoryId = 0;
  late String selectedLanguage;
  late String groupTimeFormat;
  late SharedPreferences sharedPreferences;
  TextEditingController descriptionController=new TextEditingController();
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override
  void initState(){
    //getDataFromSharedPreferences();
    this.getCategoryCache();
    this.getItems();
    if(widget.isEditOrder)
    {
      noSQLorderedItemsList = widget.existingOrder!.foodItems;
      OrderDao().getOrderById(widget.existingOrder!.id).then((value){
            setState(() {
              widget.existingOrder!.serverId=value.serverId;
            });
          for(int i=0;i<value.foodItems.length;i++){
            setState(() {
              noSQLorderedItemsList[i].orderedItemId=value.foodItems[i].orderedItemId;

            });
          }

      });

      findTotalPrice(context);
      widget.comment = widget.existingOrder!.comment;
      widget.orderName = widget.existingOrder!.orderName;

    }

    SharedPreferences.getInstance().then((value){
      sharedPreferences = value;
      setState(() {
        selectedLanguage = sharedPreferences.getString(ConstantSharedPreferenceKeys.KEY_SELECTED_LANGUAGE)!=null?sharedPreferences.getString(ConstantSharedPreferenceKeys.KEY_SELECTED_LANGUAGE)!:"Français";
        groupTimeFormat = sharedPreferences.getString(ConstantSharedPreferenceKeys.KEY_SELECTED_TIME_FORMAT)!=null?sharedPreferences.getString(ConstantSharedPreferenceKeys.KEY_SELECTED_TIME_FORMAT)!:"24H";
      });
    });
    super.initState();
    TimeOfDay _time = TimeOfDay.fromDateTime(DateTime.now().add(const Duration(minutes: 30)));
    timeOfDay = _time;
    if(timeController.text==""){
      timeController.text = "${_time.hour}:${_time.minute}";
    }
    ///if(widget.customer!=null)
    /*ContactDao().getContactById(widget.customer!.id).then((value){
      widget.customer!.serverId = value.serverId;
      if(value.contactAddressList.first.serverId!=0)
        widget.customer!.contactAddressList=value.contactAddressList;

    });*/
  }

  @override
  Widget build(BuildContext context) {
    double _totalPrice = totalPrice;
    @override
    void dispose() {
      super.dispose();
    }
    return Scaffold(
        body:
        SafeArea(
            //child:
            //Expanded(
              //flex: 1,
              child: Column(
                children: [
                  header(_totalPrice),
                  Divider(
                    color: Colors.white,
                    height: 1,
                    thickness: 1,
                  ),
                  if(!hideOrderList)
                    orderedItemsLists(context),
                  if(!hideOrderList & !this.hideOrderCategory)
                    divider(),
                  categoryListView(),
                  if(!this.hideOrderCategory)
                    divider(),
                  itemList()
                ],
              ),
            //)
        )

    );
  }

  Widget header(double _totalPrice){
    return Transform.translate(
        offset: Offset(0, 0),
        child:
        Container(
          margin: EdgeInsets.fromLTRB(0, 0, 0, 0),
          width: MediaQuery.of(context).size.width * 1.0,
          height: isMenuOptionActive?MediaQuery.of(context).size.height*0.16:
          MediaQuery.of(context).size.height*0.085,
          child: Column(
              children: [
                Container(
                    child: Row(
                      children: [
                        Transform.translate(
                            offset: Offset(0, -2),
                            child:
                            Container(
                                color: Color(0xffd9d9d9),
                                height: MediaQuery.of(context).size.height*0.075,
                                width: MediaQuery.of(context).size.width * 0.18,
                                child: Align(
                                    alignment: Alignment.center,
                                    child: Transform.translate(
                                        offset: Offset(0, 0),
                                        child: InkWell(onTap: () {setState(() {isMenuOptionActive=!isMenuOptionActive;});
                                        },splashColor: Colors.white10,child: SvgPicture.asset("assets/images/icons/option-menu.svg", height: 35)))))),
                        Transform.translate(
                            offset: Offset(1, -2),
                            child:
                            Container(color: Color(0xff262626), height: MediaQuery.of(context).size.height*0.075, width: MediaQuery.of(context).size.width * 0.66,child:  Column(children: [
                              Transform.translate(
                                  offset: Offset(-8, 4),child: Container(
                                  alignment: Alignment.centerRight,
                                  child: Text("totalPrice",
                                    textAlign: TextAlign.right,
                                    style: TextStyle(color: Color(0xffdb1e24),fontSize: 20),).tr())),
                              Transform.translate(
                                offset: Offset(-8, 4), child: Container(
                                  alignment: Alignment.centerRight,
                                  child:
                                  Text("${ utility.formatPrice(totalPrice)}",
                                    textAlign: TextAlign.right,style: TextStyle(color: Colors.white,fontSize: 20),)
                              ),
                              ),

                            ],))),
                        Expanded(
                            child: InkWell(
                              child: Transform.translate(
                                  offset: Offset(1,-2),child: Container(color: Color(0xffdb1e24), height: MediaQuery.of(context).size.height*0.075, width: MediaQuery.of(context).size.width * 0.18,child:
                              Transform.translate(
                                  offset: Offset(2,0),
                                  child: Align(alignment: Alignment.center,
                                      child: SvgPicture.asset(AppImages.sendOrderIcon, height: 35))))),
                              onTap: (){
                                setState(() {
                                  if(noSQLorderedItemsList.isEmpty){
                                    Utility().showToastMessage("noFoodSelectedForOrder".tr());
                                  }
                                  else {
                                    OrderDao().generateOrderNumber().then((orderNumber) => saveOrder(context, orderNumber));
                                  }
                                });
                              },
                            )),
                      ],
                    )
                ),
                Divider(height: 1, thickness: 1,),
                if(isMenuOptionActive)
                  Container(
                      height:MediaQuery.of(context).size.height*0.071,
                      child: Row(
                        children: [
                          Container(color: Colors.white, width: MediaQuery.of(context).size.width * 0.14,
                              margin: EdgeInsets.only(top: 6),
                              child: Align(
                                  alignment: Alignment.center,
                                  child: Transform.translate(
                                      offset: Offset(6, 0),
                                      child:
                                      InkWell(child: SvgPicture.asset(AppImages.addNameIcon, height: 35,color: widget.orderName==""?AppTheme.colorBlack:AppTheme.colorRed,),
                                          onTap: () async {
                                            if(widget.orderType==ConstantOrderType.ORDER_TYPE_DELIVERY){
                                              ContactModel contactModel=await Navigator.of(context).push(MaterialPageRoute(builder:
                                                  (context) => ContactList(returnContact: true,)));
                                              widget.customer = contactModel;
                                              if(widget.existingOrder!=null){
                                                widget.existingOrder!.customer=contactModel;
                                              }
                                            }
                                            else{
                                              setState(() {
                                                showDialog(context: context, builder: (BuildContext
                                                context) {
                                                  return InputPopup(
                                                      title: "order",
                                                      inputBoxHint: "enterOrderName",
                                                      inputBoxDefaultValue: widget.orderName,
                                                      titleImagePath:AppImages.addNameIcon,
                                                      positiveButtonText: "add",
                                                      negativeButtonText: "cancel",
                                                      inputBoxMinLines: 1,
                                                      inputBoxMaxLines: 1,
                                                      titleImageBackgroundColor: AppTheme.colorRed,
                                                      positiveButtonPressed: (Map popupResult)
                                                      {
                                                        widget.orderName = popupResult[InputPopup.components.INPUT_TEXT];
                                                      }
                                                  );
                                                });
                                              });
                                            }
                                          })))),
                          Container(color: Colors.white, width: MediaQuery.of(context).size.width * 0.14,
                            margin: EdgeInsets.only(top: 6),
                            child: Align(
                                alignment: Alignment.center,
                                child:InkWell(
                                  child:
                                  Transform.translate(
                                      offset: Offset(1, 0),
                                      child:SvgPicture.asset(AppImages.commentIcon, height: 35,color: widget.comment==""?AppTheme.colorBlack:AppTheme.colorRed)),
                                  onTap: (){
                                    setState(() {
                                      showDialog(context: context, builder: (BuildContext
                                      context) {
                                        //return Comment(flag: "OrderTakingWindow");
                                        return InputPopup(
                                          title: "",
                                          inputBoxHint: "comment",
                                          inputBoxDefaultValue: widget.comment,
                                          titleImagePath:AppImages.commentWhiteIcon,
                                          positiveButtonText: "add",
                                          negativeButtonText: "cancel",
                                          inputBoxMinLines: 2,
                                          inputBoxMaxLines: 2,
                                          titleImageBackgroundColor: AppTheme.colorGreen,
                                          positiveButtonPressed: (Map popupResult)
                                          {
                                            widget.comment = popupResult[InputPopup.components.INPUT_TEXT];
                                          },
                                        );
                                      });
                                    });
                                  },)
                            ),

                          ),
                          Container(color: Colors.white, width: MediaQuery.of(context).size.width * 0.14,
                            margin: EdgeInsets.only(top: 6),
                            child: Align(
                                alignment: Alignment.center,
                                child:Transform.translate(
                                  offset: Offset(-1, 0),
                                  child: InkWell(child: SvgPicture.asset(AppImages.delayOrderIcon, height: 35, color: isDelayedOrder?AppTheme.colorRed:Colors.black,),
                                      onTap: (){
                                        setState(() {
                                          _showTimePicker();
                                        });
                                      }
                                  ),

                                )),

                          ),
                          Container(color: Colors.white,  width: MediaQuery.of(context).size.width * 0.14,
                            margin: EdgeInsets.only(top: 6),
                            child: Align(
                                alignment: Alignment.center,
                                child:Transform.translate(
                                  offset: Offset(-1, 0),
                                  child: InkWell(child:SvgPicture.asset(AppImages.discountIcon, height: 35,),
                                      onTap: (){
                                        setState(() {
                                          //if(Provider.of<OrderTakingWindowProvider>(context, listen: false).orderItemList.length>0){
                                          if(noSQLorderedItemsList.length>0){
                                            //Provider.of<OrderTakingWindowProvider>(context, listen: false).setDiscount(selectedItemId);
                                            showDialog(context: context, builder: (BuildContext
                                            context) {
                                              return DiscountWindow(noSQLorderedItemsList[selectedIndex].discountPercentage,(int discount){
                                                setState(() {
                                                  noSQLorderedItemsList[selectedIndex].discountPercentage = discount;
                                                  findTotalPrice(context);
                                                });
                                              });
                                            });
                                          }
                                        });
                                      }),)),
                          ),
                          Container(color: Colors.white,  width: MediaQuery.of(context).size.width * 0.14,
                              margin: EdgeInsets.only(top: 6),
                              child: Align(
                                  alignment: Alignment.center,
                                  child:InkWell(onTap: () {

                                    setState(() {
                                      this.removeItemFromOrderedList(context, this.selectedItemId , this.selectedIndex);
                                    });
                                  },
                                      splashColor: Colors.white10,
                                      child: Transform.translate(
                                          offset: Offset(-1, 0),
                                          child:SvgPicture.asset(AppImages.removeItemIcon, height: 35))))),
                          Container(color: Colors.white,  width: MediaQuery.of(context).size.width * 0.14,
                              margin: EdgeInsets.only(top: 6),
                              child: Align(
                                  alignment: Alignment.center,
                                  child:Transform.translate(
                                      offset: Offset(-1, 0),
                                      child:InkWell(onTap: () {
                                        if(noSQLorderedItemsList[this.selectedIndex].isStockManagementActivated!=null&&noSQLorderedItemsList[this.selectedIndex].isStockManagementActivated
                                            ) {
                                          if (widget
                                              .dailyConsumptionUpdateMap.length==0||(widget
                                              .dailyConsumptionUpdateMap[noSQLorderedItemsList[this
                                              .selectedIndex].id]
                                              .isProductInStock != null &&
                                              widget.dailyConsumptionUpdateMap[noSQLorderedItemsList[this
                                                  .selectedIndex].id]
                                                  .isProductInStock == true)) {
                                            this
                                                .increamentItemQuantityInOrderedList(
                                                context, this.selectedItemId,
                                                this.selectedIndex);
                                          }
                                          else {
                                            Utility().showToastMessage(
                                                "outOfStock".tr());
                                          }
                                        }
                                        else{


                                          this
                                              .increamentItemQuantityInOrderedList(
                                              context, this.selectedItemId,
                                              this.selectedIndex);
                                        }

                                      },
                                          child:SvgPicture.asset(AppImages.addItemIcon, height: 35))))),
                          Expanded(
                            child: Container(width: MediaQuery.of(context).size.width * 0.14, color: Colors.white,
                                margin: EdgeInsets.only(top: 4),
                                child: Align(
                                    alignment: Alignment.center,
                                    child:InkWell(onTap: () {
                                      if(noSQLorderedItemsList.length==0)
                                        showDialog(context: context,
                                            builder: (BuildContext
                                            context) {
                                              return ConfirmationPopup(
                                                title: "confirmation",
                                                subTitle: "areYouSureYouWantToDelete",
                                                titleImagePath: AppImages.deleteWhiteIcon,
                                                titleImageBackgroundColor: AppTheme.colorRed,
                                                positiveButtonText: "delete",
                                                negativeButtonText: "cancel",
                                                positiveButtonPressed: () async {
                                                  setState(() {
                                                    Navigator.of(context).pop();
                                                  });
                                                },
                                              );
                                            });
                                      else {
                                        setState(() {
                                          this.deleteItemFromOrderedList(this.selectedItemId , this.selectedIndex);
                                        });
                                      }
                                    },
                                        splashColor: Colors.white10,
                                        child: Transform.translate(
                                            offset: Offset(-4, 0),
                                            child: SvgPicture.asset(AppImages.deleteLineIcon, height: 35))))),
                          ),
                        ],
                      )
                  )]),

          decoration: new BoxDecoration(
            color: Colors.white70,
            borderRadius: new BorderRadius.only(
              topLeft   : const Radius.circular(20.0),
              topRight  : const Radius.circular(20.0),
              bottomLeft: const Radius.circular(0.0),
              bottomRight:const Radius.circular(0.0),
            ),
            border: Border.all(
              color: Color(0xffe6e6e6),
              style: BorderStyle.solid,
              width: 2,

            ),
          ),
        )
    );
  }

  Widget divider(){
    return Divider(
      color: Colors.white, //color of divider
      height: 4, //height spacing of divider
      thickness: 2, //thickness of divier line
      indent: 25, //spacing at the start of divider
      endIndent: 25, //spacing at the end of divider
    );
  }


  Widget orderedItemsLists(BuildContext context){
    return Container(
          height: this.hideOrderCategory?isMenuOptionActive?
          MediaQuery.of(context).size.height*0.635:
          MediaQuery.of(context).size.height*0.71:
          MediaQuery.of(context).size.height*0.24,
          child: ListView.separated(
              itemCount: noSQLorderedItemsList.length+1,
              itemBuilder: (BuildContext context, int index) {
                if (index == noSQLorderedItemsList.length) {
                  return Divider(
                    height: 0,
                    thickness: 1,
                    color: Color(0xffd3d3d3),
                  );
                }
                return Container(
                    color: selectedIndex==index?Color(0xffe6e6e6): Colors.white,
                    child:
                    Column(
                        children: [
                          Row(

                              children:
                              [
                                Container(
                                  child:
                                  Column(
                                      children: [
                                        GestureDetector(
                                          child: Container(
                                            height: 50,
                                            color: selectedIndex==index?Color(0xffe6e6e6): Colors.white,
                                            padding: EdgeInsets.all(8),
                                            width: MediaQuery.of(context).size.width*0.10,
                                            //child: SvgPicture.asset("assets/images/icons/info_red.svg", height: 30),
                                            child: SvgPicture.asset(AppImages.attributesIcon, height: 30,color: AppTheme.colorRed,),
                                          ),
                                          onTap: () async{
                                            if(noSQLorderedItemsList[index].attributeCategoryIds.isEmpty){
                                              Utility().showToastMessage("noAttributeFound".tr());
                                              return;
                                            }
                                            List<AttributeModel> attList = await Navigator.of(context).push(MaterialPageRoute(
                                                builder: (context)=> AddItemAttributes(noSQLorderedItemsList[index])));
                                            if(attList!=null){
                                              setState((){
                                                noSQLorderedItemsList[index].selectedAttributes = attList;

                                                // noSQLorderedItemsList.forEach((element) {

                                                  // if(element.name==noSQLorderedItemsList[index].name){
                                                  //   if(noSQLorderedItemsList[index].selectedAttributes==
                                                  //   element.selectedAttributes){
                                                  //     print("=========================${element.name}===========${noSQLorderedItemsList[index].name}==========================");
                                                  //     element.quantity=element.quantity+1;
                                                  //     noSQLorderedItemsList.removeAt(index);
                                                  //   }
                                                  // }
                                                // });
                                                findTotalPrice(context);
                                              });
                                            }
                                          },
                                        )]),
                                ),
                                GestureDetector(
                                    child:
                                    Container(
                                      //height: 50,
                                        color: selectedIndex==index?Color(0xffe6e6e6): Colors.white,
                                        width: MediaQuery.of(context).size.width*0.50,
                                        child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                  children: [
                                                    Expanded(
                                                      child: Container(
                                                        height: noSQLorderedItemsList[index].selectedAttributes.length>0?25:50,
                                                        padding: noSQLorderedItemsList[index].selectedAttributes.length>0?
                                                        EdgeInsets.fromLTRB(0, 10.5, 0, 0):EdgeInsets.fromLTRB(0, 15.5, 0, 15.5),
                                                        color: selectedIndex==index?Color(0xffe6e6e6): Colors.white,
                                                        child: Text(noSQLorderedItemsList[index].name, style:TextStyle(
                                                            color: Colors.black,
                                                            fontSize: 14),
                                                          overflow: TextOverflow.ellipsis,
                                                        ),
                                                      ),
                                                    )]),
                                              //Row(
                                              Wrap(
                                                children: [
                                                  noSQLorderedItemsList[index].selectedAttributes.length>0?
                                                  Container(
                                                    padding: EdgeInsets.fromLTRB(0, 0, 0, 5),
                                                    child: SvgPicture.asset(AppImages.turnRightIcon,
                                                        height: 12,
                                                        color: Color(0xffa2a2a2)),
                                                  ):Container(),
                                                  for(var item in noSQLorderedItemsList[index].selectedAttributes)
                                                    Container(
                                                      padding: EdgeInsets.fromLTRB(0, 0, 0, 5),
                                                      color: selectedIndex==index?Color(0xffe6e6e6): Colors.white,
                                                      child: noSQLorderedItemsList[index].selectedAttributes[noSQLorderedItemsList[index].selectedAttributes.length-1].id==item.id?
                                                      (item.quantity>1?Text(" ${item.quantity}x${item.name}", style:TextStyle(
                                                          fontSize: 12, color: Color(0xffa2a2a2), fontStyle: FontStyle.italic),
                                                      //):Expanded(child: Text(" ${item.name}", style:TextStyle(
                                                      ):Container(child: Text(" ${item.name}", style:TextStyle(
                                                          fontSize: 12, color: Color(0xffa2a2a2), fontStyle: FontStyle.italic),overflow: TextOverflow.ellipsis,maxLines: 3,),
                                                      )):
                                                      (item.quantity>1?Text(" ${item.quantity}x${item.name}"
                                                          ", ", style:TextStyle(
                                                          fontSize: 12, color: Color(0xffa2a2a2), fontStyle: FontStyle.italic),
                                                      //):Expanded(child: Text(" ${item.name}, ", style:TextStyle(
                                                      ):Container(child: Text(" ${item.name}, ", style:TextStyle(
                                                          fontSize: 12, color: Color(0xffa2a2a2), fontStyle: FontStyle.italic),overflow: TextOverflow.ellipsis,maxLines: 3,),
                                                      )),
                                                    ),
                                                ],
                                              )])),
                                    onTap: () {
                                      setState(() {
                                        this.selectedIndex=index;
                                      });
                                    }
                                ),
                                GestureDetector(
                                    child:
                                    Container(
                                      padding: EdgeInsets.fromLTRB(4, 15.5, 0, 15.5),
                                      height: 50,
                                      color: selectedIndex==index?Color(0xffe6e6e6): Colors.white,
                                      //width: MediaQuery.of(context).size.width*0.07,
                                      child: Text("X${noSQLorderedItemsList[index].quantity}", style:TextStyle(
                                          color: Color(0xffdb1e24),
                                          fontSize: 14)),
                                    ),
                                    onTap: () {
                                      setState(() {
                                        this.selectedIndex=index;
                                      });
                                    }),
                                GestureDetector(
                                    child: Container(
                                      height: 50,
                                      color: selectedIndex==index?Color(0xffe6e6e6): Colors.white,
                                      child: Column(
                                          children: [
                                            Row(
                                                children:[
                                                  Container(
                                                    padding: EdgeInsets.fromLTRB(0, noSQLorderedItemsList[index].discountPercentage==1?15.5:16, 0,
                                                        noSQLorderedItemsList[index].discountPercentage==1?15.5:15),
                                                    height: 50,
                                                    color: selectedIndex==index?Color(0xffe6e6e6): Colors.white,
                                                    width: MediaQuery.of(context).size.width*0.11,
                                                    child:
                                                    noSQLorderedItemsList[index].discountPercentage==100?Text("free".tr(),
                                                      style: TextStyle(fontStyle: FontStyle.italic, fontSize: 12), ).tr():
                                                    noSQLorderedItemsList[index].discountPercentage==-1 ||
                                                        noSQLorderedItemsList[index].discountPercentage==0?Text(""):
                                                    Text("-${(noSQLorderedItemsList[index].discountPercentage)}%",
                                                        textAlign: TextAlign.center,
                                                        style:TextStyle(
                                                            fontStyle: FontStyle.italic,
                                                            color: Colors.black,
                                                            fontSize: 12)),
                                                  ),
                                                  Container(
                                                    padding: EdgeInsets.fromLTRB(0, 15.5, 2, 0),
                                                    height: 50,
                                                    color: selectedIndex==index?Color(0xffe6e6e6): Colors.white,
                                                    width: MediaQuery.of(context).size.width*0.18,
                                                    child: Text("${utility.formatPrice(utility.calculateItemPrice(widget.orderType,widget.orderService,noSQLorderedItemsList[index]))}",
                                                        textAlign: TextAlign.right,
                                                        style:TextStyle(
                                                            color: Colors.black,
                                                            fontSize: 14)),
                                                  ),
                                                ])]),
                                    ),
                                    onTap: () {
                                      setState(() {
                                        this.selectedIndex=index;
                                      });
                                    }),

                              ])
                        ]));
              },
              separatorBuilder: (BuildContext context, int index) {
                return Divider(
                  height: 0,
                  thickness: 1,
                  color: Color(0xffd3d3d3),
                );
              }

          )
      );
    //},);


  }
  Widget categoryListView(){
    return
      Container(
          color: Colors.white,
          height: MediaQuery.of(context).size.height*0.085,
          //child:
          //Expanded(
            child: RefreshIndicator(
                key: _refreshIndicator,
                onRefresh: getCategoryCache,
                child: FutureBuilder<List<FoodCategoryModel>>(
                    future: itemCategoryList,
                    builder: (context, snapshot) {
                      switch (snapshot.connectionState) {
                        case ConnectionState.done:
                          if (snapshot.hasError)
                            return Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: <Widget>[
                                    Icon(
                                      Icons.error,
                                      size: 50,
                                    ),
                                    Text('Error: ${snapshot.error}'),
                                  ],
                                ));
                          else
                            return ReorderableListView(
                                buildDefaultDragHandles: false,
                                scrollDirection: Axis.horizontal,
                                onReorderStart: (int newIndex) {},
                                onReorder: (int oldIndex, int newIndex) {
                                  setState(() {
                                    this.updateItemCategoryPosition(oldIndex, newIndex);
                                  });
                                },
                                children: <Widget>[
                                  for (int index = 0; index < snapshot.data!.length; index++)
                                    ReorderableDelayedDragStartListener(
                                        enabled: true,
                                        key: Key('${index}'),
                                        index: index,
                                        child: box(snapshot.data![index].name, snapshot.data![index].id,snapshot.data![index].color,
                                            snapshot.data![index]))
                                ]);
                        default:
                          return Center(
                              child: Container(
                                child: Text('somethingWentWrongTryAgain').tr(),
                              ));
                      }
                    })),
          //)
      );



  }
  Widget itemList(){
    return Expanded(
        child: Container(
          //height: 350,
            height: MediaQuery.of(context).size.height*0.50,
            margin: EdgeInsets.all(2),
            padding: EdgeInsets.fromLTRB(2, 1, 2, 1),
            color: Colors.white,
            child:
            RefreshIndicator(
                key: _refreshIndicatorItems,
                onRefresh: getItems,
                //child: FutureBuilder<List<Items>>(
                child: FutureBuilder<List<FoodItemsModel>>(
                    future: itemsList,
                    builder: (context, snapshot) {
                      switch (snapshot.connectionState) {
                        case ConnectionState.waiting:
                          return Center(child: CircularProgressIndicator());
                          break;
                        case ConnectionState.done:
                          if (snapshot.hasError)
                            return Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: <Widget>[
                                    Icon(
                                      Icons.error,
                                      size: 50,
                                    ),
                                    Text('Error: ${snapshot.error}'),
                                  ],
                                ));
                          else {
                            if(snapshot.data!.length==0){
                              //return Center(child: Text("noDataFoundOrderTaking".tr(),style: TextStyle(fontSize: 12,),));
                              return Center(child: Text("No item found. Please, go to management to create your Menu",style: TextStyle(fontSize: 12,),));
                            }
                            //return DragAndDropGridView( // commented for now by Manish
                            return GridView.builder(
                              itemCount: snapshot.data!.length,
                             /* onWillAccept: (oldIndex, newIndex) {
                                return true;
                              },
                              onReorder: (int oldIndex, int newIndex) {
                                  this.updateItemPosition(oldIndex, newIndex);
                              },*/ // commented for now by Manish
                              controller: _scrollController,
                              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: MediaQuery
                                    .of(context)
                                    .size
                                    .width > 800 ? 4 : 3,
                                crossAxisSpacing: 4,
                                mainAxisSpacing: 4,
                                childAspectRatio: MediaQuery
                                    .of(context)
                                    .size
                                    .width > 80 ? MediaQuery
                                    .of(context)
                                    .size
                                    .width /
                                    (MediaQuery
                                        .of(context)
                                        .size
                                        .height / 4) : MediaQuery
                                    .of(context)
                                    .size
                                    .width /
                                    (MediaQuery
                                        .of(context)
                                        .size
                                        .height / 5),
                              ),

                              itemBuilder: (context, index) {
                                return GestureDetector(
                                  onTap: () {
                                    setState((){
                                      if(snapshot.data![index].isProductInStock!=null &&
                                          snapshot.data![index].isProductInStock==true) {
                                        addItemToOrderItemList(
                                            context, snapshot.data![index]);
                                      }
                                      else{
                                        Utility().showToastMessage("outOfStock".tr());
                                      }
                                    });
                                  },
                                  onHorizontalDragEnd: (dragUpdateDetails) {
                                    setState(() {
                                      descriptionController.text=snapshot.data![index].description;
                                      int pendingCount = snapshot.data![index].dailyQuantityLimit - snapshot.data![index].dailyQuantityConsumed;
                                      showDialog(context: context,
                                          builder: (BuildContext context){
                                            return
                                              RadioInputPopup(
                                                value: true,
                                                groupValue: false,
                                                toggleable: true,
                                                contentEditable: false,
                                                cancelButtonNeeded: false,
                                                beforeContent: [
                                                  Padding(
                                                      padding: EdgeInsets.only(top: 10),
                                                      child: Text("${snapshot.data![index].name}".toUpperCase(),
                                                        style: TextStyle(
                                                            color: AppTheme.colorDarkGrey,fontWeight: FontWeight.bold,fontSize: 18),)),
                                                  if(snapshot.data![index].isStockManagementActivated) ...[
                                                    Padding(
                                                        padding: EdgeInsets.only(top: 5),
                                                        child: Text("Pending : ${pendingCount}".toUpperCase(),
                                                          style: TextStyle(
                                                              color: pendingCount<=3?AppTheme.colorRed:AppTheme.colorGreen,fontSize: 14),)),
                                                  ],
                                                  ListTile(
                                                    contentPadding: EdgeInsets.only(left: 10,right: 10,top: 10,bottom: 5),
                                                    leading: SvgPicture.asset(AppImages.descriptionIcon, height: 35, color: AppTheme.colorDarkGrey,),
                                                    title: Text("description".tr().toUpperCase(), style: TextStyle(color: AppTheme.colorMediumGrey,fontSize: 14)),
                                                  ),
                                                  Padding(
                                                    padding: EdgeInsets.only(right: 5.0),
                                                    child: CustomFieldWithNoIcon( //description
                                                      controller: descriptionController,
                                                      hintText: "description".tr(),
                                                      minLines: 3,
                                                      isObsecre: false,
                                                      isKeepSpaceForOuterIcon: false,
                                                      enabled: false,
                                                    ),
                                                  ),
                                                  ListTile(
                                                    contentPadding: EdgeInsets.only(left: 10,right: 10,top: 10,bottom: 5),
                                                    leading: SvgPicture.asset(AppImages.allergenIcon, height: 35, color: AppTheme.colorDarkGrey,),
                                                    title: Text("allergens".tr().toUpperCase(), style: TextStyle(color: AppTheme.colorMediumGrey,fontSize: 14)),
                                                  ),],
                                                foodItemModel: snapshot.data![index],
                                                items: [],
                                                selectedItems: [],
                                              );
                                          });

                                    });
                                  },
                                  child: Container(
                                      height: 60,
                                      width: 120,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.all(Radius.circular(6)),
                                        //color: Colors.white,
                                         color: snapshot.data![index].imagePath!=null?Colors.white:Color(int.parse("0xff"+snapshot.data![index].color)),
                                        boxShadow: [boxShadow()],
                                        border: Border.all(
                                            color: Color(0xffd9d9d9),
                                            style: BorderStyle.solid,
                                            width: 1
                                        ),
                                      ),
                                      child: Stack(
                                        children: [
                                          if(snapshot.data![index].imagePath==null||snapshot.data![index].imagePath=="")...[
                                            Container(
                                              padding: EdgeInsets.fromLTRB(0, 3, 0, 0),
                                              child: Align(
                                                alignment: Alignment.center,
                                                child: Padding(
                                                    padding: EdgeInsets.fromLTRB(1, 0, 1, 0),
                                                    child: Text(
                                                        (snapshot.data![index].displayName==null||
                                                            snapshot.data![index].displayName.isEmpty?snapshot.data![index].name:
                                                        snapshot.data![index].displayName).toUpperCase(),
                                                        textAlign: TextAlign.center,
                                                        style: TextStyle(
                                                            fontFamily: 'Roboto',
                                                            fontWeight: FontWeight.w500,
                                                            fontSize: 16,
                                                            decoration: TextDecoration.none
                                                        )
                                                    )),
                                              ),
                                            ),
                                          ]
                                          else...[
                                            Center(
                                              child:Image.file(File(snapshot.data![index].imagePath!),height: 50,),
                                            ),
                                            Positioned(
                                                bottom: 3,
                                                child: Container(
                                                  width: 105,
                                                  padding: EdgeInsets.all(2),
                                                  color: Color(0xccffffff),
                                                  child: Text((snapshot.data![index].displayName==null||
                                                      snapshot.data![index].displayName.isEmpty?snapshot.data![index].name:
                                                  snapshot.data![index].displayName).toUpperCase(),textAlign: TextAlign.center,
                                                    style: TextStyle(fontSize: 10,fontWeight: FontWeight.bold),),
                                                ))

                                          ]
                                        ],
                                      )
                                  ),
                                );
                              },
                            );
                          }
                        default:
                          return Center(
                              child: Container(
                                child: Text('somethingWentWrongTryAgain').tr(),
                              ));
                      }
                    }))));
  }

  Widget box(String? title, int categoryId, String color,FoodCategoryModel foodCategoryModel){
    return GestureDetector(
        key: Key('${categoryId}'),
        onVerticalDragEnd: (dragUpdateDetails) {
          setState(() {
            String velocity=dragUpdateDetails.velocity.toString();
            final split = velocity.split(',');
            var verticalVelocity = split[1].split(")")[0];
            if(verticalVelocity[1]!='-') {
              var magnitude=int.parse(verticalVelocity.substring(1,verticalVelocity.length-2));
              if(magnitude>800) {
                if (!this.hideOrderList && !this.hideOrderCategory) {
                  this.hideOrderCategory = true;
                }
                if (this.hideOrderList && !this.hideOrderCategory) {
                  this.hideOrderList = false;
                }
              }
            }
            if(verticalVelocity[1]=='-') {
              var magnitude=int.parse(verticalVelocity.substring(2,verticalVelocity.length-2));
              if(magnitude>800){
                if(!this.hideOrderList && !this.hideOrderCategory){
                  this.hideOrderList=true;
                }
                if(!this.hideOrderList && this.hideOrderCategory){
                  this.hideOrderCategory=false;
                }
              }}
          });
        },
        child:
        InkWell(
          key: Key(title!),
          child: Container(
              key: Key(title),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(6)),
                color: foodCategoryModel.imagePath!=null?Colors.white:Color(int.parse("0xff"+foodCategoryModel.color)),
                boxShadow: [boxShadow()],
                border: Border.all(
                    color: Color(0xffd9d9d9),
                    style: BorderStyle.solid,
                    width: 1
                ),
              ),
              margin: EdgeInsets.all(2),
              width: 105,
              height: 30,
              alignment: Alignment.center,
              child: Stack(
                children: [
                  if(foodCategoryModel.imagePath==null)...[
                    Container(
                        key: Key(title),
                        padding: const EdgeInsets.fromLTRB(2, 0, 2, 0),
                        child:Text((foodCategoryModel.displayName==null||foodCategoryModel.displayName.isEmpty?foodCategoryModel.name:foodCategoryModel.displayName).toUpperCase(), textAlign: TextAlign.center,
                            style: const TextStyle(
                                fontFamily: 'Roboto',
                                fontWeight: FontWeight.w500,
                                fontSize: 16,
                                height: 0.9
                            ),
                          key: Key(title),
                        )
                    ),
                  ]
                  else...[
                    Center(
                      child:Image.file(File(foodCategoryModel.imagePath!),height: 50,),
                    ),
                    Positioned(
                        bottom: 3,
                        child: Container(
                          width: 105,
                          padding: EdgeInsets.all(2),
                          color: Color(0xccffffff),
                          child: Text((foodCategoryModel.displayName==null||foodCategoryModel.displayName.isEmpty?foodCategoryModel.name:foodCategoryModel.displayName).toUpperCase(),textAlign: TextAlign.center,style: TextStyle(fontSize: 10,fontWeight: FontWeight.bold),),
                        ))

                  ]
                ],
              )


          ),

          onTap: () {
            setState(() {
              this.getCategoryItems(foodCategoryModel!.serverId!);
            });
          },
        ));
  }

  BoxShadow boxShadow(){
    return BoxShadow(
      color: Color(0xffe6e6e6),
      blurRadius: 1.0, // soften the shadow
      spreadRadius: 1.0, //extend the shadow
      offset: Offset(
        1.0,
        1.0,
      ),
    );
  }

  TimeOfDay _timeOfDay = TimeOfDay(hour: 8, minute: 30);

  void snackMessage(){
    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('pleaseSelectLaterTime',
            style: TextStyle(fontSize: 18),).tr(),
          backgroundColor: Colors.red,
        )
    );
  }

  void _showTimePicker(){
    showTimePicker(
        helpText: "",
        hourLabelText: "",
        confirmText: "ok".tr().toUpperCase(),
        cancelText: "cancel".tr().toUpperCase(),
        builder: (context, child) {
          final Widget mediaQueryWrapper = MediaQuery(
            data: MediaQuery.of(context).copyWith(
              alwaysUse24HourFormat: false,
            ),
            child: MediaQuery(
              data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: false),
              child:  Container(
                height: 100,
                width: 320,
                //child: child,
                child: Column(
                  children: [
                    Text("Order will move at  "),
                    Container(
                      child: child,
                    )
                  ],
                )
              ),),
          );
          return Theme(
            child: (selectedLanguage != "English" && groupTimeFormat=="12H")?
            Localizations.override(
              context: context,
              locale: Locale('es', 'US'),
              child: mediaQueryWrapper,
            ):MediaQuery(data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: groupTimeFormat=="24H"?true:false),
              child:  Container(
                height: 100,
                width: 320,
                //child: child,
                child: Align(
                  alignment: Alignment.center,
                  child: Container(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text("Select Duration",style: TextStyle(fontSize: 14,color: Colors.white,fontWeight: FontWeight.bold,decoration: TextDecoration.none),),
                          Container(
                              child: child
                          )
                        ],

                      )
                  )

                ),

              ),),
            data: ThemeData(
              useMaterial3: false,
              textButtonTheme: TextButtonThemeData(
                style: TextButton.styleFrom(
                  primary: AppTheme.colorRed, // button text color
                ),
              ),
              colorScheme: const ColorScheme.light(
                primary: AppTheme.colorRed, // <-- SEE HERE
                background:  AppTheme.colorRed,
              ),
              timePickerTheme: TimePickerThemeData(
                dialHandColor:  AppTheme.colorRed,
              ),
            ),
          );
        },
        //context: context,  initialTime: TimeOfDay.now()).then((value) =>
        context: context,  initialTime: TimeOfDay(hour: 0, minute: 0)).then((value) =>
    {
      setState((){
        //var hr=value!=null?value.hour:null;
        //var min=value!=null?value.minute:null;
        //delayedDuration = (value!.hour * 60) + value!.minute;
        delayedDuration = value!.hour.toString() + ":" + value!.minute.toString() + ":00";
        int delayInMinutes = 0;
        try {
          delayInMinutes = (int.parse(delayedDuration.split(":")[0])*60) + int.parse(delayedDuration.split(":")[1]);
        }
        catch(e){

        }
        if(delayInMinutes>0){
          isDelayedOrder = true;
        }
        else{
          isDelayedOrder = false;
        }
       /* if(hr!=null){
          if(hr<TimeOfDay.now().hour){
            _showTimePicker();
            snackMessage();
          }
          if(min!=null)
            if(hr==TimeOfDay.now().hour && min<=TimeOfDay.now().minute){
              _showTimePicker();
              snackMessage();
            }
        }

        timeOfDay = value;
        timeController.text=value?.format(context) as String;*/

      })
    });
  }
  Future<void> addItemToOrderItemList(BuildContext context, FoodItemsModel foodItemsModel) async {
    Iterable<FoodItemsModel> checkItems;

    if(noSQLorderedItemsList!=null&&noSQLorderedItemsList.length!=0&&noSQLorderedItemsList.first.serverId!=0)
      checkItems = noSQLorderedItemsList.where((element) => element.serverId == foodItemsModel.serverId);
    else
      checkItems = noSQLorderedItemsList.where((element) => element.id == foodItemsModel.id);
    // Utility().showToastMessage("mmmmmmmmfoodItemsModel.quantitymmmmmmmmmmmm===${foodItemsModel.quantity}====mmmmmmmmmmmmmmmmbrhane");
     if (checkItems.length == 0) {
      foodItemsModel.quantity = 1;
      noSQLorderedItemsList.insert(0, FoodItemsModel.clone(foodItemsModel));
      this.selectedIndex = 0;
    }

    else {
      int orderedItemId = 0;
      FoodItemsModel? existingFoodItem;
      for (var ot in checkItems){
        if(ot.discountPercentage==0&&ot.selectedAttributes.length==0){
          existingFoodItem = ot;
          break;
        }
      }
      if(existingFoodItem != null){
        existingFoodItem.quantity = existingFoodItem.quantity+1;
        for (var i=0; i<noSQLorderedItemsList.length; i++){
            if(noSQLorderedItemsList[i].serverId!=0&&noSQLorderedItemsList[i].serverId==existingFoodItem.serverId)
              selectedIndex=i;

          else
            {
              if(noSQLorderedItemsList[i].id==existingFoodItem.id)
                selectedIndex=i;
            }

        }
      }
      else{
        foodItemsModel.quantity = 1;
        noSQLorderedItemsList.insert(0, FoodItemsModel.clone(foodItemsModel));
        this.selectedIndex = 0;
      }
    }
    if(foodItemsModel.isAttributeMandatory==true&&foodItemsModel.attributeCategoryIds.isNotEmpty){



      List<AttributeModel> attList = await Navigator.of(context).push(
          MaterialPageRoute(builder: (context)=>AddItemAttributes(foodItemsModel)));
      if(attList!=null){
        setState((){

          noSQLorderedItemsList[0].selectedAttributes = attList;
          findTotalPrice(context);
        });
      }
      // List<int> numbers = [];
      //
      // late List<FoodItemsModel>  noSQLorderedItemsList1 = List.empty(growable: true);
      //
      // for(int i=0;i<noSQLorderedItemsList.length;i++){
      //   for(int j=0;j<noSQLorderedItemsList.length;j++){
      //      if(!numbers.contains(noSQLorderedItemsList[i].serverId) &&noSQLorderedItemsList[i].serverId==noSQLorderedItemsList[j].serverId){
      //      numbers.add(noSQLorderedItemsList[i].serverId!);
      //
      //      List<int> attr1 = [];
      //      List<int> attr2 = [];
      //      for(int k=0;k<noSQLorderedItemsList[i].selectedAttributes.length;k++){
      //        attr1.add(noSQLorderedItemsList[i].selectedAttributes[k].serverId!);
      //      }
      //      for(int k=0;k<noSQLorderedItemsList[j].selectedAttributes.length;k++){
      //        attr2.add(noSQLorderedItemsList[j].selectedAttributes[k].serverId!);
      //      }
      //
      //
      //
      //      if(listEquals(attr1, attr2) == true){
      //
      //      }
      //      }
      //   }
      //   print("===================noSQLorderedItemsList[i]===${noSQLorderedItemsList[i].selectedAttributes.first.serverId}================${noSQLorderedItemsList[i].name}=============");
      // }
    }
    else{
      findTotalPrice(context);
    }
    // Utility().showToastMessage("====================================brhane teamrat");
    if(foodItemsModel.isStockManagementActivated){
      // Utility().showToastMessage(foodItemsModel.id.toString());
      widget.dailyConsumptionUpdateMap[foodItemsModel.id] = foodItemsModel;
      updateFoodItemDailyConsumption(foodItemsModel, 1);
    }
  }

  void increamentItemQuantityInOrderedList(BuildContext context, int orderedItemId, int index){
    setState(() {
      noSQLorderedItemsList[index].quantity = noSQLorderedItemsList[index].quantity+1;
      findTotalPrice(context);
    });
    if(noSQLorderedItemsList[index].isStockManagementActivated!=null&&
        noSQLorderedItemsList[index].isStockManagementActivated){
      updateFoodItemDailyConsumption(widget.dailyConsumptionUpdateMap[noSQLorderedItemsList[index].id], 1);
    }
  }

  void removeItemFromOrderedList(BuildContext context, int orderedItemId, int index){

    if(noSQLorderedItemsList[index].quantity>1) {
      setState(() {
        noSQLorderedItemsList[index].quantity =
            noSQLorderedItemsList[index].quantity - 1;
      });
    }
    setState(() {
      if(noSQLorderedItemsList[index].quantity>1) {
        // noSQLorderedItemsList[index].quantity = noSQLorderedItemsList[index].quantity - 1;
        if(noSQLorderedItemsList[index].isStockManagementActivated!=null&&noSQLorderedItemsList[index].isStockManagementActivated){
          updateFoodItemDailyConsumption(widget.dailyConsumptionUpdateMap[noSQLorderedItemsList[index].id], -1);
        }
      }
      else{
        if(noSQLorderedItemsList.length==0) {
          Navigator.of(context).pop();
        }
        else
          this.deleteItemFromOrderedList(orderedItemId, index);
      }
      findTotalPrice(context);
    });
  }

  void deleteItemFromOrderedList(int orderedItemId, int index){
    if(noSQLorderedItemsList[index].isStockManagementActivated!=null&&noSQLorderedItemsList[index].isStockManagementActivated){
      updateFoodItemDailyConsumption(widget.dailyConsumptionUpdateMap[noSQLorderedItemsList[index].id],
          noSQLorderedItemsList[index].quantity*-1);
    }
    setState(() {
      noSQLorderedItemsList.removeAt(index);
      if(index>=1) {
        this.selectedIndex = index - 1;
        this.selectedItemId = noSQLorderedItemsList[this.selectedIndex].id;
      }
      else if(noSQLorderedItemsList.length>0){
        this.selectedIndex=0;
        this.selectedItemId = noSQLorderedItemsList[this.selectedIndex].id;
      }

      else{
        this.selectedIndex=0;
        this.selectedItemId =0;
      }
      findTotalPrice(context);
    });

  }

  void _delete(BuildContext context, int selectedItemId, int selectedItemIndex) {
    showCupertinoDialog(
        context: context,
        builder: (BuildContext ctx) {
          return CupertinoAlertDialog(
            title: const Text('pleaseConfirm').tr(),
            content: const Text('areYouSureToRemoveTheOrder').tr(),
            actions: [
              // The "Yes" button
              CupertinoDialogAction(

                onPressed: () {
                  setState(() {
                    this.deleteItemFromOrderedList(selectedItemId, selectedItemIndex);
                    Navigator.of(context).pop();
                  });
                },
                child: Text('yes'.tr().toUpperCase()),
                isDefaultAction: true,
                isDestructiveAction: true,
              ),
              // The "No" button
              CupertinoDialogAction(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text('no'.tr().toUpperCase()),
                  isDefaultAction: false,
                  isDestructiveAction: false

              )
            ],
          );
        });
  }

  double findTotalPrice(BuildContext buildContext){
    double totalPrice1=0;
    for(var item in noSQLorderedItemsList){
      totalPrice1 = totalPrice1 + utility.calculateItemPrice(widget.orderType,widget.orderService,item);
    }
    totalPrice = totalPrice1;
    if(widget.existingOrder!=null)
    {
      widget.existingOrder!.totalPrice = totalPrice;
    }
    return totalPrice1;
  }

  Future<List<FoodCategoryModel>> getCategoryCache() async {
    itemCategoryList =  foodCategoryDao.getAllFoodCategories();
    itemCategoryList.then((itemCatList){
      itemCategoryListTemp = itemCatList;
      if(itemCatList.isNotEmpty)
      {
        //selectedFoodCategoryId = itemCatList.first.id;
        selectedFoodCategoryId = itemCatList.first.serverId!;
      }
    });
    return itemCategoryList;
  }

  Future<Future<List<FoodItemsModel>>> getItems() async {
    setState(()
    {
      itemsList = foodItemsDao.getAllFoodItems();
      itemsList.then((value){
        itemsListTemp = value.where((element) => !(element.isAttributeMandatory==true&&element.attributeIds.length==0)).toList();
      });
    }
    );
    return itemsList;
  }

  Future<List<FoodItemsModel>> getCategoryItems(int itemCategoryId) async {
    setState(() {
      selectedFoodCategoryId = itemCategoryId;
      itemsList = foodItemsDao.getFoodItemsByCategory(itemCategoryId,isGetDeactivated: false);
      itemsList.then((value){
        itemsListTemp = value;
      });
    });
    return itemsList;
  }
  saveOrder(BuildContext context, int orderNumber) async{
    orderNumber=0;
    if(widget.isEditOrder)
    {
      // var deliverTime=widget.orderType==ConstantOrderType.ORDER_TYPE_DELIVERY?Provider.of<CustomerDetailProvider>(context, listen: false).customerDetail.timeC:DateTime.now().toString();
      widget.existingOrder!.comment = widget.comment;
      widget.existingOrder!.orderName = widget.orderName;
      widget.existingOrder!.customer = widget.customer;
      //widget.existingOrder!.deliveryInfoModel.deliveryTime = widget.deliveryTime!=null?widget.deliveryTime!:"02:00";
      widget.existingOrder!.paymentMode = widget.paymentMode;
      widget.existingOrder!.isSyncedOnServer = false;
      widget.existingOrder!.isSyncOnServerProcessing = true;
      widget.existingOrder!.syncOnServerActionPending = Utility().addServerSyncActionPending(
          widget.existingOrder!.syncOnServerActionPending, ConstantSyncOnServerPendingActions.ACTION_PENDING_UPDATE);

      widget.dailyConsumptionUpdateMap.forEach((key, value) async {
        await FoodItemsDao().updateFoodItem(value);
      });
      await OrderDao().updateOrder(widget.existingOrder!).then((value){
          OrderApis.saveOrderToSever(
              widget.existingOrder!, isUpdate: true, oncall: () {});
      });
      Navigator.pop(context);
    }
    else
    {
      await saveNoSqlOrder(context, orderNumber);
      Navigator.pop(context);
    }
  }

  updateFoodItemDailyConsumption(FoodItemsModel foodItemsModel, int consumption){
    if(foodItemsModel.isStockManagementActivated) {
      foodItemsModel.dailyQuantityConsumed =
          foodItemsModel.dailyQuantityConsumed + consumption;
      // Utility().showToastMessage(foodItemsModel.dailyQuantityConsumed.toString());
      if (foodItemsModel.dailyQuantityConsumed >=
          foodItemsModel.dailyQuantityLimit) {
        foodItemsModel.isProductInStock = false;
      }
      else {
        foodItemsModel.isProductInStock = true;
      }
    }
  }

  saveNoSqlOrder(BuildContext context,int orderNumber) async{
    double nightFee=0, deliveryFee=0, totalPrice=0;
    if(noSQLorderedItemsList.length==0)
      return;
    //var deliverTime=widget.orderType==ConstantOrderType.ORDER_TYPE_DELIVERY?Provider.of<CustomerDetailProvider>(context, listen: false).customerDetail.timeC:DateTime.now().toString();
    OrderModel orderModel = OrderModel(1, orderNumber,widget.orderName,
      widget.orderType, widget.orderService,
      widget.tableNumber,widget.comment,
      this.findTotalPrice(context),
      DateTime.now().toString(),"manager".tr(),
      //DeliveryInfoModel(DateTime.now().toString(), widget.deliveryTime!=null?widget.deliveryTime!:"02:00", "1", "0.0", "0.0"),
      //widget.orderType==ConstantOrderType.ORDER_TYPE_DELIVERY?DeliveryInfoModel(widget.deliveryDate!=null?widget.deliveryDate!:DateFormat("dd/MM/yyyy").format(DateTime.now()), widget.deliveryTime!=null?widget.deliveryTime!:DateFormat("kk:mm").format(DateTime.now()), "1", "0.0", "0.0"):null,
      DeliveryInfoModel(
          widget.deliveryDate!=null?widget.deliveryDate!:DateFormat("dd/MM/yyyy").format(DateTime.now()),
          widget.deliveryTime!=null?widget.deliveryTime!:DateFormat("kk:mm").format(DateTime.now()), 0, "0.0", "0.0"),
      //int.parse(optifoodSharedPrefrence.getString("id").toString()),
        //UserModel(int.parse(optifoodSharedPrefrence.getString("id").toString()),
        UserModel(optifoodSharedPrefrence.getInt("id")!,
            "",//optifoodSharedPrefrence.getString("name")!,
            "",//optifoodSharedPrefrence.getString("mobilePhone")!,
            "",//optifoodSharedPrefrence.getString("email")!,
          "",
            optifoodSharedPrefrence.getString("userType")!,
          true

        ),
      //list
      noSQLorderedItemsList,
      customer: widget.customer,
      paymentMode: widget.paymentMode,
      isSyncedOnServer: false,
      isSyncOnServerProcessing: true,
      syncOnServerActionPending: ConstantSyncOnServerPendingActions.ACTION_PENDING_CREATE,
      isDelayedOrder: isDelayedOrder,
      delayedOrderDuration: delayedDuration,
      orderfeeModel: OrderfeeModel(deliveryFee, nightFee)
    );



    /*await DeliveryFeeDao().getDeliveryFeeLast().then((value) {
      orderModel.foodItems.forEach((element) {
        totalPrice = (totalPrice+element.price*element.quantity) as double;
      });
      if(value!=null&&value!.activateDeliveryFee && totalPrice>=value.minimumOrderAmountToExpectDeliveryFee)
        deliveryFee=value.deliveryFee as double;
    });

    await NightModeFeeDao().getNightModeFeeLast().then((value) {

      if(value!=null&&value.activateNightFeeDelivery)
        nightFee=value.nightFee as double;

    });*/ // COMMENTED FOR NOW

    widget.dailyConsumptionUpdateMap.forEach((key, value) async {
      await FoodItemsDao().updateFoodItem(value);
    });
    //channelPrinting.invokeMethod('printTestMessage');
    /*await OrderDao().insertOrder(orderModel).then((value){
      OrderDao().getTopOrder().then((value){
        value.customer=widget.customer;
        if(deliveryFee>0 || nightFee>0){
          value.orderfeeModel?.feeDelivery=deliveryFee;
          value.orderfeeModel?.feeNightMode=nightFee;
        }
        //if(!isDelayedOrder) {
          OrderApis.saveOrderToSever(value, oncall: (String orderNumber) {
            widget.callBack!(orderNumber);
          });
        //}
      });
    });*/
    await OrderDao().insertOrder(orderModel);
    OrderApis.saveOrderToSever(orderModel, oncall: (String orderNumber) {
      widget.callBack!(orderNumber);
    });
  }
  updateItemPosition(int oldIndex, int newIndex) async {
    FoodItemsModel item = itemsListTemp[oldIndex];
    this.itemsListTemp.removeAt(oldIndex);
    this.itemsListTemp.insert(newIndex, item);

    updateItem(int index)
    async {
      if(index<itemsListTemp.length){
        itemsListTemp[index].position = index + 1;
        await foodItemsDao.updateFoodItem(itemsListTemp[index]);
        updateItem(index+1);
      }
      else{
        //Utility().showToastMessage(selectedFoodCategoryId.toString());
        this.getCategoryItems(selectedFoodCategoryId);
      }
    }
    updateItem(0);
  }

  updateItemCategoryPosition(int oldIndex, int newIndex) async {
    if(oldIndex<newIndex){
      newIndex = newIndex-1;
    }
    FoodCategoryModel categoryModel = itemCategoryListTemp[oldIndex];
    this.itemCategoryListTemp.removeAt(oldIndex);
    this.itemCategoryListTemp.insert(newIndex, categoryModel);

    updateCategory(int index)
    async {
      if(index<itemCategoryListTemp.length){
        itemCategoryListTemp[index].position = index + 1;
        await foodCategoryDao.updateFoodCategory(itemCategoryListTemp[index]);
        updateCategory(index+1);
      }
      else{
        /*setState(() {
          this.getCategoryCache();
        });*/

      }
    }
    updateCategory(0);
  }

  void getPreferenceData() async{
    var userPref = await SharedPreferences.getInstance();
  }
}
class TotalPriceProvider with ChangeNotifier
{
  double providerToalPrice = 0;
  void priceChanged(double totalPrice)
  {
    providerToalPrice = totalPrice;
    notifyListeners();
  }

}



class ProductDetailPopup extends StatefulWidget{
  Function onSelect;
  FoodItemsModel foodItemModel;
  ProductDetailPopup(this.onSelect,this.foodItemModel);
  @override
  State<StatefulWidget> createState() => _ProductDetailPopupState();
}
class _ProductDetailPopupState extends MountedState<ProductDetailPopup>{
  TextEditingController descriptionController=new TextEditingController();
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    allergenceList.forEach((element) {
      if(widget.foodItemModel.allergence.contains(element.name)){
        element.isSelected = true;
      }
      descriptionController.text=widget.foodItemModel.description;
    });
  }
  @override
  Widget build(BuildContext context) {
    return
      Dialog(
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

                  Padding(
                      padding: EdgeInsets.only(top: 10),
                      child: Text("${widget.foodItemModel.name}".toUpperCase(),
                        style: TextStyle(
                            color: AppTheme.colorDarkGrey,fontWeight: FontWeight.bold,fontSize: 18),)),
                  ListTile(
                    contentPadding: EdgeInsets.only(left: 10,right: 10,top: 10,bottom: 5),
                    leading: SvgPicture.asset(AppImages.descriptionIcon, height: 35, color: AppTheme.colorDarkGrey,),
                    title: Text("description".tr().toUpperCase(), style: TextStyle(color: AppTheme.colorMediumGrey,fontSize: 14)),
                  ),
                  CustomFieldWithNoIcon( //description
                    controller: descriptionController,
                    hintText: "description".tr(),
                    minLines: 3,
                    isObsecre: false,
                    isKeepSpaceForOuterIcon: false,
                    enabled: false,
                  ),
                  ListTile(
                    contentPadding: EdgeInsets.only(left: 10,right: 10,top: 10,bottom: 5),
                    leading: SvgPicture.asset(AppImages.allergenIcon, height: 35, color: AppTheme.colorDarkGrey,),
                    title: Text("allergens".tr().toUpperCase(), style: TextStyle(color: AppTheme.colorMediumGrey,fontSize: 14)),
                  ),
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

                                    }),

                                Text(allergenceList[index].name,style: TextStyle(fontWeight: FontWeight.bold),)
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