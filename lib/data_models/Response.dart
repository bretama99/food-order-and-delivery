class Response{
  final String message;
  final bool error;
final int code;
final List<Result> result;
final int status;
const Response({required this.message,required this.error, required this.code,required this.result,required this.status});

factory Response.fromJson(Map<String, dynamic> json) {
List<Result> data = [];
data = json["result"]
    .map<Result>((json) => Result.fromJson(json))
    .toList();

return Response(
message:json['message'],
error: json['error'],
code: json['code'],
result: data,
status: json['status']
);
}
}

class Result{
  final int id;
  final String name;

  const Result({ required this.id,required this.name});

  factory Result.fromJson(Map<String, dynamic> json) {
    return Result(
      id: json['code'],
      name:json['name'],
    );
  }
}