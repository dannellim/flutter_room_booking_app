// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:room_booking_app/providers/room_booking_provider.dart';
import 'package:room_booking_app/providers/user_profile_provider.dart';
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
  runApp(MyApp());
}
