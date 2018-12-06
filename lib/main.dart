import 'dart:async';

import 'package:intl/intl.dart';
import 'package:flutter/material.dart';

void main() => runApp(new MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'Refill RX',
      theme: new ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: new MyHomePage(title: 'Refill Calculator'),
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

  double _numberRemaining() {
    int daysPassed = new DateTime.now().difference(_datePrescribed).inDays;
    return _numberPrescribed - (daysPassed * _dosePerDay);
  }

  String _dateString(DateTime dateTime) {
    return DateFormat.yMMMMd("en_US").format(_datePrescribed);
  }

  Future<Null> _selectDate(BuildContext context) async {
    final DateTime picked = await showDatePicker(
      context: context,
      initialDate: _datePrescribed,
      firstDate: new DateTime(new DateTime.now().year),
      lastDate: new DateTime(new DateTime.now().year + 1),
    );

    if (picked != null && picked != _datePrescribed) {
      setState(() {
        _datePrescribed = picked;
      });
    }
  }

  Future<Null> _selectPrescribed(BuildContext context) async {
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
                decoration: new InputDecoration(
                    labelText: '# Prescribed',),
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
        contentPadding: const EdgeInsets.all(16.0),
        content: new Row(
          children: <Widget>[
            new Expanded(
              child: new TextField(
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                autofocus: true,
                onChanged: (n) => selected = double.tryParse(n) ?? 0,
                decoration: new InputDecoration(
                    labelText: 'Per Day', hintText: '1.5'),
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
      appBar: new AppBar(
        title: new Text(widget.title),
      ),
      body: new Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Center(
              child: ListView(
              shrinkWrap: true,
                padding: const EdgeInsets.all(20.0),
                children: <Widget>[
                  ListTile(
                    title: Text('Date Prescribed'),
                    onTap: () => _selectDate(context),
                    subtitle: Text(_dateString(_datePrescribed)),
                    trailing: IconButton(
                      icon: Icon(
                        Icons.calendar_today,
                        color: Colors.blue,
                      ),
                      tooltip: 'Select Date',
                      onPressed: () => _selectDate(context),
                    ),
                  ),
                  ListTile(
                    title: Text('Total Pills'),
                    subtitle: Text('$_numberPrescribed'),
                    onTap: () => _selectPrescribed(context),
                    trailing: IconButton(
                      icon: Icon(
                        Icons.local_hospital,
                        color: Colors.blue,
                      ),
                      tooltip: 'Select Total Pills Prescribed',
                      onPressed: () => _selectPrescribed(context),
                    ),
                  ),
                  ListTile(
                    title: Text('Dose Per Day'),
                    subtitle: Text('$_dosePerDay'),
                    onTap: () => _selectDose(context),
                    trailing: IconButton(
                      icon: Icon(
                        Icons.timer,
                        color: Colors.blue,
                      ),
                      tooltip: 'Select Dose',
                      onPressed: () => _selectPrescribed(context),
                    ),
                  ),
                  ListTile(
                    title: Text('Remaining'),
                    subtitle: Text('${_numberRemaining()}'),
                    onTap: () => _selectDose(context),
                    trailing: IconButton(
                      icon: Icon(
                        _numberRemaining() > 0 ? Icons.check_circle : Icons.warning,
                        color: _numberRemaining() > 0 ? Colors.green : Colors.red,
                      ),
                      tooltip: 'Select Dose',
                      onPressed: () => _selectPrescribed(context),
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
