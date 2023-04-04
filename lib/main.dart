import 'package:flutter/material.dart';
import 'package:room_booking_app/behaviors/no_scroll_behavior.dart';
import 'package:room_booking_app/pages/login.dart';
import 'package:room_booking_app/services/nav_service.dart';

import 'app.dart';

Future<void> main() async {
  await init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: NavigationService.navigatorKey,
      scrollBehavior: NoThumbScrollBehavior().copyWith(scrollbars: false),
      title: 'Flutter Room Booking App',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blueGrey,
      ),
      home: const LoginPage(),
    );
  }
}
