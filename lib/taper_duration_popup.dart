import 'package:flutter/material.dart';

class Taper {
  double amount;
  int days;

  Taper(this.days, this.amount);
}

Future<Taper> selectTaper(BuildContext context, Taper currentTaper) async {
  Taper selected = currentTaper;
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
              onChanged: (n) => selected.amount = double.tryParse(n) ?? 0,
              decoration: new InputDecoration(
                  labelText: 'Taper Amount'),
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

  if (entered && selected != null && selected != currentTaper) {
      return selected;
  }
  return currentTaper;
}
//
//Future<Taper> selectTaper(BuildContext context, Taper current) async {
//  var selected = new Taper(current.timeToDecrease, current.amountToDecrease);
//
//  final bool entered = await showDialog<bool>(
//    context: context,
//    builder: (context) => AlertDialog(
//      contentPadding: const EdgeInsets.all(10.0),
//      content: new Row(
//        children: <Widget>[
//          new Expanded(
//            child: new Row(
//              children: <Widget>[
//                new DropdownButton<double>(
//                  value: selected.amountToDecrease,
//                  items: <double>[0.0, 0.1, 0.25, 0.5, 1.0, 2.0, 5.0, 10.0].map((double value) {
//                    return new DropdownMenuItem<double>(
//                      value: value,
//                      child: new Text("$value"),
//                    );
//                  }).toList(),
//                  onChanged: (_) {},
//                ),
//                new DropdownButton<Duration>(
//                  value: selected.timeToDecrease,
//                  items: <Duration>[new Duration(days: 1), new Duration(days: 3), new Duration(days: 7), new Duration(days: 14)]
//                      .map((Duration d) {
//                    return new DropdownMenuItem<Duration>(
//                      value: d,
//                      child: new Text("${selected.timeToDecrease}"),
//                    );
//                  }).toList(),
//                  onChanged: (value) => selected.timeToDecrease = value,
//                ),
//                new TaperDurationPopup(),
//              ],),),
//        ],
//      ),
//      actions: <Widget>[
//        new FlatButton(
//            child: const Text('CANCEL'),
//            onPressed: () {
//              Navigator.pop(context, false);
//            }),
//        new FlatButton(
//            child: const Text('ENTER'),
//            onPressed: () {
//              Navigator.pop(context, true);
//            })
//      ],
//    ),
//  );
//
//  if (entered) {
//    return selected;
//  } else {
//    return current;
//  }
//}
//
//class TaperDurationPopup extends StatefulWidget {
//  TaperDurationPopup({Key key, }) : super(key: key);
//
//  @override
//  TaperDurationPopupState createState() => new TaperDurationPopupState();
//}
//
//class TaperDurationPopupState extends State<TaperDurationPopup> {
//
//  final List<double> _items = [0.5, 1.0, 2.0, 4.0].toList();
//
//  double _selection;
//
//  @override
//  void initState() {
//    _selection = _items.first;
//    super.initState();
//  }
//
//  @override
//  Widget build(BuildContext context) {
//    final dropdownMenuOptions = _items
//        .map((double item) =>
//    new DropdownMenuItem<String>(value: "$item", child: new Text("$item")))
//        .toList();
//
//    return new DropdownButton<String>(
//        value: _selection.toString(),
//        items: dropdownMenuOptions,
//        onChanged: (item) {
//          setState(() {
//            _selection = double.parse(item);
//          });
//        }
//    );
//  }
//}