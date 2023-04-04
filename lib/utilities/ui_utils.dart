import 'package:flutter/material.dart';
import 'package:room_booking_app/services/nav_service.dart';

class UiUtils {
  static void showAlertDialog(String btnText, String title, String message) {
    // set up the button
    Widget okButton = TextButton(
      child: Text(btnText),
      onPressed: () {
        Navigator.of(NavigationService.navigatorKey.currentContext!).pop();
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
      context: NavigationService.navigatorKey.currentContext!,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  static void loadingSpinner() async {
    showDialog(
        // The user CANNOT close this dialog  by pressing outsite it
        barrierDismissible: false,
        context: NavigationService.navigatorKey.currentContext!,
        builder: (_) {
          return Dialog(
            // The background color
            backgroundColor: Colors.white,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  // The loading indicator
                  CircularProgressIndicator(),
                  SizedBox(
                    height: 32,
                  ),
                  // Some text
                  Text('Loading...')
                ],
              ),
            ),
          );
        });
  }
}
