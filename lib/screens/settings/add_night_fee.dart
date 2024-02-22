import 'dart:io';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/src/scheduler/ticker.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:flutter_svg/svg.dart';
import 'package:image_picker/image_picker.dart';
import 'package:opti_food_app/api/night_mode_fee.dart';
import 'package:opti_food_app/assets/images.dart';
import 'package:opti_food_app/data_models/attribute_category_model.dart';
import 'package:opti_food_app/data_models/company_model.dart';
import 'package:opti_food_app/data_models/delivery_fee_model.dart';
import 'package:opti_food_app/data_models/food_items_model.dart';
import 'package:opti_food_app/data_models/night_mode_fee_model.dart';
import 'package:opti_food_app/database/attribute_category_dao.dart';
import 'package:opti_food_app/database/company_dao.dart';
import 'package:opti_food_app/database/delivery_fee_dao.dart';
import 'package:opti_food_app/database/food_category_dao.dart';
import 'package:opti_food_app/database/food_items_dao.dart';
import 'package:opti_food_app/database/night_mode_fee_dao.dart';
import 'package:opti_food_app/widgets/appbar/app_bar_optifood.dart';

import '../../data_models/food_category_model.dart';
import '../../main.dart';
import '../../utils/constants.dart';
import '../../utils/utility.dart';
import '../../widgets/app_theme.dart';
import '../../widgets/custom_field_with_no_icon.dart';
import '../../widgets/time_form_field.dart';
import '../MountedState.dart';
class AddNightFee extends StatefulWidget{

  @override
  State<StatefulWidget> createState() => _AddNightFeeState();

}
class _AddNightFeeState extends MountedState<AddNightFee> with SingleTickerProviderStateMixin{
  final GlobalKey<FormState> _globalKey = GlobalKey<FormState>();
  TextEditingController nightFeeController = TextEditingController();
  TextEditingController nightModeStartTimeController = TextEditingController();
  TextEditingController nightModeEndTimeController = TextEditingController();
  late bool activateNightFeeRestaurant=false;
  late bool activateNightFeeDelivery=true;
  String currency = optifoodSharedPrefrence.getString(ConstantSharedPreferenceKeys.KEY_SELECTED_CURRENCY)!=null?optifoodSharedPrefrence.getString(ConstantSharedPreferenceKeys.KEY_SELECTED_CURRENCY)!:ConstantCurrencySymbol.EURO.toString();
  String decimalSeparator = optifoodSharedPrefrence.getString(ConstantSharedPreferenceKeys.KEY_SELECTED_CURRENCY)!=null?optifoodSharedPrefrence.getString(ConstantSharedPreferenceKeys.KEY_SELECTED_DECIMAL_SEPARATOR)!:",";
  TimeOfDay? timeOfDayStart = TimeOfDay.now();
  TimeOfDay? timeOfDayEnd = TimeOfDay.now();
  @override
  void initState() {
    getNightFee();
    super.initState();
  }

