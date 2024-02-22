class OrderfeeModel
{
  double feeDelivery;
  double feeNightMode;
  int? serverId;


  OrderfeeModel(this.feeDelivery, this.feeNightMode,{this.serverId=0});

  factory OrderfeeModel.fromJson(Map<String, dynamic> json) => OrderfeeModel(
      json["feeDelivery"]!=null?json["feeDelivery"]:0,
      json["feeNightMode"]!=null?json["feeNightMode"]:0,
  );

  Map<String, dynamic> toJson() => {
    "feeDelivery": feeDelivery,
    "feeNightMode": feeNightMode,
    "serverId": serverId,
  };
}