import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:opti_food_app/assets/images.dart';
import 'package:opti_food_app/widgets/option_menu/option_menu_tile.dart';

import '../../../data_models/food_items_model.dart';
import '../../../data_models/user_model.dart';
import '../../../screens/MountedState.dart';
import '../../../utils/constants.dart';
import '../../app_theme.dart';

class UserOptionMenuPopup extends StatefulWidget{
  UserModel userModel;
  Function onSelect;
  static _OrderOptionMenuesAction ACTIONS = _OrderOptionMenuesAction();
  UserOptionMenuPopup({required this.onSelect,required this.userModel}){

  }
  @override
  State<StatefulWidget> createState() => _OptionMenuState();
}
class _OptionMenuState extends MountedState<UserOptionMenuPopup>{
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
      child: Dialog(
        // 5 1 1 0
        backgroundColor: Color.fromARGB(5, 1, 1, 0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.0),
        ),
        alignment: Alignment.topCenter,
        elevation: 100,
        // backgroundColor: AppTheme.colorLightGrey,
        insetPadding: EdgeInsets.fromLTRB(0, 0, 0, 0),
        child: Stack(
          children:[
            Padding(
                padding: const EdgeInsets.fromLTRB(12, 20, 15, 0),
                child: Column(
                  children: [
                    // Text("ORDER N°30",style:
                    // TextStyle(fontSize: 22,color: Colors.black),),
                    // Divider(
                    //   color: Colors.black,
                    // ),
                    Transform.translate(
                      offset: Offset(0, -5),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Container(
                                // color:Colors.grey,
                                width: MediaQuery.of(context).size.width*0.3,
                                child: Padding(
                                  padding: const EdgeInsets.only(top: 8,left: 0, bottom: 30,right: 10),
                                  child:    Container(
                                    height: 40,
                                    child: FloatingActionButton(
                                      elevation: 0,

                                      backgroundColor: AppTheme.colorDarkGrey,

                                      child:Icon(Icons.close),
                                      onPressed: () {
                                        Navigator.pop(context);
                                      },
                                    ),
                                  ),
                                ),
                              ),
                              Container(
                                width: MediaQuery.of(context).size.width*0.6,
                                // height: 90,
                                child: Padding(
                                  padding: const EdgeInsets.only(top: 8,bottom: 30,right: 10),

                                ),
                              ),
                            ],
                          ),
                          /*createOptionMenu(SvgPicture.asset("assets/images/icons/edit-red.svg", height: 30),Colors.white,"EDIT" ,(){
                            Navigator.pop(context);
                            widget.onSelect(OrderOptionMenuesAction.ACTION_EDIT);
                          }),*/
                          OptionMenuTile(SvgPicture.asset(AppImages.editRedIcon, height: 30),Colors.white,"EDIT" ,(){
                            Navigator.pop(context);
                            widget.onSelect(UserOptionMenuPopup.ACTIONS.ACTION_EDIT);
                          }),
                          if(widget.userModel.role == ConstantUserRole.USER_ROLE_DELIVERY_BOY)...[
                            OptionMenuTile(SvgPicture.asset(AppImages.phoneClientIcon, height: 30,color: Colors.white,),AppTheme.colorGreen,"CALL" ,(){
                              Navigator.pop(context);
                              widget.onSelect(UserOptionMenuPopup.ACTIONS.ACTION_CALL);
                            }),
                          ],
                          OptionMenuTile(SvgPicture.asset(AppImages.deleteIcon, height: 30,color: Colors.white),AppTheme.colorRed,"DELETE", (){
                            Navigator.pop(context);
                            widget.onSelect(UserOptionMenuPopup.ACTIONS.ACTION_DELETE);
                          }),
                        ],
                      ),
                    ),
                  ],
                )
            ),
          ],
        ),

      ),
    );
  }
}
class _OrderOptionMenuesAction
{
  // actions for all delivery, take away and eat it
  String ACTION_EDIT = "action_edit";
  String ACTION_CALL = "action_call";
  String ACTION_DELETE = "action_delete";
}
