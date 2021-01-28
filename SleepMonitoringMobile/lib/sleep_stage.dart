
import 'package:fl_animated_linechart/chart/animated_line_chart.dart';
import 'package:fl_animated_linechart/chart/line_chart.dart';
import 'package:flutter/material.dart';

class SleepMonitoring extends StatefulWidget {
 @override
  _SleepMonitoringState createState() => _SleepMonitoringState();

}

class _SleepMonitoringState extends State<SleepMonitoring> {
  LineChart chart;
  DateTime selectedDate = DateTime.now().subtract(Duration(days: 20));
  TimeOfDay selectedTime = TimeOfDay(hour: 22, minute: 40);
  TimeOfDay selectedTimeEnd = TimeOfDay(hour: 04, minute: 48);

  @override
  void initState() {
    super.initState();

  }

  @override
  Widget build(BuildContext context) {
    Map<DateTime, double> line1, line2, line3, line4, line5, line6;
  
    line1 = createLine1(0, 1, 2);
    line2 = createLine1(60, 2, 3);
    line3 = createLine1(120, 3, 2);
    line4 = createLine1(180, 2, 4);
    line5 = createLine1(240, 4, 1);
    line6 = createLine1(300, 1, 2);

    chart = LineChart.fromDateTimeMaps(
          [line1, line2, line3, line4, line5, line6], [Colors.grey, Colors.blue, Colors.deepPurple, Colors.blue, Colors.red, Colors.grey], ['Stage', 'Stage', 'Stage', 'Stage', 'Stage', 'Stage'],
          tapTextFontWeight: FontWeight.w400);
    return Scaffold(
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: 
        SingleChildScrollView(
          child: Container(
            height: 600,
        child: Column(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(8, 0, 8, 0),
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
                padding: const EdgeInsets.fromLTRB(8, 0, 8, 0),
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
                padding: const EdgeInsets.fromLTRB(0, 16, 8, 0),
                child: AnimatedLineChart(
                  chart,
                  key: UniqueKey(),
                ), //Unique key to force animations
              )),

              Padding(
                padding: const EdgeInsets.fromLTRB(8, 0, 8, 0),
                child: Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    IconButton(icon: new Icon(Icons.colorize), color: Colors.grey, onPressed: () => _selectTime(context, false)),
                    Text("Light"),
                    IconButton(icon: new Icon(Icons.colorize), color: Colors.blue, onPressed: () => _selectTime(context, false)),
                    Text("Deep"),
                    IconButton(icon: new Icon(Icons.colorize), color: Colors.deepPurple, onPressed: () => _selectTime(context, false)),
                    Text("REM"),
                    IconButton(icon: new Icon(Icons.colorize), color: Colors.red, onPressed: () => _selectTime(context, false)),
                    Text("Awake"),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(8, 8, 8, 8),
                child: Text("Sleep Quality : LEVEL 7",
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ),
              
              textBottom('2 hours 57 min', 'in bed', '10:37 PM', ' fell asleep'),
              SizedBox(height: 8),
              textBottom('02:46 AM', 'Awake', '97,77%', 'Sleep Efficiency'),
              SizedBox(height: 8),
              textBottom('1 hours 30 min', 'Total Light Sleep', '1 hours 01 min', 'Total Deep Sleep'),
              SizedBox(height: 8),
              textBottom('1 hours 0 min', 'Total REM', '1 hour 01 min', 'Total Awake')
            ]),
      ),
        )
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }

  Padding textBottom(String txt1, txt2, txt3, txt4) {
    return Padding(
                padding: const EdgeInsets.fromLTRB(8, 0, 8, 0),
                child: Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Expanded(
                      flex: 1,
                      child: Container(
                        width: MediaQuery.of(context).size.width * 0.35,
                        decoration: BoxDecoration(color: Colors.greenAccent),
                        child: FlatButton(onPressed: (){}, child: Text('\n\t\t\t\t$txt1\t\t\t\t\n$txt2\n', textAlign: TextAlign.center, style: TextStyle(color: Colors.white),), color: Colors.blue,),
                      ),
                    ),
                    SizedBox(width: 8),
                    Expanded(
                      flex: 1,
                      child: Container(
                        width: MediaQuery.of(context).size.width * 0.35,
                        decoration: BoxDecoration(color: Colors.greenAccent),
                        child: FlatButton(onPressed: (){}, child: Text('\n\t\t\t\t$txt3\t\t\t\t\n$txt4\n', textAlign: TextAlign.center, style: TextStyle(color: Colors.white),), color: Colors.blue,),
                      ),
                    ), 
                    SizedBox(height: 16), 
                  ],
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

  Map<DateTime, double> createLine1(int start, double status, double laststatus) {
    Map<DateTime, double> data = {};
    data[DateTime.now().add(Duration(minutes: start + 60))] = laststatus;

    data[DateTime.now().add(Duration(minutes: start + 45))] = status;
    data[DateTime.now().add(Duration(minutes: start + 30))] = status;
    data[DateTime.now().add(Duration(minutes: start + 15))] = status;
    data[DateTime.now().add(Duration(minutes: start))] = status;
    return data;
  }
}