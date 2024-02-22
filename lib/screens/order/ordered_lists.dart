import 'dart:async';
import 'dart:convert';
import 'package:cron/cron.dart';
import 'package:fbroadcast/fbroadcast.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:opti_food_app/api/food_item_api.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:opti_food_app/database/order_dao.dart';
import 'package:opti_food_app/utils/constants.dart';
import 'package:opti_food_app/utils/utility.dart';
import 'package:opti_food_app/widgets/appbar/navigation_bar_optifood.dart';
import 'package:opti_food_app/widgets/popup/confirmation_popup/confirmation_popup.dart';
import 'package:opti_food_app/widgets/popup/input_popup/input_popup.dart';
import 'package:stomp_dart_client/stomp.dart';
import 'package:stomp_dart_client/stomp_config.dart';
import 'package:stomp_dart_client/stomp_frame.dart';
import '../../api/all_data_api.dart';
import '../../api/message_api.dart';
import '../../assets/images.dart';
import '../../data_models/order_model.dart';
import '../../data_models/service_activation_model.dart';
import '../../database/restaurant_info_dao.dart';
import '../../database/service_activation_dao.dart';
import '../../main.dart';
import '../../widgets/app_theme.dart';
import '../contact/contact_list.dart';
import 'common_file_order_list.dart';
import 'order_taking_window.dart';import '../MountedState.dart';
class OrderedList extends StatefulWidget {
  //final String id;
  //final String isEatIn;
  //final String isTakeAway;
  final int tabIndex = 0;
  OrderedList( {Key? key}) : super(key: key);
  @override
  State<OrderedList> createState() => _OrderedListState();
}

class _OrderedListState extends MountedState<OrderedList> with SingleTickerProviderStateMixin{
  List<OrderModel> deliveryOrder=[];
  List<OrderModel> restaurantOrder=[];

