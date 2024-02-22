import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:opti_food_app/assets/images.dart';
import '../../widgets/app_theme.dart';
import '../order/ordered_lists.dart';
import '../MountedState.dart';
class DeleteOrder extends StatefulWidget {
  final String id;
  const DeleteOrder({required this.id});

  @override
  State<DeleteOrder> createState() => _DeleteOrderState();
}

class _DeleteOrderState extends MountedState<DeleteOrder> {
  @override
  Widget build(BuildContext context) {
    return Padding(

      padding: const EdgeInsets.fromLTRB(60, 250, 60, 0),
      child: Dialog(
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.only(bottomLeft: Radius.circular(20), bottomRight: Radius.circular(20),
              topLeft:  Radius.circular(20), topRight:  Radius.circular(20),),
          ),

          alignment: Alignment.topCenter,
          insetPadding: EdgeInsets.all(0),
          child: Stack(
            alignment: Alignment.center,
            children: <Widget>[
              Container(
                  width: double.infinity,
                  height: MediaQuery.of(context).size.height*0.30,
                  alignment: Alignment.center,
                  child:Padding(
                    padding: const EdgeInsets.fromLTRB(0, 0, 0, 8),
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(top: 142),
                          child: Container(
                            child: Padding(
                              padding: const EdgeInsets.only(top: 0),
                              child: Transform.translate(

                                offset: Offset(0, 15),
                                child: Divider(
                                  thickness: 0.4,),
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Row(
                              children: [
                                Expanded(
                                  flex:10,
                                  child: Transform.translate(
                                    offset: Offset(4, 6),
                                    //child: FlatButton(
                                    child: TextButton(
                                      //height: MediaQuery.of(context).size.height*0.30,
                                      /*shape: const RoundedRectangleBorder(
                                        borderRadius: BorderRadius.only(bottomLeft: Radius.circular(20)),
                                      ),*/
                                      style: TextButton.styleFrom(
                                        shape: const RoundedRectangleBorder(
                                          borderRadius: BorderRadius.only(bottomLeft: Radius.circular(20)),
                                        ),
                                        backgroundColor: Colors.white,
                                        foregroundColor: Colors.black,
                                      ),
                                      child: Padding(
                                        padding: EdgeInsets.only(left: 6,right: 0,top: 5),
                                        child: Transform.translate(
                                            offset: Offset(0, -5),
                                            child: Text('delete', style: TextStyle(fontSize: 15.0, color: AppTheme.colorMediumGrey),).tr()),
                                      ),
                                      //color: Colors.white,
                                      //textColor: Colors.black,
                                      onPressed: () {
                                        /*Navigator.of(context).push(MaterialPageRoute(builder: (context)=>
                                            OrderedList(id: widget.id,isEatIn:"", isTakeAway:"", tabIndex:0)));*/
                                      },
                                    ),
                                  ),
                                ),
                                Transform.translate(
                                  offset:Offset(0, 5),
                                  child: Container(
                                    height: 45,
                                    child: VerticalDivider(
                                      color: Colors.black54, thickness: 0.1,),
                                  ),
                                ),

                                Expanded(
                                  flex:11,
                                  child: Container(
                                    width: 180,
                                    child: Transform.translate(
                                      offset: Offset(-4, 6),
                                      //child: FlatButton(
                                      child: TextButton(
                                        /*height: MediaQuery.of(context).size.height*0.30,
                                        color: Colors.white,

                                        shape:  const RoundedRectangleBorder(
                                          borderRadius: BorderRadius.only(bottomRight: Radius.circular(20)),
                                        ),*/
                                        style: TextButton.styleFrom(
                                          backgroundColor: Colors.white,
                                          foregroundColor: Colors.black,
                                          shape:  const RoundedRectangleBorder(
                                            borderRadius: BorderRadius.only(bottomRight: Radius.circular(20)),
                                          ),
                                        ),
                                        child: Padding(
                                          padding: const EdgeInsets.only(left: 0,right: 0, top: 5),
                                          child: Transform.translate(
                                            offset: Offset(-4, -5),
                                            child: Text('cancel',
                                              textAlign: TextAlign.center, style: TextStyle(fontSize: 15.0,
                                                color: AppTheme.colorMediumGrey, ),).tr(),
                                          ),
                                        ),
                                        // color: Colors.white,
                                        //textColor: Colors.black,
                                        onPressed: () {
                                          /*Navigator.of(context).push(MaterialPageRoute(builder: (context)=>
                                              OrderedList(id: "", isEatIn:"", isTakeAway:"", tabIndex:0))); */
                                              },

                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
              ),
              Positioned(

                  top: 25,
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(10, 0, 0, 0),
                        child: Transform.translate(
                          offset: Offset(-5,0),
                          child: Container(
                            height: 50,
                            child: FloatingActionButton(
                              elevation: 0,

                              backgroundColor: AppTheme.colorRed,

                              child: SvgPicture.asset(AppImages.deleteWhiteIcon, height: 30, color: Colors.white,),
                              onPressed: () {

                              },
                            ),
                          ),

                          // Image.asset("images/OptiFoodLogo.png",height: 80,width: 60,)
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(10, 4, 0, 15),
                        child: Transform.translate(
                            offset: Offset(-5,-5),
                            child: Image.asset(AppImages.shadowIcon,width: 50, height: 30, )),
                      ),
                      Transform.translate(
                          offset: Offset(0, -22),
                          child: Text("confirmation", style: TextStyle(fontSize: 20,fontWeight: FontWeight.bold),).tr()),
                      Transform.translate(
                          offset: Offset(0, -20),
                          child: Text("areYouSureYouWantToDelete", style: TextStyle(fontSize: 14, color: AppTheme.colorMediumGrey),).tr()),
                    ],
                  )
              ),
            ],
          )
      ),
    );
  }
}
