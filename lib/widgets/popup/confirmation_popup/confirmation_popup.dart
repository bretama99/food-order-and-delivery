import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:opti_food_app/assets/images.dart';

import 'package:opti_food_app/screens/Order/order_taking_window.dart';
import 'package:opti_food_app/screens/Order/ordered_lists.dart';

import '../../../screens/MountedState.dart';
import '../../app_theme.dart';
class ConfirmationPopup extends StatefulWidget {
  /*final String id;
  final String message;
  final Color color;
  final FontWeight font;
  final  String isTakeaway;
  final String isEatIn;*/

  /*const ConfirmationPopup({Key? key, required this.id, required this.message,
    required this.color, required this.font, required this.isTakeaway, required this.isEatIn}) : super(key: key);*/

  /*const ConfirmationPopup({Key? key, required this.id, required this.message,
    required this.color, required this.font, required this.isTakeaway, required this.isEatIn}) : super(key: key);*/
  // const ChangeFromTakeawayToEatIn({Key? key}) : super(key: key);

  final String title;
  final String subTitle;
  final String titleImagePath;
  final Color? titleImageBackgroundColor;
  final String positiveButtonText;
  final String negativeButtonText;
  final Function positiveButtonPressed;
  final Function negativeButtonPressed;
  final bool isPositiveButtonHighlighted;
  final bool isNegativeButtonHighlighted;

  ConfirmationPopup({Key? key, required this.title, required this.subTitle,required this.titleImagePath,required this.titleImageBackgroundColor,required this.positiveButtonText,
    required this.negativeButtonText, this.positiveButtonPressed = _defFunction, this.negativeButtonPressed = _defFunction,
    this.isPositiveButtonHighlighted = false,this.isNegativeButtonHighlighted = false
  });

  @override
  State<ConfirmationPopup> createState() => _ConfirmationPopupState();

  static _defFunction()
  {

  }
}

class _ConfirmationPopupState extends MountedState<ConfirmationPopup> {

