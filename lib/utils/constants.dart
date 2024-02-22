class ConstantOrderType {
  static const ORDER_TYPE_DELIVERY = "delivery";
  static const ORDER_TYPE_RESTAURANT = "restaurant";
}

class ConstantRestaurantOrderType {
  static const RESTAURANT_ORDER_TYPE_TAKEAWAY = "restaurant_order_type_takeaway";
  static const RESTAURANT_ORDER_TYPE_EAT_IN = "restaurant_order_type_eat_in";
}

class ConstantDeliveryOrderType {
  static const DELIVERY = "delivery";
}

class ConstantUserRole {
  static const USER_ROLE_MANAGER = "user_role_manager";
  static const USER_ROLE_DELIVERY_BOY = "user_role_delivery_boy";
  static const USER_ROLE_WAITER = "user_role_waiter";
}

class ConstantSharedPreferenceKeys{
  static const KEY_SELECTED_LANGUAGE = "key_selected_language";
  static const KEY_SELECTED_CURRENCY = "key_selected_currency";
  static const KEY_SELECTED_DECIMAL_SEPARATOR = "key_selected_decimal_separator";
  static const KEY_SELECTED_SYMBOL_LEFT_RIGHT = "key_selected_symbol_left_right";
  static const KEY_SELECTED_THOUSAND_SEPARATOR = "key_selected_thousand_separator";
  static const KEY_SELECTED_DATE_FORMAT = "key_selected_date_format";
  static const KEY_SELECTED_TIME_FORMAT = "key_selected_time_format";
  static const KEY_PRINTER_ACTIVATED = "key_printer_activated";
  //static const KEY_PRINTER_ACTIVATED_FOR_RESTAURANT = "key_printer_activated_for_restaurant";
  static const KEY_PRINTER_ACTIVATED_FOR_EAT_IN = "key_printer_activated_for_eat_id";
  static const KEY_PRINTER_ACTIVATED_FOR_TAKE_AWAY = "key_printer_activated_for_take_away";
  static const KEY_PRINTER_ACTIVATED_FOR_DELIVERY = "key_printer_activated_for_delivery";
  static const KEY_PRINTER_ACTIVATED_PRINCIPAL_TICKET = "key_printer_activated_principal_ticket";
  static const KEY_PRINTER_ACTIVATED_ORDER_NUMBER = "key_printer_activated_order_number";
  static const KEY_PRINTER_NUMBER_OF_TICKET = "key_printer_number_of_ticket";
  static const KEY_PRINTER_MAC_ADDRESS = "key_printer_mac_address";
  static const KEY_FIREBASE_TIMESTAMP = "key_firebase_timestamp";
  static const KEY_CURRENT_SHIFT_OPENING_DATE_TIME = "key_current_shift_opening_date_time";
}

class ConstantCurrencySymbol{
  static const EURO = "€";
  static const DOLLAR = "\$";
  static const POUND = "£";
  static const AED = "AED";
  static const DKK = "kr.";
  static const DA = "DA";
  static const MAD = "MAD";
}

class ConstantReservationStatus{
  static const STATUS_PENDING = "pending";
  static const STATUS_ARRIVED = "arrived";
}

class ServerData{
  //static const OPTIFOOD_BASE_URL = "http://13.36.1.224:8092";
  static const OPTIFOOD_BASE_URL = "https://api.optifood.app";


  //static const OPTIFOOD_MANAGEMENT_BASE_URL = "http://13.36.1.224:8090";
  static const OPTIFOOD_MANAGEMENT_BASE_URL = "https://manager.optifood.app";
  static const OPTIFOOD_MANAGEMENT_DATABASE = "optifood_management";
  static const OPTIFOOD_IMAGES = "http://13.36.1.224";
}

class ConstantBroadcastKeys{
  static const KEY_ORDER_SENT = "key_order_sent";
  static const KEY_UPDATE_UI = "key_update_ui";
}

class Privileges{
  static const adminPrivileges=["orders", "booking", "maps", "message", "chat", "report", "management", "settings", "logout",
    "restaurantMenu", 'customerManagement', 'userManagement', 'messageManagement', 'optifoodManagement', 'aPIIntegration',
  'menuManagement', 'productManagement', 'productAttributes', 'customerManagement', 'companyManagement', 'managerManagement',
  'deliveryBoyManagement', 'waiterManagement', 'takeawayMode', 'eatInMode', 'tableManagement', 'deliveryMode','deliveryFee',
  'nightModeManagement', 'takeawayMode'];

  static const managerPrivileges=["orders", "booking", "maps", "message", "chat", "management", "settings", "logout",
    "restaurantMenu", 'customerManagement', 'userManagement', 'messageManagement', 'optifoodManagement',
    'menuManagement', 'productManagement', 'productAttributes', 'customerManagement', 'companyManagement',
    'deliveryBoyManagement', 'waiterManagement', 'takeawayMode', 'eatInMode', 'tableManagement', 'deliveryMode','deliveryFee',
    'nightModeManagement', 'takeawayMode'];
}

class ConstantSyncOnServerPendingActions{
  static const ACTION_PENDING_CREATE = "action_pending_create";
  static const ACTION_PENDING_UPDATE = "action_pending_update";
}