  //late DatabaseReference databaseReference;
  var _refreshIndicator = GlobalKey<RefreshIndicatorState>();
  late TabController _tabController=TabController(initialIndex: _selectedIndex, length: 2, vsync: this);
  bool _swipeIsInProgress = false;
  bool _tapIsBeingExecuted = false;
  int _selectedIndex = 0;
  int _prevIndex = 1;
  bool isToEat = true;
  bool isToTakeAway = true;
  int orderId=0;
  ServiceActivationModel serviceActivationModel=ServiceActivationModel(1, true, true, true, true, false);
  int orderNumber=-1;
  List<OrderModel> orderList = [];
  Future<List<OrderModel>> getOrderList() async {
    /*setState(() async {
    orderList =  await OrderDao().getAllOrders();
    });*/
    OrderDao().getAllOrders().then((value){
      setState((){
        orderList = value;
      });
    });

    return orderList;
  }
  initializeTab(){
    _selectedIndex=widget.tabIndex;
    _tabController = TabController(initialIndex: _selectedIndex, length: 2, vsync: this);
    _tabController.animation?.addListener(() {
      if (!_tapIsBeingExecuted &&
          !_swipeIsInProgress &&
          (_tabController.offset >= 0.5 || _tabController.offset <= -0.5)) {
        int newIndex = _tabController.offset > 0 ? _tabController.index + 1 : _tabController.index - 1;
        _swipeIsInProgress = true;
        _prevIndex = _selectedIndex;
        setState(() {
          _selectedIndex = newIndex;
        });
      } else {
        if (!_tapIsBeingExecuted &&
            _swipeIsInProgress &&
            ((_tabController.offset < 0.5 && _tabController.offset > 0) ||
                (_tabController.offset > -0.5 && _tabController.offset < 0))) {
          _swipeIsInProgress = false;
          setState(() {
            _selectedIndex = _prevIndex;
          });
        }
      }
    });
    _tabController.addListener(() {
      _swipeIsInProgress = false;
      setState(() {
        _selectedIndex = _tabController.index;
      });
      if (_tapIsBeingExecuted == true) {
        _tapIsBeingExecuted = false;
      } else {
        if (_tabController.indexIsChanging) {
          _tapIsBeingExecuted = true;
        }
      }
    });
  }
  Future<void> scheduleCall() async {
    var cron = new Cron();
    RestaurantInfoDao().getRestaurantInfo().then((value){

      if(value!=null&&value.startTime != null&&value.startTime!='') {
        /*optifoodSharedPrefrence.setString("hour", value.startTime.substring(0, 2));
        optifoodSharedPrefrence.setString("minute", value.startTime.substring(3, 5));
        var cron = new Cron();
        cron.schedule(new Schedule.parse('${optifoodSharedPrefrence.getString("minute")} ${optifoodSharedPrefrence.getString("hour")} * * *'), () async {
          setState(() {
            FoodItemApi.resetDailyQuantityConsumed();
          });
        });*/
      }

    });

  }
  @override
  void initState(){
    //databaseReference = FirebaseDatabase.instance.ref("notification");

    /*databaseReference.onValue.listen((event) {
      print(event.snapshot.value.toString()+"==================================================================");
      print(optifoodSharedPrefrence.getString(ConstantSharedPreferenceKeys.KEY_FIREBASE_TIMESTAMP));
      if(optifoodSharedPrefrence.getString(ConstantSharedPreferenceKeys.KEY_FIREBASE_TIMESTAMP)==null||
          optifoodSharedPrefrence.getString(ConstantSharedPreferenceKeys.KEY_FIREBASE_TIMESTAMP)!=
              event.snapshot.value.toString()){
        print("===========colling...........................");
        optifoodSharedPrefrence.setString(ConstantSharedPreferenceKeys.KEY_FIREBASE_TIMESTAMP, event.snapshot.value.toString());
        AllDataApis.getAllDataFromServer();

      }
      else{
        print("Not calling api");
      }
    });*/

    FBroadcast.instance().register(ConstantBroadcastKeys.KEY_ORDER_SENT, (value, callback) async {
      getOrderList();
      //await getOrderList();
     /* setState((){

      });*/
    });
    var cron = new Cron();
    RestaurantInfoDao().getRestaurantInfo().then((value) {
      var cron = new Cron();
      if (value!=null&&value.startTime != null&&value.startTime!=''){
       /* String hour = value.startTime.substring(0, 2);
        String minutes = value.startTime.substring(3, 5);

        cron.schedule(new Schedule.parse('$minutes $hour * * *'), () async {
          setState(() {
            FoodItemApi.resetDailyQuantityConsumed();
          });
        });*/
      }
    });
    Future<List<ServiceActivationModel>> serviceActivationList = ServiceActivationDao().getAllServiceActivation();
    serviceActivationList.then((value) async{
      if(value!=null&&value.length>0){
        setState(() async {
          value.last.tableManagement=false;
          await ServiceActivationDao().updateServiceActivation(value.last!);
          // widget.serviceActivationModel = value[0];
        });
      }
      else {
        setState(() async{
          await ServiceActivationDao()
              .insertServiceActivation(ServiceActivationModel(1, true, true, false, true, true));
        });

      }
    });


    scheduleCall();
    /*stompClient = StompClient(
      config: StompConfig.SockJS(
        url: socketUrl,
        onConnect: onConnect,
        beforeConnect: () async {
          await Future.delayed(Duration(milliseconds: 200));
        },
        onWebSocketError: (dynamic error) => print(error.toString()),
        stompConnectHeaders: {'Authorization': 'Bearer yourToken'},
        webSocketConnectHeaders: {'Authorization': 'Bearer yourToken'},
      ),
    );
    stompClient.activate();*/
    getOrderList();
    initializeTab();
    getAllServiceActivation();
    super.initState();

  }

  @override
  void dispose() {
    super.dispose();
    _tabController.dispose();
  }


