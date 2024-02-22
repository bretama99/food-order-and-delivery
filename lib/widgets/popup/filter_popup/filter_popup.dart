import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:opti_food_app/main.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../assets/images.dart';
import '../../app_theme.dart';

class FilterPopup extends StatefulWidget{
  Widget child;
  double height;
  bool isFilterActivated;
  FilterPopup({required this.child,this.height=260, this.isFilterActivated=false});
  @override
  State<StatefulWidget> createState() => FilterPopupState();

}
class FilterPopupState extends State<FilterPopup> with SingleTickerProviderStateMixin{
  // bool isFilterActivated = false;
  late AnimationController _controller;
  late SharedPreferences sharedPreferences;
  @override
  void initState() {
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    super.initState();
  }
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: [
            AnimatedContainer(
                //height: isFilterActivated?260:0,
                height: widget.isFilterActivated?widget.height:0,
                duration: const Duration(milliseconds: 1000),
                curve: Curves.easeInOut,
                child: SingleChildScrollView(
                  child: widget.child,
                )

            ),
          GestureDetector(
            onTap: () async {
              _controller.reverse(from: 0.5);
              setState(() {
                widget.isFilterActivated = !widget.isFilterActivated;
                optifoodSharedPrefrence.setBool("isFilterActivated", widget.isFilterActivated);
                print("==========isFilterActivatedisFilterActivated======${optifoodSharedPrefrence.getBool("isFilterActivated")}===========================");
              });


            },
            child:  Container(
              padding: const EdgeInsets.only(top: 3,bottom: 2),
              margin: const EdgeInsets.only(bottom: 0),
              width: double.infinity,
              decoration: const BoxDecoration(
                color: Colors.white70,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    spreadRadius: 0.5,
                    blurRadius: 1,
                  ),
                ],
              ),

              child: RotationTransition(
                turns: Tween(begin: 0.0, end: 1.0).animate(_controller),
                //child: SvgPicture.asset(AppImages.upArrow, height: 30,color: AppTheme.colorRed,),
                child: SvgPicture.asset(widget.isFilterActivated?AppImages.upArrow:AppImages.downArrow, height: 30,color: AppTheme.colorRed,),
                //child: Icon(isFilterActivated?Icons.arrow_drop_up_sharp:Icons.arrow_drop_down_sharp,color: AppTheme.colorRed,)
              ),
              //child: SvgPicture.asset(AppImages.downArrow, height: 30,color: AppTheme.colorRed,),
              //child: Icon(isFilterActivated?Icons.arrow_drop_up_sharp:Icons.arrow_drop_down_sharp,color: AppTheme.colorRed,)
            ),
          )

        ],
      ),
    );
  }

}