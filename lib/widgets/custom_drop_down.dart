import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import 'app_theme.dart';

class CustomDropDown extends StatelessWidget {
  SvgPicture? outerIcon;
  bool isKeepSpaceForOuterIcon = true;
  PaddingParameters? paddingParameters;
  List<String> dropDownItems;
  String selectedItem;
  Function? onItemChange;
  CustomDropDown({
    required this.dropDownItems,
    required this.selectedItem,
    this.outerIcon = null,
    this.isKeepSpaceForOuterIcon = true,
    this.paddingParameters,
    this.onItemChange
  });

  @override
  Widget build(BuildContext context) {
    return  Container(
      padding: paddingParameters!=null?EdgeInsets.only(left: paddingParameters!.left,
          top: paddingParameters!.top, right: paddingParameters!.right, bottom: paddingParameters!.bottom):
      isKeepSpaceForOuterIcon?EdgeInsets.only(left: 10,right: 10,top: 5,bottom: 5):EdgeInsets.only(top: 5,bottom: 5),
      child: Row(
        children: [
          if(outerIcon==null)...[
            if(isKeepSpaceForOuterIcon)...[
              SizedBox(width: 35,)
            ]
          ]
          else...[
            //Padding(padding: EdgeInsets.only(right: 5,left: 5),
              //child: outerIcon!,
              outerIcon!,
            //)
          ],
          SizedBox(width: 5,),
          Expanded(child:
          Card(
            color: Colors.white,
            surfaceTintColor: Colors.transparent,
            shadowColor: Colors.white38,
            elevation: 4,
            shape:  RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10), // <-- Radius
            ),
            child: Padding(
              
              //padding: EdgeInsets.only(left: 15),
              padding: EdgeInsets.only(left: 0),
              child: Theme(
                  data: Theme.of(context).copyWith(primaryColor: AppTheme.colorGrey),
                  child:  DropdownButtonHideUnderline(
                    child:ButtonTheme(
                      alignedDropdown: true,
                      child: DropdownButton(
                      items: dropDownItems.map((String items){
                        return DropdownMenuItem(
                            value: items,
                            child: Text(items.tr()));
                      }).toList(),
                      value: selectedItem,
                     // style: Theme.of(context).textTheme.titleMedium,
                      onChanged: (Object? value) {
                        //setState(() {
                        //selectedItem = value.toString();
                        this.onItemChange!(value.toString());
                        //});
                      },
                    ),
                    )

                  )
              ),
            ),
          ),
          )

        ],
      ),
    );

  }
}

class PaddingParameters {
  double left=0;
  double top=0;
  double right=0;
  double bottom=0;

  PaddingParameters(this.left, this.top, this.right, this.bottom);
}