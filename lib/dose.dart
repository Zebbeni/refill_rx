import 'package:flutter/cupertino.dart';

import 'package:flutter/material.dart';

Future<double> selectDose(BuildContext context, double dosePerDay) async {
  double selected = dosePerDay;
  final bool entered = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
          title: new Padding(
            padding: const EdgeInsets.only(top: 10.0),
            child: new Text(
              'Dose',
              style: TextStyle(
                  fontSize: 20.0, fontWeight: FontWeight.bold, height: 0.0),
              textAlign: TextAlign.center,
            ),
          ),
          content: new Row(
            children: <Widget>[
              new Expanded(
                child: new CupertinoTextField(
                  keyboardType: TextInputType.numberWithOptions(decimal: false),
                  autofocus: true,
                  onChanged: (n) => selected = double.tryParse(n) ?? 0,
                  onSubmitted: (_) {
                    Navigator.pop(context, true);
                  },
                  onEditingComplete: () {
                    Navigator.pop(context, true);
                  },
                  textInputAction: TextInputAction.done,
                ),
              ),
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
                }),
          ],
        ),
  );

  if (entered == true && selected != null) {
    return selected;
  }
  return dosePerDay;
}
