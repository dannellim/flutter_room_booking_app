// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility that Flutter provides. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';
import 'package:room_booking_app/utilities/otp_utils.dart';

void main() {
  group('otp utils', () {
    test('otp check', () async {
      String secret = "email_address@email.com::cor.sg";
      String otp1 = OtpUtils.generateOtp(secret);
      String otp2 = OtpUtils.generateOtp(secret);
      expect(otp1, otp2);
      String otp3 = OtpUtils.generateOtp("${secret}1");
      expect(otp1 != otp3, true);
    });
  });
}
