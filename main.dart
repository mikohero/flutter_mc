import 'package:flutter/material.dart';
import 'MyMap.dart';
import 'AutoMyMap.dart';
import 'MyFirstPage.dart';
import 'ShowMaps.dart';
import 'Settings.dart';
import 'MyMapStart.dart';
import 'MyCamera1.dart';
import 'Splash.dart';
import 'MyMapCamera1.dart';


void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
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
        '/MyMap': (context) => MyMap(),
        '/AutoMyApp': (context) => AutoMyApp(),
        '/MyShowMaps': (context) => MyShowMaps(),
        '/MySettings': (context) => MySettings(),
      },
    );
  }
}