 /* @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(60, 250, 60, 0),
      child: Dialog(
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(bottomLeft: Radius.circular(20), bottomRight: Radius.circular(20),
              topLeft:  Radius.circular(20), topRight:  Radius.circular(20),),
          ),

          alignment: Alignment.topCenter,
          // elevation: 100,
          backgroundColor: Colors.white,
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
                                    child: FlatButton(
                                      height: MediaQuery.of(context).size.height*0.30,
                                      shape:  RoundedRectangleBorder(
                                        borderRadius: BorderRadius.only(bottomLeft: Radius.circular(20)),
                                        // <-- Radius
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.only(left: 6,right: 0,top: 5),
                                        child: Transform.translate(
                                            offset: Offset(0, -5),
                                            //child: Text('EAT IN', style:
                                            child: Text(widget.positiveButtonText, style:
                                            TextStyle(fontSize: 15.0,
                                                //fontWeight: widget.message!="Are you sure you want to switch Take Away to Eat In"?FontWeight.normal:widget.font,
                                                //color: widget.message!="Are you sure you want to switch Take Away to Eat In"?AppTheme.colorMediumGrey:widget.color,
                                              color: widget.isPositiveButtonHighlighted?Colors.red:AppTheme.colorMediumGrey,
                                              fontWeight: widget.isPositiveButtonHighlighted?FontWeight.bold:FontWeight.normal
                                            ))),
                                      ),
                                      color: Colors.white,
                                      textColor: Colors.black,
                                      onPressed: () {

                                       *//* Navigator.of(context).push(MaterialPageRoute(builder: (context)=>OrderedList(
                                            id: widget.id,isEatIn:"isEatIn", isTakeAway:widget.isTakeaway)));*//*
                                        Navigator.pop(context);
                                        widget.positiveButtonPressed();
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
                                      child: FlatButton(
                                        // height: 45,
                                        height: MediaQuery.of(context).size.height*0.30,
                                        // minWidth: 160,
                                        color: Colors.white,
                                        shape:  RoundedRectangleBorder(
                                          borderRadius: BorderRadius.only(bottomRight: Radius.circular(20)),
                                          // <-- Radius
                                        ),
                                        child: Padding(
                                          padding: const EdgeInsets.only(left: 0,right: 0, top: 5),
                                          child: Transform.translate(
                                            offset: Offset(-4, -5),
                                            *//*child: Text('TAKE AWAY',
                                              textAlign: TextAlign.center,
                                              style: TextStyle(fontSize: 15.0, fontWeight: widget.message!="Are you sure you want to switch Take Away to Eat In"?widget.font:FontWeight.normal,
                                                color: widget.message!="Are you sure you want to switch Take Away to Eat In"?
                                                widget.color:AppTheme.colorMediumGrey, ),),*//*
                                            //child: Text('TAKE AWAY',
                                            child: Text(widget.negativeButtonText,
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                color:  widget.isNegativeButtonHighlighted?Colors.red:AppTheme.colorMediumGrey,
                                                fontWeight: widget.isNegativeButtonHighlighted?FontWeight.bold:FontWeight.normal
                                              ),
                                             ),
                                          ),
                                        ),
                                        // color: Colors.white,
                                        textColor: Colors.black,
                                        onPressed: () {
                                         *//* Navigator.of(context).push(MaterialPageRoute(builder: (context)=>
                                              OrderedList(
                                                id: widget.id, isEatIn:"", isTakeAway:"isTakeAway",)));*//*
                                          Navigator.pop(context);
                                          widget.negativeButtonPressed();
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
                              //child: SvgPicture.asset("assets/images/icons/phone-with-hand.svg", height: 30, color: Colors.white,),
                              child: SvgPicture.asset(widget.titleImagePath, height: 30, color: Colors.white,),
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
                            child: Image.asset("assets/images/icons/shadow.jpeg",width: 50, height: 30, )),
                      ),
                      Transform.translate(
                          offset: Offset(0, -22),
                          //child: Text("SERVICE", style: TextStyle(fontSize: 20,fontWeight: FontWeight.bold),)),
                          child: Text(widget.title, style: TextStyle(fontSize: 20,fontWeight: FontWeight.bold),)),
                      Transform.translate(
                          offset: Offset(0, -20),
                          child: Container(
                              height: 50,
                              width: 200,
                              //child: Text("Eat in or to Take Away?", textAlign: TextAlign.center,
                              child: Text(widget.subTitle, textAlign: TextAlign.center,
                                style: TextStyle(fontSize: 14, color: AppTheme.colorMediumGrey),))),
                    ],
                  )
              ),
            ],
          )
      ),
    );
  }*/

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
        //backgroundColor: Colors.red,
        child:
        SingleChildScrollView(
          child: Container(
            padding: EdgeInsets.only(top: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: EdgeInsets.all(10),
                  child: SvgPicture.asset(widget.titleImagePath, height: 30, color: Colors.white,),
                  decoration:
                  BoxDecoration(
                      color: widget.titleImageBackgroundColor,
                      borderRadius: BorderRadius.circular(25)
                  ),
                ),
                Image.asset(AppImages.shadowIcon,width: 50, height: 30,),
                Text(widget.title.tr(),style: TextStyle(color: Colors.black,fontWeight: FontWeight.bold,fontSize: 18),),
                Padding(padding: EdgeInsets.all(10),
                  child:
                  /*TextField(

                    controller: textEditingController,
                    minLines: widget.inputBoxMinLines,
                    maxLines: null,
                    keyboardType: widget.inputBoxMaxLines ==1? widget.textInputType : TextInputType.multiline,
                    style: TextStyle(fontStyle: FontStyle.italic),
                    decoration:
                    InputDecoration(
                      hintText: widget.inputBoxHint,
                      border: const OutlineInputBorder(
                          borderSide: BorderSide(
                              width: 0.1, color: AppTheme.colorMediumGrey)
                      ),
                      enabledBorder: const OutlineInputBorder(
                          borderSide: BorderSide(
                              width: 0.1, color: AppTheme.colorMediumGrey)
                      ),
                      contentPadding: EdgeInsets.all(10),
                      errorText: _validateTextField?null:"Field can not be empty",
                    ),),*/
                  Text(widget.subTitle.tr(), textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 14, color: AppTheme.colorMediumGrey),)

                ),
                Container(
                  margin: const EdgeInsets.only(top: 20),
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

                                Navigator.pop(context);
                                widget.positiveButtonPressed();
                            },
                            child: Container(
                              padding: EdgeInsets.all(20),
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                border: Border(right: BorderSide(color: AppTheme.colorMediumGrey,width:0.1,style: BorderStyle.solid)),
                              ),
                              child:
                              Text(widget.positiveButtonText.tr().toUpperCase(),
                                style: TextStyle(
                                    //color: AppTheme.colorMediumGrey,fontSize: 18,fontWeight: FontWeight.bold),
                                  color: widget.isPositiveButtonHighlighted?Colors.red:AppTheme.colorMediumGrey,
                                  fontWeight: widget.isPositiveButtonHighlighted?FontWeight.bold:FontWeight.normal,
                                  fontSize: 16,
                                )
                              ),
                            ),
                          )
                      ),

                      Expanded(
                          flex: 1,
                          child:
                          InkWell(
                            onTap: (){
                              Navigator.pop(context);
                              widget.negativeButtonPressed();
                            },
                            child: Container(
                              padding: EdgeInsets.all(20),
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                //border: Border(right: BorderSide(color: AppTheme.colorLightGrey,width:1,style: BorderStyle.solid)),
                              ),
                              child:
                              Text(widget.negativeButtonText.tr().toUpperCase(),
                                style: TextStyle(
                                    //color: AppTheme.colorMediumGrey,fontSize: 18,fontWeight: FontWeight.bold),
                                    color:  widget.isNegativeButtonHighlighted?Colors.red:AppTheme.colorMediumGrey,
                                    fontWeight: widget.isNegativeButtonHighlighted?FontWeight.bold:FontWeight.normal,
                                  fontSize: 16,
                                )
                              ),

                            ),
                          )
                      ),

                      //),
                    ],
                  ),
                )
              ],
            ),
          ),
        )
    );
  }
}
