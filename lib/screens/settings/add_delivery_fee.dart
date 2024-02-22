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
import 'package:opti_food_app/assets/images.dart';
import 'package:opti_food_app/data_models/attribute_category_model.dart';
import 'package:opti_food_app/data_models/company_model.dart';
import 'package:opti_food_app/data_models/delivery_fee_model.dart';
import 'package:opti_food_app/data_models/food_items_model.dart';
import 'package:opti_food_app/database/attribute_category_dao.dart';
import 'package:opti_food_app/database/company_dao.dart';
import 'package:opti_food_app/database/delivery_fee_dao.dart';
import 'package:opti_food_app/database/food_category_dao.dart';
import 'package:opti_food_app/database/food_items_dao.dart';
import 'package:opti_food_app/widgets/appbar/app_bar_optifood.dart';

import '../../api/delivery_fee.dart';
import '../../data_models/food_category_model.dart';
import '../../main.dart';
import '../../utils/constants.dart';
import '../../utils/utility.dart';
import '../../widgets/app_theme.dart';
import '../../widgets/custom_field_with_no_icon.dart';
import '../MountedState.dart';
class AddDeliveryFee extends StatefulWidget{

  @override
  State<StatefulWidget> createState() => _AddDeliveryFeeState();

}
class _AddDeliveryFeeState extends MountedState<AddDeliveryFee> with SingleTickerProviderStateMixin{
  final GlobalKey<FormState> _globalKey = GlobalKey<FormState>();
  TextEditingController displayNameController = TextEditingController();
  TextEditingController deliveryFeeController = TextEditingController();
  TextEditingController minimumOrderAmountToExpectDeliveryFeeController = TextEditingController();
  late bool activateDeliveryFee=true;
  String currency = optifoodSharedPrefrence.getString(ConstantSharedPreferenceKeys.KEY_SELECTED_CURRENCY)!=null?optifoodSharedPrefrence.getString(ConstantSharedPreferenceKeys.KEY_SELECTED_CURRENCY)!:ConstantCurrencySymbol.EURO.toString();
  String decimalSeparator = optifoodSharedPrefrence.getString(ConstantSharedPreferenceKeys.KEY_SELECTED_CURRENCY)!=null?optifoodSharedPrefrence.getString(ConstantSharedPreferenceKeys.KEY_SELECTED_DECIMAL_SEPARATOR)!:",";
  @override
  void initState() {
    getDeliveryFee();
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    FocusNode deliveryFeeFocusNode = FocusNode();
    FocusNode minimumOrderAmountToExpectDeliveryFeeFocusNode = FocusNode();
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
                          title: Text("activateDeliveryFee", style: TextStyle(fontSize: 16),).tr(),
                          trailing: Switch(
                            activeColor: AppTheme.colorRed,
                            value: activateDeliveryFee,
                            onChanged: (bool value) {
                            setState(() {
                              activateDeliveryFee=value;
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
                                  width: MediaQuery.of(context).size.width*0.53,
                              child: Flexible(
                                  flex: 1,
                                  child: Text("deliveryFee".tr(), style: TextStyle(fontSize: 16),))
                              ),
                              Container(
                                  width: MediaQuery.of(context).size.width*0.38,
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
                                        isObsecre: false,
                                        isKeepSpaceForOuterIcon: false,
                                        textInputType: TextInputType.number,
                                        controller: deliveryFeeController,
                                        focusNode: deliveryFeeFocusNode,
                                        align: "right",
                                        onChange: (){
                                          // minimumOrderAmountToExpectDeliveryFeeController.text=double.parse(minimumOrderAmountToExpectDeliveryFeeController.text).toStringAsFixed(2).replaceAll('.', decimalSeparator);
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
                              right: 10),
                          child: Row(
                            children: [
                              Container(
                                  width: MediaQuery.of(context).size.width*0.53,
                                  child: Flexible(
                                      flex: 1,
                                      child: Text("minimumOrderAmountToExpectDeliveryFee".tr(), style: TextStyle(fontSize: 16),))
                              ),
                              Container(
                                  width: MediaQuery.of(context).size.width*0.38,
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
                                        isObsecre: false,
                                        isKeepSpaceForOuterIcon: false,
                                        textInputType: TextInputType.number,
                                        controller: minimumOrderAmountToExpectDeliveryFeeController,
                                        focusNode: minimumOrderAmountToExpectDeliveryFeeFocusNode,
                                        align: "right",
                                        onChange: (){
                                          // deliveryFeeController.text=double.parse(deliveryFeeController.text).toStringAsFixed(2).replaceAll('.', decimalSeparator);
                                        },
                                      )
                                  )),
                              Container(
                                child: Text("${currency}"),)
                            ],
                          ),
                        ),
                        CustomFieldWithNoIcon(
                          controller: displayNameController,
                          hintText: displayNameController.text=="Delivery Fee"?"${displayNameController.text}".tr():displayNameController.text,
                          isObsecre: false,
                            isKeepSpaceForOuterIcon:false,
                            paddingParameters: PaddingParameters(5, 7, 13, 7),
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
                                insertDeliveryFee();
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

  insertDeliveryFee() async{
    await DeliveryFeeDao().getAllDeliveryFees().then((value) async{
      if(value.length>0) {
        await DeliveryFeeDao()
            .updateDeliveryFee(DeliveryFeeModel(1,
            activateDeliveryFee,
            double.parse(deliveryFeeController.text.split("${decimalSeparator}")[0].toString()),
            double.parse(deliveryFeeController.text.split("${decimalSeparator}")[0].toString()),
            displayNameController.text)).then((value){
          DeliveryFeeDao().getDeliveryFeeLast().then((value1){
            DeliveryFeeApi.updateDeliveryFeeServer(value1!);
          });
        });
      }
      else{
        await DeliveryFeeDao()
            .insertDeliveryFee(DeliveryFeeModel(1, activateDeliveryFee,
            double.parse(deliveryFeeController.text.split(currency)[0].toString()),
            double.parse(deliveryFeeController.text.split(currency)[0].toString()),
            displayNameController.text)).then((value){
          DeliveryFeeApi.saveDeliveryFeeToServer();
        });
      }
    });
  }


  getDeliveryFee() async{
    var response=await DeliveryFeeDao().getAllDeliveryFees().then((value) {
      if(value.length>0) {
        setState(() {
          activateDeliveryFee = value[0].activateDeliveryFee;
        });
        deliveryFeeController.text =
            value[0].deliveryFee.toStringAsFixed(2).replaceAll(
                '.', decimalSeparator).toString();
        minimumOrderAmountToExpectDeliveryFeeController.text =
            value[0].minimumOrderAmountToExpectDeliveryFee.toStringAsFixed(2)
                .replaceAll('.', decimalSeparator)
                .toString();
        displayNameController.text = value[0].displayName;
      }
      else
        displayNameController.text ="Delivery Fee";
    });
  }
}
