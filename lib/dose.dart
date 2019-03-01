import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

/// Displays a popup to prompting the user to select an amount to be taken daily
Future<double> selectDose(BuildContext context, double dosePerDay) async {
  double selected = dosePerDay;
  TextEditingController doseController = new TextEditingController();
  void _setDose() {
    selected = double.tryParse(doseController.text) ?? 0.0;
  }
  doseController.addListener(_setDose);

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
      content: new Container(
        child: new ListView(
          shrinkWrap: true,
          padding: const EdgeInsets.only(top: 0.0, bottom: 0.0),
          children: <Widget>[
            ListTile(
              title: Text('Start with'),
              trailing: new SizedBox(
                width: 100.0,
                child: new CupertinoTextField(
                  autofocus: true,
                  controller: doseController,
                  placeholder: '# per day',
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.center,
                  textInputAction: TextInputAction.done,
                ),
              ),
            ),
          ],
        ),
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
