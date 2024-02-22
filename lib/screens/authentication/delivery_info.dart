import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';
import 'package:opti_food_app/assets/images.dart';
import 'package:opti_food_app/data_models/contact_model.dart';
import 'package:opti_food_app/database/contact_dao.dart';
import 'package:opti_food_app/main.dart';
import 'package:opti_food_app/screens/order/payment.dart';
import 'package:opti_food_app/utils/constants.dart';
import 'package:opti_food_app/widgets/appbar/app_bar_optifood.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../data_models/food_items_model.dart';
import '../../data_models/order_model.dart';
import '../../database/food_items_dao.dart';
import '../../utils/utility.dart';
import '../../widgets/app_theme.dart';
import '../../widgets/popup/input_popup/radio_input_popup.dart';
import '../../widgets/time_form_field.dart';
import '../MountedState.dart';
import '../order/order_taking_window.dart';
import '../contact/contact_list.dart';
import '../settings/localization.dart';

class DeliveryInfo extends StatefulWidget {
  //final String s;
  final ContactModel customer;
  OrderModel? existingOrder; // not null only if edit order
  Function? callBack;
  DeliveryInfo({Key? key, required this.customer,this.existingOrder=null, this.callBack}) : super(key: key);
  @override
  State<DeliveryInfo> createState() => _DeliveryInfoState();
}

class _DeliveryInfoState extends MountedState<DeliveryInfo> {
  bool isValidTime = true;
  TextEditingController nameController = TextEditingController();
  TextEditingController dateController = TextEditingController();
  TextEditingController timeController = TextEditingController();
  TextEditingController creditController = TextEditingController();
  TextEditingController commentController = TextEditingController();

  List<String> _selectedItems = [];
  void _showMultiSelect() async {
    final List<String> items = [
      'Cash',
      'Credit Card',
      'Meal Voucher',
      'Cheque',
      'Platform',
    ];

    final List<String>? results = await showDialog(
      context: context,
      builder: (BuildContext context) {
        //return Payment(items: items, selectedItems:_selectedItems);
        return RadioInputPopup(
          value: true,
          groupValue: false,
          toggleable: true,
          contentEditable: true,
          cancelButtonNeeded: true,
          beforeContent: [
            ListTile(
              contentPadding: EdgeInsets.only(left: 10,right: 10,top: 10,bottom: 5),
              leading: SvgPicture.asset(AppImages.paymentIcon, height: 35, color: AppTheme.colorDarkGrey,),
              title: Text("paymentOptions".tr().toUpperCase(), style: TextStyle(color: AppTheme.colorMediumGrey,fontSize: 14)),
            ),],
          foodItemModel: FoodItemsModel(0,"","","","",0),
          items: items,
          selectedItems: _selectedItems,
        );
          // Payment(items: items, selectedItems:List.from(_selectedItems));
      },
    );

    // Update UI
    if (results != null) {
      setState(() {
        _selectedItems = results;
        creditController.text="";
        for(int i=0;i<results.length;i++){
          if(i<results.length-1) {
            creditController.text += _selectedItems[i] + ", ";
          }
          else{
            creditController.text+=_selectedItems[i];
          }
        }
      });
    }
  }
  TimeOfDay? timeOfDay = TimeOfDay.now();
  late String selectedDateFormat;
  late String selectedLanguage;
  late String groupTimeFormat;
  //late SharedPreferences sharedPreferences;
  int totalProducts = 0;
  late Future<List<OrderModel>> _orderList;
  late Future<List<FoodItemsModel>> _itemProductsList;
  late Future<List<ContactModel>> _contactList;
  Utility utility = Utility();
  Future<List<FoodItemsModel>> getItemList() async {
    totalProducts = 0;
    setState(() async {
      _itemProductsList = FoodItemsDao().getAllFoodItems();
      _itemProductsList.then((value) => {
        for (int i = 0; i < value.length; i++)
          {
            totalProducts += 1,
          }
      });
    });

    return _itemProductsList;
  }

