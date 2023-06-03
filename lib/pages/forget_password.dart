import 'package:flutter/material.dart';
import 'package:room_booking_app/app.dart';
import 'package:room_booking_app/services/nav_service.dart';
import 'package:room_booking_app/utilities/text_formatters.dart';
import 'package:room_booking_app/utilities/ui_utils.dart';
import 'package:room_booking_app/utilities/utils.dart';

class ForgetPasswordPage extends StatefulWidget {
  const ForgetPasswordPage({super.key});
  @override
  State<ForgetPasswordPage> createState() => _ForgetPasswordPageState();
}

class _ForgetPasswordPageState extends State<ForgetPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  late bool _emailVaild;

  String? get _emailErrorText {
    // // at any time, we can get the text from _controller.value.text
    final text = _emailController.value.text;
    if (Utils.isEmailValid(text)) {
      _emailVaild = true;
    } else {
      _emailVaild = false;
    }
    // return null if the text is valid
    return null;
  }

  final _emailController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _emailVaild = false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Forget Password"),
      ),
      body: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Container(
                margin: const EdgeInsets.only(
                    top: 16, left: 16, right: 16, bottom: 0),
                child: const Text(
                    'Please enter your username to submit a request to the administrator to reset your account password.'),
              ),
              Container(
                margin: const EdgeInsets.only(
                    top: 16, left: 16, right: 16, bottom: 0),
                child: TextFormField(
                  // The validator receives the text that the user has entered.
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your username';
                    }
                    if (Utils.isEmailValid(value)) {
                      return null;
                    } else {
                      return 'Invalid username';
                    }
                  },
                  inputFormatters: [LowerCaseTextFormatter()],
                  controller: _emailController,
                  onChanged: (text) => setState(() {}),
                  decoration: InputDecoration(
                      border: const OutlineInputBorder(),
                      hintText: 'test@example.com',
                      labelText: 'Username (The email you signed up with)',
                      errorText: _emailErrorText,
                      suffixIcon: IconButton(
                          onPressed: null,
                          icon: Icon(
                            _emailVaild ? Icons.check_circle : null,
                            color: Colors.green,
                          ))),
                ),
              ),
              Center(
                child: Padding(
                  padding: const EdgeInsets.only(
                      top: 16, left: 16, right: 16, bottom: 16),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      elevation: 3,
                      minimumSize: Size(MediaQuery.of(context).size.width,
                          MediaQuery.of(context).size.height * 0.05),
                    ),
                    onPressed: () async {
                      _resetPasswordLogic();
                    },
                    child: const Padding(
                      padding: EdgeInsets.all(16),
                      child: Text('Request password reset',
                          style: TextStyle(
                              fontSize: 16, overflow: TextOverflow.ellipsis)),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _resetPasswordLogic() async {
    if (_formKey.currentState!.validate()) {
      UiUtils.loadingSpinner();
      var username = _emailController.text.trim().toLowerCase();
      var profiles = await userProfileProvider.onProfiles().first;
      var profile = profiles
          .where((item) => item.username.value?.toLowerCase() == username);
      _emailController.clear();
      setState(() {});
      Navigator.of(NavigationService.navigatorKey.currentContext!).pop();
      if (profile.length == 1) {
        if (!profile.first.isPasswordReset.v!) {
          profile.first.isPasswordReset.v = true;
          await userProfileProvider.saveProfile(profile.first);
          UiUtils.showAlertDialog("Success",
              "Password reset has been requested. Please contact your administrator if you wish to speed up this process.");
        } else if (profile.first.isPasswordReset.v!) {
          UiUtils.showAlertDialog("Error",
              "Password reset has already been requested. Please contact your administrator if you wish to speed up this process.");
        }
      } else {
        UiUtils.showAlertDialog("Error", "Username does not exist.");
      }
    }
  }
}
