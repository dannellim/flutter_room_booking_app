import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:room_booking_app/models/rm_booking.dart';
import 'package:room_booking_app/test_data.dart';
import 'package:room_booking_app/utilities/cal_utils.dart';
import 'package:room_booking_app/widgets/nav_drawer.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:tekartik_common_utils/common_utils_import.dart';

import '../app.dart';

// Define a custom Form widget.
class RoomBookingPage extends StatefulWidget {
  const RoomBookingPage({super.key});

  @override
  RoomBookingPageState createState() {
    return RoomBookingPageState();
  }
}

// Define a corresponding State class.
// This class holds data related to the form.
class RoomBookingPageState extends State<RoomBookingPage> {
  RangeSelectionMode _rangeSelectionMode = RangeSelectionMode
      .toggledOff; // Can be toggled on/off by longpressing a date

  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  DateTime? _rangeStart;
  DateTime? _rangeEnd;

  final DateTime _firstDay = DateTime(
      DateTime.now().year, DateTime.now().month - 6, DateTime.now().day);
  final DateTime _lastDay = DateTime(
      DateTime.now().year + 1, DateTime.now().month, DateTime.now().day);

  TimeOfDay _timeStart = const TimeOfDay(hour: 08, minute: 0);
  TimeOfDay _timeEnd = const TimeOfDay(hour: 22, minute: 0);

  late final ValueNotifier<List<DbRmBooking>> _selectedEvents;

  final Set<DateTime> _selectedDays = LinkedHashSet<DateTime>(
    equals: isSameDay,
    hashCode: getHashCode,
  );

  @override
  void initState() {
    _selectedDay = _focusedDay;
    _selectedEvents = ValueNotifier(List.empty());
    super.initState();
  }

  @override
  void dispose() {
    _selectedEvents.dispose();
    super.dispose();
  }

  Future<void> _onDaySelected(DateTime selectedDay, DateTime focusedDay) async {
    if (!isSameDay(_selectedDay, selectedDay)) {
      setState(() {
        _selectedDay = selectedDay;
        _focusedDay = focusedDay;
        _rangeStart = null; // Important to clean those
        _rangeEnd = null;
        _rangeSelectionMode = RangeSelectionMode.toggledOff;
        // Update values in a Set
        if (_selectedDays.contains(selectedDay)) {
          _selectedDays.remove(selectedDay);
        } else {
          _selectedDays.add(selectedDay);
        }
      });
      _selectedEvents.value = await _getEventsForDay(selectedDay);
    }
  }

  Future<void> _onRangeSelected(
      DateTime? start, DateTime? end, DateTime focusedDay) async {
    setState(() {
      _selectedDay = null;
      _focusedDay = focusedDay;
      _rangeStart = start;
      _rangeEnd = end;
      _rangeSelectionMode = RangeSelectionMode.toggledOn;
    });

    //`start` or `end` could be null
    if (start != null && end != null) {
      _selectedEvents.value = await _getEventsForRange(start, end);
    } else if (start != null) {
      _selectedEvents.value = await _getEventsForDay(start);
    } else if (end != null) {
      _selectedEvents.value = await _getEventsForDay(end);
    }
  }

  Future<List<DbRmBooking>> _getEventsForRange(
      DateTime start, DateTime end) async {
    // Implementation example
    final days = daysInRange(start, end);

    return [
      for (final d in days) ...await _getEventsForDay(d),
    ];
  }

  static const List<String> roomList = TestData.roomList;
  String roomDropdownValue = roomList.first;

  static const List<String> reasonList = TestData.reasonList;
  String reasonDropdownValue = reasonList.first;

  Future<List<DbRmBooking>> _getEventsForDay(DateTime day) async {
    //main source of data
    // Implementation example
    return (await dbRmBookingProvider.onRmBookings().first)
        .where((booking) => booking.startDate.valueOrThrow
            .contains(DateFormat("yyyy-MM-dd").format(day)))
        .toList();
  }