  @override
  void initState() {

    print("=========in delivery infor ontactAddressModel.serverIdoooooooooooooommmmmmmm========="
        "${widget.customer.contactAddressList!.first.serverId}========================");  getItemList();
  //SharedPreferences.getInstance().then((value){
    //sharedPreferences = value;
    setState(() {
      selectedLanguage = optifoodSharedPrefrence.getString(ConstantSharedPreferenceKeys.KEY_SELECTED_LANGUAGE)!=null?optifoodSharedPrefrence.getString(ConstantSharedPreferenceKeys.KEY_SELECTED_LANGUAGE)!:"Français";
      groupTimeFormat = optifoodSharedPrefrence.getString(ConstantSharedPreferenceKeys.KEY_SELECTED_TIME_FORMAT)!=null?optifoodSharedPrefrence.getString(ConstantSharedPreferenceKeys.KEY_SELECTED_TIME_FORMAT)!:"24H";
      selectedDateFormat = (optifoodSharedPrefrence.getString(ConstantSharedPreferenceKeys.KEY_SELECTED_DATE_FORMAT)!=null?optifoodSharedPrefrence.getString(ConstantSharedPreferenceKeys.KEY_SELECTED_DATE_FORMAT):"dd/MM/yyyy")!;
      nameController.text = "${widget.customer.firstName} ${widget.customer.lastName}";
      if (dateController.text==""){
        dateController.text = DateFormat(selectedDateFormat).format(DateTime.now()).toString();
      }
      TimeOfDay _time = TimeOfDay.fromDateTime(DateTime.now().add(const Duration(minutes: 30)));
      timeOfDay = _time;
      if(timeController.text==""){
        if((int.parse(_time.minute.toString()))<10){
          //times="${_time.hour}:0${_time.minute}";
          timeController.text = "${_time.hour}:0${_time.minute}";
        }
        else{
          //times="${timeOfDay?.hour}:${timeOfDay!.minute}";
          timeController.text = "${_time.hour}:${_time.minute}";
        }
        //timeController.text = "${_time.hour}:${_time.minute}";
      }
      if(widget.existingOrder!=null){
        // dateController.text = DateFormat(selectedDateFormat).format(DateTime.parse(widget.existingOrder!.deliveryInfoModel!.deliveryDate)).toString();
        dateController.text = widget.existingOrder!.deliveryInfoModel!.deliveryDate;
        timeController.text = widget.existingOrder!.deliveryInfoModel!.deliveryTime.substring(0,5).toString();
        creditController.text = widget.existingOrder!.paymentMode!;
        if(creditController.text!=null&&creditController.text!=""){
          final names= creditController.text;
          final splitNames= names.split(',');
          for (int i = 0; i < splitNames.length; i++){
            _selectedItems.add(splitNames[i]);
          }
        }


        print("==========paymentMode in=========${creditController.text}=========_selectedItems===${_selectedItems}==================");
        commentController.text = widget.existingOrder!.comment;
      }
    });
  //});
    // TODO: implement initState
    super.initState();
    //nameController.text = widget.s;

  }

