import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'MyMapCamera2.dart';
import'dart:io' show Platform;
//import 'MyMap.dart';
//import 'AutoMyMap.dart';
//import 'MyFirstPage.dart';
//import 'ShowMaps.dart';
import 'SendDataToServer.dart';
//import 'MyMapStart.dart';
//import 'MyCamera1.dart';
//import 'Splash.dart';
import 'MyMapCamera1.dart';
import 'MyMapCamera1a.dart';
//import 'SendDataToServer.dart';
import 'PhotoCheck.dart';


void main() {
  if(Platform.isIOS){
    runApp(MyApp1(isIOS: Platform.isIOS));
  }else if(Platform.isAndroid){
    runApp(MyApp(isAndroid: Platform.isAndroid));
  }
}

class MyApp extends StatelessWidget {
  final bool isAndroid;
  MyApp({Key key, @required this.isAndroid}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        // Define the default brightness and colors.
        brightness: Brightness.dark,
        primaryColor: Colors.lightBlue[800],
        accentColor: Colors.deepPurple,
        // Define the default font family.
        fontFamily: 'Georgia',

        // Define the default TextTheme. Use this to specify the default
        // text styling for headlines, titles, bodies of text, and more.
        textTheme: TextTheme(
          headline1: TextStyle(fontSize: 72.0, fontWeight: FontWeight.bold),
          headline6: TextStyle(fontSize: 36.0, fontStyle: FontStyle.italic),
          bodyText2: TextStyle(fontSize: 14.0, fontFamily: 'Hind'),
        ),
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => MyMapCamera(),
        '/MySettings': (context) => MySendData(),
        '/MyMap': (context) => MyMapCamera1a(),
        '/MyPhoto': (context) => MyPhotoControl(),
      },
    );
  }
}

class MyApp1 extends StatelessWidget {
  final bool isIOS;
  MyApp1({Key key, @required this.isIOS}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CupertinoApp(
      theme: CupertinoThemeData(
        brightness: Brightness.light,
        primaryColor: Colors.lightBlue,
        textTheme: CupertinoTextThemeData(

        ),
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => MyMapCamera2(),
        '/MySettings': (context) => MySendData(),
      },
    );
  }
}
