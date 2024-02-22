import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:opti_food_app/assets/images.dart';

import 'package:opti_food_app/screens/Order/order_taking_window.dart';
import 'package:opti_food_app/screens/Order/ordered_lists.dart';

import '../../../screens/MountedState.dart';
import '../../app_theme.dart';
class InputPopup extends StatefulWidget {


  final String title;
  //final String subTitle;
  final String inputBoxHint;
  final String inputBoxDefaultValue;
  final int inputBoxMinLines;
  final int inputBoxMaxLines;
  final String titleImagePath;
  final Color titleImageBackgroundColor;
  final String positiveButtonText;
  final String negativeButtonText;
  final Function positiveButtonPressed;
  final Function negativeButtonPressed;
  final bool isPositiveButtonHighlighted;
  final bool isNegativeButtonHighlighted;
  final TextInputType textInputType;

  static _Components components = const _Components();

  InputPopup({Key? key, required this.title, required this.inputBoxHint,required this.titleImagePath,required this.titleImageBackgroundColor,required this.positiveButtonText,
    required this.negativeButtonText, this.positiveButtonPressed = _defFunction, this.negativeButtonPressed = _defFunction,this.isPositiveButtonHighlighted = false,this.isNegativeButtonHighlighted = false,
    this.inputBoxMinLines = 1,this.inputBoxMaxLines = 1,this.inputBoxDefaultValue="",this.textInputType = TextInputType.text
  });

  @override
  State<InputPopup> createState() => _InputPopupState();

  static _defFunction()
  {

  }
}

class _InputPopupState extends MountedState<InputPopup> {
  final TextEditingController textEditingController = TextEditingController();
  bool _validateTextField = true;
  @override
  Widget build(BuildContext context) {
    textEditingController.text = widget.inputBoxDefaultValue;
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
                child: TextField(

                  controller: textEditingController,
                  minLines: widget.inputBoxMinLines,
                  maxLines: null,
                  keyboardType: widget.inputBoxMaxLines ==1? widget.textInputType : TextInputType.multiline,
                  style: TextStyle(fontStyle: FontStyle.italic),
                  decoration:
                  InputDecoration(
                      hintText: widget.inputBoxHint.tr(),
                      border: const OutlineInputBorder(
                          borderSide: BorderSide(
                              width: 0.1, color: AppTheme.colorMediumGrey)
                      ),
                      enabledBorder: const OutlineInputBorder(
                          borderSide: BorderSide(
                              width: 0.1, color: AppTheme.colorMediumGrey)
                      ),
                      contentPadding: EdgeInsets.all(10),
                      errorText: _validateTextField?null:"fieldCanNotBeEmpty".tr(),
                  ),),
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
                            if(textEditingController.text.isEmpty)
                              {
                                setState(() {
                                  _validateTextField = false;
                                });
                              }
                            else
                              {
                                Navigator.pop(context);
                                Map resultMap = {
                                  InputPopup.components.INPUT_TEXT : textEditingController.text
                                };

                                widget.positiveButtonPressed(resultMap);

                              }
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
                              //border: Border(right: BorderSide(color: AppTheme.colorLightGrey,width:1,style: BorderStyle.solid)),
                            ),
                            child:
                            Text(widget.negativeButtonText.tr().toUpperCase(),style: TextStyle(color: AppTheme.colorMediumGrey,fontSize: 16,),),

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
class _Components
{
  const _Components();
  String get INPUT_TEXT => "inputText";
}
