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
}
