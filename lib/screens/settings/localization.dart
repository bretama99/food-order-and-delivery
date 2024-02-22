import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/svg.dart';
import 'package:opti_food_app/utils/constants.dart';
import 'package:opti_food_app/widgets/app_theme.dart';
import 'package:opti_food_app/widgets/appbar/app_bar_optifood.dart';
import 'package:opti_food_app/widgets/custom_drop_down.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:opti_food_app/screens/order/ordered_lists.dart';import '../MountedState.dart';
class OptifoodLocalization extends StatefulWidget{
  @override
  State<StatefulWidget> createState() => _OptifoodLocalizationState();
}
class _OptifoodLocalizationState extends MountedState<OptifoodLocalization>{
  var languages = ["English","Nederlands","Deutsh","Español","Français","Português","Italiano"];
  var dateFormats = ["dd/MM/yyyy","dd-MM-yyyy","MM/dd/yyyy","MM-dd-yyyy","yyyy-MM-dd"];
  String selectedLanguage = "Français";

  var currencies = [
    ConstantCurrencySymbol.EURO,
    ConstantCurrencySymbol.DOLLAR,
    ConstantCurrencySymbol.POUND,
    ConstantCurrencySymbol.AED,
    ConstantCurrencySymbol.DKK,
    ConstantCurrencySymbol.DA,
    ConstantCurrencySymbol.MAD,
  ];
  String selectedCurrency = ConstantCurrencySymbol.EURO;
  String groupLeftRight = "Right";
  String groupThousandsSeparator = "No Separator";
  String groupDecimalSeparator = ",";
  String groupTimeFormat = "24H";

