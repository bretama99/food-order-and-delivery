import 'dart:collection';
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:geolocator/geolocator.dart';
import 'package:opti_food_app/assets/images.dart';
import 'package:opti_food_app/data_models/contact_model.dart';
import 'package:opti_food_app/data_models/restaurant_info_model.dart';
import 'package:opti_food_app/database/restaurant_info_dao.dart';
import 'package:opti_food_app/utils/constants.dart';
import 'package:opti_food_app/widgets/appbar/app_bar_optifood.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../data_models/order_model.dart';
import '../../database/order_dao.dart';
import '../../widgets/app_theme.dart';

class DeliveryBoyPathOptimization extends StatelessWidget{
  @override


  Widget build(BuildContext context) {
    /*return MaterialApp(
      home: _DeliveryBoyPathOptimization(),
    );*/
    return _DeliveryBoyPathOptimization();
  }
}

class _DeliveryBoyPathOptimization extends StatefulWidget{
  @override
  _DeliveryBoyPathOptimizationState createState() => _DeliveryBoyPathOptimizationState();
}

class _DeliveryBoyPathOptimizationState extends State {
  String totalTime = "0m";
  String arrivalTime = "";
  String totalDistance = "0 km";

  List<Map<String,String>> optimizationList = [];
  Map<String,OrderModel> orderLatLngMap = {};
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getData();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      /*appBar: AppBar(
        automaticallyImplyLeading: false,
        elevation: 0,
        titleSpacing: 0,
        backgroundColor: AppTheme.colorLightGrey,
        title: Card(
          color: AppTheme.colorLightGrey,
          child: Container(
            decoration: const BoxDecoration(
                color:Colors.white,
                borderRadius: BorderRadius.horizontal(left:
                Radius.circular(6),right: Radius.circular(6))),
            child: Row(
              children: [
                Container(
                  decoration: const BoxDecoration(
                    border: Border(right: BorderSide(color: AppTheme.colorLightGrey))
                  ),
                  child: InkWell(
                    onTap: ()
                    {
                      //        Navigator.of(context).pop();
                      Navigator.pop(context);
                    },
                    child: SvgPicture.asset("assets/images/icons/back.svg", height: 45, color: Color(0xff000000),)),
                  ),
              ],
            ),
          ),
        ),
      ),*/
      appBar: AppBarOptifood(),

