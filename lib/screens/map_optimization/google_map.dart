import 'dart:math';
import 'dart:typed_data';
import 'dart:async';
import 'dart:io';
import 'dart:ui' as ui;
import 'package:cron/cron.dart';
import 'package:dio/dio.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:flutter/services.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:opti_food_app/data_models/restaurant_info_model.dart';
import 'package:opti_food_app/main.dart';
import 'package:opti_food_app/widgets/appbar/app_bar_optifood.dart';
import 'package:autocomplete_textfield/autocomplete_textfield.dart';
import 'package:roundcheckbox/roundcheckbox.dart';
import 'package:url_launcher/url_launcher.dart' as UrlLauncher;
// import 'package:flutter_typeahead/flutter_typeahead.dart';

import '../../api/user_api.dart';
import '../../assets/images.dart';
import '../../data_models/order_model.dart';
import '../../data_models/user_model.dart';
import '../../database/order_dao.dart';
import '../../database/restaurant_info_dao.dart';
import '../../database/user_dao.dart';
import '../../utils/constants.dart';
import '../../utils/utility.dart';
import '../../widgets/app_theme.dart';
import '../../widgets/appbar/app_icon_model.dart';
import '../../widgets/option_menu/user/user_option_menu_popup.dart';
import '../order/order_option_menues.dart';
import '../order/restaurant_group_order.dart';
import 'client_info.dart';
import 'delivery_boy_path_optimization.dart';
import '../../data_models/delivery_boys.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:path/path.dart' as path;
import 'package:image/image.dart' as IMG;


class GoogleMapOptifood extends StatelessWidget{

  @override
  Widget build(BuildContext context) {
    /*return MaterialApp(
      home: _GoogleMapTest(),
    );*/
    return _GoogleMap();
  }
}

class _GoogleMap extends StatefulWidget{
  @override
  _GoogleMapInitState createState() => _GoogleMapInitState();
}

class _GoogleMapInitState extends State {

  GoogleMapController? mapController;
  Completer<GoogleMapController> _controller = Completer();//contrller for Google map
  Set<Marker> markers = Set(); //markers for google map
  //LatLng showLocation = LatLng(27.7089427, 85.3086209);
  //LatLng currentPostion = LatLng(27.7089427, 85.3086209);
  LatLng showLocation = LatLng(48.7275277, 3.10574831);
  LatLng currentPostion = LatLng(48.7275277, 3.10574831);
  LatLng endPostion = LatLng(31.2175, 76.1407);
  BitmapDescriptor customIcon = BitmapDescriptor.defaultMarker;
  BitmapDescriptor restaurantIcon = BitmapDescriptor.defaultMarker;
  UserModel? userModel=null;
  OrderModel? orderModel=null;

  PolylinePoints polylinePoints = PolylinePoints();
  Map<PolylineId, Polyline> polylines = {}; //polylines to show direction
  //String googleAPiKey = "AIzaSyDcvjlWKsTTa7aF4twb0Yu5YxJHSXqEEUs";
  String googleAPiKey = "AIzaSyDzUrI1I9awcIGQViB8xEIzcMVLlPqmu_k";
  //String googleAPiKey = "AIzaSyDBV4hvIGgi6Cu-f2u_ZY2Idzdf01WvBBk";

  bool isCheckClients = true;
  bool isCheckDeliveryMen = true;
  //location to show in map
  GlobalKey<AutoCompleteTextFieldState<String>> key = GlobalKey();
  TextEditingController searchTextController=TextEditingController();
  List<String> suggestionList = [];
  List<String> customerList = [];
  List<DeliveryBoys> deliveryBoys=[];
  List<OrderModel> orders=[];
  var _selectedDeliveryBoyImage;
  var restaurantImage;
  late Uint8List markerIcon;
  double minDistance=double.infinity;
  bool isClientActive=false;
  DeliveryBoys? selectedModel=null;
  var clientValue="Client";
  var deliveryBoyvalue = "Delivery Boy";
  late RestaurantInfoModel restaurantInfo;
  late int latIndex=0, addresLength=0;

  updateMarker(){
    markers.add(Marker(
      markerId: MarkerId(currentPostion.toString()),
      position: currentPostion,
      infoWindow: InfoWindow(
      ),
      icon: BitmapDescriptor.defaultMarker, //Icon for Marker
    ));
    CameraPosition cameraPosition = CameraPosition(
      target: currentPostion,
      zoom: 12.0,
    );
    mapController?.animateCamera(CameraUpdate.newCameraPosition(cameraPosition));
  }
  static String OPTIFOOD_DATABASE='optifood';

