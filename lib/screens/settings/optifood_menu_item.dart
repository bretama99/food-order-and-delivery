import 'package:flutter/cupertino.dart';
import 'package:flutter_svg/svg.dart';

class OptifoodMenuItem{
  String id;
  String text;
  SvgPicture icon;
  bool isShowSwitch;
  bool isSwitchOn;
  Function? onSwitchChangeCallback;
  bool isShowTextField;
  Function? textFieldCallback;
  TextEditingController? textFieldController;
  Function? onClick;
  List<OptifoodMenuItem> subMenuList;
  bool isEnabled = true;
  String privilegeName="";
  OptifoodMenuItem(this.id,this.text,this.icon,{this.isEnabled=true,this.subMenuList=const [],this.isShowSwitch = false,this.isSwitchOn = false,this.onClick,this.isShowTextField=false,this.textFieldCallback,this.textFieldController,this.onSwitchChangeCallback,
  required this.privilegeName});
  OptifoodMenuItem.clone(OptifoodMenuItem menuItem,{Function? onClick,Function? textFieldCallback,TextEditingController? textFieldController,Function? onSwitchChangeCallback}):this(
      menuItem.id,
      menuItem.text,
      menuItem.icon,
      isEnabled: menuItem.isEnabled,
      subMenuList: menuItem.subMenuList,
      isShowSwitch: menuItem.isShowSwitch,
      isSwitchOn: menuItem.isSwitchOn,
      onClick: onClick!=null?onClick:menuItem.onClick,
      isShowTextField: menuItem.isShowTextField,
      textFieldCallback: textFieldCallback!=null?textFieldCallback!:menuItem.textFieldCallback,
      textFieldController: textFieldController!=null?textFieldController!:menuItem.textFieldController,
      onSwitchChangeCallback: onSwitchChangeCallback!=null?onSwitchChangeCallback!:menuItem.onSwitchChangeCallback,
      privilegeName: menuItem.privilegeName
  );
  OptifoodMenuItem addSubMenuList(List<OptifoodMenuItem> subMenuList){
    this.subMenuList = subMenuList;
    return this;
  }
}