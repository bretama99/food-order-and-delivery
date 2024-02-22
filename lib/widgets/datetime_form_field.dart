import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../assets/images.dart';
import '../screens/MountedState.dart';
import '../utils/constants.dart';
import '../utils/utility.dart';
import 'app_theme.dart';
import 'custom_field_with_no_icon.dart';
class DateTimeFormField extends StatefulWidget {
  late TextEditingController dateTimeController = TextEditingController();
  final String? timeHintText;
  bool? isObsecre = true;
  bool? enabled = true;
  final String? placeholder;
  SvgPicture? outerIcon;
  PaddingParameters? paddingParameters;
  String? align;
  bool isKeepSpaceForOuterIcon = true;
  late String timeConfirmText;
  late String dateConfirmText;
  late String timeCancelText;
  late String dateCancelText;
  DateTime initialDate;
  DateTime firstDate;
  int lastDate;
  TimeOfDay initialTime;
  String? minuteLabelText;
  String? selectDate;
  late TextEditingController startDateTime;
  late TextEditingController endDateTime;
  bool? dateFlug;
  bool showTimePicker = true;
  Function? onDateSelected;
  Function? onTimeSelected;
  DateTime? lastDates;
  DateTimeFormField({
        required this.dateTimeController,
        required this.initialDate,
        required this.firstDate,
        required this.lastDate,
        this.timeHintText,
        this.isObsecre,
        this.enabled,
        this.placeholder,
        this.outerIcon = null,
        required this.isKeepSpaceForOuterIcon,
        this.paddingParameters,
        this.align,
        this.dateConfirmText="ok",
        this.dateCancelText="cancel",
        this.timeConfirmText="ok",
        this.timeCancelText="cancel",
        required this.initialTime,
        this.minuteLabelText,
        this.selectDate,
        required this.startDateTime,
        required this.endDateTime,
        this.dateFlug,
        this.showTimePicker=true,
        this.onDateSelected, this.onTimeSelected,
        this.lastDates,
      });
  static _defFunction(value){
  }

  @override
  State<DateTimeFormField> createState() => _DateTimeFormFieldState();
}

class _DateTimeFormFieldState extends MountedState<DateTimeFormField> {
  late String selectedLanguage;
  late String groupTimeFormat;
  late SharedPreferences sharedPreferences;
  Utility utility = Utility();
  late String selectedDateFormat="dd/MM/yyyy";
  @override
  void initState() {
    SharedPreferences.getInstance().then((value){
      sharedPreferences = value;
      setState(() {
        selectedLanguage = sharedPreferences.getString(ConstantSharedPreferenceKeys.KEY_SELECTED_LANGUAGE)!=null?sharedPreferences.getString(ConstantSharedPreferenceKeys.KEY_SELECTED_LANGUAGE)!:"Français";
        groupTimeFormat = sharedPreferences.getString(ConstantSharedPreferenceKeys.KEY_SELECTED_TIME_FORMAT)!=null?sharedPreferences.getString(ConstantSharedPreferenceKeys.KEY_SELECTED_TIME_FORMAT)!:"24H";
        selectedDateFormat = (sharedPreferences.getString(ConstantSharedPreferenceKeys.KEY_SELECTED_DATE_FORMAT)!=null?sharedPreferences.getString(ConstantSharedPreferenceKeys.KEY_SELECTED_DATE_FORMAT):"dd/MM/yyyy")!;
      });
    });
    super.initState();
  }


