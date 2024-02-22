import 'package:dio/dio.dart';
import '../../utils/constants.dart';
import '../data_models/contact_model.dart';
import '../data_models/order_model.dart';
import '../database/contact_dao.dart';
import '../database/order_dao.dart';
import '../main.dart';
class ContactApis {
  Function? callBack;

  ContactApis({this.callBack});

  static String OPTIFOOD_DATABASE = optifoodSharedPrefrence.getString("database").toString();
  static String authorization = optifoodSharedPrefrence.getString("accessToken").toString();
  /*static getContactListFromServer({required Function oncall1}) async {
    List<ContactModel> fetchedData = [];
    final dio = Dio();
    dio.options.headers['X-TenantID'] = OPTIFOOD_DATABASE;
    await dio.get(ServerData.OPTIFOOD_BASE_URL + "/api/customer").then((
        response) async {
      List<ContactModel> fetchedData = [];
      if (response.statusCode == 200) {
        for (int i = 0; i < response.data.length; i++) {
          var singleItem = ContactModel.fromJsonServer(response.data[i]);
          fetchedData.add(singleItem);
        }


        for (int i = 0; i < fetchedData.length; i++) {
          ContactDao().getAllContacts().then((value) {
            // var result=null;
            // if(value.length>0)
            //   result=value.firstWhere((element) => element.serverId==fetchedData[i].serverId);
            // if(result!=null){
            //   result?.serverId=fetchedData[i].serverId;
            //   result?.firstName=fetchedData[i].firstName;
            //   result?.lastName=fetchedData[i].lastName;
            //   result?.phoneNumber=fetchedData[i].phoneNumber;
            //   result?.email=fetchedData[i].email;
            //   result?.lat=fetchedData[i].lat;
            //   result?.lon=fetchedData[i].lon;
            //   result?.address=fetchedData[i].address;
            //   result?.companyId=fetchedData[i].companyId;
            //   result?.isSynced=true;
            //   result?.serverId=fetchedData[i].serverId;
            //   OrderDao().updateOrder(result!);
            // }
            // else{
            ContactModel contactModel = ContactModel(
                fetchedData[i].id, fetchedData[i].firstName,
                fetchedData[i].lastName, fetchedData[i].address,
                fetchedData[i].phoneNumber, fetchedData[i].email,
                serverId: fetchedData[i].serverId,
                isSynced: fetchedData[i].isSynced);
            contactModel.isSynced = true;
            ContactDao().insertContact(contactModel);

            // }
          });
        }
      }
    });
  }*/
}