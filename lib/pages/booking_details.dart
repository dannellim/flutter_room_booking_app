import 'package:flutter/material.dart';
import 'package:room_booking_app/app.dart';
import 'package:room_booking_app/models/rm_booking.dart';
import 'package:room_booking_app/services/nav_service.dart';
import 'package:room_booking_app/test_data.dart';
import 'package:room_booking_app/utilities/ui_utils.dart';
import 'package:room_booking_app/utilities/utils.dart';

class EditBookingPage extends StatefulWidget {
  /// null when new booking
  final DbRmBooking? initialBooking;
  const EditBookingPage({super.key, required this.initialBooking});
  @override
  State<EditBookingPage> createState() => _EditBookingPageState();
}

class _EditBookingPageState extends State<EditBookingPage> {
  //final _formKey = GlobalKey<FormState>();
  //int? get _bookingId => widget.initialBooking?.id;
  static const List<String> _roomList = TestData.roomList;
  String _roomDropdownValue = _roomList.first;

  static const List<String> _reasonList = TestData.reasonList;
  String _reasonDropdownValue = _reasonList.first;

  @override
  void initState() {
    _initFormFields();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Booking'),
      ),
      body: SingleChildScrollView(
        child: Container(
          margin: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Flex(
                  direction: MediaQuery.of(context).size.width >= 768
                      ? Axis.horizontal
                      : Axis.vertical,
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: <Widget>[
                    Row(
                      children: [
                        const Text("Start Date: ",
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold),
                            textAlign: TextAlign.left),
                        Text(widget.initialBooking?.startDate.v ?? "",
                            style: const TextStyle(fontSize: 16),
                            textAlign: TextAlign.left),
                      ],
                    ),
                    Row(
                      children: [
                        const Text("Start Time: ",
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold),
                            textAlign: TextAlign.left),
                        Text(widget.initialBooking?.startTime.v ?? "",
                            style: const TextStyle(fontSize: 16),
                            textAlign: TextAlign.left),
                      ],
                    ),
                    Row(
                      children: [
                        const Text("End Date: ",
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold),
                            textAlign: TextAlign.left),
                        Text(widget.initialBooking?.endDate.v ?? "",
                            style: const TextStyle(fontSize: 16),
                            textAlign: TextAlign.left),
                      ],
                    ),
                    Row(
                      children: [
                        const Text("End Time: ",
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold),
                            textAlign: TextAlign.left),
                        Text(widget.initialBooking?.endTime.v ?? "",
                            style: const TextStyle(fontSize: 16),
                            textAlign: TextAlign.left),
                      ],
                    ),
                  ]),
              Container(
                margin: const EdgeInsets.only(
                    top: 16, left: 0, right: 0, bottom: 16),
                child: DropdownButtonFormField<String>(
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Room',
                  ),
                  isExpanded: true,
                  value: _roomDropdownValue,
                  icon: const Icon(Icons.arrow_drop_down),
                  onChanged: (String? value) {
                    // This is called when the user selects an item.
                    setState(() {
                      _roomDropdownValue = value!;
                    });
                  },
                  items:
                      _roomList.map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                ),
              ),
              Container(
                margin:
                    const EdgeInsets.only(top: 8, left: 0, right: 0, bottom: 0),
                child: DropdownButtonFormField<String>(
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Reason',
                  ),
                  isExpanded: true,
                  value: _reasonDropdownValue,
                  icon: const Icon(Icons.arrow_drop_down),
                  onChanged: (String? value) {
                    // This is called when the user selects an item.
                    setState(() {
                      _reasonDropdownValue = value!;
                    });
                  },
                  items:
                      _reasonList.map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(
                height: 16,
              ),
              Center(
                child: Padding(
                  padding: EdgeInsets.zero,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      elevation: 3,
                      minimumSize: Size(MediaQuery.of(context).size.width,
                          MediaQuery.of(context).size.height * 0.05),
                    ),
                    onPressed: () async {
                      await update();
                      Navigator.pop(
                          NavigationService.navigatorKey.currentContext!);
                    },
                    child: const Padding(
                      padding: EdgeInsets.all(16),
                      child: Text('Update booking',
                          style: TextStyle(fontSize: 16)),
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  void _initFormFields() {
    for (var item in _roomList) {
      if (Utils.isSimpleStringsSame(
          item, widget.initialBooking?.room.v ?? "")) {
        _roomDropdownValue = item;
        break;
      }
    }
    for (var item in _reasonList) {
      if (Utils.isSimpleStringsSame(
          item, widget.initialBooking?.reason.v ?? "")) {
        _reasonDropdownValue = item;
        break;
      }
    }
  }

  Future<void> update() async {
    UiUtils.loadingSpinner();
    widget.initialBooking?.reason.v = _reasonDropdownValue;
    widget.initialBooking?.room.v = _roomDropdownValue;
    await dbRmBookingProvider.saveRmBooking(widget.initialBooking!);
    Navigator.of(NavigationService.navigatorKey.currentContext!).pop();
  }
}
