import 'dart:async';

import 'package:intl/intl.dart';
import 'package:flutter/material.dart';

import 'package:refill_rx/date_prescribed.dart';
import 'package:refill_rx/dose.dart';
import 'package:refill_rx/prescribed.dart';
import 'package:refill_rx/result.dart';
import 'package:refill_rx/taper.dart';

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
    var daysString = _taper.days > 1 ? '${_taper.days} days' : 'day';
    return '-${_taper.amount} every $daysString';
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
    _today = new DateTime(
      now.year,
      now.month,
      now.day,
    );
    return new Scaffold(
      resizeToAvoidBottomPadding: false,
      body: new SafeArea(
        child: new Center(
          child: new Stack(
            children: [
              new ListView(
                padding: const EdgeInsets.all(10.0),
                shrinkWrap: true,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.only(top: 20.0, bottom: 20.0),
                    child: Text(
                      'Refill Calculator',
                      style: TextStyle(
                          fontSize: 30.0,
                          fontWeight: FontWeight.bold,
                          height: 0.0),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  ListTile(
                      title: Text('Start Date'),
                      onTap: () async {
                        var selected =
                        await selectDate(context, _today, _datePrescribed);
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
                      trailing: Text(
                        _dateString(_datePrescribed),
                        style: _inputStyle(),
                      )),
                  ListTile(
                    title: Text('Prescription'),
                    onTap: () async {
                      int selected =
                      await selectPrescribed(context, _numberPrescribed);
                      setState(() {
                        _numberPrescribed = selected;
                      });
                    },
                    trailing: Text(
                      '$_numberPrescribed',
                      style: _inputStyle(),
                    ),
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
                    title: Text('Dose'),
                    trailing: Text('$_dosePerDay / day', style: _inputStyle()),
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
                  _canGraph()
                      ? new Result(
                    _today,
                    _datePrescribed,
                    _numberPrescribed,
                    _dosePerDay,
                    _taper,
                  )
                      : new Center(),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
