import 'package:flutter/material.dart';

Future<double> selectDose(BuildContext context, double dosePerDay) async {
  double selected = dosePerDay;
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

  if (entered == true && selected != null) {
    return selected;
  }
  return dosePerDay;
}