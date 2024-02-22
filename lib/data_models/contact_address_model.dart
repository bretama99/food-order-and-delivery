import 'package:opti_food_app/data_models/company_model.dart';

import '../database/contact_dao.dart';

class ContactAddressModel{
  int id;
  String name;
  String address;
  double lat;
  double lon;
  int companyId;
  int? companyServerId;
  CompanyModel? companyModel;
  int serverId = 0;
  bool isDefaultAddress = false;

  ContactAddressModel(this.id, this.name, this.address, this.lat, this.lon,
      this.companyId,{this.serverId = 0, this.companyModel = null, this.companyServerId,this.isDefaultAddress=false});

  ContactAddressModel.clone(ContactAddressModel contactAddressModelOriginal):
  this(
        contactAddressModelOriginal.id,
        contactAddressModelOriginal.name,
        contactAddressModelOriginal.address,
        contactAddressModelOriginal.lat,
        contactAddressModelOriginal.lon,
        contactAddressModelOriginal.companyId,
        serverId: contactAddressModelOriginal.serverId,
        companyModel: contactAddressModelOriginal.companyModel,
        companyServerId: contactAddressModelOriginal.companyServerId,
        isDefaultAddress: contactAddressModelOriginal.isDefaultAddress
      );

  factory ContactAddressModel.fromJson(Map<String, dynamic> json) {
    return ContactAddressModel(
      json[ContactDao.columnsAddress.COL_ID],
      json[ContactDao.columnsAddress.COL_NAME],
      json[ContactDao.columnsAddress.COL_ADDRESS],
      json[ContactDao.columnsAddress.COL_LAT],
      json[ContactDao.columnsAddress.COL_LON],
      json[ContactDao.columnsAddress.COL_COMPANY_ID],
      serverId:json[ContactDao.columnsAddress.COL_SERVER_ID],
      companyServerId:json[ContactDao.columns.COL_COMPANY_SERVER_ID],
      isDefaultAddress:json[ContactDao.columnsAddress.COL_IS_DEFAULT_ADDRESS],
      //companyModel: json[ContactDao.columnsAddress.COL_COMPANY]
      companyModel: json[ContactDao.columnsAddress.COL_COMPANY]!=null?CompanyModel.fromJson(json[ContactDao.columnsAddress.COL_COMPANY]):null
    );
  }

  factory ContactAddressModel.fromJsonServer(Map<String, dynamic> json) {
    return ContactAddressModel(
      1,
      json['name']!=null?json['name']:"",
      json["address"],
      json["latitude"],
      json["longitude"],
      json["companyId"],
      serverId:json["customerAddressId"],
        companyServerId:json["companyId"],
    /* companyModel: CompanyModel.fromJsonServer(json['companyResponseModel']==null
         || json['companyResponseModel']==""?
     {}:json['companyResponseModel']),*/
      companyModel: json['companyResponseModel']!=null?CompanyModel.fromJsonServer(json['companyResponseModel']):null
     // isDefaultAddress:json[ContactDao.columnsAddress.COL_IS_DEFAULT_ADDRESS],
    );
  }

  Map<String, dynamic> toJson() => {
    ContactDao.columnsAddress.COL_ID: id,
    ContactDao.columnsAddress.COL_NAME: name,
    ContactDao.columnsAddress.COL_ADDRESS: address,
    ContactDao.columnsAddress.COL_LAT: lat,
    ContactDao.columnsAddress.COL_LON: lon,
    ContactDao.columnsAddress.COL_COMPANY_ID: companyId,
    ContactDao.columns.COL_SERVER_ID:serverId,
    ContactDao.columns.COL_COMPANY_SERVER_ID:companyServerId,

    ContactDao.columnsAddress.COL_IS_DEFAULT_ADDRESS: isDefaultAddress,
    //ContactDao.columnsAddress.COL_COMPANY:companyModel?.toJson()
    ContactDao.columnsAddress.COL_COMPANY:companyModel!=null?companyModel!.toJson():null
  };
}