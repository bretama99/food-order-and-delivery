class DeliveryInfoModel
{
  int assignedTo;
  String lat;
  String long;
  String deliveryDate;
  String deliveryTime;
  bool isSynced;
  int? serverId;


  DeliveryInfoModel(this.deliveryDate,this.deliveryTime,this.assignedTo,this.lat,this.long,{this.serverId=0,this.isSynced=false});

  factory DeliveryInfoModel.fromJson(Map<String, dynamic> json) => DeliveryInfoModel(
      json["deliveryDate"],
      json["deliveryTime"],
      json["assignedTo"],
      json["lat"]!=null?json["lat"]:"0",
      json["long"]!=null?json["long"]:"0",
      serverId: json["orderDeliveryDataId"]
  );

  Map<String, dynamic> toJson() => {
    "deliveryDate": deliveryDate,
    "deliveryTime": deliveryTime,
    "assignedTo": assignedTo,
    "lat" : lat,
    "long" : long,
  };
}