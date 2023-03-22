import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class Utils {
  static bool isEmailValid(String email) {
    return RegExp(
            r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]{3,}")
        .hasMatch(email);
  }

  static bool isMin8Char(String text) {
    return RegExp(r"^.{8,}$").hasMatch(text);
  }

  static bool is1UpperChar(String text) {
    return RegExp(r"(?=.*[A-Z])").hasMatch(text);
  }

  static bool is1LowerChar(String text) {
    return RegExp(r"(?=.*[a-z])").hasMatch(text);
  }

  static bool is1Digit(String text) {
    return RegExp(r"(?=.*\d)").hasMatch(text);
  }

  static bool is1SpecChar(String text) {
    return RegExp(r"(?=.*\W)").hasMatch(text);
  }

  static void showAlertDialog(
      BuildContext context, String btnText, String title, String message) {
    // set up the button
    Widget okButton = TextButton(
      child: Text(btnText),
      onPressed: () {
        Navigator.of(context).pop();
      },
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text(title),
      content: Text(message),
      actions: [
        okButton,
      ],
    );

    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }
}
