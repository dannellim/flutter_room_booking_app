// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility that Flutter provides. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';
import 'package:room_booking_app/models/user_profile.dart';
import 'package:room_booking_app/providers/user_profile_provider.dart';
import 'package:sembast/sembast_memory.dart';

void main() {
  group('user profile provider', () {
    test('save', () async {
      var provider = UserProfileProvider(databaseFactoryMemory);
      await provider.deleteDb();
      await provider.open();
      await provider.saveProfile(DbUserProfile()
        ..username.v = "username"
        ..createdDt = DateTime.now().millisecondsSinceEpoch);
      var first = await provider.onProfiles().first;
      expect(first.first.username.v, 'username');
      await provider.close();
    });
    test('edit', () async {
      var provider = UserProfileProvider(databaseFactoryMemory);
      await provider.deleteDb();
      await provider.open();
      await provider.saveProfile(DbUserProfile()
        ..username.v = "username"
        ..createdDt = DateTime.now().millisecondsSinceEpoch);
      var first = await provider.onProfiles().first;
      await provider.saveProfile(DbUserProfile()
        ..id = first.first.id
        ..username.v = "test_edit"
        ..createdDt = DateTime.now().millisecondsSinceEpoch);
      first = await provider.onProfiles().first;
      expect(first.first.username.v, 'test_edit');
      await provider.close();
    });
    test('delete', () async {
      var provider = UserProfileProvider(databaseFactoryMemory);
      await provider.deleteDb();
      await provider.open();
      await provider.saveProfile(DbUserProfile()
        ..username.v = "test_delete"
        ..createdDt = DateTime.now().millisecondsSinceEpoch);
      var first = await provider.onProfiles().first;
      expect(first.length, 1);
      await provider.deleteProfile(first.first.id);
      first = await provider.onProfiles().first;
      expect(first.length, 0);
      await provider.close();
    });
  });
}
