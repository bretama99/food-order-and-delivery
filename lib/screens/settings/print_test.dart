// import 'package:esc_pos_printer/esc_pos_printer.dart';
//
// import 'package:dio/dio.dart';
// import 'package:easy_localization/easy_localization.dart';
// import 'package:flutter/material.dart';
// import 'package:opti_food_app/api/login_api.dart';
// import 'package:opti_food_app/api/product.dart';
// import 'package:opti_food_app/data_models/login_model.dart';
// import 'package:opti_food_app/data_models/login_response_model.dart';
// import 'package:opti_food_app/database/attribute_category_dao.dart';
// import 'package:opti_food_app/database/attribute_dao.dart';
// import 'package:opti_food_app/database/food_category_dao.dart';
// import 'package:opti_food_app/database/food_items_dao.dart';
// import 'package:opti_food_app/screens/order/ordered_lists.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import '../../api/order_apis.dart';
// import '../../assets/images.dart';
// import '../../utils/constants.dart';
// import '../../widgets/custom_field.dart';
// import 'package:wifi_configuration_2/wifi_configuration_2.dart';
//
// class Print extends StatefulWidget {
//   const Print({Key? key}) : super(key: key);
//   @override
//   State<Print> createState() => _PrintState();
// }
//
// class _PrintState extends MountedState<Print> {
//   @override
//   void initState(){
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final isLandscape = MediaQuery.of(context).orientation == Orientation.landscape;
//     return Scaffold(
//       body: Container()
//     );
//   }
//   final GlobalKey<FormState> _globalKey = GlobalKey<FormState>();
//   TextEditingController emailController = TextEditingController();
//   TextEditingController passwordController = TextEditingController();
//
//   void testReceipt(NetworkPrinter printer) {
//     printer.text(
//         'Regular: aA bB cC dD eE fF gG hH iI jJ kK lL mM nN oO pP qQ rR sS tT uU vV wW xX yY zZ');
//     printer.text('Special 1: àÀ èÈ éÉ ûÛ üÜ çÇ ôÔ',
//         styles: PosStyles(codeTable: 'CP1252'));
//     printer.text('Special 2: blåbærgrød',
//         styles: PosStyles(codeTable: 'CP1252'));
//
//     printer.text('Bold text', styles: PosStyles(bold: true));
//     printer.text('Reverse text', styles: PosStyles(reverse: true));
//     printer.text('Underlined text',
//         styles: PosStyles(underline: true), linesAfter: 1);
//     printer.text('Align left', styles: PosStyles(align: PosAlign.left));
//     printer.text('Align center', styles: PosStyles(align: PosAlign.center));
//     printer.text('Align right',
//         styles: PosStyles(align: PosAlign.right), linesAfter: 1);
//
//     printer.text('Text size 200%',
//         styles: PosStyles(
//           height: PosTextSize.size2,
//           width: PosTextSize.size2,
//         ));
//
//     printer.feed(2);
//     printer.cut();
//   }
// }