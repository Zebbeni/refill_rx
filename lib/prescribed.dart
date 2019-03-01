import 'package:flutter/material.dart';

/// Displays a popup to enter an amount of medication prescribed
Future<int> selectPrescribed(BuildContext context, int numberPrescribed) async {
  int selected = numberPrescribed;
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
                labelText: 'Total Prescribed',),
              textInputAction: TextInputAction.next,
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
  return numberPrescribed;
}