import 'package:base32/base32.dart';
import 'package:flutter/material.dart';
import 'package:flutter_otp_text_field/flutter_otp_text_field.dart';
import 'package:otp/otp.dart';
import 'package:room_booking_app/constants.dart';
import 'package:room_booking_app/services/nav_service.dart';

class OtpUtils {
  static String generateOtp(String secret) {
    return OTP.generateTOTPCodeString(
        secret, DateTime.now().millisecondsSinceEpoch,
        algorithm: Algorithm.SHA512, isGoogle: true);
  }

  static String generateSecret(String company, String email) {
    return base32.encodeString(company + email).replaceAll(RegExp(r'='), '');
  }

  static String generateQrData(String company, String email) {
    String base32secret = generateSecret(company, email);
    return "otpauth://totp/$company:$email?secret=$base32secret&issuer=$company&algorithm=SHA512&digits=6&period=30";
  }

  static Future<bool?> showOtpAlert(String username) async {
    return showDialog<bool>(
      context: NavigationService.navigatorKey.currentContext!,
      barrierDismissible: true,
      builder: (BuildContext context) {
        bool clearText = false;
        return StatefulBuilder(builder: (context, setState) {
          return AlertDialog(
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                const Text(
                  "Enter OTP",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(
                  height: 16,
                ),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: OtpTextField(
                      clearText: clearText,
                      numberOfFields: 6,
                      autoFocus: true,
                      showFieldAsBox: true,
                      focusedBorderColor: Theme.of(context).colorScheme.primary,
                      onCodeChanged: (String code) {
                        //handle validation or checks here
                      },
                      //runs when every textfield is filled
                      onSubmit: (String verificationCode) {
                        setState(() {
                          clearText = true;
                        });
                        String secret =
                            generateSecret(Constants.company, username);
                        String code = generateOtp(secret);
                        bool result = OTP.constantTimeVerification(
                            base32.encodeString(verificationCode),
                            base32.encodeString(code));
                        Navigator.pop(context, result);
                      }),
                ),
              ],
            ),
          );
        });
      },
    );
  }
}
