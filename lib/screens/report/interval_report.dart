import 'package:charts_common/src/data/series.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:opti_food_app/screens/report/search_form.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../assets/images.dart';
import '../../data_models/order_model.dart';
import '../../main.dart';
import '../../utils/constants.dart';
import '../../utils/utility.dart';
import '../../widgets/app_theme.dart';
import 'category_report.dart';
import 'common_file_for_interval_report.dart';
import 'package:charts_flutter/flutter.dart' as charts;

import 'common_for_category_user.dart';
import '../MountedState.dart';
class IntervalReport extends StatefulWidget {
  // final List<OrderModel> orderList;
  final double takAway;
  final double eatIn;
  final double delivery;
  final double totalValue;
  List<CategoryData> chartDataCategories;
  List<Series<CategoryData, String>> series;
  double totalSales;
  final List<charts.Series<ItemData, String>> seriesProduct;
  final List<charts.Series<ItemData, String>> seriesProduct1;
  final List<charts.Series<ItemData, String>> seriesProduct2;
  final int topOneProduct;
  final int topTwoProduct;
  final int topThreeProduct;
  final List<ItemData> productHighest;
  final List<ItemData> productHighest1;
  final List<ItemData> productHighest2;
  final double cash;
  final double creditCard;
  final double mealVoucher;
  final double cheque;
  final double platform;
  final double totalValueP;
  final int totalQantity;
  final bool isFilterActivated;
  final List<Series<OrderData, String>> seriesForUsers;
  final List<OrderData> chartDataUsers;
  final int totalCountForAllDeliveryBoys;
  final List<Series<OrderData, String>> seriesForDeliveryBoys;
  final List<OrderData> chartDataDeliveryBoys;
  IntervalReport(
      this.takAway,
      this.eatIn,
      this.delivery,
      this.totalValue,
      this.chartDataCategories,
      this.series,
      this.totalSales,
      this.seriesProduct,
      this.seriesProduct1,
      this.seriesProduct2,
      this.topOneProduct,
      this.topTwoProduct,
      this.topThreeProduct,
      this.productHighest,
      this.productHighest1,
      this.productHighest2,
      this.cash,
      this.creditCard,
      this.mealVoucher,
      this.cheque,
      this.platform,
      this.totalValueP,
      this.totalQantity,
      this.isFilterActivated,
      this.seriesForUsers,
      this.chartDataUsers,
      this.totalCountForAllDeliveryBoys,
      this.seriesForDeliveryBoys,
      this.chartDataDeliveryBoys,
      {Key? key})
      : super(key: key);

  @override
  State<IntervalReport> createState() => _IntervalReportState();
}

