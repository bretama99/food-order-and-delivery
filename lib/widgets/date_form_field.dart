import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import '../screens/MountedState.dart';
import 'app_theme.dart';

class DateFormField extends StatefulWidget {
  final TextEditingController? controller;
  final String? hintText;
  bool? isObsecre = true;
  bool? enabled = true;
  final String? placeholder;
  PaddingParameters? paddingParameters;
  String? align;
  bool isKeepSpaceForOuterIcon = true;
  SvgPicture? outerIcon;
  bool readOnly = false;


  DateFormField({
    this.controller,
    this.hintText,
    this.isObsecre,
    this.enabled,
    this.placeholder,
    required this.isKeepSpaceForOuterIcon,
    required this.readOnly,
    this.align,
    this.outerIcon,
    this.paddingParameters
  });

  @override
  State<DateFormField> createState() => _DateFormFieldState();
}

class _DateFormFieldState extends MountedState<DateFormField> {
  @override
  void initState() {
    super.initState();
    if (widget.controller?.text==""){
      widget.controller?.text = DateFormat("dd/MM/yyyy").format(DateTime.now()).toString();
    }
  }
  @override
  Widget build(BuildContext context) {
    return TextFormField(
        readOnly: true,
        enabled: widget.enabled,
      controller: widget.controller,
      obscureText: widget.isObsecre!,
      onTap: () async{
        DateTime?pickedDate=await showDatePicker(
          locale : const Locale("fr","FR"),
          context: context,
             helpText: DateFormat("yyyy").format(DateTime.now()).toString(),
            initialDate: DateTime.now(), firstDate: DateTime(2000), lastDate: DateTime(2101),
          builder: (context, child) {
            return Padding(
              padding: const EdgeInsets.only(top: 100,bottom: 100,left: 15,right: 15),
              child: Theme(
                  data: Theme.of(context).copyWith(
                    shadowColor: Colors.black,
                    appBarTheme: const AppBarTheme(actionsIconTheme: IconThemeData(color: Colors.amber),
                        centerTitle: true,
                        elevation: 60,
                        titleTextStyle: TextStyle(color: Colors.lightBlueAccent, fontSize: 22)),
                    colorScheme: const ColorScheme.light(
                      primary: AppTheme.colorRed,
                    ),
                    textButtonTheme: TextButtonThemeData(
                      style: TextButton.styleFrom(
                        primary: AppTheme.colorRed, // button text color
                      ),
                    ),
                  ),
                  child: child!
                ),
            );
          },
        );
        if(pickedDate!=null){
          String formattedDate = DateFormat("dd/MM/yyyy").format(pickedDate);
        setState((){
            widget.controller?.text = formattedDate.toString();
          });
        }
      },
      decoration:  InputDecoration(
        hintText: "selectDate".tr(),
        contentPadding:
        EdgeInsets.only(left: 15, bottom: 11, top: 11, right: 15),
        border: InputBorder.none,
        focusedBorder: InputBorder.none,
        errorBorder: InputBorder.none,
        disabledBorder: InputBorder.none,
      ),
      // textAlign: TextAlign.left
    );
  }
}

class PaddingParameters {
  double left=0;
  double top=0;
  double right=0;
  double bottom=0;

  PaddingParameters(this.left, this.top, this.right, this.bottom);
}










