import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:opti_food_app/assets/images.dart';

import 'package:opti_food_app/screens/Order/order_taking_window.dart';
import 'package:opti_food_app/screens/Order/ordered_lists.dart';

import '../../../screens/MountedState.dart';
import '../../app_theme.dart';
class PopupWidget extends StatefulWidget {
  List<Widget>? givenWidget;
  final String positiveButtonText;
  final String negativeButtonText;
  final Function positiveButtonPressed;
  final Function negativeButtonPressed;
  final bool isPositiveButtonHighlighted;
  final bool isNegativeButtonHighlighted;
  final String title;

  static _Components components = const _Components();

  PopupWidget({Key? key, required this.givenWidget,required this.positiveButtonText,
              required this.negativeButtonText, this.positiveButtonPressed = _defFunction, this.negativeButtonPressed = _defFunction,
              this.isPositiveButtonHighlighted = false,this.isNegativeButtonHighlighted = false, required this.title,
  });

  @override
  State<PopupWidget> createState() => _PopupWidgetState();

  static _defFunction()
  {

  }
}

class _PopupWidgetState extends MountedState<PopupWidget> {
  final TextEditingController textEditingController = TextEditingController();
  bool _validateTextField = true;
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
        SingleChildScrollView(
          child: Container(
            padding: EdgeInsets.only(top: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  height: 40,
                  alignment: Alignment.center,
                  child: Text("${widget.title}", style: TextStyle(fontSize: 18),),),
                ...widget.givenWidget!,
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
                              widget.positiveButtonPressed();
                              Navigator.pop(context);
                            },
                            child: Container(
                              padding: EdgeInsets.all(20),
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                border: Border(right: BorderSide(color: AppTheme.colorMediumGrey,width:0.1,style: BorderStyle.solid)),
                              ),
                              child:
                              Text(widget.positiveButtonText.tr().toUpperCase(),style: TextStyle(color: AppTheme.colorMediumGrey,fontSize: 16,),),
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
                              ),
                              child:
                              Text(widget.negativeButtonText.tr().toUpperCase(),style: TextStyle(color: AppTheme.colorMediumGrey,fontSize: 16,),),

                            ),
                          )
                      ),
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
class _Components
{
  const _Components();
  String get INPUT_TEXT => "inputText";
}
