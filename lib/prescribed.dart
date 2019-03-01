import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

/// Displays a popup to enter an amount of medication prescribed
Future<int> selectPrescribed(BuildContext context, int numberPrescribed) async {
  int selected = numberPrescribed;
  TextEditingController prescribedController = new TextEditingController();
  void _setPrescribed() {
    selected = int.tryParse(prescribedController.text) ?? 0;
  }
  prescribedController.addListener(_setPrescribed);

  final bool entered = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: new Padding(
        padding: const EdgeInsets.only(top: 10.0),
        child: new Text(
          'Prescription',
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
              title: Text('Start With'),
              trailing: new SizedBox(
                width: 100.0,
                child: new CupertinoTextField(
                  autofocus: true,
                  controller: prescribedController,
                  placeholder: '',
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
            })
      ],
    ),
  );

  if (entered == true && selected != null) {
    return selected;
  }
  return numberPrescribed;
}