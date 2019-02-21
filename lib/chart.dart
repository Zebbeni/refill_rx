import 'package:charts_flutter/flutter.dart' as charts;
import 'package:flutter/material.dart';

class SimpleTimeSeriesChart extends StatelessWidget {
  final List<charts.Series> seriesList;
  final DateTime today;

  SimpleTimeSeriesChart(this.seriesList, this.today);

  @override
  Widget build(BuildContext context) {
    return new Container(
      height: 125,
      margin: const EdgeInsets.all(10.0),
      child: charts.TimeSeriesChart(
        seriesList,
        animate: true,
        selectionModels: [
          new charts.SelectionModelConfig(
              type: charts.SelectionModelType.info,
          )
        ],
        behaviors: [
          new charts.SelectNearest(),
          new charts.InitialSelection(selectedDataConfig: [
            new charts.SeriesDatumConfig<DateTime>("PrescriptionTimeline", today)
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