  @override
  Widget build(BuildContext context) {
    final isLandscape = MediaQuery.of(context).orientation == Orientation.landscape;
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: NavigationBarOptifood(onRefrontCallback: (){
          getAllServiceActivation();
          setState(() {
            getOrderList();
          });
        }),
        body:
        TabBarView(
          controller: _tabController,
          children: [
            SafeArea(
                child: CommonFileOrderList(ConstantOrderType.ORDER_TYPE_RESTAURANT,
                    Utility().getAttachedSortedOrderList(
                    //snapshot.data!.where((element) => element.orderType == ConstantOrderType.ORDER_TYPE_RESTAURANT).toList(),
                    orderList.where((element) => element.orderType ==
                        ConstantOrderType.ORDER_TYPE_RESTAURANT).toList(),
                    orderNumber, 'restaurant'),
                    _selectedIndex,() {
                      getOrderList();
                      setState(() {
                      });
                    }, deliveryOrder: deliveryOrder, restaurantOrder: restaurantOrder)
            ),
            SafeArea(
                child: CommonFileOrderList(ConstantOrderType.ORDER_TYPE_DELIVERY,
                  Utility().getAttachedSortedOrderList(
                    //snapshot.data!.where((element) => element.orderType == ConstantOrderType.ORDER_TYPE_DELIVERY).toList(),
                    orderList.where((element) => element.orderType ==
                        ConstantOrderType.ORDER_TYPE_DELIVERY).toList(),
                    orderNumber, 'delivery'),
                  _selectedIndex,(){
                    setState(() {
                      getOrderList();
                    });
                  },deliveryOrder: deliveryOrder, restaurantOrder: restaurantOrder,)),
          ],
        ),
        floatingActionButton: Padding(
          padding: const EdgeInsets.only(top: 40),
          child: SizedBox(
            height: 65.0,
            width: 65.0,
            child: FittedBox(
              child: FloatingActionButton(
                backgroundColor: AppTheme.colorRed,
                child: SvgPicture.asset(AppImages.addWhiteIcon, height: 30,),
                onPressed: () async {
                  if (_selectedIndex == 0 && serviceActivationModel.eatInMode==true && serviceActivationModel.takeawayMode==true) {
                    showDialog(context: context, builder: (BuildContext
                    ConfirmationPopupcontext) {
                      return ConfirmationPopup(
                        title: "service",
                        subTitle: "eatInOrToTakeAway",
                        titleImagePath: AppImages.phoneWithHandIcon,
                        titleImageBackgroundColor: AppTheme.colorRed,
                        positiveButtonText: "eatIn",
                        negativeButtonText: "takeAway",
                        positiveButtonPressed: () async {
                          orderNumber=-1;
                          if(serviceActivationModel.tableManagement==true)
                            showDialog(context: context, builder: (BuildContext InputPopupContext)
                            {
                              return InputPopup(
                                title: "table".tr(),
                                inputBoxHint: "enterTableNumber:",
                                titleImagePath: AppImages.dinnerTableIcon,
                                positiveButtonText: "add",
                                negativeButtonText: "cancel",
                                inputBoxMinLines: 1,
                                inputBoxMaxLines: 1,
                                textInputType: TextInputType.number,
                                titleImageBackgroundColor: AppTheme.colorRed,
                                positiveButtonPressed: (Map popupResult) async {
                                  orderNumber=-1;
                                  String tableNo = await popupResult[InputPopup.components.INPUT_TEXT];
                                  Map results =  await Navigator.of(context).push(MaterialPageRoute(builder: (context)=>OrderTakingWindow(
                                      ConstantOrderType.ORDER_TYPE_RESTAURANT,
                                      ConstantRestaurantOrderType.RESTAURANT_ORDER_TYPE_EAT_IN,
                                      tableNumber: tableNo
                                  )
                                  ));
                                  setState(() {
                                    getOrderList();
                                  });
                                },
                              );
                            });

                          else {
                            Map results = await Navigator.of(context).push(
                                MaterialPageRoute(builder: (context) =>
                                    OrderTakingWindow(
                                        ConstantOrderType
                                            .ORDER_TYPE_RESTAURANT,
                                        ConstantRestaurantOrderType
                                            .RESTAURANT_ORDER_TYPE_EAT_IN
                                    )
                                ));
                          }
                          setState(() {
                            getOrderList();
                          });
                        },
                        negativeButtonPressed: () async {
                          orderNumber=-1;
                          //Map results = await Navigator.of(context).push(MaterialPageRoute(builder: (context)=>OrderTakingWindow(ConstantOrderType.ORDER_TYPE_RESTAURANT,
                          await Navigator.of(context).push(MaterialPageRoute(builder: (context)=>OrderTakingWindow(ConstantOrderType.ORDER_TYPE_RESTAURANT,
                            ConstantRestaurantOrderType.RESTAURANT_ORDER_TYPE_TAKEAWAY,

                          )));
                          setState(() {
                            getOrderList();
                          });
                        },
                      );
                    });
                  }
                  else if(_selectedIndex == 0 && serviceActivationModel.takeawayMode==true && serviceActivationModel.eatInMode==false){
                    orderNumber=-1;
                    await Navigator.of(context).push(MaterialPageRoute(builder: (context)=>
                        OrderTakingWindow(ConstantOrderType.ORDER_TYPE_RESTAURANT,
                        ConstantRestaurantOrderType.RESTAURANT_ORDER_TYPE_TAKEAWAY
                    )));
                    setState(() {
                      getOrderList();
                    });
                  }
                  else if(_selectedIndex == 0 && serviceActivationModel.takeawayMode==false && serviceActivationModel.eatInMode==true) {
                    if(serviceActivationModel.tableManagement==true)
                      showDialog(context: context, builder: (BuildContext InputPopupContext)
                      {
                        orderNumber=-1;
                        return InputPopup(
                          title: "table",
                          inputBoxHint: "enterTableNumber:",
                          titleImagePath: AppImages.dinnerTableIcon,
                          positiveButtonText: "add",
                          negativeButtonText: "cancel",
                          inputBoxMinLines: 1,
                          inputBoxMaxLines: 1,
                          textInputType: TextInputType.number,
                          titleImageBackgroundColor: AppTheme.colorRed,
                          positiveButtonPressed: (Map popupResult) async {
                            orderNumber=-1;
                            String tableNo = await popupResult[InputPopup.components.INPUT_TEXT];
                            Map results =  await Navigator.of(context).push(MaterialPageRoute(builder: (context)=>OrderTakingWindow(
                                ConstantOrderType.ORDER_TYPE_RESTAURANT,
                                ConstantRestaurantOrderType.RESTAURANT_ORDER_TYPE_EAT_IN,
                                tableNumber: tableNo
                            )
                            ));
                            setState(() {
                              getOrderList();
                            });
                          },
                        );
                      });
                    else {
                      orderNumber=-1;
                      Map results = await Navigator.of(context).push(
                          MaterialPageRoute(builder: (context) =>
                              OrderTakingWindow(
                                  ConstantOrderType.ORDER_TYPE_RESTAURANT,
                                  ConstantRestaurantOrderType
                                      .RESTAURANT_ORDER_TYPE_EAT_IN
                              )
                          ));
                      setState(() {
                        getOrderList();
                      });
                    }
                  }
                  else {
                    orderNumber=-1;
                    await Navigator.of(context).push(MaterialPageRoute(builder:
                        (context) => ContactList(
                        isFromOrder:true
                    )));

                    setState(() {
                      getOrderList();
                    });
                  }
                },
              ),
            ),
          ),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation
            .centerDocked,
        bottomNavigationBar: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: AppTheme.colorMediumGrey.withOpacity(0.9),
                spreadRadius: 0.1,
                blurRadius: 4,
                offset: Offset(0, 1), // changes position of shadow
              ),
            ],
          ),
          height: 70,
          child: TabBar(
            controller: _tabController,
            onTap: (index) {
              setState((){
                if(serviceActivationModel.deliveryMode==false)
                  _tabController.index=index == 1? _tabController.previousIndex : index;
                if(serviceActivationModel.takeawayMode==false && serviceActivationModel.eatInMode==false)
                  _tabController.index=index == 0? _tabController.previousIndex : index;
              });

            },
            labelColor: AppTheme.colorRed,
            unselectedLabelColor: Colors.black,
            indicatorSize: TabBarIndicatorSize.tab,
            indicatorColor: (serviceActivationModel.eatInMode==true || serviceActivationModel.takeawayMode==true) &&
                serviceActivationModel.deliveryMode==true?Colors.red:Colors.white,
            indicatorWeight: 2,
            indicator:  UnderlineTabIndicator(
              borderSide: (serviceActivationModel!.eatInMode==true || serviceActivationModel!.takeawayMode==true) &&
                  serviceActivationModel!.deliveryMode==true?BorderSide(color: AppTheme.colorRed, width: 4.0):BorderSide(color: Colors.white, width: 4.0),
              insets: EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 67.0),
            ),
            automaticIndicatorColorAdjustment: false,
            tabs: [
              Tab(
                child: ListView(
                  children: <Widget>[
                    if((serviceActivationModel.eatInMode==true || serviceActivationModel.takeawayMode==true) &&
                        serviceActivationModel.deliveryMode==true)
                      SvgPicture.asset(AppImages.phoneWithHandIcon,
                        height: 30,
                        color: (_selectedIndex) == 0
                            ? AppTheme.colorRed
                            : AppTheme.colorMediumGrey,),
                    if(serviceActivationModel.deliveryMode==true && (serviceActivationModel.eatInMode==true || serviceActivationModel.takeawayMode==true))
                      Text("restaurant", textAlign: TextAlign.center,
                        style: TextStyle(color: (_selectedIndex) == 1 ? AppTheme
                            .colorMediumGrey : AppTheme.colorRed),).tr(),
                  ],
                ),
              ),
              Tab(
                child: ListView(
                  children: <Widget>[
                    if((serviceActivationModel.eatInMode==true || serviceActivationModel.takeawayMode==true) &&
                        serviceActivationModel.deliveryMode==true)
                      SvgPicture.asset(AppImages.scooterIcon, height: 30,
                        color: _selectedIndex == 1
                            ? AppTheme.colorRed
                            : AppTheme.colorMediumGrey,),
                    if(serviceActivationModel.deliveryMode==true && (serviceActivationModel.eatInMode==true || serviceActivationModel.takeawayMode==true))
                      Text("delivery", textAlign: TextAlign.center,
                        style: TextStyle(color: _selectedIndex == 1
                            ? AppTheme.colorRed
                            : AppTheme.colorMediumGrey),).tr(),
                  ],
                ),
              ),

            ],
          ),
        ),

      ),
    );
  }
  getAllServiceActivation() async{
    Future<List<ServiceActivationModel>> serviceActivationList = ServiceActivationDao().getAllServiceActivation();
    serviceActivationList.then((value) async{
      setState((){
        if(value.length>0){
          serviceActivationModel = value[0];
          setState((){
            _tabController.index =serviceActivationModel.eatInMode==false && serviceActivationModel.takeawayMode==false
                ? 1: 0;
            _selectedIndex=serviceActivationModel.eatInMode==false && serviceActivationModel.takeawayMode==false
                ? 1: 0;
          });
        }
      });

    });
  }

/*void onConnect(StompClient client, StompFrame frame) {
    client.subscribe(
        destination: '/topic/order',
        callback: (StompFrame frame) {
          if (frame.body != null) {
            print("Push notification called on order listsssssssssssssssssssssssss");
            AllDataApis.getAllDataFromServer();
          }
        });
  }*/



}