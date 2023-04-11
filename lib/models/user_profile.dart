import 'dart:convert';

import 'package:room_booking_app/models/db.dart';

class DbUserProfile extends DbRecord {
  final username = CvField<String>('username');
  final password = CvField<String>('password');
  final firstName = CvField<String>('firstName');
  final lastName = CvField<String>('lastName');
  final email = CvField<String>('email');
  final handphoneNumber = CvField<String>('handphoneNumber');
  final service = CvField<String>('service');
  final cell = CvField<String>('cell');
  final isAdmin = CvField<bool>('isAdmin');
  final createdDt = CvField<int>('createdDt');
  final updatedDt = CvField<int>('updatedDt');

  @override
  List<CvField> get fields => [
        username,
        password,
        firstName,
        lastName,
        email,
        handphoneNumber,
        service,
        cell,
        isAdmin,
        createdDt,
        updatedDt
      ];

  Map toJson() => {
        'username': username,
        'password': password,
        'firstName': firstName,
        'lastName': lastName,
        'email': email,
        'handphoneNumber': handphoneNumber,
        'service': service,
        'cell': cell,
        'isAdmin': isAdmin,
        'createdDt': createdDt,
        'updatedDt': updatedDt,
      };

  @override
  String toString() => jsonEncode(this);

  String getName() {
    return "${firstName.v} ${lastName.v}";
  }
}
