import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:opti_food_app/assets/images.dart';
import 'package:opti_food_app/screens/order/ordered_lists.dart';

import '../../widgets/app_theme.dart';
import '../MountedState.dart';
class ChangeFromTakeawayToEatIn extends StatefulWidget {
  final String id;
  final String message;
  final Color color;
  final FontWeight font;
  final  String isTakeaway;
  final String isEatIn;

  const ChangeFromTakeawayToEatIn({Key? key, required this.id, required this.message,
    required this.color, required this.font, required this.isTakeaway, required this.isEatIn}) : super(key: key);

  @override
  State<ChangeFromTakeawayToEatIn> createState() => _ChangeFromTakeawayToEatInState();
}

class _ChangeFromTakeawayToEatInState extends MountedState<ChangeFromTakeawayToEatIn> {

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(60, 250, 60, 0),
      child: Dialog(
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.transparent,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(bottomLeft: Radius.circular(20), bottomRight: Radius.circular(20),
              topLeft:  Radius.circular(20), topRight:  Radius.circular(20),),
          ),

          alignment: Alignment.topCenter,
          // elevation: 100,
          insetPadding: EdgeInsets.all(0),
          child: Stack(
            alignment: Alignment.center,
            children: <Widget>[
              Container(
                  width: double.infinity,
                  height: MediaQuery.of(context).size.height*0.30,
                  alignment: Alignment.center,
                  child:Padding(
                    padding: const EdgeInsets.fromLTRB(0, 0, 0, 8),
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(top: 142),
                          child: Container(
                            child: Padding(
                              padding: const EdgeInsets.only(top: 0),
                              child: Transform.translate(

                                offset: Offset(0, 15),
                                child: Divider(
                                  thickness: 0.4,),
                              ),
                            ),
                          ),
                        ),

                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Row(
                              children: [
                                Expanded(
                                  flex:10,
                                  child: Transform.translate(
                                    offset: Offset(4, 6),
                                    //child: FlatButton(
                                    child: TextButton(
                                      style: TextButton.styleFrom(
                                          shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.only(bottomLeft: Radius.circular(20)
                                        ), // <-- Radius
                                      ),
                                        backgroundColor: Colors.white,
                                        foregroundColor: Colors.black,
                                      ),
                                      //height: MediaQuery.of(context).size.height*0.30,

                                      /*shape:  RoundedRectangleBorder(
                                        borderRadius: BorderRadius.only(bottomLeft: Radius.circular(20)),
                                        // <-- Radius
                                      ),*/
                                      child: Padding(
                                        padding: const EdgeInsets.only(left: 6,right: 0,top: 5),
                                        child: Transform.translate(
                                            offset: Offset(0, -5),
                                            child: Text('eatIn'.tr(), style:
                                            TextStyle(fontSize: 15.0,
                                                fontWeight: widget.message!="Are you sure you want to switch Take Away to Eat In"?FontWeight.normal:widget.font,
                                                color:
                                            widget.message!="Are you sure you want to switch Take Away to Eat In"?AppTheme.colorMediumGrey:widget.color),)),
                                      ),
                                      //color: Colors.white,
                                      //textColor: Colors.black,
                                      onPressed: () {

                                        /*Navigator.of(context).push(MaterialPageRoute(builder:
                                            (context)=>OrderedList(
                                          id: widget.id,isEatIn:"isEatIn", isTakeAway:widget.isTakeaway, tabIndex:0)));*/
                                      },
                                    ),
                                  ),
                                ),
                                Transform.translate(
                                  offset:Offset(0, 5),
                                  child: Container(
                                    height: 45,
                                    child: VerticalDivider(

                                      color: Colors.black54, thickness: 0.1,),
                                  ),
                                ),

                                Expanded(
                                  flex:11,
                                  child: Container(
                                    width: 180,
                                    child: Transform.translate(
                                      offset: Offset(-4, 6),
                                      //child: FlatButton(
                                      child: TextButton(
                                        // height: 45,
                                        //height: MediaQuery.of(context).size.height*0.30,
                                        // minWidth: 160,
                                        /*color: Colors.white,
                                        shape:  RoundedRectangleBorder(
                                          borderRadius: BorderRadius.only(bottomRight: Radius.circular(20)),
                                          // <-- Radius
                                        ),*/
                                        style: TextButton.styleFrom(
                                         backgroundColor: Colors.white,
                                         foregroundColor: Colors.black,
                                            shape:  RoundedRectangleBorder(
                                              borderRadius: BorderRadius.only(bottomRight: Radius.circular(20)),
                                              // <-- Radius
                                            ),
                                        ),
                                        child: Padding(
                                          padding: const EdgeInsets.only(left: 0,right: 0, top: 5),
                                          child: Transform.translate(
                                            offset: Offset(-4, -5),
                                            child: Text('takeAway'.tr(),
                                              textAlign: TextAlign.center,
                                              style: TextStyle(fontSize: 15.0, fontWeight: widget.message!="Are you sure you want to switch Take Away to Eat In"?widget.font:FontWeight.normal,
                                                color: widget.message!="Are you sure you want to switch Take Away to Eat In"?
                                                widget.color:AppTheme.colorMediumGrey, ),),
                                          ),
                                        ),
                                        // color: Colors.white,
                                        //textColor: Colors.black,
                                        onPressed: () {
                                          /*Navigator.of(context).push(MaterialPageRoute(builder: (context)=>
                                              OrderedList(
                                            id: widget.id, isEatIn:"", isTakeAway:"isTakeAway", tabIndex:0)));*/
                                        },
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
              ),
              Positioned(
                  top: 25,
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(10, 0, 0, 0),
                        child: Transform.translate(
                          offset: Offset(-5,0),
                          child: Container(
                            height: 50,
                            child: FloatingActionButton(
                              elevation: 0,
                              backgroundColor: AppTheme.colorRed,
                              child: SvgPicture.asset(AppImages.phoneWithHandIcon, height: 30, color: Colors.white,),
                              onPressed: () {
                              },
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(10, 4, 0, 15),
                        child: Transform.translate(
                            offset: Offset(-5,-5),
                            child: Image.asset(AppImages.shadowIcon,width: 50, height: 30, )),
                      ),
                      Transform.translate(
                          offset: Offset(0, -22),
                          child: Text("service", style: TextStyle(fontSize: 20,fontWeight: FontWeight.bold),).tr()),
                      Transform.translate(
                          offset: Offset(0, -20),
                          child: Container(
                            height: 50,
                              width: 200,
                              child: Text("eatInOrToTakeAway", textAlign: TextAlign.center,
                                style: TextStyle(fontSize: 14, color: AppTheme.colorMediumGrey),).tr())),
                    ],
                  )
              ),
            ],
          )
      ),
    );
  }
}
