import 'dart:async';

import 'package:intl/intl.dart';
import 'package:flutter/material.dart';

import 'package:refill_rx/taper_duration_popup.dart';

void main() => runApp(new MyApp());

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
  Taper _taper = new Taper(0, 0);

  TextStyle _resultStyle() {
    return TextStyle(
      color: _numberRemaining() > 0 ? Colors.green : Colors.red,
      fontWeight: FontWeight.bold,
      fontSize: 22.0,
    );
  }

  TextStyle _inputStyle() {
    return TextStyle(
      color: Colors.blue,
      fontWeight: FontWeight.bold,
      fontSize: 17.0,
    );
  }

  double _numberRemaining() {
    int daysPassed = new DateTime.now().difference(_datePrescribed).inDays;
    return _numberPrescribed - (daysPassed * _dosePerDay);
  }

  String _dateString(DateTime dateTime) {
    return DateFormat.yMMMd("en_US").format(_datePrescribed);
  }

  String _taperString() {
    if (_taper.amount == 0.0 || _taper?.days == null || _taper.days == 0) {
      return 'None';
    }
    return '-${_taper.amount} every ${_taper.days} days';
  }

  Future<Null> _selectDate(BuildContext context) async {
    final DateTime picked = await showDatePicker(
      context: context,
      initialDate: _datePrescribed,
      firstDate: new DateTime(new DateTime.now().year - 1),
      lastDate: new DateTime(new DateTime.now().year + 1),
      selectableDayPredicate: (DateTime val) => val.isBefore(new DateTime.now()),
    );

    if (picked != null && picked != _datePrescribed) {
      setState(() {
        _datePrescribed = picked;
      });
    }
  }

  Future<Null> _selectPrescribed(BuildContext cntext) async {
    int selected = _numberPrescribed;
    final bool entered = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        contentPadding: const EdgeInsets.all(16.0),
        content: new Row(
          children: <Widget>[
            new Expanded(
              child: new TextField(
                keyboardType: TextInputType.number,
                autofocus: true,
                onChanged: (n) => selected = int.tryParse(n) ?? 0,
                onSubmitted: (_) {
                  Navigator.pop(context, true);
                },
                decoration: new InputDecoration(
                    labelText: 'Total Pills Prescribed',),
              ),
            )
          ],
        ),
        actions: <Widget>[
          new FlatButton(
              child: const Text('CANCEL'),
              onPressed: () {
                Navigator.pop(context, false);
              }),
          new FlatButton(
              child: const Text('ENTER'),
              onPressed: () {
                Navigator.pop(context, true);
              })
        ],
      ),
    );

    if (entered && selected != null && selected != _numberPrescribed) {
      setState(() {
        _numberPrescribed = selected;
      });
    }
  }

  Future<Null> _selectDose(BuildContext context) async {
    double selected = _dosePerDay;
    final bool entered = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        contentPadding: const EdgeInsets.all(10.0),
        content: new Row(
          children: <Widget>[
            new Expanded(
              child: new TextField(
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                autofocus: true,
                onChanged: (n) => selected = double.tryParse(n) ?? 0,
                decoration: new InputDecoration(
                    labelText: 'Avg. Dose Per Day'),
                onSubmitted: (_) {
                  Navigator.pop(context, true);
                },
              ),
            )
          ],
        ),
        actions: <Widget>[
          new FlatButton(
              child: const Text('CANCEL'),
              onPressed: () {
                Navigator.pop(context, false);
              }),
          new FlatButton(
              child: const Text('ENTER'),
              onPressed: () {
                Navigator.pop(context, true);
              })
        ],
      ),
    );

    if (entered && selected != null && selected != _dosePerDay) {
      setState(() {
        _dosePerDay = selected;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
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
                    onTap: () => _selectDate(context),
                    leading: IconButton(
                      icon: Icon(
                        Icons.event_note,
                        color: Colors.blue,
                      ),
                      tooltip: 'Select Date',
                      onPressed: () => _selectDate(context),
                    ),
                    trailing: Text(_dateString(_datePrescribed), style: _inputStyle(),)
                  ),
                  Container(
                    child: ListTile(
                      title: Text('Total Pills'),
                      trailing: Text('$_numberPrescribed', style: _inputStyle(),),
                      onTap: () => _selectPrescribed(context),
                      leading: IconButton(
                        icon: Icon(
                          Icons.local_hospital,
                          color: Colors.blue,
                        ),
                        tooltip: 'Select Total Pills Prescribed',
                        onPressed: () => _selectPrescribed(context),
                      ),
                    ),
                  ),
                  ListTile(
                    title: Text('Dose Per Day'),
                    trailing: Text(
                        '$_dosePerDay',
                        style: _inputStyle(),
                    ),
                    onTap: () => _selectDose(context),
                    leading: IconButton(
                      icon: Icon(
                        Icons.timer,
                        color: Colors.blue,
                      ),
                      tooltip: 'Select Dose',
                      onPressed: () => _selectPrescribed(context),
                    ),
                  ),
                  ListTile(
                    title: Text('Taper'),
                    trailing: Text(
                      '${_taperString()}',
                      style: _inputStyle(),
                    ),
                    onTap: () async {
                      var newTaper = await selectTaper(context, _taper);
                      setState(() {
                        _taper = newTaper;
                      });
                    },
                    leading: IconButton(
                      icon: Icon(
                        Icons.trending_down,
                        color: Colors.blue,
                      ),
                      tooltip: 'Select Taper',
                      onPressed: () => _selectPrescribed(context),
                    ),
                  ),
                  ListTile(
                    title: Text('Remaining', style: _resultStyle()),
                    trailing: Text('${_numberRemaining()}', style: _resultStyle()),
                    leading: IconButton(
                      icon: Icon(
                        _numberRemaining() > 0 ? Icons.check_circle : Icons.warning,
                        color: _numberRemaining() > 0 ? Colors.green : Colors.red,
                      ),
                      tooltip: 'Remaining',
                    ),
                  ),
                ],
              ),
            ),
          ],
      )
    );
  }
}
