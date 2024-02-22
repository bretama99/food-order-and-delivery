import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:opti_food_app/screens/order/order_taking_window.dart';

import '../../widgets/app_theme.dart';
import '../MountedState.dart';

class DiscountWindow extends StatefulWidget {
  int discount;
  Function onDiscountSubmit;
  DiscountWindow(this.discount,this.onDiscountSubmit,{Key? key}) : super(key: key);
  @override
  State<DiscountWindow> createState() => _DiscountWindowState();
}

class _DiscountWindowState extends MountedState<DiscountWindow> {
  String discount="";
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }
  @override
  void initState() {
    super.initState();
    discount = widget.discount==0?"":widget.discount.toString();
  }

  Widget getDiscountWindow()
  {
    return Dialog(
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.transparent,
        shape:
        const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(bottomLeft: Radius.circular(20), bottomRight: Radius.circular(20),
            topLeft:  Radius.circular(20), topRight:  Radius.circular(20),),
        ),
        child:
        SingleChildScrollView(
          child: Container(
          padding: EdgeInsets.only(top: 20,left: 10,right: 10),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children:[
              Text("pleaseEnterTheDiscountValue",style:
          TextStyle(fontSize: 16,color: Colors.black),textAlign: TextAlign.center,).tr(),
              SizedBox(
                height: 20,
              ),
              Row(
                mainAxisSize: MainAxisSize.max,
                children: [
                  for(var i=1; i<6; i++)
                    ...[
                      Expanded(
                          child:
                            InkWell(
                                onTap: ()
                              {
                                setState(() {
                                  if(this.discount.length<2)
                                    this.discount=this.discount+i.toString();
                                });
                              },
                                child:
                                Container(
                                  padding: EdgeInsets.only(top: 10,bottom: 10),
                                  child: Align(
                                      alignment: Alignment.center,
                                      child: Text("${i}",
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                              fontFamily: 'Roboto',
                                              fontWeight: FontWeight.w500,
                                              fontSize: 16,
                                              decoration: TextDecoration.none
                                          ))),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.all(Radius.circular(6)),
                                    color: Colors.white,
                                    boxShadow: [BoxShadow(
                                        color: AppTheme.colorLightGrey,
                                        blurRadius: 1.0, // soften the shadow
                                        spreadRadius: 1.0, //extend the shadow
                                        offset: Offset(
                                          1.0,
                                          1.0,
                                        ))],
                                    border: Border.all(
                                        color: AppTheme.colorGrey,
                                        style: BorderStyle.solid,
                                        width: 1
                                    ),
                                  ),

                                ),
                            )
                      ),
                    ],
                ],
              ),
              SizedBox(
                height: 10,
              ),
              Row(
                mainAxisSize: MainAxisSize.max,
                children: [
                  for(var i=6; i<11; i++)
                    ...[
                      Expanded(
                          child:
                          InkWell(
                            onTap: ()
                            {
                              setState(() {
                                var selectedValue = i;
                                if(i==10)
                                {
                                  selectedValue = 0;
                                }
                                if(this.discount.length<2)
                                  this.discount=this.discount+selectedValue.toString();
                              });
                            },
                            child:
                            Container(
                              padding: EdgeInsets.only(top: 10,bottom: 10),
                              child: Align(
                                  alignment: Alignment.center,
                                  child: Text(i==10?"0":"${i}",
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                          fontFamily: 'Roboto',
                                          fontWeight: FontWeight.w500,
                                          fontSize: 16,
                                          decoration: TextDecoration.none
                                      ))),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.all(Radius.circular(6)),
                                color: Colors.white,
                                boxShadow: [BoxShadow(
                                    color: AppTheme.colorLightGrey,
                                    blurRadius: 1.0, // soften the shadow
                                    spreadRadius: 1.0, //extend the shadow
                                    offset: Offset(
                                      1.0,
                                      1.0,
                                    ))],
                                border: Border.all(
                                    color: AppTheme.colorGrey,
                                    style: BorderStyle.solid,
                                    width: 1
                                ),
                              ),

                            ),
                          )
                      ),
                    ],
                ],
              ),
              SizedBox(
                height: 10,
              ),
              Row(
                mainAxisSize: MainAxisSize.max,
                children: [
                      Expanded(
                          flex: 1,
                          child:
                          InkWell(
                            onTap: (){
                              setState(() {
                                this.discount="";
                              });
                            },
                            child:
                            Container(
                              padding: EdgeInsets.only(top: 10,bottom: 10),
                              child: Align(
                                  alignment: Alignment.center,
                                  child: Text("c".tr().toUpperCase(),
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                          fontFamily: 'Roboto',
                                          fontWeight: FontWeight.w500,
                                          fontSize: 16,
                                          decoration: TextDecoration.none,
                                          color: Colors.white
                                      ))),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.all(Radius.circular(6)),
                                color: AppTheme.colorRed,
                                boxShadow: [BoxShadow(
                                    color: AppTheme.colorLightGrey,
                                    blurRadius: 1.0, // soften the shadow
                                    spreadRadius: 1.0, //extend the shadow
                                    offset: Offset(
                                      1.0,
                                      1.0,
                                    ))],
                                border: Border.all(
                                    color: AppTheme.colorGrey,
                                    style: BorderStyle.solid,
                                    width: 1
                                ),
                              ),

                            ),
                          )
                      ),
                      Expanded(
                      flex: 2,
                      child:
                      InkWell(
                        onTap:(){
                          setState(() {
                            this.discount="100";
                          });
                        },
                        child:
                        Container(
                          padding: EdgeInsets.only(top: 10,bottom: 10),
                          child: Align(
                              alignment: Alignment.center,
                              child: Text("free".tr().toUpperCase(),
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: Colors.white,
                                      fontFamily: 'Roboto',
                                      fontWeight: FontWeight.w500,
                                      fontSize: 16,
                                      decoration: TextDecoration.none,

                                  )).tr()),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.all(Radius.circular(6)),
                            color: AppTheme.colorGreen,
                            boxShadow: [BoxShadow(
                                color: AppTheme.colorLightGrey,
                                blurRadius: 1.0, // soften the shadow
                                spreadRadius: 1.0, //extend the shadow
                                offset: Offset(
                                  1.0,
                                  1.0,
                                ))],
                            border: Border.all(
                                color: AppTheme.colorGrey,
                                style: BorderStyle.solid,
                                width: 1
                            ),
                          ),

                        ),
                      )
                  ),
                      Expanded(
                      flex: 2,
                      child:
                      InkWell(
                        onTap: null,
                        child:
                        Container(
                          padding: EdgeInsets.only(top: 10,bottom: 10),
                          child: Align(
                              alignment: Alignment.center,
                              child: this.discount.length>0?Text("${this.discount}%"):Text("",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      fontFamily: 'Roboto',
                                      fontWeight: FontWeight.w500,
                                      fontSize: 16,
                                      decoration: TextDecoration.none
                                  ))),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.all(Radius.circular(6)),
                            color: Colors.white,
                            boxShadow: [BoxShadow(
                                color: AppTheme.colorLightGrey,
                                blurRadius: 1.0, // soften the shadow
                                spreadRadius: 1.0, //extend the shadow
                                offset: Offset(
                                  1.0,
                                  1.0,
                                ))],
                            border: Border.all(
                                color: AppTheme.colorGrey,
                                style: BorderStyle.solid,
                                width: 1
                            ),
                          ),

                        ),
                      )
                  ),
                ],
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
                                widget.discount = int.parse(discount);
                                widget.onDiscountSubmit(widget.discount);
                                Navigator.of(context).pop();
                          },
                          child: Container(
                            padding: EdgeInsets.all(20),
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              border: Border(right: BorderSide(color: AppTheme.colorMediumGrey,width:0.1,style: BorderStyle.solid)),
                            ),
                            child:
                            Text("ok".tr().toUpperCase(),style: TextStyle(color: AppTheme.colorMediumGrey,),).tr(),
                          ),
                        )
                    ),

                    Expanded(
                        flex: 1,
                        child:
                        InkWell(
                          onTap: (){
                            Navigator.pop(context);
                          },
                          child: Container(
                            padding: EdgeInsets.all(20),
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                            ),
                            child:
                            Text("cancel".tr().toUpperCase(),style: TextStyle(color: AppTheme.colorMediumGrey,),).tr(),

                          ),
                        )
                    ),

                    //),
                  ],
                ),
              )
            ]
          ),
        ),
        ),
    );
  }
  @override
  Widget build(BuildContext context) {
    return getDiscountWindow();
  }
}
