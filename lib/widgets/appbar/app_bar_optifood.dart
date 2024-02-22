import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:geolocator/geolocator.dart';

import '../../assets/images.dart';
import '../../screens/MountedState.dart';
import '../app_theme.dart';
import 'app_icon_model.dart';

class AppBarOptifood extends StatefulWidget implements PreferredSizeWidget
{
  List<AppIconModel> appIconList = List.empty();
  Color backGroundColor;
  List<Widget>? content;
  bool isShowSearchBar;
  Function onSearch;
  _AppBarOptifoodState __appBarOptifoodState = _AppBarOptifoodState();
  AppBarOptifood({
    this.appIconList = const[],this.backGroundColor = AppTheme.colorLightGrey,
    this.isShowSearchBar = false,this.onSearch= _defFunction, this.content});

  static _defFunction(){}

  @override
  //State<StatefulWidget> createState() => _AppBarOptifoodState();
  State<StatefulWidget> createState() => __appBarOptifoodState;


  @override
  Size get preferredSize => Size.fromHeight(60);

  void closeSearchBar(){
    __appBarOptifoodState.closeSearchBar();
  }
}

class _AppBarOptifoodState extends MountedState<AppBarOptifood>
{
  bool isSearchBarOpen = false;
  Widget customSearchBar = Text("");
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    //widget.isSearchBarOpen = false;
  }
  @override
  Widget build(BuildContext context) {
    if(widget.isShowSearchBar) {
      //if (widget.isSearchBarOpen) {
      if (isSearchBarOpen) {
        customSearchBar = getSearchBar();
      }
      else {
        customSearchBar = getSearchIcon();
      }
    }
    else
      {
        customSearchBar = Text("");
      }
    return AppBar(
      automaticallyImplyLeading: false,
      elevation: 0,
      titleSpacing: 0,
      surfaceTintColor: Colors.transparent,
      backgroundColor: widget.backGroundColor,
      title:
      /*Container(
        padding: EdgeInsets.only(left: 3, right: 3),
          color: AppTheme.colorLightGrey,
        child: Card(
          child: Container(
        decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        ),
    child: Row(
            children: [
              Container(
                height: 80,
                padding: EdgeInsets.only(left: 7,right: 7),
                decoration: const BoxDecoration(
                  border: Border(right: BorderSide(color: AppTheme.colorLightGrey)),
                ),
                child: InkWell(
                    onTap: ()
                    {
                      Navigator.pop(context);
                    },
                    child: SvgPicture.asset(AppImages.backIcon, height: 45, color: AppTheme.colorRed,)),
              ),
              Container(
                alignment: Alignment.centerRight,
                child: customSearchBar,
              ),
            ],
        ),
      )))*/
      Container(
        padding: EdgeInsets.only(left: 2, right: 2),
        child:
        Card(
          color: Colors.white,
          surfaceTintColor: Colors.transparent,
          child: ListTile(
            minVerticalPadding: 0,
            horizontalTitleGap: 0,
            contentPadding: EdgeInsets.all(0),
            dense: true,
            leading:
            Container(
              height: 100,
              padding: EdgeInsets.only(left: 7,right: 7),
              decoration: const BoxDecoration(
                border: Border(right: BorderSide(color: AppTheme.colorLightGrey)),
              ),
              child: InkWell(
                  onTap: ()
                  {
                    Navigator.pop(context);
                  },
                  child: SvgPicture.asset(AppImages.backIcon, height: 45, color: AppTheme.colorRed,)
              ),
            ),
            trailing: widget.appIconList.isEmpty?null:
            Container(
              //padding: EdgeInsets.all(5),
              child: generateIcons()
            ),
            title: Container(
              alignment: Alignment.centerRight,
               child: widget.content==null?customSearchBar: Row(children: widget.content!),

            ),
          ),
        ),
      ),
    );
  }

  Widget getSearchIcon()
  {
    return IconButton(icon: Icon(Icons.search,color: AppTheme.colorRed,),iconSize: 35,onPressed: ()
    {
      setState((){
        isSearchBarOpen = true;
        customSearchBar = getSearchBar();
      });
    },);
  }

  Widget getSearchBar()
  {
    return TextField(
      autofocus: true,
      onTap: (){print("text field tapped");},
      onChanged: (searchQuery){
        widget.onSearch(searchQuery);
      },
      decoration: new InputDecoration(
          hintText: 'location...'.tr(),
          suffixIcon: IconButton(
            icon: Icon(Icons.close),
            onPressed: ()
            {
              closeSearchBar();
            },
          ),

          prefixIcon: Icon(Icons.search),
          border: InputBorder.none
      ),
    );
  }
  void closeSearchBar(){
    isSearchBarOpen = false;
    widget.onSearch("");
    setState(()
    {
      customSearchBar = getSearchIcon();
    });
  }
  Widget generateIcons()
  {
    List<Widget> list = List.empty(growable: true);
    widget.appIconList.forEach((appIcon) {
      list.add(
          //Flexible(
          Container(
          //flex:1,
          //fit: FlexFit.tight,
          child: GestureDetector(
            //child: SvgPicture.asset("assets/images/icons/optimisation.svg", height: 45, color: Color(0xff000000),),
            child: Padding(padding: EdgeInsets.only(left: 5,right: 5),child: appIcon.svgPicture,),
            onTap: (){
              //Navigator.of(context).push(MaterialPageRoute(builder: (BuildContext context) => DeliveryBoyPathOptimization()));
              setState(() {
                customSearchBar = getSearchBar();
              });
              appIcon.onTap();
            },
          )
      ));
    });
    return Padding(padding: EdgeInsets.only(right: 10),child: Wrap(children: list,));
  }
}