  List<DbRmBooking> _getEventMarkersForDay(DateTime day) {
    //main source of data
    // Implementation example
    return _bookings
        .where((booking) => booking.startDate.valueOrThrow
            .contains(DateFormat("yyyy-MM-dd").format(day)))
        .toList();
  }

  List<DbRmBooking> _bookings = List.empty();

  @override
  Widget build(BuildContext context) {
    // Build a Form widget using the _formKey created above.
    return Scaffold(
        drawer: const NavDrawer(),
        appBar: AppBar(
          title: const Text('Home'),
        ),
        body: StreamBuilder<List<DbRmBooking>>(
            stream: dbRmBookingProvider.onRmBookings(),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                _bookings = snapshot.data!;
                _selectedEvents.value = snapshot.data!
                    .where((booking) => booking.startDate.valueOrThrow.contains(
                        DateFormat("yyyy-MM-dd").format(_selectedDay!)))
                    .toList();
              }
              return Column(
                children: [
                  TableCalendar<DbRmBooking>(
                    eventLoader: _getEventMarkersForDay,
                    firstDay: _firstDay,
                    lastDay: _lastDay,
                    focusedDay: _focusedDay,
                    selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                    rangeStartDay: _rangeStart,
                    rangeEndDay: _rangeEnd,
                    availableCalendarFormats: const {
                      CalendarFormat.month: 'Month'
                    },
                    rangeSelectionMode: _rangeSelectionMode,
                    onDaySelected: _onDaySelected,
                    onRangeSelected: _onRangeSelected,
                    onPageChanged: (focusedDay) {
                      _focusedDay = focusedDay;
                    },
                  ),
                  const SizedBox(height: 16.0),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      elevation: 3,
                      minimumSize: Size(MediaQuery.of(context).size.width * 0.5,
                          MediaQuery.of(context).size.height * 0.05),
                    ),
                    onPressed: () {
                      _timeStart = const TimeOfDay(hour: 08, minute: 0);
                      _timeEnd = const TimeOfDay(hour: 22, minute: 0);
                      _rangeStart ??= _selectedDay;
                      _rangeEnd ??= _selectedDay;
                      showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return StatefulBuilder(
                              builder: (context, setState) {
                                return AlertDialog(
                                    scrollable: true,
                                    content: Stack(
                                      alignment: Alignment.center,
                                      children: <Widget>[
                                        Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Row(
                                              children: [
                                                const Text("Start Date: ",
                                                    style: TextStyle(
                                                        fontSize: 16,
                                                        fontWeight:
                                                            FontWeight.bold),
                                                    textAlign: TextAlign.left),
                                                Text(
                                                    DateFormat("dd MMMM yyyy")
                                                        .format(_rangeStart!),
                                                    style: const TextStyle(
                                                        fontSize: 16),
                                                    textAlign: TextAlign.left),
                                                IconButton(
                                                    icon:
                                                        const Icon(Icons.edit),
                                                    iconSize: 16,
                                                    onPressed: () async {
                                                      // your code
                                                      final DateTime? picked =
                                                          await showDatePicker(
                                                              context: context,
                                                              initialDate:
                                                                  _rangeStart!,
                                                              firstDate:
                                                                  _firstDay,
                                                              lastDate:
                                                                  _lastDay);
                                                      if (picked != null &&
                                                          picked !=
                                                              (_selectedDay !=
                                                                      null
                                                                  ? _selectedDay!
                                                                  : _rangeStart!)) {
                                                        setState(() {
                                                          _rangeStart = picked;
                                                          // _selectedDay != null
                                                          //     ? _selectedDay =
                                                          //         picked
                                                          //     : _rangeStart =
                                                          //         picked;
                                                        });
                                                      }
                                                    })
                                              ],
                                            ),
                                            //const SizedBox(height: 8.0),
                                            Row(
                                              children: [
                                                const Text("Start Time: ",
                                                    style: TextStyle(
                                                        fontSize: 16,
                                                        fontWeight:
                                                            FontWeight.bold),
                                                    textAlign: TextAlign.left),
                                                Text(_timeStart.format(context),
                                                    style: const TextStyle(
                                                        fontSize: 16),
                                                    textAlign: TextAlign.left),
                                                IconButton(
                                                    icon:
                                                        const Icon(Icons.edit),
                                                    iconSize: 16,
                                                    onPressed: () async {
                                                      // your code
                                                      TimeOfDay?
                                                          selectedTime24Hour =
                                                          await showTimePicker(
                                                        context: context,
                                                        initialTime: _timeStart,
                                                        builder: (BuildContext
                                                                context,
                                                            Widget? child) {
                                                          return MediaQuery(
                                                            data: MediaQuery.of(
                                                                    context)
                                                                .copyWith(
                                                                    alwaysUse24HourFormat:
                                                                        true),
                                                            child: child!,
                                                          );
                                                        },
                                                      );

                                                      if (selectedTime24Hour !=
                                                              null &&
                                                          selectedTime24Hour !=
                                                              _timeStart) {
                                                        setState(() {
                                                          _timeStart =
                                                              selectedTime24Hour;
                                                        });
                                                      }
                                                    })
                                              ],
                                            ),

                                            Row(
                                              children: [
                                                const Text("End Date: ",
                                                    style: TextStyle(
                                                        fontSize: 16,
                                                        fontWeight:
                                                            FontWeight.bold),
                                                    textAlign: TextAlign.left),
                                                Text(
                                                    DateFormat("dd MMMM yyyy")
                                                        .format(_rangeEnd!),
                                                    style: const TextStyle(
                                                        fontSize: 16),
                                                    textAlign: TextAlign.left),
                                                IconButton(
                                                    icon:
                                                        const Icon(Icons.edit),
                                                    iconSize: 16,
                                                    onPressed: () async {
                                                      // your code
                                                      final DateTime? picked =
                                                          await showDatePicker(
                                                              context: context,
                                                              initialDate:
                                                                  _rangeEnd!,
                                                              firstDate:
                                                                  _firstDay,
                                                              lastDate:
                                                                  _lastDay);
                                                      if (picked != null &&
                                                          picked !=
                                                              (_selectedDay !=
                                                                      null
                                                                  ? _selectedDay!
                                                                  : _rangeEnd!)) {
                                                        setState(() {
                                                          _rangeEnd = picked;
                                                        });
                                                      }
                                                    })
                                              ],
                                            ),

                                            Row(
                                              children: [
                                                const Text("End Time: ",
                                                    style: TextStyle(
                                                        fontSize: 16,
                                                        fontWeight:
                                                            FontWeight.bold),
                                                    textAlign: TextAlign.left),
                                                Text(_timeEnd.format(context),
                                                    style: const TextStyle(
                                                        fontSize: 16),
                                                    textAlign: TextAlign.left),
                                                IconButton(
                                                    icon:
                                                        const Icon(Icons.edit),
                                                    iconSize: 16,
                                                    onPressed: () async {
                                                      // your code
                                                      TimeOfDay?
                                                          selectedTime24Hour =
                                                          await showTimePicker(
                                                        context: context,
                                                        initialTime: _timeEnd,
                                                        builder: (BuildContext
                                                                context,
                                                            Widget? child) {
                                                          return MediaQuery(
                                                            data: MediaQuery.of(
                                                                    context)
                                                                .copyWith(
                                                                    alwaysUse24HourFormat:
                                                                        true),
                                                            child: child!,
                                                          );
                                                        },
                                                      );

                                                      if (selectedTime24Hour !=
                                                              null &&
                                                          selectedTime24Hour !=
                                                              _timeEnd) {
                                                        setState(() {
                                                          _timeEnd =
                                                              selectedTime24Hour;
                                                        });
                                                      }
                                                    })
                                              ],
                                            ),
                                            Container(
                                              margin: const EdgeInsets.only(
                                                  top: 16,
                                                  left: 0,
                                                  right: 0,
                                                  bottom: 16),
                                              child: DropdownButtonFormField<
                                                  String>(
                                                decoration:
                                                    const InputDecoration(
                                                  border: OutlineInputBorder(),
                                                  labelText: 'Room',
                                                ),
                                                isExpanded: true,
                                                value: roomDropdownValue,
                                                icon: const Icon(
                                                    Icons.arrow_drop_down),
                                                onChanged: (String? value) {
                                                  // This is called when the user selects an item.
                                                  setState(() {
                                                    roomDropdownValue = value!;
                                                  });
                                                },
                                                items: roomList.map<
                                                        DropdownMenuItem<
                                                            String>>(
                                                    (String value) {
                                                  return DropdownMenuItem<
                                                      String>(
                                                    value: value,
                                                    child: Text(value),
                                                  );
                                                }).toList(),
                                              ),
                                            ),
                                            Container(
                                              margin: const EdgeInsets.only(
                                                  top: 8,
                                                  left: 0,
                                                  right: 0,
                                                  bottom: 0),
                                              child: DropdownButtonFormField<
                                                  String>(
                                                decoration:
                                                    const InputDecoration(
                                                  border: OutlineInputBorder(),
                                                  labelText: 'Reason',
                                                ),
                                                isExpanded: true,
                                                value: reasonDropdownValue,
                                                icon: const Icon(
                                                    Icons.arrow_drop_down),
                                                onChanged: (String? value) {
                                                  // This is called when the user selects an item.
                                                  setState(() {
                                                    reasonDropdownValue =
                                                        value!;
                                                  });
                                                },
                                                items: reasonList.map<
                                                        DropdownMenuItem<
                                                            String>>(
                                                    (String value) {
                                                  return DropdownMenuItem<
                                                      String>(
                                                    value: value,
                                                    child: Text(value),
                                                  );
                                                }).toList(),
                                              ),
                                            ),
                                            Center(
                                              child: Padding(
                                                padding: const EdgeInsets.only(
                                                    top: 16,
                                                    left: 0,
                                                    right: 0,
                                                    bottom: 0),
                                                child: ElevatedButton(
                                                  style:
                                                      ElevatedButton.styleFrom(
                                                    elevation: 3,
                                                    minimumSize: Size(
                                                        MediaQuery.of(context)
                                                            .size
                                                            .width,
                                                        MediaQuery.of(context)
                                                                .size
                                                                .height *
                                                            0.05),
                                                  ),
                                                  onPressed: () async {
                                                    await saveRoomBooking();
                                                    // ignore: use_build_context_synchronously
                                                    Navigator.pop(context);
                                                  },
                                                  child: const Padding(
                                                    padding: EdgeInsets.all(16),
                                                    child: Text('Book Room',
                                                        style: TextStyle(
                                                            fontSize: 16)),
                                                  ),
                                                ),
                                              ),
                                            )
                                          ],
                                        ),
                                      ],
                                    ));
                              },
                            );
                          });
                    },
                    child: const Padding(
                      padding: EdgeInsets.all(16),
                      child:
                          Text('New Booking', style: TextStyle(fontSize: 16)),
                    ),
                  ),
                  const SizedBox(height: 16.0),
                  Expanded(
                    child: ValueListenableBuilder<List<DbRmBooking>>(
                      valueListenable: _selectedEvents,
                      builder: (context, value, _) {
                        return ListView.builder(
                          itemCount: value.length,
                          itemBuilder: (context, index) {
                            return Container(
                              margin: const EdgeInsets.symmetric(
                                horizontal: 16.0,
                                vertical: 4.0,
                              ),
                              decoration: BoxDecoration(
                                border: Border.all(),
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                              child: ListTile(
                                onTap: () => {
                                  showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        Text bookingText = Text.rich(
                                          TextSpan(
                                            // with no TextStyle it will have default text style
                                            text: '',
                                            children: <TextSpan>[
                                              const TextSpan(
                                                  text: 'Code: ',
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold)),
                                              TextSpan(
                                                  text:
                                                      "${value[index].code.v}\n"),
                                              const TextSpan(
                                                  text: 'Start Date: ',
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold)),
                                              TextSpan(
                                                  text:
                                                      "${value[index].startDate.v}\n"),
                                              const TextSpan(
                                                  text: 'Start Time: ',
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold)),
                                              TextSpan(
                                                  text:
                                                      "${value[index].startTime.v}\n"),
                                              const TextSpan(
                                                  text: 'End Date: ',
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold)),
                                              TextSpan(
                                                  text:
                                                      "${value[index].endDate.v}\n"),
                                              const TextSpan(
                                                  text: 'End Time: ',
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold)),
                                              TextSpan(
                                                  text:
                                                      "${value[index].endTime.v}\n"),
                                              const TextSpan(
                                                  text: 'Room: ',
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold)),
                                              TextSpan(
                                                  text:
                                                      "${value[index].room.v}\n"),
                                              const TextSpan(
                                                  text: 'Reason: ',
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold)),
                                              TextSpan(
                                                  text:
                                                      "${value[index].reason.v}\n"),
                                              const TextSpan(
                                                  text: 'Booked By: ',
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold)),
                                              TextSpan(
                                                  text:
                                                      "${value[index].bookedBy.v}\n"),
                                              const TextSpan(
                                                  text:
                                                      'Date & Time of Booking: ',
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold)),
                                              TextSpan(
                                                  text: DateFormat(
                                                          "dd MMM yyyy hh:mm a")
                                                      .format(DateTime
                                                          .fromMillisecondsSinceEpoch(
                                                              value[index]
                                                                  .bookedDate
                                                                  .valueOrThrow))),
                                            ],
                                          ),
                                        );

                                        // String bookingDetails =
                                        //     "Code: ${value[index].code}\nStart Date: ${value[index].startDate}\nStart Time: ${value[index].startTime}\nEnd Date: ${value[index].endDate}\nEnd Time: ${value[index].endTime}\nRoom: ${value[index].room}\nReason: ${value[index].reason}\nBooked By: ${value[index].bookedBy}\nBooked Time: ${value[index].bookedTime}\n";
                                        return AlertDialog(
                                          title: const Text("Booking Details"),
                                          titleTextStyle: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: Colors.black,
                                              fontSize: 16),
                                          content: bookingText,
                                          actions: [
                                            ElevatedButton(
                                              style: ElevatedButton.styleFrom(
                                                elevation: 3,
                                              ),
                                              onPressed: () {
                                                Navigator.pop(context);
                                              },
                                              child: const Padding(
                                                padding: EdgeInsets.all(8),
                                                child: Text('OK',
                                                    style: TextStyle(
                                                        fontSize: 16)),
                                              ),
                                            ),
                                          ],
                                        );
                                      })
                                },
                                title: Text(value[index].toSummary()),
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),
                ],
              );
            }));
  }

  saveRoomBooking() async {
    // if (kDebugMode) {
    //   print("_selectedDay $_selectedDay");
    //   print("_rangeStart $_rangeStart");
    //   print("_rangeEnd $_rangeEnd");
    //   print("_timeStart $_timeStart");
    //   print("_timeEnd $_timeEnd");
    //   print("roomDropdownValue $roomDropdownValue");
    //   print("reasonDropdownValue $reasonDropdownValue");
    // }
    await dbRmBookingProvider.saveRmBooking(DbRmBooking()
      ..id = DateTime.now().millisecondsSinceEpoch
      ..startDate.v = DateFormat("yyyy-MM-dd").format(_rangeStart!)
      ..startTime.v = _timeStart.format(context)
      ..endDate.v = DateFormat("yyyy-MM-dd").format(_rangeEnd!)
      ..endTime.v = _timeEnd.format(context)
      ..room.v = roomDropdownValue
      ..reason.v = reasonDropdownValue
      ..bookedDate.v = DateTime.now().millisecondsSinceEpoch);
    _selectedEvents.value = await _getEventsForDay(_selectedDay!);
  }
}