      body: Container(

          child:
              Column(
                children: [
                  /*Flexible(
                    flex: 1,
                     child: DropdownButton<String>(
                        items: <String>['A', 'B', 'C', 'D'].map((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                        onChanged: (_) {},
                      )
                  ),*/
                  Container(
                    height: 70,
                    color: AppTheme.colorLightGrey,
                    padding: EdgeInsets.only(right: 20.0,left: 20.0),
                    child: Row(
                        children: [
                          Flexible(
                            flex:1,
                            fit: FlexFit.tight,
                            child:
                            Container(
                              alignment: Alignment.centerLeft,
                              //child: Image.asset('assets/images/map_icons/est_marker_red.png',width: 35,height: 35,alignment: Alignment.centerLeft,),),
                                child: 
                                Column(
                                  children: [
                                    SvgPicture.asset("assets/svg/icons/map/location.svg", height: 45, color: Color(0xff000000),fit: BoxFit.fill,),
                                    SizedBox(height: 7,),
                                    const Text("6 Points",style: TextStyle(color: Colors.black,fontSize: 14),)
                                  ],
                                )
                            )
                          ),
                          Flexible(
                            flex:1,
                            fit: FlexFit.tight,
                            child:
                            Container(
                              alignment: Alignment.center,
                              //child: Image.asset('assets/images/map_icons/est_timer.png',width: 35,height: 35,alignment: Alignment.centerLeft,),),
                                child:
                                Column(
                                  children: [
                                  SvgPicture.asset("assets/svg/icons/map/distance.svg", height: 45, color: Color(0xff000000),fit: BoxFit.fill,),
                                    SizedBox(height: 7,),
                                    //Text("442.5 km",style: TextStyle(color: Colors.black,fontSize: 14),).tr()
                                    Text(totalDistance,style: TextStyle(color: Colors.black,fontSize: 14),).tr()
                                  ],
                                )
                            )
                          ),

                          Flexible(
                            flex:1,
                            fit: FlexFit.tight,
                            child:
                            Container(
                                alignment: Alignment.center,
                                //child: Image.asset('assets/images/map_icons/est_timer.png',width: 35,height: 35,alignment: Alignment.centerLeft,),),
                                child:
                                Column(
                                  children: [
                                    SvgPicture.asset("assets/svg/icons/map/stopwatch.svg", height: 45, color: Color(0xff000000),fit: BoxFit.fill,),
                                    SizedBox(height: 7,),
                                    //Text("5h 14",style: TextStyle(color: Colors.black,fontSize: 14),)
                                    Text(totalTime,style: TextStyle(color: Colors.black,fontSize: 14),)
                                  ],
                                )

                          ),
                          ),

                          Flexible(
                            flex:1,
                            fit: FlexFit.tight,
                            child:
                            Container(
                              alignment: Alignment.centerRight,
                                child:
                                Column(
                                  children: [
                                  SvgPicture.asset("assets/svg/icons/map/clock.svg", height: 45, color: Color(0xff000000),),
                                    SizedBox(height: 7,),
                                    //Text("13:23",style: TextStyle(color: Colors.black,fontSize: 14),)
                                    Text(arrivalTime,style: TextStyle(color: Colors.black,fontSize: 14),)
                                  ],
                                )
                            )
                          ),
                        ]
                    ),
                  ),
                  Expanded(
                    //padding: EdgeInsets.all(5),
                    child:
                    Padding(
                      padding: EdgeInsets.all(5),
                      child: createItemCard(),
                    )
                  )
                ],
              )

      )
    );
  }

  Future<void> getData() async {
    LocationPermission locationPermission = await Geolocator.checkPermission();
    locationPermission = await Geolocator.requestPermission();
    if(locationPermission == LocationPermission.denied)
    {
      locationPermission = await Geolocator.requestPermission();
    }
    String clientLatLon = "";
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    OrderDao().getAllOrders().then((orders) async {
      orders.forEach((order) {
        if(order.orderType == ConstantOrderType.ORDER_TYPE_DELIVERY){
          ContactModel? contactModel = order.customer;
          clientLatLon = clientLatLon + "|" + contactModel!.getDefaultAddress().lat.toString() + "," + contactModel!.getDefaultAddress().lon.toString();
          orderLatLngMap[contactModel.getDefaultAddress().lat.toString()+"_"+contactModel.getDefaultAddress().lon.toString()] = order;
        }
      });
      RestaurantInfoModel restaurantInfoModel = await RestaurantInfoDao().getRestaurantInfo();
      String url = "https://maps.googleapis.com/maps/api/directions/json?origin=" +
                    //restaurantInfoModel.lat.toString() + "," +
                    //restaurantInfoModel.lon.toString() +
                    position.latitude.toString() + "," +
                    position.longitude.toString() +
                    "&destination=" +
                    restaurantInfoModel.lat.toString() + "," +
                    restaurantInfoModel.lon.toString() +
                    "&waypoints=optimize:true" + clientLatLon +
                    "&key=AIzaSyDzUrI1I9awcIGQViB8xEIzcMVLlPqmu_k";

      final dio = Dio();
      print(url);
      await dio.get(url).then((response){
        print(response.data);
        int totalTimeMinutes = 0;
        int totalDistanceMeters = 0;
        Map<String,dynamic> jsonData = response.data;
        List jsonRouteList = jsonData['routes'] as List;
        jsonRouteList.forEach((jsonRoute) {
          print("in loop");
          List jsonLegList = jsonRoute['legs'];
          jsonLegList.forEach((jsonLeg) {
            print("in inner loop");

            // get time duration and estimated time
            Map<String,dynamic> durationObject = jsonLeg['duration'];
            String duration = durationObject['text'] as String;
            int timeMinutes = 0;
            List durationList = duration.split(" ");
            if(durationList.length == 4){
              timeMinutes = int.parse(durationList[0]) * 60;
              timeMinutes = timeMinutes + int.parse(durationList[2]);
              totalTimeMinutes = totalTimeMinutes + timeMinutes;

              //totalTimeMinutes = totalTimeMinutes + int.parse(durationList[0]) * 60;
              //totalTimeMinutes = totalTimeMinutes + int.parse(durationList[2]);
            }
            if(durationList.length == 2){
              if(durationList[1] == "hours"){
                timeMinutes = (int.parse(durationList[0])) * 60;
                totalTimeMinutes = totalTimeMinutes + timeMinutes;
              }
              else{
                timeMinutes =   int.parse(durationList[0]);
                totalTimeMinutes = totalTimeMinutes + timeMinutes;
              }
            }

            //get distance
            Map<String,dynamic> distanceObject = jsonLeg['distance'];
            //totalDistanceMeters = totalDistanceMeters + int.parse(distanceObject['value']);
            totalDistanceMeters = totalDistanceMeters + distanceObject['value'] as int;

            Map<String,dynamic> startLocation = jsonLeg['start_location'];
            Map<String,dynamic> endLocation = jsonLeg['end_location'];

            String startLatLngKey = startLocation["lat"].toString()+"_"+startLocation["lng"].toString();
            String endLatLngKey = endLocation["lat"].toString()+"_"+endLocation["lng"].toString();

            optimizationList.add({
              "duration":formatTimeDuration(timeMinutes),
              "distance": ((distanceObject['value'] as int)/1000).toStringAsFixed(1)+" km",
              "start_address":jsonLeg['start_address'],
              "end_address":jsonLeg['end_address'],
              "start_customer_name":orderLatLngMap.containsKey(startLatLngKey)?orderLatLngMap[startLatLngKey]!.customer!.lastName+" "+orderLatLngMap[startLatLngKey]!.customer!.firstName:"",
              "end_customer_name":orderLatLngMap.containsKey(endLatLngKey)?orderLatLngMap[endLatLngKey]!.customer!.lastName+" "+orderLatLngMap[endLatLngKey]!.customer!.firstName:""
            });
          });
        });
        setState(() {
          totalTime = "";
          arrivalTime = "";
          totalDistance = "";

          totalTime = formatTimeDuration(totalTimeMinutes);

          DateFormat dateFormat = DateFormat("HH:mm");
          arrivalTime = dateFormat.format(DateTime.now().add(Duration(minutes: totalTimeMinutes)));

          totalDistance = (totalDistanceMeters/1000).toStringAsFixed(1)+" km";
        });
      }).catchError((err){
        print("Error : "+err.toString());
      });
    });
  }

  String formatTimeDuration(int timeMinutes){
    String responseTime = "";
    int hours = timeMinutes~/60;
    int mins = timeMinutes%60;
    if(hours>=1){
      responseTime = hours.toString() + " h ";
    }
    if(mins>=1){
      responseTime = responseTime + mins.toString() + " min";
    }
    return responseTime;
  }

  Widget createItemCard()
  {
    return ListView.builder(
        itemCount: optimizationList.length,
        itemBuilder: (BuildContext ctx,int index){
          return Container(
              constraints: const BoxConstraints(minHeight: 0,maxHeight: 200),
              child:
              Card(
                  color: Colors.white,
                  surfaceTintColor: Colors.transparent,
                  shadowColor: Colors.white38,
                  elevation:4,
                  shape:  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10), // <-- Radius
                  ),
                  child:
                  Container(
                    //padding: EdgeInsets.only(left: 10,right: 10),
                    child:
                    Column(
                      children: [
                        Expanded(
                            child:
                            Container
                              (
                              //padding: EdgeInsets.all(10),
                              padding: EdgeInsets.only(top: 10,bottom: 10),
                              child:
                              Row(
                                children: [
                                  Flexible(
                                      //flex: 1,
                                      flex: 2,
                                      fit: FlexFit.loose,
                                      child:
                                      Container(
                                        padding: EdgeInsets.all(10),
                                        alignment: Alignment.center,
                                        height: double.infinity,
                                        width: double.infinity,
                                        //child: Image.asset('assets/images/map_icons/est_marker_red.png',width: 35,height: 35,alignment: Alignment.centerLeft,),
                                          child: SvgPicture.asset("assets/svg/icons/map/location.svg", height: 45, color: Color(0xff000000),),
                                      )
                                  ),
                                  Expanded(
                                      //flex: 4,
                                      flex: 8,
                                      child : Container(
                                          //padding: EdgeInsets.all(10),
                                          padding: EdgeInsets.only(left: 10),
                                          decoration: BoxDecoration(border: Border(left: BorderSide(color: AppTheme.colorLightGrey,width: 1.0,style: BorderStyle.solid),right: BorderSide(color: AppTheme.colorLightGrey,width: 1.0,style: BorderStyle.solid))),
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Flexible(
                                                flex: 1,
                                                child: Text(optimizationList[index]["start_customer_name"].toString(),style: TextStyle(color: Colors.black,fontSize: 16,fontWeight: FontWeight.bold),),
                                                //child: Text(optimizationList[index]["start_address"].toString(),style: TextStyle(color: Colors.black,fontSize: 16,fontWeight: FontWeight.bold),),
                                              ),
                                              Container(
                                                padding: EdgeInsets.only(top: 10,left: 10),
                                                child: Wrap(
                                                  children: [
                                                    //Text("Heading1 : ",style: TextStyle(color: Colors.black,fontSize: 12),),
                                                    Text(optimizationList[index]["start_address"].toString(),style: TextStyle(color: Colors.red,fontSize: 12),),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          )
                                      )

                                  ),
                                  //Container(
                                  Expanded(
                                      //padding: EdgeInsets.all(10),
                                      flex: 3,
                                      child: Column(
                                        children: [
                                          Flexible(
                                            flex: 1,
                                            //child: Image.asset('assets/images/map_icons/est_clock.png',width: 25,height: 25,alignment: Alignment.centerLeft,),
                                            child: SvgPicture.asset("assets/svg/icons/map/distance.svg", height: 45, color: AppTheme.colorRed,),
                                          ),
                                          SizedBox(height: 5,),
                                          Flexible(
                                            flex: 1,
                                            //child: Text("20.9 KM",style: TextStyle(fontSize: 18,color: Colors.grey),),
                                            child: Text(optimizationList[index]["distance"].toString(),style: TextStyle(fontSize: 18,color: Colors.grey),),
                                          ),
                                        ],
                                      )
                                  ),
                                ],
                              ),
                            )

                        ),
                        Expanded(child:
                        Container
                          (
                          decoration: BoxDecoration(border: Border(top: BorderSide(color: AppTheme.colorLightGrey,width: 1,style: BorderStyle.solid))),
                          //padding: EdgeInsets.all(10),
                          padding: EdgeInsets.only(top: 10,bottom: 10),
                          child:
                          Row(
                            children: [
                              Flexible(
                                  flex: 2,
                                  child:
                                  Container(
                                    padding: EdgeInsets.all(10),
                                    //child: Image.asset('assets/images/map_icons/est_flag.png',width: 35,height: 35,alignment: Alignment.centerLeft,),
                                    //child: SvgPicture.asset("assets/svg/icons/map/finish-flag.svg", height: 45, color: Color(0xff000000),),
                                    child: SvgPicture.asset(AppImages.finishFlag, height: 45, color: Color(0xff000000),),
                                  )
                              ),
                              Expanded(
                                  flex: 8,
                                  child : Container(
                                      //padding: EdgeInsets.all(10),
                                      padding: EdgeInsets.only(left: 10),
                                      decoration: BoxDecoration(border: Border(left: BorderSide(color: AppTheme.colorLightGrey,width: 1.0,style: BorderStyle.solid),right: BorderSide(color: AppTheme.colorLightGrey,width: 1.0,style: BorderStyle.solid))),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Flexible(
                                            flex: 1,
                                            child: Text(optimizationList[index]["end_customer_name"].toString(),style: TextStyle(color: Colors.black,fontSize: 16,fontWeight: FontWeight.bold),).tr(),
                                            //child: Text(optimizationList[index]["end_address"].toString(),style: TextStyle(color: Colors.black,fontSize: 16,fontWeight: FontWeight.bold),).tr(),
                                          ),
                                          Container(
                                            padding: EdgeInsets.only(top: 10,left: 10),
                                            child: Wrap(
                                              children: [
                                                //Text("Heading1 : ",style: TextStyle(color: Colors.black,fontSize: 12),),
                                                Text(optimizationList[index]["end_address"].toString(),style: TextStyle(color: Colors.red,fontSize: 12),),
                                              ],
                                            ),
                                          ),
                                        ],
                                      )
                                  )

                              ),
                              //Container(
                                Expanded(
                                  //padding: EdgeInsets.all(10),
                                  flex: 3,
                                  child: Column(
                                    children: [
                                      Flexible(
                                        flex: 1,
                                        //child: Image.asset('assets/images/map_icons/est_clock.png',width: 25,height: 25,alignment: Alignment.centerLeft,),
                                        child: SvgPicture.asset("assets/svg/icons/map/stopwatch.svg", height: 45, color: AppTheme.colorRed,),
                                      ),
                                      SizedBox(height: 5,),
                                      Flexible(
                                        flex: 1,
                                        //child: Text("20.9 KM",style: TextStyle(fontSize: 18,color: Colors.grey),),
                                        child: Text(optimizationList[index]["duration"].toString(),style: TextStyle(fontSize: 18,color: Colors.grey),),
                                      ),
                                    ],
                                  )
                              ),
                            ],
                          ),
                        )
                        )

                      ],
                    ),
                  )


          ),
          );
        });
  }
  /*Widget createItemCard()
  {
    return
      Container(

        constraints: const BoxConstraints(minHeight: 0,maxHeight: 100),
        child:  Card(
           elevation: 5,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15.0),
              side: BorderSide(color: Colors.grey,width: 2.5,style: BorderStyle.solid)
          ),
          child:
              //Column(
                //children: [
                  Row(
                    children: [
                      //Container(
                      //padding: EdgeInsets.all(10),
                      //child:
                      Flexible(
                          flex: 1,
                          child:
                          Container(
                            child: Image.asset('assets/images/map_icons/est_marker_red.png',width: 35,height: 35,alignment: Alignment.centerLeft,),
                          )
                      ),

                      Expanded(
                          flex: 4,
                          child : Container(
                              padding: EdgeInsets.all(10),
                              decoration: BoxDecoration(border: Border(left: BorderSide(color: Colors.grey,width: 1.0,style: BorderStyle.solid),right: BorderSide(color: Colors.grey,width: 1.0,style: BorderStyle.solid))),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Flexible(
                                    flex: 1,
                                    child: Text("Heading",style: TextStyle(color: Colors.black,fontSize: 16,fontWeight: FontWeight.bold),),
                                  ),
                                  Container(
                                    padding: EdgeInsets.only(top: 10,left: 10),
                                    child: Wrap(
                                      children: [
                                        Text("Heading1 : ",style: TextStyle(color: Colors.black,fontSize: 12),),
                                        Text("Hello to all of you",style: TextStyle(color: Colors.red,fontSize: 12),),
                                      ],
                                    ),
                                  ),
                                ],
                              )
                          )

                      ),
                      Flexible(
                          flex: 1,
                          child: Column(
                            children: [
                              Flexible(
                                flex: 1,
                                child: Image.asset('assets/images/map_icons/est_clock.png',width: 25,height: 25,alignment: Alignment.centerLeft,),
                              ),
                              SizedBox(height: 5,),
                              Flexible(
                                flex: 1,
                                child: Text("20.9 KM",style: TextStyle(fontSize: 18,color: Colors.grey),),
                              ),
                            ],
                          )
                      ),
                      // )
                    ],
                  ),
                //],
              //)
        ),
      );
  }*/
}