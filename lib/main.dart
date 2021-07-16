//import 'package:universal_io/io.dart';
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_background/flutter_background.dart';
import 'package:signalr_core/signalr_core.dart';
import 'package:wakelock/wakelock.dart';
//import 'package:http/io_client.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'SignalR Testing'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {


  final androidConfig = FlutterBackgroundAndroidConfig(
    notificationTitle: "Title of the notification",
    notificationText: "Text of the notification",
    notificationImportance: AndroidNotificationImportance.Default,
    notificationIcon: AndroidResource(name: 'background_icon', defType: 'drawable'), // Default is ic_launcher from folder mipmap
  );



  var globalCounter = 0;

  @override
  void initState() {
    super.initState();


    //Wakelock.enable();

    //_initBackground();
    _buildServer();
  }

  _initBackground() async{
    bool success = await FlutterBackground.initialize(androidConfig: androidConfig);
    print("background init: "+  success.toString());
    print("already has permissions: " + FlutterBackground.hasPermissions.toString());


    await FlutterBackground.enableBackgroundExecution();


    if(!FlutterBackground.isBackgroundExecutionEnabled){
        print('retrying background');
        await FlutterBackground.enableBackgroundExecution();
    }


    Timer.periodic(new Duration(seconds: 1), (timer) {
      //debugPrint(timer.tick.toString());
      globalCounter++;
      print('$globalCounter  isBackground:  ${FlutterBackground.isBackgroundExecutionEnabled}');
    });
  }


  var connection;

  _buildServer() async {
     connection = HubConnectionBuilder().withUrl('http://192.168.216.45:5003/chatHub',
        HttpConnectionOptions(
          logging: (level, message) => print(message),
        )).withAutomaticReconnect().build();


   /*  this.connection.on("ReceiveMessage", (user, message) => {
      print(user + " " + message);
     });*/


  /*   connection.on('ReceiveMessage', (user, message) {
       //print(user);
       //print(message);
     });*/
     connection.on('ReceiveMessage', (message) {
       print("ReceiveMessage" +  message.toString());
     });

/*    await connection.start();

    connection.on('ReceiveMessage', (message) {
      print(message.toString());
    });

    await connection.invoke('SendMessage', args: ['Bob', 'Says hi!']);*/

  }

  var group = "rahat_group";
  var groupMessage = "group message";
  var pMessage = "personal message";
  var message = "message";

  _start() async{
     try {
       await this.connection.start();
       print("SignalR Connected.");
     } catch (err) {
       print(err);
       //setTimeout(this.start, 5000);
     }
  }

  //send({String? methodName, List<dynamic>? args}) => Future<void>
  //send({String? methodName, List<dynamic>? args}) => Future<void>
  //invoke(String, {List<dynamic>? args}) => Future<dynamic>

  _joinGroup() async{
    await this.connection.invoke('JoinGroup', args: ['habib', this.group]);
    //await this.connection.invoke('JoinGroup', args: ['habib', this.group]);
    //await connection.invoke('SendMessage', args: ['Bob', 'Says hi!']);

  }

  _sendToGroup() async{
    //await this.connection.invoke("GroupMsg", this.group, this.groupMessage);
    await this.connection.invoke('GroupMsg', args: ['rahat_group', this.groupMessage]);
  }

  _personalMessage() async{
    //await this.connection.invoke("PersonalMessage", "habib", this.pMessage);
    await this.connection.invoke('PersonalMessage', args: ['habib', this.pMessage]);
  }

  _broadcast() async{
    //await this.connection.invoke("BroadcastMsg", "habib", this.message);
    await this.connection.invoke('BroadcastMsg', args: ['habib', 'broadcast msg']);
  }

  changeText() {
    setState(() {
    });

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(

          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton(
                onPressed: () => changeText(),
                child: Text('Counter: $globalCounter')),
            ElevatedButton(
                onPressed: _start,
                child: Text('Start')),
            ElevatedButton(
                onPressed: _joinGroup,
                child: Text('Join Group')),
            ElevatedButton(
                onPressed: _sendToGroup,
                child: Text('Send To Group')),
            ElevatedButton(
                onPressed: _personalMessage,
                child: Text('Personal Message')),
            ElevatedButton(
                onPressed: _broadcast,
                child: Text('Broadcast'))
          ],
        ),
      ),
    );
  }
}
