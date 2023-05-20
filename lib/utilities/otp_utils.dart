import 'package:base32/base32.dart';
import 'package:flutter/material.dart';
import 'package:flutter_otp_text_field/flutter_otp_text_field.dart';
import 'package:otp/otp.dart';
import 'package:qr_flutter/qr_flutter.dart';
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

  static Future<bool?> showOtpDialog(String email) async {
    return showDialog<bool>(
      context: NavigationService.navigatorKey.currentContext!,
      barrierDismissible: true,
      builder: (BuildContext context) {
        bool clearText = false;
        return StatefulBuilder(builder: (context, setState) {
          return AlertDialog(
            content: SingleChildScrollView(
              child: SizedBox(
                width: MediaQuery.of(context).size.width,
                child: Column(
                  children: <Widget>[
                    const Text(
                      "Enter OTP",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(
                      height: 32,
                    ),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: OtpTextField(
                        clearText: clearText,
                        numberOfFields: 6,
                        showFieldAsBox: true,
                        focusedBorderColor:
                            Theme.of(context).colorScheme.primary,
                        onCodeChanged: (String code) {
                          //handle validation or checks here
                        },
                        //runs when every textfield is filled
                        onSubmit: (String verificationCode) {
                          setState(() {
                            clearText = true;
                          });

                          String secret =
                              generateSecret(Constants.company, email);
                          String code = generateOtp(secret);
                          bool result = OTP.constantTimeVerification(
                              base32.encodeString(verificationCode),
                              base32.encodeString(code));
                          Navigator.pop(context, result);
                        }, // end onSubmit
                      ),
                    ),
                    const SizedBox(
                      height: 64,
                    ),
                    const Text("First time?"),
                    const SizedBox(
                      height: 8,
                    ),
                    const Text(
                        "Install Google Authenticator on your phone by scanning the QR Codes below for your respective device."),
                    const SizedBox(
                      height: 8,
                    ),
                    const Text(
                        "Follow the steps below to register your account for OTP generation."),
                    const SizedBox(
                      height: 32,
                    ),
                    Flex(
                      direction: MediaQuery.of(context).size.width >= 768
                          ? Axis.horizontal
                          : Axis.vertical,
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Column(
                          children: [
                            QrImageView(
                              data: Constants.authenticatorAppleStoreUrl,
                              version: QrVersions.auto,
                              size: 200.0,
                            ),
                            const Text("Apple Store"),
                          ],
                        ),
                        Column(
                          children: [
                            QrImageView(
                              data: Constants.authenticatorGoogleStoreUrl,
                              version: QrVersions.auto,
                              size: 200.0,
                            ),
                            const Text("Google Play Store"),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 64,
                    ),
                    const Text(
                        "Open your Google Authenticator and scan the QR Code below to register your account for OTP generation."),
                    const SizedBox(
                      height: 32,
                    ),
                    Column(
                      children: [
                        QrImageView(
                          data: generateQrData(Constants.company, email),
                          version: QrVersions.auto,
                          size: 200.0,
                        ),
                        const Text("Scan QR using Google Authenticator"),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        });
      },
    );
  }
}
