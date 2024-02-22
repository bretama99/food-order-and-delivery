import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:opti_food_app/screens/report/category_report.dart';
import 'package:opti_food_app/screens/report/search_form.dart';
import '../../utils/utility.dart';
import '../../widgets/app_theme.dart';
import 'package:charts_flutter/flutter.dart' as charts;

import 'interval_report.dart';
import '../MountedState.dart';
class CommonCategoryUser extends StatefulWidget {
  final String title;
  final List<charts.Series<OrderData, String>> series;
  const CommonCategoryUser({Key? key, required this.title, required this.series}) : super(key: key);

  @override
  State<CommonCategoryUser> createState() => _CommonCategoryUserState();
}

class _CommonCategoryUserState extends MountedState<CommonCategoryUser> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(2, 7, 0, 0),
      child: Expanded(
        child: charts.PieChart(widget.series,
            animate: true,
            animationDuration: const Duration(seconds: 2),
            defaultRenderer: charts.ArcRendererConfig(
                arcWidth: 80,
                arcRendererDecorators: [
                  charts.ArcLabelDecorator(
                    labelPosition: charts.ArcLabelPosition.inside,

                  )
                ]
            )
        ),
      ),
    );
  }
}
