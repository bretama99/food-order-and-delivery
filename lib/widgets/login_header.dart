import 'package:flutter/material.dart';
import 'package:opti_food_app/assets/images.dart';
class LoginHeader extends StatelessWidget {
  const LoginHeader({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration:const BoxDecoration(
            image: DecorationImage(
              image: AssetImage(AppImages.orderTakingOptifoodIcon),
              fit: BoxFit.cover,
            )
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              margin: const EdgeInsets.fromLTRB(40, 0, 40, 0),
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10)
              ),

              child: Column(
                children: [
                  Container(
                    margin: EdgeInsets.fromLTRB(40, 0, 40, 0),
                    color: Colors.white,
                    alignment: Alignment.bottomCenter,
                    child: Image.asset(AppImages.optifoodLogoIcon, height: 150),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
