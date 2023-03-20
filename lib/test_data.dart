import 'dart:collection';
import 'dart:math';
import 'package:intl/intl.dart';
import 'package:room_booking_app/models/booking.dart';
import 'package:table_calendar/table_calendar.dart';

import 'utilities/cal_utils.dart';

class TestData {
  static const List<String> serviceList = <String>[
    'Chinese Congregation',
    'Mustard Seed Service (Youth)',
    'Saturday Praise Service',
    'Sunday Worship Service',
  ];
  String serviceDropdownValue = serviceList.first;

  static const List<String> cellList = <String>[
    'Cell One',
    'Cell Two',
    'Cell Three',
    'Cell Four',
  ];

  static const List<String> roomList = <String>[
    '#01-01',
    '#01-02',
    '#01-03',
    'Sanctuary',
    '#02-01',
    '#02-02',
    '#02-03',
    'Shaw Hall',
    '#03-01',
    '#03-02',
    '#03-03',
    'Lounge',
  ];

  static const List<String> reasonList = <String>[
    'Cell',
    'Music Practice',
    'Service',
    'Camp',
  ];
}

final tToday = DateTime.now();
final tFirstDay = DateTime(tToday.year, tToday.month - 3, tToday.day);
final tLastDay = DateTime(tToday.year, tToday.month + 3, tToday.day);

final tEvents = LinkedHashMap<DateTime, List<Booking>>(
  equals: isSameDay,
  hashCode: getHashCode,
)..addAll(_tEventSource);

final _tEventSource = {
  for (var item in List.generate(50, (index) => index))
    DateTime.utc(tFirstDay.year, tFirstDay.month, item * 5): List.generate(
      item % 8 + 1,
      (index) => Booking(
          id: index,
          code: getRandomString(5),
          startDate: DateFormat("dd MMMM yyyy ")
              .format(DateTime.utc(tFirstDay.year, tFirstDay.month, item * 5)),
          startTime: "startTime",
          endDate: "endDate",
          endTime: "endTime",
          room: TestData.roomList[Random().nextInt(TestData.roomList.length)],
          reason:
              TestData.reasonList[Random().nextInt(TestData.reasonList.length)],
          bookedBy: "bookedBy",
          bookedTime: "bookedTime",
          isRecurring: false),
    )
}..addAll({
    kToday: [
      Booking(
          id: 88,
          code: getRandomString(5),
          startDate: "startDate",
          startTime: "startTime",
          endDate: "endDate",
          endTime: "endTime",
          room: TestData.roomList[Random().nextInt(TestData.roomList.length)],
          reason:
              TestData.reasonList[Random().nextInt(TestData.reasonList.length)],
          bookedBy: "bookedBy",
          bookedTime: "bookedTime",
          isRecurring: false),
      Booking(
          id: 99,
          code: getRandomString(5),
          startDate: "startDate",
          startTime: "startTime",
          endDate: "endDate",
          endTime: "endTime",
          room: TestData.roomList[Random().nextInt(TestData.roomList.length)],
          reason:
              TestData.reasonList[Random().nextInt(TestData.reasonList.length)],
          bookedBy: "bookedBy",
          bookedTime: "bookedTime",
          isRecurring: false),
    ],
  });

const _chars = 'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890';
Random _rnd = Random();

String getRandomString(int length) => String.fromCharCodes(Iterable.generate(
        length, (_) => _chars.codeUnitAt(_rnd.nextInt(_chars.length))))
    .toUpperCase();