  @override
  Widget build(BuildContext context) {
    return
      Container(
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
            Expanded(child:
            Card(
              color: Colors.white,
              surfaceTintColor: Colors.transparent,
              shadowColor: Colors.white38,
              elevation: 4,
              shape:  RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10), // <-- Radius
              ),
              child: Theme(
                  data: Theme.of(context).copyWith(primaryColor: AppTheme.colorGrey),
                  child: TextFormField(
                textAlign: widget.align=='right'?TextAlign.right: widget.align=='center'?TextAlign.center:
                TextAlign.left,
                onEditingComplete:(){
                },
                validator: (value) {
                },
                readOnly: true,
                controller: widget.dateTimeController,
                onChanged: (text){
                },
                onTap: () async{
                  DateTime?pickedDate=await showDatePicker(

                    locale : Locale("${utility.getCountryCode()}", "${utility.getCountryCode().toUpperCase()}"),
                    confirmText: widget.dateConfirmText!.tr().toUpperCase(),
                    cancelText: widget.dateCancelText!.tr().toUpperCase(),
                    context: context,
                    helpText: DateFormat(selectedDateFormat).format(DateTime.now()).toString(),
                    initialDate: widget.initialDate,
                    firstDate: widget.firstDate.subtract(Duration(days: 0)),
                    lastDate:widget.lastDates==null?DateTime(widget.lastDate):widget.lastDates!,
                    builder: (context, child) {
                      return Padding(
                        padding: const EdgeInsets.only(top: 10,bottom: 10,left: 15,right: 15),
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
                    String formattedDate = DateFormat(selectedDateFormat).format(pickedDate);
                    setState((){
                      widget.dateTimeController.text = formattedDate.toString();
                      if(widget.showTimePicker){
                        _showTimePicker();
                      }
                      else{
                          widget.onDateSelected!(widget.dateTimeController.text);
                      }
                    });
                  }
                },
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
                    hintText: widget.dateTimeController.text.isEmpty?widget.selectDate!.tr():"",
                ),
              )
            ),
          ),
          )

        ],
      ),
    );

  }

  void _showTimePicker() {
    showTimePicker(
        helpText: "",
        hourLabelText: "",
        cancelText: widget.timeCancelText!.tr().toUpperCase(),
        confirmText: widget.timeConfirmText!.tr().toUpperCase(),
        minuteLabelText: widget.minuteLabelText!.tr(),
        builder: (context, child) {
          final Widget mediaQueryWrapper = MediaQuery(
            data: MediaQuery.of(context).copyWith(
              alwaysUse24HourFormat: false,
            ),
            child: MediaQuery(
              data: MediaQuery.of(context).copyWith(
                  alwaysUse24HourFormat: false),
              child: Container(
                height: 100,
                width: 320,
                child: child,
              ),),
          );
          return Theme(
            child: (selectedLanguage != "English" && groupTimeFormat == "12H") ?
            Localizations.override(
              context: context,
              locale: Locale('es', 'US'),
              child: mediaQueryWrapper,
            ) : MediaQuery(data: MediaQuery.of(context).copyWith(
                alwaysUse24HourFormat: groupTimeFormat == "24H" ? true : false),
              child: Container(
                height: 100,
                width: 320,
                child: child,
              ),),
            data: ThemeData(
              textButtonTheme: TextButtonThemeData(
                style: TextButton.styleFrom(
                  primary: AppTheme.colorRed, // button text color
                ),
              ),
              colorScheme: const ColorScheme.light(
                primary: AppTheme.colorRed, // <-- SEE HERE
                background: AppTheme.colorRed,
              ),
              timePickerTheme: TimePickerThemeData(
                dialHandColor: AppTheme.colorRed,
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
    widget.dateTimeController.text=widget.dateTimeController.text+" - "+("0"+(int.parse(time.split(":")[0])-12).toString())+":${time.split(":")[1]}"+" PM";
    }
    else
    if(selectedLanguage != "English" && groupTimeFormat=="12H" && int.parse(time.split(":")[0])<12){
      widget.dateTimeController.text=widget.dateTimeController.text+" - "+time+" AM";
    }
    else
    if(selectedLanguage == "English" && groupTimeFormat=="24H"){
     widget.dateTimeController.text=widget.dateTimeController.text+" - "+time;
    }
    else {
    var preVal=widget.dateTimeController.text;
      widget.dateTimeController.text = value?.format(context) as String;
      widget.dateTimeController.text=preVal+" - "+widget.dateTimeController.text;
    }
    if(widget.dateFlug!){
      setState(() {
        widget.endDateTime.text=widget.dateTimeController.text;
      });
    }
        if(!widget.dateFlug!) {
          setState(() {
            widget.startDateTime.text = widget.dateTimeController.text;
          });
        }
        var timeCheckerStart="", timeCheckerEnd="";
        if(groupTimeFormat=="12H") {
          timeCheckerStart =
          widget.startDateTime.text!.split(" ")[widget.startDateTime.text!.split(" ").length-1];
          timeCheckerEnd=widget.endDateTime.text!.split(" ")[widget.endDateTime.text!.split(" ").length-1];
          print("Time checkers: ${timeCheckerEnd} ${timeCheckerStart}");
        }

        if(widget.startDateTime!="" && widget.endDateTime!="" && widget.dateFlug!=null){

          String startDate=widget.startDateTime.text!.split(" ")[0];
          String startHour=(widget.startDateTime.text!.split(" ")[2].split(":")[0].length==2?"":"0")+widget.startDateTime.text!.split(" ")[2].split(":")[0];
          String startMinute=widget.startDateTime.text!.split(" ")[2].split(":")[1];
          String endDate=widget.endDateTime.text!.split(" ")[0];
          String endHour=(widget.endDateTime.text!.split(" ")[2].split(":")[0].length==2?"":"0")+widget.endDateTime.text!.split(" ")[2].split(":")[0];
          String endMinute=widget.endDateTime.text!.split(" ")[2].split(":")[1];
        DateTime d1=DateTime.parse(startDate.split("/")[2]+"-"+startDate.split("/")[1]+"-"+
            startDate.split("/")[0]+" ${startHour}:${startMinute}");
        DateTime d2=DateTime.parse(endDate.split("/")[2]+"-"+endDate.split("/")[1]+"-"+
            endDate.split("/")[0]+" ${endHour}:${endMinute}");
        if(groupTimeFormat=="24H" || (timeCheckerStart=="AM" && timeCheckerEnd=="AM") || (timeCheckerStart=="PM" && timeCheckerEnd=="PM")){
          print("===================================");
            if(d1.compareTo(d2)<0) {
              setState((){
                if(widget.onTimeSelected!=null){
                  widget.onTimeSelected!(d1.toString());
                }
              });

              return;
            }
            else {
              setState(() {
                Utility().showToastMessage("Start date should be before end date");
                widget.dateTimeController.text = "";
              });
            }
            }
        else{

          if((DateTime.parse(startDate.split("/")[2]+"-"+startDate.split("/")[1]+"-"+
              startDate.split("/")[0])).compareTo(DateTime.parse(endDate.split("/")[2]+"-"+endDate.split("/")[1]+"-"+
              endDate.split("/")[0]))<0) {
            setState((){
              if(widget.onTimeSelected!=null){
                widget.onTimeSelected!(d1.toString());
              }
            });
            return;
          }

          else if(DateTime.parse(startDate.split("/")[2]+"-"+startDate.split("/")[1]+"-"+
              startDate.split("/")[0]).compareTo(DateTime.parse(endDate.split("/")[2]+"-"+endDate.split("/")[1]+"-"+
              endDate.split("/")[0]))==0 && timeCheckerStart=="AM"){
            setState((){
              if(widget.onTimeSelected!=null){
                widget.onTimeSelected!(d1.toString());
              }
            });
            return;
          }
          else {
            setState(() {
              Utility().showToastMessage("Start date should be before end date");
              widget.dateTimeController.text = "";
            });
          }
        }
        }
      })
    });
  }

}













