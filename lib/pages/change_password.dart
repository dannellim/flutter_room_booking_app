import 'package:flutter/material.dart';
import 'package:room_booking_app/app.dart';
import 'package:room_booking_app/models/user_profile.dart';
import 'package:room_booking_app/services/nav_service.dart';
import 'package:room_booking_app/utilities/crypto_utils.dart';
import 'package:room_booking_app/utilities/otp_utils.dart';
import 'package:room_booking_app/utilities/ui_utils.dart';
import 'package:room_booking_app/utilities/utils.dart';
import 'package:tekartik_common_utils/common_utils_import.dart';

class ChangePasswordPage extends StatefulWidget {
  final int profileId;
  const ChangePasswordPage({super.key, required this.profileId});
  @override
  State<ChangePasswordPage> createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends State<ChangePasswordPage> {
  late DbUserProfile _profile;
  final _formKey = GlobalKey<FormState>();
  final _oldPassController = TextEditingController();
  final _newPassController = TextEditingController();
  final _newAgainPassController = TextEditingController();
  late bool _oldPasswordVisible;
  late bool _newPasswordVisible;
  late bool _newAgainPasswordVisible;
  bool _isInitialized = false;

  bool _is8Character = false;
  bool _is1Upper = false;
  bool _is1Lower = false;
  bool _is1Digit = false;
  bool _is1Special = false;
  bool _isDiffOld = false;
  bool _areBothNewPassSame = false;

  String? get _pwdErrorText {
    // // at any time, we can get the text from _controller.value.text
    final text = _newPassController.value.text;
    final oldText = _oldPassController.value.text;
    _is8Character = Utils.isMin8Char(text);
    _is1Upper = Utils.is1UpperChar(text);
    _is1Lower = Utils.is1LowerChar(text);
    _is1Digit = Utils.is1Digit(text);
    _is1Special = Utils.is1SpecChar(text);
    _isDiffOld = text != oldText;
    // return null if the text is valid
    return null;
  }

  String? get _retypePwdErrorText {
    // // at any time, we can get the text from _controller.value.text
    final newText = _newPassController.value.text;
    final retypeText = _newAgainPassController.value.text;
    _areBothNewPassSame = newText == retypeText;
    // return null if the text is valid
    return null;
  }

  void _oldPwdToggle() {
    setState(() {
      _oldPasswordVisible = !_oldPasswordVisible;
    });
  }

  void _newPwdToggle() {
    setState(() {
      _newPasswordVisible = !_newPasswordVisible;
    });
  }

  void _newAgainPwdToggle() {
    setState(() {
      _newAgainPasswordVisible = !_newAgainPasswordVisible;
    });
  }

  @override
  void initState() {
    super.initState();
    _oldPasswordVisible = false;
    _newPasswordVisible = false;
    _newAgainPasswordVisible = false;
  }

  @override
  void dispose() {
    _oldPassController.dispose();
    _newPassController.dispose();
    _newAgainPassController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DbUserProfile?>(
        stream: userProfileProvider.onProfile(widget.profileId),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            if (snapshot.hasData && !_isInitialized) {
              _profile = snapshot.data!;
              _isInitialized = true;
            }
            return Scaffold(
              appBar: AppBar(
                title: const Text("Change Passsword"),
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
                        child: TextFormField(
                          controller: _oldPassController,
                          obscureText: !_oldPasswordVisible,
                          // The validator receives the text that the user has entered.
                          validator: (value) {
                            return Utils.passwordCheck(value);
                          },
                          onChanged: (text) => setState(() {}),
                          decoration: InputDecoration(
                            border: const OutlineInputBorder(),
                            hintText: 'Old Password',
                            labelText: 'Old Password',
                            suffixIcon: IconButton(
                              icon: Icon(_oldPasswordVisible
                                  ? Icons.visibility
                                  : Icons.visibility_off),
                              onPressed: _oldPwdToggle,
                            ),
                          ),
                        ),
                      ),
                      Container(
                        margin: const EdgeInsets.only(
                            top: 16, left: 16, right: 16, bottom: 0),
                        child: TextFormField(
                          controller: _newPassController,
                          obscureText: !_newPasswordVisible,
                          // The validator receives the text that the user has entered.
                          validator: (value) {
                            return Utils.passwordCheck(value);
                          },
                          onChanged: (text) => setState(() {}),
                          decoration: InputDecoration(
                            errorText: _pwdErrorText,
                            border: const OutlineInputBorder(),
                            hintText: 'New Password',
                            labelText: 'New Password',
                            suffixIcon: IconButton(
                              icon: Icon(_newPasswordVisible
                                  ? Icons.visibility
                                  : Icons.visibility_off),
                              onPressed: _newPwdToggle,
                            ),
                          ),
                        ),
                      ),
                      Container(
                        width: double.infinity,
                        margin: const EdgeInsets.only(
                            top: 16, left: 16, right: 16, bottom: 0),
                        child: Row(
                          children: [
                            _is8Character
                                ? const Icon(
                                    Icons.check_circle_rounded,
                                    color: Colors.green,
                                  )
                                : const Icon(
                                    Icons.remove_circle_rounded,
                                    color: Colors.red,
                                  ),
                            const SizedBox(width: 8),
                            const Expanded(
                                child: Text('At least 8 characters',
                                    textAlign: TextAlign.left,
                                    style: TextStyle(fontSize: 16))),
                          ],
                        ),
                      ),
                      Container(
                        width: double.infinity,
                        margin: const EdgeInsets.only(
                            top: 8, left: 16, right: 16, bottom: 0),
                        child: Row(
                          children: [
                            _is1Upper
                                ? const Icon(
                                    Icons.check_circle_rounded,
                                    color: Colors.green,
                                  )
                                : const Icon(
                                    Icons.remove_circle_rounded,
                                    color: Colors.red,
                                  ),
                            const SizedBox(width: 8),
                            const Expanded(
                                child: Text('At least ONE uppercase character',
                                    textAlign: TextAlign.left,
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                    softWrap: false,
                                    style: TextStyle(fontSize: 16))),
                          ],
                        ),
                      ),
                      Container(
                        width: double.infinity,
                        margin: const EdgeInsets.only(
                            top: 8, left: 16, right: 16, bottom: 0),
                        child: Row(
                          children: [
                            _is1Lower
                                ? const Icon(
                                    Icons.check_circle_rounded,
                                    color: Colors.green,
                                  )
                                : const Icon(
                                    Icons.remove_circle_rounded,
                                    color: Colors.red,
                                  ),
                            const SizedBox(width: 8),
                            const Expanded(
                                child: Text('At least ONE lowercase character',
                                    textAlign: TextAlign.left,
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                    softWrap: false,
                                    style: TextStyle(fontSize: 16))),
                          ],
                        ),
                      ),
                      Container(
                        width: double.infinity,
                        margin: const EdgeInsets.only(
                            top: 8, left: 16, right: 16, bottom: 0),
                        child: Row(
                          children: [
                            _is1Digit
                                ? const Icon(
                                    Icons.check_circle_rounded,
                                    color: Colors.green,
                                  )
                                : const Icon(
                                    Icons.remove_circle_rounded,
                                    color: Colors.red,
                                  ),
                            const SizedBox(width: 8),
                            const Expanded(
                                child: Text('At least ONE digit',
                                    textAlign: TextAlign.left,
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                    softWrap: false,
                                    style: TextStyle(fontSize: 16))),
                          ],
                        ),
                      ),
                      Container(
                        width: double.infinity,
                        margin: const EdgeInsets.only(
                            top: 8, left: 16, right: 16, bottom: 0),
                        child: Row(
                          children: [
                            _is1Special
                                ? const Icon(
                                    Icons.check_circle_rounded,
                                    color: Colors.green,
                                  )
                                : const Icon(
                                    Icons.remove_circle_rounded,
                                    color: Colors.red,
                                  ),
                            const SizedBox(width: 8),
                            const Expanded(
                                child: Text('At least ONE special character',
                                    textAlign: TextAlign.left,
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                    softWrap: false,
                                    style: TextStyle(fontSize: 16))),
                          ],
                        ),
                      ),
                      Container(
                        width: double.infinity,
                        margin: const EdgeInsets.only(
                            top: 8, left: 16, right: 16, bottom: 8),
                        child: Row(
                          children: [
                            _isDiffOld
                                ? const Icon(
                                    Icons.check_circle_rounded,
                                    color: Colors.green,
                                  )
                                : const Icon(
                                    Icons.remove_circle_rounded,
                                    color: Colors.red,
                                  ),
                            const SizedBox(width: 8),
                            Expanded(
                                child: Text(
                                    _isDiffOld
                                        ? 'Different from old password'
                                        : 'Same as old password',
                                    textAlign: TextAlign.left,
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                    softWrap: false,
                                    style: const TextStyle(fontSize: 16))),
                          ],
                        ),
                      ),
                      Container(
                        margin: const EdgeInsets.only(
                            top: 16, left: 16, right: 16, bottom: 0),
                        child: TextFormField(
                          controller: _newAgainPassController,
                          obscureText: !_newAgainPasswordVisible,
                          // The validator receives the text that the user has entered.
                          validator: (value) {
                            return Utils.passwordCheck(value);
                          },
                          onChanged: (text) => setState(() {}),
                          decoration: InputDecoration(
                            errorText: _retypePwdErrorText,
                            border: const OutlineInputBorder(),
                            hintText: 'Retype New Password',
                            labelText: 'Retype New Password',
                            suffixIcon: IconButton(
                              icon: Icon(_newAgainPasswordVisible
                                  ? Icons.visibility
                                  : Icons.visibility_off),
                              onPressed: _newAgainPwdToggle,
                            ),
                          ),
                        ),
                      ),
                      Container(
                        width: double.infinity,
                        margin: const EdgeInsets.only(
                            top: 16, left: 16, right: 16, bottom: 0),
                        child: Row(
                          children: [
                            _areBothNewPassSame
                                ? const Icon(
                                    Icons.check_circle_rounded,
                                    color: Colors.green,
                                  )
                                : const Icon(
                                    Icons.remove_circle_rounded,
                                    color: Colors.red,
                                  ),
                            const SizedBox(width: 8),
                            Expanded(
                                child: Text(
                                    _areBothNewPassSame
                                        ? 'Passwords match'
                                        : 'Passwords do not match',
                                    textAlign: TextAlign.left,
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                    softWrap: false,
                                    style: const TextStyle(fontSize: 16))),
                          ],
                        ),
                      ),
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.only(
                              top: 16, left: 16, right: 16, bottom: 16),
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              elevation: 3,
                              minimumSize: Size(
                                  MediaQuery.of(context).size.width,
                                  MediaQuery.of(context).size.height * 0.05),
                            ),
                            onPressed: () async {
                              await _changePass();
                            },
                            child: const Padding(
                              padding: EdgeInsets.all(16),
                              child: Text('Change Password',
                                  style: TextStyle(fontSize: 16)),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          } else {
            return const CircularProgressIndicator();
          }
        });
  }