class _IntervalReportState extends MountedState<IntervalReport>
    with TickerProviderStateMixin {
  double _width = 0;

  final GlobalKey<FormState> _globalKey = GlobalKey<FormState>();
  TextEditingController dateTimeEndController = TextEditingController();
  TextEditingController dateTimeStartController = TextEditingController();
  double totalValue = 0;
  int totalOrders = 0;
  late Future<List<OrderModel>> _orderList;
  late double takAway = 0;
  late double eatIn = 0;
  late double delivery = 0;
  late double collect = 0;
  late double point = 0;
  late double uber = 0;
  late double just = 0;
  late double deliveroo = 0;
  late bool isFormToDisplay = true;

  var _refreshIndicator = GlobalKey<RefreshIndicatorState>();
  late TextEditingController _controller1;
  late TextEditingController _startDateTimeController = TextEditingController();
  late TextEditingController _endDateTimeController = TextEditingController();

  late TextEditingController _controller3;
  late TextEditingController _controller4;

  GlobalKey<FormState> _oFormKey = GlobalKey<FormState>();
  late String selectedDateFormat;
  late String groupTimeFormat;
  late SharedPreferences sharedPreferences;
  // late bool height=true;
  Utility utility = Utility();
  int selected_index = 0;
  int _selectedIndex = 0;
  final Duration duration = const Duration(milliseconds: 400);
  late AnimationController _controller;

  late TabController _tabController =
      TabController(initialIndex: _selectedIndex, length: 4, vsync: this);
  bool _swipeIsInProgress = false;
  bool _tapIsBeingExecuted = false;
  int _prevIndex = 1;
  int index = 0;
  Future<void> onTabChanged() async {
    // SharedPreferences.getInstance().then((value){
    //   sharedPreferences = value;
    //   setState(() {
    //     height = sharedPreferences.getBool("isFilterActivated")!;
    //     print(height.toString())
    //     ;      });
    // });
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
  var selectedLanguage = optifoodSharedPrefrence
              .getString(ConstantSharedPreferenceKeys.KEY_SELECTED_LANGUAGE) !=
          null
      ? optifoodSharedPrefrence
          .getString(ConstantSharedPreferenceKeys.KEY_SELECTED_LANGUAGE)!
      : ConstantSharedPreferenceKeys.KEY_SELECTED_LANGUAGE;

  @override
  void initState() {
    _width = 0;
    super.initState();
    Future.delayed(const Duration(milliseconds: 500), () {
      setState(() {
        _width = widget.takAway;
      });
    });
    print("================intervalreport==================");
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

    getChartData();
    super.initState();
    DateTime now = DateTime.now();
    Intl.defaultLocale = 'pt_BR';
  }

  bool selected = false;
  int totalSales = 6000;
  late List<OrderData> _chartData = [];
  late List<OrderData> _chartDataDeliveryBoy = [];

  // late List<charts.Series<OrderData, String>> series = [];
  late List<charts.Series<OrderData, String>> seriesForDeliveryBoy = [];

  // double totalValue = 0;
  // int totalOrders = 0;
  int totalProducts = 0;
  int totalContacts = 0;

  late Future<List<OrderModel>> _orderList1 = [] as Future<List<OrderModel>>;
  @override
  Widget build(BuildContext context) {
    final isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      // appBar: AppBarOptifood(),
      body: ListView(
        children: [
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
                                  padding:
                                      const EdgeInsets.fromLTRB(0, 0, 0, 8),
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
                                  padding:
                                      const EdgeInsets.fromLTRB(0, 0, 0, 8),
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
                            SizedBox(
                              height: MediaQuery.of(context).size.height * 0.6,
                              child: ListView(
                                children: [
                                  Positioned(
                                    bottom: 200,
                                    child: SingleChildScrollView(
                                      child: Padding(
                                        // widget.isFilterActivated?MediaQuery.of(context).size.height*0.07
                                        padding: EdgeInsets.fromLTRB(
                                            0,
                                            0,
                                            0,
                                            MediaQuery.of(context).size.height *
                                                0.25),
                                        child: Card(
                                          color: Colors.white,
                                          surfaceTintColor: Colors.transparent,
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(20),
                                          ),
                                          elevation: 15,
                                          child: Padding(
                                            padding: const EdgeInsets.fromLTRB(
                                                0, 0, 0, 28),
                                            child: Column(
                                              children: [
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.fromLTRB(
                                                          0, 15, 0, 10),
                                                  child: Center(
                                                    child: Text(
                                                      "saleChannels".tr(),
                                                      style: const TextStyle(
                                                          fontSize: 18,
                                                          color:
                                                              AppTheme.colorRed,
                                                          fontWeight:
                                                              FontWeight.bold),
                                                    ),
                                                  ),
                                                ),
                                                SizedBox(
                                                  height: MediaQuery.of(context)
                                                          .size
                                                          .height *
                                                      0.06,
                                                  child: Padding(
                                                    padding: const EdgeInsets
                                                        .fromLTRB(15, 0, 13, 0),
                                                    child: Column(
                                                      children: [
                                                        Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                      .fromLTRB(
                                                                  0, 12, 0, 0),
                                                          child: Row(
                                                            children: [
                                                              Padding(
                                                                padding:
                                                                    const EdgeInsets
                                                                            .fromLTRB(
                                                                        20,
                                                                        0,
                                                                        0,
                                                                        2),
                                                                child: Container(
                                                                    width: MediaQuery.of(context)
                                                                            .size
                                                                            .width *
                                                                        0.66,
                                                                    child: Text(
                                                                        "takeAway"
                                                                            .tr())),
                                                              ),
                                                              Container(
                                                                  // margin: EdgeInsets.only(left: 220),
                                                                  child: Text(Utility()
                                                                      .formatPrice(
                                                                          widget
                                                                              .takAway))),
                                                            ],
                                                          ),
                                                        ),
                                                        Stack(
                                                          children: [
                                                            Container(
                                                              width: MediaQuery.of(
                                                                          context)
                                                                      .size
                                                                      .width *
                                                                  0.90,
                                                              height: 10,
                                                              decoration: BoxDecoration(
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              4),
                                                                  color: AppTheme
                                                                      .colorLightGrey),
                                                            ),
                                                            AnimatedContainer(
                                                                duration:
                                                                    const Duration(
                                                                        milliseconds:
                                                                            400),
                                                                width: widget
                                                                            .takAway !=
                                                                        0
                                                                    ? MediaQuery.of(context)
                                                                            .size
                                                                            .width *
                                                                        (0.90 *
                                                                            widget
                                                                                .takAway /
                                                                            widget
                                                                                .totalValue)
                                                                    : widget
                                                                        .takAway,
                                                                height: 10,
                                                                decoration: BoxDecoration(
                                                                    borderRadius:
                                                                        BorderRadius
                                                                            .circular(
                                                                                6),
                                                                    color: Color(
                                                                        0xffdb1e24))),
                                                          ],
                                                        )
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                                SizedBox(
                                                  height: MediaQuery.of(context)
                                                          .size
                                                          .height *
                                                      0.06,
                                                  child: Padding(
                                                    padding: const EdgeInsets
                                                        .fromLTRB(15, 0, 13, 0),
                                                    child: Column(
                                                      children: [
                                                        Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                      .fromLTRB(
                                                                  0, 12, 0, 0),
                                                          child: Row(
                                                            children: [
                                                              Padding(
                                                                padding:
                                                                    const EdgeInsets
                                                                            .fromLTRB(
                                                                        20,
                                                                        0,
                                                                        0,
                                                                        2),
                                                                child: Container(
                                                                    width: MediaQuery.of(context)
                                                                            .size
                                                                            .width *
                                                                        0.66,
                                                                    child: Text(
                                                                        "eatIn"
                                                                            .tr())),
                                                              ),
                                                              Container(
                                                                  // margin: EdgeInsets.only(left: 220),
                                                                  child: Text(Utility()
                                                                      .formatPrice(
                                                                          widget
                                                                              .eatIn))),
                                                            ],
                                                          ),
                                                        ),
                                                        Stack(
                                                          children: [
                                                            Container(
                                                              width: MediaQuery.of(
                                                                          context)
                                                                      .size
                                                                      .width *
                                                                  0.90,
                                                              height: 10,
                                                              decoration: BoxDecoration(
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              4),
                                                                  color: AppTheme
                                                                      .colorLightGrey),
                                                            ),
                                                            AnimatedContainer(
                                                                duration:
                                                                    const Duration(
                                                                        milliseconds:
                                                                            400),
                                                                width: widget
                                                                            .eatIn !=
                                                                        0
                                                                    ? MediaQuery.of(context)
                                                                            .size
                                                                            .width *
                                                                        (0.90 *
                                                                            widget
                                                                                .eatIn /
                                                                            widget
                                                                                .totalValue)
                                                                    : widget
                                                                        .eatIn,
                                                                height: 10,
                                                                decoration: BoxDecoration(
                                                                    borderRadius:
                                                                        BorderRadius
                                                                            .circular(
                                                                                6),
                                                                    color: Color(
                                                                        0xffdb1e24))),
                                                          ],
                                                        )
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                                SizedBox(
                                                  height: MediaQuery.of(context)
                                                          .size
                                                          .height *
                                                      0.06,
                                                  child: Padding(
                                                    padding: const EdgeInsets
                                                        .fromLTRB(15, 0, 13, 0),
                                                    child: Column(
                                                      children: [
                                                        Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                      .fromLTRB(
                                                                  0, 12, 0, 0),
                                                          child: Row(
                                                            children: [
                                                              Padding(
                                                                padding:
                                                                    const EdgeInsets
                                                                            .fromLTRB(
                                                                        20,
                                                                        0,
                                                                        0,
                                                                        2),
                                                                child: Container(
                                                                    width: MediaQuery.of(context)
                                                                            .size
                                                                            .width *
                                                                        0.66,
                                                                    child: Text(
                                                                        "delivery"
                                                                            .tr())),
                                                              ),
                                                              Container(
                                                                  // margin: EdgeInsets.only(left: 220),
                                                                  child: Text(Utility()
                                                                      .formatPrice(
                                                                          widget
                                                                              .delivery))),
                                                            ],
                                                          ),
                                                        ),
                                                        Stack(
                                                          children: [
                                                            Container(
                                                              width: MediaQuery.of(
                                                                          context)
                                                                      .size
                                                                      .width *
                                                                  0.90,
                                                              height: 10,
                                                              decoration: BoxDecoration(
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              4),
                                                                  color: AppTheme
                                                                      .colorLightGrey),
                                                            ),
                                                            AnimatedContainer(
                                                                duration:
                                                                    const Duration(
                                                                        milliseconds:
                                                                            400),
                                                                width: widget
                                                                            .delivery !=
                                                                        0
                                                                    ? MediaQuery.of(context)
                                                                            .size
                                                                            .width *
                                                                        (0.90 *
                                                                            widget
                                                                                .delivery /
                                                                            widget
                                                                                .totalValue)
                                                                    : widget
                                                                        .delivery,
                                                                height: 10,
                                                                decoration: BoxDecoration(
                                                                    borderRadius:
                                                                        BorderRadius
                                                                            .circular(
                                                                                6),
                                                                    color: Color(
                                                                        0xffdb1e24))),
                                                          ],
                                                        )
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                                CommonFileForIntervalReport(
                                                    totalPrice: collect,
                                                    color:
                                                        const Color(0xff924dc1),
                                                    title: "clickCollect".tr(),
                                                    gross: totalValue),
                                                CommonFileForIntervalReport(
                                                    totalPrice: point,
                                                    color:
                                                        const Color(0xff306f9a),
                                                    title: "pointOfSale".tr(),
                                                    gross: totalValue),
                                                CommonFileForIntervalReport(
                                                    totalPrice: uber,
                                                    color:
                                                        const Color(0xff57bd70),
                                                    title: "uberEats".tr(),
                                                    gross: totalValue),
                                                CommonFileForIntervalReport(
                                                    totalPrice: just,
                                                    color:
                                                        const Color(0xffff6d00),
                                                    title: "justEat".tr(),
                                                    gross: totalValue),
                                                CommonFileForIntervalReport(
                                                    totalPrice: deliveroo,
                                                    color:
                                                        const Color(0xff00d2bb),
                                                    title: "deliveroo".tr(),
                                                    gross: totalValue),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            // CommonInterval(),

                            SafeArea(
                              child: Container(
                                color: Colors.white,
                                height:
                                    MediaQuery.of(context).size.height * 0.94,
                                child: Padding(
                                  padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
                                  child: ListView(
                                    children: [
                                      SizedBox(
                                        height:
                                            MediaQuery.of(context).size.height *
                                                0.54,
                                        child: Card(
                                          color: Colors.white,
                                          surfaceTintColor: Colors.transparent,
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(20),
                                          ),
                                          elevation: 10,
                                          child: Column(
                                            children: [
                                              Transform.translate(
                                                  offset: Offset(
                                                      0,
                                                      MediaQuery.of(context)
                                                              .size
                                                              .height *
                                                          0.02),
                                                  child: Text(
                                                    "saleCategories".tr(),
                                                    style: const TextStyle(
                                                        fontSize: 18,
                                                        color:
                                                            AppTheme.colorRed,
                                                        fontWeight:
                                                            FontWeight.bold),
                                                  )),
                                              Expanded(
                                                child: charts.PieChart(
                                                    widget.series,
                                                    animate: true,
                                                    animationDuration:
                                                        const Duration(
                                                            seconds: 2),
                                                    defaultRenderer: charts
                                                        .ArcRendererConfig(
                                                            arcWidth: 100,
                                                            arcRendererDecorators: [
                                                          charts.ArcLabelDecorator(
                                                              labelPosition: charts
                                                                  .ArcLabelPosition
                                                                  .inside)
                                                        ])),
                                              ),
                                              Transform.translate(
                                                offset: Offset(
                                                    0,
                                                    -(MediaQuery.of(context)
                                                            .size
                                                            .height *
                                                        0.02)),
                                                child: Row(
                                                  children: [
                                                    Padding(
                                                      padding: EdgeInsets.fromLTRB(
                                                          25,
                                                          widget.chartDataCategories
                                                                          .length %
                                                                      2 ==
                                                                  0
                                                              ? 0
                                                              : 15,
                                                          0,
                                                          0),
                                                      child: SizedBox(
                                                          width: MediaQuery.of(
                                                                      context)
                                                                  .size
                                                                  .width *
                                                              0.42,
                                                          child:
                                                              widget.totalSales ==
                                                                      0
                                                                  ? Container()
                                                                  : Column(
                                                                      children: [
                                                                        for (var i =
                                                                                0;
                                                                            i < widget.chartDataCategories.length / 2;
                                                                            i++)
                                                                          Row(
                                                                            children: [
                                                                              Padding(
                                                                                padding: const EdgeInsets.fromLTRB(0, 0, 1, 0),
                                                                                child: Container(
                                                                                  margin: EdgeInsets.only(right: 3.0),
                                                                                  height: isLandscape ? MediaQuery.of(context).size.height * 0.02 : MediaQuery.of(context).size.height * 0.01,
                                                                                  width: 8,
                                                                                  decoration: BoxDecoration(
                                                                                    borderRadius: BorderRadius.circular(4),
                                                                                    color: widget.chartDataCategories[i].colors,
                                                                                  ),
                                                                                ),
                                                                              ),
                                                                              SizedBox(
                                                                                width: isLandscape ? MediaQuery.of(context).size.width * 0.21 : MediaQuery.of(context).size.width * 0.21,

                                                                                // width: MediaQuery.of(context).size.width * 0.12,
                                                                                child: Text(
                                                                                  '${widget.chartDataCategories[i].cat} ',
                                                                                  style: const TextStyle(fontSize: 12),
                                                                                ),
                                                                              ),
                                                                              // Utility().formatPrice(row.percentage)
                                                                              Padding(
                                                                                padding: const EdgeInsets.fromLTRB(2, 0, 0, 0),
                                                                                child: widget.totalSales != 0
                                                                                    ? Container(
                                                                                        child: ((widget.chartDataCategories[i].percentage)) < 10
                                                                                            ? Container(
                                                                                                margin: const EdgeInsets.only(left: 14),
                                                                                                child: Text(
                                                                                                  '${Utility().formatPrice(widget.chartDataCategories[i].percentage)}',
                                                                                                  style: const TextStyle(fontSize: 12),
                                                                                                ),
                                                                                              )
                                                                                            : Container(
                                                                                                child: ((widget.chartDataCategories[i].percentage / widget.totalSales) * 100) == 100
                                                                                                    ? Text(
                                                                                                        '${Utility().formatPrice(widget.chartDataCategories[i].percentage)}',
                                                                                                        style: const TextStyle(fontSize: 12),
                                                                                                      )
                                                                                                    : Container(
                                                                                                        margin: const EdgeInsets.only(left: 7),
                                                                                                        child: Text(
                                                                                                          '${Utility().formatPrice(widget.chartDataCategories[i].percentage)}',
                                                                                                          style: const TextStyle(fontSize: 12),
                                                                                                        ),
                                                                                                      ),
                                                                                              ),
                                                                                      )
                                                                                    : const Text("0%"),
                                                                              ),
                                                                            ],
                                                                          )
                                                                      ],
                                                                    )),
                                                    ),
                                                    Padding(
                                                      padding: EdgeInsets.fromLTRB(
                                                          0,
                                                          widget.chartDataCategories
                                                                          .length %
                                                                      2 ==
                                                                  0
                                                              ? 3
                                                              : 15,
                                                          10,
                                                          0),
                                                      child:
                                                          widget.totalSales == 0
                                                              ? Container()
                                                              : SizedBox(
                                                                  height: MediaQuery.of(
                                                                              context)
                                                                          .size
                                                                          .height *
                                                                      (0.015) *
                                                                      (widget.chartDataCategories.length /
                                                                              2)
                                                                          .round(),
                                                                  child:
                                                                      const VerticalDivider(
                                                                    thickness:
                                                                        1,
                                                                    width: 10,
                                                                    color: AppTheme
                                                                        .colorLightGrey,
                                                                  ),
                                                                ),
                                                    ),
                                                    Transform.translate(
                                                      offset:
                                                          const Offset(0, 0),
                                                      child: Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                    .fromLTRB(
                                                                8, 0, 0, 0),
                                                        child: SizedBox(
                                                            width: MediaQuery.of(
                                                                        context)
                                                                    .size
                                                                    .width *
                                                                0.39,
                                                            child:
                                                                widget.totalSales ==
                                                                        0
                                                                    ? Container()
                                                                    : Column(
                                                                        children: [
                                                                          for (var i = (widget.chartDataCategories.length / 2).round();
                                                                              i < widget.chartDataCategories.length;
                                                                              i++)
                                                                            Row(
                                                                              children: [
                                                                                Padding(
                                                                                  padding: const EdgeInsets.fromLTRB(0, 0, 1, 0),
                                                                                  child: Container(
                                                                                    margin: isLandscape ? const EdgeInsets.only(left: 92.0, right: 3.0) : const EdgeInsets.only(right: 3.0),
                                                                                    height: isLandscape ? MediaQuery.of(context).size.height * 0.02 : MediaQuery.of(context).size.height * 0.01,
                                                                                    width: 8,
                                                                                    decoration: BoxDecoration(
                                                                                      borderRadius: BorderRadius.circular(4),
                                                                                      color: widget.chartDataCategories[i].colors,
                                                                                    ),
                                                                                  ),
                                                                                ),
                                                                                SizedBox(
                                                                                  width: isLandscape ? MediaQuery.of(context).size.width * 0.22 : MediaQuery.of(context).size.width * 0.20,
                                                                                  child: Text(
                                                                                    '${widget.chartDataCategories[i].cat} ',
                                                                                    style: const TextStyle(fontSize: 12),
                                                                                  ),
                                                                                ),
                                                                                Padding(
                                                                                  padding: const EdgeInsets.fromLTRB(2, 0, 0, 0),
                                                                                  child: widget.totalSales != 0
                                                                                      ? Container(
                                                                                          child: ((widget.chartDataCategories[i].percentage / widget.totalSales) * 100) < 10
                                                                                              ? Container(
                                                                                                  margin: const EdgeInsets.only(left: 14),
                                                                                                  child: Text(
                                                                                                    '${Utility().formatPrice(widget.chartDataCategories[i].percentage)}',
                                                                                                    style: const TextStyle(fontSize: 12),
                                                                                                  ),
                                                                                                )
                                                                                              : Container(
                                                                                                  child: ((widget.chartDataCategories[i].percentage / widget.totalSales) * 100) == 100
                                                                                                      ? Text(
                                                                                                          '${Utility().formatPrice(widget.chartDataCategories[i].percentage)}',
                                                                                                          style: const TextStyle(fontSize: 12),
                                                                                                        )
                                                                                                      : Container(
                                                                                                          margin: const EdgeInsets.only(left: 7),
                                                                                                          child: Text(
                                                                                                            ' ${Utility().formatPrice(widget.chartDataCategories[i].percentage)}',
                                                                                                            style: const TextStyle(fontSize: 12),
                                                                                                          ),
                                                                                                        ),
                                                                                                ),
                                                                                        )
                                                                                      : const Text("0%"),
                                                                                ),
                                                                              ],
                                                                            )
                                                                        ],
                                                                      )),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      Padding(
                                        padding: EdgeInsets.only(
                                            bottom: MediaQuery.of(context)
                                                    .size
                                                    .height *
                                                0.20),
                                        child: SizedBox(
                                          height: MediaQuery.of(context)
                                                  .size
                                                  .height *
                                              0.62,
                                          child: Padding(
                                            padding: const EdgeInsets.fromLTRB(
                                                0, 0, 0, 15),
                                            child: Card(
                                              color: Colors.white,
                                              surfaceTintColor: Colors.transparent,
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(20),
                                              ),
                                              elevation: 15,
                                              child: Column(
                                                children: [
                                                  SizedBox(
                                                    height:
                                                        MediaQuery.of(context)
                                                                .size
                                                                .height *
                                                            0.35,
                                                    child: Padding(
                                                      padding: const EdgeInsets
                                                              .fromLTRB(
                                                          0, 14, 0, 0),
                                                      child: Stack(
                                                        children: [
                                                          Padding(
                                                            padding: EdgeInsets.fromLTRB(
                                                                MediaQuery.of(
                                                                            context)
                                                                        .size
                                                                        .height *
                                                                    0.08,
                                                                20,
                                                                0,
                                                                0),
                                                            child: Text(
                                                              "toP3ProductsSold"
                                                                  .tr(),
                                                              style: const TextStyle(
                                                                  fontSize: 18,
                                                                  color: AppTheme
                                                                      .colorRed,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold),
                                                            ),
                                                          ),
                                                          widget.topOneProduct ==
                                                                  0
                                                              ? Container()
                                                              : Center(
                                                                  child:
                                                                      Padding(
                                                                    padding:
                                                                        const EdgeInsets.fromLTRB(
                                                                            0,
                                                                            115,
                                                                            2,
                                                                            0),
                                                                    child:
                                                                        Column(
                                                                      children: [
                                                                        Padding(
                                                                          padding: const EdgeInsets.fromLTRB(
                                                                              5,
                                                                              0,
                                                                              0,
                                                                              5),
                                                                          child:
                                                                              SizedBox(
                                                                            width:
                                                                                MediaQuery.of(context).size.width * 0.34,
                                                                            // height:MediaQuery.of(context).size.height*0.046,
                                                                            child:
                                                                                Text(
                                                                              widget.productHighest[0].item,
                                                                              textAlign: TextAlign.center,
                                                                              style: const TextStyle(
                                                                                color: Color(0xff282828),
                                                                                fontWeight: FontWeight.normal,
                                                                                fontSize: 16,
                                                                              ),
                                                                            ),
                                                                          ),
                                                                        ),
                                                                        Padding(
                                                                          padding: const EdgeInsets.fromLTRB(
                                                                              0,
                                                                              0,
                                                                              0,
                                                                              5),
                                                                          child:
                                                                              Text(
                                                                            Utility().formatPrice(widget.productHighest[0].percentage),
                                                                            textAlign:
                                                                                TextAlign.center,
                                                                            style:
                                                                                const TextStyle(
                                                                              color: Color(0xffdb1e24),
                                                                              fontWeight: FontWeight.normal,
                                                                              fontSize: 14,
                                                                            ),
                                                                          ),
                                                                        ),
                                                                        Text(
                                                                          "${((widget.productHighest[0].quantity / widget.totalQantity) * 100).round()}%",
                                                                          textAlign:
                                                                              TextAlign.center,
                                                                          style:
                                                                              const TextStyle(
                                                                            color:
                                                                                Color(0xff282828),
                                                                            fontWeight:
                                                                                FontWeight.normal,
                                                                            fontSize:
                                                                                14,
                                                                          ),
                                                                        ),
                                                                      ],
                                                                    ),
                                                                  ),
                                                                ),
                                                          Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                        .fromLTRB(
                                                                    0,
                                                                    35,
                                                                    0,
                                                                    0),
                                                            child: Expanded(
                                                              child: charts.PieChart(
                                                                  widget
                                                                      .seriesProduct,
                                                                  animate:
                                                                      widget.topOneProduct ==
                                                                              0
                                                                          ? false
                                                                          : true,
                                                                  animationDuration:
                                                                      const Duration(
                                                                          seconds:
                                                                              2),
                                                                  defaultRenderer:
                                                                      charts.ArcRendererConfig(
                                                                          arcWidth:
                                                                              30,
                                                                          arcRendererDecorators: [
                                                                        // new charts.ArcLabelDecorator(
                                                                        //
                                                                        //     labelPosition: charts.ArcLabelPosition.inside)
                                                                      ])),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                  Transform.translate(
                                                    offset: Offset(
                                                        0,
                                                        -(MediaQuery.of(context)
                                                                .size
                                                                .height *
                                                            0.016)),
                                                    child: Container(
                                                      alignment:
                                                          Alignment.centerLeft,
                                                      // width: MediaQuery.of(context).size.width*0.,
                                                      child: Expanded(
                                                        child: Row(
                                                          children: [
                                                            Stack(
                                                              children: [
                                                                widget.topTwoProduct ==
                                                                        0
                                                                    ? Container()
                                                                    : Padding(
                                                                        padding: const EdgeInsets.fromLTRB(
                                                                            45,
                                                                            62,
                                                                            0,
                                                                            30),
                                                                        child:
                                                                            Center(
                                                                          child:
                                                                              Column(
                                                                            children: [
                                                                              Padding(
                                                                                padding: const EdgeInsets.fromLTRB(3, 0, 0, 3),
                                                                                child: SizedBox(
                                                                                  width: MediaQuery.of(context).size.width * 0.25,
                                                                                  // height:MediaQuery.of(context).size.height*0.046,
                                                                                  child: Text(
                                                                                    widget.productHighest1[0].item,
                                                                                    textAlign: TextAlign.center,
                                                                                    style: const TextStyle(
                                                                                      color: Color(0xff282828),
                                                                                      fontWeight: FontWeight.normal,
                                                                                      fontSize: 14,
                                                                                    ),
                                                                                  ),
                                                                                ),
                                                                              ),
                                                                              Padding(
                                                                                padding: const EdgeInsets.fromLTRB(0, 0, 0, 3),
                                                                                child: Text(
                                                                                  Utility().formatPrice(widget.productHighest1[0].percentage),
                                                                                  textAlign: TextAlign.center,
                                                                                  style: const TextStyle(
                                                                                    color: Color(0xffff6d00),
                                                                                    fontWeight: FontWeight.normal,
                                                                                    fontSize: 13,
                                                                                  ),
                                                                                ),
                                                                              ),
                                                                              Padding(
                                                                                padding: const EdgeInsets.fromLTRB(3, 0, 0, 0),
                                                                                child: Text(
                                                                                  "${((widget.productHighest1[0].quantity / widget.totalQantity) * 100).round()}%",
                                                                                  textAlign: TextAlign.center,
                                                                                  style: const TextStyle(
                                                                                    color: Color(0xff282828),
                                                                                    fontWeight: FontWeight.normal,
                                                                                    fontSize: 13,
                                                                                  ),
                                                                                ),
                                                                              ),
                                                                            ],
                                                                          ),
                                                                        ),
                                                                      ),
                                                                Padding(
                                                                  padding:
                                                                      const EdgeInsets
                                                                              .fromLTRB(
                                                                          7,
                                                                          0,
                                                                          0,
                                                                          0),
                                                                  child:
                                                                      SizedBox(
                                                                    height: MediaQuery.of(context)
                                                                            .size
                                                                            .height *
                                                                        0.233,
                                                                    width: MediaQuery.of(context)
                                                                            .size
                                                                            .width *
                                                                        0.47,
                                                                    child: charts.PieChart(
                                                                        widget
                                                                            .seriesProduct1,
                                                                        animate: widget.topTwoProduct ==
                                                                                0
                                                                            ? false
                                                                            : true,
                                                                        defaultRenderer: charts.ArcRendererConfig(
                                                                            arcWidth:
                                                                                15,
                                                                            arcRendererDecorators: [
                                                                              // new charts.ArcLabelDecorator(
                                                                              //
                                                                              //     labelPosition: charts.ArcLabelPosition.inside)
                                                                            ])),
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                            Stack(
                                                              children: [
                                                                widget.topThreeProduct ==
                                                                        0
                                                                    ? Container()
                                                                    : Padding(
                                                                        padding: const EdgeInsets.fromLTRB(
                                                                            35,
                                                                            62,
                                                                            38,
                                                                            30),
                                                                        child:
                                                                            Center(
                                                                          child:
                                                                              Container(
                                                                            child:
                                                                                Column(
                                                                              children: [
                                                                                Padding(
                                                                                  padding: const EdgeInsets.fromLTRB(3, 0, 0, 3),
                                                                                  child: Container(
                                                                                    width: MediaQuery.of(context).size.width * 0.25,
                                                                                    // height:MediaQuery.of(context).size.height*0.046,
                                                                                    child: Text(
                                                                                      widget.productHighest2[0].item,
                                                                                      textAlign: TextAlign.center,
                                                                                      style: const TextStyle(
                                                                                        color: Color(0xff282828),
                                                                                        fontWeight: FontWeight.normal,
                                                                                        fontSize: 14,
                                                                                      ),
                                                                                    ),
                                                                                  ),
                                                                                ),
                                                                                Padding(
                                                                                  padding: const EdgeInsets.fromLTRB(0, 0, 0, 3),
                                                                                  child: Text(
                                                                                    Utility().formatPrice(widget.productHighest2[0].percentage),
                                                                                    textAlign: TextAlign.center,
                                                                                    style: const TextStyle(
                                                                                      color: Color(0xffeabd3b),
                                                                                      fontWeight: FontWeight.normal,
                                                                                      fontSize: 13,
                                                                                    ),
                                                                                  ),
                                                                                ),
                                                                                Text(
                                                                                  "${((widget.productHighest2[0].quantity / widget.totalQantity) * 100).round()}%",
                                                                                  textAlign: TextAlign.center,
                                                                                  style: const TextStyle(
                                                                                    color: Color(0xff282828),
                                                                                    fontWeight: FontWeight.normal,
                                                                                    fontSize: 13,
                                                                                  ),
                                                                                ),
                                                                              ],
                                                                            ),
                                                                          ),
                                                                        ),
                                                                      ),
                                                                Transform
                                                                    .translate(
                                                                  offset:
                                                                      Offset(-5,
                                                                          0),
                                                                  child:
                                                                      SizedBox(
                                                                    height: MediaQuery.of(context)
                                                                            .size
                                                                            .height *
                                                                        0.233,
                                                                    width: MediaQuery.of(context)
                                                                            .size
                                                                            .width *
                                                                        0.47,
                                                                    child: charts.PieChart(
                                                                        widget
                                                                            .seriesProduct2,
                                                                        animate: widget.topThreeProduct ==
                                                                                0
                                                                            ? false
                                                                            : true,
                                                                        defaultRenderer: charts.ArcRendererConfig(
                                                                            arcWidth:
                                                                                15,
                                                                            arcRendererDecorators: [])),
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            // CategoryReport(),

                            //user report
                            SafeArea(
                              child: ListView(
                                children: [
                                  SizedBox(
                                    height: MediaQuery.of(context).size.height *
                                        (0.50 +
                                            widget.chartDataUsers.length / 100),
                                    child: Card(
                                      color: Colors.white,
                                      surfaceTintColor: Colors.transparent,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      elevation: 15,
                                      child: Padding(
                                        padding: const EdgeInsets.fromLTRB(
                                            0, 0, 0, 15),
                                        child: Column(
                                          children: [
                                            Transform.translate(
                                                offset: Offset(
                                                    0,
                                                    MediaQuery.of(context)
                                                            .size
                                                            .height *
                                                        0.015),
                                                child: Center(
                                                  child: Text(
                                                    "saleUsers".tr(),
                                                    style: const TextStyle(
                                                        fontSize: 18,
                                                        color:
                                                            AppTheme.colorRed,
                                                        fontWeight:
                                                            FontWeight.bold),
                                                  ),
                                                )),
                                            Expanded(
                                              child: Stack(
                                                children: [
                                                  SizedBox(
                                                      height:
                                                          MediaQuery.of(context)
                                                                  .size
                                                                  .height *
                                                              0.4,
                                                      child: CommonCategoryUser(
                                                          title: "saleUsers",
                                                          series: widget
                                                              .seriesForUsers)),
                                                  Column(
                                                    children: [
                                                      Row(
                                                        children: [
                                                          Padding(
                                                            padding: EdgeInsets.fromLTRB(
                                                                18,
                                                                MediaQuery.of(
                                                                            context)
                                                                        .size
                                                                        .height *
                                                                    0.41,
                                                                0,
                                                                0),
                                                            child: SizedBox(
                                                                width: MediaQuery.of(
                                                                            context)
                                                                        .size
                                                                        .width *
                                                                    0.40,
                                                                child: Column(
                                                                  children: [
                                                                    for (var i =
                                                                            0;
                                                                        i <
                                                                            widget.chartDataUsers.length /
                                                                                2;
                                                                        i++)
                                                                      Row(
                                                                        children: [
                                                                          Padding(
                                                                            padding: const EdgeInsets.fromLTRB(
                                                                                0,
                                                                                0,
                                                                                1,
                                                                                0),
                                                                            child:
                                                                                Container(
                                                                              margin: const EdgeInsets.only(right: 3.0),
                                                                              height: isLandscape ? MediaQuery.of(context).size.height * 0.02 : MediaQuery.of(context).size.height * 0.01,
                                                                              width: 8,
                                                                              decoration: BoxDecoration(
                                                                                borderRadius: BorderRadius.circular(4),
                                                                                color: widget.chartDataUsers[i].color,
                                                                              ),
                                                                            ),
                                                                          ),
                                                                          SizedBox(
                                                                            width: isLandscape
                                                                                ? MediaQuery.of(context).size.width * 0.20
                                                                                : MediaQuery.of(context).size.width * 0.2,

                                                                            // width: MediaQuery.of(context).size.width * 0.12,
                                                                            child:
                                                                                Text(
                                                                              '${widget.chartDataUsers[i].user} ',
                                                                              style: const TextStyle(fontSize: 12),
                                                                            ),
                                                                          ),
                                                                          Padding(
                                                                            padding: const EdgeInsets.fromLTRB(
                                                                                12,
                                                                                0,
                                                                                0,
                                                                                0),
                                                                            child:
                                                                                Text(
                                                                              Utility().formatPrice(widget.chartDataUsers[i].percentage),
                                                                              style: const TextStyle(fontSize: 12),
                                                                            ),
                                                                          ),
                                                                        ],
                                                                      )
                                                                  ],
                                                                )),
                                                          ),
                                                          Padding(
                                                            padding: EdgeInsets.fromLTRB(
                                                                10,
                                                                MediaQuery.of(
                                                                            context)
                                                                        .size
                                                                        .height *
                                                                    0.41,
                                                                10,
                                                                0),
                                                            child: SizedBox(
                                                              height: MediaQuery.of(
                                                                          context)
                                                                      .size
                                                                      .height *
                                                                  (0.017) *
                                                                  (widget.chartDataUsers
                                                                              .length /
                                                                          2)
                                                                      .round(),
                                                              child:
                                                                  const VerticalDivider(
                                                                thickness: 1,
                                                                width: 10,
                                                                color: AppTheme
                                                                    .colorLightGrey,
                                                              ),
                                                            ),
                                                          ),
                                                          Padding(
                                                            padding: EdgeInsets.fromLTRB(
                                                                5,
                                                                MediaQuery.of(
                                                                            context)
                                                                        .size
                                                                        .height *
                                                                    0.41,
                                                                0,
                                                                0),
                                                            child: SizedBox(
                                                                width: MediaQuery.of(
                                                                            context)
                                                                        .size
                                                                        .width *
                                                                    0.40,
                                                                child: Column(
                                                                  children: [
                                                                    for (var i =
                                                                            (widget.chartDataUsers.length / 2).round();
                                                                        i < widget.chartDataUsers.length;
                                                                        i++)
                                                                      Row(
                                                                        children: [
                                                                          Padding(
                                                                            padding: const EdgeInsets.fromLTRB(
                                                                                0,
                                                                                0,
                                                                                1,
                                                                                0),
                                                                            child:
                                                                                Container(
                                                                              margin: isLandscape ? const EdgeInsets.only(left: 92.0, right: 3.0) : const EdgeInsets.only(right: 3.0),
                                                                              height: isLandscape ? MediaQuery.of(context).size.height * 0.02 : MediaQuery.of(context).size.height * 0.01,
                                                                              width: 8,
                                                                              decoration: BoxDecoration(
                                                                                borderRadius: BorderRadius.circular(4),
                                                                                color: widget.chartDataUsers[i].color,
                                                                              ),
                                                                            ),
                                                                          ),
                                                                          SizedBox(
                                                                            width: isLandscape
                                                                                ? MediaQuery.of(context).size.width * 0.22
                                                                                : MediaQuery.of(context).size.width * 0.21,
                                                                            child:
                                                                                Text(
                                                                              '${widget.chartDataUsers[i].user} ',
                                                                              style: const TextStyle(fontSize: 12),
                                                                            ),
                                                                          ),
                                                                          Padding(
                                                                            padding: const EdgeInsets.fromLTRB(
                                                                                0,
                                                                                0,
                                                                                2,
                                                                                0),
                                                                            child:
                                                                                Text(
                                                                              Utility().formatPrice(widget.chartDataUsers[i].percentage),
                                                                              style: const TextStyle(fontSize: 12),
                                                                            ),
                                                                          ),
                                                                        ],
                                                                      )
                                                                  ],
                                                                )),
                                                          ),
                                                        ],
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding:
                                        const EdgeInsets.fromLTRB(0, 0, 0, 30),
                                    child: SizedBox(
                                      height:
                                          MediaQuery.of(context).size.height *
                                              0.53,
                                      child: Card(
                                        color: Colors.white,
                                        surfaceTintColor: Colors.transparent,
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(20),
                                        ),
                                        elevation: 15,
                                        child: Padding(
                                          padding: const EdgeInsets.fromLTRB(
                                              0, 0, 0, 15),
                                          child: Column(
                                            children: [
                                              Transform.translate(
                                                  offset: Offset(
                                                      0,
                                                      MediaQuery.of(context)
                                                              .size
                                                              .height *
                                                          0.015),
                                                  child: Center(
                                                    child: Text(
                                                      "deliveriesDeliveryMan"
                                                          .tr(),
                                                      style: const TextStyle(
                                                          fontSize: 18,
                                                          color:
                                                              AppTheme.colorRed,
                                                          fontWeight:
                                                              FontWeight.bold),
                                                    ),
                                                  )),
                                              Expanded(
                                                child: Stack(
                                                  children: [
                                                    SizedBox(
                                                        height: MediaQuery.of(
                                                                    context)
                                                                .size
                                                                .height *
                                                            0.4,
                                                        child: CommonCategoryUser(
                                                            title:
                                                                "deliveriesDeliveryMan",
                                                            series: widget
                                                                .seriesForDeliveryBoys)),
                                                    Column(
                                                      children: [
                                                        Row(
                                                          children: [
                                                            Padding(
                                                              padding: EdgeInsets.fromLTRB(
                                                                  18,
                                                                  MediaQuery.of(
                                                                              context)
                                                                          .size
                                                                          .height *
                                                                      0.41,
                                                                  0,
                                                                  0),
                                                              child: SizedBox(
                                                                  width: MediaQuery.of(
                                                                              context)
                                                                          .size
                                                                          .width *
                                                                      0.40,
                                                                  child: Column(
                                                                    crossAxisAlignment:
                                                                        CrossAxisAlignment
                                                                            .end,
                                                                    children: [
                                                                      for (var i =
                                                                              0;
                                                                          i < widget.chartDataDeliveryBoys.length / 2;
                                                                          i++)
                                                                        Row(
                                                                          children: [
                                                                            Padding(
                                                                              padding: const EdgeInsets.fromLTRB(0, 0, 1, 0),
                                                                              child: Container(
                                                                                margin: const EdgeInsets.only(right: 3.0),
                                                                                height: isLandscape ? MediaQuery.of(context).size.height * 0.02 : MediaQuery.of(context).size.height * 0.01,
                                                                                width: 8,
                                                                                decoration: BoxDecoration(
                                                                                  borderRadius: BorderRadius.circular(4),
                                                                                  color: widget.chartDataDeliveryBoys[i].color,
                                                                                ),
                                                                              ),
                                                                            ),
                                                                            SizedBox(
                                                                              width: MediaQuery.of(context).size.width * 0.31,

                                                                              // width: MediaQuery.of(context).size.width * 0.12,
                                                                              child: Text(
                                                                                '${widget.chartDataDeliveryBoys[i].user} ',
                                                                                style: const TextStyle(fontSize: 12),
                                                                              ),
                                                                            ),
                                                                            Padding(
                                                                              padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
                                                                              child: Text(
                                                                                widget.chartDataDeliveryBoys[i].countForSingleDeliveryBoy.toStringAsFixed(0),
                                                                                style: const TextStyle(fontSize: 12),
                                                                              ),
                                                                            ),
                                                                          ],
                                                                        )
                                                                    ],
                                                                  )),
                                                            ),
                                                            Padding(
                                                              padding: EdgeInsets.fromLTRB(
                                                                  6,
                                                                  MediaQuery.of(
                                                                              context)
                                                                          .size
                                                                          .height *
                                                                      0.41,
                                                                  10,
                                                                  0),
                                                              child: SizedBox(
                                                                height: MediaQuery.of(
                                                                            context)
                                                                        .size
                                                                        .height *
                                                                    (0.017) *
                                                                    (widget.chartDataDeliveryBoys.length /
                                                                            2)
                                                                        .round(),
                                                                child:
                                                                    const VerticalDivider(
                                                                  thickness: 1,
                                                                  width: 10,
                                                                  color: AppTheme
                                                                      .colorLightGrey,
                                                                ),
                                                              ),
                                                            ),
                                                            Padding(
                                                              padding: EdgeInsets.fromLTRB(
                                                                  5,
                                                                  MediaQuery.of(
                                                                              context)
                                                                          .size
                                                                          .height *
                                                                      0.41,
                                                                  0,
                                                                  0),
                                                              child: SizedBox(
                                                                  width: MediaQuery.of(
                                                                              context)
                                                                          .size
                                                                          .width *
                                                                      0.40,
                                                                  child: Column(
                                                                    children: [
                                                                      for (var i =
                                                                              (widget.chartDataDeliveryBoys.length / 2).round();
                                                                          i < widget.chartDataDeliveryBoys.length;
                                                                          i++)
                                                                        Row(
                                                                          children: [
                                                                            Padding(
                                                                              padding: const EdgeInsets.fromLTRB(0, 0, 1, 0),
                                                                              child: Container(
                                                                                margin: const EdgeInsets.only(right: 3.0),
                                                                                height: isLandscape ? MediaQuery.of(context).size.height * 0.02 : MediaQuery.of(context).size.height * 0.01,
                                                                                width: 8,
                                                                                decoration: BoxDecoration(
                                                                                  borderRadius: BorderRadius.circular(4),
                                                                                  color: widget.chartDataDeliveryBoys[i].color,
                                                                                ),
                                                                              ),
                                                                            ),
                                                                            SizedBox(
                                                                              width: MediaQuery.of(context).size.width * 0.28,
                                                                              child: Text(
                                                                                '${widget.chartDataDeliveryBoys[i].user} ',
                                                                                style: const TextStyle(fontSize: 12),
                                                                              ),
                                                                            ),
                                                                            Padding(
                                                                              padding: const EdgeInsets.fromLTRB(10, 0, 0, 0),
                                                                              child: Text(
                                                                                widget.chartDataDeliveryBoys[i].countForSingleDeliveryBoy.toStringAsFixed(0),
                                                                                style: const TextStyle(fontSize: 12),
                                                                              ),
                                                                            ),
                                                                          ],
                                                                        )
                                                                    ],
                                                                  )),
                                                            ),
                                                          ],
                                                        ),
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  )
                                ],
                              ),
                            ),
                            // UserOrdersReport(),

                            SizedBox(
                              height: MediaQuery.of(context).size.height * 0.6,
                              child: ListView(
                                children: [
                                  Card(
                                    color: Colors.white,
                                    surfaceTintColor: Colors.transparent,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    elevation: 15,
                                    child: Padding(
                                      padding: const EdgeInsets.fromLTRB(
                                          0, 0, 0, 28),
                                      child: Column(
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.fromLTRB(
                                                0, 15, 0, 10),
                                            child: Center(
                                              child: Text(
                                                "paymentDelivery".tr(),
                                                style: const TextStyle(
                                                    fontSize: 18,
                                                    color: AppTheme.colorRed,
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                            ),
                                          ),
                                          SizedBox(
                                            height: MediaQuery.of(context)
                                                    .size
                                                    .height *
                                                0.06,
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.fromLTRB(
                                                      15, 0, 13, 0),
                                              child: Column(
                                                children: [
                                                  Padding(
                                                    padding: const EdgeInsets
                                                        .fromLTRB(0, 12, 0, 0),
                                                    child: Row(
                                                      children: [
                                                        Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                      .fromLTRB(
                                                                  20, 0, 0, 2),
                                                          child: Container(
                                                              width: MediaQuery.of(
                                                                          context)
                                                                      .size
                                                                      .width *
                                                                  0.66,
                                                              child: Text(
                                                                  "cash".tr())),
                                                        ),
                                                        Container(
                                                            // margin: EdgeInsets.only(left: 220),
                                                            child: Text(Utility()
                                                                .formatPrice(
                                                                    widget
                                                                        .cash))),
                                                      ],
                                                    ),
                                                  ),
                                                  Stack(
                                                    children: [
                                                      Container(
                                                        width: MediaQuery.of(
                                                                    context)
                                                                .size
                                                                .width *
                                                            0.90,
                                                        height: 10,
                                                        decoration: BoxDecoration(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        4),
                                                            color: AppTheme
                                                                .colorLightGrey),
                                                      ),
                                                      AnimatedContainer(
                                                          duration:
                                                              const Duration(
                                                                  milliseconds:
                                                                      400),
                                                          width: widget.cash !=
                                                                  0
                                                              ? MediaQuery.of(
                                                                          context)
                                                                      .size
                                                                      .width *
                                                                  (0.90 *
                                                                      widget
                                                                          .cash /
                                                                      widget
                                                                          .totalValueP)
                                                              : widget.cash,
                                                          height: 10,
                                                          decoration: BoxDecoration(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          6),
                                                              color: Color(
                                                                  0xffdb1e24))),
                                                    ],
                                                  )
                                                ],
                                              ),
                                            ),
                                          ),
                                          SizedBox(
                                            height: MediaQuery.of(context)
                                                    .size
                                                    .height *
                                                0.06,
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.fromLTRB(
                                                      15, 0, 13, 0),
                                              child: Column(
                                                children: [
                                                  Padding(
                                                    padding: const EdgeInsets
                                                        .fromLTRB(0, 12, 0, 0),
                                                    child: Row(
                                                      children: [
                                                        Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                      .fromLTRB(
                                                                  20, 0, 0, 2),
                                                          child: Container(
                                                              width: MediaQuery.of(
                                                                          context)
                                                                      .size
                                                                      .width *
                                                                  0.66,
                                                              child: Text(
                                                                  "creditCard"
                                                                      .tr())),
                                                        ),
                                                        Container(
                                                            // margin: EdgeInsets.only(left: 220),
                                                            child: Text(Utility()
                                                                .formatPrice(widget
                                                                    .creditCard))),
                                                      ],
                                                    ),
                                                  ),
                                                  Stack(
                                                    children: [
                                                      Container(
                                                        width: MediaQuery.of(
                                                                    context)
                                                                .size
                                                                .width *
                                                            0.90,
                                                        height: 10,
                                                        decoration: BoxDecoration(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        4),
                                                            color: AppTheme
                                                                .colorLightGrey),
                                                      ),
                                                      AnimatedContainer(
                                                          duration:
                                                              const Duration(
                                                                  milliseconds:
                                                                      400),
                                                          width: widget
                                                                      .creditCard !=
                                                                  0
                                                              ? MediaQuery.of(
                                                                          context)
                                                                      .size
                                                                      .width *
                                                                  (0.90 *
                                                                      widget
                                                                          .creditCard /
                                                                      widget
                                                                          .totalValueP)
                                                              : widget
                                                                  .creditCard,
                                                          height: 10,
                                                          decoration: BoxDecoration(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          6),
                                                              color: Color(
                                                                  0xff9f0005))),
                                                    ],
                                                  )
                                                ],
                                              ),
                                            ),
                                          ),
                                          SizedBox(
                                            height: MediaQuery.of(context)
                                                    .size
                                                    .height *
                                                0.06,
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.fromLTRB(
                                                      15, 0, 13, 0),
                                              child: Column(
                                                children: [
                                                  Padding(
                                                    padding: const EdgeInsets
                                                        .fromLTRB(0, 12, 0, 0),
                                                    child: Row(
                                                      children: [
                                                        Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                      .fromLTRB(
                                                                  20, 0, 0, 2),
                                                          child: Container(
                                                              width: MediaQuery.of(
                                                                          context)
                                                                      .size
                                                                      .width *
                                                                  0.66,
                                                              child: Text(
                                                                  "mealVoucher"
                                                                      .tr())),
                                                        ),
                                                        Container(
                                                            // margin: EdgeInsets.only(left: 220),
                                                            child: Text(Utility()
                                                                .formatPrice(widget
                                                                    .mealVoucher))),
                                                      ],
                                                    ),
                                                  ),
                                                  Stack(
                                                    children: [
                                                      Container(
                                                        width: MediaQuery.of(
                                                                    context)
                                                                .size
                                                                .width *
                                                            0.90,
                                                        height: 10,
                                                        decoration: BoxDecoration(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        4),
                                                            color: AppTheme
                                                                .colorLightGrey),
                                                      ),
                                                      AnimatedContainer(
                                                          duration:
                                                              const Duration(
                                                                  milliseconds:
                                                                      400),
                                                          width: widget
                                                                      .mealVoucher !=
                                                                  0
                                                              ? MediaQuery.of(
                                                                          context)
                                                                      .size
                                                                      .width *
                                                                  (0.90 *
                                                                      widget
                                                                          .mealVoucher /
                                                                      widget
                                                                          .totalValueP)
                                                              : widget
                                                                  .mealVoucher,
                                                          height: 10,
                                                          decoration: BoxDecoration(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          6),
                                                              color: Color(
                                                                  0xffed8e91))),
                                                    ],
                                                  )
                                                ],
                                              ),
                                            ),
                                          ),
                                          SizedBox(
                                            height: MediaQuery.of(context)
                                                    .size
                                                    .height *
                                                0.06,
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.fromLTRB(
                                                      15, 0, 13, 0),
                                              child: Column(
                                                children: [
                                                  Padding(
                                                    padding: const EdgeInsets
                                                        .fromLTRB(0, 12, 0, 0),
                                                    child: Row(
                                                      children: [
                                                        Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                      .fromLTRB(
                                                                  20, 0, 0, 2),
                                                          child: Container(
                                                              width: MediaQuery.of(
                                                                          context)
                                                                      .size
                                                                      .width *
                                                                  0.66,
                                                              child: Text(
                                                                  "cheque"
                                                                      .tr())),
                                                        ),
                                                        Container(
                                                            // margin: EdgeInsets.only(left: 220),
                                                            child: Text(Utility()
                                                                .formatPrice(widget
                                                                    .cheque))),
                                                      ],
                                                    ),
                                                  ),
                                                  Stack(
                                                    children: [
                                                      Container(
                                                        width: MediaQuery.of(
                                                                    context)
                                                                .size
                                                                .width *
                                                            0.90,
                                                        height: 10,
                                                        decoration: BoxDecoration(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        4),
                                                            color: AppTheme
                                                                .colorLightGrey),
                                                      ),
                                                      AnimatedContainer(
                                                          duration:
                                                              const Duration(
                                                                  milliseconds:
                                                                      400),
                                                          width: widget
                                                                      .cheque !=
                                                                  0
                                                              ? MediaQuery.of(
                                                                          context)
                                                                      .size
                                                                      .width *
                                                                  (0.90 *
                                                                      widget
                                                                          .cheque /
                                                                      widget
                                                                          .totalValueP)
                                                              : widget.cheque,
                                                          height: 10,
                                                          decoration: BoxDecoration(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          6),
                                                              color: Color(
                                                                  0xff924dc1))),
                                                    ],
                                                  )
                                                ],
                                              ),
                                            ),
                                          ),
                                          SizedBox(
                                            height: MediaQuery.of(context)
                                                    .size
                                                    .height *
                                                0.06,
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.fromLTRB(
                                                      15, 0, 13, 0),
                                              child: Column(
                                                children: [
                                                  Padding(
                                                    padding: const EdgeInsets
                                                        .fromLTRB(0, 12, 0, 0),
                                                    child: Row(
                                                      children: [
                                                        Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                      .fromLTRB(
                                                                  20, 0, 0, 2),
                                                          child: Container(
                                                              width: MediaQuery.of(
                                                                          context)
                                                                      .size
                                                                      .width *
                                                                  0.66,
                                                              child: Text(
                                                                  "platform"
                                                                      .tr())),
                                                        ),
                                                        Container(
                                                            // margin: EdgeInsets.only(left: 220),
                                                            child: Text(Utility()
                                                                .formatPrice(widget
                                                                    .platform))),
                                                      ],
                                                    ),
                                                  ),
                                                  Stack(
                                                    children: [
                                                      Container(
                                                        width: MediaQuery.of(
                                                                    context)
                                                                .size
                                                                .width *
                                                            0.90,
                                                        height: 10,
                                                        decoration: BoxDecoration(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        4),
                                                            color: AppTheme
                                                                .colorLightGrey),
                                                      ),
                                                      AnimatedContainer(
                                                          duration:
                                                              const Duration(
                                                                  milliseconds:
                                                                      400),
                                                          width: widget
                                                                      .platform !=
                                                                  0
                                                              ? MediaQuery.of(
                                                                          context)
                                                                      .size
                                                                      .width *
                                                                  (0.90 *
                                                                      widget
                                                                          .platform /
                                                                      widget
                                                                          .totalValueP)
                                                              : widget.platform,
                                                          height: 10,
                                                          decoration: BoxDecoration(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          6),
                                                              color: Color(
                                                                  0xff306f9a))),
                                                    ],
                                                  )
                                                ],
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
                            // PaymentReport(),
                          ]))
                ]),
              )),
        ],
      ),
    );
  }

  List<OrderData> getChartData() {
    _chartDataDeliveryBoy = [
      OrderData("Delivery Boy 1", 10, const Color(0xffff6d00),
          charts.ColorUtil.fromDartColor(const Color(0xffff6d00)), 20, 0),
      OrderData("Delivery Boy 2", 5, const Color(0xff924dc1),
          charts.ColorUtil.fromDartColor(const Color(0xff924dc1)), 20, 0),
      OrderData("Delivery Boy 3", 5, const Color(0xff57bd70),
          charts.ColorUtil.fromDartColor(const Color(0xff57bd70)), 20, 0),
    ];
    seriesForDeliveryBoy = [
      charts.Series(
        id: "Category",
        data: _chartDataDeliveryBoy,
        labelAccessorFn: (OrderData row, _) =>
            '${((row.percentage * 100 / row.total)).round()}%',
        domainFn: (OrderData series, _) => series.user,
        measureFn: (OrderData series, _) => series.percentage,
        colorFn: (OrderData series, _) => series.colors,
        radiusPxFn: (OrderData series, _) => series.total,
      )
    ];

    return _chartData;
  }
}
