import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:opti_food_app/assets/images.dart';

import 'package:opti_food_app/screens/Order/order_taking_window.dart';
import 'package:opti_food_app/screens/Order/ordered_lists.dart';

import '../../../data_models/food_items_model.dart';
import '../../../screens/MountedState.dart';
import '../../../screens/order/order_taking_window.dart';
import '../../app_theme.dart';
class RadioInputPopup extends StatefulWidget {
  Function? onSelect;
  FoodItemsModel foodItemModel;
  bool value= true;
  Color? activeColor;
  bool groupValue=false;
  bool toggleable=true;
  List<Widget>? beforeContent;
  static _Components components = const _Components();
  bool cancelButtonNeeded=true;
  bool contentEditable=true;
  final Function positiveButtonPressed;
  final Function negativeButtonPressed;
  final List<String> items;
  List<String> selectedItems;
  RadioInputPopup(
      {Key? key,
        required this.value,
        this.activeColor,
        required this.groupValue,
        required this.toggleable,
        this.beforeContent,
        this.onSelect,
        required this.foodItemModel,
        required this.contentEditable,
        required this.cancelButtonNeeded,
        this.positiveButtonPressed = _defFunction,
        this.negativeButtonPressed = _defFunction,
        required this.items,
        required this.selectedItems,
      });

  @override
  State<RadioInputPopup> createState() => _RadioInputPopupState();

  static _defFunction()
  {

  }
}

class _RadioInputPopupState extends MountedState<RadioInputPopup> {
  final TextEditingController textEditingController = TextEditingController();
  bool _validateTextField = true;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    allergenceList.forEach((element) {
      if(widget.foodItemModel.allergence.contains(element.name)){
        element.isSelected = true;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return
      Dialog(
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.transparent,
          shape:
          const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(bottomLeft: Radius.circular(20), bottomRight: Radius.circular(20),
              topLeft:  Radius.circular(20), topRight:  Radius.circular(20),),
          ),
          child:
          Container(
              padding: EdgeInsets.only(top: 15),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ...widget.beforeContent!,
                  Flexible(
                    child: GridView.builder(
                      shrinkWrap: true,
                      scrollDirection: Axis.vertical,
                      itemCount:widget.items.length==0?allergenceList.length:widget.items.length,
                      itemBuilder: (BuildContext context, int index) {
                        return
                          Container(
                            height: 30,
                            padding: EdgeInsets.zero,
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if(widget.items.length>0)
                                  Radio(
                                      value: true,
                                      activeColor: AppTheme.colorRed,
                                      groupValue: widget.selectedItems.contains(widget.items![index]),
                                      toggleable: true,
                                      onChanged: (isChecked){
                                        setState(() {
                                          _itemChange(widget.items[index], !widget.selectedItems.contains(widget.items[index]));
                                        });
                                      }),

                                if(widget.items.length>0)
                                  Text(widget.items[index],style: TextStyle(fontWeight: FontWeight.bold),),
                                if(widget.items.length==0)
                                  Radio(
                                      value: true,
                                      activeColor: AppTheme.colorRed,
                                      groupValue: allergenceList[index].isSelected,
                                      toggleable: true,
                                      onChanged: (value){
                                        if(widget.contentEditable){
                                          setState((){
                                            allergenceList[index].isSelected=!allergenceList[index].isSelected;
                                          });
                                        }
                                      }),

                                if(widget.items.length==0)
                                  Text(allergenceList[index].name,style: TextStyle(fontWeight: FontWeight.bold),)
                              ],
                            ),
                          );

                      }, gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 2,
                        mainAxisSpacing: 2,
                        childAspectRatio: 8/2

                    ),
                    ),
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
                                if(widget.items.length==0) {
                                  String allergence = "";
                                  allergenceList.where((element) =>
                                  element.isSelected == true).forEach((el) {
                                    allergence = allergence + el.name + ", ";
                                  });
                                  if (allergence.isNotEmpty) {
                                    allergence = allergence.trim();
                                    allergence = allergence.substring(
                                        0, allergence.length - 1);
                                  }
                                  Navigator.pop(context);
                                  widget.onSelect!(allergence);
                                }
                                else{
                                  Navigator.pop(context, widget.selectedItems);
                                }
                              },
                              child: Container(
                                padding: EdgeInsets.all(20),
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  border: Border(right: BorderSide(color: AppTheme.colorMediumGrey,width:0.1,style: BorderStyle.solid)),
                                ),
                                child:
                                Text("ok".tr().toUpperCase(),
                                    style: TextStyle(
                                      //color: AppTheme.colorMediumGrey,fontSize: 18,fontWeight: FontWeight.bold),
                                      color: AppTheme.colorMediumGrey,
                                      fontWeight: FontWeight.normal,
                                      fontSize: 16,
                                    )
                                ).tr(),
                              ),
                            )
                        ),
                        if(widget.cancelButtonNeeded)
                          Expanded(
                              flex: 1,
                              child:
                              InkWell(
                                onTap: (){
                                  Navigator.pop(context);
                                  //widget.negativeButtonPressed();
                                },
                                child: Container(
                                  padding: EdgeInsets.all(20),
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                  ),
                                  child:
                                  Text("cancel".tr().toUpperCase(),
                                      style: TextStyle(
                                        //color: AppTheme.colorMediumGrey,fontSize: 18,fontWeight: FontWeight.bold),
                                        color:  AppTheme.colorMediumGrey,
                                        fontWeight: FontWeight.normal,
                                        fontSize: 16,
                                      )
                                  ).tr(),

                                ),
                              )
                          ),

                      ],
                    ),
                  )
                ],
              )
          )

      );
  }
  List<AllergenceModel> allergenceList = [
    AllergenceModel("Gluten", false),
    AllergenceModel("Peanuts", false),
    AllergenceModel("Tree nuts", false),
    AllergenceModel("Celery", false),
    AllergenceModel("Mustard", false),
    AllergenceModel("Eggs", false),
    AllergenceModel("Milk", false),
    AllergenceModel("Sesame", false),
    AllergenceModel("Fish", false),
    AllergenceModel("Crustaceans", false),
    AllergenceModel("Molluscs", false),
    AllergenceModel("Soya", false),
    AllergenceModel("Sulphites", false),
    AllergenceModel("Lupin", false),
  ];

  void _itemChange(String itemValue, bool isSelected) {
    setState(() {
      if (isSelected) {
        widget.selectedItems.add(itemValue);
      } else {
        widget.selectedItems.remove(itemValue);
      }
    });
  }
}
class _Components
{
  const _Components();
  String get INPUT_TEXT => "inputText";
}

class AllergenceModel{
  String name;
  bool isSelected;
  AllergenceModel(this.name,this.isSelected);
}