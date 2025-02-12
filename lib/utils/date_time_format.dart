import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

String formatDatestamp(Timestamp timestamp) {
  final DateTime date = timestamp.toDate();
  final DateFormat formatter = DateFormat('dd MMM yyyy');
  return formatter.format(date);
}

DateTime formatDateToDateTime(String formattedDate) {
  final DateFormat formatter = DateFormat('dd MMM yyyy');
  try {
    return formatter.parse(formattedDate);
  } catch (e) {
    rethrow;
  }
}

String formatTimestamp(Timestamp timestamp) {
  final DateTime date = timestamp.toDate();
  final DateFormat formatter = DateFormat('hh:mm a');
  return formatter.format(date);
}

String formatDateTimestamp(Timestamp timestamp) {
  final DateTime date = timestamp.toDate();
  final DateFormat formatter = DateFormat('dd MMM yyyy hh:mm a');
  return formatter.format(date);
}
