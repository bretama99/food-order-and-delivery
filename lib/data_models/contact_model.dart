

import '../database/contact_dao.dart';
import 'contact_address_model.dart';

class ContactModel{
  int id;
  String firstName;
  String lastName;
  //String address;
  String phoneNumber;
  String email;
  //double lat;
  //double lon;
  //int companyId = 0;
  //int? companyServerId;
  bool isSynced;
  int? serverId;
  //CompanyModel? companyModel;
  //List<ContactModel> extraAddressList = [];
  List<ContactAddressModel> contactAddressList = [];
  //ContactModel? primaryContactModel; //will not null only for extra addresses. and no need to save in database, will use only for extra address regrence

  //CompanyDao companyDao = CompanyDao();
  ContactModel(
      this.id,
      this.firstName,
      this.lastName,
      //this.address,
      this.phoneNumber,
      this.email,
      {
        this.serverId=0,
        //this.companyServerId,
        this.isSynced=false,
        this.contactAddressList = const [],
        //this.companyId=0,
        // this.companyModel=null,
        // this.lat=0,
        // this.lon=0,
        // this.primaryContactModel=null
      }
      );


  ContactAddressModel getDefaultAddress(){
    late ContactAddressModel contactAddressModel;
    for(int i=0;i<contactAddressList.length;i++){

    }
    if(contactAddressList.length>0){
      contactAddressModel = contactAddressList.first;
    }
    contactAddressList.forEach((element) {
      if (element.isDefaultAddress) {
        contactAddressModel = element;
      }
    });
    return contactAddressModel;
  }

  factory ContactModel.fromJson(Map<String, dynamic> json) {
    List contactAddresses = json[ContactDao.columns.COL_CONTACT_ADDRESS] as List;
    List<ContactAddressModel> contactAddressList = contactAddresses.map((e) => ContactAddressModel.fromJson(e)).toList();
    //String companyIDCol = ContactDao.columns.COL_COMPANY_ID;
    return ContactModel(
        json[ContactDao.columns.COL_ID],
        json[ContactDao.columns.COL_FIRST_NAME],
        json[ContactDao.columns.COL_LAST_NAME],
        //json[ContactDao.columns.COL_ADDRESS],
        json[ContactDao.columns.COL_PHONE_NUMBER],
        json[ContactDao.columns.COL_EMAIL],
        //companyServerId: json[ContactDao.columns.COL_COMPANY_SERVER_ID],
        serverId: json[ContactDao.columns.COL_SERVER_ID],
        isSynced:json[ContactDao.columns.COL_IS_SYNCED],
        //lat:json[ContactDao.columns.COL_LAT],
        //lon:json[ContactDao.columns.COL_LON],
        //extraAddressList: extraAddressList,
        contactAddressList: contactAddressList
      //companyId:json[companyIDCol]
    );
  }

  factory ContactModel.fromJsonServer(Map<String, dynamic> json) {
    List<ContactAddressModel> contactAddressList = [];
    if(json['customerAddressResponseModel']!=null) {
      //final contactAddresses = json['customerAddressResponseModel'] as List;
      List contactAddresses = json['customerAddressResponseModel'] as List;
      contactAddressList = contactAddresses.map((e) =>
          ContactAddressModel.fromJsonServer(e)).toList();
    }
    //String companyIDCol = ContactDao.columns.COL_COMPANY_ID;
    return ContactModel(
      0,//json["customerId"],
      json["firstName"],
      json["lastName"],
      json["phoneNumber"],
      //json["address"],
      json["email"],
      //companyServerId: json["companyId"],
      serverId: json["customerId"],
      isSynced:true,//json[ContactDao.columns.COL_IS_SYNCED],
      //lat:json["latitude"],
      //lon:json["longitude"],
      //extraAddressList: extraAddressList,
      contactAddressList: contactAddressList,
      //companyId:json["companyId"]
    );
  }

  Map<String, dynamic> toJson() => {
    ContactDao.columns.COL_ID: id,
    ContactDao.columns.COL_FIRST_NAME: firstName,
    ContactDao.columns.COL_LAST_NAME: lastName,
    //ContactDao.columns.COL_ADDRESS: address,
    ContactDao.columns.COL_PHONE_NUMBER: phoneNumber,
    ContactDao.columns.COL_EMAIL: email,
    //ContactDao.columns.COL_COMPANY_SERVER_ID:companyServerId,
    ContactDao.columns.COL_SERVER_ID:serverId,
    ContactDao.columns.COL_IS_SYNCED:isSynced,
    //ContactDao.columns.COL_EXTRA_ADDRESS: extraAddressList!=null?extraAddressList.map((e) => e.toJsonForExtraAddress()).toList(growable: true):[],
    ContactDao.columns.COL_CONTACT_ADDRESS: contactAddressList!=null?contactAddressList.map((e) => e.toJson()).toList(growable: true):[],
    //ContactDao.columns.COL_COMPANY_ID: companyId,
    //ContactDao.columns.COL_LAT: lat,
    //ContactDao.columns.COL_LON: lon
  };

