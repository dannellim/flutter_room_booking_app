class Utils {
  static bool isSimpleStringsSame(String one, String two) {
    var first = one.toLowerCase().replaceAll(RegExp(r"\s+"), "");
    var second = two.toLowerCase().replaceAll(RegExp(r"\s+"), "");
    if (first.compareTo(second) == 0) {
      return true;
    } else {
      return false;
    }
  }

  static bool isEmailValid(String email) {
    return RegExp(
            r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]{2,}")
        .hasMatch(email);
  }

  static String? passwordCheck(String? password) {
    if (password == null || password.isEmpty) {
      return 'Please enter your password';
    }
    if (isPasswordValid(password)) {
      return null;
    } else {
      String error = "Password needs to ";
      if (!isMin8Char(password)) {
        error += "be at least 8 characters; ";
      }
      if (!is1UpperChar(password)) {
        error += "have at least ONE uppercase character; ";
      }
      if (!is1LowerChar(password)) {
        error += "have at least ONE lowercase character; ";
      }
      if (!is1Digit(password)) {
        error += "have at least ONE digit; ";
      }
      if (!is1SpecChar(password)) {
        error += "have at least special character; ";
      }
      return error;
    }
  }

  static bool isPasswordValid(String password) {
    return isMin8Char(password) &&
        is1UpperChar(password) &&
        is1LowerChar(password) &&
        is1Digit(password) &&
        is1SpecChar(password);
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
