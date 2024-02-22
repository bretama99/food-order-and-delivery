import 'package:dio/dio.dart';

class AppConfig{
  static get _databaseName => "optifood";
  static get databaseName => _databaseName;
  static DateTime dateTime = DateTime.now();
}
var baseUrl = "http://13.36.1.224:8092/api";
BaseOptions options = BaseOptions(
  baseUrl: baseUrl,
);
Dio dio = Dio(options);

getDB() async {
  var dbHeader = dio.options.headers['X-TenantID'] = AppConfig.databaseName;
  return dbHeader;
}