    TimeOfDay _timeOfDay = TimeOfDay(hour: 8, minute: 30);
    void _showTimePicker(){
      showTimePicker(
          helpText: "",
          hourLabelText: "",
          cancelText: "cancel".tr(),
          confirmText: "ok".tr(),
          builder: (context, child) {
            final Widget mediaQueryWrapper = MediaQuery(
              data: MediaQuery.of(context).copyWith(
                alwaysUse24HourFormat: false,
              ),
              child: MediaQuery(
                data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: false),
                  child:  Container(
                  height: 100,
                  width: 320,
                  child: child,
                ),),
              // child: child,
            );
           return Theme(
              child: (selectedLanguage != "English" && groupTimeFormat=="12H")?
              Localizations.override(
                context: context,
                locale: Locale('es', 'US'),
                child: mediaQueryWrapper,
              ):MediaQuery(data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: groupTimeFormat=="24H"?true:false),
                child:  Container(
                height: 100,
                width: 320,
                child: child,
              ),),
              data: ThemeData(
                useMaterial3: false,
                textButtonTheme: TextButtonThemeData(
                  style: TextButton.styleFrom(
                    primary: AppTheme.colorRed, // button text color
                  ),
                ),
                colorScheme: const ColorScheme.light(
                  primary: AppTheme.colorRed, // <-- SEE HERE
                  background:  AppTheme.colorRed,
                ),
                timePickerTheme: TimePickerThemeData(
                  dialHandColor:  AppTheme.colorRed,
                ),
              ),
            );
          },
          context: context,
          initialTime: TimeOfDay.now()).then((value) =>
      {
        setState((){
          var time=value.toString().split("(")[1].split(")")[0];
          if(selectedLanguage != "English" && groupTimeFormat=="12H" && int.parse(time.split(":")[0])>12){
            timeController.text=(int.parse(time.split(":")[0])-12).toString()+":${time.split(":")[1]}"+" PM";
          }
          else if(selectedLanguage != "English" && groupTimeFormat=="12H" && int.parse(time.split(":")[0])<12){
            timeController.text=time+" AM";
          }
          else if(selectedLanguage == "English" && groupTimeFormat=="24H"){
            timeController.text=time;
          }
          else {
            timeOfDay = value;
            timeController.text = value?.format(context) as String;
          }
          print(Utility().convertTimeFormat(timeController.text));
          var aa=Localizations.override(
              context: context,
              locale: Locale('fr', 'US'));
        })
      });
    }
  final GlobalKey<FormState> _globalKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        /*appBar: AppBar(
          elevation: 0,
          backgroundColor: AppTheme.colorLightGrey,
          actions: [
            Container(
              height: 100,
              child: Card(
                color: AppTheme.colorLightGrey,
                child: Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(0, 0, 1, 0),
                      child: Container(
                        decoration: const BoxDecoration(
                            color:Colors.white,
                            borderRadius: BorderRadius.horizontal(left:
                            Radius.circular(6))),
                        width:60,
                        height: 96,
                        alignment: Alignment.center,
                        child: InkWell(
                            onTap: (){
                              // Navigator.of(context).pop();
                              Navigator.of(context).push(MaterialPageRoute(builder:
                                  (context)=>ContactList()));
                            },
                            child: SvgPicture.asset("assets/images/icons/back.svg", height: 40, color: AppTheme.colorRed,)),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
                      child: Row(
                        children: [
                          Container(
                            color:Colors.white,
                            width:228,
                            height: 100,
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
                      child: Container(
                        decoration: const BoxDecoration(
                            color:Colors.white,
                            borderRadius: BorderRadius.horizontal(right:
                            Radius.circular(6))),
                        width:60,
                        height: 196,
                        alignment: Alignment.center,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),*/
      appBar: AppBarOptifood(),
        body:Padding(
          padding: const EdgeInsets.only(left: 7,right: 10,top: 35),
          child: Form(
            key: _globalKey,
            child: ListView(
              children: [
                Row(
                  children: [
                    Container(
                        width: MediaQuery.of(context).size.width*0.15,
                        child: SvgPicture.asset(AppImages.clientInfoIcon, height: 35, color: AppTheme.colorDarkGrey,)),
                    Container(
                      width: MediaQuery.of(context).size.width*0.8,
                      child:Card(
                        color: Colors.white,
                        surfaceTintColor: Colors.transparent,
                        shadowColor: Colors.white38,
                        elevation: 4,
                        shape:  RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10), // <-- Radius
                        ),
                        child:
                        TextFormField(
                              onTap: (){
                                Navigator.of(context).push(MaterialPageRoute(builder: (context)=>ContactList()));
                              },
                          readOnly: true,
                          controller: nameController,
                          decoration:  InputDecoration(
                            contentPadding:
                            EdgeInsets.only(left: 15, bottom: 11, top: 11, right: 15),
                            border: InputBorder.none,
                            focusedBorder: InputBorder.none,
                            errorBorder: InputBorder.none,
                            disabledBorder: InputBorder.none,
                            hintText: "name".tr(),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 11),
                  child: Row(
                    children: [
                      Container(
                        width: MediaQuery.of(context).size.width*0.15,
                        child: SvgPicture.asset(AppImages.calendarIcon, height: 35, color: AppTheme.colorDarkGrey,)
                      ),
                      Container(
                        width: MediaQuery.of(context).size.width*0.8,
                        child:Card(
                            color: Colors.white,
                            surfaceTintColor: Colors.transparent,
                          shadowColor: Colors.white38,
                          elevation: 4,                    shape:  RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10), // <-- Radius
                        ),
                          child:
                          TextFormField(
                            validator: (value) {
                              if (value!.isEmpty) return 'pleaseEnterDate'.tr();
                              else return null;
                            },
                            readOnly: true,
                            controller: dateController,
                            onTap: () async{
                              DateTime?pickedDate=await showDatePicker(
                                locale : Locale("${utility.getCountryCode()}", "${utility.getCountryCode().toUpperCase()}"),
                                confirmText: "ok".tr(),
                                cancelText: "cancel".tr(),
                                context: context,
                                helpText: DateFormat(selectedDateFormat).format(DateTime.now()).toString(),
                                initialDate: DateTime.now(),
                                firstDate: DateTime.now().subtract(Duration(days: 0)),
                                lastDate: DateTime(2101),
                                builder: (context, child) {
                                  return Padding(
                                    //padding: const EdgeInsets.only(top: 100,bottom: 100,left: 15,right: 15),
                                    padding: const EdgeInsets.only(top: 10,bottom: 10,left: 15,right: 15),
                                    child: Theme(
                                        data: Theme.of(context).copyWith(
                                          useMaterial3: false,
                                          shadowColor: Colors.black,
                                          appBarTheme: const AppBarTheme(actionsIconTheme: IconThemeData(color: Colors.amber),
                                              centerTitle: true,
                                              elevation: 60,
                                              titleTextStyle: TextStyle(color: Colors.lightBlueAccent, fontSize: 22)),
                                          colorScheme: const ColorScheme.light(
                                            primary: AppTheme.colorRed,
                                          ),
                                          textButtonTheme: TextButtonThemeData(
                                            style: TextButton.styleFrom(
                                              primary: AppTheme.colorRed, // button text color
                                            ),
                                          ),
                                        ),
                                        child: child!
                                    ),
                                  );
                                },
                              );
                              if(pickedDate!=null){
                                print(utility.getCountryCode());
                                String formattedDate = DateFormat(selectedDateFormat).format(pickedDate);
                                setState((){
                                  dateController.text = formattedDate.toString();
                                });
                              }
                            },
                            decoration: InputDecoration(
                              hintText: "selectDate".tr(),
                              contentPadding:
                              EdgeInsets.only(left: 15, bottom: 11, top: 11, right: 15),
                              border: InputBorder.none,
                              focusedBorder: InputBorder.none,
                              errorBorder: InputBorder.none,
                              disabledBorder: InputBorder.none,
                            ),
                          )
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 11,bottom: 11),
                  child: Row(
                    children: [
                      Container(
                          width: MediaQuery.of(context).size.width*0.15,
                          child: SvgPicture.asset(AppImages.timeIcon, height: 35, color: AppTheme.colorDarkGrey,)),
                      Container(
                        width: MediaQuery.of(context).size.width*0.8,
                        child:
                        TimeFormField(
                          deliveryDate:this.dateController.text,
                          controller: this.timeController,
                          isObsecre: false,
                          enabled: true,
                          isKeepSpaceForOuterIcon: false,

                        ),
                      ),
                    ],
                  ),
                ),
                Row(
                  children: [
                    Container(
                        width: MediaQuery.of(context).size.width*0.15,
                        child: SvgPicture.asset(AppImages.paymentIcon, height: 35, color: AppTheme.colorDarkGrey,)),
                    Container(
                      width: MediaQuery.of(context).size.width*0.8,
                      child:Card(
                        color: Colors.white,
                        surfaceTintColor: Colors.transparent,
                        shadowColor: Colors.white38,
                        elevation: 4,
                        shape:  RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10), // <-- Radius
                      ),
                        child: TextFormField(
                          validator: (value) {
                            if (value!.isEmpty) return 'pleaseSelectPaymentMode'.tr();
                            else return null;
                          },
                          onTap: (){
                            _showMultiSelect();
                          },
                          controller: creditController,
                          readOnly: true,
                          decoration: InputDecoration(
                            contentPadding:
                            EdgeInsets.only(left: 15, bottom: 11, top: 11, right: 15),
                            border: InputBorder.none,
                            focusedBorder: InputBorder.none,
                            errorBorder: InputBorder.none,
                            disabledBorder: InputBorder.none,
                            hintText: _selectedItems.isEmpty?"paymentMode".tr():_selectedItems.join(','),
                            //hintText: "Payment mode",
                          ),
                          // textAlign: TextAlign.left
                        ),
                      ),
                    ),
                  ],
                ),

                Padding(
                  padding: const EdgeInsets.only(top: 14),
                  child: Row(
                    children: [
                      Container(
                          width: MediaQuery.of(context).size.width*0.15,
                          child: SvgPicture.asset(AppImages.commentDarkIcon,
                            height: 35, color: AppTheme.colorDarkGrey,)),
                      Container(
                        width: MediaQuery.of(context).size.width*0.8,
                        child:Card(
                            color: Colors.white,
                            surfaceTintColor: Colors.transparent,
                          shadowColor: Colors.white38,
                          elevation: 4,                      shape:  RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10), // <-- Radius
                        ),
                          child:
                          TextFormField(
                            maxLines: 4,
                            controller: commentController,
                            decoration: InputDecoration(
                              contentPadding:
                              EdgeInsets.only(left: 15, bottom: 11, top: 11, right: 15),
                              border: InputBorder.none,
                              focusedBorder: InputBorder.none,
                              errorBorder: InputBorder.none,
                              disabledBorder: InputBorder.none,
                              hintText: "comment".tr(),
                            ),
                          )
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 60,right: 55,top: 50),
                  child: Container(
                    height:45 ,
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
                        primary: AppTheme.colorDarkGrey,
                          elevation: 10, shadowColor: AppTheme.colorDarkGrey),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text('next', style: TextStyle(fontSize: 18.0, color: Colors.white),).tr(),
                          SvgPicture.asset(AppImages.nextIcon,
                            height: 35, color: AppTheme.colorRed,)
                        ],
                      ),
                      onPressed: () async {
                        var times;
                        if((int.parse(timeOfDay!.minute.toString()))<10){
                          times="${timeOfDay?.hour}:0${timeOfDay!.minute}";
                        }
                        else{
                          times="${timeOfDay?.hour}:${timeOfDay!.minute}";
                        }
                        if (_globalKey.currentState!.validate()) {

                          await Navigator.of(context).push(MaterialPageRoute(
                              builder: (context)=>OrderTakingWindow(ConstantOrderType.ORDER_TYPE_DELIVERY,
                                ConstantDeliveryOrderType.DELIVERY,
                                comment:commentController.text,
                                customer: widget.customer,
                                paymentMode: _selectedItems.join(","),
                                existingOrder: widget.existingOrder,
                                deliveryDate: dateController.text,
                                deliveryTime: timeController.text,
                                isEditOrder: widget.existingOrder!=null,
                                  callBack:(String on){
                                      widget.callBack!(on);
                                      print("Updated in deliveryyyyyyyyyyyyyyyyyy callback: ${on}");

                                  }
                              ),
                          ),
                          );

                          Navigator.pop(context);
                          }
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
    );
  }

}
