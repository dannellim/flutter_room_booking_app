import 'dart:convert';

class Booking {
  int id = 0;
  late String code;
  late String startDate;
  late String startTime;
  late String endDate;
  late String endTime;
  late String room;
  late String reason;
  late String bookedBy;
  late String bookedTime;
  bool isRecurring = false;

  Booking(
      {required this.id,
      required this.code,
      required this.startDate,
      required this.startTime,
      required this.endDate,
      required this.endTime,
      required this.room,
      required this.reason,
      required this.bookedBy,
      required this.bookedTime,
      required this.isRecurring});

  String toSummary() {
    return "ID: $id | Code: $code | Room: $room | Reason: $reason | BookedBy: $bookedBy";
  }

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
        'bookedTime': bookedTime,
        'isRecurring': isRecurring,
      };

  @override
  String toString() => jsonEncode(this);
}
