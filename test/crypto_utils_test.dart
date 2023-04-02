// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility that Flutter provides. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';
import 'package:room_booking_app/utilities/crypto_utils.dart';

void main() {
  group('crypto utils', () {
    test('encrypt decrypt', () async {
      String password = "password";
      String key = "key";
      String encrypted = CryptoUtils.encrypt(key, password);
      expect(password.toLowerCase() != encrypted.toLowerCase(), true);
      String decrypted = CryptoUtils.decrypt(key, encrypted);
      expect(password, decrypted);
    });
  });
}
