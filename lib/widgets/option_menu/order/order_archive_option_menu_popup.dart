import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:opti_food_app/assets/images.dart';
import 'package:opti_food_app/widgets/option_menu/option_menu_tile.dart';

import '../../../screens/MountedState.dart';
import '../../app_theme.dart';

class OrderArchiveOptionMenuPopup extends StatefulWidget{
  Function onSelect;
  static _OrderOptionMenuesAction ACTIONS = _OrderOptionMenuesAction();
  OrderArchiveOptionMenuPopup({required this.onSelect}){

  }
  @override
  State<StatefulWidget> createState() => _OptionMenuState();
}
class _OptionMenuState extends MountedState<OrderArchiveOptionMenuPopup>{
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
                          OptionMenuTile(SvgPicture.asset(AppImages.restoreIcon, height: 30, color:AppTheme.colorGreen),Colors.white,"RESTORE" ,(){
                            Navigator.pop(context);
                            widget.onSelect(OrderArchiveOptionMenuPopup.ACTIONS.ACTION_RESTORE);
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
  String ACTION_RESTORE = "action_restore";
}
