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

  void _setAmount() => selected.amount = double.tryParse(amountController.text) ?? 0.0;
  void _setDays() => selected.days = int.tryParse(daysController.text) ?? 1;

  amountController.addListener(_setAmount);
  amountController.addListener(_setDays);

  var entered = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      contentPadding: const EdgeInsets.all(10.0),
      content: new Row(
        children: <Widget>[
          new Expanded(
            child: new TextFormField(
              autofocus: true,
              controller: amountController,
              decoration: new InputDecoration(
                  labelText: 'Decrease by',
                  isDense: true,
              ),
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              textAlign: TextAlign.center,
            ),
          ),
          new Expanded(
            child: new TextFormField(
              autofocus: true,
              controller: daysController,
              decoration: new InputDecoration(
                  labelText: 'Every',
                  suffixText: 'day(s)',
                isDense: true,
              ),
              keyboardType: TextInputType.numberWithOptions(),
              textAlign: TextAlign.center,
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
              _setAmount();
              _setDays();
              Navigator.pop(context, true);
            })
      ],
    ),
  );

  if (entered == true && selected.days != null && selected.amount != null) {
    selected.amount = selected.amount.abs(); // don't allow negatives
    return selected;
  }
  return currentTaper;
}