class DeliveryBoys {
  late int id;
  late String name;
  late double latitude;
  late double longitude;
  late String imagePath;
  late String phoneNumber;
  late String adress;
  late int orderNumber;
  late bool isOrder;
  late bool isSynced;
  int? serverId;
  late String? email;

  DeliveryBoys({
    required this.id,
    required this.name,
    required this.latitude,
    required this.longitude,
    required this.imagePath,
    required this.phoneNumber,
    required this.adress,
    required this.orderNumber,
    required this.isOrder,
    required this.email

  });

}