import 'package:flutter/material.dart';
import 'package:opti_food_app/data_models/attribute_category_model.dart';
import 'package:opti_food_app/data_models/attribute_model.dart';
import 'package:opti_food_app/data_models/company_model.dart';
import 'package:opti_food_app/data_models/contact_model.dart';
import 'package:opti_food_app/data_models/food_category_model.dart';
import 'package:opti_food_app/data_models/food_items_model.dart';
import 'package:opti_food_app/data_models/order_model.dart';
import 'package:opti_food_app/database/company_dao.dart';
import 'package:opti_food_app/database/food_category_dao.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sembast/sembast.dart';
import 'package:sembast/sembast_io.dart';
import 'package:path/path.dart';

import 'app_database.dart';
import 'attribute_category_dao.dart';

class ContactDao
{
  static _Columns columns = const _Columns();
  static _ColumnsAddresses columnsAddress = const _ColumnsAddresses();
  static const String folderName = "Contacts";
  final _contactFolder = intMapStoreFactory.store(folderName);

  Future<Database> get _db async => await AppDatabase.instance.database;


  Future<ContactModel> insertContact(ContactModel contactModel) async {
    //Database _db = await getDatabase();
      var key = await _contactFolder.add(await _db, contactModel.toJson());
      Finder finder = Finder(filter: Filter.byKey(key));
      contactModel.id = key;
      await _contactFolder.update(await _db, contactModel.toJson(),finder: finder);
      return contactModel;
  }

  Future<ContactModel> updateContact(ContactModel contactModel) async {
    //Database _db = await getDatabase();
    final finder = Finder(filter: Filter.byKey(contactModel.id));
    await _contactFolder.update(await _db, contactModel.toJson(), finder: finder);
    return contactModel;
  }

  Future delete(ContactModel contactModel) async {
    print("Delete customer ID: ${contactModel.id}");
    //Database _db = await getDatabase();
    //final finder = Finder(filter: Filter.byKey(order.id));
    final finder = Finder(filter: Filter.equals(columns.COL_ID, contactModel.id));
    //final finder = Finder(filter: Filter.equals(columns.COL_ID, order.id));
    await _contactFolder.delete(await _db, finder: finder);
  }

  Future<List<ContactModel>> getAllContacts() async {

    List<CompanyModel> companyModelList = await CompanyDao().getAllCompanies();
    final recordSnapshot = await _contactFolder.find(await _db);
    return recordSnapshot.map((snapshot){
      final contacts = ContactModel.fromJson(snapshot.value);
      contacts.contactAddressList.forEach((element) {
        //element.companyId = 1;
        if(element.companyId!=null&&element.companyId!=0 && companyModelList.where((e) => e.id==element.companyId || e.serverId==element.companyServerId).length>0){
          element.companyModel = companyModelList.where((e) =>
          e.id==element.companyId || e.serverId==element.companyServerId).first;
        }
        //element.primaryContactModel = contacts;
      });
      return contacts;
    }).toList();
  }

  Future<List<ContactModel>> getAllContactsByCompany(CompanyModel companyModel) async {
    final recordSnapshot = await _contactFolder.find(await _db,finder: Finder(filter: Filter.equals(columns.COL_CONTACT_ADDRESS, companyModel.id)));
    /*final recordSnapshot = await _contactFolder.find(await _db,finder: Finder(filter: Filter.custom((record){
      ContactModel contactModel = ContactModel.fromJson(record as Map<String,dynamic>);
      print(contactModel.serverId);
      return false;
    })));*/
    return recordSnapshot.map((snapshot){
      final contacts = ContactModel.fromJson(snapshot.value);
      // contacts. = companyModel;
      return contacts;
    }).toList();
    return [];
  }
  Future<int> getCount() async{
    //Database _db = await getDatabase();
    final recordSnapshot = await _contactFolder.find(await _db);
    return recordSnapshot.length;
  }
  Future<ContactModel?> getContactByPhoneNumber(String phoneNumber) async {
  //Future<bool> isPhoneNumberExist(String phoneNumber) async {
    //Database _db = await getDatabase();
    final recordSnapshot = await _contactFolder.find(await _db,finder: Finder(filter: Filter.equals(columns.COL_PHONE_NUMBER, phoneNumber)));
    if(recordSnapshot.isNotEmpty){
      return recordSnapshot.map((snapshot) {
        final contacts = ContactModel.fromJson(snapshot.value);
        return contacts;
      }).first;
    }
    else{
      return null;
    }
  }

  Future<ContactModel?> getCustomerByServerId(int serverId) async {
    // List<SortOrder> sortList = [];
    // sortList.add(SortOrder(columns.COL_ID));
    final recordSnapshot = await _contactFolder.find(await _db,finder: Finder(filter: Filter.equals(columns.COL_SERVER_ID, serverId)));

    if(recordSnapshot.length==0)
      return null;
    return recordSnapshot.map((snapshot) {
      final customer = ContactModel.fromJson(snapshot.value);
      return customer;
    }).first;
  }

  Future<ContactModel> getContactLast() async {
    // Database _db = await getDatabase();
    List<SortOrder> sortList = [];
    sortList.add(SortOrder(columns.COL_ID), );
    final recordSnapshot = await _contactFolder.find(await _db,finder: Finder(sortOrders: sortList));
    return recordSnapshot.map((snapshot) {
      final contact = ContactModel.fromJson(snapshot.value);
      return contact;
    }).toList()[recordSnapshot.length-1];
  }

  Future<ContactModel> getContactById(int id) async {
    final finder = Finder(filter: Filter.byKey(id));
    final recordSnapshot = await _contactFolder.find(await _db,finder: finder);
    return recordSnapshot.map((snapshot) {
      final contacts = ContactModel.fromJson(snapshot.value);
      return contacts;
    }).first;
  }

  /*Future<Database> getDatabase() async
  {
    final appDocumentDir = await getApplicationDocumentsDirectory();
    // Path with the form: /platform-specific-directory/demo.db
    final dbPath = join(appDocumentDir.path, 'Optifood_nosql.db');

    final database = await databaseFactoryIo.openDatabase(dbPath);
    return database;
  }*/
}
class _Columns
{
  const _Columns();
  String get COL_ID => "id";
  String get COL_FIRST_NAME => "first_name";
  String get COL_LAST_NAME => "last_name";
  //String get COL_ADDRESS => "address";
  String get COL_PHONE_NUMBER => "phone_number";
  String get COL_EMAIL => "email";
  String get COL_CONTACT_ADDRESS => "contact_address";
  //String get COL_COMPANY_ID => "company_id";
  String get COL_COMPANY_SERVER_ID => "company_server_id";
  //String get COL_COMPANY => "company";
  //String get COL_LAT => "lat";
  //String get COL_LON => "lon";
  String get COL_SERVER_ID => "server_id";
  String get COL_IS_SYNCED => "is_synced";
}
class _ColumnsAddresses{
  const _ColumnsAddresses();
  String get COL_ID => "id";
  String get COL_SERVER_ID => "server_id";
  String get COL_NAME => "name";
  String get COL_ADDRESS => "address";
  String get COL_LAT => "lat";
  String get COL_LON => "lon";
  String get COL_COMPANY_ID => "company_id";
  String get COL_COMPANY_SERVER_ID => "company_server_id";
  String get COL_IS_DEFAULT_ADDRESS => "is_default_address";
  String get COL_COMPANY => "company";
}