  Future<bool> _changePass() async {
    bool result = false;
    if (_formKey.currentState!.validate()) {
      if (_areBothNewPassSame && _isDiffOld) {
        UiUtils.loadingSpinner();
        result = await _checkOldPassLogic();
        Navigator.of(NavigationService.navigatorKey.currentContext!).pop();
        if (result) {
          if (_profile.is2FA.v!) {
            var ans = await OtpUtils.showOtpAlert(_profile.username.v!);
            if (ans == null) {
              return false;
            }
            if (ans) {
              result = false;
              _changePassLogic();
              result = true;
            } else {
              UiUtils.showAlertDialog(
                  "Error", "OTP is wrong. Please try again.");
            }
          } else {
            result = false;
            _changePassLogic();
            result = true;
          }
        } else {
          UiUtils.showAlertDialog("Error", "Old password is wrong.");
        }
      }
    }
    return result;
  }

  void _changePassLogic() async {
    _profile.updatedDt = DateTime.now().millisecondsSinceEpoch;
    _profile.password.v = CryptoUtils.encrypt(
        _profile.username.v!.toLowerCase(), _newPassController.text);
    UiUtils.loadingSpinner();
    await userProfileProvider.saveProfile(_profile);
    Navigator.of(NavigationService.navigatorKey.currentContext!).pop();
    UiUtils.showAlertDialog("Success", "Your password has been changed!");
    _isInitialized = false;
    setState(() {
      _oldPassController.clear();
      _newAgainPassController.clear();
      _newPassController.clear();
    });
  }

  Future<bool> _checkOldPassLogic() async {
    bool result = false;
    var profiles = HashSet<DbUserProfile>.from(
        await userProfileProvider.onProfiles().first);
    if (profiles.isNotEmpty) {
      var password =
          CryptoUtils.encrypt(_profile.username.v!, _oldPassController.text);
      var profile = profiles.where((item) =>
          item.username.value?.toLowerCase() ==
              _profile.username.v?.toLowerCase() &&
          item.password.value == password);
      if (profile.isNotEmpty) {
        result = true;
      }
    }
    return result;
  }
}