  String selectedDateFormat = "dd/MM/yyyy";
  late SharedPreferences sharedPreferences;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    SharedPreferences.getInstance().then((value){
      sharedPreferences = value;
      setState(() {
        selectedLanguage = sharedPreferences.getString(ConstantSharedPreferenceKeys.KEY_SELECTED_LANGUAGE)!=null?sharedPreferences.getString(ConstantSharedPreferenceKeys.KEY_SELECTED_LANGUAGE)!:"Français";
        selectedCurrency = sharedPreferences.getString(ConstantSharedPreferenceKeys.KEY_SELECTED_CURRENCY)!=null?sharedPreferences.getString(ConstantSharedPreferenceKeys.KEY_SELECTED_CURRENCY)!:ConstantCurrencySymbol.EURO;
        groupLeftRight = sharedPreferences.getString(ConstantSharedPreferenceKeys.KEY_SELECTED_SYMBOL_LEFT_RIGHT)!=null?sharedPreferences.getString(ConstantSharedPreferenceKeys.KEY_SELECTED_SYMBOL_LEFT_RIGHT)!:"Right";
        selectedDateFormat = sharedPreferences.getString(ConstantSharedPreferenceKeys.KEY_SELECTED_DATE_FORMAT)!=null?sharedPreferences.getString(ConstantSharedPreferenceKeys.KEY_SELECTED_DATE_FORMAT)!:"dd/MM/yyyy";
        groupTimeFormat = sharedPreferences.getString(ConstantSharedPreferenceKeys.KEY_SELECTED_TIME_FORMAT)!=null?sharedPreferences.getString(ConstantSharedPreferenceKeys.KEY_SELECTED_TIME_FORMAT)!:"24H";
      });
    });

  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBarOptifood(),
        body: SingleChildScrollView(
          child: Container(
            padding: EdgeInsets.all(20),
            child: Column(
              children: [
                Container(
                  width: double.infinity,
                  child: Text("selectLanguage".tr(),style: TextStyle(fontWeight: FontWeight.bold,fontSize: 16),),),
                Container(
                    width: double.infinity,
                  child: CustomDropDown(dropDownItems: languages, selectedItem: selectedLanguage,isKeepSpaceForOuterIcon:false,onItemChange: (String value){
                    setState(() {
                      selectedLanguage = value;
                    });
                  },),
                ),

                Container(
                  width: double.infinity,
                  margin: EdgeInsets.only(top: 20),
                  child: Text("selectCurrency".tr(),style: TextStyle(fontWeight: FontWeight.bold,fontSize: 16),),),
                Container(
                    width: double.infinity,
                    child: CustomDropDown(dropDownItems: currencies, selectedItem: selectedCurrency,isKeepSpaceForOuterIcon:false,onItemChange: (String value){
                      setState(() {
                        selectedCurrency = value;
                      });
                    },),
                    /*child: DropdownButtonHideUnderline(
                      child: DropdownButton(
                        items: currencies.map((String items){
                          return DropdownMenuItem(
                              value: items,
                              child: Text(items));
                        }).toList(),
                        onChanged: (String? newValue){
                          setState((){
                            selectedCurrency = newValue!;
                          });
                        },
                        value: selectedCurrency,
                      ),
                    )*/
                ),
                Container(
                  margin: EdgeInsets.only(top: 20),
                  width: double.infinity,
                  child: Text("selectSymbolLocation".tr(),style: TextStyle(fontWeight: FontWeight.bold,fontSize: 16),),),
                Row(
                  children: [
                    Expanded(
                        flex: 1,
                        child:
                        ListTile(
                          leading: Radio(
                              value: "Left",
                              activeColor: AppTheme.colorRed,
                              groupValue: groupLeftRight,
                              onChanged: (value){
                                setState((){
                                  groupLeftRight = "Left";
                                });
                              }),
                          title: Text("left").tr(),
                        )
                    ),
                    Expanded(
                        flex: 1,
                        child: ListTile(
                          leading: Radio(
                              value: "Right",
                              activeColor: AppTheme.colorRed,
                              groupValue: groupLeftRight,
                              onChanged: (value){
                                setState((){
                                  groupLeftRight = "Right";
                                });
                              }),
                          title: Text("right".tr()),
                        )
                    ),
                  ],
                ),
                Container(
                  margin: EdgeInsets.only(top: 20),
                  width: double.infinity,
                  child: Text("selectThousandsSeparator".tr(),style: TextStyle(fontWeight: FontWeight.bold,fontSize: 16),),),
                Row(
                  children: [
                    Expanded(
                        flex: 1,
                        child: ListTile(
                          leading: Radio(
                              value: "No Separator",
                              activeColor: AppTheme.colorRed,
                              groupValue: groupThousandsSeparator,
                              onChanged: (value){
                                setState((){
                                  groupThousandsSeparator = "No Separator";
                                });
                              }),
                          title: Text("none".tr()),
                        )
                    ),
                    Expanded(
                        flex: 1,
                        child: ListTile(
                          leading: Radio(
                              value: ",",
                              activeColor: AppTheme.colorRed,
                              groupValue: groupThousandsSeparator,
                              onChanged: (value){
                                setState((){
                                  groupThousandsSeparator = ",";
                                });
                              }),
                          title: Text("( , )"),
                        )
                    ),
                  ],
                ),
                Container(
                  margin: EdgeInsets.only(top: 20),
                  width: double.infinity,
                  child: Text("selectDecimalSeparator".tr(),style: TextStyle(fontWeight: FontWeight.bold,fontSize: 16),),),
                Row(
                  children: [
                    Expanded(
                        flex: 1,
                        child: ListTile(
                          leading: Radio(
                              value: ",",
                              activeColor: AppTheme.colorRed,
                              groupValue: groupDecimalSeparator,
                              onChanged: (value){
                                setState((){
                                  groupDecimalSeparator = ",";
                                });
                              }),
                          title: Text("( , )"),
                        )
                    ),
                    Expanded(
                        flex: 1,
                        child: ListTile(
                          leading: Radio(
                              value: ".",
                              activeColor: AppTheme.colorRed,
                              groupValue: groupDecimalSeparator,
                              onChanged: (value){
                                setState((){
                                  groupDecimalSeparator = ".";
                                });
                              }),
                          title: Text("( . )"),
                        )
                    ),
                  ],
                ),

                Container(
                  width: double.infinity,
                  child: Text("selectDateFormat".tr(),style: TextStyle(fontWeight: FontWeight.bold,fontSize: 16),),),
                Container(
                    width: double.infinity,
                  child: CustomDropDown(dropDownItems: dateFormats, selectedItem: selectedDateFormat,isKeepSpaceForOuterIcon:false,onItemChange: (String value){
                    setState(() {
                      selectedDateFormat = value;
                    });
                  },),
                    /*DropdownButtonHideUnderline(
                      child: DropdownButton(
                        items: dateFormats.map((String items){
                          return DropdownMenuItem(
                              value: items,
                              child: Text(items));
                        }).toList(),
                        onChanged: (String? newValue){
                          setState((){
                            selectedDateFormat = newValue!;
                          });
                        },
                        value: selectedDateFormat,
                      ),
                    )*/
                ),

                Container(
                  margin: EdgeInsets.only(top: 20),
                  width: double.infinity,
                  child: Text("selectTimeFormat".tr(),style: TextStyle(fontWeight: FontWeight.bold,fontSize: 16),),),
                Row(
                  children: [
                    Expanded(
                        flex: 1,
                        child: ListTile(
                          leading: Radio(
                              value: "12H",
                              activeColor: AppTheme.colorRed,
                              groupValue: groupTimeFormat,
                              onChanged: (value){
                                setState((){
                                  groupTimeFormat = "12H";
                                });
                              }),
                          title: Text("12H"),
                        )
                    ),
                    Expanded(
                        flex: 1,
                        child: ListTile(
                          leading: Radio(
                              value: "24H",
                              activeColor: AppTheme.colorRed,
                              groupValue: groupTimeFormat,
                              onChanged: (value){
                                setState((){
                                  groupTimeFormat = "24H";
                                });
                              }),
                          title: Text("24H"),
                        )
                    ),
                  ],
                ),

                Padding(
                  padding: const EdgeInsets.only(left: 60,right: 55,top: 20,bottom: 20),
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
                            child: SvgPicture.asset("assets/images/icons/save-red.svg",
                              height: 25,),
                          ),
                          Text('save', style: const TextStyle(fontSize: 18.0, color: Colors.white),).tr(),
                        ],
                      ),
                      onPressed: () async {
                        sharedPreferences.setString(ConstantSharedPreferenceKeys.KEY_SELECTED_LANGUAGE, selectedLanguage);
                        sharedPreferences.setString(ConstantSharedPreferenceKeys.KEY_SELECTED_CURRENCY, selectedCurrency);
                        sharedPreferences.setString(ConstantSharedPreferenceKeys.KEY_SELECTED_DECIMAL_SEPARATOR, groupDecimalSeparator);
                        sharedPreferences.setString(ConstantSharedPreferenceKeys.KEY_SELECTED_SYMBOL_LEFT_RIGHT, groupLeftRight);
                        sharedPreferences.setString(ConstantSharedPreferenceKeys.KEY_SELECTED_THOUSAND_SEPARATOR, groupThousandsSeparator);
                        sharedPreferences.setString(ConstantSharedPreferenceKeys.KEY_SELECTED_DATE_FORMAT, selectedDateFormat);
                        sharedPreferences.setString(ConstantSharedPreferenceKeys.KEY_SELECTED_TIME_FORMAT, groupTimeFormat);

                        EasyLocalization.ensureInitialized();
                        if(selectedLanguage == "English"){
                          EasyLocalization.of(context)!.setLocale(Locale("en","EN"));
                        }
                        else if(selectedLanguage == "Nederlands"){
                          EasyLocalization.of(context)!.setLocale(Locale("nl","NL"));
                        }
                        else if(selectedLanguage == "Deutsh"){
                          EasyLocalization.of(context)!.setLocale(Locale("de","DE"));
                        }
                       else if(selectedLanguage == "Español"){
                          EasyLocalization.of(context)!.setLocale(Locale("es","ES"));
                        }
                        else if(selectedLanguage == "Português"){
                          EasyLocalization.of(context)!.setLocale(Locale("pt","PT"));
                        }
                        else if(selectedLanguage == "Italiano"){
                          EasyLocalization.of(context)!.setLocale(Locale("it","IT"));
                        }

                        else{
                          EasyLocalization.of(context)!.setLocale(Locale("fr","FR"));
                        }

                        Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) => OrderedList()));
                        //Navigator.of(context).pop();
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        )

    );
  }
}