import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:opti_food_app/assets/images.dart';

import 'package:opti_food_app/screens/Order/order_taking_window.dart';
import 'package:opti_food_app/screens/Order/ordered_lists.dart';

import '../../../screens/MountedState.dart';
import '../../app_theme.dart';
class AlertPopup extends StatefulWidget {
  final String title;
  final String subTitle;
  final String titleImagePath;
  final Color titleImageBackgroundColor;
  final String positiveButtonText;
  final Function positiveButtonPressed;

  AlertPopup({Key? key, required this.title, required this.subTitle,required this.titleImagePath,required this.titleImageBackgroundColor,required this.positiveButtonText,
    this.positiveButtonPressed = _defFunction
  });

  @override
  State<AlertPopup> createState() => _AlertPopupState();

  static _defFunction()
  {

  }
}

class _AlertPopupState extends MountedState<AlertPopup> {
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
                                    //color: widget.isPositiveButtonHighlighted?Colors.red:AppTheme.colorMediumGrey,
                                    color: Colors.red,
                                    //fontWeight: widget.isPositiveButtonHighlighted?FontWeight.bold:FontWeight.normal,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  )
                              ),
                            ),
                          )
                      ),

                      /*Expanded(
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
                      ),*/

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
