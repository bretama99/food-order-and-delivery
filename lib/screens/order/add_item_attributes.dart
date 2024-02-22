import 'dart:async';
import 'dart:io';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:opti_food_app/assets/images.dart';
import 'package:opti_food_app/data_models/attribute_model.dart';
import 'package:opti_food_app/database/attribute_category_dao.dart';
import 'package:opti_food_app/database/attribute_dao.dart';
import 'package:provider/provider.dart';
import '../../data_models/attribute_category_model.dart';
import '../../data_models/food_items_model.dart';
import '../../utils/utility.dart';
import '../../widgets/app_theme.dart';
//import 'package:drag_and_drop_gridview/devdrag.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';
import '../MountedState.dart';
class AddItemAttributes  extends  StatefulWidget{
  late List<AttributeModel> attributeModelList;
  FoodItemsModel foodItemsModel;
  AddItemAttributes(this.foodItemsModel,{Key? key}) : super(key: key);



  @override
  State<AddItemAttributes> createState() => _AddItemAttributesState();

}

class _AddItemAttributesState extends MountedState<AddItemAttributes> {
  AttributeCategoryDao attributeCategoryDao = AttributeCategoryDao();
  AttributeDao attributeDao = AttributeDao();
  NumberFormat myFormat = NumberFormat.decimalPattern('en_us');
  List<AttributeModel> attributes = [];
  late Future<List<AttributeCategoryModel>>  attributeCategoryList;
  late Future<List<AttributeModel>>  attributeList;
  List<AttributeCategoryModel> attributeCategoryListTemp=[];
  var _refreshIndicator = GlobalKey<RefreshIndicatorState>();
  var _refreshIndicatorAttributes= GlobalKey<RefreshIndicatorState>();
  int selectedIndex=0;
  int selectedItemId=0;
  int x=3;

  int totalPrice=0;
  ScrollController? _scrollController;
  int attributeCategoryId=1;
  int selectedAttributeCatId = 0;

  Map<int,AttributeModel> selectedAttributesMap = Map();
  @override
  void initState() {
    super.initState();
    widget.attributeModelList = widget.foodItemsModel.selectedAttributes;
    getAttributeCategory();
    getAttribues();
    if(widget.attributeModelList.isNotEmpty){
      widget.attributeModelList.forEach((element) {
        selectedAttributesMap[element.serverId!] = element;
      });
    }
    //this.filterAttributesByCategory(1);
  }


