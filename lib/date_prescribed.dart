import 'package:flutter/material.dart';

Future<DateTime> selectDate(BuildContext context, DateTime today, DateTime datePrescribed) async {
  final DateTime picked = await showDatePicker(
    context: context,
    initialDate: datePrescribed,
    firstDate: new DateTime(today.year - 1),
    lastDate: new DateTime(today.year + 1),
    selectableDayPredicate: (DateTime val) => val.isBefore(new DateTime.now()),
  );

  if (picked != null) {
    return picked;
  }
  return datePrescribed;
}