  factory ContactModel.fromJsonForOrder(Map<String, dynamic> json){
    print(json);
    List contactAddresses = json[ContactDao.columns.COL_CONTACT_ADDRESS] as List;
    List<ContactAddressModel> contactAddressList = contactAddresses.map((e) => ContactAddressModel.fromJson(e)).toList();
    return ContactModel(
      json[ContactDao.columns.COL_ID],
      json[ContactDao.columns.COL_FIRST_NAME],
      json[ContactDao.columns.COL_LAST_NAME],
      //json[ContactDao.columns.COL_ADDRESS],
      json[ContactDao.columns.COL_PHONE_NUMBER],
      json[ContactDao.columns.COL_EMAIL],
      //companyServerId: json[ContactDao.columns.COL_COMPANY_SERVER_ID],
      serverId: json[ContactDao.columns.COL_SERVER_ID],
      contactAddressList: contactAddressList,
      //isSynced:json[ContactDao.columns.COL_IS_SYNCED],
      //companyModel:json[ContactDao.columns.COL_COMPANY]!=""?CompanyModel.fromJson(json[ContactDao.columns.COL_COMPANY]!):null,
      //lat:json[ContactDao.columns.COL_LAT],
      //lon:json[ContactDao.columns.COL_LON],
    );
  }

  factory ContactModel.fromJsonForOrderServer(Map<String, dynamic> json){
    return ContactModel(
      json['customerId'],
      json[ContactDao.columns.COL_FIRST_NAME],
      json[ContactDao.columns.COL_LAST_NAME],
      //json[ContactDao.columns.COL_ADDRESS],
      json[ContactDao.columns.COL_PHONE_NUMBER],
      json[ContactDao.columns.COL_EMAIL],
      // companyServerId: json[ContactDao.columns.COL_COMPANY_SERVER_ID],
      serverId: json[ContactDao.columns.COL_SERVER_ID],
      isSynced:json[ContactDao.columns.COL_IS_SYNCED],
      //companyModel:json[ContactDao.columns.COL_COMPANY]!=""?CompanyModel.fromJson(json[ContactDao.columns.COL_COMPANY]!):null,
      //lat:json[ContactDao.columns.COL_LAT],
      //lon:json[ContactDao.columns.COL_LON],
    );
  }

  Map<String, dynamic> toJsonForOrder() => {
    ContactDao.columns.COL_ID: id,
    ContactDao.columns.COL_FIRST_NAME: firstName,
    ContactDao.columns.COL_LAST_NAME: lastName,
    //ContactDao.columns.COL_ADDRESS: address,
    ContactDao.columns.COL_PHONE_NUMBER: phoneNumber,
    ContactDao.columns.COL_EMAIL: email,
    //ContactDao.columns.COL_COMPANY_SERVER_ID:companyServerId,
    ContactDao.columns.COL_SERVER_ID:serverId,
    ContactDao.columns.COL_IS_SYNCED:isSynced,
    ContactDao.columns.COL_CONTACT_ADDRESS: contactAddressList!=null?contactAddressList.map((e) => e.toJson()).toList(growable: true):[],
    //ContactDao.columns.COL_COMPANY: companyModel!=null?companyModel!.toJson():"",
    //ContactDao.columns.COL_LAT: lat,
    //ContactDao.columns.COL_LON: lon
  };

/*factory ContactModel.fromJsonForExtraAddress(Map<String, dynamic> json){
    return ContactModel(
        json[ContactDao.columns.COL_ID],
        json[ContactDao.columns.COL_FIRST_NAME],
        json[ContactDao.columns.COL_LAST_NAME],
        json[ContactDao.columns.COL_ADDRESS],
        json[ContactDao.columns.COL_PHONE_NUMBER],
        json[ContactDao.columns.COL_EMAIL],
      companyServerId: json[ContactDao.columns.COL_COMPANY_SERVER_ID],
      serverId: json[ContactDao.columns.COL_SERVER_ID],
      isSynced:json[ContactDao.columns.COL_IS_SYNCED],
        companyId:json[ContactDao.columns.COL_COMPANY_ID],
        lat:json[ContactDao.columns.COL_LAT],
        lon:json[ContactDao.columns.COL_LON],
    );
  }*/

/*Map<String, dynamic> toJsonForExtraAddress() => {
    ContactDao.columns.COL_ID: id,
    ContactDao.columns.COL_FIRST_NAME: firstName,
    ContactDao.columns.COL_LAST_NAME: lastName,
    ContactDao.columns.COL_ADDRESS: address,
    ContactDao.columns.COL_PHONE_NUMBER: phoneNumber,
    ContactDao.columns.COL_EMAIL: email,
    ContactDao.columns.COL_COMPANY_SERVER_ID:companyServerId,
    ContactDao.columns.COL_SERVER_ID:serverId,
    ContactDao.columns.COL_IS_SYNCED:isSynced,
    ContactDao.columns.COL_COMPANY_ID: companyId,
    ContactDao.columns.COL_LAT: lat,
    ContactDao.columns.COL_LON: lon
  };*/

/*factory ContactModel.fromJsonExtraAddressFromserver(Map<String, dynamic> json){
    return ContactModel(
      json['customerId'],
        json["firstName"],
        json["lastName"],
      json["address"],
        json["phoneNumber"],
        json["email"],
      companyServerId: json['companyId'],
      serverId: json['customerAddressId'],
      isSynced:json[ContactDao.columns.COL_IS_SYNCED],
      companyId:json["companyId"],
      lat:json['latitude'],
      lon:json['longitude'],
    );
  }*/
}