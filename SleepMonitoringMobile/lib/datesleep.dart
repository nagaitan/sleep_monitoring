class DateSleepQuality {
  String message;
  Data data;

  DateSleepQuality({this.message, this.data});

  DateSleepQuality.fromJson(Map<String, dynamic> json) {
    message = json['message'];
    data = json['data'] != null ? new Data.fromJson(json['data']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['message'] = this.message;
    if (this.data != null) {
      data['data'] = this.data.toJson();
    }
    return data;
  }
}

class Data {
  String quality;
  String awake;
  String rem;
  String lightsleep;
  String deepsleep;
  String inbed;
  String fellasleep;
  String awakeat;
  String sleepefficiency;
  List<Stage> stage;

  Data(
      {
      this.quality,
      this.awake,
      this.rem,
      this.lightsleep,
      this.deepsleep,
      this.inbed,
      this.fellasleep,
      this.awakeat,
      this.sleepefficiency,
      this.stage});

  Data.fromJson(Map<String, dynamic> json) {
    quality = json['quality'];
    awake = json['awake'];
    rem = json['rem'];
    lightsleep = json['lightsleep'];
    deepsleep = json['deepsleep'];
    inbed = json['inbed'];
    fellasleep = json['fellasleep'];
    awakeat = json['awakeat'];
    sleepefficiency = json['sleepefficiency'];
    if (json['stage'] != null) {
      stage = new List<Stage>();
      json['stage'].forEach((v) {
        stage.add(new Stage.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['quality'] = this.quality;
    data['awake'] = this.awake;
    data['rem'] = this.rem;
    data['lightsleep'] = this.lightsleep;
    data['deepsleep'] = this.deepsleep;
    data['inbed'] = this.inbed;
    data['fellasleep'] = this.fellasleep;
    data['awakeat'] = this.awakeat;
    data['sleepefficiency'] = this.sleepefficiency;
    if (this.stage != null) {
      data['stage'] = this.stage.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Stage {
  int time;
  int stage;

  Stage({this.time, this.stage});

  Stage.fromJson(Map<String, dynamic> json) {
    time = json['time'];
    stage = json['stage'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['time'] = this.time;
    data['stage'] = this.stage;
    return data;
  }
}