import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:opti_food_app/assets/images.dart';
import 'package:opti_food_app/data_models/order_model.dart';
import 'package:opti_food_app/database/order_dao.dart';
import 'package:opti_food_app/database/user_dao.dart';
import 'package:opti_food_app/utils/constants.dart';
import 'package:opti_food_app/utils/utility.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../data_models/attribute_model.dart';
import '../../widgets/app_theme.dart';import '../MountedState.dart';
class PreviewOrderList extends StatefulWidget {
  //final Order orderList;
  final OrderModel orderList;
  final String? name;
  const PreviewOrderList(this.orderList, {Key? key, this.name="Manager"}) : super(key: key);


  @override
  State<PreviewOrderList> createState() => _PreviewOrderListState();
}
class _PreviewOrderListState extends MountedState<PreviewOrderList> {
  late SharedPreferences sharedPreferences;

  @override
  void initState(){

    SharedPreferences.getInstance().then((value){
      sharedPreferences = value;
    });

    // getOrderList();
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Dialog(
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.transparent,
      shape:
      const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(bottomLeft: Radius.circular(20), bottomRight: Radius.circular(20),
          topLeft:  Radius.circular(20), topRight:  Radius.circular(20),),
      ),
      insetPadding: EdgeInsets.all(20.0),
      //child:
      //SingleChildScrollView(
      child: Container(
          padding: EdgeInsets.only(top: 20,bottom: 20,left: 10,right: 10),
          child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Text("order".tr().toUpperCase()+" N°${widget.orderList.orderNumber}",style:
                  TextStyle(fontSize: 22,color: Colors.black),),
                ),
                Divider(
                  color: Colors.black,
                ),

                if(widget.orderList.orderType == ConstantOrderType.ORDER_TYPE_DELIVERY)
                  ...[
                    if(widget.orderList.customer!=null)
                      ...[
                        Padding(padding: EdgeInsets.all(5),
                          child: Row(
                            children: [
                              Text("customer".tr(),style:
                              TextStyle(fontSize: 16,color: Colors.black),),
                              Text(": ${widget.orderList.customer!.firstName+" "+widget.orderList.customer!.lastName}",style:
                              TextStyle(fontSize: 16,color: Colors.black),)
                            ],
                          ),
                        ),
                        Padding(padding: EdgeInsets.all(5),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("address".tr(),style:
                              TextStyle(fontSize: 16,color: Colors.black),),

                              Flexible(child: Text(": ${widget.orderList.customer!.getDefaultAddress().address}",style:
                              TextStyle(fontSize: 16,color: Colors.black)),)
                            ],
                          ),
                        ),
                        Padding(padding: EdgeInsets.all(5),
                          child: Row(
                            children: [
                              Text("phone".tr(),style:
                              TextStyle(fontSize: 16,color: Colors.black),),
                              Text(": ${widget.orderList.customer!.phoneNumber}",style:
                              TextStyle(fontSize: 16,color: Colors.black),),
                            ],
                          ),
                        ),
                        if(widget.orderList.customer!.getDefaultAddress().companyModel!=null)...[
                          Padding(padding: EdgeInsets.all(5),
                            child: Row(
                              children: [
                                Text("company".tr(),style:
                                TextStyle(fontSize: 16,color: Colors.black),),
                                Text(": ${widget.orderList.customer!.getDefaultAddress().companyModel!.name}",style:
                                TextStyle(fontSize: 16,color: Colors.black),),
                              ],
                            ),
                          ),
                        ],
                        if(widget.orderList.paymentMode!=null)...[
                          Padding(padding: EdgeInsets.all(5),
                            child: Row(
                              children: [
                                Text("paymentMode".tr(),style:
                                TextStyle(fontSize: 16,color: Colors.black),),
                                Text(": ${widget.orderList.paymentMode!}",style:
                                TextStyle(fontSize: 16,color: Colors.black),),
                              ],
                            ),
                          ),
                        ]
                      ],
                  ]
                else
                  ...[
                    if(widget.orderList.orderName!=null && widget.orderList.orderName.isNotEmpty)
                      ...[
                        Padding(padding: EdgeInsets.all(5),
                          child: Row(
                            children: [
                              Text("orderName".tr(),style:
                              TextStyle(fontSize: 16,color: Colors.black),),
                              Text(": ${widget.orderList.orderName}",style:
                              TextStyle(fontSize: 16,color: Colors.black),),
                            ],
                          ),
                        ),
                      ],
                    if(widget.orderList.tableNumber!=null && widget.orderList.tableNumber.isNotEmpty)
                      ...[
                        Padding(padding: EdgeInsets.all(5),
                          child: Row(
                            children: [
                              Text("tableNumber".tr(),style:
                              TextStyle(fontSize: 16,color: Colors.black),),
                              Text(": ${widget.orderList.tableNumber}",style:
                              TextStyle(fontSize: 16,color: Colors.black),),
                            ],
                          ),
                        ),
                      ],
                  ],

                Padding(padding: EdgeInsets.all(5),
                  child: Row(
                    children: [
                      Text("type".tr(),style:
                      TextStyle(fontSize: 16,color: Colors.black),),
                      Text(": ${widget.orderList.orderType==ConstantOrderType.ORDER_TYPE_DELIVERY?"Delivery":
                      widget.orderList.orderService==ConstantRestaurantOrderType.RESTAURANT_ORDER_TYPE_EAT_IN?"Eat In":"Takeaway"}",style:
                      TextStyle(fontSize: 16,color: Colors.black),),
                    ],
                  ),
                ),

                Padding(padding: EdgeInsets.all(5),
                  child: Row(
                    children: [
                      Text("sender".tr(),style:
                      TextStyle(fontSize: 16,color: Colors.black),),
                      Text(": ${widget.name}",style:
                      TextStyle(fontSize: 16,color: Colors.black),),
                    ],
                  ),
                ),
                Padding(padding: EdgeInsets.all(5),
                  child: Row(
                    children: [
                      Text("Created Date".tr(),style:
                      TextStyle(fontSize: 16,color: Colors.black),),
                      Text(": ${Utility().convertDateFormat(widget.orderList.createdAt.split(" ")[0])}",style:
                      TextStyle(fontSize: 16,color: Colors.black),),
                    ],
                  ),
                ),
                Padding(padding: EdgeInsets.all(5),
                  child: Row(
                    children: [
                      Text("time".tr(),style:
                      TextStyle(fontSize: 16,color: Colors.black),),
                      Text(widget.orderList.createdAt.toString().contains('T')?widget.orderList.createdAt.split(
                          "T")[1].substring(
                          0, 5):widget.orderList.createdAt.split(
                          " ")[1].split(".")[0].substring(
                          0, 5),
                        style:
                        TextStyle(fontSize: 16,color: Colors.black),),
                    ],
                  ),
                ),
                if(widget.orderList.comment!=null && widget.orderList.comment.isNotEmpty)
                  ...[
                    Padding(padding: EdgeInsets.all(5),
                      child: Row(
                        children: [
                          Text("comment".tr(),style:
                          TextStyle(fontSize: 16,color: Colors.black),),
                          Text(": ${widget.orderList.comment}",style:
                          TextStyle(fontSize: 16,color: Colors.black),),
                        ],
                      ),
                    ),
                  ],
                Divider(
                  color: Colors.black,
                ),
                getOrderItems(),
                Divider(
                  color: Colors.black,
                ),
                Container(
                  child: ListTile(
                    leading: Text("total".tr().toUpperCase()+":", style: TextStyle(color: AppTheme.colorDarkGrey, fontSize: 18),),
                    trailing: Text(' ${Utility().formatPrice(widget.orderList.totalPrice)}', style: TextStyle(color: AppTheme.colorDarkGrey, fontWeight: FontWeight.bold, fontSize: 18),),
                    //trailing: Text('${widget.orderList.totalPrice}€', style: TextStyle(color: AppTheme.colorDarkGrey, fontSize: 18),),
                  ),
                )
              ]
          )
      ),
      //)
    );
  }

  /* @override
  Widget build(BuildContext context) {
    return
      Center(
        child: Padding(

          padding: const EdgeInsets.fromLTRB(0, 45, 0, 0),
          child: Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.0),
              ),
              alignment: Alignment.topCenter,
              elevation: 100,
              backgroundColor: Colors.white,
              insetPadding: EdgeInsets.fromLTRB(20, 20, 20, 70),
              //child: Stack(
              child: Stack(
                children:[
              Padding(
                        padding: const EdgeInsets.fromLTRB(12, 20, 15, 0),
                        child: Column(
                          children: [
                            Text("ORDER N°${widget.orderList.orderNumber}",style:
                            TextStyle(fontSize: 22,color: Colors.black),),
                            Divider(
                              color: Colors.black,
                            ),
                            Transform.translate(
                              offset: Offset(0, -5),
                              child: Column(
                                children: [
                                  Row(
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.only(top: 8,left: 10),
                                        child: Text("Type: ",style:
                                        TextStyle(fontSize: 16,color: Colors.black),),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.only(top: 8),
                                        child: Column(
                                          children: [
                                            if(widget.orderList.orderService.orderService =="Delivery")...[
                                              Text("Delivery", style:
                                              TextStyle(fontSize: 16,color: Colors.black)),
                                            ]else if(widget.orderList.orderService.orderService =="Take Away")...[
                                              Text("Take Away", style:
                                              TextStyle(fontSize: 16,color: Colors.black))
                                            ]
                                            else...[
                                                Text("Eat In", style:
                                                TextStyle(fontSize: 16,color: Colors.black))
                                              ]

                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                  if(widget.orderList.orderName!="" && widget.orderList.orderName!=null &&widget.orderList.orderService.orderService !="Delivery")...[
                                      const Padding(
                                        padding: const EdgeInsets.only(top: 8,left: 10),
                                        child: Text("Name: ",style:
                                        TextStyle(fontSize: 16,color: Colors.black),),
                                      ),
                                      Padding(
                                        padding: EdgeInsets.only(top: 8),
                                        child: Text(widget.orderList.orderName,style:
                                        TextStyle(fontSize: 16,color: Colors.black),),
                                      ),
                                    ],
        ]
                                  ),
                                  Row(
                                    children: const [
                                      Padding(
                                        padding: EdgeInsets.only(top: 8,left: 10),
                                        child: Text("Sender",style:
                                        TextStyle(fontSize: 16,color: Colors.black),),
                                      ),
                                      Padding(
                                        padding: EdgeInsets.only(top: 8),
                                        child: Text(": Manager",style:
                                        TextStyle(fontSize: 16,color: Colors.black),),
                                      ),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      const Padding(
                                        padding: EdgeInsets.only(top: 8,left: 10),
                                        child: Text("Time",style:
                                        TextStyle(fontSize: 16,color: Colors.black),),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.only(top: 8),
                                        child: Text(": ${widget.orderList.createdAt.split(
                                            " ")[1].split(".")[0].substring(
                                            0, 5)}",style:
                                        TextStyle(fontSize: 16,color: Colors.black),),
                                      ),

                                    ],
                                  ),
                                  const Padding(
                                    padding: EdgeInsets.only(top: 3),
                                    child: Divider(
                                      color: Colors.black,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            ],
                        )
              ),

              SafeArea(
                child: Container(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 5, top: 170),
                    child: ListView.builder(
                                                itemCount: widget.orderList.orderedItems.length,
                                                itemBuilder: (context, index) => Container(
                                                  height: 40,
                                                  child: ListTile(
                                                      subtitle: Transform.translate(
                                                        offset: Offset(0,-6),
                                                        child: Container(child:  Row(
                                                          children: [
                                                            widget.orderList.orderedItems[index].orderedItemAttribute.length!=0? SvgPicture.asset("assets/images/icons/turn-right.svg", height: 12, color: AppTheme.colorMediumGrey):Text(""),
                                                            Padding(
                                                              padding: EdgeInsets.fromLTRB(3, 0, 0, 0),
                                                              child:Wrap(
                                                                children: List
                                                                    .generate(
                                                                  widget.orderList.orderedItems[index].orderedItemAttribute.length,
                                                                      (indexAtt) {
                                                                    return Text(
                                                                      "${widget.orderList.orderedItems[index].orderedItemAttribute[indexAtt]
                                                                          .attribute
                                                                          .attributeName}, ",
                                                                      style: const TextStyle(
                                                                          fontSize: 9,
                                                                          fontStyle: FontStyle
                                                                              .italic,
                                                                          color: Color(
                                                                              0xffa2a2a2)),);
                                                                  },
                                                                ),
                                                              ),
                                                              // Text('${samples[index].orderAttribute}', style:
                                                              // TextStyle(fontSize: 12,fontStyle: FontStyle.italic,
                                                              //     color: AppTheme.colorMediumGrey),),
                                                            ),
                                                          ],
                                                        ),
                                                        ),
                                                      ),
                                                      // leading: Icon(Icons.person,),
                                                      title: Text('${widget.orderList.orderedItems[index].item.itemName}', style: TextStyle(color: AppTheme.colorDarkGrey, fontSize: 18),),
                                                      trailing: Transform.translate(
                                                          offset: Offset(-10, -4),
                                                          //${widget.orderList.orderedItems[index].item.itemPrice.last.eatInPrice}
                                                          child: Text("x${widget.orderList.orderedItems[index].quantity}    "
                                                              "${widget.orderList.orderedItems[index].itemPrice.defaultPrice.toStringAsFixed(2).replaceAll(".", ",")}€", style: TextStyle(color: AppTheme.colorDarkGrey, fontSize: 18))),
                                                      // trailing: Row(
                                                      //   children: [
                                                      //     Text("data"),
                                                      //     Text("data"),
                                                      //   ],
                                                      // ),
                                                      // trailing: Container(
                                                      //   height: MediaQuery.of(context).size.height*0.1,
                                                      //   width: MediaQuery.of(context).size.width*0.25,
                                                      // )),
                                                 // <-- Radius
                                                  ),
                                                  // margin: const EdgeInsets.only(top: 20.0),

                                                ),
                  ),
                  ),
                ),
              ),


    ],
          ),

          ),
        ),
      );

  }*/
  /*Widget getOrderItems()
  {
    return ListView.builder(
      scrollDirection: Axis.vertical,
      shrinkWrap: true,
      //itemCount: widget.orderList.orderedItems.length,
      itemCount: widget.orderList.foodItems.length,
      itemBuilder: (context, index) =>
      Container(
        height: 40,
        width: double.infinity,
        child:
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: double.infinity,
              child:
            Row(
              //mainAxisSize: MainAxisSize.max,
              children: [
                Flexible(
                    flex: 3,
                    child:Column(
                      children: [
                        Flexible(
                          flex: 1,
                          child: Text('${widget.orderList.foodItems[index].name}',textAlign: TextAlign.start, style: TextStyle(color: AppTheme.colorDarkGrey, fontSize: 16,backgroundColor: Colors.red),),),

                        if(widget.orderList.foodItems[index].selectedAttributes.isNotEmpty)
                          ...[
                            showAttributes(widget.orderList.foodItems[index].selectedAttributes),
                          ]
                      ],
                    )

                ),

                Flexible(
                    flex: 1,
                    child:
                    Column(
                      children: [
                        Wrap(
                          children: [
                            Padding(padding: EdgeInsets.only(right: 7),
                              child: Text(
                                "${widget.orderList.foodItems[index].discountPercentage>0?"-"+widget.orderList.foodItems[index].discountPercentage.toString()+"%":""}",
                                style: TextStyle(color: AppTheme.colorDarkGrey, fontSize: 16,fontStyle: FontStyle.italic),
                              ),
                            ),
                            Text("x${widget.orderList.foodItems[index].quantity}  "
                                "${(Utility().calculateItemPrice(widget.orderList.foodItems[index])).toStringAsFixed(2).replaceAll(".", ",")}€", style: TextStyle(color: AppTheme.colorDarkGrey, fontSize: 16)),
                          ],
                        ),
                      ],
                    )
                )
              ],
            ),
            )
          ],
        ),
      )

    );
  }*/
  Widget getOrderItems()
  {
    return ListView.builder(
      scrollDirection: Axis.vertical,
      shrinkWrap: true,
      //itemCount: widget.orderList.orderedItems.length,
      itemCount: widget.orderList.foodItems.length,
      itemBuilder: (context, index) => ListTile(
          dense: true,
          contentPadding: EdgeInsets.all(0),
          leading: Container(
            // alignment: Alignment.center,
            //color: Colors.amber,
              child:Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  //Expanded(
                  Flexible(
                    flex: 1,
                    child:
                    Container(
                      //color: Colors.red,
                      child: Text('${widget.orderList.foodItems[index].name}',textAlign: TextAlign.start,
                        style: TextStyle(color: AppTheme.colorDarkGrey, fontSize: 16),
                      ),),
                  ),
                  if(widget.orderList.foodItems[index].selectedAttributes!=null && widget.orderList.foodItems[index].selectedAttributes.isNotEmpty)
                    ...[
                      showAttributes(widget.orderList.foodItems[index].selectedAttributes),
                    ]
                ],
              )

          ),
          trailing:
          Container(
            //alignment: Alignment.topRight,
            //color: Colors.green,
              child:
              Column(
                children: [
                  Wrap(
                    children: [
                      Padding(padding: EdgeInsets.only(right: 7),
                        child: Text(
                          "${widget.orderList.foodItems[index].discountPercentage>0?"-"+widget.orderList.foodItems[index].discountPercentage.toString()+"%":""}",
                          style: TextStyle(color: AppTheme.colorDarkGrey, fontSize: 12,fontStyle: FontStyle.italic),
                        ),
                      ),
                      Text("x${widget.orderList.foodItems[index].quantity} ",
                          style: TextStyle(color: AppTheme.colorRed, fontSize: 12)),
                      Text(
                          "${(Utility().formatPrice(Utility().calculateItemPrice(widget.orderList.orderType,widget.orderList.orderService,widget.orderList.foodItems[index])))}",
                          style: TextStyle(color: AppTheme.colorDarkGrey, fontWeight: FontWeight.bold, fontSize: 12)),
                    ],
                  ),
                ],
              )
          )
      ),
    );
  }
  Widget showAttributes(List<AttributeModel> attributeList)
  {
    return Wrap(
      children: [
        attributeList.length>0?
        Container(
          padding: EdgeInsets.fromLTRB(0, 0, 0, 5),
          child: SvgPicture.asset(AppImages.turnRightIcon,
              height: 12,
              color: Color(0xffa2a2a2)),
        ):Container(),
        for(var item in attributeList)
          Container(
            padding: EdgeInsets.fromLTRB(0, 0, 0, 5),
            color: Colors.white,
            child: attributeList[attributeList.length-1].id==item.id?
            (item.quantity>1?Text(" ${item.quantity}x${item.name}", style:TextStyle(
                fontSize: 12, color: Color(0xffa2a2a2), fontStyle: FontStyle.italic),
            ):Text(" ${item.name}", style:TextStyle(
                fontSize: 12, color: Color(0xffa2a2a2), fontStyle: FontStyle.italic),
            )):
            (item.quantity>1?Text(" ${item.quantity}x${item.name}"
                ", ", style:TextStyle(
                fontSize: 12, color: Color(0xffa2a2a2), fontStyle: FontStyle.italic),
            ):Text(" ${item.name}, ", style:TextStyle(
                fontSize: 12, color: Color(0xffa2a2a2), fontStyle: FontStyle.italic),
            )),
          ),
      ],
    );
  }
}
