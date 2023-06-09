import 'package:flutter/material.dart';
import 'package:room_booking_app/app.dart';
import 'package:room_booking_app/models/user_profile.dart';
import 'package:room_booking_app/pages/forget_password.dart';
import 'package:room_booking_app/pages/room_booking.dart';
import 'package:room_booking_app/services/nav_service.dart';
import 'package:room_booking_app/utilities/crypto_utils.dart';
import 'package:room_booking_app/utilities/otp_utils.dart';
import 'package:room_booking_app/utilities/ui_utils.dart';
import 'package:room_booking_app/utilities/utils.dart';
import 'package:tekartik_common_utils/common_utils_import.dart';
import 'sign_up.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  // Create a global key that uniquely identifies the Form widget
  // and allows validation of the form.
  //
  // Note: This is a `GlobalKey<FormState>`,
  // not a GlobalKey<MyCustomFormState>.
  final _formKey = GlobalKey<FormState>();
  late bool _passwordVisible;
  late bool _emailVaild;
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  String? get _errorText {
    // // at any time, we can get the text from _controller.value.text
    final text = emailController.value.text;
    if (Utils.isEmailValid(text)) {
      _emailVaild = true;
    } else {
      _emailVaild = false;
    }
    // return null if the text is valid
    return null;
  }

  void _toggle() {
    setState(() {
      _passwordVisible = !_passwordVisible;
    });
  }

  @override
  void initState() {
    super.initState();
    _passwordVisible = false;
    _emailVaild = false;
  }

  @override
  void dispose() {
    emailController.dispose();
    super.dispose();
  }

  void _clearFields() {
    emailController.clear();
    passwordController.clear();
    _passwordVisible = false;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    // Build a Form widget using the _formKey created above.
    return Scaffold(
      body: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.only(
                  top: 96, left: 32, right: 32, bottom: 0),
              child: Center(
                  child: SizedBox(
                width: 200,
                height: 150,
                child: Image.asset('images/flutter_logo.png',
                    fit: BoxFit.fitWidth),
              )),
            ),
            Container(
              margin:
                  const EdgeInsets.only(top: 0, left: 32, right: 32, bottom: 0),
              child: TextFormField(
                onFieldSubmitted: (value) => _login(),
                controller: emailController,
                // The validator receives the text that the user has entered.
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your email address';
                  }
                  if (Utils.isEmailValid(value)) {
                    return null;
                  } else {
                    return 'Invalid email address';
                  }
                },
                onChanged: (text) => setState(() {}),
                decoration: InputDecoration(
                    border: const OutlineInputBorder(),
                    hintText: 'test@example.com',
                    labelText: 'Email Address',
                    errorText: _errorText,
                    suffixIcon: IconButton(
                        onPressed: null,
                        icon: Icon(
                          _emailVaild ? Icons.check_circle : null,
                          color: Colors.green,
                        ))),
              ),
            ),
            Container(
              margin: const EdgeInsets.only(
                  top: 16, left: 32, right: 32, bottom: 0),
              child: TextFormField(
                onFieldSubmitted: (value) => _login(),
                controller: passwordController,
                obscureText: !_passwordVisible,
                // The validator receives the text that the user has entered.
                // validator: (value) {
                //   return Utils.passwordCheck(value);
                // },
                decoration: InputDecoration(
                  border: const OutlineInputBorder(),
                  hintText: 'Password',
                  labelText: 'Password',
                  suffixIcon: IconButton(
                    icon: Icon(_passwordVisible
                        ? Icons.visibility
                        : Icons.visibility_off),
                    onPressed: _toggle,
                  ),
                ),
              ),
            ),
            Center(
              child: Padding(
                padding: const EdgeInsets.only(
                    top: 8, left: 32, right: 32, bottom: 0),
                child: TextButton(
                  onPressed: () async {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const ForgetPasswordPage()),
                    );
                  },
                  child: const Text(
                    'Forgot Password',
                  ),
                ),
              ),
            ),
            Center(
              child: Padding(
                padding: const EdgeInsets.only(
                    top: 8, left: 32, right: 32, bottom: 16),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    elevation: 3,
                    minimumSize: Size(MediaQuery.of(context).size.width,
                        MediaQuery.of(context).size.height * 0.05),
                  ),
                  onPressed: () async {
                    _login();
                  },
                  child: const Padding(
                    padding: EdgeInsets.all(16),
                    child: Text('Login', style: TextStyle(fontSize: 16)),
                  ),
                ),
              ),
            ),
            Center(
              child: Padding(
                padding: const EdgeInsets.only(
                    top: 32, left: 32, right: 32, bottom: 16),
                child: TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const SignUpPage()),
                    );
                  },
                  child: const Text(
                    'New User? Create Account',
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _login() async {
    if (_formKey.currentState!.validate()) {
      UiUtils.loadingSpinner();
      var result = await _loginLogic();
      _clearFields();
      Navigator.of(NavigationService.navigatorKey.currentContext!)
          .pop(); //close spinner
      if (result != null) {
        if (result.isApproved.v!) {
          if (result.is2FA.v!) {
            var ans = await OtpUtils.showOtpAlert(result.username.v!);
            if (ans!) {
              _loginToHome(result);
            } else {
              UiUtils.showAlertDialog(
                  "Error", "OTP is wrong. Please try again.");
            }
          } else {
            _loginToHome(result);
          }
        } else {
          UiUtils.showAlertDialog("Error",
              "Please contact your administrator to approve your account first.");
        }
      } else {
        UiUtils.showAlertDialog("Error", "Invalid username or password.");
      }
    }
  }

  void _loginToHome(DbUserProfile result) {
    Navigator.push(
      NavigationService.navigatorKey.currentContext!,
      MaterialPageRoute(
          builder: (context) => RoomBookingPage(
                profileId: result.id!,
                isAdmin: result.isAdmin.v!,
              )),
    );
  }

  Future<DbUserProfile?> _loginLogic() async {
    DbUserProfile? result;
    var email = emailController.text.trim().toLowerCase();
    var password = CryptoUtils.encrypt(email, passwordController.text);
    var profiles = HashSet<DbUserProfile>.from(
        await userProfileProvider.onProfiles().first);
    var profile = profiles.where((item) =>
        item.username.value?.toLowerCase() == email &&
        item.password.value == password);
    if (profile.length == 1) {
      result = profile.first;
    }
    return result;
  }
}
