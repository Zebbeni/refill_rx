import 'dart:async';

import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:refill_rx/date_prescribed.dart';
import 'package:refill_rx/dose.dart';
import 'package:refill_rx/prescribed.dart';
import 'package:refill_rx/result.dart';
import 'package:refill_rx/taper.dart';

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

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => new _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  DateTime _datePrescribed = new DateTime.now();
  int _numberPrescribed = 0;
  double _dosePerDay = 0.0;
  Taper _taper = new Taper(1, 0);
  DateTime _today;

  TextStyle _inputStyle() {
    return TextStyle(
      color: Colors.blue,
      fontWeight: FontWeight.bold,
      fontSize: 17.0,
    );
  }

  String _dateString(DateTime dateTime) {
    return DateFormat.yMMMd("en_US").format(dateTime);
  }

  String _taperString() {
    if (_taper.amount == 0.0 || _taper?.days == null || _taper.days == 0) {
      return 'None';
    }
    return '-${_taper.amount} every ${_taper.days} days';
  }

  bool _canGraph() => _dosePerDay > 0 && _numberPrescribed > 0.0;

  Future _updateTaper() async {
    var newTaper = await selectTaper(context, _taper);
    setState(() {
      _taper = newTaper;
    });
  }

  @override
  Widget build(BuildContext context) {
    var now = new DateTime.now();
    _today = new DateTime(now.year, now.month, now.day,);
    return new Scaffold(
      body: new Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Center(
              child: ListView(
              shrinkWrap: true,
                padding: const EdgeInsets.all(5.0),
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Text('Refill Calculator',
                        style: TextStyle(
                          fontSize: 30.0,
                          fontWeight: FontWeight.bold,
                          height: 0.0
                        ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  ListTile(
                    title: Text('Prescribed'),
                    onTap: () async {
                      var selected = await selectDate(context, _today, _datePrescribed);
                      setState(() {
                        _datePrescribed = selected;
                      });
                    },
                    leading: IconButton(
                      icon: Icon(
                        Icons.event_note,
                        color: Colors.blue,
                      ),
                      tooltip: 'Select Date',
                      onPressed: () => {},
                    ),
                    trailing: Text(_dateString(_datePrescribed), style: _inputStyle(),)
                  ),
                  ListTile(
                    title: Text('Initial Amount'),
                    onTap: () async {
                      int selected = await selectPrescribed(context, _numberPrescribed);
                      setState(() {
                        _numberPrescribed = selected;
                      });
                    },
                    trailing: Text('$_numberPrescribed', style: _inputStyle(),),
                    leading: IconButton(
                      icon: Icon(
                        Icons.local_hospital,
                        color: Colors.blue,
                      ),
                      onPressed: () => {},
                      tooltip: 'Select Total Pills Prescribed',
                    ),
                  ),
                  ListTile(
                    title: Text('Dose Per Day'),
                    trailing: Text('$_dosePerDay', style: _inputStyle()),
                    onTap: () async {
                      var dose = await selectDose(context, _dosePerDay);
                      setState(() {
                        _dosePerDay = dose;
                      });
                    },
                    leading: IconButton(
                      icon: Icon(
                        Icons.timer,
                        color: Colors.blue,
                      ),
                      tooltip: 'Select Dose',
                      onPressed: () async {
                        var dose = await selectDose(context, _dosePerDay);
                        setState(() {
                          _dosePerDay = dose;
                        });
                      },
                    ),
                  ),
                  ListTile(
                    title: Text('Taper'),
                    trailing: Text('${_taperString()}', style: _inputStyle()),
                    onTap: _updateTaper,
                    leading: IconButton(
                      icon: Icon(
                        Icons.trending_down,
                        color: Colors.blue,
                      ),
                      tooltip: 'Select Taper',
                      onPressed: _updateTaper,
                    ),
                  ),
                  _canGraph() ? new Result(
                    _today,
                    _datePrescribed,
                    _numberPrescribed,
                    _dosePerDay,
                    _taper,
                  ): new Center(),
                ],
              ),
            ),
          ],
      )
    );
  }
}
