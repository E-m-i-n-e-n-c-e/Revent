import 'package:flutter/material.dart';

Color getColorForClub(String clubId) {
  final colors = {
    'wildbeats': Colors.purple,
    'cyberarc': Colors.blue,
    'betalabs': Colors.green,
    'gdgc': Colors.red,
    'codersclub': Colors.orange,
  };
  return colors[clubId] ?? Colors.grey;
}

String formatTimeRange(BuildContext context, DateTime start, DateTime end) {
  final startTime = TimeOfDay.fromDateTime(start);
  final endTime = TimeOfDay.fromDateTime(end);
  return '${startTime.format(context)} - ${endTime.format(context)}';
}

String formatEventDateTime(DateTime dateTime) {
  return '${dateTime.toLocal()}'.split(' ')[0];
}
