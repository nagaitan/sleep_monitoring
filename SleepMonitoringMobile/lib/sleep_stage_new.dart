import 'package:SleepMonitoring/format.dart';
import 'package:SleepMonitoring/static.dart';
import 'package:SleepMonitoring/weeksleep.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'datesleep.dart';
import 'dart:convert';
import 'package:intl/intl.dart';

class FlChartPage extends StatefulWidget {
  @override
  _FlChartPageState createState() => _FlChartPageState();
}

class _FlChartPageState extends State<FlChartPage> {

  List<Color> gradientColors = [
    Colors.red,
    Colors.blue[200],
    Colors.blue[400],
    Colors.blue[400],
    Colors.blue[200],
    Colors.blue[200],
    Colors.blue[400],
    Colors.blue[400],
    Colors.blue[200],
    Colors.green,
    Colors.blue[200],
    Colors.blue[400],
    Colors.green,
    Colors.red,
    Colors.red,
    Colors.red,
  ];

  bool showAvg = false;
  var errorMessage = '';
  var _userID = '2306';
  var _date = '2020-12-28 22:00:00';
  DateSleepQuality _dataSleep;
  WeekSleepQuality _weekleepQuality;

  DateTime selectedDate = DateTime.now().subtract(Duration(days: 20));
  final Duration animDuration = const Duration(milliseconds: 250);
  int touchedIndex;
  bool isPatient = !StaticValue.user.username.contains('doctor');
  var selectedPatient = StaticValue.user.username.contains('doctor') ? "Patient-1" : "${StaticValue.user.username}";
  var already = false;

  @override
  void initState() {
    super.initState();
    _date = selectedDate.toIso8601String();
    if (!already) {
      getSleepDataByDate();
      getSleepDataByWeek();
      already = true;
    }
  }


