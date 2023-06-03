import 'dart:convert';

import 'package:intl/intl.dart';
import 'package:room_booking_app/models/db.dart';

class DbRmBooking extends DbRecord {
  final code = CvField<String>('code', '');
  final startDate = CvField<String>('startDate', '');
  final startTime = CvField<String>('startTime', '');
  final endDate = CvField<String>('endDate', '');
  final endTime = CvField<String>('endTime', '');
  final room = CvField<String>('room', '');
  final reason = CvField<String>('reason', '');
  final bookedBy = CvField<String>('bookedBy', '');
  final bookedDate =
      CvField<int>('bookedDate', DateTime.now().millisecondsSinceEpoch);

  @override
  List<CvField> get fields => [
        code,
        startDate,
        startTime,
        endDate,
        endTime,
        room,
        reason,
        bookedBy,
        bookedDate,
      ];

  Map toJson() => {
        'id': id,
        'code': code,
        'startDate': startDate,
        'startTime': startTime,
        'endDate': endDate,
        'endTime': endTime,
        'room': room,
        'reason': reason,
        'bookedBy': bookedBy,
        'bookedDate': bookedDate,
      };

  @override
  String toString() => jsonEncode(this);

  String toSummary() {
    var _ = DateFormat("dd MMM yyyy hh:mm a")
        .format(DateTime.fromMillisecondsSinceEpoch(bookedDate.valueOrThrow));
    return "ID: $id   |   $room   |   $reason   |   $bookedBy   |   $startTime    |   $endTime    |   bookedDate: $_";
  }
}
