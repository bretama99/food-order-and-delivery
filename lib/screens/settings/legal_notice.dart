import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:opti_food_app/assets/images.dart';
import 'package:opti_food_app/widgets/appbar/app_bar_optifood.dart';
import 'package:url_launcher/url_launcher.dart';
import '../MountedState.dart';
class LegalNotice extends StatefulWidget{
  @override
  State<StatefulWidget> createState() => _LegalNoticeState();
}
class _LegalNoticeState extends MountedState<LegalNotice>{
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarOptifood(),
      body: Container(
        child: Stack(
          alignment: Alignment.center,
          children: [
            Center(
              child: Column(
              children: [
                Container(
                  margin: EdgeInsets.only(top: 100,),
                  padding: EdgeInsets.only(left: 70,right: 70),
                  child: Image.asset(AppImages.optifood_logo_full_grey),
                ),
                Text("Version 2.23")
              ],
            ),
            ),
            Positioned(
                bottom: 15,
                child: Align(
                  alignment: Alignment.center,
                  child: Column(
                    children: [
                      Text("copyright © e-com'unik 2018-2023"),
                      GestureDetector(
                        child: Text("e-comunik.fr",style: TextStyle(decoration: TextDecoration.underline),),
                        onTap: () async {
                            await launch("https://e-comunik.fr");
                          }
                          )
                          ]
                  ),
                )
            )
          ],
        ),
      ),
    );
  }

}