  @override
  Widget build(BuildContext context) {
    return 
    SingleChildScrollView(
     child: SafeArea(
      child: Column(
        children: <Widget>[
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
          //daily
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children : <Widget>[
          Expanded(
            flex: 1,
            child: 
          FlatButton(
            color: Colors.blue[100],
            
            child: 
            Row(children: <Widget>[
                Text(
                "Daily : " + "${Format.date(selectedDate)}",
                  style: TextStyle(
                    fontSize: 16,
                      color:
                          Colors.black),
                ),
                IconButton(icon: new Icon(Icons.mode_edit), onPressed: () => _selectDate(context)),
            ],),
            onPressed: () {
              print('click');
              setState(() {
                showAvg = !showAvg;
              });
            },
          ),),
          
          ]),
          SizedBox(height: 16,),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
                Icon(Icons.indeterminate_check_box, color: Colors.red,),
                Text(
                  'Awake \n${_dataSleep != null ? _dataSleep.data.awake : '-'}',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      color:
                          Colors.black),
                ),
                SizedBox(
                  width: 16,
                ),
                Icon(Icons.indeterminate_check_box, color: Colors.green,),
                Text(
                  'REM \n${_dataSleep != null ? _dataSleep.data.rem : '-'}',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      color:
                          Colors.black),
                ),
                SizedBox(
                  width: 16,
                ),
                Icon(Icons.indeterminate_check_box, color: Colors.blue[200],),
                Text(
                  'Light Sleep \n${_dataSleep != null ? _dataSleep.data.lightsleep : '-'}',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      color:
                          Colors.black),
                ),
                SizedBox(
                  width: 16,
                ),
                Icon(Icons.indeterminate_check_box, color: Colors.blue[400],),
                Text(
                  'Deep Sleep \n${_dataSleep != null ? _dataSleep.data.deepsleep : '-'}',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      color:
                          Colors.black),
                ),
            ],
          ),
          SizedBox(height : 16),
          AspectRatio(
            aspectRatio: 3 / 2,
            child: Container(
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(
                    Radius.circular(10),
                  ),
                  color: Color(0xff232d37)),
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 20, horizontal: 10),
                child: LineChart(
                  mainChart(),
                ),
              ),
            ),
          ),
          SizedBox(
                  height: 16,
                ),
          Text( 
            'Sleep Quality ${_dataSleep != null ? _dataSleep.data.quality : '-'}',
                  textAlign: TextAlign.left,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                      color:
                          Colors.black),
                ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
                Container(
                  margin: const EdgeInsets.all(8.0),
                  padding: const EdgeInsets.all(3.0),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.blueAccent)
                  ),
                  child: 
                      Text(
                        'In Bed \n${_dataSleep != null ? _dataSleep.data.inbed : '-'}',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color:
                                Colors.black),
                      ),
                ),
                Container(
                  margin: const EdgeInsets.all(8.0),
                  padding: const EdgeInsets.all(3.0),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.blueAccent)
                  ),
                  child: 
                      Text(
                        'Fell Asleep \n${_dataSleep != null ? _dataSleep.data.fellasleep : '-'}',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color:
                                Colors.black),
                      ),
                ),
                Container(
                  margin: const EdgeInsets.all(8.0),
                  padding: const EdgeInsets.all(3.0),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.blueAccent)
                  ),
                  child:         
                  Text(
                    'Awake \n${_dataSleep != null ? _dataSleep.data.awakeat : '-'}',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        color:
                            Colors.black),
                  ),
                ),
                Container(
                  margin: const EdgeInsets.all(8.0),
                  padding: const EdgeInsets.all(3.0),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.blueAccent)
                  ),
                  child:         
                  Text(
                    'Sleep Efficiency \n${_dataSleep != null ? _dataSleep.data.sleepefficiency : '-'}',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        color:
                            Colors.black),
                  ),
                ),
            ],
          ),
          SizedBox(height: 16),
          //weekly
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children : <Widget>[
          Expanded(
            flex: 1,
            child: 
          FlatButton(
            color: Colors.blue[100],
            
            child: 
            Row(children: <Widget>[
                Text(
                "Weekly : " + "${Format.date(selectedDate)}" + " to " + "${Format.date(selectedDate.add(Duration(days: 6)))}",
                  style: TextStyle(
                    fontSize: 16,
                      color:
                          Colors.black),
                ),
                IconButton(icon: new Icon(Icons.mode_edit), onPressed: () => _selectDate(context)),
            ],),
            onPressed: () {
              print('click');
              setState(() {
                showAvg = !showAvg;
              });
            },
          ),),
          
          ]),
          SizedBox(height: 16),
          _weekly(),
          Text(
                  'Sleep Quality Average: LEVEL : ${_weekleepQuality == null ? '-' : _weekleepQuality.data.quality}',
                  textAlign: TextAlign.left,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                      color:
                          Colors.black),
                ),

          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
                Container(
                  margin: const EdgeInsets.all(8.0),
                  padding: const EdgeInsets.all(3.0),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.blueAccent)
                  ),
                  child: 
                      Text(
                        'Avg. In Bed \n ${_weekleepQuality == null ? '-' : _weekleepQuality.data.inbed}',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color:
                                Colors.black),
                      ),
                ),
                Container(
                  margin: const EdgeInsets.all(8.0),
                  padding: const EdgeInsets.all(3.0),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.blueAccent)
                  ),
                  child: 
                      Text(
                        'Avg. Fell Asleep \n${_weekleepQuality == null ? '-' : _weekleepQuality.data.fellasleep}',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color:
                                Colors.black),
                      ),
                ),
                Container(
                  margin: const EdgeInsets.all(8.0),
                  padding: const EdgeInsets.all(3.0),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.blueAccent)
                  ),
                  child:         
                  Text(
                    'Avg. Awake \n${_weekleepQuality == null ? '-' : _weekleepQuality.data.awake}',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        color:
                            Colors.black),
                  ),
                ),
            ],
          ),

          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
                Container(
                  margin: const EdgeInsets.all(8.0),
                  padding: const EdgeInsets.all(3.0),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.blueAccent)
                  ),
                  child: 
                      Text(
                        'Avg.Sleep Efficiency\n${_weekleepQuality == null ? '-' : _weekleepQuality.data.sleepefficiency}',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color:
                                Colors.black),
                      ),
                ),
                Container(
                  margin: const EdgeInsets.all(8.0),
                  padding: const EdgeInsets.all(3.0),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.blueAccent)
                  ),
                  child: 
                      Text(
                        'Total Light Sleep \n${_weekleepQuality == null ? '-' : _weekleepQuality.data.lightsleep}',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color:
                                Colors.black),
                      ),
                ),
            ],
          ),

          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
                Container(
                  margin: const EdgeInsets.all(8.0),
                  padding: const EdgeInsets.all(3.0),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.blueAccent)
                  ),
                  child: 
                      Text(
                        'Total Deep Sleep \n${_weekleepQuality == null ? '-' : _weekleepQuality.data.deepsleep}',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color:
                                Colors.black),
                      ),
                ),
                Container(
                  margin: const EdgeInsets.all(8.0),
                  padding: const EdgeInsets.all(3.0),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.blueAccent)
                  ),
                  child: 
                      Text(
                        'Total REM \n${_weekleepQuality == null ? '-' : _weekleepQuality.data.rem}',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color:
                                Colors.black),
                      ),
                ),
                Container(
                  margin: const EdgeInsets.all(8.0),
                  padding: const EdgeInsets.all(3.0),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.blueAccent)
                  ),
                  child: 
                      Text(
                        'Total Awake \n${_weekleepQuality == null ? '-' : _weekleepQuality.data.awake}',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color:
                                Colors.black),
                      ),
                ),
            ],
          ),

        ],
      ),
    ), 
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
        _date = selectedDate.add(Duration(days: 1)).toIso8601String();
        getSleepDataByDate();
        getSleepDataByWeek();
      });
}

