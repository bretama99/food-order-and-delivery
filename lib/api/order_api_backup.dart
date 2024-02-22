// import 'package:dio/dio.dart';
// import 'package:fbroadcast/fbroadcast.dart';
// import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
// import 'package:opti_food_app/utils/constants.dart';
// import 'package:opti_food_app/utils/utility.dart';
// import '../../utils/constants.dart';
// import '../data_models/order_model.dart';
// import '../database/order_dao.dart';
// import '../main.dart';
// import '../services/optifood_background_service.dart';
// class OrderApis {
//   Function? callBack;
//   OrderApis({this.callBack});
//   static String OPTIFOOD_DATABASE='optifood1';
//
//   Future<void> syncOrders() async {
//     List<OrderModel> orderModelList = await OrderDao().getUnSyncedOrders();
//     orderModelList.forEach((element) {
//       saveOrderToSever(element,oncall: (String orderNumber){
//         FBroadcast.instance().broadcast(ConstantBroadcastKeys.KEY_ORDER_SENT);
//       });
//     });
//   }
//
//   void getOrderListFromServer({required Function localCallBack}) async{
//     List<OrderModel> fetchedData = [];
//     final dio = Dio();
//     dio.options.headers['X-TenantID'] = OPTIFOOD_DATABASE;
//     print("Checkingggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggg");
//     await dio.get(ServerData.OPTIFOOD_BASE_URL+"/api/order").then((response) async {
//       List<OrderModel> fetchedData = [];
//       if (response.statusCode == 200) {
//         print("Checkingggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggg");
//         for (int i = 0; i < response.data.length; i++) {
//           var singleItem = OrderModel.fromJsonServer(response.data[i]);
//           fetchedData.add(singleItem);
//         }
//
//         for(int i=0; i<fetchedData.length;i++){
//           OrderDao().getOrderByServerId(1).then((value){
//             var result=null;
//             if(value.length>0)
//               result=value.firstWhere((element) => element.serverId==fetchedData[i].serverId);
//             if(result!=null){
//               result?.serverId=fetchedData[i].serverId;
//               result?.orderNumber=fetchedData[i].orderNumber;
//               result?.orderName=fetchedData[i].orderName;
//               result?.orderType=fetchedData[i].orderType;
//               result?.orderService=fetchedData[i].orderService;
//               result?.comment=fetchedData[i].comment;
//               result?.totalPrice=fetchedData[i].totalPrice;
//               result?.createdAt=fetchedData[i].createdAt;
//               result?.createdBy=fetchedData[i].createdBy;
//               result?.deliveryInfoModel=fetchedData[i].deliveryInfoModel;
//               result?.foodItems=fetchedData[i].foodItems;
//               result?.isSynced=true;
//               result?.serverId=fetchedData[i].serverId;
//               OrderDao().updateOrder(result!);
//             }
//             else{
//               OrderModel orderModel = OrderModel(
//                   fetchedData[i].id, fetchedData[i].orderNumber, fetchedData[i].orderName, fetchedData[i].orderType,
//                   fetchedData[i].orderService, fetchedData[i].tableNumber, fetchedData[i].comment, fetchedData[i].totalPrice,
//                   fetchedData[i].createdAt, fetchedData[i].createdBy, fetchedData[i].deliveryInfoModel, fetchedData[i].foodItems);
//               orderModel.isSyncedOnServer=true;
//               orderModel.serverId=fetchedData[i].serverId;
//               OrderDao().insertOrder(orderModel);
//
//             }
//           });
//
//         }
//       }
//       localCallBack();
//     }).onError((error, stackTrace){
//       localCallBack();
//     });
//   }
//
//
//
//   static saveOrderToSever(OrderModel orderModel, {required Function oncall})async{
//     final dio = Dio();
//     dio.options.headers['X-TenantID'] = OPTIFOOD_DATABASE;
//     var orderedItems=[];
//     var deliverInfo={};
//     var orderedItemAttributes=[];
//     for(int i=0; i<orderModel.foodItems.length; i++){
//       if(orderModel.foodItems[i].attributeIds!=null && orderModel.foodItems[i].attributeIds.isNotEmpty) {
//         for (int j = 0; j < orderModel.foodItems[i].selectedAttributes.length; j++) {
//           var orderedItemAttribute={
//             "orderedItemId": orderModel.foodItems[i].serverId,
//             "orderedItemAttributeId": orderModel.foodItems[i].selectedAttributes[j].serverId,
//             "attribuetId": orderModel.foodItems[i].selectedAttributes[j].id,
//             "quantity": orderModel.foodItems[i].selectedAttributes[j].quantity,
//             "attributeValue": orderModel.foodItems[i].selectedAttributes[j].price
//           };
//           orderedItemAttributes.add(orderedItemAttribute);
//         }
//       }
//       var item={
//         'orderId': 0,
//         'orderedItemId': 0,
//         'discount': 10,
//         'menuPrice': 5.0,
//         'itemId': orderModel.foodItems[i].id,
//         'price': orderModel.foodItems[i].price,
//         'quantiry': orderModel.foodItems[i].quantity,
//         'orderedItemAttributeRequestModels': []
//       };
//       orderedItems.add(item);
//     }
//
//     var data = {
//       'customerId': orderModel.customer?.id,
//       'orderSourceId': 0,
//       'orderNumber': orderModel.orderNumber,
//       'status': "Ordered",
//       'paymentOption': orderModel.paymentMode,
//       'orderService':orderModel.orderService,
//       'isPrepared': false,
//       'orderTable': orderModel.tableNumber,
//       'managerId': 1,
//       'waiterId': 1,
//       'kitchenId': 1,
//       'totalPrice':orderModel.totalPrice,
//       'comment': orderModel.comment,
//       'arrivedTime': "00:00:00",
//       'delayTime': null,
//       'orderType': orderModel.orderType,
//       'orderedItemRequestModels': orderedItemAttributes,
//       'orderDeliveryDataRequestModel': orderModel.orderType=='delivery'?
//       {
//         'orderId': 0,
//         "customerAddressId": 0,
//         'companyId': 0,
//         'assignedTo':orderModel.deliveryInfoModel!.assignedTo,
//         'deliveryDate': orderModel.deliveryInfoModel!.deliveryDate.split("/")[2]+"-"+orderModel.deliveryInfoModel!.deliveryDate.split("/")[1]+"-"+orderModel.deliveryInfoModel!.deliveryDate.split("/")[0],
//         'deliveryTime': orderModel.deliveryInfoModel!.deliveryTime+":00"
//       } : null
//
//
//
//     };
//     var response = await dio.post(ServerData.OPTIFOOD_BASE_URL+'/api/order',
//       data: data,
//     ).then((response){
//       var mappedOrderModel = OrderModel.fromJsonServer(response.data);
//       orderModel.isSyncedOnServer=true;
//       orderModel.isSyncOnServerProcessing=false;
//       orderModel.serverId=mappedOrderModel.id;
//       orderModel.orderNumber=mappedOrderModel.orderNumber;
//       var singleItem = OrderModel.fromJsonServer(response.data);
//       OrderDao().updateOrder(orderModel);
//
//       FBroadcast.instance().broadcast(ConstantBroadcastKeys.KEY_ORDER_SENT,value:orderModel);
//     }).catchError((err) async {
//       orderModel.isSyncedOnServer=false;
//       orderModel.isSyncOnServerProcessing=false;
//       await OrderDao().updateOrder(orderModel);
//       FBroadcast.instance().broadcast(ConstantBroadcastKeys.KEY_ORDER_SENT,value:orderModel);
//       optifoodBackgroundService.syncPendingLocalData();
//     });
//   }
//
//
//   static updateOrderToSever(OrderModel orderModel, {required Function oncall})async{
//     final dio = Dio();
//     dio.options.headers['X-TenantID'] = OPTIFOOD_DATABASE;
//     var orderedItems=[];
//     var deliverInfo={};
//     for(int i=0; i<orderModel.foodItems.length; i++){
//       var orderedItemAttributes=[];
//       if(orderModel.foodItems[i].attributeIds!=null && orderModel.foodItems[i].attributeIds.isNotEmpty) {
//         for (int j = 0; j < orderModel.foodItems[i].selectedAttributes.length; j++) {
//           var orderedItemAttribute={
//             "orderedItemId": orderModel.foodItems[i].serverId,
//             "orderedItemAttributeId": orderModel.foodItems[i].selectedAttributes[j].serverId,
//             "attribuetId": orderModel.foodItems[i].selectedAttributes[j].id,
//             "quantity": orderModel.foodItems[i].selectedAttributes[j].quantity,
//             "attributeValue": orderModel.foodItems[i].selectedAttributes[j].price
//           };
//         }
//       }
//       var item={
//         'orderId': orderModel.id,
//         'orderedItemId': orderModel.foodItems[i].serverId,
//         'discount': orderModel.foodItems[i].discountPercentage,
//         'menuPrice': 0.0,
//         'itemId': orderModel.foodItems[i].id,
//         'price': orderModel.foodItems[i].price,
//         'quantiry': orderModel.foodItems[i].quantity,
//         'orderedItemAttributeRequestModels': orderedItemAttributes
//       };
//       orderedItems.add(item);
//     }
//
//     var data = {
//       'customerId': orderModel.customer?.id,
//       'orderSourceId': 0,
//       'orderNumber': orderModel.orderNumber,
//       'status': "Ordered",
//       'paymentOption': orderModel.paymentMode,
//       'orderService':orderModel.orderService,
//       'isPrepared': false,
//       'orderTable': orderModel.tableNumber,
//       'managerId': 1,
//       'waiterId': 1,
//       'kitchenId': 1,
//       'totalPrice':orderModel.totalPrice,
//       'comment': orderModel.comment,
//       'arrivedTime': "00:00:00",
//       'delayTime': null,
//       'orderType': orderModel.orderType,
//       'orderedItemRequestModels': orderedItems,
//       'orderDeliveryDataRequestModel': orderModel.orderType=='delivery'?
//       {
//         'orderDeliveryDataId': orderModel.deliveryInfoModel!.serverId,
//         'orderId': 0,
//         "customerAddressId": 0,
//         'companyId': 0,
//         'assignedTo': orderModel.deliveryInfoModel!.assignedTo,
//         'deliveryDate': orderModel.deliveryInfoModel!.deliveryDate.split("/")[2]+"-"+orderModel.deliveryInfoModel!.deliveryDate.split("/")[1]+"-"+orderModel.deliveryInfoModel!.deliveryDate.split("/")[0],
//         'deliveryTime': orderModel.deliveryInfoModel!.deliveryTime+":00"
//       } : null
//
//
//     };
//     print("dddddddddddddddddddddddddd server idddddddddddddddd: ${orderModel.serverId}}");
//     var response = await dio.put(ServerData.OPTIFOOD_BASE_URL+'/api/order/${orderModel.serverId}',
//       data: data,
//     ).then((response){
//       var mappedOrderModel = OrderModel.fromJsonServer(response.data);
//       orderModel.isSyncedOnServer=true;
//       // orderModel.isSyncOnServerProcessing=false;
//       OrderDao().updateOrder(orderModel);
//       // FBroadcast.instance().broadcast(ConstantBroadcastKeys.KEY_ORDER_SENT,value:orderModel);
//     }).catchError((err) async {
//       // orderModel.isSyncedOnServer=false;
//       // orderModel.isSyncOnServerProcessing=false;
//       // await OrderDao().updateOrder(orderModel);
//       // FBroadcast.instance().broadcast(ConstantBroadcastKeys.KEY_ORDER_SENT,value:orderModel);
//       // optifoodBackgroundService.syncPendingLocalData();
//     });
//   }
//
//
// }