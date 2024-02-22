import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:easy_localization/easy_localization.dart';
import 'app_theme.dart';

class CustomFieldWithNoIcon extends StatelessWidget {
  // const CustomField({Key? key}) : super(key: key);
  final TextEditingController? controller;
  final String? hintText;
  TextStyle? hintStyle;
  TextStyle? textStyle;
  bool? isObsecre = true;
  bool enabled = true;
  bool readOnly = false;
  final String? placeholder;
  final int? maxLines;
  int minLines = 1;
  TextInputType textInputType = TextInputType.text;
  Function validator;
  SvgPicture? outerIcon;
  //Icon? suffixIcon;
  IconButton? suffixIcon;
  TextCapitalization textCapitalization = TextCapitalization.none;
  Function? onTap;
  Function? onEditingComplete;
  Function? onChange;
  FocusNode? focusNode;
  bool isKeepSpaceForOuterIcon = true;
  bool obSecure = false;
  PaddingParameters? paddingParameters;
  String? align;
  CustomFieldWithNoIcon({
    this.controller,
    this.hintText,
    this.hintStyle,
    this.textStyle,
    this.isObsecre,
    this.enabled = true,
    this.placeholder,
    this.maxLines,
    this.minLines=1,
    this.readOnly = false,
    this.textInputType = TextInputType.text,
    this.validator = _defFunction,
    this.outerIcon = null,
    this.isKeepSpaceForOuterIcon = true,
    this.textCapitalization = TextCapitalization.none,
    this.onTap,
    this.onEditingComplete,
    this.onChange,
    this.focusNode,
    this.suffixIcon,
    this.obSecure = false,
    this.paddingParameters,
    this.align,
  });

  static _defFunction(value){

  }
  @override
  Widget build(BuildContext context) {
    return  Container(
      padding: paddingParameters!=null?EdgeInsets.only(left: paddingParameters!.left,
      top: paddingParameters!.top, right: paddingParameters!.right, bottom: paddingParameters!.bottom):
      isKeepSpaceForOuterIcon?EdgeInsets.only(left: 10,right: 10,top: 5,bottom: 5):EdgeInsets.only(top: 5,bottom: 5),
      child: Row(
        children: [
          if(outerIcon==null)...[
            if(isKeepSpaceForOuterIcon)...[
              SizedBox(width: 35,)
            ]
          ]
          else...[
              outerIcon!
            ],
          SizedBox(width: 5,),
          Expanded(child:
          Card(
            color: Colors.white,
            surfaceTintColor: Colors.transparent,
            shadowColor: Colors.white38,
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            child: Theme(
              data: Theme.of(context).copyWith(primaryColor: AppTheme.colorGrey),
              child:
              TextFormField(
                textAlign: align=='right'?TextAlign.right: align=='center'?TextAlign.center:
                TextAlign.left,
              validator: (value){
                return validator(value);
              },
              onTap: () {
                if (this.onTap != null) {
                  this.onTap!();
                }
              },
              onChanged: (text){
                if(this.onChange!=null) {
                  this.onChange!(text);
                }
              },
              obscureText: obSecure,
              focusNode: focusNode,
              keyboardType: textInputType,
              textCapitalization: textCapitalization,
              minLines: minLines,
              maxLines: minLines,
              readOnly: readOnly,
              // maxLines: maxLines,
              enabled: enabled,
              controller: controller,
              style: textStyle!=null?textStyle!:null,
              // obscureText: isObsecre!,
              decoration: InputDecoration(

                  disabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: AppTheme.colorDarkGrey, width: 0.005),
                  ),
                contentPadding:
                EdgeInsets.only(left: 15, bottom: 11, top: 11, right: 15),
                border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                errorBorder: InputBorder.none,
                hintText: hintText!=null?hintText!.tr():'',
                hintStyle: hintStyle!=null?hintStyle!:null,
                //suffixIcon: Icon(Icons.copy)
                suffixIcon: suffixIcon!=null?suffixIcon as IconButton:null
              ),
            ),
            ),
          ),
          )

        ],
      ),
    );
    return
      TextFormField(
        validator: (value){
          return validator(value);
        },
        keyboardType: textInputType,
        readOnly: readOnly,
        // maxLines: maxLines,
        enabled: enabled,
        controller: controller,
        // obscureText: isObsecre!,
        decoration: InputDecoration(
          contentPadding:
          EdgeInsets.only(left: 15, bottom: 11, top: 11, right: 15),
          border: InputBorder.none,
          focusedBorder: InputBorder.none,
          errorBorder: InputBorder.none,
          disabledBorder: InputBorder.none,
          hintText: hintText,
        ),
      );
  }
  /*@override
  Widget build(BuildContext context) {
    return
      TextFormField(
        validator: (value){
          return validator(value);
        },
        keyboardType: textInputType,
      readOnly: readOnly,
      // maxLines: maxLines,
      enabled: enabled,
      controller: controller,
      // obscureText: isObsecre!,
      decoration: InputDecoration(
        contentPadding:
        EdgeInsets.only(left: 15, bottom: 11, top: 11, right: 15),
        border: InputBorder.none,
        focusedBorder: InputBorder.none,
        errorBorder: InputBorder.none,
        disabledBorder: InputBorder.none,
        hintText: hintText,
      ),
    );
  }*/

}

class PaddingParameters {
  double left=0;
  double top=0;
  double right=0;
  double bottom=0;

  PaddingParameters(this.left, this.top, this.right, this.bottom);
}













