// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:room_booking_app/models/user_profile.dart';
import 'package:room_booking_app/providers/room_booking_provider.dart';
import 'package:room_booking_app/providers/user_profile_provider.dart';
import 'package:room_booking_app/test_data.dart';
import 'package:room_booking_app/utilities/crypto_utils.dart';
import 'package:tekartik_app_flutter_sembast/sembast.dart';
import 'package:tekartik_common_utils/common_utils_import.dart';

import 'main.dart';

late DbRmBookingProvider dbRmBookingProvider;
late UserProfileProvider userProfileProvider;

/// App initialization
Future<void> init() async {
  var databaseFactory = getDatabaseFactory();
  dbRmBookingProvider = DbRmBookingProvider(databaseFactory);
  userProfileProvider = UserProfileProvider(databaseFactory);
  await dbRmBookingProvider.ready;
  await userProfileProvider.ready;
  dbRmBookingProvider.clearAllRoomBookings;
  userProfileProvider.clearAllProfiles;
  //for testing admin
  userProfileProvider.saveProfile(DbUserProfile()
    ..id = DateTime.now().millisecondsSinceEpoch
    ..username.v = "admin@cor.sg".trim().toLowerCase()
    ..password.v =
        CryptoUtils.encrypt("admin@cor.sg".trim().toLowerCase(), "Admin@123")
    ..firstName.v = "The".trim().toUpperCase()
    ..lastName.v = "Admin".trim().toUpperCase()
    ..email.v = "admin@cor.sg".trim().toLowerCase()
    ..handphoneNumber.v = "123456".trim()
    ..service.v = TestData.roomList[0].toUpperCase()
    ..cell.v = TestData.cellList[0].toUpperCase()
    ..isAdmin.v = true
    ..createdDt = DateTime.now().millisecondsSinceEpoch
    ..updatedDt = DateTime.now().millisecondsSinceEpoch);
  runApp(MyApp());
}
