import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:opti_food_app/api/reservation_api.dart';
import 'package:opti_food_app/data_models/contact_model.dart';
import 'package:opti_food_app/data_models/reservation_model.dart';
import 'package:opti_food_app/database/reservation_dao.dart';
import 'package:opti_food_app/screens/contact/contact_list.dart';
import 'package:opti_food_app/screens/reservation/add_reservation.dart';
import 'package:opti_food_app/utils/constants.dart';
import 'package:opti_food_app/widgets/appbar/navigation_bar_optifood.dart';
import 'package:opti_food_app/widgets/option_menu/reservation/reservation_option_menu_popup.dart';

import '../../assets/images.dart';
import '../../widgets/app_theme.dart';
import '../../widgets/appbar/app_bar_optifood.dart';
import '../../widgets/datetime_form_field.dart';
import '../../widgets/popup/confirmation_popup/confirmation_popup.dart';
import '../MountedState.dart';
class ReservationList extends StatefulWidget{
  TextEditingController selectedDateController = TextEditingController();
  @override
  State<StatefulWidget> createState()=> _ReservationListState();
  late String selectedDate;

}
class _ReservationListState extends MountedState<ReservationList>{
  List<ReservationModel> reservationList = [];
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    widget.selectedDate = DateFormat("dd/MM/yyyy").format(DateTime.now());
    getReservationList(widget.selectedDate);
  }
  void getReservationList(String date){
    ReservationDao().getReservationList(date).then((value){
      setState((){
        reservationList = value;
      });
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarOptifood(),
      body: Container(
        child: SafeArea(
            child: Padding(
                padding: const EdgeInsets.fromLTRB(3, 0, 3, 0),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.only(top: 22,bottom: 35),
                      margin: EdgeInsets.only(bottom: 30),
                      width: double.infinity,
                      decoration: const BoxDecoration(
                        color: Colors.white70,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black12,
                            spreadRadius: 2,
                            blurRadius: 5,
                          ),
                        ],
                      ),
                      child: DateTimeFormField(
                        dateTimeController: widget.selectedDateController,
                        initialDate: DateTime.now(),
                        firstDate: DateTime.now(),
                        lastDate: 2100,
                        initialTime: TimeOfDay.now(),
                        isKeepSpaceForOuterIcon: true,
                        selectDate: DateFormat("dd/MM/yyyy").format(DateTime.now()),
                        showTimePicker: false,
                        endDateTime: widget.selectedDateController,
                        startDateTime: widget.selectedDateController,
                        outerIcon: SvgPicture.asset(AppImages.calendarIcon, height: 35,),
                        onDateSelected: (String date){
                          getReservationList(date);
                        },
                      ),
                    ),
                    if(reservationList.length>0) ...[
                      Expanded(
                        child:ListView.builder(
                            itemCount: reservationList.length,
                            itemBuilder: (context, index) => GestureDetector(
                              onTap: () async {

                              },
                              onHorizontalDragStart: (DragStartDetails dragStartDetails){
                                if(reservationList[index].status == ConstantReservationStatus.STATUS_ARRIVED){
                                  return;
                                }
                                setState(() {
                                  showDialog(context: context,
                                      builder: (BuildContext context) {
                                        return ReservationOptionMenuPopup(onSelect: (action) async {
                                          if(action == ReservationOptionMenuPopup.ACTIONS.ACTION_DELETE){
                                            showDialog(
                                                context: context,
                                                builder: (BuildContext
                                                context) {
                                                  return ConfirmationPopup(
                                                    title: "delete".tr(),
                                                    titleImagePath: AppImages.deleteIcon,
                                                    positiveButtonText: "delete".tr(),
                                                    negativeButtonText: "cancel".tr(),
                                                    titleImageBackgroundColor: AppTheme
                                                        .colorRed,
                                                    positiveButtonPressed: () async {
                                                      await ReservationDao().delete(reservationList[index]).then((value) {
                                                        ReservationApis.deleteReservation(reservationList[index].serverId!);
                                                      });
                                                      setState(() {
                                                        // getReservationList(date);
                                                        getReservationList(widget.selectedDate);
                                                      });
                                                    },
                                                    subTitle: 'areYouSureToDeleteCategory'.tr(),
                                                  );
                                                });
                                          }
                                          else if(action == ReservationOptionMenuPopup.ACTIONS.ACTION_EDIT){
                                            await Navigator.of(context).push(
                                                MaterialPageRoute(
                                                    builder: (context) =>
                                                        AddReservation(
                                                          existingReservationModel: reservationList[index],
                                                        )
                                                ));
                                            setState(() {
                                              getReservationList(widget.selectedDate);
                                            });
                                          }
                                          else if(action == ReservationOptionMenuPopup.ACTIONS.ACTION_ARRIVED){
                                            reservationList[index].status = ConstantReservationStatus.STATUS_ARRIVED;
                                            await ReservationDao().updateReservation(reservationList[index]).then((value){
                                              ReservationApis.changeStatusReservationServer(reservationList[index]);
                                            });
                                            setState(() {
                                              getReservationList(widget.selectedDate);
                                            });
                                          }
                                        });
                                      });
                                });


                              },
                              child: Container(
                                //height: 88,
                                child: Card(
                                    color: Colors.white,
                                    surfaceTintColor: Colors.transparent,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(
                                          10), // <-- Radius
                                    ),
                                    child: Stack(
                                      children: [
                                        Container(
                                            child: Row(
                                                children: <Widget>[
                                                  Container(
                                                      decoration: BoxDecoration(
                                                        borderRadius: BorderRadius.only(topLeft: Radius.circular(10),bottomLeft: Radius.circular(10)),
                                                        color: AppTheme.colorLightGrey,
                                                      ),
                                                      width: 70,
                                                      height: 96,
                                                      alignment: Alignment.center,
                                                      child: Text(
                                                        reservationList[index].reservationTime, style: const TextStyle(
                                                          fontSize: 18,
                                                          color: Color(0xff282828),
                                                          fontWeight: FontWeight.bold),)
                                                  ),
                                                  Expanded(
                                                    child: InkWell(
                                                      onTap: () {

                                                      },
                                                      child: Column(
                                                        crossAxisAlignment: CrossAxisAlignment.start,
                                                        children: [
                                                          Padding(padding: EdgeInsets.only(right: 5,left: 15),
                                                            child: Text(reservationList[index].name,style: TextStyle(fontSize: 16,fontWeight: FontWeight.bold),),
                                                          ),

                                                          Padding(
                                                            padding: const EdgeInsets
                                                                .fromLTRB(8, 0, 0, 0),
                                                            child: Row(
                                                              children: [
                                                                SvgPicture.asset(
                                                                    AppImages.dinnerTableIcon,
                                                                    height: 11,
                                                                    color: const Color(
                                                                        0xffa2a2a2)),
                                                                Padding(
                                                                  padding: EdgeInsets
                                                                      .fromLTRB(
                                                                      4, 0, 0, 0),
                                                                  child: Text(reservationList[index].typeOfReservation,
                                                                    style: TextStyle(
                                                                        fontSize: 11,
                                                                        color: Color(
                                                                            0xffa2a2a2)),),),
                                                              ],
                                                            ),
                                                          ),
                                                          Padding(
                                                            padding: const EdgeInsets
                                                                .fromLTRB(8, 0, 0, 0),
                                                            child: Row(
                                                              children: [
                                                                SvgPicture.asset(
                                                                    AppImages.numberPersons,
                                                                    height: 11,
                                                                    color: const Color(
                                                                        0xffa2a2a2)),
                                                                Padding(
                                                                  padding: EdgeInsets
                                                                      .fromLTRB(
                                                                      4, 0, 0, 0),
                                                                  child: Text(reservationList[index].numberOfPersons.toString()+" Persons",
                                                                    style: TextStyle(
                                                                        fontSize: 11,
                                                                        color: Color(
                                                                            0xffa2a2a2)),),),
                                                              ],
                                                            ),
                                                          ),
                                                          Padding(
                                                            padding: const EdgeInsets
                                                                .fromLTRB(8, 0, 0, 0),
                                                            child: Row(
                                                              children: [
                                                                SvgPicture.asset(
                                                                    AppImages.phoneClientIcon,
                                                                    height: 11,
                                                                    color: const Color(
                                                                        0xffa2a2a2)),
                                                                Padding(
                                                                  padding: EdgeInsets
                                                                      .fromLTRB(
                                                                      4, 0, 0, 0),
                                                                  child: Text(reservationList[index].phone,
                                                                    style: TextStyle(
                                                                        fontSize: 11,
                                                                        color: Color(
                                                                            0xffa2a2a2)),),),
                                                              ],
                                                            ),
                                                          ),
                                                          Padding(
                                                            padding: const EdgeInsets
                                                                .fromLTRB(8, 0, 0, 0),
                                                            child: Row(
                                                              children: [
                                                                SvgPicture.asset(
                                                                    AppImages.managerIcon,
                                                                    height: 11,
                                                                    color: const Color(
                                                                        0xffa2a2a2)),
                                                                Padding(
                                                                  padding: EdgeInsets
                                                                      .fromLTRB(
                                                                      4, 0, 0, 0),
                                                                  child: Text("manager".tr(),
                                                                    style: TextStyle(
                                                                        fontSize: 11,
                                                                        color: Color(
                                                                            0xffa2a2a2)),),),
                                                              ],
                                                            ),
                                                          )
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                ]
                                            )
                                        ),
                                        if(reservationList[index].status == ConstantReservationStatus.STATUS_ARRIVED)
                                          ...[
                                            Positioned(
                                              top: 25,
                                              right: 20,
                                              child: Container(
                                                  height: 50,
                                                  width: 50,
                                                  child: SvgPicture.asset(AppImages.checkMarks,color: AppTheme.colorGreen,)),)
                                            //child: SvgPicture.asset(AppImages.finishFlag,color: AppTheme.colorGreen,)),)
                                            /*child: FloatingActionButton(
                                                  elevation: 0,
                                                  backgroundColor: AppTheme.colorGreen,
                                                  child: SvgPicture.asset(AppImages.finishFlag,color: Colors.white,height: 30,),
                                                  onPressed: () {

                                                  },
                                                ),
                                            )
                                            )*/
                                          ]

                                      ],
                                    )
                                ),
                              ),
                            )
                        ),
                      ),
                    ]
                    else ...[
                      Expanded(child: Center(child: Text("noReservation".tr(),style: TextStyle(fontSize: 16,),textAlign: TextAlign.center,)) ,)
                    ]

                  ],
                )
            )
        ),
      ),
      floatingActionButton:
      Padding(
        padding: const EdgeInsets.only(top: 40),
        child: SizedBox(
          height: 65.0,
          width: 65.0,
          child: FittedBox(
            child: FloatingActionButton(
              backgroundColor: AppTheme.colorRed,
              child: SvgPicture.asset(AppImages.addWhiteIcon, height: 30,),
              onPressed: () async {
                //ContactModel contact =
                await Navigator.of(context).push(MaterialPageRoute(builder: (context)=>
                    ContactList(returnContact: true,showAddButton: false,showSkipButton: true,isFromReservation:true)));
                // Navigator.pop(context);

                // await Navigator.of(context).push(MaterialPageRoute(builder: (context)=>
                //     AddReservation(contactModel: contact,)));
                // getReservationList(DateFormat("dd/MM/yyyy").format(DateTime.now()));
                getReservationList(widget.selectedDate);
                //if(companyModel!=null){
                //getAttributes();
                //}
              },
            ),
          ),
        ),
      ),
    );
  }

}