  @override
  Widget build(BuildContext context) {
    @override
    void dispose() {
      super.dispose();
    }
    return Scaffold(
        body:
        SafeArea(
            child:

            Column(
              children: [
                categoryListView(),
                divider(),
                attributeDisplay(),
              ],
            )
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


  Widget categoryListView(){
    return
      Container(
          color: Colors.white,
          height: 70,
          margin: EdgeInsets.fromLTRB(0, 4, 0, 0),
          child:
          RefreshIndicator(
              key: _refreshIndicator,
              onRefresh: getAttributeCategory,
              //child: FutureBuilder<List<AttributeCategory>>(
              child: FutureBuilder<List<AttributeCategoryModel>>(
                  future: attributeCategoryList,
                  builder: (context, snapshot) {
                    switch (snapshot.connectionState) {
                      /*case ConnectionState.waiting:
                        return Center(child: CircularProgressIndicator());*/
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
                          return
                            ReorderableListView(
                                buildDefaultDragHandles: false,
                                scrollDirection: Axis.horizontal,
                                onReorder: (int oldIndex, int newIndex) {
                                  setState(() {
                                    this.updateAttributeCategoryPosition(oldIndex, newIndex);
                                  });
                                },
                                children: <Widget>[
                                  for (int index = 0; index < snapshot.data!.length; index++)
                                    ReorderableDelayedDragStartListener(
                                        enabled: true,
                                        key: Key('${index}'),
                                        index: index,
                                        //child: box(snapshot.data![index].name.toUpperCase(), snapshot.data![index].id,snapshot.data![index].color))
                                        child: box(snapshot.data![index]))
                                ]);
                      default:
                        return Center(
                            child: Container(
                              child: Text('somethingWentWrongTryAgain').tr(),
                            ));
                    }
                  })));



  }
  Widget attributeDisplay(){
    return Expanded(
        child:
        RefreshIndicator(
            key: _refreshIndicatorAttributes,
            onRefresh: getAttribues,
            //child: FutureBuilder<List<Attribute>>(
            child: FutureBuilder<List<AttributeModel>>(
                future: attributeList,
                builder: (context, snapshot) {
                  switch (snapshot.connectionState) {
                    case ConnectionState.waiting:
                      return Center(child: CircularProgressIndicator());
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
                      else return Column(
                          children: [
                            Expanded(
                              child: Container(
                                height: 540,
                                margin: EdgeInsets.fromLTRB(2,2,2,2),
                                padding: EdgeInsets.fromLTRB(2, 2, 2, 2),
                                color: Colors.white,
                                child:

                                Column(
                                    children: [
                                      Expanded(
                                        //child: DragAndDropGridView( // commented for now by Manish
                                        child: GridView.builder(
                                          itemCount:snapshot.data!.length,
                                          /*onWillAccept: (oldIndex, newIndex) {
                                            return true;
                                          },
                                          onReorder: (int oldIndex, int newIndex) {
                                            setState(() {
                                              this.updateAttributePosition(oldIndex, newIndex);
                                            });
                                          },*/ // commented for now by Manish
                                          controller: _scrollController,
                                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                            crossAxisCount:  MediaQuery.of(context).size.width>800?4:3,
                                            crossAxisSpacing: 4,
                                            mainAxisSpacing: 4,
                                            childAspectRatio: MediaQuery.of(context).size.width>800?MediaQuery.of(context).size.width /
                                                (MediaQuery.of(context).size.height / 3):MediaQuery.of(context).size.width /
                                                (MediaQuery.of(context).size.height / 4),
                                          ),

                                          itemBuilder: (context,index) {
                                            return GestureDetector(
                                              onTap:(){
                                                //addAttributeToOrderedList(context, snapshot.data![index].attributeId);
                                                //addAttributeToOrderedList(context, snapshot.data![index].id);
                                                setState(() {
                                                  addAttributeToOrderedList(context, snapshot.data![index]);
                                                });
                                              },
                                              child:
                                                  Stack(
                                                    children: [
                                                      Container(
                                                          height: 60,
                                                          width: 115,
                                                          margin: EdgeInsets.fromLTRB(2, 6, 2, 0),
                                                          decoration: BoxDecoration(
                                                            borderRadius: BorderRadius.all(Radius.circular(6)),
                                                            color: snapshot.data![index].imagePath!=null?Colors.white:Color(int.parse("0xff"+snapshot.data![index].color)),
                                                            boxShadow: [boxShadow()],
                                                            border: Border.all(
                                                                color: Color(0xffd9d9d9),
                                                                style: BorderStyle.solid,
                                                                width: 1
                                                            ),
                                                          ),
                                                          alignment: Alignment.center,
                                                          child: Stack(
                                                            children: [
                                                              if(snapshot.data![index].imagePath==null)...[
                                                                Container(
                                                                    padding: EdgeInsets.fromLTRB(2, 0, 2, 0),
                                                                    child:Text( (snapshot.data![index].displayName==null||snapshot.data![index].displayName.isEmpty?snapshot.data![index].name:snapshot.data![index].displayName).toUpperCase(), textAlign: TextAlign.center,
                                                                        style: TextStyle(
                                                                            fontFamily: 'Roboto',
                                                                            fontWeight: FontWeight.w500,
                                                                            fontSize: 16,
                                                                            height: 0.9
                                                                        ))),
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
                                                                      child: Text((snapshot.data![index].displayName==null||snapshot.data![index].displayName.isEmpty?snapshot.data![index].name:snapshot.data![index].displayName).toUpperCase(),textAlign: TextAlign.center,style: TextStyle(fontSize: 10,fontWeight: FontWeight.bold),),
                                                                    ))

                                                              ],

                                                            ],
                                                          )
                                                        /*child: Container(
                                                  padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
                                                  child:
                                                  Align(
                                                    alignment: Alignment.center,
                                                    child:
                                                    Row(
                                                      children: [
                                                        Expanded(
                                                            child:
                                                            GestureDetector(child:
                                                            Container(
                                                                child: Text("${
                                                                    //snapshot.data![index].attributeName}"
                                                                    snapshot.data![index].name.toUpperCase()}"
                                                                    //"${snapshot.data![index].value>0?"(${snapshot.data![index].value}€)":""}" ,
                                                                    "${snapshot.data![index].price>0?"(${snapshot.data![index].price}€)":""}" ,
                                                                    textAlign: TextAlign.center,
                                                                    style: TextStyle(
                                                                        fontSize: 16,
                                                                        decoration: TextDecoration.none
                                                                    )
                                                                  // style: TextStyle(fontSize: 18, color: Colors.black, height: 0.9 )
                                                                )),
                                                                onTap: () {
                                                                  //addAttributeToOrderedList(context, snapshot.data![index].attributeId);
                                                                  //addAttributeToOrderedList(context, snapshot.data![index].id);
                                                                  setState(() {
                                                                    addAttributeToOrderedList(context, snapshot.data![index]);
                                                                  });

                                                                })
                                                        ),
                                              //Consumer<OrderTakingWindowProvider>(builder: (context, orderTakingWindowProvider, child){
                                              Consumer(builder: (context, orderTakingWindowProvider, child){
                                                return
                                                  GestureDetector(
                                                    child:
                                                    Container(
                                                      child:
                                                      // Transform.translate(offset: Offset(0,-16),child:
                                                      //this.findAttributQuantity(snapshot.data![index].attributeId, orderTakingWindowProvider.orderItemList)==0?Container():
                                                      //this.findAttributQuantity(snapshot.data![index].id, orderTakingWindowProvider.orderItemList)==0?Container():
                                                      this.findAttributQuantity(snapshot.data![index].id)==0?Container():
                                                      Transform.translate(offset: Offset(4,-8),
                                                          child: Container(
                                                            width:25,
                                                            height: 25,
                                                            margin: EdgeInsets.fromLTRB(0, 0, 0, 26),
                                                            child:
                                                            //Transform.translate(offset: Offset(0,2),
                                                            Container(
                                                                //child:Text("${this.findAttributQuantity(snapshot.data![index].attributeId, orderTakingWindowProvider.orderItemList)}", textAlign: TextAlign.center,
                                                                //child:Text("${this.findAttributQuantity(snapshot.data![index].id, orderTakingWindowProvider.orderItemList)}", textAlign: TextAlign.center,
                                                                child:
                                                                Center(
                                                                  child: Text("${this.findAttributQuantity(snapshot.data![index].id)}", textAlign: TextAlign.center,
                                                                      style: TextStyle(color: Colors.white,fontSize: 15)),
                                                                ),

                                                            ),
                                                            decoration: BoxDecoration(
                                                              shape: BoxShape.circle,
                                                              color: AppTheme.colorRed,
                                                              // borderRadius: BorderRadius.circular(100)
                                                              //more than 50% of width makes circle
                                                            ),)
                                                      ),
                                                    ),
                                                    onTap: () {
                                                      //removeAttributeFromOrderedList(context, snapshot.data![index].attributeId, orderTakingWindowProvider.orderItemList);
                                                      removeAttributeFromOrderedList(snapshot.data![index].id);
                                                    }
                                                );

                                              })
                                                      ],
                                                    ),
                                                  ),
                                                ),*/
                                                      ),
                                                      Consumer(builder: (context, orderTakingWindowProvider, child){ // to show bubble for attributes selected
                                                        return
                                                          //GestureDetector(
                                                              //child:
                                                                  Positioned(
                                                                    top: 0,
                                                                    right: 0,
                                                                    child: Container(
                                                                      child:
                                                                      // Transform.translate(offset: Offset(0,-16),child:
                                                                      //this.findAttributQuantity(snapshot.data![index].attributeId, orderTakingWindowProvider.orderItemList)==0?Container():
                                                                      //this.findAttributQuantity(snapshot.data![index].id, orderTakingWindowProvider.orderItemList)==0?Container():
                                                                      this.findAttributQuantity(snapshot.data![index].serverId!)==0?Container():
                                                                      //Transform.translate(offset: Offset(4,-8),
                                                                      GestureDetector(
                                                                        onTap: (){
                                                                          removeAttributeFromOrderedList(snapshot.data![index].serverId!);
                                                                        },
                                                                        child: Transform.translate(
                                                                            //offset: Offset(85,-1),
                                                                          offset: Offset(0,0),
                                                                            child:
                                                                            Container(
                                                                              width:25,
                                                                              height: 25,
                                                                              margin: EdgeInsets.fromLTRB(0, 0, 0, 26),
                                                                              child:
                                                                              //Transform.translate(offset: Offset(0,2),
                                                                              Container(
                                                                                //child:Text("${this.findAttributQuantity(snapshot.data![index].attributeId, orderTakingWindowProvider.orderItemList)}", textAlign: TextAlign.center,
                                                                                //child:Text("${this.findAttributQuantity(snapshot.data![index].id, orderTakingWindowProvider.orderItemList)}", textAlign: TextAlign.center,
                                                                                child:
                                                                                Center(
                                                                                  child: Text("${this.findAttributQuantity(snapshot.data![index].serverId!)}", textAlign: TextAlign.center,
                                                                                      style: TextStyle(color: Colors.white,fontSize: 15)),
                                                                                ),

                                                                              ),
                                                                              decoration: BoxDecoration(
                                                                                shape: BoxShape.circle,
                                                                                color: AppTheme.colorRed,
                                                                                // borderRadius: BorderRadius.circular(100)
                                                                                //more than 50% of width makes circle
                                                                              ),)
                                                                        ),
                                                                      ),

                                                                    ),
                                                                  );

                                                            /*  onTap: () {
                                                                //removeAttributeFromOrderedList(context, snapshot.data![index].attributeId, orderTakingWindowProvider.orderItemList);
                                                                removeAttributeFromOrderedList(snapshot.data![index].id);
                                                              }
                                                          );
*/
                                                      })
                                                    ],
                                                  )

                                            );
                                          },
                                        ),
                                      ),

                                    ]),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(left: 60,right: 55,top: 15,bottom: 15),
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

                                    List<AttributeModel> attList = selectedAttributesMap.values.toList();
                                    /*attList.sort((a,b)=>
                                        a.position.compareTo(b.position)
                                      );*/
                                    attList.sort((a,b)=>
                                        ("${getAttributeCategoryPositionById(a.categoryID)}${a.position}").toString().
                                        compareTo(("${getAttributeCategoryPositionById(b.categoryID)}${b.position}").toString())
                                    );
                                    if(selectedAttributesMap.values.length==0&&widget.foodItemsModel.isAttributeMandatory){
                                      Utility().showToastMessage("selectAtLeastOneAttribute".tr());
                                    }
                                    else{
                                      Navigator.pop(context,attList);
                                    }
                                  },
                                ),
                              ),
                            ),

                           /* Container(
                              width: 200,
                              alignment: Alignment.center,
                              child:
                              SizedBox(
                                  height:50, //height of button
                                  width:180,
                                  child: ElevatedButton.icon(
                                    icon: Text('SAVE', style: TextStyle(fontSize: 18),),
                                    label: Icon(Icons.arrow_forward_ios, size: 20, color: AppTheme.colorRed,),
                                    style: ElevatedButton.styleFrom(
                                      primary: Colors.black, //background color of button
                                      elevation: 3, //elevation of button
                                      shape: RoundedRectangleBorder( //to set border radius to button
                                          borderRadius: BorderRadius.circular(16)
                                      ),
                                    ),
                                    onPressed: (){
                                      List<AttributeModel> attList = selectedAttributesMap.values.toList();
                                      *//*attList.sort((a,b)=>
                                        a.position.compareTo(b.position)
                                      );*//*
                                      attList.sort((a,b)=>
                                        ("${getAttributeCategoryPositionById(a.categoryID)}${a.position}").toString().
                                          compareTo(("${getAttributeCategoryPositionById(b.categoryID)}${b.position}").toString())
                                      );
                                      Navigator.pop(context,attList);
                                    },
                                  )),

                            )*/
                          ]);
                    default:
                      return Center(
                          child: Container(
                            child: Text('somethingWentWrongTryAgain').tr(),
                          ));
                  }
                })));
  }

  Widget box(AttributeCategoryModel attributeCategoryModel){
    return InkWell(
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(6)),
          color: attributeCategoryModel.imagePath!=null?Colors.white:Color(int.parse("0xff"+attributeCategoryModel.color)),
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
        /*child: Padding(
            padding: EdgeInsets.fromLTRB(2, 0, 2, 0),
            child:Text("${attributeCategoryModel.displayName.isEmpty==null||attributeCategoryModel.displayName.isEmpty?attributeCategoryModel.name:attributeCategoryModel.displayName}",  textAlign: TextAlign.center,
                // style:TextStyle(color: Colors.black, fontSize: 15)
                style: TextStyle(
                    fontFamily: 'Roboto',
                    fontWeight: FontWeight.w500,
                    fontSize: 16,
                    height: 0.9
                ))),*/
          child: Stack(
            children: [
              if(attributeCategoryModel.imagePath==null)...[
                Container(
                    padding: EdgeInsets.fromLTRB(2, 0, 2, 0),
                    child:Text((attributeCategoryModel.displayName==null||attributeCategoryModel.displayName.isEmpty?attributeCategoryModel.name:attributeCategoryModel.displayName).toUpperCase(), textAlign: TextAlign.center,
                        style: TextStyle(
                            fontFamily: 'Roboto',
                            fontWeight: FontWeight.w500,
                            fontSize: 16,
                            height: 0.9
                        ))),
              ]
              else...[
                Center(
                  child:Image.file(File(attributeCategoryModel.imagePath!),height: 50,),
                ),
                Positioned(
                    bottom: 3,
                    child: Container(
                      width: 105,
                      padding: EdgeInsets.all(2),
                      color: Color(0xccffffff),
                      child: Text((attributeCategoryModel.displayName==null||attributeCategoryModel.displayName.isEmpty?attributeCategoryModel.name:attributeCategoryModel.displayName).toUpperCase(),textAlign: TextAlign.center,style: TextStyle(fontSize: 10,fontWeight: FontWeight.bold),),
                    ))

              ]
            ],
          )

      ),
      onTap: () {
        setState(() {
          filterAttributesByCategory(attributeCategoryModel!.serverId!);
        });
      },
    );
  }

  BoxShadow boxShadow(){
    return BoxShadow(
      color: AppTheme.colorLightGrey,
      blurRadius: 1.0, // soften the shadow
      spreadRadius: 1.0, //extend the shadow
      offset: Offset(
        1.0,
        1.0,
      ),
    );
  }
  void filterAttributesByCategory(int categoryId){

    selectedAttributeCatId = categoryId;
    setState(() {
      attributeList = attributeDao.getAttributeByCategory(categoryId);
      attributeList.then((value){
        this.attributes = value;
      });
    });
  }

  /*void addAttributeToOrderedList(BuildContext context, int attributeId){
    print("Nowwwwwwwwwwwwwwwwwwwwwww");
    var orderItemId=Provider.of<OrderTakingWindowProvider>(context,listen:false).orderItemId;
    var orderedItem=Provider.of<OrderTakingWindowProvider>(context,listen:false).orderItemList.firstWhere((element) =>
    element.orderedItemId==orderItemId);
    setState(() {
      List<ItemAttributes> itemAttribues=orderedItem.itemAttributes;

      Iterable<ItemAttributes> checkItems = itemAttribues.where((element) =>
      element.attributeId == attributeId);
      if (checkItems.length==0) {
        List<ItemAttributes> temp=itemAttribues;
        Attribute selectedAttribute =
        this.attributeListTemp.firstWhere((element) =>
        element.attributeId == attributeId);
        ItemAttributes ia = ItemAttributes(
            itemAttributeId: itemAttribues.length+1,
            attributeId: attributeId, orderedItemId: orderItemId, attributeName: selectedAttribute.attributeName,
            quantity: 1, value: selectedAttribute.value,);
        Provider.of<OrderTakingWindowProvider>(context,listen:false).addItemAttribute(orderItemId, ia);

      }
      else{
        setState(() {
          for(var i=0; i<itemAttribues.length; i++){
            Attribute selectedItemAttributes =
            this.attributeListTemp.firstWhere((element) =>
            element.attributeId == attributeId);
            if(itemAttribues[i].attributeId==attributeId && itemAttribues[i].orderedItemId==orderItemId){
              Provider.of<OrderTakingWindowProvider>(context,listen:false).updateItemAttribute(orderItemId, itemAttribues[i].itemAttributeId);
            }
          }
        });

      }
    });

  }*/

  void addAttributeToOrderedList(BuildContext context, AttributeModel attributeModel){
    if(selectedAttributesMap.keys.contains(attributeModel.serverId!)){
      selectedAttributesMap[attributeModel.serverId]!.quantity += 1;
    }
    else{
      attributeModel.quantity = 1;
      selectedAttributesMap[attributeModel.serverId!] = attributeModel;
    }
  }

  /*removeAttributeFromOrderedList(BuildContext context, int attributeId, List<OrderedItem> orderedItems){
    setState(() {
      var orderItemId=Provider.of<OrderTakingWindowProvider>(context,listen:false).orderItemId;
      var selectedOrderedItem=orderedItems.firstWhere((element) =>
      element.orderedItemId==orderItemId);
      selectedOrderedItem.itemAttributes.removeWhere((item) =>
      item.attributeId == attributeId && item.orderedItemId==orderItemId);
    });
  }*/

  removeAttributeFromOrderedList(int attributeId){
    setState(() {
      selectedAttributesMap[attributeId]!.quantity = 0;
      selectedAttributesMap.remove(attributeId);
    });
  }

  /*int findAttributQuantity(int attributeId, List<OrderedItem> itemAttributesSate){
    var orderItemId=Provider.of<OrderTakingWindowProvider>(context,listen:false).orderItemId;
    List<ItemAttributes> ia=[];
    for(var ot in itemAttributesSate)
     ia.addAll(ot.itemAttributes);
    ia.retainWhere((item) {
      return item.attributeId == attributeId && item.orderedItemId==orderItemId;
    });
    return ia.length >0?ia[0].quantity:0;

  }*/

  int findAttributQuantity(int attributeId){
    if(selectedAttributesMap.keys.contains(attributeId)){
      return selectedAttributesMap[attributeId]!.quantity;
    }
    else{
      return 0;
    }
  }


  /*Future<Future<List<AttributeCategory>>> getAttributeCategory() async {
    setState(() {
      attributeCategoryList = attributeCategoryObj.getAttributeCategoryList();
      attributeCategoryList.then((value) {
        attributeCategoryListTemp=value;
      });
    });

    return attributeCategoryList;
  }*/
  Future<Future<List<AttributeCategoryModel>>> getAttributeCategory() async {
    setState(() {
      //attributeCategoryList = attributeCategoryDao.getAllAttributeCategories();
      attributeCategoryList = attributeCategoryDao.getAttributeCategoriesByIds(widget.foodItemsModel.attributeCategoryIds);
      attributeCategoryList.then((value) {
        attributeCategoryListTemp=value;
        filterAttributesByCategory(value.first.serverId!);
      });
    });
    return attributeCategoryList;
  }

  Future<Future<List<AttributeModel>>> getAttribues() async {
    setState(() {
      attributeList = attributeDao.getAllAttributes();
      attributeList.then((value){
        attributes = value;
        //selectedAttributeCatId = attributes.first.categoryID;
        selectedAttributeCatId = attributes.first.catServerId!;
      });
    });
    attributeList.then((value){

    });
    return attributeList;
  }


  updateAttributePosition(int oldIndex, int newIndex) async {
    AttributeModel attributeModel = attributes[oldIndex];
    this.attributes.removeAt(oldIndex);
    this.attributes.insert(newIndex, attributeModel);

    updateAttribute(int index)
    async {
      if(index<attributes.length){
        attributes[index].position = index + 1;
        await attributeDao.updateAttribute(attributes[index]);
        if(selectedAttributesMap.containsKey(attributes[index].id)){
          selectedAttributesMap[attributes[index].id]!.position = attributes[index].position;
        }
        updateAttribute(index+1);
      }
      else{
        setState(() {
          filterAttributesByCategory(selectedAttributeCatId);
        });
      }
    }
    updateAttribute(0);
  }

  updateAttributeCategoryPosition(int oldIndex, int newIndex) async {
    if(oldIndex<newIndex){
      newIndex = newIndex-1;
    }
    AttributeCategoryModel attributeCategoryModel = attributeCategoryListTemp[oldIndex];
    this.attributeCategoryListTemp.removeAt(oldIndex);
    this.attributeCategoryListTemp.insert(newIndex, attributeCategoryModel);

    updateAttributeCategory(int index)
    async {
      if(index<attributeCategoryListTemp.length){
        attributeCategoryListTemp[index].position = index + 1;
        await attributeCategoryDao.updateAttributeCategory(attributeCategoryListTemp[index]);
        /*if(selectedAttributesMap.containsKey(attributes[index].id)){
          selectedAttributesMap[attributes[index].id]!.position = attributes[index].position;
        }*/
        updateAttributeCategory(index+1);
      }
      else{
        /*setState(() {
          this.getAttributeCategory();
        });*/
      }
    }
    updateAttributeCategory(0);
    /*AttributeCategoryModel attributeCategoryModelOldIndex = attributeCategoryListTemp[oldIndex];
    AttributeCategoryModel attributeCategoryModelNewIndex = attributeCategoryListTemp[newIndex];
    int oldIndexPosition = attributeCategoryModelOldIndex.position;
    attributeCategoryModelOldIndex.position = attributeCategoryModelNewIndex.position;
    attributeCategoryModelNewIndex.position = oldIndexPosition;

    await attributeCategoryDao.updateAttributeCategory(attributeCategoryModelOldIndex);
    await attributeCategoryDao.updateAttributeCategory(attributeCategoryModelNewIndex);
    setState(() {
      this.getAttributeCategory();
      //this.getCategoryItems(selectedFoodCategoryId);
    });*/
    /*if(this.attributeCategoryListTemp.length==2){
      pupdaterint("Lenght 2222222222222222222");
      attributeCategoryObj.updateAttributeCategory(AttributeCategory.withId(
          this.attributeCategoryListTemp[0].attributeCategoryId,
          this.attributeCategoryListTemp[0].attributeCategoryName, this.attributeCategoryListTemp[0].color,
          1,
          "Ashebir", this.attributeCategoryListTemp[0].createdAt)).then((data) {
      });
      attributeCategoryObj.updateAttributeCategory(AttributeCategory.withId(
          this.attributeCategoryListTemp[1].attributeCategoryId,
          this.attributeCategoryListTemp[1].attributeCategoryName, this.attributeCategoryListTemp[1].color,
          0,
          "Ashebir", this.attributeCategoryListTemp[1].createdAt)).then((data) {
        this.getAttributeCategory();

      });
    }
    else {
      if (oldIndex > newIndex)
        oldIndex = oldIndex - 1;
      AttributeCategory ac = this.attributeCategoryListTemp.removeAt(oldIndex);
      this.attributeCategoryListTemp.insert(newIndex, ac);

      for (var i = 0; i < this.attributeCategoryListTemp.length; i++) {
        this.attributeCategoryListTemp[i].position = i;
      }

      for (var i = 0; i < this.attributeCategoryListTemp.length; i++) {
        attributeCategoryObj.updateAttributeCategory(AttributeCategory.withId(
            this.attributeCategoryListTemp[i].attributeCategoryId,
            this.attributeCategoryListTemp[i].attributeCategoryName,
            this.attributeCategoryListTemp[i].color,
            this.attributeCategoryListTemp[i].position,
            "Ashebir", this.attributeCategoryListTemp[i].createdAt)).then((
            data) {});
      }
    }
    Future.delayed(const Duration(milliseconds: 200), () {
      setState(() {
        // getAttributeCategory();
      });
    });*/

  }
  int getAttributeCategoryPositionById(int id){
    return attributeCategoryListTemp.where((element) => element.serverId==id).first.position;
  }

}