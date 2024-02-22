import '../database/company_dao.dart';

class CompanyModel{
  int id = 0;
  String name;
  String? phoneNo;
  String? address;
  String? email;
  String? imagePath;
  bool isSynced;
  int? serverId;
  
  CompanyModel(this.name,{this.serverId=0,this.isSynced=false,this.phoneNo,this.address,this.email,this.id=0,this.imagePath});
  factory CompanyModel.fromJson(Map<String, dynamic> json){
    return CompanyModel(
        json[CompanyDao.columns.COL_NAME],
        serverId: json[CompanyDao.columns.COL_SERVER_ID],
        isSynced:json[CompanyDao.columns.COL_IS_SYNCED],
        phoneNo:json[CompanyDao.columns.COL_PHONE_NO],
        address:json[CompanyDao.columns.COL_ADDRESS],
        email:json[CompanyDao.columns.COL_EMAIL],
        id:json[CompanyDao.columns.COL_ID],
        imagePath:json[CompanyDao.columns.COL_IMAGE_PATH]
    );
  }

  factory CompanyModel.fromJsonServer(Map<String, dynamic> json){
    return CompanyModel(
        json["companyName"],
        serverId: json["companyId"],
        //isSynced:json[CompanyDao.columns.COL_IS_SYNCED],
        isSynced:true,
        phoneNo:json["phoneNumber"],
        address:json["address"],
        email:json["email"],
        id:json["companyId"],
        imagePath:json["image"]
    );
  }

  Map<String, dynamic> toJson() => {
    CompanyDao.columns.COL_ID: id,
    CompanyDao.columns.COL_NAME:name,
    CompanyDao.columns.COL_SERVER_ID:serverId,
    CompanyDao.columns.COL_IS_SYNCED:isSynced,
    CompanyDao.columns.COL_ADDRESS: address,
    CompanyDao.columns.COL_EMAIL: email,
    CompanyDao.columns.COL_PHONE_NO:phoneNo,
    CompanyDao.columns.COL_IMAGE_PATH:imagePath
  };
}