import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class Taper {
  double amount;
  int days;

  Taper(this.days, this.amount);

  @override
  toString() => "Taper: $amount per $days days";
}

Future<Taper> selectTaper(BuildContext context, Taper currentTaper) async {
  Taper selected = new Taper(currentTaper.days, currentTaper.amount);

  TextEditingController amountController = new TextEditingController();
  TextEditingController daysController = new TextEditingController();

  void _setAmount() {
      selected.amount = double.tryParse(amountController.text) ?? 0.0;
  }
  void _setDays() {
    selected.days = int.tryParse(daysController.text) ?? 1;
  }

  amountController.addListener(_setAmount);
  amountController.addListener(_setDays);

  var entered = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: new Padding(
        padding: const EdgeInsets.only(top: 10.0),
        child: new Text(
          'Taper',
          style: TextStyle(
              fontSize: 20.0,
              fontWeight: FontWeight.bold,
              height: 0.0),
          textAlign: TextAlign.center,
        ),
      ),
      content: new Container(
        child: new ListView(
          shrinkWrap: true,
          padding: const EdgeInsets.only(top: 0.0, bottom: 0.0),
            children: <Widget>[
              ListTile(
                title: Text('Decrease by'),
                trailing: new SizedBox(
                  width: 65.0,
                  child: new CupertinoTextField(
                    autofocus: true,
                    controller: amountController,
                    keyboardType: TextInputType.numberWithOptions(decimal: true),
                    textAlign: TextAlign.center,
                    textInputAction: TextInputAction.done,
                  ),
                ),
              ),
              ListTile(
                title: Text('Every'),
                trailing: new SizedBox(
                  width: 65.0,
                  child: new CupertinoTextField(
                    controller: daysController,
                    placeholder: 'day(s)',
                    keyboardType: TextInputType.numberWithOptions(),
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
              _setAmount();
              _setDays();
              Navigator.pop(context, true);
            })
      ],
    )
  );

  if (entered == true && selected.days != null && selected.amount != null) {
    selected.amount = selected.amount.abs(); // don't allow negatives
    return selected;
  }
  return currentTaper;
}
