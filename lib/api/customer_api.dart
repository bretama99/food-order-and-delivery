import 'package:fbroadcast/fbroadcast.dart';
import 'package:opti_food_app/data_models/restaurant_info_model.dart';
import 'package:opti_food_app/database/restaurant_info_dao.dart';
import 'package:dio/dio.dart';
import '../../utils/constants.dart';
import '../data_models/contact_address_model.dart';
import '../data_models/contact_model.dart';
import '../database/contact_dao.dart';
import '../main.dart';

class CustomerApis {
  static String OPTIFOOD_DATABASE=optifoodSharedPrefrence.getString("database").toString();
  static String authorization = optifoodSharedPrefrence.getString("accessToken").toString();
  void saveContactToSever(ContactModel contactModel) {
      final dio = Dio();
      dio.options.headers['X-TenantID'] = OPTIFOOD_DATABASE;
      dio.options.headers['Authorization'] = authorization;
      dio.post(ServerData.OPTIFOOD_BASE_URL+"/api/customer",
        data: {
          "lastName":contactModel.lastName,
          "firstName":contactModel.firstName,
          "phoneNumber":contactModel.phoneNumber,
          "email":contactModel.email,
          /*"address":contactModel.address,
          "companyId":contactModel.companyId,
          "latitude":contactModel.lat,
          "longitude":contactModel.lon,*/
          "customerAddressRequestModel" :
            {
              "address":contactModel.getDefaultAddress().address,
              "companyId":contactModel.getDefaultAddress().companyId,
              "companyServerId":contactModel.getDefaultAddress().serverId,
              "latitude":contactModel.getDefaultAddress().lat,
              "longitude":contactModel.getDefaultAddress().lon,
            }
        },
      ).then((response){
        print("=====contactModel.serverId=singleData.serverId================================================");

        var singleData = ContactModel.fromJsonServer(response.data);
        contactModel.isSynced=true;
        contactModel.serverId=singleData.serverId;
        print("=====contactModel.serverId=singleData.serverId=================${singleData.serverId}================================");
        contactModel.contactAddressList=singleData.contactAddressList;
        contactModel.contactAddressList.first.serverId=singleData.contactAddressList.first.serverId;
        ContactDao().updateContact(contactModel).then((value333) {
          FBroadcast.instance().broadcast(
              ConstantBroadcastKeys.KEY_UPDATE_UI, value: contactModel);
         // if(callBack!=null)
         //  callBack!();
        });

      }).catchError((onError){

        // if(callBack!=null)
        //     callBack!();
      });
  }

  void getCustomerFromServer({Function? callback = null}) async {
    final dio = Dio();
    dio.options.headers['X-TenantID'] = OPTIFOOD_DATABASE;
    dio.options.headers['Authorization'] = authorization;

    await dio.get(ServerData.OPTIFOOD_BASE_URL+"/api/customer").then((response) async {
      if (response.statusCode == 200) {
        saveCustomerDataFromServerToLocalDB(response.data, callback: () {
          //callback!();
        });
      }
      if(callback!=null){
        callback();
      }
//       List<ContactModel> fetchedData = [];
//       if (response.statusCode == 200) {
//         print("=============response.data.length==========${response.data.length}==============================");
//
//         for (int i = 0; i < response.data.length; i++) {
//           var singleItem = ContactModel.fromJsonServer(response.data[i]);
//           if(singleItem.contactAddressList.isEmpty){
//             continue;
//           }
//           fetchedData.add(singleItem);
//         }
//
//
//         for (int i = 0; i < fetchedData.length; i++) {
//            ContactDao().getCustomerByServerId(fetchedData[i].serverId!).then((
//                 value) {
//             /*ContactModel contactModel = ContactModel(
//               fetchedData[i].id,
//               fetchedData[i].lastName,
//               fetchedData[i].firstName,
//               fetchedData[i].phoneNumber,
//               fetchedData[i].address,
//               fetchedData[i].email,
//                 companyServerId:fetchedData[i].companyServerId,
//                 companyId:fetchedData[i].companyId,
//               serverId: fetchedData[i].serverId,
//               extraAddressList: fetchedData[i].extraAddressList
//             );*/
//             // fetchedData[i].contactAddressList[0].isDefaultAddress=true;
//             ContactModel contactModel = ContactModel(
//                 fetchedData[i].id,
//                 fetchedData[i].firstName,
//                 fetchedData[i].lastName,
//                 fetchedData[i].phoneNumber,
//                 fetchedData[i].email,
//                 contactAddressList:fetchedData[i].contactAddressList,
//                 serverId: fetchedData[i].serverId,
//             );
//
//               if (value!=null) {
//                 /*value.lastName=fetchedData[i].lastName;
//                 value.serverId=fetchedData[i].serverId;
//                 value.firstName=fetchedData[i].firstName;
//                 value.phoneNumber = fetchedData[i].phoneNumber;
//                 value.address = fetchedData[i].address;
//                 value.email=fetchedData[i].email;
//                 value.companyId = fetchedData[i].companyId;
//                 value.companyServerId = fetchedData[i].companyServerId;
//                 value.extraAddressList=fetchedData[i].extraAddressList;
// */
//                 ContactDao()
//                     .updateContact(value)
//                     .then((res1) {
//                   if (i == fetchedData.length - 1) {
//                   }
//                 });
//               }
//               else {
//                 ContactDao().insertContact(contactModel).then((
//                     res2) {
//                   if (i == fetchedData.length - 1) {
//                   }
//                 });
//               }
//             });
//           }
//       }
//       if(callback!=null){
//         callback();
//       }
    }).catchError((onError){
      if(callback!=null){
        callback();
      }
    });
  }

