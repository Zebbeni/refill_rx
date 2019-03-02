import 'dart:math';

import 'package:charts_flutter/flutter.dart' as charts;
import 'package:flutter/material.dart';

import 'package:refill_rx/taper.dart';
import 'package:refill_rx/chart.dart';

class Result extends StatelessWidget {
  final DateTime _today;
  final DateTime _datePrescribed;
  final int _numberPrescribed;
  final double _dosePerDay;
  final Taper _taper;

  double _currentRemaining;
  double _prescriptionOverflow;
  DateTime _dateEmpty;

  Result(this._today, this._datePrescribed, this._numberPrescribed,
      this._dosePerDay, this._taper);

  @override
  Widget build(BuildContext context) {
    var chartData = _calcTimelineData();
    return new Column(
      children: [
        new PrescriptionTimelineChart(_today, chartData),
        new ListTile(
          title: Text(
            _resultText(),
            style: _resultStyle(),
            textAlign: TextAlign.center,
          ),
          leading: IconButton(
            icon: _resultIcon(),
            onPressed: () => {},
            tooltip: 'Remaining',
          ),
        ),
        _dateEmpty == null
            ? new Padding(
                padding: EdgeInsets.only(left: 30.0, right: 30.0),
                child: new Text(
                  'Dose likely to reach zero \nwith ${_prescriptionOverflow.toInt()} remaining',
                  style: TextStyle(
                    color: _resultColor(),
                    fontStyle: FontStyle.italic,
                    fontSize: 14.0,
                  ),
                  textAlign: TextAlign.center,
                ))
            : new Center(),
      ],
    );
  }

  String _resultText() {
    if (_dateEmpty != null) {
      if (_dateEmpty.isBefore(_today)) {
        var daysPast = _today.difference(_dateEmpty).inDays;
        return daysPast == 1
            ? "$daysPast Day Overdue"
            : "$daysPast Days Overdue";
      } else {
        var daysUntil = _dateEmpty.difference(_today).inDays;
        return daysUntil == 1 ? "$daysUntil Day Left" : "$daysUntil Days Left";
      }
    } else {
      return "Overflow by $_prescriptionOverflow";
    }
  }

  TextStyle _resultStyle() {
    return TextStyle(
      color: _resultColor(),
      fontWeight: FontWeight.bold,
      fontSize: 22.0,
    );
  }

  Color _resultColor() {
    if (_prescriptionOverflow != null && _prescriptionOverflow > 0) {
      return Colors.orange;
    }
    return _currentRemaining > 0 ? Colors.green : Colors.red;
  }

  Icon _resultIcon() {
    if (_prescriptionOverflow != null && _prescriptionOverflow > 0) {
      return Icon(Icons.warning, color: _resultColor());
    }
    if (_currentRemaining <= 0) {
      return Icon(Icons.cancel, color: _resultColor());
    }
    return Icon(Icons.check_circle, color: _resultColor());
  }

  /// Create one series with sample hard coded data.
  List<charts.Series<TimelinePoint, DateTime>> _calcTimelineData() {
    double _prescriptionRemaining = _numberPrescribed.toDouble();
    List<TimelinePoint> timelinePoints = [
      new TimelinePoint(_datePrescribed, _prescriptionRemaining)
    ];

    _currentRemaining = _prescriptionRemaining;
    _dateEmpty = null; // reset dateEmpty to null
    _prescriptionOverflow = 0; // initialize to non-null
    DateTime _date = _datePrescribed;
    int _daysUntilRateChange = _taper.days;
    double _rateOfDecrease = _dosePerDay;

    // Add timeline points from the date of prescription and the date where
    // the rate of decrease becomes 0 or the prescription runs out.
    while (_prescriptionRemaining > 0 && _rateOfDecrease > 0) {
      // update date
      _date = _date.add(new Duration(days: 1));
      // update prescription remaining
      _prescriptionRemaining = max(_prescriptionRemaining - _rateOfDecrease, 0);
      if (_date.isAtSameMomentAs(_today)) {
        _currentRemaining = _prescriptionRemaining;
      }
      // add to timeline
      timelinePoints.add(new TimelinePoint(_date, _prescriptionRemaining));
      // update rate of decrease
      _daysUntilRateChange--;
      if (_daysUntilRateChange == 0) {
        _rateOfDecrease = max(_rateOfDecrease - _taper.amount, 0);
        _daysUntilRateChange = _taper.days;
      }
    }

    if (_prescriptionRemaining == 0) {
      _dateEmpty = _date;
    } else {
      _prescriptionOverflow = _prescriptionRemaining;
    }

    if (_date.isBefore(_today)) {
      timelinePoints.add(new TimelinePoint(_today, _prescriptionRemaining));
      _currentRemaining = _prescriptionRemaining;
    }

    var c = _resultColor();

    return [
      new charts.Series<TimelinePoint, DateTime>(
        id: 'PrescriptionTimeline',
        colorFn: (_, __) => new charts.Color(r: c.red, g: c.green, b: c.blue),
        domainFn: (TimelinePoint point, _) => point.time,
        measureFn: (TimelinePoint point, _) => point.prescriptionRemaining,
        data: timelinePoints,
      )
    ];
  }
}
