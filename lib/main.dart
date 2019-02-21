import 'dart:async';
import 'dart:math';

import 'package:charts_flutter/flutter.dart' as charts;
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:refill_rx/chart.dart';
import 'package:refill_rx/taper_duration_popup.dart';

void main() {
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);
  runApp(new MyApp());
}

class TimelinePoint {
  final DateTime time;
  final double prescriptionRemaining;

  TimelinePoint(this.time, this.prescriptionRemaining);

  @override
  String toString() {
    return "${DateFormat.yMMMd("en_US").format(time)}: $prescriptionRemaining";
  }
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
  DateTime _dateEmpty;
  int _numberPrescribed = 0;
  double _currentRemaining = 0;
  double _dosePerDay = 0.0;
  Taper _taper = new Taper(1, 0);
  DateTime _today = new DateTime(
      new DateTime.now().year,
      new DateTime.now().month,
      new DateTime.now().day,
  );

  /// Create one series with sample hard coded data.
  List<charts.Series<TimelinePoint, DateTime>> _calcTimelineData() {
    final timelinePoints = new List<TimelinePoint>();
    DateTime _date = _datePrescribed;

    double _rateOfDecrease = _dosePerDay;
    double _prescriptionRemaining = _numberPrescribed.toDouble();
    int _daysUntilRateChange = _taper.days;

    _dateEmpty = null; // reset dateEmpty to null

    while(_prescriptionRemaining > 0 && _rateOfDecrease > 0) {
      timelinePoints.add(new TimelinePoint(_date, _prescriptionRemaining));
      _prescriptionRemaining = max(_prescriptionRemaining - _rateOfDecrease, 0);
      _date = _date.add(new Duration(days: 1));
      _daysUntilRateChange--;
      if (_daysUntilRateChange == 0) {
        _rateOfDecrease = max(_rateOfDecrease - _taper.amount, 0);
        _daysUntilRateChange = _taper.days;
      }
      if (_date.isAtSameMomentAs(_today)) {
        _currentRemaining = _prescriptionRemaining;
      }
    }

    timelinePoints.add(new TimelinePoint(_date, _prescriptionRemaining));

    if (_prescriptionRemaining == 0) {
      _dateEmpty = _date;
    }

    if (_date.isBefore(_today)) {
      timelinePoints.add(new TimelinePoint(_today, _prescriptionRemaining));
      _currentRemaining = _prescriptionRemaining;
    }

      return [
        new charts.Series<TimelinePoint, DateTime>(
          id: 'PrescriptionTimeline',
          colorFn: (_, __) => charts.MaterialPalette.blue.shadeDefault,
          domainFn: (TimelinePoint point, _) => point.time,
          measureFn: (TimelinePoint point, _) => point.prescriptionRemaining,
          data: timelinePoints,
        )];
  }

  String _resultText() {
    if (_dateEmpty != null) {
      if (_dateEmpty.isAfter(_today)) {
        return "${_dateEmpty.difference(_today).inDays} Days Left";
      } else {
        return "${_today.difference(_dateEmpty).inDays} Days Overdue";
      }
    } else {
      return "${_currentRemaining} remain, overflow likely";
    }
  }

  TextStyle _resultStyle() {
    return TextStyle(
      color: _currentRemaining > 0 ? Colors.green : Colors.red,
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

  Future<Null> _selectDate(BuildContext context) async {
    final DateTime picked = await showDatePicker(
      context: context,
      initialDate: _datePrescribed,
      firstDate: new DateTime(_today.year - 1),
      lastDate: new DateTime(_today.year + 1),
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

    if (entered == true && selected != null && selected != _numberPrescribed) {
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
                      onPressed: () => {},
                    ),
                    trailing: Text(_dateString(_datePrescribed), style: _inputStyle(),)
                  ),
                  Container(
                    child: ListTile(
                      title: Text('Total Pills'),
                      onTap: () => _selectPrescribed(context),
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
                    title: Text(_resultText(), style: _resultStyle()),
//                    trailing: Text('${_currentRemaining}', style: _resultStyle()),
                    leading: IconButton(
                      icon: Icon(
                        _currentRemaining > 0 ? Icons.check_circle : Icons.warning,
                        color: _currentRemaining > 0 ? Colors.green : Colors.red,
                      ),
                      onPressed: () => {},
                      tooltip: 'Remaining',
                    ),
                  ),
                  _canGraph() ? new SimpleTimeSeriesChart(
                      _calcTimelineData(),
                      _today,
                  ): new Center(),
                ],
              ),
            ),
          ],
      )
    );
  }
}
