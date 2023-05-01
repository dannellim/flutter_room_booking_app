import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:room_booking_app/app.dart';
import 'package:room_booking_app/models/user_profile.dart';
import 'package:room_booking_app/test_data.dart';
import 'package:room_booking_app/utilities/crypto_utils.dart';
import 'package:room_booking_app/utilities/ui_utils.dart';
import 'package:room_booking_app/utilities/utils.dart';
import 'package:room_booking_app/utilities/text_formatters.dart';
import 'package:tekartik_common_utils/common_utils_import.dart';

// Define a custom Form widget.
class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  SignupPageState createState() {
    return SignupPageState();
  }
}

// Define a corresponding State class.
// This class holds data related to the form.
class SignupPageState extends State<SignUpPage> {
  static const String saveSuccess = "saveSuccess";
  static const String saveFail = "saveFail";
  static const String saveExists = "saveExists";
  // Create a global key that uniquely identifies the Form widget
  // and allows validation of the form.
  //
  // Note: This is a `GlobalKey<FormState>`,
  // not a GlobalKey<MyCustomFormState>.
  final _formKey = GlobalKey<FormState>();
  late bool _emailVaild;
  late bool _numVaild;
  late bool _passwordVisible;

  String? get _errorText {
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

  String? get _numErrorText {
    // // at any time, we can get the text from _controller.value.text
    final text = _numController.value.text;
    if (text.length == 8) {
      _numVaild = true;
    } else {
      _numVaild = false;
    }
    // return null if the text is valid
    return null;
  }

  void _toggle() {
    setState(() {
      _passwordVisible = !_passwordVisible;
    });
  }

  final _numController = TextEditingController();
  final _passwordController = TextEditingController();
  final _emailController = TextEditingController();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _numController.dispose();
    _passwordController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _passwordVisible = false;
    _emailVaild = false;
    _numVaild = false;
  }

  String _serviceDropdownValue = TestData.serviceList.first;
  String _cellDropdownValue = TestData.cellList.first;

  bool _is8Character = false;
  bool _is1Upper = false;
  bool _is1Lower = false;
  bool _is1Digit = false;
  bool _is1Special = false;

  String? get _pwdErrorText {
    // // at any time, we can get the text from _controller.value.text
    final text = _passwordController.value.text;
    _is8Character = Utils.isMin8Char(text);
    _is1Upper = Utils.is1UpperChar(text);
    _is1Lower = Utils.is1LowerChar(text);
    _is1Digit = Utils.is1Digit(text);
    _is1Special = Utils.is1SpecChar(text);
    // return null if the text is valid
    return null;
  }

