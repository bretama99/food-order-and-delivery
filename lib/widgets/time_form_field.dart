import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../screens/MountedState.dart';
import '../utils/constants.dart';
import '../utils/utility.dart';
import 'app_theme.dart';
import 'custom_field_with_no_icon.dart';
class TimeFormField extends StatefulWidget {
  late final String deliveryDate;
  late final TextEditingController? controller;
  final String? hintText;
  bool? isObsecre = true;
  bool? enabled = true;
  final String? placeholder;
  SvgPicture? outerIcon;
  PaddingParameters? paddingParameters;
  String? align;
  bool isKeepSpaceForOuterIcon = true;
  String? confirmText;
  String? cancelText;
  TimeFormField({
    this.controller,
    this.hintText,
    this.isObsecre,
    this.enabled,
    this.placeholder,
    this.outerIcon = null,
    required this.isKeepSpaceForOuterIcon,
    this.paddingParameters,
    this.align,
    this.confirmText,
    this.cancelText,
    this.deliveryDate="",
  });
    @override
  State<TimeFormField> createState() => _TimeFormFieldState();
}

class _TimeFormFieldState extends MountedState<TimeFormField> {

  late String selectedLanguage;
  late String groupTimeFormat;
  late SharedPreferences sharedPreferences;
  TimeOfDay? timeOfDay = TimeOfDay.now();
  @override
  void initState() {
    SharedPreferences.getInstance().then((value){
      sharedPreferences = value;
      setState(() {
        selectedLanguage = sharedPreferences.getString(ConstantSharedPreferenceKeys.KEY_SELECTED_LANGUAGE)!=null?sharedPreferences.getString(ConstantSharedPreferenceKeys.KEY_SELECTED_LANGUAGE)!:"Français";
        groupTimeFormat = sharedPreferences.getString(ConstantSharedPreferenceKeys.KEY_SELECTED_TIME_FORMAT)!=null?sharedPreferences.getString(ConstantSharedPreferenceKeys.KEY_SELECTED_TIME_FORMAT)!:"24H";
      });
    });
    super.initState();
  }


  @override
  Widget build(BuildContext context) {
   return Container(
       padding: widget.paddingParameters!=null?EdgeInsets.only(left: widget.paddingParameters!.left,
           top: widget.paddingParameters!.top, right: widget.paddingParameters!.right, bottom: widget.paddingParameters!.bottom):
       widget.isKeepSpaceForOuterIcon?EdgeInsets.only(left: 10,right: 10,top: 5,bottom: 5):EdgeInsets.only(top: 5,bottom: 5),
       child: Row(
         children: [
           if(widget.outerIcon==null)...[
             if(widget.isKeepSpaceForOuterIcon)...[
               SizedBox(width: 35,)
             ]
           ]
           else...[
             widget.outerIcon!
           ],
           SizedBox(width: 5,),
        Expanded(
          child: Container(
            child: Card(
              color: Colors.white,
              surfaceTintColor: Colors.transparent,
              shadowColor: Colors.white38,
              elevation: 4,
              shape:  RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10), // <-- Radius
              ),
              child: TextFormField(
                validator: (value) {
                  print("Selected Timeeeeeeeeeeeeeeee: ${value}");

                  String dateForDelivery =
                      widget.deliveryDate.split("/")[2]
                          .substring(0, 4) + "-" +
                          widget.deliveryDate.split(
                              "/")[1] + "-" +
                          widget.deliveryDate.split("-")[0].substring(0,2);

                  String dateNow = DateTime.now().toString().split(" ")[0]+" 00:00:00";
                  DateTime dt1 = DateTime.parse(dateNow);
                  DateTime dt2 = DateTime.parse(dateForDelivery+" "+"00:00:00");
                  double hour=double.parse(value.toString().split(":")[0]);
                  double minute=double.parse(value.toString().split(":")[1]);
                  double _timeDiff = (hour + minute/60)-(TimeOfDay.now().hour+TimeOfDay.now().minute/60);
                  if(_timeDiff<0 &&!dt2.isAfter(dt1))
                    return 'pleaseSelectLaterTime'.tr();
                  if (value!.isEmpty)
                    return 'pleaseEnterValue'.tr();
                  else
                    return null;
                },
                readOnly: true,
                onTap: (){
                  _showTimePicker();
                },
                enabled: widget.enabled,
                controller: widget.controller,
                obscureText: widget.isObsecre!,
                decoration: InputDecoration(
                  hintText: widget.hintText,
                  contentPadding:
                  EdgeInsets.only(left: 15, bottom: 11, top: 11, right: 15),
                  border: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  errorBorder: InputBorder.none,
                  disabledBorder: InputBorder.none,
                ),
              ),
            ),
          ),
        )]),
     );
  }

   _showTimePicker(){
    showTimePicker(
        helpText: "",
        hourLabelText: "",
        cancelText: "cancel".tr().toUpperCase(),
        confirmText: "ok".tr().toUpperCase(),
        minuteLabelText: "minute".tr(),
        builder: (context, child) {
          final Widget mediaQueryWrapper = MediaQuery(
            data: MediaQuery.of(context).copyWith(
              alwaysUse24HourFormat: false,
            ),
            child: MediaQuery(
              data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: false),
              child:  Container(
                height: 100,
                width: 320,
                child: child,
              ),),
          );
          return Theme(
            child: (selectedLanguage != "English" && groupTimeFormat=="12H")?
            Localizations.override(
              context: context,
              locale: Locale('es', 'US'),
              child: mediaQueryWrapper,
            ):MediaQuery(data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: groupTimeFormat=="24H"?true:false),
              child:  Container(
                height: 100,
                width: 320,
                child: child,
              ),),
            data: ThemeData(
              useMaterial3: false,
              textButtonTheme: TextButtonThemeData(
                style: TextButton.styleFrom(
                  primary: AppTheme.colorRed, // button text color
                ),
              ),
              colorScheme: const ColorScheme.light(
                primary: AppTheme.colorRed, // <-- SEE HERE
                background:  AppTheme.colorRed,
              ),
              timePickerTheme: TimePickerThemeData(
                dialHandColor:  AppTheme.colorRed,
              ),
            ),
          );
        },
        context: context,
        initialTime: TimeOfDay.now()).then((value) =>
    {
      setState((){
        var time=value.toString().split("(")[1].split(")")[0];
        if(selectedLanguage != "English" && groupTimeFormat=="12H" && int.parse(time.split(":")[0])>12){
          widget.controller!.text=((int.parse(time.split(":")[0])-12)<10?"0":"")+(int.parse(time.split(":")[0])-12).toString()+":${time.split(":")[1]}"+" PM";
        }
        else if(selectedLanguage != "English" && groupTimeFormat=="12H" && int.parse(time.split(":")[0])<12){
          widget.controller!.text=time+" AM";
        }
        else if(selectedLanguage == "English" && groupTimeFormat=="24H"){
          widget.controller!.text=time;
        }
        else {
          timeOfDay = value;
          widget.controller!.text = value?.format(context) as String;
        }
      })
    });
  }

}













