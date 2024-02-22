import 'package:flutter_svg/flutter_svg.dart';

class AppIconModel
{
  SvgPicture svgPicture;
  Function onTap;
  AppIconModel({required this.svgPicture, required this.onTap});
}