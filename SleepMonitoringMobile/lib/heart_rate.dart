
import 'package:SleepMonitoring/heart_rate_model.dart';
import 'package:SleepMonitoring/static.dart';
import 'package:fl_animated_linechart/chart/animated_line_chart.dart';
import 'package:fl_animated_linechart/chart/line_chart.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';

class HeartRate extends StatefulWidget {
 @override
  _HeartRateState createState() => _HeartRateState();

}

class _HeartRateState extends State<HeartRate> {
  Map<DateTime, double> line1;
  LineChart chart;
  DateTime selectedDate = DateTime.now().subtract(Duration(days: 19));
  TimeOfDay selectedTime = TimeOfDay.now();
  TimeOfDay selectedTimeEnd = TimeOfDay.now();
  bool isPatient = !StaticValue.user.username.contains('doctor');
  var selectedPatient = StaticValue.user.username.contains('doctor') ? "Patient-1" : "${StaticValue.user.username}";
  var errorMessage = '';
  var _userID = '2306';
  var _date = '2020-12-28 22:00:00';
  HeartRateModel dataHeartRate;
  var already = false;
  @override
  void initState() {
    super.initState();
    _date = selectedDate.toIso8601String();

    line1 = createLine2();

    chart = LineChart.fromDateTimeMaps(
          [line1], [Colors.green], [''],
          tapTextFontWeight: FontWeight.w900,);

    if (!already) {
      getHeartRateDate();
      already = true;
    }
  }

  Future<HeartRateModel> getHeartRateDate() async {
  setState(() {
    errorMessage = 'Loading...';  
  });
  final response =
      await http.post('${StaticValue.endpoint}getHeartRateData', 
      headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'userID': _userID,
        'date': _date
      }),);
  print("ISI RESPONSE ${response.body}");

  if (response.statusCode == 200) {
    var log = HeartRateModel.fromJson(jsonDecode(response.body));
        dataHeartRate = log;
        line1 = createLine2();
        setState(() {
          chart = LineChart.fromDateTimeMaps(
          [line1], [Colors.green], [''],
          tapTextFontWeight: FontWeight.w900,);
        });
    return log;
  } else {
    print('Masuk 2');
    setState(() {
        errorMessage = 'Failed to load data';
      });
    // If the server did not return a 200 OK response,
    // then throw an exception.
    throw Exception('Failed to load data');
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Container(
        child: Column(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children : <Widget>[
              isPatient ? 
          IconButton(icon: new Icon(Icons.person), onPressed: () => _selectDate(context)) : IconButton(icon: new Icon(Icons.people), onPressed: () => _selectDate(context)),    
                if (!isPatient)
                  new DropdownButton<String>(
                    value: selectedPatient,
                    style: TextStyle(color: Colors.blue[900], fontSize: 15, fontWeight: FontWeight.bold),
                    items: <String>['Patient-1', 'Patient-2', 'Patient-3'].map((String value) {
                      return new DropdownMenuItem<String>(
                        value: value,
                        child: new Text(value),
                      );
                    }).toList(),
                    onChanged: ( val ) {
                      setState(() {
                        selectedPatient = val;
                      });
                    },
                  ),
                  if(isPatient)
                  Text(
                    '\n\t\t$selectedPatient\n',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.blue[900], fontSize: 15, fontWeight: FontWeight.bold),
                  ),

                ]),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    Text("Date : "),
                    Text(
                      "${selectedDate.toLocal()}".split(' ')[0],
                      style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                    ),
                    IconButton(icon: new Icon(Icons.mode_edit), onPressed: () => _selectDate(context)),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
                child: Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    Text("Start Time : "),
                    Text(
                      "${selectedTime.hour.toString()} : ${selectedTime.minute.toString()}",
                      style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                    ),
                    IconButton(icon: new Icon(Icons.mode_edit), onPressed: () => _selectTime(context, true)),
                    Text("End Time : "),
                    Text(
                      "${selectedTimeEnd.hour.toString()} : ${selectedTimeEnd.minute.toString()}",
                      style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                    ),
                    IconButton(icon: new Icon(Icons.mode_edit), onPressed: () => _selectTime(context, false))
                  ],
                ),
              ),
              Expanded(
                  child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: AnimatedLineChart(
                  chart,
                  key: UniqueKey(),
                ), //Unique key to force animations
              )),
              Text("Sumbu X : Waktu, Sumbu Y : ECG"),
            ]),
      ),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }

  _selectDate(BuildContext context) async {
    final DateTime picked = await showDatePicker(
      context: context,
      initialDate: selectedDate, // Refer step 1
      firstDate: DateTime(2000),
      lastDate: DateTime(2025),
    );
    if (picked != null && picked != selectedDate)
      setState(() {
        selectedDate = picked;
        getHeartRateDate();
      });
}

 Future<Null> _selectTime(BuildContext context, bool isStart) async {
    final TimeOfDay picked = await showTimePicker(
      context: context,
      initialTime: isStart ? selectedTime : selectedTimeEnd,
    );
    if (picked != null)
      setState(() {
        if (isStart){
          selectedTime = picked;
        }else{
          selectedTimeEnd = picked;
        }
      });
  }

  Map<DateTime, double> createLine2() {
    Map<DateTime, double> data = {};
    if (dataHeartRate != null){
      dataHeartRate.data.forEach((element) {
          data[DateTime.fromMillisecondsSinceEpoch(element.time)] = element.heartRate;
      });
      return data;
    }

    //if API not available  
    
    data[DateTime.now().add(Duration(minutes: 20))] = 0.82;
    data[DateTime.now().add(Duration(minutes: 19))] = 0.83;
    data[DateTime.now().add(Duration(minutes: 18))] = 0.82;
    data[DateTime.now().add(Duration(minutes: 17))] = 0.82;
    data[DateTime.now().add(Duration(minutes: 16))] = 0.82;
    data[DateTime.now().add(Duration(minutes: 15))] = 0.81;
    data[DateTime.now().add(Duration(minutes: 14))] = 0.79;
    data[DateTime.now().add(Duration(minutes: 13))] = 0.80;
    data[DateTime.now().add(Duration(minutes: 12))] = 0.80;
    data[DateTime.now().add(Duration(minutes: 11))] = 0.81;
    data[DateTime.now().add(Duration(minutes: 10))] = 0.82;
    data[DateTime.now().add(Duration(minutes: 9))] = 0.82;
    data[DateTime.now().add(Duration(minutes: 8))] = 0.82;
    data[DateTime.now().add(Duration(minutes: 7))] = 0.81;
    data[DateTime.now().add(Duration(minutes: 6))] = 0.81;
    data[DateTime.now().add(Duration(minutes: 5))] = 0.80;
    data[DateTime.now().add(Duration(minutes: 4))] = 0.79;
    data[DateTime.now().add(Duration(minutes: 3))] = 0.79;
    data[DateTime.now().add(Duration(minutes: 2))] = 0.8;
    data[DateTime.now().add(Duration(minutes: 1))] = 0.82;
    return data;
  }
}

extension TimeOfDayExtension on TimeOfDay {
  TimeOfDay add({int hour = 0, int minute = 0}) {
    return this.replacing(hour: this.hour + hour, minute: this.minute + minute);
  }
}