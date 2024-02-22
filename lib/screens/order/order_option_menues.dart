import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:opti_food_app/assets/images.dart';
import 'package:opti_food_app/screens/order/restaurant_group_order.dart';

import 'package:opti_food_app/screens/order/order_taking_window.dart';
import 'package:opti_food_app/widgets/app_theme.dart';
import '../../data_models/order_model.dart';
import '../../data_models/service_activation_model.dart';
import '../../database/service_activation_dao.dart';
import '../../utils/constants.dart';
import '../option_menu_popups/delete_order.dart';
import 'ordered_lists.dart';
import '../MountedState.dart';
class OrderOptionMenues extends StatefulWidget {
  Function onSelect;
  final OrderModel orderModel;
  //OrderOptionMenues({Key? key, required this.id}) : super(key: key);
  OrderOptionMenues({Key? key,required this.orderModel,this.onSelect =  _myDefaultFunc}) : super(key: key);

  @override
  State<OrderOptionMenues> createState() => _OrderOptionMenuesState();

  static _myDefaultFunc()
  {}
}
class _OrderOptionMenuesState extends MountedState<OrderOptionMenues> {

  ServiceActivationModel serviceActivationModel=ServiceActivationModel(1, true, true, true, true, false);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
      child: Dialog(
          // 5 1 1 0
        backgroundColor: Color.fromARGB(5, 1, 1, 0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.0),
        ),
        alignment: Alignment.topCenter,
        elevation: 100,
        // backgroundColor: AppTheme.colorLightGrey,
        insetPadding: EdgeInsets.fromLTRB(0, 0, 0, 0),
        child: Stack(
          children:[
            Padding(
                padding: const EdgeInsets.fromLTRB(12, 20, 15, 0),
                child: Column(
                  children: [
                    // Text("ORDER N°30",style:
                    // TextStyle(fontSize: 22,color: Colors.black),),
                    // Divider(
                    //   color: Colors.black,
                    // ),
                    Transform.translate(
                      offset: Offset(0, -5),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Container(
                                // color:Colors.grey,
                                width: MediaQuery.of(context).size.width*0.3,
                                child: Padding(
                                  padding: const EdgeInsets.only(top: 8,left: 0, bottom: 30,right: 10),
                                  child:    Container(
                                    height: 40,
                                    child: FloatingActionButton(
                                      elevation: 0,
                                      backgroundColor: AppTheme.colorDarkGrey,
                                      child:Icon(Icons.close),
                                      onPressed: () {
                                        Navigator.pop(context);
                                      },
                                    ),
                                  ),
                                ),
                              ),
                              Container(
                                width: MediaQuery.of(context).size.width*0.6,
                                // height: 90,
                                child: Padding(
                                  padding: const EdgeInsets.only(top: 8,bottom: 30,right: 10),

                                ),
                              ),
                            ],
                          ),
                          createOptionMenu(SvgPicture.asset(AppImages.editRedIcon, height: 30),Colors.white,"EDIT" ,(){
                            Navigator.pop(context);
                            widget.onSelect(OrderOptionMenuesAction.ACTION_EDIT);
                          }),
                          createOptionMenu(SvgPicture.asset(AppImages.commentGreenIcon, height: 30),Colors.white,"COMMENT", (){
                            Navigator.pop(context);
                            widget.onSelect(OrderOptionMenuesAction.ACTION_COMMENT);
                          }),
                          if(widget.orderModel.attachedBy==0)...[
                            createOptionMenu(SvgPicture.asset(AppImages.groupWhiteIcon, height: 30, color: Colors.white),Color(0xff30ce00),"GROUP", (){
                              Navigator.pop(context);
                              widget.onSelect(OrderOptionMenuesAction.ACTION_GROUP);
                            }),
                          ],
                          if(widget.orderModel.orderType == ConstantOrderType.ORDER_TYPE_RESTAURANT && serviceActivationModel.tableManagement==true)
                            ...[
                              if(widget.orderModel.orderService == ConstantRestaurantOrderType.RESTAURANT_ORDER_TYPE_EAT_IN && serviceActivationModel.tableManagement==true)
                                ...[
                                  createOptionMenu(
                                      SvgPicture.asset(AppImages.dinnerTableIcon, height: 30,color: Colors.white),AppTheme.colorDarkGrey,"TABLE NUMBER", () {
                                    Navigator.pop(context);
                                    widget.onSelect(OrderOptionMenuesAction.ACTION_TABLE_NUMBER);
                                  })
                                ]
                            ],
                          if(widget.orderModel.orderType == ConstantOrderType.ORDER_TYPE_DELIVERY)
                            ...[
                              createOptionMenu(
                                  SvgPicture.asset(AppImages.assignIcon, height: 30,color: Colors.white),AppTheme.colorDarkGrey,"ASSIGN", () {
                                Navigator.pop(context);
                                widget.onSelect(OrderOptionMenuesAction.ACTION_ASSIGN_DELIVERYBOY);
                              })
                            ],
                          createOptionMenu(SvgPicture.asset(AppImages.printWhiteIcon, height: 30,color: Colors.white),Color(0xfffdc403),"PRINT", (){
                            Navigator.pop(context);
                            widget.onSelect(OrderOptionMenuesAction.ACTION_PRINT);
                          }),
                          createOptionMenu(SvgPicture.asset(AppImages.deleteIcon, height: 30,color: Colors.white),AppTheme.colorRed,"DELETE", (){
                            Navigator.pop(context);
                            widget.onSelect(OrderOptionMenuesAction.ACTION_DELETE);
                          }),
                        ],
                      ),
                      /*child: Column(
                        children: [
                          Row(
                            children: [
                              Container(
                                // color:Colors.grey,
                                width: MediaQuery.of(context).size.width*0.3,
                                child: Padding(
                                  padding: const EdgeInsets.only(top: 8,left: 0, bottom: 30,right: 10),
                                  child:    Container(
                                    height: 40,
                                    child: FloatingActionButton(
elevation: 0,

                                      backgroundColor: AppTheme.colorDarkGrey,

                                      child:Icon(Icons.close),
                                      onPressed: () {
                                        *//*Navigator.of(context).push(MaterialPageRoute(builder:
                                            (context)=>OrderedList(id: "",isEatIn:"", isTakeAway:"")));*//*
                                        Navigator.pop(context);
                                      },
                                    ),
                                  ),
                                ),
                              ),
                              Container(
                                width: MediaQuery.of(context).size.width*0.6,
                                // height: 90,
                                child: Padding(
                                  padding: const EdgeInsets.only(top: 8,bottom: 30,right: 10),

                                ),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              Container(
                                width: MediaQuery.of(context).size.width*0.3,
                                child: Padding(
                                  padding: const EdgeInsets.only(top: 8,left: 0, bottom: 30,right: 10),
                                  child:  Container(
                                    height: 50,
                                    child: FloatingActionButton(
                                      elevation: 0,

                                      backgroundColor: Colors.white,

                                      child: SvgPicture.asset("assets/images/icons/edit-red.svg", height: 30),
                                      onPressed: () {
                                        *//*Navigator.of(context).push(MaterialPageRoute(builder: (context)=>OrderTakingWindow(
                                          orderName: "", orderItemId: 1,data: [], orderedItems: [],)));*//*
                                        Navigator.pop(context);
                                        widget.onSelect(OrderOptionMenuesAction.ACTION_EDIT);
                                      },
                                    ),
                                  ),
                                ),
                              ),
                              Container(
                                width: MediaQuery.of(context).size.width*0.6,
                                // height: 90,
                                child: Padding(
                                  padding: const EdgeInsets.only(top: 8,bottom: 30,right: 10),
                                  child: ElevatedButton(

                                    onPressed: () {
                                      *//*Navigator.of(context).push(MaterialPageRoute(builder: (context)=>OrderTakingWindow(
                                        orderName: "", orderItemId: 1,data: [], orderedItems: [],)));*//*
                                      Navigator.pop(context);
                                      widget.onSelect(OrderOptionMenuesAction.ACTION_EDIT);
                                    },
                                    style: ElevatedButton.styleFrom(
                                      //<-- SEE HERE
                                      elevation: 0,
                                      primary: Colors.white,
                                      side: BorderSide(
                                        width: 1.3,
                                      ),
                                    ),

                                    child: Text('EDIT',style: TextStyle(color: Colors.black),),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              Container(
                                width: MediaQuery.of(context).size.width*0.3,
                                child: Padding(
                                  padding: const EdgeInsets.only(top: 8,left: 0, bottom: 30,right: 10),
                                  child:  Container(
                                    height: 50,
                                    child: FloatingActionButton(
                                      elevation: 0,

                                      backgroundColor: Colors.white,

                                      child: SvgPicture.asset("assets/images/icons/comment-grn.svg", height: 30),
                                      onPressed: () {
                                        Navigator.of(context).push(MaterialPageRoute(builder: (context)=>
                                            OrderedList(id: "",isEatIn:"", isTakeAway:"")));

                                        showDialog(context: context, builder: (BuildContext
                                        context) {
                                          return Comment(flag: "", orderName: "",
                                              orderedItemId: 0,
                                              data: [],
                                              orderedItems: []);
                                        });
                                      },
                                    ),
                                  ),
                                ),
                              ),
                              Container(
                                width: MediaQuery.of(context).size.width*0.6,
                                // height: 90,
                                child: Padding(
                                  padding: const EdgeInsets.only(top: 8,bottom: 30,right: 10),
                                  child: ElevatedButton(

                                    onPressed: () {
                                      Navigator.of(context).push(MaterialPageRoute(builder: (context)=>
                                      OrderedList(id: "", isEatIn:"", isTakeAway:"")));

                                      showDialog(context: context, builder: (BuildContext
                                      context) {
                                      return Comment(flag: "", orderName: "",
                                          orderedItemId: 0,
                                          data: [],
                                          orderedItems: []);
                                      });

                                    },
                                    style: ElevatedButton.styleFrom(
                                      //<-- SEE HERE
                                      primary: Colors.white,
                                      elevation: 0,
                                      side: BorderSide(
                                        width: 1.3,

                                      ),
                                    ),

                                    child: Text('COMMENT',style: TextStyle(color: Colors.black),),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              Container(
                                width: MediaQuery.of(context).size.width*0.3,
                                child: Padding(
                                  padding: const EdgeInsets.only(top: 8,left: 0, bottom: 30,right: 10),
                                  child:  Container(
                                    height: 50,
                                    child: FloatingActionButton(
                                      elevation: 0,
                                      backgroundColor: Color(0xff30ce00),
                                      child: SvgPicture.asset("assets/images/icons/group-wht.svg", height: 30, color: Colors.white),
                                      onPressed: () {

                                        Navigator.of(context).push(MaterialPageRoute(builder: (context)=>
                                            RestaurantGroupOrder(id: '',)));
                                      },
                                    ),
                                  ),
                                  // SvgPicture.asset("menu/group-wht.svg", height: 30, color: AppTheme.colorRed,),
                                ),
                              ),
                              Container(
                                width: MediaQuery.of(context).size.width*0.6,
                                // height: 90,
                                child: Padding(
                                  padding: const EdgeInsets.only(top: 8,bottom: 30,right: 10),
                                  child: ElevatedButton(
                                    onPressed: () {
                                      Navigator.of(context).push(MaterialPageRoute(builder: (context)=>
                                          RestaurantGroupOrder(id: '',)));
                                    },
                                    style: ElevatedButton.styleFrom(
                                      //<-- SEE HERE
                                      primary: Colors.white,
                                      elevation: 0,
                                      side: BorderSide(
                                        width: 1.3,
                                      ),
                                    ),
                                    child: Text('GROUP',style: TextStyle(color: Colors.black),),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              Container(
                                width: MediaQuery.of(context).size.width*0.3,
                                child: Padding(
                                  padding: const EdgeInsets.only(top: 8,left: 0, bottom: 30,right: 10),
                                  child: Container(
                                    height: 50,
                                    child: FloatingActionButton(
                                      elevation: 0,

                                      backgroundColor: AppTheme.colorDarkGrey,

                                      child: SvgPicture.asset("assets/images/icons/dinner-table.svg", height: 30,color: Colors.white),
                                      onPressed: () {

                                      },
                                    ),
                                  ),
                                ),
                              ),
                              Container(
                                width: MediaQuery.of(context).size.width*0.6,
                                // height: 90,
                                child: Padding(
                                  padding: const EdgeInsets.only(top: 8,bottom: 30,right: 10),
                                  child: ElevatedButton(

                                    onPressed: () {},
                                    style: ElevatedButton.styleFrom(
                                      //<-- SEE HERE
                                      primary: Colors.white,
                                      elevation: 0,
                                      side: BorderSide(
                                        width: 1.3,
                                      ),
                                    ),

                                    child: Text('TABLE NUMBER',style: TextStyle(color: Colors.black),),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              Container(
                                width: MediaQuery.of(context).size.width*0.3,
                                child: Padding(
                                  padding: const EdgeInsets.only(top: 8,left: 0, bottom: 30,right: 10),
                                  child: Container(
                                    height: 50,
                                    child: FloatingActionButton(
                                      elevation: 0,

                                      backgroundColor: Color(0xfffdc403),

                                      child: SvgPicture.asset("assets/images/icons/print-wht.svg", height: 30,color: Colors.white),
                                      onPressed: () {

                                      },
                                    ),
                                  ),
                                  // SvgPicture.asset("images/optimisation.svg", height: 30, color: Colors.white,),
                                ),
                              ),
                              Container(
                                width: MediaQuery.of(context).size.width*0.6,
                                // height: 90,
                                child: Padding(
                                  padding: const EdgeInsets.only(top: 8,bottom: 30,right: 10),
                                  child: ElevatedButton(
                                    onPressed: () {},
                                    style: ElevatedButton.styleFrom(
                                      //<-- SEE HERE
                                      primary: Colors.white,
                                      elevation: 0,
                                      side: BorderSide(
                                        width: 1.3,
                                      ),
                                    ),
                                    child: Text('PRINT',style: TextStyle(color: Colors.black),),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              Container(
                                width: MediaQuery.of(context).size.width*0.3,
                                child: Padding(
                                  padding: const EdgeInsets.only(top: 8,left: 0, bottom: 30,right: 10),
                                  child: Container(
                                    height: 50,
                                    child: FloatingActionButton(
                                      elevation: 0,
                                      //backgroundColor: AppTheme.colorRed,
                                      backgroundColor: AppTheme.colorRed,
                                      child: SvgPicture.asset("assets/images/icons/delete.svg", height: 30,color: Colors.white),
                                      onPressed: () {
                                        *//*Navigator.of(context).push(MaterialPageRoute(builder:
                                            (context)=>OrderedList(id: "",isEatIn:"", isTakeAway:"")));

                                        showDialog(context: context, builder: (BuildContext
                                        context) {
                                          return DeleteOrder(id: widget.id);
                                        });*//*

                                        Navigator.pop(context);
                                        widget.onSelect(OrderOptionMenuesAction.ACTION_DELETE);
                                      },
                                    ),
                                  ),
                                ),
                              ),
                              Container(
                                width: MediaQuery.of(context).size.width*0.6,
                                // height: 90,
                                child: Padding(
                                  padding: const EdgeInsets.only(top: 8,bottom: 30,right: 10),
                                  child: ElevatedButton(

                                    onPressed: () {
                                      *//*Navigator.of(context).push(MaterialPageRoute(builder:
                                          (context)=>OrderedList(id: "",isEatIn:"",isTakeAway:"")));

                                      showDialog(context: context, builder: (BuildContext
                                      context) {
                                        return DeleteOrder(id: widget.id);
                                      });*//*

                                      Navigator.pop(context);
                                      widget.onSelect(OrderOptionMenuesAction.ACTION_DELETE);
                                    },
                                    style: ElevatedButton.styleFrom(
                                      //<-- SEE HERE
                                      primary: Colors.white,
                                      elevation: 0,
                                      side: BorderSide(
                                        width: 1.3,
                                      ),
                                    ),
                                    child: Text('DELETE',style: TextStyle(color: Colors.black),),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),*/
                    ),
                  ],
                )
            ),
          ],
        ),

      ),
    );
  }

  Widget createOptionMenu(SvgPicture svg,Color svgBackground,String title,Function onSelect)
  {
    return Row(
      children: [
        Container(
          width: MediaQuery.of(context).size.width*0.3,
          child: Padding(
            padding: const EdgeInsets.only(top: 8,left: 0, bottom: 30,right: 10),
            child:  Container(
              height: 50,
              child: FloatingActionButton(
                elevation: 0,

                //backgroundColor: Colors.white,
                backgroundColor: svgBackground,

                //child: SvgPicture.asset(svgPath, height: 30),
                child: svg,
                onPressed: () {
                  /*Navigator.of(context).push(MaterialPageRoute(builder: (context)=>OrderTakingWindow(
                                          orderName: "", orderItemId: 1,data: [], orderedItems: [],)));*/
                  //Navigator.pop(context);
                  //widget.onSelect(OrderOptionMenuesAction.ACTION_EDIT);
                  onSelect();
                },
              ),
            ),
          ),
        ),
        Container(
          width: MediaQuery.of(context).size.width*0.6,
          // height: 90,
          child: Padding(
            padding: const EdgeInsets.only(top: 8,bottom: 30,right: 10),
            child: ElevatedButton(

              onPressed: () {
                /*Navigator.of(context).push(MaterialPageRoute(builder: (context)=>OrderTakingWindow(
                                        orderName: "", orderItemId: 1,data: [], orderedItems: [],)));*/
                //Navigator.pop(context);
                //widget.onSelect(OrderOptionMenuesAction.ACTION_EDIT);
                onSelect();
              },
              style: ElevatedButton.styleFrom(
                surfaceTintColor: Colors.transparent,
                //<-- SEE HERE
                elevation: 0,
                primary: Colors.white,
                side: BorderSide(
                  width: 1.3,
                ),
              ),

              child: Text(title,style: TextStyle(color: Colors.black),),
            ),
          ),
        ),
      ],
    );
  }

  getAllServiceActivation() async{
    Future<List<ServiceActivationModel>> serviceActivationList = ServiceActivationDao().getAllServiceActivation();
    serviceActivationList.then((value) async{
      setState((){
        if(value.length>0){
          serviceActivationModel = value[0];
        }
      });

    });
  }
}

class OrderOptionMenuesAction
{
  // actions for all delivery, take away and eat it
  static const String ACTION_EDIT = "action_edit";
  static const String ACTION_COMMENT = "action_comment";
  static const String ACTION_GROUP = "action_group";
  static const String ACTION_PRINT = "action_print";
  static const String ACTION_DELETE = "action_delete";

  // actions for eat it only
  static const String ACTION_TABLE_NUMBER = "action_table_number";

  //actions for delivery only
  static const String ACTION_ASSIGN_DELIVERYBOY = "action_assign_deliveryboy";
}