  Future<void> saveCustomerAddress(ContactModel primaryContact,ContactAddressModel contactAddressModel) async {
    final dio = Dio();
    dio.options.headers['X-TenantID'] = OPTIFOOD_DATABASE;
    dio.options.headers['Authorization'] = authorization;
    var response = await dio.post(ServerData.OPTIFOOD_BASE_URL+"/api/customer-address",
      data: {
        "customerId":primaryContact.serverId,
        "companyId":contactAddressModel.companyServerId,
        "name":contactAddressModel.name,
        "latitude":contactAddressModel.lat,
        "longitude":contactAddressModel.lon,
        "address":contactAddressModel.address,
      },
    ).then((response){
      Map<String,dynamic> map = response.data;
      contactAddressModel.serverId = map['customerAddressId'];
      ContactDao().updateContact(primaryContact);
    }).catchError((onError){
    });
  }

  static saveCustomerDataFromServerToLocalDB(var responseData, {Function? callback = null}){


      List<ContactModel> fetchedData = [];
      for (int i = 0; i < responseData.length; i++) {
        var singleItem = ContactModel.fromJsonServer(responseData[i]);
        if(singleItem.contactAddressList.isEmpty){
          continue;
        }
        if(responseData[i]['deleted']==true) {
          print("Now check for delete customer ${responseData[i]['deleted']}");
          ContactDao().getCustomerByServerId(singleItem.serverId!).then((value){
            if(value!=null) {
              ContactDao().delete(value!);
            }
          });
        }
        else
          fetchedData.add(singleItem);
      }


      for (int i = 0; i < fetchedData.length; i++) {
        ContactDao().getCustomerByServerId(fetchedData[i].serverId!).then((
            value) {
          ContactModel contactModel = ContactModel(
            fetchedData[i].id,
            //value!.id,
            fetchedData[i].firstName,
            fetchedData[i].lastName,
            fetchedData[i].phoneNumber,
            fetchedData[i].email,
            contactAddressList:fetchedData[i].contactAddressList,
            serverId: fetchedData[i].serverId,
          );

          if (value!=null) {
            contactModel.id = value!.id;
            ContactDao()
                .updateContact(contactModel)
                .then((res1) {
              if (i == fetchedData.length - 1) {
              }
            });
          }
          else {
            ContactDao().insertContact(contactModel).then((
                res2) {
              if (i == fetchedData.length - 1) {
              }
            });
          }
          FBroadcast.instance().broadcast(
              ConstantBroadcastKeys.KEY_UPDATE_UI);
        });
      }
    if(callback!=null){
      callback();
    }
  }
  Future<void> deleteContact(int serverId) async {
    final dio = Dio();
    dio.options.headers['X-TenantID'] = OPTIFOOD_DATABASE.toString();
    await dio.delete(ServerData.OPTIFOOD_BASE_URL+"/api/customer/${serverId}").then((value){
    });
  }
}