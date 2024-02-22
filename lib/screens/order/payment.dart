import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../widgets/app_theme.dart';import '../MountedState.dart';
class Payment extends StatefulWidget {
  final List<String> items;
  //final List<String> selectedItems;
  List<String> selectedItems;
   Payment({Key? key, required this.items, required this.selectedItems}) : super(key: key);
  // const Payment({Key? key}) : super(key: key);

  @override
  State<Payment> createState() => _PaymentState();
}

class _PaymentState extends MountedState<Payment> {
  void _itemChange(String itemValue, bool isSelected) {
    setState(() {
      if (isSelected) {
        widget.selectedItems.add(itemValue);
      } else {
        widget.selectedItems.remove(itemValue);
      }
    });
  }

  void _cancel() {
    Navigator.pop(context);
  }

  void _submit() {
    Navigator.pop(context, widget.selectedItems);
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Dialog(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        shape:
        const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(bottomLeft: Radius.circular(20), bottomRight: Radius.circular(20),
        topLeft:  Radius.circular(20), topRight:  Radius.circular(20),),
        ),
        child:
        SingleChildScrollView(
          child: Container(
            padding: EdgeInsets.only(top: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
                children: [
                  ListView.builder(
                      scrollDirection: Axis.vertical,
                      shrinkWrap: true,
                      itemCount: widget.items.length,
                      itemBuilder: (BuildContext context, int index) {
                       return SizedBox(
                          height: 30,
                          child: Container(
                            height: 30,
                            padding: EdgeInsets.zero,
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Radio(
                                    value: true,
                                    activeColor: AppTheme.colorRed,
                                    groupValue: widget.selectedItems.contains(widget.items[index]),
                                    toggleable: true,
                                    onChanged: (isChecked){
                                      _itemChange(widget.items[index], !widget.selectedItems.contains(widget.items[index]));
                                    }),

                                Text(widget.items[index],style: TextStyle(fontWeight: FontWeight.bold),)
                              ],
                            ),
                          ),

                         /* CheckboxListTile(
                              dense: true,
                              visualDensity: VisualDensity.compact,
                              activeColor: AppTheme.colorRed, selectedTileColor: AppTheme.colorRed,
                              value: widget.selectedItems.contains(widget.items[index]),
                              title: Text(widget.items[index], style: TextStyle(
                                  fontSize: 18),),
                              controlAffinity: ListTileControlAffinity.leading,
                              onChanged: (isChecked) {
                                _itemChange(widget.items[index], isChecked!);
                              }
                          ),*/
                        );
                      }
                  ),
                  Container(
                    margin: const EdgeInsets.only(top: 20),
                    decoration: const BoxDecoration(
                      border: Border(top: BorderSide(color: AppTheme.colorMediumGrey,width:0.1,style: BorderStyle.solid)),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                            flex: 1,
                            child:
                            InkWell(
                              onTap: (){
                                _submit();
                              },
                              child: Container(
                                padding: const EdgeInsets.all(20),
                                alignment: Alignment.center,
                                decoration: const BoxDecoration(
                                  border: Border(right: BorderSide(color: AppTheme.colorMediumGrey,width:0.1,style: BorderStyle.solid)),
                                ),
                                child:
                                const Text("ok",style: TextStyle(color: AppTheme.colorMediumGrey,fontSize: 18,fontWeight: FontWeight.bold),).tr(),
                              ),
                            )
                        ),

                        Expanded(
                            flex: 1,
                            child:
                            InkWell(
                              onTap: (){
                                Navigator.pop(context);
                              },
                              child: Container(
                                padding: const EdgeInsets.all(20),
                                alignment: Alignment.center,
                                decoration: const BoxDecoration(
                                  //border: Border(right: BorderSide(color: AppTheme.colorLightGrey,width:1,style: BorderStyle.solid)),
                                ),
                                child:
                                const Text("cancel",style: TextStyle(color: AppTheme.colorMediumGrey,fontSize: 18,fontWeight: FontWeight.bold),).tr(),

                              ),
                            )
                        ),

                        //),
                      ],
                    ),
                  )
                ]
            ),
          ),
        )
    );
  }
  /*@override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(60, 210, 60, 0),
      child: Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.only(bottomLeft: Radius.circular(20), bottomRight: Radius.circular(20),
              topLeft:  Radius.circular(20), topRight:  Radius.circular(20),),
          ),
          alignment: Alignment.topCenter,
          // elevation: 100,
          backgroundColor: Colors.white,
          insetPadding: EdgeInsets.all(0),
          child: Stack(
            alignment: Alignment.center,
            children: <Widget>[
              Container(
                  width: double.infinity,
                  height: MediaQuery.of(context).size.height*0.33,
                  alignment: Alignment.center,
                 child: Column(
                   children: [
                     SizedBox(
                       height: MediaQuery.of(context).size.height*0.242,
                       child: Padding(
                         padding: const EdgeInsets.only(top: 10,bottom: 0),
                         child: ListView.builder(
                             itemCount: widget.items.length,
                             itemBuilder: (BuildContext context, int index) {
                               return SizedBox(
                                 height: 30,
                                 child: CheckboxListTile(
                                   dense: true,
                                   visualDensity: VisualDensity.compact,
                                   activeColor: AppTheme.colorRed, selectedTileColor: AppTheme.colorRed,
                                   value: widget.selectedItems.contains(widget.items[index]),
                                   title: Text(widget.items[index], style: TextStyle(
                                       fontSize: 18),),
                                   controlAffinity: ListTileControlAffinity.leading,
                                   onChanged: (isChecked) {
                                     _itemChange(widget.items[index], isChecked!);
                                   }
                                 ),
                               );
                             }
                         ),
                       ),
                     ),
                     Container(
                       child: Transform.translate(
                         offset: Offset(0, 3),
                         child: Divider(
                           thickness: 0.4,),
                       ),
                     ),
                     Row(
                       children: [
                         Expanded(
                           flex:1,
                           child: Transform.translate(
                             offset: Offset(4, -4),
                             child: FlatButton(
                               height: 45,
                               shape:  const RoundedRectangleBorder(
                                 borderRadius: BorderRadius.only(bottomLeft: Radius.circular(20)),
                               ),
                               child: Transform.translate(
                                   offset: Offset(0, 0),
                                   child: Text('OK', style: TextStyle(fontSize: 15.0, color: AppTheme.colorMediumGrey),)),
                               color: Colors.white,
                               textColor: Colors.black,
                               onPressed: () {
                                 _submit();
                               },
                             ),
                           ),
                         ),
                         Transform.translate(
                           offset:Offset(0, -3),
                           child: Container(
                             height: 30,
                             child: VerticalDivider(
                               color: Colors.black54, thickness: 0.1,),
                           ),
                         ),
                         Expanded(
                           flex:1,
                           child: Container(
                             // width: 180,
                             child: Transform.translate(
                               offset: Offset(-4, -4),
                               child: FlatButton(
                                 height: 45,
                                 color: Colors.white,
                                 shape:  RoundedRectangleBorder(
                                   borderRadius: BorderRadius.only(bottomRight: Radius.circular(20)),
                                 ),
                                 child: Transform.translate(
                                   offset: Offset(-4, 0),
                                   child: Text('CANCEL',
                                     textAlign: TextAlign.center, style: TextStyle(fontSize: 15.0,
                                       color: AppTheme.colorMediumGrey, ),),
                                 ),
                                 // color: Colors.white,
                                 textColor: Colors.black,
                                 onPressed: () {
                                   _cancel();
                                 },
                               ),
                             ),
                           ),
                         ),
                       ],
                     ),
                   ],
                 )
              ),
            ],
          )
      ),
    );
  }*/
}
