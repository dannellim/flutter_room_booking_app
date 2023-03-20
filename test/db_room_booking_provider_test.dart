// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility that Flutter provides. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';
import 'package:room_booking_app/models/rm_booking.dart';
import 'package:room_booking_app/providers/room_booking_provider.dart';
import 'package:sembast/sembast_memory.dart';

void main() {
  group('provider', () {
    test('save', () async {
      var provider = DbRmBookingProvider(databaseFactoryMemory);
      await provider.deleteDb();
      await provider.open();
      await provider.saveRmBooking(DbRmBooking()
        ..bookedBy.v = "test_save"
        ..bookedDate.v = DateTime.now().millisecondsSinceEpoch);
      var first = await provider.onRmBookings().first;
      expect(first.first.bookedBy.v, 'test');
      await provider.close();
    });
    test('edit', () async {
      var provider = DbRmBookingProvider(databaseFactoryMemory);
      await provider.deleteDb();
      await provider.open();
      await provider.saveRmBooking(DbRmBooking()
        ..bookedBy.v = "test"
        ..bookedDate.v = DateTime.now().millisecondsSinceEpoch);
      var first = await provider.onRmBookings().first;
      await provider.saveRmBooking(DbRmBooking()
        ..id = first.first.id
        ..bookedBy.v = "test_edit"
        ..bookedDate.v = DateTime.now().millisecondsSinceEpoch);
      first = await provider.onRmBookings().first;
      expect(first.first.bookedBy.v, 'test_edit');
      await provider.close();
    });
    test('delete', () async {
      var provider = DbRmBookingProvider(databaseFactoryMemory);
      await provider.deleteDb();
      await provider.open();
      await provider.saveRmBooking(DbRmBooking()
        ..bookedBy.v = "test_delete"
        ..bookedDate.v = DateTime.now().millisecondsSinceEpoch);
      var first = await provider.onRmBookings().first;
      expect(first.length, 1);
      await provider.deleteRmBooking(first.first.id);
      first = await provider.onRmBookings().first;
      expect(first.length, 0);
      await provider.close();
    });
  });
}
