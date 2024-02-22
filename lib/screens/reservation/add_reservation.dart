import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:opti_food_app/data_models/reservation_model.dart';
import 'package:opti_food_app/database/reservation_dao.dart';
import 'package:opti_food_app/screens/reservation/reservation_list.dart';
import 'package:opti_food_app/utils/constants.dart';
import 'package:opti_food_app/utils/utility.dart';
import 'package:opti_food_app/widgets/appbar/app_bar_optifood.dart';
import 'package:opti_food_app/widgets/custom_drop_down.dart';

import '../../api/reservation_api.dart';
import '../../assets/images.dart';
import '../../data_models/contact_model.dart';
import '../../widgets/app_theme.dart';
import '../../widgets/custom_field_with_no_icon.dart';
import '../MountedState.dart';
class AddReservation extends StatefulWidget{
  TextEditingController nameController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  TextEditingController dateController = TextEditingController();
  TextEditingController timeController = TextEditingController();
  TextEditingController numberOfPersonsController = TextEditingController();
  TextEditingController commentController = TextEditingController();
  ContactModel? contactModel;
  ReservationModel? existingReservationModel;
  AddReservation({this.contactModel,this.existingReservationModel});

  @override
  State<StatefulWidget> createState() => _AddReservationState();
}
class _AddReservationState extends MountedState<AddReservation>{
  final GlobalKey<FormState> _globalKey = GlobalKey<FormState>();
  var typeOfReservation = ["pleaseSelectReservationType","terrace","table","allRestaurant"];
  String selectedReservationType = "pleaseSelectReservationType";
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    if(widget.existingReservationModel!=null){
      widget.nameController.text = widget.existingReservationModel!.name;
      widget.phoneController.text = widget.existingReservationModel!.phone;
      widget.dateController.text = widget.existingReservationModel!.reservationDate;
      widget.timeController.text = widget.existingReservationModel!.reservationTime;
      widget.numberOfPersonsController.text = widget.existingReservationModel!.numberOfPersons.toString();
      widget.commentController.text = widget.existingReservationModel!.comment;
      selectedReservationType = widget.existingReservationModel!.typeOfReservation;
    }
    else {
      widget.dateController.text =
          DateFormat("dd/MM/yyyy").format(DateTime.now()).toString();
      widget.numberOfPersonsController.text = "1";
      if (widget.contactModel != null) {
        widget.nameController.text = widget.contactModel!.lastName + " " +
            widget.contactModel!.firstName;
        widget.phoneController.text = widget.contactModel!.phoneNumber;
      }
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarOptifood(),
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.all(10),
          child: Form(
            key: _globalKey,
            child: Column(
              children: [
                CustomFieldWithNoIcon(
                  validator: (value){
                    if(value==null || value.isEmpty) {
                      return "pleaseEnterName".tr();
                    }
                    else{
                      return null;
                    }
                  },
                  controller: widget.nameController,
                  hintText: "name".tr(),
                  isObsecre: false,
                  outerIcon: SvgPicture.asset(AppImages.clientInfoIcon, height: 35, color: AppTheme.colorDarkGrey,),
                ),
                CustomFieldWithNoIcon(
                  validator: (value){
                    if(value==null || value.isEmpty) {
                      return "pleaseEnterPhoneNumber".tr();
                    }
                    else{
                      return null;
                    }
                  },
                  controller: widget.phoneController,
                  hintText: "phoneNumber".tr(),
                  isObsecre: false,
                  textInputType: TextInputType.phone,
                  outerIcon: SvgPicture.asset(AppImages.phoneClientIcon, height: 35, color: AppTheme.colorDarkGrey,),
                ),
                CustomFieldWithNoIcon(
                  readOnly: true,
                  hintText: "reservationDate".tr(),
                  controller: widget.dateController,
                  onTap: () async {
                    String date = await Utility().pickDate(context);
                    widget.dateController.text = date;
                  },
                  isObsecre: false,
                  outerIcon: SvgPicture.asset(AppImages.calendarIcon, height: 35, color: AppTheme.colorDarkGrey,),
                ),
                CustomFieldWithNoIcon(
                  validator: (value){
                    if(value==null || value.isEmpty) {
                      return "pleaseEnterReservationTime".tr();
                    }
                    else{
                      return null;
                    }
                  },
                  controller: widget.timeController,
                  hintText: "reservationTime".tr(),
                  readOnly: true,
                  onTap: () async {
                    String? time = await Utility().pickTime(context)!;
                    if(time!=null){
                      widget.timeController.text = time;
                    }
                  },
                  isObsecre: false,
                  outerIcon: SvgPicture.asset(AppImages.timeIcon, height: 35, color: AppTheme.colorDarkGrey,),
                ),
                Container(
                  width: double.infinity,
                  //padding: EdgeInsets.only(left: 15,right: 15),
                  child: /*DropdownButtonHideUnderline(
                    child: DropdownButton(
                      items: typeOfReservation.map((String items){
                        return DropdownMenuItem(
                            value: items,
                            child: Text(items));
                      }).toList(),
                      value: selectedReservationType,
                      onChanged: (Object? value) {
                        setState(() {
                          selectedReservationType = value.toString();
                        });
                      },
                    ),*/
                  CustomDropDown(dropDownItems: typeOfReservation,
                    selectedItem: selectedReservationType,
                    outerIcon: SvgPicture.asset(AppImages.dinnerTableIcon, height: 35, color: AppTheme.colorDarkGrey,),
                    onItemChange: (String value){
                      setState(() {
                        selectedReservationType = value;
                      });
                    },
                  ),
                ),
                CustomFieldWithNoIcon(
                  validator: (value){
                    if(value==null || value.isEmpty) {
                      return "pleaseEnterNumberOfPersons".tr();
                    }
                    else{
                      return null;
                    }
                  },
                  controller: widget.numberOfPersonsController,
                  hintText: "numberOfPersons".tr(),
                  textInputType: TextInputType.number,
                  isObsecre: false,
                  outerIcon: SvgPicture.asset(AppImages.numberPersons, height: 35, color: AppTheme.colorDarkGrey,),
                ),
                CustomFieldWithNoIcon(
                  controller: widget.commentController,
                  hintText: "comment".tr(),
                  minLines: 3,
                  maxLines: 3,
                  isObsecre: false,
                  outerIcon: SvgPicture.asset(AppImages.commentDarkIcon, height: 35, color: AppTheme.colorDarkGrey,),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 60,right: 55,top: 50),
                  child: Container(
                    height:45 ,
                    width: 300,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.all(
                            Radius.circular(10)),
                        boxShadow: [
                          BoxShadow(color: AppTheme.colorDarkGrey,spreadRadius:2 , blurRadius: 0,)
                        ]
                    ),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          surfaceTintColor: Colors.transparent,
                          primary: Colors.transparent,
                          elevation: 10, shadowColor: AppTheme.colorDarkGrey),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,

                        children: [
                          Padding(
                            padding: const EdgeInsets.only(right: 15),
                            child: SvgPicture.asset(AppImages.saveIcon,
                              height: 25,),
                          ),
                          Text('save', style: TextStyle(fontSize: 18.0, color: Colors.white),).tr(),
                        ],
                      ),
                      onPressed: () async {
                        if (_globalKey.currentState!.validate()==false) {
                          return;
                        }
                        if(selectedReservationType == "Please select reservation type"){
                          Utility().showToastMessage("Please select reservation type");
                          return;
                        }
                        ReservationModel reservationModel = ReservationModel(1, widget.nameController.text,
                            widget.phoneController.text,
                            widget.dateController.text,
                            widget.timeController.text,
                            selectedReservationType,
                            int.parse(widget.numberOfPersonsController.text),
                            widget.commentController.text,
                            ConstantReservationStatus.STATUS_PENDING
                        );
                        if(widget.existingReservationModel!=null){
                          reservationModel.id = widget.existingReservationModel!.id;
                          reservationModel.serverId = widget.existingReservationModel!.serverId;
                          await ReservationDao().updateReservation(reservationModel).then((value) {
                            ReservationApis.saveReservationToSever(reservationModel,isUpdate: true);

                          });
                          Navigator.pop(context);
                        }
                        else{
                          await ReservationDao().insertReservation(reservationModel).then((value){
                            ReservationApis.saveReservationToSever(reservationModel);
                          });
                          Navigator.pop(context);
                          print("===========saved reservationnnnnnnnn=============================");
                          await Navigator.of(context).push(MaterialPageRoute(builder: (context)=>ReservationList()));
                          Navigator.pop(context);

                        }
                        //

                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

}