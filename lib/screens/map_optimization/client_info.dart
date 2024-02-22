import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:opti_food_app/data_models/delivery_boys.dart';

import '../../assets/images.dart';
import '../../widgets/app_theme.dart';
import 'package:url_launcher/url_launcher.dart' as UrlLauncher;

import '../MountedState.dart';
import '../order/restaurant_group_order.dart';

class ClientInfoGoogleMap extends StatefulWidget {
  final DeliveryBoys order;
  const ClientInfoGoogleMap({Key? key, required this.order}) : super(key: key);

  @override
  State<ClientInfoGoogleMap> createState() => _ClientInfoGoogleMapState();
}

class _ClientInfoGoogleMapState extends MountedState<ClientInfoGoogleMap> {
  @override
  Widget build(BuildContext context) {
    return Dialog(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        shape:
        const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(bottomLeft: Radius.circular(20), bottomRight: Radius.circular(20),
            topLeft:  Radius.circular(20), topRight:  Radius.circular(20),),
        ),
        //backgroundColor: Colors.red,
        child:
        SingleChildScrollView(
          child: Container(
            padding: EdgeInsets.only(top: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Container(
                //   padding: EdgeInsets.all(10),
                //   // child: SvgPicture.asset(AppImages.restaurantIcon, height: 30, color: Colors.white,),
                //   decoration:
                //   BoxDecoration(
                //       color: Colors.red,
                //       borderRadius: BorderRadius.circular(25)
                //   ),
                // ),
                // Image.asset(AppImages.shadowIcon,width: 50, height: 30,),
                Container(
                    margin: const EdgeInsets.only(top: 2),
                    decoration: BoxDecoration(
                      border: Border(bottom: BorderSide(color: AppTheme.colorMediumGrey,width:0.8,style: BorderStyle.solid)),
                    ),
                    child: Text("Customer Information",style: TextStyle(color: Colors.black,fontWeight: FontWeight.bold,fontSize: 18),)),
                Row(
                  children: [
                    Padding(padding: EdgeInsets.all(10),
                        child:

                        Text("Full Name: ", textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 14),)

                    ),
                    Padding(padding: EdgeInsets.all(1),
                        child:

                        Text("${widget.order.name}", textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 14),)

                    ),
                  ],
                ),
                Row(
                  children: [
                    Padding(padding: EdgeInsets.all(10),
                        child:

                        Text("Phane Number: ", textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 14),)

                    ),
                    Padding(padding: EdgeInsets.all(1),
                        child:

                        Text("${widget.order.name}", textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 14),)

                    ),
                  ],
                ),

                Row(
                  children: [
                    Padding(padding: EdgeInsets.all(10),
                        child:

                        Text("Address: ", textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 14),)

                    ),
                    Padding(padding: EdgeInsets.all(1),
                        child:

                        Text("${widget.order.adress}", textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 14),)

                    ),
                  ],
                ),
                Row(
                  children: [
                    Padding(padding: EdgeInsets.all(10),
                        child:

                        Text("Email: ", textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 14),)

                    ),
                    Padding(padding: EdgeInsets.all(1),
                        child:

                        Text("${widget.order.email}", textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 14),)

                    ),
                  ],
                ),
                Container(
                  margin: const EdgeInsets.only(top: 20),
                  decoration: BoxDecoration(
                    border: Border(top: BorderSide(color: AppTheme.colorMediumGrey,width:0.1,style: BorderStyle.solid)),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                          flex: 1,
                          child:
                          InkWell(
                            onTap: () async {

                              Navigator.pop(context);
                              // await Navigator.of(context).push(
                              //     MaterialPageRoute(builder: (context) =>
                              //         RestaurantGroupOrder(primaryOrder: widget.order,)));
                              // widget.positiveButtonPressed();
                            },
                            child: Container(
                              padding: EdgeInsets.all(20),
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                border: Border(right: BorderSide(color: AppTheme.colorMediumGrey,width:0.1,style: BorderStyle.solid)),
                              ),
                              child:
                              Text("Group",
                                  style: TextStyle(
                                    //color: AppTheme.colorMediumGrey,fontSize: 18,fontWeight: FontWeight.bold),
                                    color: AppTheme.colorMediumGrey,
                                    fontWeight: FontWeight.normal,
                                    fontSize: 16,
                                  )
                              ),
                            ),
                          )
                      ),

                      Expanded(
                          flex: 1,
                          child:
                          InkWell(
                            onTap: (){
                              Navigator.pop(context);
                              UrlLauncher.launch("tel:"+widget.order.phoneNumber);
                              // widget.negativeButtonPressed();
                            },
                            child: Container(
                              padding: EdgeInsets.all(20),
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                //border: Border(right: BorderSide(color: AppTheme.colorLightGrey,width:1,style: BorderStyle.solid)),
                              ),
                              child:
                              Text("Call",
                                  style: TextStyle(
                                    //color: AppTheme.colorMediumGrey,fontSize: 18,fontWeight: FontWeight.bold),
                                    color:  AppTheme.colorMediumGrey,
                                    fontWeight: FontWeight.normal,
                                    fontSize: 16,
                                  )
                              ),

                            ),
                          )
                      ),

                      //),
                    ],
                  ),
                )
              ],
            ),
          ),
        )
    );
  }
}
