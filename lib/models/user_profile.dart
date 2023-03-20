import 'dart:convert';

class UserProfile {
  late String username;
  late String password;
  late String firstName;
  late String lastName;
  late String email;
  late String handphoneNumber;
  late String service;
  late String cell;
  bool isAdmin = false;

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
      };

  @override
  String toString() => jsonEncode(this);
}