  @override
  Widget build(BuildContext context) {
    // Build a Form widget using the _formKey created above.
    return Scaffold(
      appBar: AppBar(
        title: const Text("Sign up"),
      ),
      body: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: double.infinity,
                margin: const EdgeInsets.only(
                    top: 16, left: 16, right: 16, bottom: 0),
                child: const Text('Profile Details',
                    textAlign: TextAlign.left,
                    style:
                        TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
              Container(
                margin: const EdgeInsets.only(
                    top: 16, left: 16, right: 16, bottom: 0),
                child: TextFormField(
                  // The validator receives the text that the user has entered.
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your first name';
                    } else {
                      return null;
                    }
                  },
                  decoration: const InputDecoration(
                      border: OutlineInputBorder(), labelText: 'First Name'),
                  inputFormatters: [UpperCaseTextFormatter()],
                  controller: _firstNameController,
                ),
              ),
              Container(
                margin: const EdgeInsets.only(
                    top: 16, left: 16, right: 16, bottom: 0),
                child: TextFormField(
                  // The validator receives the text that the user has entered.
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your last name';
                    } else {
                      return null;
                    }
                  },
                  inputFormatters: [UpperCaseTextFormatter()],
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Last Name',
                  ),
                  controller: _lastNameController,
                ),
              ),
              Container(
                margin: const EdgeInsets.only(
                    top: 16, left: 16, right: 16, bottom: 0),
                child: TextFormField(
                  // The validator receives the text that the user has entered.
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your email';
                    }
                    if (Utils.isEmailValid(value)) {
                      return null;
                    } else {
                      return 'Invalid email address';
                    }
                  },
                  inputFormatters: [LowerCaseTextFormatter()],
                  controller: _emailController,
                  onChanged: (text) => setState(() {}),
                  decoration: InputDecoration(
                      border: const OutlineInputBorder(),
                      hintText: 'test@example.com',
                      labelText: 'Email (This will be your username)',
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
                    top: 16, left: 16, right: 16, bottom: 0),
                child: TextFormField(
                    // The validator receives the text that the user has entered.
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your phone number';
                      }
                      if (value.length == 8) {
                        return null;
                      } else {
                        return 'Invalid phone number';
                      }
                    },
                    controller: _numController,
                    onChanged: (text) => setState(() {}),
                    decoration: InputDecoration(
                        border: const OutlineInputBorder(),
                        labelText: 'Handphone Number',
                        errorText: _numErrorText,
                        suffixIcon: IconButton(
                            onPressed: null,
                            icon: Icon(
                              _numVaild ? Icons.check_circle : null,
                              color: Colors.green,
                            ))),
                    inputFormatters: <TextInputFormatter>[
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(8)
                    ],
                    keyboardType: TextInputType.number),
              ),
              Container(
                margin: const EdgeInsets.only(
                    top: 16, left: 16, right: 16, bottom: 0),
                child: DropdownButtonFormField<String>(
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Service',
                  ),
                  isExpanded: true,
                  value: _serviceDropdownValue,
                  icon: const Icon(Icons.arrow_drop_down),
                  onChanged: (String? value) {
                    // This is called when the user selects an item.
                    setState(() {
                      _serviceDropdownValue = value!;
                    });
                  },
                  items: TestData.serviceList
                      .map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                ),
              ),
              Container(
                margin: const EdgeInsets.only(
                    top: 16, left: 16, right: 16, bottom: 0),
                child: DropdownButtonFormField<String>(
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Cell Group',
                  ),
                  isExpanded: true,
                  value: _cellDropdownValue,
                  icon: const Icon(Icons.arrow_drop_down),
                  onChanged: (String? value) {
                    // This is called when the user selects an item.
                    setState(() {
                      _cellDropdownValue = value!;
                    });
                  },
                  items: TestData.cellList
                      .map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                ),
              ),
              Container(
                width: double.infinity,
                margin: const EdgeInsets.only(
                    top: 16, left: 16, right: 16, bottom: 0),
                child: const Text('Account Details',
                    textAlign: TextAlign.left,
                    style:
                        TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
              Container(
                margin: const EdgeInsets.only(
                    top: 16, left: 16, right: 16, bottom: 0),
                child: TextFormField(
                  enabled: false,
                  controller: _emailController,
                  decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText:
                          'Username (This is your email. You cannot change this.)'),
                ),
              ),
              Container(
                margin: const EdgeInsets.only(
                    top: 16, left: 16, right: 16, bottom: 0),
                child: TextFormField(
                  controller: _passwordController,
                  obscureText: !_passwordVisible,
                  // The validator receives the text that the user has entered.
                  validator: (value) {
                    return Utils.passwordCheck(value);
                  },
                  onChanged: (text) => setState(() {}),
                  decoration: InputDecoration(
                    errorText: _pwdErrorText,
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
                      // Validate returns true if the form is valid, or false otherwise.
                      if (_formKey.currentState!.validate()) {
                        var result = await _saveUserProfile(context.mounted);
                        if (context.mounted) {
                          if (result == saveExists) {
                            UiUtils.showAlertDialog(
                                "Error", "This email is already in use.");
                          } else if (result == saveSuccess) {
                            Navigator.of(context)
                                .popUntil((route) => route.isFirst);
                            UiUtils.showAlertDialog("Success",
                                "Your account has been successfully created!");
                          } else {
                            UiUtils.showAlertDialog("Error",
                                "Unable to create account. Please contact the helpdesk for more information.");
                          }
                        }
                      }
                    },
                    child: const Padding(
                      padding: EdgeInsets.all(16),
                      child: Text('Sign Up', style: TextStyle(fontSize: 16)),
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

  Future<String> _saveUserProfile([bool mounted = true]) async {
    UiUtils.loadingSpinner();
    var result = await _userProfileLogic();
    if (!mounted) return saveFail;
    Navigator.of(context).pop();
    return result;
  }

  Future<String> _userProfileLogic() async {
    var result = saveFail;
    var email = _emailController.text.trim().toLowerCase();
    //check if email already exists
    var profiles = HashSet<DbUserProfile>.from(
        await userProfileProvider.onProfiles().first);
    var profile =
        profiles.where((item) => item.username.value?.toLowerCase() == email);
    if (profile.length == 1) {
      return saveExists;
    }

    try {
      await userProfileProvider.saveProfile(DbUserProfile()
        ..id = DateTime.now().millisecondsSinceEpoch
        ..username.v = _emailController.text.trim().toLowerCase()
        ..password.v = CryptoUtils.encrypt(
            _emailController.text.trim().toLowerCase(),
            _passwordController.text)
        ..firstName.v = _firstNameController.text.trim().toUpperCase()
        ..lastName.v = _lastNameController.text.trim().toUpperCase()
        ..email.v = _emailController.text.trim().toLowerCase()
        ..handphoneNumber.v = _numController.text.trim()
        ..service.v = _serviceDropdownValue.trim().toUpperCase()
        ..cell.v = _cellDropdownValue.trim().toUpperCase()
        ..isAdmin.v = true
        ..createdDt.v = DateTime.now().millisecondsSinceEpoch
        ..updatedDt.v = DateTime.now().millisecondsSinceEpoch);
      result = saveSuccess;
    } on Exception catch (e, s) {
      // ignore: use_build_context_synchronously
      UiUtils.showAlertDialog("Exception", s.toString());
    }
    return result;
  }
}