  getUserListFromServer({Function? callback = null}) async{
    List<UserModel> fetchedData = [];
    final dio = Dio();
    dio.options.headers['X-TenantID'] = OPTIFOOD_DATABASE;
    await dio.get(ServerData.OPTIFOOD_MANAGEMENT_BASE_URL+"/api/user").then((response) async {
      List<UserModel> fetchedData = [];
      if (response.statusCode == 200) {
        for (int i = 0; i < response.data.length; i++) {
          var singleItem = UserModel.fromJsonServer(response.data[i]);
          fetchedData.add(singleItem);
        }
        UserDao().getAllUsersWithoutRole().then((value){
          var result=null;
          for(int i=0; i<fetchedData.length; i++) {

            if (value.length > 0)
              result = value.firstWhere((element) => element.serverId ==
                  fetchedData[i].serverId);
            if (result != null) {
              result?.serverId = fetchedData[i].serverId;
              result?.name = fetchedData[i].name;
              result?.latitude = fetchedData[i].latitude;
              result?.longitude = fetchedData[i].longitude;
              result?.phoneNumber = fetchedData[i].phoneNumber;
              result?.email = fetchedData[i].email;
              result?.role = fetchedData[i].role;
              result?.isDeliveryBoyActive = fetchedData[i].isDeliveryBoyActive;
              result?.isActivated = fetchedData[i].isActivated;
              result?.isSynced = true;
              result?.intServerId = fetchedData[i].intServerId;
              // result?.isSyncOnServerProcessing = false;
              result?.isSyncOnServerProcessing = false;
              result?.isDeliveryBoyActive =fetchedData[i].isDeliveryBoyActive;
              // print("==ii=isDeliveryBoyActive===${fetchedData[i].isDeliveryBoyActive}=====${fetchedData[i].email}===serverId===${fetchedData[i].serverId}====");
              // UserDao().updateUser(result).then((value){
              //   print("==2nd=isDeliveryBoyActive===${value.isDeliveryBoyActive}=====${value.email}========");
              // });
              // MessageDao().updateMessage(result!);
            }
            // else {
            UserModel userModel = UserModel(
                fetchedData[i].id,
                fetchedData[i].name,
                fetchedData[i].phoneNumber,
                fetchedData[i].email,
                fetchedData[i].password,
                fetchedData[i].role,
                fetchedData[i].isDeliveryBoyActive,
                isActivated: fetchedData[i].isActivated,
                imagePath: fetchedData[i].imagePath,
                latitude: fetchedData[i].latitude,
                longitude: fetchedData[i].longitude,
                isSynced: true,
                isSyncOnServerProcessing: false,
                syncOnServerActionPending: "pending",
                serverId: fetchedData[i].serverId,
                intServerId: fetchedData[i].intServerId
            );

            userModel.isSynced = true;
            userModel.serverId = fetchedData[i].serverId;
            userModel.intServerId = fetchedData[i].intServerId;
            userModel.latitude = fetchedData[i].latitude;
            userModel.longitude = fetchedData[i].longitude;
            userModel.isSyncOnServerProcessing = false;
            userModel.syncOnServerActionPending = Utility().removeServerSyncActionPending(ConstantSyncOnServerPendingActions.ACTION_PENDING_UPDATE);
            UserDao().getUserByServerId(fetchedData[i].serverId).then((value){
              if(value!=null){

                UserDao().updateUser(userModel).then((value11){
                  UserDao().getUserByServerId(fetchedData[i].serverId).then((value){
                    value!.isDeliveryBoyActive = userModel.isDeliveryBoyActive;
                    UserDao().updateUser(value).then((value11) {
                      print("==2nd=isDeliveryBoyActive===${value!.isDeliveryBoyActive}=====${value.email}========");
                      print("==2nd=isDeliveryBoyActivevalue11===${value11!.isDeliveryBoyActive}=====${value11.email}========");
                      // getOrderList();
                      getIcons();

                    });
                  });

                });
              }
              else{
                UserDao().insertUser(userModel);
              }
            });
          }
          // }
        });

      }
      if(callback!=null){
        callback();
      }
    }).onError((error, stackTrace){
      if(callback!=null){
        callback();
      }
    });
  }

  bool updateMar = true;
  @override void initState() {
    //var cron = new Cron();
    //cron.schedule(new Schedule.parse('*/1 * * * * '), () async {
      //setState(() {
       // markers=Set();
        //_getUserLocation();
       // deliveryBoys=[];
       // getUserListFromServer();
      // updateMar=false;
     // });
    //});
    _getUserLocation();
    getIcons();
    getRestaurantIcons();
    getBytesFromCanvas(2, 150, 150);
    super.initState();
  }


  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBarOptifood(
        backGroundColor: Colors.transparent,
        appIconList: [
          AppIconModel(
            svgPicture: SvgPicture.asset("assets/images/delivery_boy.jpeg", height: 35, color: AppTheme.colorRed,),
            onTap: (){
              Navigator.of(context).push(MaterialPageRoute(builder: (BuildContext context) => DeliveryBoyPathOptimization()));
            },
          ),

          /*AppIconModel(
            svgPicture: SvgPicture.asset("assets/svg/icons/map/location.svg", height: 35, color: Color(0xff000000),),
            onTap: (){
              print("second");
            }
        ),*/
        ],),
      //drawer: MainNavigationDrawer(),

