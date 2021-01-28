import 'dart:convert';

import 'package:SleepMonitoring/heart_rate.dart';
import 'package:SleepMonitoring/sleep_stage_new.dart';
import 'package:SleepMonitoring/static.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'FadeAnimation.dart';
import 'loginresponse.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
        // This makes the visual density adapt to the platform that you run
        // the app on. For desktop platforms, the controls will be smaller and
        // closer together (more dense) than on mobile platforms.
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> with SingleTickerProviderStateMixin {
  TabController controller;
  Future<Login> futureUser;
  @override
  void initState() {
     controller = new TabController(vsync: this, length: 2);
    super.initState();
  }
  var alradyLogin = false;
  var _username = '';
  var _password = '';
  var errorMessage = '';
  @override
  Widget build(BuildContext context) {
    return alradyLogin ? getWidgetLogin() : getWidgetNotLogin();
  }

  Future<Login> goLogin() async {
  setState(() {
    errorMessage = 'Loading...';  
  });
  final response =
      await http.post('${StaticValue.endpoint}login', 
      headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'username': _username,
        'password': _password
      }),);

  if (response.statusCode == 200) {
    var log = Login.fromJson(jsonDecode(response.body));
    if (log.code == 200){
      setState(() {
        StaticValue.user = log;
        alradyLogin = true;
      });
    }else{
      setState(() {
        alradyLogin = false;
        errorMessage = 'Login Gagal';
      });
    }
    return log;
  } else {
    print('Masuk 2');
    setState(() {
        alradyLogin = false;
        errorMessage = 'Login Gagal';
      });
    // If the server did not return a 200 OK response,
    // then throw an exception.
    throw Exception('Failed to load album');
  }
}

  Scaffold getWidgetLogin(){
      return new Scaffold(
      //create appBar
        appBar: new AppBar(
          //warna background
          backgroundColor: Colors.blue,
          //judul
          title: new Text("My Sleep Dashboard"),
            //bottom
            bottom: new TabBar(
              controller: controller,
              //source code lanjutan
              tabs: <Widget>[
                new Tab(icon: new Icon(Icons.date_range),text: "Sleep Quality",),
                new Tab(icon: new Icon(Icons.favorite),text: "Heart Monitoring",),
              ],
          ),
        ),
        body: new TabBarView(
          //controller untuk tab bar
          controller: controller,
          children: <Widget>[
            //kemudian panggil halaman sesuai tab yang sudah dibuat
            FlChartPage(),
            HeartRate(),
          ],
        ),
      );
  }

  Scaffold getWidgetNotLogin(){
      return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
      	child: Container(
	        child: Column(
	          children: <Widget>[
	            Container(
	              height: 400,
	              decoration: BoxDecoration(
	                image: DecorationImage(
	                  image: AssetImage('assets/background.png'),
	                  fit: BoxFit.fill
	                )
	              ),
	              child: Stack(
	                children: <Widget>[
	                  Positioned(
	                    left: 30,
	                    width: 80,
	                    height: 200,
	                    child: FadeAnimation(1, Container(
	                      decoration: BoxDecoration(
	                        image: DecorationImage(
	                          image: AssetImage('assets/light-1.png')
	                        )
	                      ),
	                    )),
	                  ),
	                  Positioned(
	                    left: 140,
	                    width: 80,
	                    height: 150,
	                    child: FadeAnimation(1.3, Container(
	                      decoration: BoxDecoration(
	                        image: DecorationImage(
	                          image: AssetImage('assets/light-2.png')
	                        )
	                      ),
	                    )),
	                  ),
	                  Positioned(
	                    child: FadeAnimation(1.6, Container(
	                      margin: EdgeInsets.only(top: 50),
	                      child: Center(
	                        child: Text("Login", style: TextStyle(color: Colors.white, fontSize: 40, fontWeight: FontWeight.bold),),
	                      ),
	                    )),
	                  )
	                ],
	              ),
	            ),
              FadeAnimation(1.5, Text("$errorMessage", style: TextStyle(color: Colors.red),)),
	            Padding(
	              padding: EdgeInsets.all(30.0),
	              child: Column(
	                children: <Widget>[
	                  FadeAnimation(1.8, Container(
	                    padding: EdgeInsets.all(5),
	                    decoration: BoxDecoration(
	                      color: Colors.white,
	                      borderRadius: BorderRadius.circular(10),
	                      boxShadow: [
	                        BoxShadow(
	                          color: Color.fromRGBO(143, 148, 251, .2),
	                          blurRadius: 20.0,
	                          offset: Offset(0, 10)
	                        )
	                      ]
	                    ),
	                    child: Column(
	                      children: <Widget>[
	                        Container(
	                          padding: EdgeInsets.all(8.0),
	                          decoration: BoxDecoration(
	                            border: Border(bottom: BorderSide(color: Colors.grey[100]))
	                          ),
	                          child: TextField(
                              decoration: InputDecoration(
	                              border: InputBorder.none,
	                              hintText: "Username",
	                              hintStyle: TextStyle(color: Colors.grey[400])
	                            ),
                              onChanged: (val) => _username = val,
	                          ),
	                        ),
	                        Container(
	                          padding: EdgeInsets.all(8.0),
	                          child: TextField(
                              obscureText: true,
	                            decoration: InputDecoration(
	                              border: InputBorder.none,
	                              hintText: "Password",
	                              hintStyle: TextStyle(color: Colors.grey[400])
	                            ),
                              onChanged: (val) => _password = val,
	                          ),
	                        )
	                      ],
	                    ),
	                  )),
	                  SizedBox(height: 30,),
                    GestureDetector(
                                onTap: () {
                                  print("goLogin");
                                  _username = 'patient-1';
                                  _password = '12345';
                                  if (_username.isEmpty || _password.isEmpty){
                                    setState(() {
                                      errorMessage = 'Masukkan Username & Password';
                                    });
                                  }else{
                                    futureUser = goLogin();
                                  }
                                },
                                child:  
                                      Padding(
                                      padding: const EdgeInsets.only(
                                          left: 16, right: 16.0),
                                      child:
                                      FadeAnimation(2, Container(
	                    height: 50,
	                    decoration: BoxDecoration(
	                      borderRadius: BorderRadius.circular(10),
	                      gradient: LinearGradient(
	                        colors: [
	                          Color.fromRGBO(143, 148, 251, 1),
	                          Color.fromRGBO(143, 148, 251, .6),
	                        ]
	                      )
	                    ),
	                    child: 
                      
                                      Center(
                                        child: Text("Login", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),),
                                      ),
                              
	                  )),
                                        ),
                              ),
	                  SizedBox(height: 70,),
	                  FadeAnimation(1.5, Text("Dashboard Sleep Monitoring.", style: TextStyle(color: Color.fromRGBO(143, 148, 251, 1)),)),
	                ],
	              ),
	            )
	          ],
	        ),
	      ),
      )
    );
  }

  void _showToast(BuildContext context) {
    final scaffold = Scaffold.of(context);
    scaffold.showSnackBar(
      SnackBar(
        content: const Text('Added to favorite'),
        action: SnackBarAction(
            label: 'UNDO', onPressed: scaffold.hideCurrentSnackBar),
      ),
    );
  }

}
