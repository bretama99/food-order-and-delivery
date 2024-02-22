import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class OptionMenuTile extends StatelessWidget{
  SvgPicture svg;
  Color svgBackground;
  Color btnBackground;
  String title;
  Function onSelect;
  Color textColor = Colors.black;
  OptionMenuTile(this.svg,this.svgBackground,this.title,this.onSelect,{this.textColor=Colors.black,this.btnBackground=Colors.white});
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: MediaQuery.of(context).size.width*0.3,
          child: Padding(
            padding: const EdgeInsets.only(top: 8,left: 0, bottom: 30,right: 10),
            child:  Container(
              height: 50,
              child: FloatingActionButton(
                elevation: 0,
                //backgroundColor: Colors.white,
                backgroundColor: svgBackground,

                //child: SvgPicture.asset(svgPath, height: 30),
                child: svg,
                onPressed: () {
                  /*Navigator.of(context).push(MaterialPageRoute(builder: (context)=>OrderTakingWindow(
                                          orderName: "", orderItemId: 1,data: [], orderedItems: [],)));*/
                  //Navigator.pop(context);
                  //widget.onSelect(OrderOptionMenuesAction.ACTION_EDIT);
                  onSelect();
                },
              ),
            ),
          ),
        ),
        Container(
          width: MediaQuery.of(context).size.width*0.6,
          // height: 90,
          child: Padding(
            padding: const EdgeInsets.only(top: 8,bottom: 30,right: 10),
            child: ElevatedButton(

              onPressed: () {
                /*Navigator.of(context).push(MaterialPageRoute(builder: (context)=>OrderTakingWindow(
                                        orderName: "", orderItemId: 1,data: [], orderedItems: [],)));*/
                //Navigator.pop(context);
                //widget.onSelect(OrderOptionMenuesAction.ACTION_EDIT);
                onSelect();
              },
              style: ElevatedButton.styleFrom(
                surfaceTintColor: Colors.transparent,
                //<-- SEE HERE
                elevation: 0,
                primary: btnBackground,
                side: BorderSide(
                  width: 1.3,
                ),
              ),

              child: Text(title,style: TextStyle(color: textColor),),
            ),
          ),
        ),
      ],
    );
  }

}