      /*Container(
        color: Colors.grey,
        child:   Row(
          children: [
            Flexible(
              flex:1,
              fit: FlexFit.tight,
              child: Checkbox(onChanged: null,value: false,checkColor: Colors.red,),
            ),
            Flexible(
              flex:1,
              fit: FlexFit.tight,
              child: Checkbox(onChanged: null,value: false,checkColor: Colors.red,),
            )
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(onPressed: (

          ) {
        setState(() {
          refreshMarkers();
        });
        },
        backgroundColor: Color(0xffd50823),
        child: Icon(Icons.refresh),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,*/
      body: Container(
        child:  Expanded(
            flex: 1,
            child:
            Container(
              child: Stack(
                children: [
                  createGoogleMap(),
                  Positioned(
                    top: 100,
                    left: 0,
                    child: Column(
                      children: [Wrap(
                        spacing: 40,
                        children: [
                          Flexible(
                              flex:1,
                              fit: FlexFit.tight,
                              child: Container(
                                  alignment: Alignment.center,
                                  child:
                                  Row(
                                      children:[
                                        Radio(
                                            value: "Client",
                                            activeColor: AppTheme.colorRed,
                                            groupValue: clientValue,
                                            toggleable: true,
                                            onChanged: (value){
                                              setState((){
                                                if(clientValue=="")
                                                  clientValue='Client';
                                                else
                                                  clientValue="";

                                              if(clientValue=="Client")
                                                addMarker("client");
                                              else
                                                removeMarker("client");
                                              });
                                            }),
                                          Text("client".tr().toUpperCase(), style: TextStyle(fontSize: 18),),
                                        Radio(
                                            value: "Delivery Boy",
                                            activeColor: AppTheme.colorRed,
                                            groupValue: deliveryBoyvalue,
                                            toggleable: true,
                                            onChanged: (value){
                                              setState((){
                                                if(deliveryBoyvalue=="")
                                                  deliveryBoyvalue = "Delivery Boy";
                                                else
                                                  deliveryBoyvalue="";
                                              if(deliveryBoyvalue == "Delivery Boy")
                                                addMarker("deliveryBoy");
                                              else
                                                removeMarker("deliveryBoy");
                                              });
                                            }),
                                        Text("deliveryBoy".tr(), style: TextStyle(fontSize: 18)),
                                        // RoundCheckBox(
                                        //   isChecked: isCheckClients,
                                        //   checkedColor: Color(0xff30ce00),
                                        //   onTap: (value){
                                        //     setState((){
                                        //       isCheckClients=value!;
                                        //     });
                                        //     if(value==true){
                                        //       addMarker("deliveryOrder");
                                        //     }
                                        //     else
                                        //       removeMarker("deliveryOrder");
                                        //   },
                                        //   size:24,
                                        //   checkedWidget: Container(
                                        //       padding: EdgeInsets.all(3),
                                        //       child: SvgPicture.asset("assets/images/icons/check.svg", height: 0.1, width: 0.1, )
                                        //   ),
                                        // ),
                                        // Text("Clients",style: TextStyle(color: Colors.black,fontSize: 18,fontWeight: FontWeight.bold),)
                                      ]
                                  )
                              )
                          ),
                          /*Flexible(
                              flex:1,
                              fit: FlexFit.tight,
                              child: Container(
                                  alignment: Alignment.center,
                                  child:Row(
                                      children:[
                                        Padding(
                                          padding: EdgeInsets.fromLTRB(0, 0, 0, 4),
                                          child: RoundCheckBox(
                                            isChecked: isCheckDeliveryMen,
                                            checkedColor: Color(0xff30ce00),
                                            onTap: (value){
                                              if(value==true){
                                                addMarker("deliveryBoy");
                                              }
                                              else {
                                                removeMarker("deliveryBoy");
                                                isCheckDeliveryMen=false;
                                              }

                                            },
                                            size:24,
                                            checkedWidget: Container(
                                                padding: EdgeInsets.all(3),
                                                child: SvgPicture.asset("assets/images/icons/check.svg", height: 0.1, width: 0.1, )
                                              // ),
                                            ),
                                          ),
                                        ),
                                        Text("Delivery Men",style: TextStyle(color: Colors.black,fontSize: 18,fontWeight: FontWeight.bold),)
                                      ]
                                  )
                              )
                          )*/
                        ],
                      ),
                        Container(
                          height: 50,
                          margin: EdgeInsets.only(left: 10,right: 10),
                          width: MediaQuery.of(context).size.width-20,
                          decoration: const BoxDecoration(
                            borderRadius: BorderRadius.horizontal(
                              left: Radius.circular(6),
                              right: Radius.circular(6),
                            ),
                            color: Color(0xFFffffff),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey,
                                blurRadius: 2.0,
                                spreadRadius: 1.0,
                              )
                            ],
                          ),
                          child: searchBox(),
                        ),

                      ],
                    ),
                  ),
                  if(selectedModel!=null)
                    Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        child:
                        GestureDetector(
                            onTap: (){
                            },
                            child:
                            Padding(
                              padding: EdgeInsets.fromLTRB(8.0, 8.0, 8.0, 8.0),
                              child: Container (
                                  height: 78,
                                  width: MediaQuery.of(context).size.width*0.9,
                                  decoration: new BoxDecoration (
                                      color: AppTheme.colorDarkGrey,
                                      border: Border.all(
                                        color: AppTheme.colorDarkGrey,
                                      ),
                                      borderRadius: BorderRadius.all(Radius.circular(30))
                                  ),
                                  child:
                                  Column(
                                    children: [
                                    Row(
                                      children: [
                                        Padding(
                                          padding: EdgeInsets.only(left: 12, top: 10),
                                          child: CircleAvatar(
                                            backgroundImage: !selectedModel!.isOrder?FileImage(_selectedDeliveryBoyImage):null,
                                            child:
                                            selectedModel!.isOrder?
                                            Container(
                                              width: MediaQuery.of(context).size.width*0.15,
                                              height: 30,
                                              margin: EdgeInsets.fromLTRB(0, 4, 0, 2),
                                              child:
                                              Center(
                                                child: Text("${selectedModel?.orderNumber}", textAlign: TextAlign.center,
                                                    style: TextStyle(color: Colors.white,fontSize: 18)),
                                              ),
                                              decoration: BoxDecoration(
                                                shape: BoxShape.circle,
                                                color: AppTheme.colorRed,
                                              ),)
                                                :Container(),
                                            backgroundColor: Color(0xffdb1e24),
                                            radius: 25,
                                          ),
                                        ),
                                        Container(
                                            color: AppTheme.colorDarkGrey,
                                            width: MediaQuery.of(context).size.width*0.53,
                                            padding: EdgeInsets.only(top: 9, left: 12),
                                            child:
                                            Column(
                                                children: [
                                                  Row(
                                                      children: [
                                                        !selectedModel!.isOrder?Container(
                                                          alignment: Alignment.center,
                                                          child:
                                                          Text(
                                                              "${selectedModel!.name.toUpperCase()}",
                                                              textAlign: TextAlign.start,
                                                              style: TextStyle(fontSize: 14.0, color: Colors.white)),
                                                        ):
                                                        Container(
                                                          child: Text("${selectedModel!.name.toUpperCase()}",
                                                            textAlign: TextAlign.start,
                                                            style: TextStyle(fontSize: 13.0, color: Colors.white),
                                                          ),
                                                        ),
                                                      ]),
                                                  Row(
                                                      children: [
                                                        if(selectedModel!.isOrder)
                                                          Wrap(
                                                              children: [
                                                                /*Container(
                                                                  child: Padding(
                                                                    padding: const EdgeInsets.only(right: 0),
                                                                    child: SvgPicture.asset(AppImages.clientAddressIcon,
                                                                        height: 10),
                                                                  ),),*/
                                                                Container(
                                                                    child: LimitedBox(
                                                                      maxWidth: MediaQuery.of(context).size.width*0.45,

                                                                      child: selectedModel?.adress.split(",")!.length!=0?Text("${selectedModel?.adress.substring(0,(selectedModel?.adress.split(",")[0])!.length+1)}\n"
                                                                          "${selectedModel?.adress.substring((selectedModel?.adress.split(",")[0])!.length+2,
                                                                              selectedModel?.adress.length)}"
                                                                        ,style: TextStyle(color: Colors.white,fontSize: 10),
                                                                        overflow: TextOverflow.ellipsis,
                                                                      ):Text("${selectedModel!.adress}"
                                                                        ,style: TextStyle(color: Colors.white,fontSize: 10),
                                                                        overflow: TextOverflow.ellipsis,
                                                                      )
                                                                    ))
                                                              ]),
                                                      ]),

                                                ])),
                                        Expanded(
                                          child:
                                          Container(
                                            width: MediaQuery.of(context).size.width*0.17,
                                            alignment: Alignment.centerRight,
                                            padding: EdgeInsets.only(right: 16, top: 21),
                                            child: Wrap(
                                              spacing: 8, // space between two icons
                                              children: <Widget>[
                                                if(selectedModel!.isOrder)
                                                  InkWell(
                                                    child:
                                                    Padding(
                                                        padding: EdgeInsets.fromLTRB(0, 0, 0, 9),
                                                        child: SvgPicture.asset("assets/images/icons/group-wht.svg",height: 32, color: AppTheme.colorGreen,)),
                                                    onTap: () {
                                                      Navigator.of(context).push(MaterialPageRoute(builder: (context)=>RestaurantGroupOrder(primaryOrder: getOrderModel(selectedModel!.orderNumber))));
                                                    },
                                                  ),
                                                InkWell(
                                                    onTap: () {
                                                      setState(() {
                                                        String? phoneNumber=selectedModel!.phoneNumber;
                                                        UrlLauncher.launch("tel:"+phoneNumber);
                                                      });
                                                    },
                                                    child:
                                                    Padding(padding: EdgeInsets.only(bottom: 10),child: SvgPicture.asset("assets/images/icons/phone-client.svg", height: 32,color: AppTheme.colorGreen,))),

                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
                                    )

                                  ],),
                              ),
                            )
                        )
                    )
                ],
              ),
            )
        ),
      ),

    );
  }

  GoogleMap createGoogleMap()
  {
    return GoogleMap(
      padding: EdgeInsets.fromLTRB(0,0,0,70),
      zoomGesturesEnabled: true,
      compassEnabled: true,
      scrollGesturesEnabled: true,
      zoomControlsEnabled: true,
      rotateGesturesEnabled: true,
      onLongPress: (LatLng latlng){
        setSelectedMarker(latlng);
        getDirections();
      },

      initialCameraPosition: CameraPosition(
        target: showLocation,
        zoom: 10.0,
      ),
      markers: markers,
      polylines: Set<Polyline>.of(polylines.values),
      mapType: MapType.normal,

      onMapCreated: (controller) {
        setState(() {
          mapController = controller;
        });
      },
    );
  }
  void _getUserLocation() async {
    LocationPermission locationPermission = await Geolocator.checkPermission();
    locationPermission = await Geolocator.requestPermission();
    if(locationPermission == LocationPermission.denied)
    {
      locationPermission = await Geolocator.requestPermission();
    }
    // var position = await GeolocatorPlatform.instance
    //     .getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);

    setState(() {
     // currentPostion = LatLng(position.latitude, position.longitude); commented for now
      CameraPosition cameraPosition;
      if(updateMar)
      cameraPosition = CameraPosition( //innital position in map
        target: currentPostion, //initial position
        zoom: 10.0, //initial zoom level
      );
      else
        cameraPosition = CameraPosition( //innital position in map
          target: currentPostion, //initial position
          // zoom: 10.0, //initial zoom level
        );
     var  currPosition=LatLng(position.latitude, position.longitude);
      markers.add(Marker(
        markerId: MarkerId(currPosition.toString()),
        position: currPosition,
        infoWindow: InfoWindow(
        ),
        icon: BitmapDescriptor.defaultMarker, //Icon for Marker
      ));

      mapController?.animateCamera(CameraUpdate.newCameraPosition(cameraPosition));
      getDirections();
    });
  }
  getIcons() async {
    final Uint8List markerIcon = await getBytesFromAsset(
        "assets/images/deliveryboy.png", 200);
    setState(() {
      customIcon = BitmapDescriptor.fromBytes(markerIcon);
      getUsers();
    });
    /*
    customIcon = await BitmapDescriptor.fromAssetImage(
        ImageConfiguration(size:Size(40,40)),
        "assets/images/map_icons/ic_delivery_boy.png");*/
  }


  Future<Uint8List> getBytesFromAsset(String path, int width) async {
    ByteData data = await rootBundle.load(path);
    ui.Codec codec = await ui.instantiateImageCodec(data.buffer.asUint8List(), targetWidth: width);
    ui.FrameInfo fi = await codec.getNextFrame();
    return (await fi.image.toByteData(format: ui.ImageByteFormat.png))!.buffer.asUint8List();
  }

  getDirections() async {
    List<LatLng> polylineCoordinates = [];
    PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
      googleAPiKey,
      //PointLatLng(currentPostion.latitude, currentPostion.longitude),
      //PointLatLng(endPostion.latitude, endPostion.longitude),
      PointLatLng(31.2175, 76.1407),
      PointLatLng(31.1918, 76.2588),
      travelMode: TravelMode.driving,
    );

    if (result.points.isNotEmpty) {
      print("result not empty");
      result.points.forEach((PointLatLng point) {
        polylineCoordinates.add(LatLng(point.latitude, point.longitude));
      });
    } else {
      print("result empty");
      print(result.errorMessage);
    }
    addPolyLine(polylineCoordinates);
  }

  addPolyLine(List<LatLng> polylineCoordinates) {
    PolylineId id = PolylineId("poly");
    Polyline polyline = Polyline(
      polylineId: id,
      color: Colors.deepPurpleAccent,
      points: polylineCoordinates,
      width: 8,
    );
    polylines[id] = polyline;
    setState(() {});
  }

  Widget searchBox()
  {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Material(
        color: Colors.white,
        elevation: 4,
        child: Builder(
          builder: (context) {
            /*if (filteredSearchHistory.isEmpty &&
                controller.query.isEmpty) {*/
            return Container(
              height: 56,
              width: double.infinity,
              alignment: Alignment.center,
              child:
              autocopleteField(),
              /*TextField(
                  decoration: new InputDecoration(
                      hintText: 'Location...',
                      suffixIcon: Icon(Icons.close),
                      prefixIcon: InkWell(child: Icon(Icons.search),
                      onTap: ((){
                        searchTextController.text="";
                      }),),
                      border: InputBorder.none
                  ),

                ),*/
            );
            //}
          },
        ),
      ),
    );
  }

  Widget autocopleteField(){
    return SimpleAutoCompleteTextField(
      controller: searchTextController,
      onFocusChanged: (value){
        if(searchTextController.text.isEmpty && value) {
          setState(() {
            this.selectedModel=null;
          });
        }
      },
      key: key,
      suggestions: suggestionList,
      textSubmitted: (value) {
        setState(() {
          setSelectedModel(value);
        });
      },
      decoration: InputDecoration(
          hintText: 'location'.tr()+'...',
          suffixIcon:
          InkWell(
            child: Icon(Icons.close),
            onTap: () {
              setState(() {
                this.selectedModel=null;
                searchTextController.text="";
                CameraPosition cameraPosition = CameraPosition(
                  target: currentPostion,
                  zoom: 10.0,
                );
                mapController?.animateCamera(CameraUpdate.newCameraPosition(cameraPosition));
              });
            },
          ),
          prefixIcon:
          InkWell(child: Icon(Icons.search),
            onTap: (){
            },
          ),
          border: InputBorder.none
      ),
    );
  }


  Future<Uint8List> getBytesFromCanvas(int customNum, int width, int height) async  {
    final ui.PictureRecorder pictureRecorder = ui.PictureRecorder();
    final Canvas canvas = Canvas(pictureRecorder);
    final Paint paint = Paint()..color = Color(0xffdb1e24);
    final Radius radius = Radius.circular(width/2);
    canvas.drawRRect(
        RRect.fromRectAndCorners(
          Rect.fromLTWH(0.0, 0.0, width.toDouble(),  height.toDouble()),
          topLeft: radius,
          topRight: radius,
          bottomLeft: radius,
          bottomRight: radius,
        ),
        paint);

    TextPainter painter = TextPainter(textDirection: ui.TextDirection.ltr);
    painter.text = TextSpan(
      text: customNum.toString(), // your custom number here
      style: TextStyle(fontSize: 65.0, color: Colors.white),
    );

    painter.layout();
    painter.paint(
        canvas,
        Offset((width * 0.5) - painter.width * 0.5,
            (height * .5) - painter.height * 0.5));
    final img = await pictureRecorder.endRecording().toImage(width, height);
    final data = await img.toByteData(format: ui.ImageByteFormat.png);
    markerIcon =data!.buffer.asUint8List();
    return data!.buffer.asUint8List();
  }
  late Future<List<OrderModel>> orderList;
  Future<List<OrderModel>> getOrderList() async {
    orders=[];
    setState(() {
      orderList = OrderDao().getAllOrders();
      orderList.then((value){
        orders=value;
        for(int i=0; i<value.length; i++) {
          if (value[i].customer != null) {
            String? name = "${value[i].customer?.lastName}";
            suggestionList.add("${value[i].customer?.lastName}");
            if(i==0){
              endPostion = LatLng(value[i].customer!.getDefaultAddress().lat, value[i].customer!.getDefaultAddress().lon);
            }
            deliveryBoys.add(
                DeliveryBoys(id: value[i].id,
                    name: "${value[i].customer?.lastName}, ${value[i].customer?.firstName}",
                    latitude: value[i].customer!.getDefaultAddress().lat,
                    longitude: value[i].customer!.getDefaultAddress().lon,
                    imagePath: "",
                    phoneNumber: value[i].customer!.phoneNumber,
                    adress: value[i].customer!.getDefaultAddress().address,
                    isOrder: true,
                    orderNumber: value[i].orderNumber,
                   email: value[i].customer?.email
                )
            );
          }
          setState(() {
            initializeMarkers();
          });
        } });
    });
    // updateMarker();
    return orderList;
  }

  List<UserModel> users = [];
  void getUsers() async {
    Future<List<UserModel>> userModelList = UserDao().getAllUsers("user_role_delivery_boy");
    // var id = optifoodSharedPrefrence.getString("id");
    userModelList.then((value){
      setState((){
        users= value;
        double a=0.0;
        double b=0.0;
        deliveryBoys=[];
        suggestionList=[];
        for(int i=0; i<value.length; i++){
          if(value[i].isDeliveryBoyActive) {
            print("==ginside ifoogle mappp2nd11=isDeliveryBoyActive===${value[i]!.isDeliveryBoyActive}=====${value[i]!.email}========");

            suggestionList.add(value[i].name);
            //set delivery boy
            deliveryBoys.add(
                DeliveryBoys(id: value[i].id,
                    name: value[i].name,
                    latitude: value[i].latitude == 0.0 ? 48.7275277 : value[i]
                        .latitude,
                    longitude: value[i].longitude == 0.0 ? 3.1057483 : value[i]
                        .longitude,
                    imagePath: value[i].imagePath == "" ||
                        value[i].imagePath == null ? "" : value[i].imagePath!,
                    phoneNumber: value[i].phoneNumber,
                    adress: "",
                    isOrder: false,
                    orderNumber: 0,
                email: value[i].email)
            );
          }
        }
        setState(() {
          initializeMarkers();
          // initializeDeliveryBoyMarkers();
        });

      });
      getOrderList();

    });
  }

  void initializeMarkers() async{
    for(int i=0; i<deliveryBoys.length; i++){
      LatLng position = LatLng(deliveryBoys[i].latitude, deliveryBoys[i].longitude);
      markerIcon=await getBytesFromCanvas(deliveryBoys[i].orderNumber, 150, 150);
      setState((){
        markers.add(Marker(

            // onTap: deliveryBoys[i].isOrder?() {
            //   showDialog(context: context, builder: (BuildContext
            //   ConfirmationPopupcontext) {
            //     return ClientInfoGoogleMap(
            //       order:deliveryBoys[i]
            //     );
            //   });
            //   print("=====================${deliveryBoys[i].id}===========000000000000000000000000br======================================");
            // }:(){
            //
            // },
          markerId: MarkerId(position.toString()),
          consumeTapEvents: false,
          position: position,
          infoWindow: InfoWindow(
          ),
          icon: deliveryBoys[i].isOrder?BitmapDescriptor.fromBytes(markerIcon):customIcon,
        ));
      });

    }
    setState((){
      getRestaurantIcons();

    });

  }
  void initializeDeliveryBoyMarkers(){
    setState((){
      for(int i=0; i<deliveryBoys.length; i++){
        LatLng position = LatLng(deliveryBoys[i].latitude, deliveryBoys[i].longitude);
        markers.add(Marker(
          markerId: MarkerId(users[i].id.toString()),
          consumeTapEvents: false,
          position: position,
          infoWindow: InfoWindow(
          ),
          icon: customIcon,
        ));
      }
    });


  }


  setSelectedModel(String name){
    selectedModel=deliveryBoys.firstWhere((element) => element.name==name);
    LatLng position = LatLng(selectedModel!.latitude, selectedModel!.longitude);
    setState(() {
      selectedModel=selectedModel;
      if(selectedModel!.isOrder){
        latIndex = selectedModel!.adress.lastIndexOf(',');
        addresLength=selectedModel!.adress.length;
      }
      if(!selectedModel!.isOrder)
        _selectedDeliveryBoyImage = File(selectedModel!.imagePath!);
      showLocation=position;
      currentPostion=position;
      CameraPosition cameraPosition = CameraPosition(
        target: currentPostion,
        zoom: 17.0,
      );
      mapController?.animateCamera(CameraUpdate.newCameraPosition(cameraPosition)); //the zoom you want
      getDirections();
    });


  }

  setSelectedMarker(LatLng latLng){
    DeliveryBoys deliveryBoy=getNearestDeliveryBoyLocation(latLng);
    LatLng position = LatLng(deliveryBoy.latitude, deliveryBoy.longitude);
    setState(() {
      this.selectedModel=deliveryBoy;
      if(!selectedModel!.isOrder)
        _selectedDeliveryBoyImage = File(selectedModel!.imagePath!);
      showLocation = LatLng(deliveryBoy.latitude, deliveryBoy.longitude);
      currentPostion = LatLng(deliveryBoy.latitude, deliveryBoy.longitude);

      CameraPosition cameraPosition = CameraPosition(
        target: currentPostion,
        zoom: 17.0,
      );
      mapController?.animateCamera(
          CameraUpdate.newCameraPosition(
              cameraPosition));
      getDirections();
    });
    if(orderModel!=null && userModel!=null) {
      getPolyline();

    }
  }

  DeliveryBoys getNearestDeliveryBoyLocation(LatLng latLng){
    DeliveryBoys nearestDeliveryBoy=deliveryBoys[0];
    double distance=0, minDistance=double.infinity;
    for(int i=0; i<deliveryBoys.length; i++){
      var p = 0.017453292519943295;
      var a = 0.5 - cos((deliveryBoys[i].latitude - latLng.latitude) * p)/2 +
          cos(latLng.latitude * p) * cos(deliveryBoys[i].latitude * p) *
              (1 - cos((deliveryBoys[i].longitude - latLng.longitude) * p))/2;
      distance= 12742 * asin(sqrt(a));
      if(distance<minDistance) {
        minDistance = distance;
        nearestDeliveryBoy=deliveryBoys[i];
      }
    }
    return nearestDeliveryBoy;
  }

  removeMarker(String type) {
    if (type == "deliveryBoy") {
      Iterable<DeliveryBoys> deilveryBoy = deliveryBoys.where((element) =>
      element.isOrder == false);
      deilveryBoy.forEach((element) {
        LatLng position = LatLng(element.latitude, element.longitude);
        setState(() {
          markers.removeWhere((element) =>
          element.markerId.value == position.toString());
        });
      });
    }

    if (type == "client") {
      Iterable<DeliveryBoys> deilveryBoy = deliveryBoys.where((element) =>
      element.isOrder == true);
      deilveryBoy.forEach((element) {
        LatLng position = LatLng(element.latitude, element.longitude);
        setState(() {
          markers.removeWhere((element) =>
          element.markerId.value == position.toString());
        });
      });
    }
  }

  addMarker(String type) async{
    if(type=="deliveryBoy"){
        for(int i=0; i<deliveryBoys.length; i++) {
          if (deliveryBoys[i].isOrder == false) {
            LatLng position = LatLng(
                deliveryBoys[i].latitude, deliveryBoys[i].longitude);
            setState(() {
              markers.add(Marker(
                markerId: MarkerId(position.toString()),
                consumeTapEvents: false,
                position: position,
                infoWindow: InfoWindow(
                ),
                icon: customIcon,
              ));
            });
          }
        }
    }

    if(type=="client"){
      for(int i=0; i<deliveryBoys.length; i++) {
        if (deliveryBoys[i].isOrder == true) {
          LatLng position = LatLng(
              deliveryBoys[i].latitude, deliveryBoys[i].longitude);
          markerIcon =
          await getBytesFromCanvas(deliveryBoys[i].orderNumber, 150, 150);
          setState(() {
            markers.add(Marker(
              markerId: MarkerId(position.toString()),
              consumeTapEvents: false,
              position: position,
              infoWindow: InfoWindow(
              ),
              icon: BitmapDescriptor.fromBytes(markerIcon)
            ));
          });
        }
      }
    }
  }

  void getPolyline() async {
    LatLng source=LatLng(deliveryBoys.firstWhere((element) => element.id==userModel?.id).latitude,
        deliveryBoys.firstWhere((element) => element.id==userModel?.id).longitude);
    String? lat=orderModel?.deliveryInfoModel!.lat;
    String? long=orderModel?.deliveryInfoModel!.lat;
    LatLng destination=LatLng(double.parse(lat!),double.parse(long!));
    List<LatLng> polylineCoordinates = [];
    PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
      googleAPiKey,
      PointLatLng(source.latitude, source.longitude),
      PointLatLng(destination.latitude, destination.longitude),
      travelMode: TravelMode.driving,
    );
    if (result.points.isNotEmpty) {
      result.points.forEach((PointLatLng point) {
        polylineCoordinates.add(LatLng(point.latitude, point.longitude));
      });
    }
    else {
      print(result.errorMessage);
    }
    addPolyLine(polylineCoordinates);
    setState(() {});

  }

  OrderModel getOrderModel(int orderNumber){
    OrderModel order=orders.firstWhere((element) => element.orderNumber==orderNumber);
    return order;
  }

  Uint8List? resizeImage(Uint8List data, width, height) {
    Uint8List? resizedData = data;
    IMG.Image? img = IMG.decodeImage(data);
    IMG.Image resized = IMG.copyResize(img!, width: width, height: height);
    resizedData = Uint8List.fromList(IMG.encodePng(resized));
    return resizedData;
  }
  getRestaurantInfo(){
    RestaurantInfoDao().getRestaurantInfo().then((value) async{
      if (value!=null) {
        setState(() async {
          currentPostion = LatLng(value.lat, value.lon);
          Uint8List icon;
          if (value.imagePath != null) {
          // getMappps();
          final imageName = path.basename(value.imagePath.toString());
          restaurantImage =
              ServerData.OPTIFOOD_IMAGES + "/restaurant/" + imageName;
           icon = (await NetworkAssetBundle(Uri.parse(restaurantImage))
              .load(restaurantImage))
              .buffer
              .asUint8List();
          icon = resizeImage(icon, 100, 100)!;
        }
          else{
            icon = await getBytesFromAsset(AppImages.restaurantIcon, 130);
          }
        CameraPosition cameraPosition;
          if(updateMar)
          cameraPosition = CameraPosition(
          target: currentPostion,
          zoom: 5.0,
        );
          else
            cameraPosition = CameraPosition(
              target: currentPostion,
            );
        restaurantIcon = BitmapDescriptor.fromBytes(icon);
        markers.add(Marker(
          markerId: MarkerId(currentPostion.toString()),
          position: currentPostion,
          infoWindow: InfoWindow(
          ),
          icon: restaurantIcon//Icon for Marker
        ));
        mapController?.animateCamera(
            CameraUpdate.newCameraPosition(cameraPosition));
        getDirections();
        restaurantInfo = value;
      });
      }
      else
        _getUserLocation();
      getOrderList();
    });
  }

  getRestaurantIcons() async {
    setState(() async {
    final Uint8List icon = await getBytesFromAsset(
        AppImages.restaurantIcon, 130);
      restaurantIcon = BitmapDescriptor.fromBytes(icon);
    getRestaurantInfo();
    });
  }

  Future<BitmapDescriptor?> getRestaurantIcon() async {
    setState(() async {
      final Uint8List icon = await getBytesFromAsset(
          restaurantImage, 130);
      restaurantIcon = BitmapDescriptor.fromBytes(icon);
      getRestaurantInfo();
    });
    restaurantIcon!;
  }

getAddress(){

}
}