Future<DateSleepQuality> getSleepDataByDate() async {
  setState(() {
    errorMessage = 'Loading...';  
  });
  final response =
      await http.post('${StaticValue.endpoint}getSleepQualityByDate', 
      headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'userID': _userID,
        'date': _date
      }),);
  print("ISI RESPONSE ${response.body}");

  if (response.statusCode == 200) {
    var log = DateSleepQuality.fromJson(jsonDecode(response.body));
      setState(() {
        _dataSleep = log;
        gradientColors.clear();
        int i = 0;
        for (i = 0; i < _dataSleep.data.stage.length; i ++){
          gradientColors.add(getStageColor(_dataSleep.data.stage[i].stage));
        }
      });
      print("ISI STAGES ${_dataSleep.data.stage}");
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

Future<WeekSleepQuality> getSleepDataByWeek() async {
  setState(() {
    errorMessage = 'Loading...';  
  });
  final response =
      await http.post('${StaticValue.endpoint}getSleepQualityByWeek', 
      headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'userID': _userID,
        'date': _date
      }),);
  
  if (response.statusCode == 200) {
    var log = WeekSleepQuality.fromJson(jsonDecode(response.body));
      setState(() {
        _weekleepQuality = log;
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

Color getStageColor(int stage){
  if (stage == 4){
      return Colors.red;
  }else if (stage == 3){
      return Colors.green;
  }else if (stage == 2){
    return Colors.blue[200];
  }else if (stage == 1){
    return Colors.blue[400];
  }
  return Colors.red;
}

  LineChartData mainChart() {
    return LineChartData(
      gridData: FlGridData(
        show: true,
        drawVerticalLine: true,
        getDrawingHorizontalLine: (value) {
          return FlLine(
            color: Color(0xff37434d),
            strokeWidth: 1,
          );
        },
        getDrawingVerticalLine: (value) {
          return FlLine(
            color: Color(0xff37434d),
            strokeWidth: 1,
          );
        },
      ),
      titlesData: FlTitlesData(
        show: true,
        bottomTitles: SideTitles(
          showTitles: true,
          reservedSize: 22,
          textStyle: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 14),
          getTitles: (value) {
            print('bottomTitles $value');
            switch (value.toInt()) {
              case 1:
                return '10:00 PM';
              case 7:
                return '3 AM';
              case 13:
                return '7:00 AM';
            }
            return '';
          },
          margin: 8,
        ),
        leftTitles: SideTitles(
          showTitles: true,
          textStyle: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
          getTitles: (value) {
            print('leftTitles $value');
            switch (value.toInt()) {
              case 1:
                return 'Deep Sleep';
              case 2:
                return 'Light Sleep';
              case 3:
                return 'REM';
              case 4:
                return 'Awake';
            }
            return '';
          },
          reservedSize: 28,
          margin: 12,
        ),
      ),
      borderData: FlBorderData(
          show: true,
          border: Border.all(color: const Color(0xff37434d), width: 1)),
      minX: 0,
      maxX: 15,
      minY: 0,
      maxY: 4,
      lineBarsData: [
        LineChartBarData(
          spots: (_dataSleep == null) ? [
            FlSpot(0, 4),
            FlSpot(1, 4),
            FlSpot(2, 2),
            FlSpot(3, 1),
            FlSpot(4, 1),
            FlSpot(5, 2),
            FlSpot(6, 1),
            FlSpot(7, 1),
            FlSpot(8, 2),
            FlSpot(9, 3),
            FlSpot(10, 2),
            FlSpot(11, 1),
            FlSpot(12, 3),
            FlSpot(13, 4),
            FlSpot(14, 4),
            FlSpot(15, 4),
          ] : [
            FlSpot(0, _dataSleep.data.stage[0].stage.toDouble()),
            FlSpot(1, _dataSleep.data.stage[1].stage.toDouble()),
            FlSpot(2, _dataSleep.data.stage[2].stage.toDouble()),
            FlSpot(3, _dataSleep.data.stage[3].stage.toDouble()),
            FlSpot(4, _dataSleep.data.stage[4].stage.toDouble()),
            FlSpot(5, _dataSleep.data.stage[5].stage.toDouble()),
            FlSpot(6, _dataSleep.data.stage[6].stage.toDouble()),
            FlSpot(7, _dataSleep.data.stage[7].stage.toDouble()),
            FlSpot(8, _dataSleep.data.stage[8].stage.toDouble()),
            FlSpot(9, _dataSleep.data.stage[9].stage.toDouble()),
            FlSpot(10, _dataSleep.data.stage[10].stage.toDouble()),
            FlSpot(11, _dataSleep.data.stage[11].stage.toDouble()),
            FlSpot(12, _dataSleep.data.stage[12].stage.toDouble()),
            FlSpot(13, _dataSleep.data.stage[13].stage.toDouble()),
            FlSpot(14, _dataSleep.data.stage[14].stage.toDouble()),
            FlSpot(15, _dataSleep.data.stage[15].stage.toDouble()),
          ],
          isCurved: true,
          colors: gradientColors,
          barWidth: 5,
          isStrokeCapRound: true,
          dotData: FlDotData(
            show: true,
          ),
          belowBarData: BarAreaData(
            show: true,
            colors:
                gradientColors.map((color) => color.withOpacity(0.3)).toList(),
          ),
        ),
      ],
    );
  }

  List<BarChartGroupData> showingGroups() => List.generate(7, (i) {
        switch (i) {
          case 0:
            return makeGroupData(0, 5, isTouched: i == touchedIndex);
          case 1:
            return makeGroupData(1, 6.5, isTouched: i == touchedIndex);
          case 2:
            return makeGroupData(2, 5, isTouched: i == touchedIndex);
          case 3:
            return makeGroupData(3, 7.5, isTouched: i == touchedIndex);
          case 4:
            return makeGroupData(4, 9, isTouched: i == touchedIndex);
          case 5:
            return makeGroupData(5, 11.5, isTouched: i == touchedIndex);
          case 6:
            return makeGroupData(6, 6.5, isTouched: i == touchedIndex);
          default:
            return null;
        }
      });

    BarChartGroupData makeGroupData(
    int x,
    double y, {
    bool isTouched = false,
    Color barColor = Colors.white,
    double width = 22,
    List<int> showTooltips = const [],
  }) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          y: isTouched ? y + 1 : y,
          width: width,
          backDrawRodData: BackgroundBarChartRodData(
            show: true,
            y: 20,
          ),
        ),
      ],
      showingTooltipIndicators: showTooltips,
    );
  }

  Widget _weekly(){
    return AspectRatio(
      aspectRatio: 1.7,
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
        color: const Color(0xff2c4260),
        child: BarChart(
          BarChartData(
            alignment: BarChartAlignment.spaceAround,
            maxY: 20,
            barTouchData: BarTouchData(
              enabled: false,
              touchTooltipData: BarTouchTooltipData(
                tooltipBgColor: Colors.transparent,
                tooltipPadding: const EdgeInsets.all(0),
                tooltipBottomMargin: 8,
                getTooltipItem: (
                  BarChartGroupData group,
                  int groupIndex,
                  BarChartRodData rod,
                  int rodIndex,
                ) {
                  return BarTooltipItem(
                    rod.y.round().toString(),
                    TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  );
                },
              ),
            ),
            titlesData: FlTitlesData(
              show: true,
              bottomTitles: SideTitles(
                showTitles: true,
                textStyle: TextStyle(
                  color: Colors.white
                ),
                margin: 20,
                getTitles: (double value) {
                  if (_weekleepQuality == null){
                  switch (value.toInt()) {
                    case 0:
                      return 'Mon';
                    case 1:
                      return 'Tue';
                    case 2:
                      return 'Wed';
                    case 3:
                      return 'Thu';
                    case 4:
                      return 'Fri';
                    case 5:
                      return 'Sat';
                    case 6:
                      return 'Sun';
                    default:
                      return '';
                  }
                  }else{
                    final DateFormat formatter = DateFormat('MMMd');
                    final String formatted = formatter.format(DateTime.parse(_weekleepQuality.data.sleepquality[value.toInt()].time));

                    return formatted;
                  }
                },
              ),
              leftTitles: SideTitles(showTitles: false),
            ),
            borderData: FlBorderData(
              show: false,
            ),
            barGroups: 
            _weekleepQuality == null ?
            [
              BarChartGroupData(
                x: 0,
                barRods: [
                  BarChartRodData(y: 7, color: Colors.blue)
                ],
                showingTooltipIndicators: [0],
              ),
              BarChartGroupData(
                x: 1,
                barRods: [
                  BarChartRodData(y: 8, color: Colors.blue)
                ],
                showingTooltipIndicators: [0],
              ),
              BarChartGroupData(
                x: 2,
                barRods: [
                  BarChartRodData(y: 8, color: Colors.blue)
                ],
                showingTooltipIndicators: [0],
              ),
              BarChartGroupData(
                x: 3,
                barRods: [
                  BarChartRodData(y: 7, color: Colors.blue)
                ],
                showingTooltipIndicators: [0],
              ),
              BarChartGroupData(
                x: 4,
                barRods: [
                  BarChartRodData(y: 8, color: Colors.blue)
                ],
                showingTooltipIndicators: [0],
              ),
              BarChartGroupData(
                x: 5,
                barRods: [
                  BarChartRodData(y: 8, color: Colors.blue)
                ],
                showingTooltipIndicators: [0],
              ),
              BarChartGroupData(
                x: 6,
                barRods: [
                  BarChartRodData(y: 8, color: Colors.blue)
                ],
                showingTooltipIndicators: [0],
              ),
            ] : 
            //from API
            [
              BarChartGroupData(
                x: 0,
                barRods: [
                  BarChartRodData(y: double.parse(_weekleepQuality.data.sleepquality[0].quality), color: Colors.blue)
                ],
                showingTooltipIndicators: [0],
              ),
              BarChartGroupData(
                x: 1,
                barRods: [
                  BarChartRodData(y: double.parse(_weekleepQuality.data.sleepquality[1].quality), color: Colors.blue)
                ],
                showingTooltipIndicators: [0],
              ),
              BarChartGroupData(
                x: 2,
                barRods: [
                  BarChartRodData(y: double.parse(_weekleepQuality.data.sleepquality[2].quality), color: Colors.blue)
                ],
                showingTooltipIndicators: [0],
              ),
              BarChartGroupData(
                x: 3,
                barRods: [
                  BarChartRodData(y: double.parse(_weekleepQuality.data.sleepquality[3].quality), color: Colors.blue)
                ],
                showingTooltipIndicators: [0],
              ),
              BarChartGroupData(
                x: 4,
                barRods: [
                  BarChartRodData(y: double.parse(_weekleepQuality.data.sleepquality[4].quality), color: Colors.blue)
                ],
                showingTooltipIndicators: [0],
              ),
              BarChartGroupData(
                x: 5,
                barRods: [
                  BarChartRodData(y: double.parse(_weekleepQuality.data.sleepquality[5].quality), color: Colors.blue)
                ],
                showingTooltipIndicators: [0],
              ),
              BarChartGroupData(
                x: 6,
                barRods: [
                  BarChartRodData(y: double.parse(_weekleepQuality.data.sleepquality[6].quality), color: Colors.blue)
                ],
                showingTooltipIndicators: [0],
              ),
            ],
          ),
        ),
      ),
    );
  }

}
