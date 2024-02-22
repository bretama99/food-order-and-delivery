import 'dart:ffi';

import 'package:dio/dio.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:opti_food_app/data_models/food_items_model.dart';
import 'package:opti_food_app/data_models/user_model.dart';
import 'package:opti_food_app/database/food_items_dao.dart';
import 'package:opti_food_app/database/user_dao.dart';
import 'package:opti_food_app/screens/report/payment_report.dart';
import 'package:opti_food_app/screens/report/user_orders_report.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../assets/images.dart';
import '../../data_models/food_category_model.dart';
import '../../data_models/order_model.dart';
import '../../database/food_category_dao.dart';
import '../../database/order_dao.dart';
import '../../main.dart';
import '../../utils/app_config.dart';
import '../../utils/constants.dart';
import '../../utils/utility.dart';
import '../../widgets/app_theme.dart';
import '../../widgets/appbar/app_bar_optifood.dart';
import '../../widgets/datetime_form_field.dart';
import '../../widgets/popup/filter_popup/filter_popup.dart';
import '../products/food_category_list.dart';
import 'category_report.dart';
import 'common_interval.dart';
import 'interval_report.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import '../MountedState.dart';
class SearchForm extends StatefulWidget {
  const SearchForm({Key? key}) : super(key: key);

  @override
  State<SearchForm> createState() => _SearchFormState();
}

class _SearchFormState extends MountedState<SearchForm> with TickerProviderStateMixin {
  final GlobalKey<FormState> _globalKey = GlobalKey<FormState>();
  TextEditingController dateTimeEndController = TextEditingController();
  TextEditingController dateTimeStartController = TextEditingController();
  late final TextEditingController _startDateTimeController =
      TextEditingController();
  late final TextEditingController _endDateTimeController =
      TextEditingController();
  late String selectedDateFormat;
  late String groupTimeFormat;
  late SharedPreferences sharedPreferences;
  Utility utility = Utility();
  var selectedLanguage = optifoodSharedPrefrence
              .getString(ConstantSharedPreferenceKeys.KEY_SELECTED_LANGUAGE) !=
          null
      ? optifoodSharedPrefrence
          .getString(ConstantSharedPreferenceKeys.KEY_SELECTED_LANGUAGE)!
      : ConstantSharedPreferenceKeys.KEY_SELECTED_LANGUAGE;

  bool isLeftCollapsed = true;
  bool isRightCollapsed = true;
  bool isTopCollapsed = true;
  bool isBottomCollapsed = true;
  late double screenWidth, screenHeight;
  final Duration duration = const Duration(milliseconds: 400);
  late AnimationController _controller;
  int _selectedIndex = 0;
  late bool isFormToDisplay = true;

  late TabController _tabController =
      TabController(initialIndex: _selectedIndex, length: 4, vsync: this);
  bool _swipeIsInProgress = false;
  bool _tapIsBeingExecuted = false;
  int _prevIndex = 1;
  int index = 0;

  void onTabChanged() {
    final aniValue = _tabController.animation?.value;
    if (aniValue! > 0.5 && aniValue <= 1.5) {
      setState(() {
        _selectedIndex = 1;
      });
    } else if (aniValue <= 0.5 && aniValue >= 0.0) {
      setState(() {
        _selectedIndex = 0;
      });
    } else if (aniValue > 1.5 && aniValue <= 2.5) {
      setState(() {
        _selectedIndex = 2;
      });
    } else if (aniValue > 2.5 && aniValue <= 3.0) {
      setState(() {
        _selectedIndex = 3;
      });
    }
  }

  late bool isFilterActivated = true;

  var list = [];
  var userColor = [];
  @override
  void initState() {
    list = [
      '0xffdb1e24',
      '0xff00cdb7',
      '0xff57bd70',
      '0xff282828',
      '0xff37ea08',
      '0xff8153b6',
      '0xffff7f00',
      '0xff7d3ac1',
      '0xffdb4cb2',
      '0xffef7e32',
      '0xff1de4bd',
      '0xffeabd3b'
    ];

    userColor = [
      '0xffdb1e24',
      '0xff00cdb7',
      '0xff57bd70',
      '0xff282828',
      '0xff37ea08',
      '0xff8153b6',
      '0xffff7f00',
      '0xff7d3ac1',
      '0xffdb4cb2',
      '0xffef7e32',
      '0xff1de4bd',
      '0xffeabd3b'
    ];

    _tabController.animation?.addListener(onTabChanged);
    _controller = AnimationController(vsync: this, duration: duration);
    SharedPreferences.getInstance().then((value) {
      sharedPreferences = value;
      setState(() {
        groupTimeFormat = sharedPreferences.getString(
                    ConstantSharedPreferenceKeys.KEY_SELECTED_TIME_FORMAT) !=
                null
            ? sharedPreferences.getString(
                ConstantSharedPreferenceKeys.KEY_SELECTED_TIME_FORMAT)!
            : "24H";
        selectedDateFormat = (sharedPreferences.getString(
                    ConstantSharedPreferenceKeys.KEY_SELECTED_DATE_FORMAT) !=
                null
            ? sharedPreferences.getString(
                ConstantSharedPreferenceKeys.KEY_SELECTED_DATE_FORMAT)
            : "dd/MM/yyyy")!;
      });
    });
    super.initState();
    _orderList = getOrderList();
    print("=================================================");
    DateTime now = DateTime.now();
    String formattedDate = DateFormat('h:mm a').format(now);
    Intl.defaultLocale = 'pt_BR';
    // _getValue();
    // _tabController.animation?.addListener(() {
    //   if (!_tapIsBeingExecuted &&
    //       !_swipeIsInProgress &&
    //       (_tabController.offset >= 0.5 || _tabController.offset <= -0.5)) {
    //     int newIndex = _tabController.offset > 0 ? _tabController.index + 1 : _tabController.index - 1;
    //     _swipeIsInProgress = true;
    //     _prevIndex = _selectedIndex;
    //     setState(() {
    //       _selectedIndex = newIndex;
    //     });
    //   } else {
    //     if (!_tapIsBeingExecuted &&
    //         _swipeIsInProgress &&
    //         ((_tabController.offset < 0.5 && _tabController.offset > 0) ||
    //             (_tabController.offset > -0.5 && _tabController.offset < 0))) {
    //       _swipeIsInProgress = false;
    //       setState(() {
    //         _selectedIndex = _prevIndex;
    //       });
    //     }
    //   }
    // });
    // _tabController.addListener(() {
    //   _swipeIsInProgress = false;
    //   setState(() {
    //     _selectedIndex = _tabController.index;
    //   });
    //   if (_tapIsBeingExecuted == true) {
    //     _tapIsBeingExecuted = false;
    //   } else {
    //     if (_tabController.indexIsChanging) {
    //       _tapIsBeingExecuted = true;
    //     }
    //   }
    // });
    UserDao().getAllUsersWithoutRole().then((value) {
      setState(() {
        userList = value;
      });
    });
  }

