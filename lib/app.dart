// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:room_booking_app/providers/room_booking_provider.dart';
import 'package:tekartik_app_flutter_sembast/sembast.dart';
import 'package:tekartik_common_utils/common_utils_import.dart';

import 'main.dart';

late DbRmBookingProvider dbRmBookingProvider;

/// App initialization
Future<void> init() async {
  var databaseFactory = getDatabaseFactory();
  dbRmBookingProvider = DbRmBookingProvider(databaseFactory);
  await dbRmBookingProvider.ready;
  dbRmBookingProvider.clearAllRoomBookings;
  runApp(MyApp());
}
