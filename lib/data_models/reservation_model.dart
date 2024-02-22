import 'package:opti_food_app/database/reservation_dao.dart';

class ReservationModel{
  int id;
  String name;
  String phone;
  String reservationDate;
  String reservationTime;
  String typeOfReservation;
  int numberOfPersons;
  String comment;
  String status;
  bool isSynced;
  int? serverId;

  ReservationModel(
      this.id,
      this.name,
      this.phone,
      this.reservationDate,
      this.reservationTime,
      this.typeOfReservation,
      this.numberOfPersons,
      this.comment,
      this.status,{this.serverId=0,this.isSynced=false}
      );
  factory ReservationModel.fromJson(Map<String, dynamic> json) => ReservationModel(
    json[ReservationDao.columns.COL_ID],
    json[ReservationDao.columns.COL_NAME],
    json[ReservationDao.columns.COL_PHONE_NUMBER],
    json[ReservationDao.columns.COL_RESERVATION_DATE],
    json[ReservationDao.columns.COL_RESERVATION_TIME],
    json[ReservationDao.columns.COL_TYPE_OF_RESERVATION],
    json[ReservationDao.columns.COL_NO_OF_PERSONS],
    json[ReservationDao.columns.COL_COMMENT],
    json[ReservationDao.columns.COL_STATUS],
    serverId: json[ReservationDao.columns.COL_SERVER_ID],
    isSynced: json[ReservationDao.columns.COL_IS_SYNCED],
  );

  factory ReservationModel.fromJsonServer(Map<String, dynamic> json){
    return ReservationModel(
      json[ReservationDao.columns.COL_ID],
      json["name"],
      json["phone"],
      json["reservationDate"],
      json["reservationTime"],
      json["typeOfReservation"],
      json["numberOfPersons"],
      json["comment"],
      json["status"],
      serverId: json["reservationId"],
      isSynced: json[ReservationDao.columns.COL_IS_SYNCED]
    );
  }

  Map<String, dynamic> toJson() => {
    ReservationDao.columns.COL_ID: id,
    ReservationDao.columns.COL_NAME: name,
    ReservationDao.columns.COL_PHONE_NUMBER: phone,
    ReservationDao.columns.COL_RESERVATION_DATE: reservationDate,
    ReservationDao.columns.COL_RESERVATION_TIME: reservationTime,
    ReservationDao.columns.COL_TYPE_OF_RESERVATION: typeOfReservation,
    ReservationDao.columns.COL_NO_OF_PERSONS: numberOfPersons,
    ReservationDao.columns.COL_COMMENT: comment,
    ReservationDao.columns.COL_STATUS: status,
    ReservationDao.columns.COL_SERVER_ID: serverId,
    ReservationDao.columns.COL_IS_SYNCED: isSynced,
  };
}