import 'package:flutter/material.dart';

String formatTimeRange(BuildContext context, DateTime start, DateTime end) {
  final startTime = TimeOfDay.fromDateTime(start);
  final endTime = TimeOfDay.fromDateTime(end);
  return '${startTime.format(context)} - ${endTime.format(context)}';
}

String formatEventDateTime(DateTime dateTime) {
  return '${dateTime.toLocal()}'.split(' ')[0];
}
