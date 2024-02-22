import 'dart:ffi';
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:flutter/material.dart';
import 'package:opti_food_app/data_models/order_model.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../utils/utility.dart';
import '../../widgets/app_theme.dart';
import '../../widgets/appbar/app_bar_optifood.dart';
import 'common_for_category_user.dart';
import '../MountedState.dart';
class CategoryReport extends StatefulWidget {
  // final bool isFilterActivated;
  // final Future<List<OrderModel>> orderList;
  final List<CategoryData> chartDataCategories;
  final List<charts.Series<CategoryData, String>> series;
  final double totalSales;
  final List<charts.Series<ItemData, String>> seriesProduct;
  final List<charts.Series<ItemData, String>> seriesProduct1;
  final List<charts.Series<ItemData, String>> seriesProduct2;
  final int topOneProduct;
  final int topTwoProduct;
  final int topThreeProduct;
  final List<ItemData> productHighest;
  final List<ItemData> productHighest1;
  final List<ItemData> productHighest2;
  final int totalQantity;
  const CategoryReport(this.chartDataCategories, this.series,this.totalSales, this.seriesProduct, this.seriesProduct1,
      this.seriesProduct2, this.topOneProduct, this.topTwoProduct, this.topThreeProduct,
  this.productHighest, this.productHighest1, this.productHighest2, this.totalQantity, {Key? key}) : super(key: key);

  @override
  State<CategoryReport> createState() => _CategoryReportState();
}

class _CategoryReportState extends MountedState<CategoryReport> {
  int totalSales = 5000;
  late List<CategoryData> _chartDataCategories = [];
  late List<ProductData> _productHighest = [];
  late List<charts.Series<ProductData, String>> seriesProduct = [];

  late List<ProductData> _productHighest1 = [];
  late List<charts.Series<ProductData, String>> seriesProduct1 = [];
  late List<ProductData> _productHighest2 = [];
  late List<charts.Series<ProductData, String>> seriesProduct2 = [];

