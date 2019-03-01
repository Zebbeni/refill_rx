import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:refill_rx/home.dart';

void main() {
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);
  runApp(new MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Refill RX',
      theme: new ThemeData(
        primarySwatch: Colors.blue,
        fontFamily: 'Arial',
      ),
      home: new MyHomePage(title: 'Refill RX'),
    );
  }
}