import 'package:base32/base32.dart';
import 'package:otp/otp.dart';
import 'package:room_booking_app/utilities/ui_utils.dart';

class OtpUtils {
  static String generateOtp(String secret) {
    String result = "";
    try {
      String base32secret = base32.encodeString(secret);
      result = OTP.generateTOTPCodeString(
          base32secret, DateTime.now().millisecondsSinceEpoch,
          isGoogle: true);
    } catch (e) {
      UiUtils.showAlertDialog("Error", e.toString());
    }
    return result;
  }
}