  late List<charts.Series<CategoryData, String>> series = [];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getChartData();
    getChartDataProduct();

  }
  @override
  Widget build(BuildContext context) {
    final isLandscape = MediaQuery.of(context).orientation == Orientation.landscape;
    return Scaffold(
      body: Padding(
        padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
        child: SafeArea(
          child: Container(
            color: Colors.white,
            height: MediaQuery.of(context).size.height*0.94,

            child: Padding(
              padding:  EdgeInsets.fromLTRB(0, 0, 0, 0),
              child: ListView(
                children: [
                  SizedBox(
                    height: MediaQuery.of(context).size.height*0.54,
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
                              offset:Offset(0,MediaQuery.of(context).size.height*0.02),
                              child: Text(
                                "saleCategories".tr(),
                                style: const TextStyle(
                                    fontSize: 18,
                                    color:
                                    AppTheme.colorRed,
                                    fontWeight: FontWeight.bold),
                              )),
                          widget.totalSales==0?Padding(
                            padding: const EdgeInsets.fromLTRB(0, 20, 0, 0),
                            child: SizedBox(
                              height: MediaQuery.of(context).size.height*0.4,
                              child: Expanded(
                                child: charts.PieChart(widget.series,
                                    animate: false,
                                    defaultRenderer: charts.ArcRendererConfig(
                                              arcWidth: 80,
                                          )
                                ),
                              ),
                            ),
                          )
                              :Expanded(
                            child: charts.PieChart(widget.series,

                                animate: true,
                                animationDuration: const Duration(seconds: 2),
                                defaultRenderer: charts.ArcRendererConfig(
                                    arcWidth: 100,
                                    arcRendererDecorators: [
                                      charts.ArcLabelDecorator(
                                          labelPosition: charts.ArcLabelPosition.inside
                                      )
                                    ]
                                )
                            ),
                          ),
                          Transform.translate(
                            offset: Offset(0, -(MediaQuery.of(context).size.height*0.02)),
                            child: Row(
                              children: [
                                Padding(
                                  padding: EdgeInsets
                                      .fromLTRB(
                                      25,widget.chartDataCategories.length%2==0?0:0, 0, 0),
                                  child: SizedBox(
                                      width: MediaQuery.of(
                                          context)
                                          .size
                                          .width *
                                          0.42,
                                      child: widget.totalSales==0?Container():Column(
                                        children: [
                                          for (var i = 0; i < widget.chartDataCategories.length/2;
                                          i++) Row(
                                            children: [
                                              Padding(
                                                padding: const EdgeInsets.fromLTRB(0, 0, 1, 0),
                                                child: Container(
                                                  margin: EdgeInsets.only(right: 3.0),

                                                  height: isLandscape?MediaQuery.of(context).size.height * 0.02:MediaQuery.of(context).size.height * 0.01,
                                                  width: 8,
                                                  decoration: BoxDecoration(
                                                    borderRadius: BorderRadius.circular(4),
                                                    color: widget.chartDataCategories[i].colors,
                                                  ),
                                                ),
                                              ),
                                              SizedBox(
                                                width: isLandscape?MediaQuery.of(context).size.width * 0.21:MediaQuery.of(context).size.width * 0.245,

                                                // width: MediaQuery.of(context).size.width * 0.12,
                                                child: Text(
                                                  '${widget.chartDataCategories[i].cat} ',
                                                  style: const TextStyle(fontSize: 12),
                                                ),
                                              ),
                                              Padding(
                                                padding: const EdgeInsets.fromLTRB(2, 0, 0, 0),
                                                child: widget.totalSales != 0
                                                    ? Container(
                                                  child: ((widget.chartDataCategories[i].percentage/widget.totalSales)*100) < 10
                                                      ? Container(
                                                    margin: const EdgeInsets.only(left: 14),

                                                    child: Text(
                                                      '${((widget.chartDataCategories[i].percentage/widget.totalSales)*100).round()}%',
                                                      style: const TextStyle(fontSize: 12),
                                                    ),
                                                  )
                                                      : Container(
                                                    child: ((widget.chartDataCategories[i].percentage/widget.totalSales)*100) == 100
                                                        ? Text(
                                                      '${((widget.chartDataCategories[i].percentage/widget.totalSales)*100).round()}%',
                                                      style: const TextStyle(fontSize: 12),
                                                    )
                                                        : Container(
                                                      margin: const EdgeInsets.only(left: 7),

                                                      child: Text(
                                                        '${((widget.chartDataCategories[i].percentage/widget.totalSales)*100).round()}%',
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
                                      )
                                  ),
                                ),
                                Padding(
                                  padding: EdgeInsets
                                      .fromLTRB(
                                      0, widget.chartDataCategories.length%2==0?3:15, 10, 0),
                                  child: widget.totalSales==0?Container():SizedBox(
                                    height: MediaQuery.of(context).size.height*(0.015)*(widget.chartDataCategories.length/2).round(),
                                    child: const VerticalDivider(
                                      thickness: 1,
                                      width: 10,
                                      color: AppTheme
                                          .colorLightGrey,
                                    ),
                                  ),
                                ),
                                Transform.translate(
                                  offset: const Offset(0, 0),
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
                                        child: widget.totalSales==0?Container():Column(
                                          children: [
                                            for (var i = (widget.chartDataCategories
                                                .length/2).round();
                                            i <
                                                widget.chartDataCategories
                                                    .length;
                                            i++)
                                              Row(
                                                children: [
                                                  Padding(
                                                    padding: const EdgeInsets.fromLTRB(0, 0, 1, 0),
                                                    child: Container(
                                                      margin: isLandscape? const EdgeInsets.only(left: 92.0,right: 3.0):const EdgeInsets.only(right: 3.0),

                                                      height: isLandscape?MediaQuery.of(context).size.height * 0.02:MediaQuery.of(context).size.height * 0.01,
                                                      width: 8,
                                                      decoration: BoxDecoration(
                                                        borderRadius: BorderRadius.circular(4),
                                                        color: widget.chartDataCategories[i].colors,
                                                      ),
                                                    ),
                                                  ),
                                                  SizedBox(
                                                    width: isLandscape?MediaQuery.of(context).size.width * 0.22:MediaQuery.of(context).size.width * 0.22,

                                                    child: Text(
                                                      '${widget.chartDataCategories[i].cat} ',
                                                      style: const TextStyle(fontSize: 12),
                                                    ),
                                                  ),
                                                  Padding(
                                                    padding: const EdgeInsets.fromLTRB(2, 0, 0, 0),
                                                    child: widget.totalSales != 0
                                                        ? Container(
                                                      child: ((widget.chartDataCategories[i].percentage/widget.totalSales)*100) < 10
                                                          ? Container(
                                                        margin: const EdgeInsets.only(left: 14),

                                                        child: Text(
                                                          '${((widget.chartDataCategories[i].percentage/widget.totalSales)*100).round()}%',
                                                          style: const TextStyle(fontSize: 12),
                                                        ),
                                                      )
                                                          : Container(
                                                        child: ((widget.chartDataCategories[i].percentage/widget.totalSales)*100) == 100
                                                            ? Text(
                                                          '${((widget.chartDataCategories[i].percentage/widget.totalSales)*100).round()}%',
                                                          style: const TextStyle(fontSize: 12),
                                                        )
                                                            : Container(
                                                          margin: const EdgeInsets.only(left: 7),

                                                          child: Text(
                                                            ' ${((widget.chartDataCategories[i].percentage/widget.totalSales)*100).round()}%',
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
                                        )
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  SizedBox(
                    height: MediaQuery.of(context).size.height*0.62,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(0, 0, 0, 15),
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
                              height: MediaQuery.of(context).size.height*0.35,
                              child: Padding(
                                padding: const EdgeInsets.fromLTRB(0, 14, 0, 0),
                                child: Stack(
                                  children: [
                                    Padding(
                                      padding: EdgeInsets.fromLTRB(MediaQuery.of(context).size.height*0.11, 20, 0, 0),
                                      child: Text("toP3ProductsSoldpppppppppp".tr(), style: const TextStyle(                              fontSize: 18,
                                          color:
                                          AppTheme.colorRed,
                                          fontWeight: FontWeight.bold),),
                                    ),
                                    widget.topOneProduct==0?Container():Center(
                                      child: Padding(
                                        padding: const EdgeInsets.fromLTRB(0, 115, 2, 0),
                                        child: Column(
                                          children: [
                                            Padding(
                                              padding: const EdgeInsets.fromLTRB(5, 0, 0, 5),
                                              child: SizedBox(
                                                width: MediaQuery.of(context).size.width*0.34,
                                                // height:MediaQuery.of(context).size.height*0.046,
                                                child: Text(widget.productHighest[0].item,
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
                                              padding: const EdgeInsets.fromLTRB(0, 0, 0, 5),
                                              child: Text("mmmmmmmm",
                                                textAlign: TextAlign.center,
                                                style: const TextStyle(
                                                  color: Color(0xffdb1e24),
                                                  fontWeight: FontWeight.normal,
                                                  fontSize: 14,
                                                ),
                                              ),
                                            ),
                                            Text("${(widget.productHighest[0].quantity)}%",
                                              textAlign: TextAlign.center,
                                              style: const TextStyle(
                                                color: Color(0xff282828),
                                                fontWeight: FontWeight.normal,
                                                fontSize: 14,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.fromLTRB(0, 35, 0, 0),
                                      child: Expanded(
                                        child: charts.PieChart(widget.seriesProduct,
                                            animate: widget.topOneProduct==0?false:true,
                                            animationDuration: const Duration(seconds: 2),
                                            defaultRenderer: charts.ArcRendererConfig(
                                                arcWidth: 30,
                                                arcRendererDecorators: [
                                                  // new charts.ArcLabelDecorator(
                                                  //
                                                  //     labelPosition: charts.ArcLabelPosition.inside)
                                                ])
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            Transform.translate(
                              offset: Offset(0, -(MediaQuery.of(context).size.height*0.016)),
                              child: Container(
                                alignment: Alignment.centerLeft,
                                // width: MediaQuery.of(context).size.width*0.,
                                child: Expanded(
                                  child: Row(
                                    children: [
                                      Stack(
                                        children: [
                                          widget.topTwoProduct==0?Container()
                                              :Padding(
                                            padding: const EdgeInsets.fromLTRB(45, 62, 0, 30),
                                            child: Center(
                                              child: Column(
                                                children: [
                                                  Padding(
                                                    padding: const EdgeInsets.fromLTRB(3, 0, 0, 3),
                                                    child: SizedBox(
                                                      width: MediaQuery.of(context).size.width*0.25,
                                                      // height:MediaQuery.of(context).size.height*0.046,
                                                      child: Text(widget.productHighest1[0].item,
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
                                                    child: Text(Utility().formatPrice(widget.productHighest1[0].percentage),
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
                                                    child: Text("${((widget.productHighest1[0].percentage/widget.totalSales)*100).round()}%",
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
                                            padding: const EdgeInsets.fromLTRB(7, 0, 0, 0),
                                            child: SizedBox(
                                              height:MediaQuery.of(context).size.height*0.233,
                                              width: MediaQuery.of(context).size.width*0.47,
                                              child:  charts.PieChart(widget.seriesProduct1,
                                                  animate: widget.topTwoProduct==0?false:true,
                                                  defaultRenderer: charts.ArcRendererConfig(
                                                      arcWidth: 15,

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
                                          widget.topThreeProduct==0?Container():Padding(
                                            padding: const EdgeInsets.fromLTRB(35, 62, 38, 30),
                                            child: Center(
                                              child: Container(
                                                child: Column(
                                                  children: [
                                                    Padding(
                                                      padding: const EdgeInsets.fromLTRB(3, 0, 0, 3),
                                                      child: Container(
                                                        width: MediaQuery.of(context).size.width*0.25,
                                                        // height:MediaQuery.of(context).size.height*0.046,
                                                        child: Text(widget.productHighest2[0].item,
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
                                                      child: Text(Utility().formatPrice(widget.productHighest2[0].percentage),
                                                        textAlign: TextAlign.center,

                                                        style: const TextStyle(
                                                          color: Color(0xff306f9a),
                                                          fontWeight: FontWeight.normal,
                                                          fontSize: 13,
                                                        ),
                                                      ),
                                                    ),
                                                    Text("${((widget.productHighest2[0].percentage/widget.totalSales)*100).round()}%",
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

                                          Transform.translate(
                                            offset: Offset(-5, 0),
                                            child: SizedBox(
                                              height:MediaQuery.of(context).size.height*0.233,
                                              width: MediaQuery.of(context).size.width*0.47,
                                              child:  charts.PieChart(widget.seriesProduct2,
                                                  animate:widget.topThreeProduct==0?false:true,
                                                  defaultRenderer: charts.ArcRendererConfig(
                                                      arcWidth: 15,
                                                      arcRendererDecorators: [
                                                      ])),
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
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
  double totalCategories=0;
  double topOneProduct=0;
  double topTwoProduct=0;
  double topThreeProduct=0;
  getChartDataProduct(){
    _productHighest = [
      ProductData("Product one", charts.ColorUtil.fromDartColor(const Color(0xffdb1e24)), const Color(0xffdb1e24), 5000, topOneProduct),
      ProductData("Product two", charts.ColorUtil.fromDartColor(const Color(0xffe6e6e6)), const Color(0xffe6e6e6), 5000, 5000)
    ];

    seriesProduct = [
      charts.Series(
        id: "Category",
        displayName: "m",
        data: _productHighest,
        labelAccessorFn: (ProductData row, _) => Utility().formatPrice(row.percentage),
        domainFn: (ProductData series, _) => series.item,
        measureFn: (ProductData series, _) => series.percentage,
        colorFn: (ProductData series, _) => series.color,
        radiusPxFn:(ProductData series, _) => series.percentage,

      )
    ];

    _productHighest1 = [
      ProductData("Product two", charts.ColorUtil.fromDartColor(const Color(0xffff6d00)), const Color(0xffff6d00), 5000, topTwoProduct),
      ProductData("Product three", charts.ColorUtil.fromDartColor(const Color(0xffe6e6e6)), const Color(0xffe6e6e6), 5000, 5000)
    ];

    seriesProduct1 = [
      charts.Series(
        id: "Category",
        displayName: "m",
        data: _productHighest1,
        labelAccessorFn: (ProductData row, _) => Utility().formatPrice(row.percentage),
        domainFn: (ProductData series, _) => series.item,
        measureFn: (ProductData series, _) => series.percentage,
        colorFn: (ProductData series, _) => series.color,
        radiusPxFn:(ProductData series, _) => series.percentage,

      )
    ];

    _productHighest2 = [
      ProductData("Product three", charts.ColorUtil.fromDartColor(const Color(0xff306f9a)), const Color(0xff306f9a), 10000, topTwoProduct),
      ProductData("Product four", charts.ColorUtil.fromDartColor(const Color(0xffe6e6e6)), const Color(0xffe6e6e6), 10000, 10000)
    ];

    seriesProduct2 = [
      charts.Series(
        id: "Category",
        displayName: "m",
        data: _productHighest2,
        labelAccessorFn: (ProductData row, _) => Utility().formatPrice(row.percentage),
        domainFn: (ProductData series, _) => series.item,
        measureFn: (ProductData series, _) => series.percentage,
        colorFn: (ProductData series, _) => series.color,
        radiusPxFn:(ProductData series, _) => series.percentage,

      )
    ];
    return _productHighest;
  }
  List<CategoryData> getChartData() {
    if(totalCategories==0){
      _chartDataCategories = [
        CategoryData("Cat one", charts.ColorUtil.fromDartColor(const Color(0xffe6e6e6)), const Color(0xffe6e6e6), 6000, 4000),
      ];
      series = [
        charts.Series(
          id: "Category",
          data: _chartDataCategories,
          // labelAccessorFn: (CategoryData row, _) => Utility().formatPrice(0),
          domainFn: (CategoryData series, _) => series.cat,
          measureFn: (CategoryData series, _) => series.percentage,
          colorFn: (CategoryData series, _) => series.color,
          radiusPxFn:(CategoryData series, _) => series.percentage,

        )
      ];
    }
    else {
      _chartDataCategories = [
        CategoryData("Cat one", charts.ColorUtil.fromDartColor(const Color(0xff57bd70)), const Color(0xff57bd70), 6000, 2000),
        CategoryData("Cat two ", charts.ColorUtil.fromDartColor(const Color(0xff924dc1)), const Color(0xff924dc1), 6000, 500),
        CategoryData("Cat three", charts.ColorUtil.fromDartColor(const Color(0xff306f9a)), const Color(0xff306f9a), 6000, 500),
        CategoryData("Cat four", charts.ColorUtil.fromDartColor(const Color(0xffdb1e24)), const Color(0xffdb1e24), 6000, 1000),
        CategoryData("Cat five", charts.ColorUtil.fromDartColor(const Color(0xff00d2bb)), const Color(0xff00d2bb), 6000, 1000),
        CategoryData("Cat six", charts.ColorUtil.fromDartColor(const Color(0xffff6d00)), const Color(0xffff6d00), 6000, 1000),

      ];
      series = [
        charts.Series(
          id: "Category",
          displayName: "m",
          data: _chartDataCategories,
          labelAccessorFn: (CategoryData row, _) => Utility().formatPrice(row.percentage),
          domainFn: (CategoryData series, _) => series.cat,
          measureFn: (CategoryData series, _) => series.percentage,
          colorFn: (CategoryData series, _) => series.color,
          radiusPxFn:(CategoryData series, _) => series.percentage,

        )
      ];
    }


    return _chartDataCategories;
  }

}

class CategoryData {
  late final String cat;
  final charts.Color color;
  final Color colors;
  final double totalSale;
  late double percentage;
  CategoryData(this.cat, this.color, this.colors, this.totalSale, this.percentage);
}

class ProductData {
  late final String item;
  final charts.Color color;
  final Color colors;
  final double totalSale;
  late double percentage;
  ProductData(this.item, this.color, this.colors, this.totalSale, this.percentage);
}

class ItemData {
  late final String item;
  final charts.Color color;
  final Color colors;
  final double totalSale;
  late double percentage;
  late int quantity;
  ItemData(this.item, this.color, this.colors, this.totalSale, this.percentage,this.quantity);
}