  @override
  void dispose() {
    // _controller.dispose();
    // _tabController.dispose();
    super.dispose();
  }

  Future<void> _getValue() async {
    await Future.delayed(const Duration(seconds: 3), () {
      setState(() {});
    });
  }

  bool selected = false;

  @override
  Widget build(BuildContext context) {
    // Size size = MediaQuery
    //     .of(context)
    //     .size;
    // screenHeight = size.height;
    // screenWidth = size.width;
    return Scaffold(
      appBar: AppBarOptifood(),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(3, 0, 3, 0),
          child: Column(
            children: <Widget>[
              // dashboard(),
              // sideBar(),
              // bottomBar(),
              FilterPopup(
                  height: MediaQuery.of(context).size.height * 0.21,
                  child: dashboard(),
                  isFilterActivated: isFilterActivated),
              Expanded(
                  child:
                      // upperBar(),
                      IntervalReport(
                          takAway,
                          eatIn,
                          delivery,
                          totalValue,
                          _chartDataCategories,
                          series,
                          totalSales,
                          seriesProduct,
                          seriesProduct1,
                          seriesProduct2,
                          topOneProduct,
                          topTwoProduct,
                          topThreeProduct,
                          _productHighest,
                          _productHighest1,
                          _productHighest2,
                          cash,
                          creditCard,
                          mealVoucher,
                          cheque,
                          platform,
                          totalValueP,
                          totalQantity,
                          isFilterActivated,
                          seriesForUsers,
                          _chartDataUsers,
                          totalCountForAllDeliveryBoys,
                          seriesForDeliveryBoys,
                          _chartDataDeliveryBoys
                      )),
              // AnimatedPositioned(
              //     left: isLeftCollapsed ? 0 : 0.5 * screenWidth,
              //     right: isRightCollapsed ? 0 : -0.2 * screenWidth,
              //     top: isTopCollapsed ? 0 : -0.5 * screenHeight,
              //     bottom: isBottomCollapsed ? MediaQuery.of(context).size.height*0.4 : 1 * screenHeight,
              //     duration: duration,
              //     child: dashboard(context)),
            ],
          ),
        ),
      ),
    );
  }

  Widget dashboard() {
    setState(() {
      // isFilterActivated = !isFilterActivated;
    });
    return Form(
      key: _globalKey,
      child: Column(
        children: [
          Container(
              decoration: const BoxDecoration(
                color: Colors.white70,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    spreadRadius: 2,
                    blurRadius: 5,
                  ),
                ],
              ),
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                    0,
                    MediaQuery.of(context).size.height * 0.016,
                    0,
                    MediaQuery.of(context).size.height * 0.022),
                child: Column(
                  children: [
                    DateTimeFormField(
                      onTimeSelected: (value) {
                        if (_startDateTimeController.text.isNotEmpty &&
                            _endDateTimeController.text.isNotEmpty) {
                          setState(() {
                            isFilterActivated = false;
                            _orderList = getReport();
                          });
                        }
                      },
                      dateTimeController: _startDateTimeController,
                      initialDate: DateTime.now(),
                      firstDate: DateTime(1990),
                      initialTime: TimeOfDay.now(),
                      lastDate: 2100,
                      lastDates: DateTime.now(),
                      isKeepSpaceForOuterIcon: true,
                      dateConfirmText: "ok".tr(),
                      dateCancelText: "cancel".tr(),
                      timeConfirmText: "ok".tr(),
                      timeCancelText: "cancel".tr(),
                      minuteLabelText: "minute".tr(),
                      selectDate: "selectStartdDate".tr(),
                      startDateTime: _startDateTimeController,
                      endDateTime: _endDateTimeController,
                      outerIcon: SvgPicture.asset(
                        AppImages.calendarIcon,
                        height: 35,
                      ),
                      dateFlug: false,
                    ),
                    DateTimeFormField(
                      onTimeSelected: (value) {
                        if (_startDateTimeController.text.isNotEmpty &&
                            _endDateTimeController.text.isNotEmpty) {
                          setState(() {
                            isFilterActivated = false;
                            // FilterPopup(height:0, isFilterActivated:false, child:Container());
                          });
                          setState(() {
                            _orderList = getReport();
                          });
                        }
                      },
                      dateTimeController: _endDateTimeController,
                      initialDate: DateTime.now(),
                      firstDate: DateTime.now().subtract(Duration(days: 210)),
                      initialTime: TimeOfDay.now(),
                      lastDate: 2100,
                      lastDates: DateTime.now(),
                      isKeepSpaceForOuterIcon: true,
                      dateConfirmText: "ok".tr(),
                      dateCancelText: "cancel".tr(),
                      timeConfirmText: "ok".tr(),
                      timeCancelText: "cancel".tr(),
                      minuteLabelText: "minute".tr(),
                      selectDate: "selectEndDate".tr(),
                      startDateTime: _startDateTimeController,
                      endDateTime: _endDateTimeController,
                      dateFlug: true,
                      outerIcon: SvgPicture.asset(
                        AppImages.calendarIcon,
                        height: 35,
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }

  Widget upperBar() {
    print("=====================================$takAway==taketake====");

    return ListView(
      children: [
        Text(takAway.toString()),
        DefaultTabController(
            length: 4, // length of tabs
            initialIndex: 0,
            child: Container(
              height: MediaQuery.of(context).size.height * 0.86,
              color: Colors.white,
              child: ListView(children: <Widget>[
                SizedBox(
                  // height: MediaQuery.of(context).size.height*0.1,
                  child: TabBar(
                    controller: _tabController,
                    labelPadding: EdgeInsets.fromLTRB(0, 8, 0, 4),
                    onTap: (index) {
                      setState(() {
                        _selectedIndex = index;
                      });
                    },
                    indicatorColor: AppTheme.colorRed,
                    labelColor: Colors.white,
                    unselectedLabelColor: Colors.white,
                    tabs: [
                      Tab(
                        child: ListView(
                          children: <Widget>[
                            Padding(
                              padding: const EdgeInsets.fromLTRB(0, 0, 0, 8),
                              child: SvgPicture.asset(
                                AppImages.chart,
                                height: 20,
                                color: (_selectedIndex) == 0
                                    ? AppTheme.colorRed
                                    : AppTheme.colorMediumGrey,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(0.0),
                              child: Text(
                                "channels".tr(),
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    color: (_selectedIndex) == 0
                                        ? AppTheme.colorRed
                                        : AppTheme.colorMediumGrey),
                              ).tr(),
                            ),
                          ],
                        ),
                      ),
                      Tab(
                        child: ListView(
                          children: <Widget>[
                            Padding(
                              padding: const EdgeInsets.fromLTRB(0, 0, 0, 8),
                              child: SvgPicture.asset(
                                AppImages.pieChart,
                                height: 20,
                                color: (_selectedIndex) == 1
                                    ? AppTheme.colorRed
                                    : AppTheme.colorMediumGrey,
                              ),
                            ),
                            Text(
                              "products".tr(),
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  color: (_selectedIndex) == 1
                                      ? AppTheme.colorRed
                                      : AppTheme.colorMediumGrey),
                            ).tr(),
                          ],
                        ),
                        // text: 'Products'.tr()
                      ),
                      Tab(
                        child: ListView(
                          children: <Widget>[
                            Padding(
                                padding: const EdgeInsets.fromLTRB(0, 0, 0, 8),
                                child: SvgPicture.asset(
                                  AppImages.userChart,
                                  height: 20,
                                  color: (_selectedIndex) == 2
                                      ? AppTheme.colorRed
                                      : AppTheme.colorMediumGrey,
                                )),
                            Text(
                              "users".tr(),
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  color: (_selectedIndex) == 2
                                      ? AppTheme.colorRed
                                      : AppTheme.colorMediumGrey),
                            ).tr(),
                          ],
                        ),
                      ),
                      Tab(
                        child: ListView(
                          children: <Widget>[
                            Padding(
                                padding: const EdgeInsets.fromLTRB(0, 0, 0, 8),
                                child: SvgPicture.asset(
                                  AppImages.paymentChartIcon,
                                  height: 20,
                                  color: (_selectedIndex) == 3
                                      ? AppTheme.colorRed
                                      : AppTheme.colorMediumGrey,
                                )),
                            Text(
                              "payment",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  color: (_selectedIndex) == 3
                                      ? AppTheme.colorRed
                                      : AppTheme.colorMediumGrey),
                            ).tr(),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                    height: MediaQuery.of(context).size.height * 0.77,
                    decoration: const BoxDecoration(
                        border: Border(
                            top: BorderSide(
                                color: AppTheme.colorRed, width: 0.5))),
                    child: TabBarView(
                        controller: _tabController,
                        children: <Widget>[
                          CommonInterval(takAway, eatIn, delivery, totalValue),
                          CategoryReport(
                              _chartDataCategories,
                              series,
                              totalSales,
                              seriesProduct,
                              seriesProduct1,
                              seriesProduct2,
                              topOneProduct,
                              topTwoProduct,
                              topThreeProduct,
                              _productHighest,
                              _productHighest1,
                              _productHighest2,
                              totalQantity),
                          Container(),
                          // UserOrdersReport(),
                          PaymentReport(),
                        ]))
              ]),
            )),
      ],
    );
  }

  //common
  double totalValue = 0;
  late double takAway = 0;
  late double eatIn = 0;
  late double delivery = 0;
  late double collect = 0;
  late double point = 0;
  late double uber = 0;
  late double just = 0;
  late double deliveroo = 0;

  //Payment
  late double cash = 0;
  late double creditCard = 0;
  late double mealVoucher = 0;
  late double cheque = 0;
  late double platform = 0;
  late double totalValueP = 0;

  //categories
  double totalCategories = 0;
  int topOneProduct = 0;
  int topTwoProduct = 0;
  int topThreeProduct = 0;
  double totalSales = 0;
  late List<CategoryData> _chartDataCategories = [];

  late List<ItemData> _chartDataProducts = [];

  late List<ItemData> _productHighest = [];
  late List<charts.Series<ItemData, String>> seriesProduct = [];
  late List<ItemData> _productHighest1 = [];
  late List<charts.Series<ItemData, String>> seriesProduct1 = [];
  late List<ItemData> _productHighest2 = [];
  late List<charts.Series<ItemData, String>> seriesProduct2 = [];
  late List<charts.Series<CategoryData, String>> series = [];
  List<FoodCategoryModel> foodCategoryList = [];
  List<FoodItemsModel> foodItemList = [];
  List<UserModel> userList = [];
  var totalCountForAllDeliveryBoys =0;


  //top 3
  late Future<List<OrderModel>> _orderList;
  Future<List<OrderModel>> getReport() async {
    //categories
    totalCategories = totalSales = 0;
    topTwoProduct = topThreeProduct = 0;
    topOneProduct = 0;
    _chartDataCategories = [];
    _productHighest = [];
    seriesProduct = [];
    _productHighest1 = [];
    seriesProduct1 = [];
    _productHighest2 = [];
    seriesProduct2 = [];
    series = [];
    foodCategoryList = [];
    foodItemList = [];
    userList = [];
    takAway = eatIn = delivery = 0;
    totalQantity = 0;
    totalCountForAllDeliveryBoys=0;

    var finalStartDate = "";
    var finalEndDate = "";
    final DateFormat formatter = DateFormat('yyyy-MM-dd');

    if (_startDateTimeController.text.isNotEmpty &&
        _endDateTimeController.text.isNotEmpty) {
      var startDate = DateFormat('d/M/y')
          .parse(_startDateTimeController.text.substring(0, 10));
      var endDate = DateFormat('d/M/y')
          .parse(_endDateTimeController.text.substring(0, 10));
      final String startDateFormatted = formatter.format(startDate);
      final String endDateFormatted = formatter.format(endDate);
      finalStartDate = startDateFormatted +
          " " +
          _startDateTimeController.text.substring(13, 18);
      finalEndDate = endDateFormatted +
          " " +
          _endDateTimeController.text.substring(13, 18);
    }
    FoodCategoryDao().getAllFoodCategories().then((value) {
      setState(() {
        foodCategoryList = value;
      });
    });

    FoodItemsDao().getAllFoodItemsForReport().then((value) {
      setState(() {
        foodItemList = value;
      });
    });

    UserDao().getAllUsersWithoutRole().then((value) {
      setState(() {
        userList = value;
      });
    });

    List<OrderModel> fetchedData = [];
    List<double> categoryPayments = [];
    final dio = Dio();
    dio.options.headers['X-TenantID'] = optifoodSharedPrefrence.getString("database").toString();
    await dio.get(ServerData.OPTIFOOD_BASE_URL + "/api/order/report",
        queryParameters: {
          "fromDate": finalStartDate,
          "toDate": finalEndDate,
          "dateTimeZone": AppConfig.dateTime.timeZoneOffset.inMinutes,
          "limit": 10000000
        }).then((response) {
      setState(() {
        if (response.statusCode == 200) {
          for (int i = 0; i < response.data.length; i++) {
            var singleItem = OrderModel.fromJsonServer(response.data[i]);
            fetchedData.add(singleItem);
          }
        }

        for (int i = 0; i < fetchedData.length; i++) {
          totalValue += fetchedData[i].totalPrice;
          if (fetchedData[i].orderService == "restaurant_order_type_takeaway") {
            takAway += fetchedData[i].totalPrice;
          } else if (fetchedData[i].orderService ==
              "restaurant_order_type_eat_in") {
            eatIn += fetchedData[i].totalPrice;
          } else if (fetchedData[i].orderService == "delivery") {
            delivery += fetchedData[i].totalPrice;
          } else if (fetchedData[i].orderService == "partners") {
            just += 1;
          }
        }

        for (int i = 0; i < fetchedData.length; i++) {
          if (fetchedData[i].paymentMode == "Cash") {
            cash += fetchedData[i].totalPrice;
          } else if (fetchedData[i].paymentMode == "Credit Card") {
            creditCard += fetchedData[i].totalPrice;
          } else if (fetchedData[i].paymentMode == "Cheque") {
            cheque += fetchedData[i].totalPrice;
          } else if (fetchedData[i].paymentMode == "Platform") {
            platform += fetchedData[i].totalPrice;
          } else if (fetchedData[i].paymentMode == "Meal Voucher") {
            mealVoucher += fetchedData[i].totalPrice;
          }
        }

        //for user report
        var totalPriceForUsers = 0.0;
        for (int i = 0; i < userList.length; i++) {

          List<OrderData> filterUsers = _chartDataUsers
              .where((element) => element.user == userList[i].name)
              .toList();
          if (filterUsers.length > 0) continue;
          var tempPrice = 0.0;
          var deliveryBoyCount = 0;
          for (int j = 0; j < fetchedData.length; j++) {

            //for delivery count
            if(userList[i].role=='user_role_delivery_boy' && userList[i].intServerId==fetchedData[j].deliveryInfoModel!.assignedTo){
              deliveryBoyCount+=1;
            }
            //if (userList[i].intServerId == fetchedData[j].managerId) {
            if (userList[i].intServerId == fetchedData[j].manager.intServerId) {
              tempPrice += fetchedData[j].totalPrice;
            }
          }

          totalPriceForUsers += tempPrice;
          String valueString = "";

          valueString = (userColor..shuffle()).first;
          userColor.removeWhere((item) => item == valueString);
          int value = int.parse(valueString);
          if (tempPrice > 0)
            _chartDataUsers.add(
              OrderData(userList[i].name, tempPrice, Color(value),
                  charts.ColorUtil.fromDartColor(Color(value)), 6000,0),
            );


          //delivery data
          if(deliveryBoyCount>0 && userList[i].role=='user_role_delivery_boy'){
            totalCountForAllDeliveryBoys+=deliveryBoyCount;
            _chartDataDeliveryBoys.add(
              OrderData(userList[i].name, tempPrice, Color(value),
                  charts.ColorUtil.fromDartColor(Color(value)), 6000,deliveryBoyCount),
            );
          }
        }


        seriesForUsers = [
          charts.Series(
            id: "User",
            data: _chartDataUsers,
            labelAccessorFn: (OrderData row, _) =>
                '${((row.percentage * 100 / totalPriceForUsers)).round()}%',
            domainFn: (OrderData series, _) => series.user,
            measureFn: (OrderData series, _) => series.percentage,
            colorFn: (OrderData series, _) => series.colors,
            radiusPxFn: (OrderData series, _) => series.total,
          )
        ];

        //Delivery boys
        seriesForDeliveryBoys = [
          charts.Series(
            id: "User",
            data: _chartDataDeliveryBoys,
            labelAccessorFn: (OrderData row, _) =>
            '${((row.countForSingleDeliveryBoy * 100 / totalCountForAllDeliveryBoys)).round()}%',
            domainFn: (OrderData series, _) => series.user,
            measureFn: (OrderData series, _) => series.countForSingleDeliveryBoy,
            colorFn: (OrderData series, _) => series.colors,
            radiusPxFn: (OrderData series, _) => series.total,
          )
        ];

        totalValueP = cash + creditCard + cheque + platform + mealVoucher;

        for (int j = 0; j < foodCategoryList.length; j++) {
          double tempVal = 0;
          for (int y = 0; y < fetchedData.length; y++) {
            List<FoodItemsModel>? temData = [];
            temData = fetchedData[y]
                .foodItems
                .where((i) =>
                    i.categoryID == foodCategoryList[j].serverId ||
                    i.catServerId == foodCategoryList[j].serverId ||
                    i.categoryID == foodCategoryList[j].id)
                .toList();

            for (int k = 0; k < temData.length; k++) {
              if (fetchedData[y].orderService == "delivery" &&
                  temData[k].deliveryPrice != 0.0) {
                tempVal += temData[k].deliveryPrice * temData[k].quantity;
              } else if (fetchedData[y].orderService ==
                      "restaurant_order_type_eat_in" &&
                  temData[k].eatInPrice != 0.0) {
                tempVal += temData[k].eatInPrice * temData[k].quantity;
              } else {
                tempVal += temData[k].price * temData[k].quantity;
              }
            }
          }
          categoryPayments.add(tempVal);
          totalSales += tempVal;
        }

        List<FoodItemsModel>? foodItems = [];
        // only for top 3 items
        for (int y = 0; y < fetchedData.length; y++) {
          List<FoodItemsModel>? temDatas = [];
          temDatas = fetchedData[y].foodItems.toList();
          for (int k = 0; k < temDatas.length; k++) {
            foodItems.add(temDatas[k]);
          }
        }
        List<FoodItemsModel> foodItemsModels = [];
        for (int x = 0; x < foodItemList.length; x++) {
          int quantity = 0;
          int count = 0;
          double price = 0;
          for (int j = 0; j < foodItems.length; j++) {
            if (foodItemList[x].serverId == foodItems[j].serverId) {
              quantity += foodItems[j].quantity;
              count++;
              price += foodItems[j].price;
            }
          }
          if (count > 0) {
            FoodItemsModel foodItemsModel = new FoodItemsModel(
                1,
                foodItemList[x].name,
                foodItemList[x].displayName,
                foodItemList[x].description,
                "allergence",
                price);
            foodItemsModel.quantity = quantity;
            foodItemsModel.serverId = foodItemList[x].serverId;
            foodItemsModels.add(foodItemsModel);
          }
        }

        for (int z = 0; z < foodItemsModels.length; z++) {
          String valueString = "";
          totalQantity += foodItemsModels[z].quantity;
          print(
              "=================quantity item=====${foodItemsModels[z].quantity}==================================");
          // if(foodCategoryList[x].color=="ffffff"){
          valueString = "0xff306f9a";
          // }
          // else{valueString = "0x${foodCategoryList[x].color}";}
          int value = int.parse(valueString);
          _chartDataProducts.add(
            ItemData(
                foodItemsModels[z].name,
                charts.ColorUtil.fromDartColor(Color(value)),
                Color(value),
                totalSales,
                foodItemsModels[z].price,
                foodItemsModels[z].quantity),
          );
        }

        Comparator<ItemData> sortByPercentage1 =
            (a, b) => a.quantity.compareTo(b.quantity);
        _chartDataProducts.sort(sortByPercentage1);

        for (int x = 0; x < categoryPayments.length; x++) {
          if (categoryPayments[x] != 0) {
            String valueString = "";
            if (foodCategoryList[x].color == "ffffff") {
              valueString = (list..shuffle()).first;
              list.removeWhere((item) => item == valueString);
              // valueString="0xff306f9a";
            } else {
              valueString = "0x${foodCategoryList[x].color}";
            }
            int value = int.parse(valueString);
            _chartDataCategories.add(
              CategoryData(
                  foodCategoryList[x].name,
                  charts.ColorUtil.fromDartColor(Color(value)),
                  Color(value),
                  totalSales,
                  categoryPayments[x]),
            );
          }
        }

        series = [
          charts.Series(
            id: "Category",
            displayName: "m",
            data: _chartDataCategories,
            labelAccessorFn: (CategoryData row, _) =>
                Utility().formatPrice(row.percentage),
            domainFn: (CategoryData series, _) => series.cat,
            measureFn: (CategoryData series, _) => series.percentage,
            colorFn: (CategoryData series, _) => series.color,
            radiusPxFn: (CategoryData series, _) => series.percentage,
          )
        ];

        Comparator<CategoryData> sortByPercentage =
            (a, b) => a.percentage.compareTo(b.percentage);
        _chartDataCategories.sort(sortByPercentage);

        if (_chartDataProducts.length > 0) {
          topOneProduct =
              _chartDataProducts[_chartDataProducts.length - 1].quantity;
          _productHighest = [
            ItemData(
                _chartDataProducts[_chartDataProducts.length - 1].item,
                charts.ColorUtil.fromDartColor(Color(0xffdb1e24)),
                Color(0xffdb1e24),
                5000,
                _chartDataProducts[_chartDataProducts.length - 1].percentage,
                topOneProduct),
          ];
        } else {
          _productHighest = [
            ItemData(
                "Product two",
                charts.ColorUtil.fromDartColor(const Color(0xffe6e6e6)),
                const Color(0xffe6e6e6),
                totalSales,
                totalSales,
                0)
          ];
        }

        seriesProduct = [
          charts.Series(
            id: "Category",
            displayName: "m",
            data: _productHighest,
            labelAccessorFn: (ItemData row, _) =>
                Utility().formatPrice(row.totalSale),
            domainFn: (ItemData series, _) => series.item,
            measureFn: (ItemData series, _) => series.percentage,
            colorFn: (ItemData series, _) => series.color,
            radiusPxFn: (ItemData series, _) => series.quantity,
          )
        ];
        //
        //top two
        if (_chartDataProducts.length > 1) {
          topTwoProduct =
              _chartDataProducts[_chartDataProducts.length - 2].quantity;
          // String valueString = "0x${_chartDataCategories[_chartDataCategories
          //     .length - 2].color}";
          // int value = int.parse(valueString);
          _productHighest1 = [
            ItemData(
                _chartDataProducts[_chartDataProducts.length - 2].item,
                charts.ColorUtil.fromDartColor(Color(0xffff6d00)),
                Color(0xffff6d00),
                5000,
                _chartDataProducts[_chartDataProducts.length - 2].percentage,
                topTwoProduct),
          ];
        } else {
          _productHighest1 = [
            ItemData(
                "Product three",
                charts.ColorUtil.fromDartColor(const Color(0xffe6e6e6)),
                const Color(0xffe6e6e6),
                5000,
                5000,
                0)
          ];
        }
        seriesProduct1 = [
          charts.Series(
            id: "Category",
            displayName: "m",
            data: _productHighest1,
            labelAccessorFn: (ItemData row, _) =>
                Utility().formatPrice(row.totalSale),
            domainFn: (ItemData series, _) => series.item,
            measureFn: (ItemData series, _) => series.percentage,
            colorFn: (ItemData series, _) => series.color,
            radiusPxFn: (ItemData series, _) => series.quantity,
          )
        ];

        if (_chartDataProducts.length > 2) {
          topThreeProduct =
              _chartDataProducts[_chartDataProducts.length - 3].quantity;
          // String valueString = "0x${_chartDataCategories[_chartDataCategories
          //     .length - 3].color}";
          // int value = int.parse(valueString);
          _productHighest2 = [
            ItemData(
                _chartDataProducts[_chartDataProducts.length - 3].item,
                charts.ColorUtil.fromDartColor(Color(0xff306f9a)),
                Color(0xff306f9a),
                10000,
                _chartDataProducts[_chartDataProducts.length - 3].percentage,
                topThreeProduct),
          ];
        } else {
          _productHighest2 = [
            ItemData(
                "Product four",
                charts.ColorUtil.fromDartColor(const Color(0xffe6e6e6)),
                const Color(0xffe6e6e6),
                10000,
                10000,
                0)
          ];
        }

        seriesProduct2 = [
          charts.Series(
            id: "Category",
            displayName: "m",
            data: _productHighest2,
            labelAccessorFn: (ItemData row, _) =>
                Utility().formatPrice(row.totalSale),
            domainFn: (ItemData series, _) => series.item,
            measureFn: (ItemData series, _) => series.percentage,
            colorFn: (ItemData series, _) => series.color,
            radiusPxFn: (ItemData series, _) => series.quantity,
          )
        ];
      });
    });
    return fetchedData;
  }

  var totalQantity = 0;
  Future<List<OrderModel>> getOrderList() async {
    totalQantity = 0;
    //categories
    totalCategories = totalSales = 0;
    topOneProduct = topThreeProduct = topTwoProduct = 0;
    _chartDataCategories = [];
    _productHighest = [];
    seriesProduct = [];
    _productHighest1 = [];
    seriesProduct1 = [];
    _productHighest2 = [];
    seriesProduct2 = [];
    series = [];
    foodCategoryList = [];
    takAway = eatIn = delivery = 0;
    totalCountForAllDeliveryBoys=0;

    FoodCategoryDao().getAllFoodCategories().then((value) {
      setState(() {
        foodCategoryList = value;
      });
    });

    FoodItemsDao().getAllFoodItemsForReport().then((value) {
      setState(() {
        foodItemList = value;
      });
    });

    /*UserDao().getAllUsersWithoutRole().then((value) {
      setState(() {
        userList = value;
      });
    });*/
    userList = await UserDao().getAllUsersWithoutRole();

    List<double> categoryPayments = [];
    _orderList = OrderDao().getAllOrders();
    _orderList.then((value) => {
          setState(() {
            for (int i = 0; i < value.length; i++) {
              totalValue += value[i].totalPrice;
              if (value[i].orderService == "restaurant_order_type_takeaway") {
                takAway += value[i].totalPrice;
              } else if (value[i].orderService ==
                  "restaurant_order_type_eat_in") {
                eatIn += value[i].totalPrice;
              } else if (value[i].orderService == "delivery") {
                delivery += value[i].totalPrice;
              } else if (value[i].orderService == "partners") {
                just += 1;
              }
            }

            for (int i = 0; i < value.length; i++) {
              if (value[i].paymentMode == "Cash") {
                cash += value[i].totalPrice;
              } else if (value[i].paymentMode == "Credit Card") {
                creditCard += value[i].totalPrice;
              } else if (value[i].paymentMode == "Cheque") {
                cheque += value[i].totalPrice;
              } else if (value[i].paymentMode == "Platform") {
                platform += value[i].totalPrice;
              } else if (value[i].paymentMode == "Meal Voucher") {
                mealVoucher += value[i].totalPrice;
              }
            }
            totalValueP = cash + creditCard + cheque + platform + mealVoucher;
            //for user report
            var totalPriceForUsers = 0.0;
            for (int i = 0; i < userList.length; i++) {
              var tempPrice = 0.0;
              List<OrderData> filterUsers = _chartDataUsers
                  .where((element) => element.user == userList[i].name)
                  .toList();
              var deliveryBoyCount=0;
              if (filterUsers.length > 0) continue;
              for (int j = 0; j < value.length; j++) {
                //for delivery count
                if(userList[i].role=='user_role_delivery_boy' && userList[i].intServerId==value[j].deliveryInfoModel!.assignedTo){
                  deliveryBoyCount+=1;
                }
                //if (userList[i].intServerId == value[j].managerId) {
                if (userList[i].intServerId == value[j].manager.intServerId) {
                  tempPrice += value[j].totalPrice;
                }
              }
              totalPriceForUsers += tempPrice;
              String valueString = "";

              valueString = (userColor..shuffle()).first;
              userColor.removeWhere((item) => item == valueString);
              int value1 = int.parse(valueString);
              if (tempPrice > 0) {
                if (filterUsers.length == 0)
                  _chartDataUsers.add(
                    OrderData(userList[i].name, tempPrice, Color(value1),
                        charts.ColorUtil.fromDartColor(Color(value1)), 6000,0),
                  );
              }

              //delivery data
              if(deliveryBoyCount>0 && userList[i].role=='user_role_delivery_boy'){
                totalCountForAllDeliveryBoys+=deliveryBoyCount;
                _chartDataDeliveryBoys.add(
                  OrderData(userList[i].name, tempPrice, Color(value1),
                      charts.ColorUtil.fromDartColor(Color(value1)), 6000,deliveryBoyCount),
                );
              }
            }



            seriesForUsers = [
              charts.Series(
                id: "User",
                data: _chartDataUsers,
                labelAccessorFn: (OrderData row, _) =>
                    '${((row.percentage * 100 / totalPriceForUsers)).round()}%',
                domainFn: (OrderData series, _) => series.user,
                measureFn: (OrderData series, _) => series.percentage,
                colorFn: (OrderData series, _) => series.colors,
                radiusPxFn: (OrderData series, _) => series.total,
              )
            ];

            //Delivery boys
            seriesForDeliveryBoys = [
              charts.Series(
                id: "User",
                data: _chartDataDeliveryBoys,
                labelAccessorFn: (OrderData row, _) =>
                '${((row.countForSingleDeliveryBoy * 100 / totalCountForAllDeliveryBoys)).round()}%',
                domainFn: (OrderData series, _) => series.user,
                measureFn: (OrderData series, _) => series.countForSingleDeliveryBoy,
                colorFn: (OrderData series, _) => series.colors,
                radiusPxFn: (OrderData series, _) => series.total,
              )
            ];

            //=================categories============
            for (int j = 0; j < foodCategoryList.length; j++) {
              double tempVal = 0;
              for (int y = 0; y < value.length; y++) {
                List<FoodItemsModel>? temData = [];

                temData = value[y]
                    .foodItems
                    .where((i) => i.catServerId == foodCategoryList[j].serverId)
                    .toList();

                for (int k = 0; k < temData.length; k++) {
                  if (value[y].orderService == "delivery" &&
                      temData[k].deliveryPrice != 0.0) {
                    tempVal += temData[k].deliveryPrice * temData[k].quantity;
                  } else if (value[y].orderService ==
                          "restaurant_order_type_eat_in" &&
                      temData[k].eatInPrice != 0.0) {
                    tempVal += temData[k].eatInPrice * temData[k].quantity;
                  } else {
                    tempVal += temData[k].price * temData[k].quantity;
                  }
                }
              }
              categoryPayments.add(tempVal);
              totalSales += tempVal;
            }

            List<FoodItemsModel>? foodItems = [];
            // only for top 3 items

            for (int y = 0; y < value.length; y++) {
              List<FoodItemsModel>? temDatas = [];
              temDatas = value[y].foodItems.toList();

              for (int k = 0; k < temDatas.length; k++) {
                foodItems.add(temDatas[k]);
              }
            }

            for (int c = 0; c < foodItems.length; c++) {
              totalQantity += foodItems[c].quantity;
            }

            List<FoodItemsModel> foodItemsModels = [];
            double totalQuantityOfItems = 0.0;
            /*for (int x = 0; x < foodItemList.length; x++) {
              int quantity = 0;
              int count = 0;
              double price = 0;
              for (int j = 0; j < foodItems.length; j++) {
                if (foodItemList[x].serverId == foodItems[j].serverId) {
                  quantity += foodItems[j].quantity;
                  totalQuantityOfItems += foodItems[j].quantity;
                  count++;
                  price += foodItems[j].price;
                }
              }

              if (count > 0) {
                FoodItemsModel foodItemsModel = new FoodItemsModel(
                    1,
                    foodItemList[x].name,
                    foodItemList[x].displayName,
                    foodItemList[x].description,
                    "allergence",
                    price);
                foodItemsModel.quantity = quantity;
                foodItemsModel.serverId = foodItemList[x].serverId;
                foodItemsModels.add(foodItemsModel);
              }
            }*/

            for (int x = 0; x < foodItemList.length; x++) {
              int quantity = 0;
              int count = 0;
              double price = 0;
              for (int j = 0; j < foodItems.length; j++) {
                if (foodItemList[x].serverId == foodItems[j].serverId) {
                  quantity += foodItems[j].quantity;
                  totalQuantityOfItems += foodItems[j].quantity;
                  count++;
                  price += foodItems[j].price;
                }
              }

              if (count > 0) {
                FoodItemsModel foodItemsModel = new FoodItemsModel(
                    1,
                    foodItemList[x].name,
                    foodItemList[x].displayName,
                    foodItemList[x].description,
                    "allergence",
                    price);
                foodItemsModel.quantity = quantity;
                foodItemsModel.serverId = foodItemList[x].serverId;
                foodItemsModels.add(foodItemsModel);
              }
            }

            // foodItems = foodItems1.toList();

            for (int z = 0; z < foodItemsModels.length; z++) {
              String valueString = "";
              valueString = "0xff306f9a";
              int value = int.parse(valueString);
              _chartDataProducts.add(
                ItemData(
                    foodItemsModels[z].name,
                    charts.ColorUtil.fromDartColor(Color(value)),
                    Color(value),
                    totalQuantityOfItems,
                    foodItemsModels[z].price,
                    foodItemsModels[z].quantity),
              );
            }

            Comparator<ItemData> sortByPercentage1 =
                (a, b) => a.quantity.compareTo(b.quantity);
            _chartDataProducts.sort(sortByPercentage1);

            for (int x = 0; x < categoryPayments.length; x++) {
              if (categoryPayments[x] != 0) {
                String valueString = "";
                if (foodCategoryList[x].color == "ffffff") {
                  valueString = (list..shuffle()).first;
                  list.removeWhere((item) => item == valueString);
                  // list.remove(valueString);

                }
                // else{valueString = "0x${foodCategoryList[x].color}";}
                int value = int.parse(valueString);
                _chartDataCategories.add(
                  CategoryData(
                      foodCategoryList[x].name,
                      charts.ColorUtil.fromDartColor(Color(value)),
                      Color(value),
                      totalSales,
                      categoryPayments[x]),
                );
              }
            }

            series = [
              charts.Series(
                id: "Category",
                displayName: "m",
                data: _chartDataCategories,
                labelAccessorFn: (CategoryData row, _) =>
                    ((row.percentage / totalSales) * 100).round().toString() +
                    "%",
                domainFn: (CategoryData series, _) => series.cat,
                measureFn: (CategoryData series, _) => series.percentage,
                colorFn: (CategoryData series, _) => series.color,
                radiusPxFn: (CategoryData series, _) => series.percentage,
              )
            ];

            Comparator<CategoryData> sortByPercentage =
                (a, b) => a.percentage.compareTo(b.percentage);
            _chartDataCategories.sort(sortByPercentage);

            if (_chartDataProducts.length > 0) {
              topOneProduct =
                  _chartDataProducts[_chartDataProducts.length - 1].quantity;
              _productHighest = [
                ItemData(
                    _chartDataProducts[_chartDataProducts.length - 1].item,
                    charts.ColorUtil.fromDartColor(Color(0xffdb1e24)),
                    Color(0xffdb1e24),
                    5000,
                    _chartDataProducts[_chartDataProducts.length - 1]
                        .percentage,
                    topOneProduct),
              ];
            }

            seriesProduct = [
              charts.Series(
                id: "Category",
                displayName: "m",
                data: _productHighest,
                labelAccessorFn: (ItemData row, _) =>
                    Utility().formatPrice(row.totalSale),
                domainFn: (ItemData series, _) => series.item,
                measureFn: (ItemData series, _) => series.percentage,
                colorFn: (ItemData series, _) => series.color,
                radiusPxFn: (ItemData series, _) => series.quantity,
              )
            ];
            //
            //top two
            if (_chartDataProducts.length > 1) {
              topTwoProduct =
                  _chartDataProducts[_chartDataProducts.length - 2].quantity;
              _productHighest1 = [
                ItemData(
                    _chartDataProducts[_chartDataProducts.length - 2].item,
                    charts.ColorUtil.fromDartColor(Color(0xffff6d00)),
                    Color(0xffff6d00),
                    5000,
                    _chartDataProducts[_chartDataProducts.length - 2]
                        .percentage,
                    topTwoProduct),
              ];
            } else {
              _productHighest1 = [
                ItemData(
                    "Product three",
                    charts.ColorUtil.fromDartColor(const Color(0xffe6e6e6)),
                    const Color(0xffe6e6e6),
                    5000,
                    5000,
                    0)
              ];
            }
            seriesProduct1 = [
              charts.Series(
                id: "Category",
                displayName: "m",
                data: _productHighest1,
                labelAccessorFn: (ItemData row, _) =>
                    Utility().formatPrice(row.totalSale),
                domainFn: (ItemData series, _) => series.item,
                measureFn: (ItemData series, _) => series.percentage,
                colorFn: (ItemData series, _) => series.color,
                radiusPxFn: (ItemData series, _) => series.quantity,
              )
            ];

            if (_chartDataProducts.length > 2) {
              topThreeProduct =
                  _chartDataProducts[_chartDataProducts.length - 3].quantity;
              // String valueString = "0x${_chartDataCategories[_chartDataCategories
              //     .length - 3].color}";
              // int value = int.parse(valueString);
              _productHighest2 = [
                ItemData(
                    _chartDataProducts[_chartDataProducts.length - 3].item,
                    charts.ColorUtil.fromDartColor(Color(0xffeabd3b)),
                    Color(0xffeabd3b),
                    50000,
                    _chartDataProducts[_chartDataProducts.length - 3]
                        .percentage,
                    topThreeProduct),
                // ItemData("Product four",
                // charts.ColorUtil.fromDartColor(const Color(0xffeabd3b)),
                // const Color(0xffeabd3b), 5000, 5000,0)
              ];
            } else {
              _productHighest2 = [
                ItemData(
                    "Product four",
                    charts.ColorUtil.fromDartColor(const Color(0xffe6e6e6)),
                    const Color(0xffe6e6e6),
                    10000,
                    10000,
                    0)
              ];
            }

            seriesProduct2 = [
              charts.Series(
                id: "Category",
                data: _productHighest2,
                labelAccessorFn: (ItemData row, _) =>
                    Utility().formatPrice(row.totalSale),
                domainFn: (ItemData series, _) => series.item,
                measureFn: (ItemData series, _) => series.percentage,
                colorFn: (ItemData series, _) => series.color,
                radiusPxFn: (ItemData series, _) => series.quantity,
              )
            ];
          }),
        });
    return _orderList;
  }

  late List<OrderData> _chartDataUsers = [];
  late List<OrderData> _chartDataDeliveryBoys = [];
  late List<charts.Series<OrderData, String>> seriesForUsers = [];
  late List<charts.Series<OrderData, String>> seriesForDeliveryBoys = [];
}

class OrderData {
  OrderData(this.user, this.percentage, this.color, this.colors, this.total,this.countForSingleDeliveryBoy);
  final String user;
  final double percentage;
  final Color color;
  final charts.Color colors;
  final double total;
  final int countForSingleDeliveryBoy;
}
