import 'package:charts_flutter/flutter.dart' as charts;
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';

class TimelinePoint {
  final DateTime time;
  final double prescriptionRemaining;

  TimelinePoint(this.time, this.prescriptionRemaining);

  @override
  String toString() {
    return "${DateFormat.yMMMd("en_US").format(time)}: $prescriptionRemaining";
  }
}

class SimpleTimeSeriesChart extends StatelessWidget {
  final DateTime _today;
  final List<charts.Series<TimelinePoint, DateTime>> _chartData;

  SimpleTimeSeriesChart(this._today, this._chartData);

  @override
  Widget build(BuildContext context) {
    return new Container(
      height: 125,
      margin: const EdgeInsets.all(10.0),
      child: charts.TimeSeriesChart(
        _chartData,
        animate: true,
        selectionModels: [
          new charts.SelectionModelConfig(
              type: charts.SelectionModelType.info,
          )
        ],
        behaviors: [
          new charts.SelectNearest(),
          new charts.InitialSelection(selectedDataConfig: [
            new charts.SeriesDatumConfig<DateTime>("PrescriptionTimeline", _today)
          ])
        ],
        // Optionally pass in a [DateTimeFactory] used by the chart. The factory
        // should create the same type of [DateTime] as the data provided. If none
        // specified, the default creates local date time.
        domainAxis: new charts.EndPointsTimeAxisSpec(
            tickFormatterSpec: new charts.AutoDateTimeTickFormatterSpec(
                day: new charts.TimeFormatterSpec(
                    format: 'MM/dd', transitionFormat: 'MM/dd')),
        ),
      ),
    );
  }
}