  void _showTimePicker(String timeType){
    showTimePicker(
        helpText: "",
        hourLabelText: "",
        builder: (context, child) {
          return Theme(
            child: MediaQuery(data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
              child:  Container(
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
        if(timeType=="startTime") {
          nightModeStartTimeController.text = value?.format(context) as String;
          timeOfDayStart = value;
        }
      if(timeType=="endTime") {
        nightModeEndTimeController.text = value?.format(context) as String;
        timeOfDayStart = value;
      }
      })
    });
  }
  @override
  Widget build(BuildContext context) {
    FocusNode nightFeeFocusNode = FocusNode();
    FocusNode startTimeFocusNode = FocusNode();
    FocusNode endTimeFocusNode = FocusNode();
    return Scaffold(
      appBar: AppBarOptifood(),
      body: Container(
          child: Stack(
            children: [
              SingleChildScrollView(
                  child: Form(
                    key: _globalKey,
                    child: Column(
                      children: [
                        ListTile(
                          contentPadding: EdgeInsets.only(left: 10,right: 10,top: 15),
                          title: Text("activateNightFeeForRestaurantOrder", style: TextStyle(fontSize: 16),).tr(),
                          trailing: Switch(
                            activeColor: AppTheme.colorRed,
                            value: activateNightFeeRestaurant,
                            onChanged: (bool value) {
                              setState(() {
                                activateNightFeeRestaurant=value;
                              });
                            },
                          ),
                        ),
                        ListTile(
                          contentPadding: EdgeInsets.only(left: 10,right: 10,top: 15),
                          title: Text("activateNightFeeForDeliveryOrder", style: TextStyle(fontSize: 16),).tr(),
                          trailing: Switch(
                            activeColor: AppTheme.colorRed,
                            value: activateNightFeeDelivery,
                            onChanged: (bool value) {
                              setState(() {
                                activateNightFeeDelivery=value;
                              });
                            },
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.only(
                              left: 10,
                              right: 10),
                          child: Row(
                            children: [
                              Container(
                                  width: MediaQuery.of(context).size.width*0.54,
                                  child: Flexible(
                                      flex: 1,
                                      child: Text("nightFee".tr(), style: TextStyle(fontSize: 16),))
                              ),
                              Container(
                                  width: MediaQuery.of(context).size.width*0.37,
                                  child: Flexible(
                                      flex: 1,
                                      child: CustomFieldWithNoIcon(
                                        validator: (value){
                                          if(value==null || value.isEmpty) {
                                            return "${"invalid".tr()}\n ${"price".tr()}";
                                          }
                                          else{
                                            return null;
                                          }
                                        },
                                        isKeepSpaceForOuterIcon: false,
                                        textInputType: TextInputType.number,
                                        controller: nightFeeController,
                                        focusNode: nightFeeFocusNode,
                                        align: "right",
                                        onChange: (){
                                          setState((){
                                            nightFeeController.text=double.parse(nightFeeController.text).toStringAsFixed(2).replaceAll('.', decimalSeparator);
                                          });
                                        },
                                      )
                                  )),
                              Container(
                                child: Text("${currency}"),)
                            ],
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.only(
                              left: 10,
                              right: 9),
                          child: Row(
                            children: [
                              Container(
                                  width: MediaQuery.of(context).size.width*0.545,
                                  child: Flexible(
                                      flex: 1,
                                      child: Text("nightModeStartTime".tr(), style: TextStyle(fontSize: 16),))
                              ),
                              Container(
                                  width: MediaQuery.of(context).size.width*0.385,
                                  child:
                                  TimeFormField(
                                    controller: this.nightModeStartTimeController,
                                    isObsecre: false,
                                    enabled: true,
                                    isKeepSpaceForOuterIcon: false,
                                    hintText: "startTime".tr(),
                                  )),
                            ],
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.only(
                              left: 10,
                              right: 9),
                          child: Row(
                            children: [
                              Container(
                                  width: MediaQuery.of(context).size.width*0.545,
                                  child: Flexible(
                                      flex: 1,
                                      child: Text("nightModeEndTime".tr(), style: TextStyle(fontSize: 16),))
                              ),
                              Container(
                                width: MediaQuery.of(context).size.width*0.385,
                                child: TimeFormField(
                                        controller: this.nightModeEndTimeController,
                                        isObsecre: false,
                                        enabled: true,
                                        isKeepSpaceForOuterIcon: false,
                                        hintText: "endTime".tr(),
                                    ),
                               ),
                            ],
                          ),
                        ),

                        Padding(
                          padding: const EdgeInsets.only(left: 60,right: 55,top: 50,bottom: 50),
                          child: Container(
                            height:45 ,
                            width: 300,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.all(
                                    Radius.circular(10)),
                                boxShadow: [
                                  BoxShadow(color: AppTheme.colorDarkGrey,spreadRadius:2 , blurRadius: 0,)
                                ]
                            ),
                            child: ElevatedButton(

                              style: ElevatedButton.styleFrom(
                                  surfaceTintColor: Colors.transparent,
                                  primary: AppTheme.colorDarkGrey,
                                  elevation: 10, shadowColor: AppTheme.colorDarkGrey),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(right: 15),
                                    child: SvgPicture.asset(AppImages.saveIcon,
                                      height: 25,),
                                  ),
                                  Text('save', style: TextStyle(fontSize: 18.0, color: Colors.white),).tr(),
                                ],
                              ),
                              onPressed: () async {
                                insertNightFee();
                                Navigator.pop(context);
                              },
                            ),
                          ),
                        ),

                      ],
                    ),
                  )
              )

            ],
          )
      ),
    );
  }
  insertNightFee() async{
    await NightModeFeeDao().getAllNightModeFee().then((value) async{
      if(value.length>0) {
        await NightModeFeeDao()
            .updateNightModeFee(NightModeFeeModel(1,
            activateNightFeeRestaurant,
            activateNightFeeDelivery,
            double.parse(nightFeeController.text.split(decimalSeparator)[0]!),
            timeOfDayStart!.format(context).toString()!,
            timeOfDayEnd!.format(context).toString()!)).then((value){
          NightModeFeeDao().getNightModeFeeLast().then((value1) {
            print("Last recordddddddddddddddddddddddd: ${value1!.id} ${value1.activateNightFeeRestaurant}");
            NightModeFeeApi.updateNightModeFeeServer(value1!);
          });
        });

      }
      else{
        await NightModeFeeDao()
            .insertNightModeFee(
            NightModeFeeModel(1,
                activateNightFeeRestaurant,
                activateNightFeeDelivery,
            double.parse(nightFeeController.text),
                timeOfDayStart!.format(context).toString().split(decimalSeparator)[0]!,
                timeOfDayEnd!.format(context).toString()!)).then((value){
                  NightModeFeeApi.saveNightModeFeeToServer();
        });
      }
    });
  }
int serverId=0;
  getNightFee() async{
    var response=await NightModeFeeDao().getAllNightModeFee().then((value) {
      setState((){
        if(value.length>0) {
          serverId=value[0].serverId!;
          activateNightFeeRestaurant = value[0].activateNightFeeRestaurant;
          activateNightFeeDelivery = value[0].activateNightFeeDelivery;
          nightFeeController.text =
              value[0].nightFee.toStringAsFixed(2).replaceAll(
                  '.', decimalSeparator).toString();
          nightModeStartTimeController.text =
          value[0].startTime.toString();
          nightModeEndTimeController.text =
          value[0].endTime.toString();
        }
      });
    });
  }
}
