var http = require('http');
var express = require("express");
const bodyParser = require('body-parser');
var app = express();
app.use(bodyParser.json());
// const nacl = require('tweetnacl')
// nacl.util = require('tweetnacl-util')
// var mysql = require('mysql');
// var crypto = require('crypto');
// var aesjs = require('aes-js');
// var pg = require('pg');
const { Pool, Client } = require('pg')
const connectionString = "postgres://medandig_ecg:SleepMonitoring@123@medandigitalcenter.com:5432/medandig_ecg_monitor";

/*
var connection = mysql.createConnection({
  host     : 'localhost',
  user     : 'medandig_sleeper',
  password : 'Sleeper@123',
  database : 'medandig_sleep_monitoring'
});
*/

/*
const Pool = require('pg').Pool
const pool = new Pool({
  user: 'medandig_ecg',
  host: 'medandigitalcenter.com',
  database: 'medandig_ecg_monitor',
  password: 'SleepMonitoring@123',
  port: 5432,
  ssl : true
})

/*
var client = new pg.Client({
  user: "medandig_ecg_monitor",
  password: "SleepMonitoring@123",
  database: "medandig_ecg_monitor",
  port: 5432,
  host: "https://www.medandigitalcenter.com",
  ssl: true
}); 
client.connect();
*/

/*
//setup firebase
const admin = require('firebase-admin');
        
const serviceAccount = require('./sleepmonitoring-292107-30561417ee19.json');

admin.initializeApp({
    credential: admin.credential.cert(serviceAccount),
    databaseURL: "https://sleepmonitoring-292107.firebaseio.com"
});

const db = admin.firestore();
*/

var objUser = {
  "patient-1": "12345",
  "patient-2": "12345",
  "doctor": "12345"
};

var objUserID = {
  "patient-1": "2304",
  "patient-2": "2305",
  "doctor": "2306"
};

app.get('/hello', (req, res) => {
  res.json({"result" : "data received"});
})

//by week, data is dummy, need to be connected to database 
app.post('/getSleepQualityByWeek', (req, res) => {
  // if (req.body.date != "2020-12-28"){
  //   res.json({
  //     "message" : "Data is not available for Selected Date",
  //     "userID" : objUserID[req.body.username]
  //   });
  // }
  res.json({
    "message" : "Success",
    "userID" : objUserID[req.body.username],
    "data" : {
      "quality" : "8",
      "awake" : "12%\n57m",
      "rem" : "17%\n1h20m",
      "lightsleep" : "57%\n4h31m",
      "deepsleep" : "15%\n1h11m",
      "inbed": "4h57m",
      "fellasleep" : "11:37pm",
      "awakeat" : "06:40am",
      "sleepefficiency" : "87,7%",
      "sleepquality" : getWeeklySleepDataByDate(req.body.username, req.body.date)
    }
  });
})

//by date
app.post('/getSleepQualityByDate', (req, res) => {
  // if (req.body.date != "2020-12-28"){
  //   res.json({
  //     "message" : "Data is not available for Selected Date",
  //     "userID" : objUserID[req.body.username]
  //   });
  // }

  //4 = Awake, 3 = REM, 2 = LIGHTSLEEP, 1 = DEEPSLEEP

  res.json({
    "message" : "Success",
    "userID" : objUserID[req.body.username],
    "data" : {
      "quality" : "8",
      "awake" : "12%\n57m",
      "rem" : "17%\n1h20m",
      "lightsleep" : "57%\n4h31m",
      "deepsleep" : "15%\n1h11m",
      "inbed": "4h57m",
      "fellasleep" : "11:37pm",
      "awakeat" : "06:40am",
      "sleepefficiency" : "87,7%",
      "stage": getSleepDataByDate(req.body.username, req.body.date)
    }
  });
})

//by date
app.post('/getHeartRateData', (req, res) => {
  res.json({
    "message" : "Success",
    "userID" : objUserID[req.body.username],
    "data" : getHeartRateData(req.body.username, req.body.date)
  });
})

//send user id & get key symmetric
app.post('/login', (req, res) => {

  if (req.body.password == ""+objUser[req.body.username]){
      res.json(
        {
          "message" : "success",
          "code" : 200,
          "userID" : "2305",
          "username" : req.body.username
        });
  }

  res.json(
    {
      "result" : "failed",
      "code" : 401
    });
})

function getSleepDataByDate(userId, date){
  var sleepData = [];
  const d = new Date(date);
  var tempD = new Date(date);
  
  for (var i = 0; i < 16; i++) {
    if (i == 0 || i == 15) {
      sleepData.push({"time" : tempD.setMinutes (tempD.getMinutes() + i * 30), "stage" : 4})
    }else {
      sleepData.push({"time" : tempD.setMinutes (tempD.getMinutes() + i * 30), "stage" : Math.floor(Math.random() * 4) + 1})
    }
  }
  return sleepData;
}

function getWeeklySleepDataByDate(userId, date){
  var sleepData = [];
  var tempD = new Date(date);
  
  for (var i = 0; i < 7; i++) {
    sleepData.push({"time" : tempD.addDays(i), "quality" : "" + getInterval(7,8)})
  }
  return sleepData;
}

function getHeartRateData(userId, date){
  var sleepData = [];
  var tempD = new Date(date);
  
  for (var i = 0; i < 20; i++) {
    sleepData.push({"time" : tempD.setSeconds (tempD.getSeconds() + i * 3), "heart_rate" : getInterval(60,90)/10})
  }
  return sleepData;
}


function getInterval(min, max) { // min and max included 
  return Math.floor(Math.random() * (max - min + 1) + min);
}

var JsonToArray = function(json)
{
	var str = JSON.stringify(json, null, 0);
	var ret = new Uint8Array(32);
	for (var i = 0; i < 32; i++) {
    ret[""+i] = json[""+i];
	}
	return ret
};

Date.prototype.addDays = function(days) {
  var date = new Date(this.valueOf());
  date.setDate(date.getDate() + days);
  return date;
}

var JsonNonceToArray = function(json)
{
	var str = JSON.stringify(json, null, 0);
	var ret = new Uint8Array(24);
	for (var i = 0; i < 24; i++) {
    ret[""+i] = json[""+i];
	}
	return ret
};

Date.prototype.addMinutes = function(minutes) {
  this.setMinutes(this.getMinutes() + minutes);
  return this;
};

var JsonMsgToArray = function(json, panjang)
{
	var str = JSON.stringify(json, null, 0);
	var ret = new Uint8Array(panjang);
	for (var i = 0; i < panjang; i++) {
    ret[""+i] = json[""+i];
	}
	return ret
};

app.listen(5000, () => {
 console.log("Server running on port 5000");
});


// var server = http.createServer(function(req, res) {
//     res.writeHead(200, {'Content-Type': 'text/plain'});
//     var message = 'It works!\n',
//         version = 'NodeJS ' + process.versions.node + '\n',
//         response = [message, version].join('\n');
//     res.end(response);
// });
// server.listen();

