class HeartRateModel {
  String message;
  List<Data> data;

  HeartRateModel({this.message, this.data});

  HeartRateModel.fromJson(Map<String, dynamic> json) {
    message = json['message'];
    if (json['data'] != null) {
      data = new List<Data>();
      json['data'].forEach((v) {
        data.add(new Data.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['message'] = this.message;
    if (this.data != null) {
      data['data'] = this.data.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Data {
  int time;
  double heartRate;

  Data({this.time, this.heartRate});

  Data.fromJson(Map<String, dynamic> json) {
    time = json['time'];
    heartRate = double.parse("${json['heart_rate']}");
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['time'] = this.time;
    data['heart_rate'] = this.heartRate;
    return data;
  }
}