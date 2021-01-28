/*
  {
    "result": "success",
    "code": 200,
    "userID": "2306"
}
*/
class Login {
  final String userID;
  final int code;
  final String result;
  final String username;

  Login({this.userID, this.code, this.result, this.username});

  factory Login.fromJson(Map<String, dynamic> json) {
    return Login(
      userID: json['userID'],
      code: json['code'],
      result: json['result'],
      username: json['username']
    );
  }
}