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

  //for testing admin
  int adminId = 888;
  var profiles = await userProfileProvider.getProfile(adminId);
  if (profiles == null) {
    await userProfileProvider.saveProfile(DbUserProfile()
      ..id = adminId
      ..username.v = "admin@cor.sg".trim().toLowerCase()
      ..password.v =
          CryptoUtils.encrypt("admin@cor.sg".trim().toLowerCase(), "Admin@123")
      ..firstName.v = "The".trim().toUpperCase()
      ..lastName.v = "Admin".trim().toUpperCase()
      ..email.v = "admin@cor.sg".trim().toLowerCase()
      ..handphoneNumber.v = "12345678".trim()
      ..service.v = TestData.serviceList.last.toUpperCase()
      ..cell.v = TestData.cellList.last.toUpperCase()
      ..is2FA.v = false
      ..isAdmin.v = true
      ..isApproved.v = true);
  }

  runApp(MyApp());
}
