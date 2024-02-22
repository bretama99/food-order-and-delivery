import 'package:flutter/material.dart';

import '../../utils/utility.dart';
import '../../widgets/app_theme.dart';import '../MountedState.dart';
class CommonFileForIntervalReport extends StatefulWidget {
  final Color color;
  final String title;
  final double totalPrice;
  final double gross;
  const CommonFileForIntervalReport({Key? key, required this.color, required this.title, required this.totalPrice, required this.gross}) : super(key: key);

  @override
  State<CommonFileForIntervalReport> createState() => _CommonFileForIntervalReportState();
}

class _CommonFileForIntervalReportState extends MountedState<CommonFileForIntervalReport> {
  double _width = 0;

  @override
  void initState() {
    _width = 0;
    super.initState();
    Future.delayed(const Duration(milliseconds: 500), () {
      setState(() {
        _width = widget.totalPrice;
      });
    });
  }
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: MediaQuery.of(context).size.height*0.06,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(15, 0, 13, 0),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(0, 12, 0, 0),
              child: Row(
                children:  [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 0, 2),
                    child: Container(
                        width: MediaQuery.of(context).size.width*0.66,
                        child: Text(widget.title)),
                  ),
                  Container(
                      // margin: EdgeInsets.only(left: 220),
                      child: Text(Utility().formatPrice(widget.totalPrice))),
                ],
              ),
            ),
            Stack(
              children: [
                Container(
                  width:MediaQuery.of(context).size.width*0.90,
                  height: 10,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(4),
                      color: AppTheme.colorLightGrey),
                ),
                AnimatedContainer(
                    duration: const Duration(milliseconds: 400),
                    width: _width!=0?MediaQuery.of(context).size.width*(0.90*_width/widget.gross):_width,
                    height: 10,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(6),
                        color: widget.color)),
              ],
            )
          ],
        ),
      ),
    );
  }
}
