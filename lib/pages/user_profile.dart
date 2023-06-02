import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:room_booking_app/app.dart';
import 'package:room_booking_app/constants.dart';
import 'package:room_booking_app/models/user_profile.dart';
import 'package:room_booking_app/services/nav_service.dart';
import 'package:room_booking_app/test_data.dart';
import 'package:room_booking_app/utilities/otp_utils.dart';
import 'package:room_booking_app/utilities/text_formatters.dart';
import 'package:room_booking_app/utilities/ui_utils.dart';
import 'package:room_booking_app/utilities/utils.dart';

class ProfilePage extends StatefulWidget {
  final int profileId;
  const ProfilePage({super.key, required this.profileId});
  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final _numController = TextEditingController();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  late DbUserProfile _profile;
  late bool _numVaild;
  late bool _emailValid;
  bool _isInitialized = false;
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

  String? get _errorText {
    // // at any time, we can get the text from _controller.value.text
    final text = _emailController.value.text;
    if (Utils.isEmailValid(text)) {
      _emailValid = true;
    } else {
      _emailValid = false;
    }
    // return null if the text is valid
    return null;
  }

  String _serviceDropdownValue = "";
  String _cellDropdownValue = "";

  @override
  void initState() {
    super.initState();
    _numVaild = false;
    _emailValid = false;
  }

  @override
  void dispose() {
    _numController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
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
              _initFormFields();
              _isInitialized = true;
            }
            return Scaffold(
              appBar: AppBar(
                title: const Text("User Profile"),
              ),
              body: Form(
                  key: _formKey,
                  child: SingleChildScrollView(
                      child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: <Widget>[
                              TextFormField(
                                // The validator receives the text that the user has entered.
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter your first name';
                                  } else {
                                    return null;
                                  }
                                },
                                decoration: const InputDecoration(
                                    border: OutlineInputBorder(),
                                    labelText: 'First Name'),
                                inputFormatters: [UpperCaseTextFormatter()],
                                controller: _firstNameController,
                              ),
                              const SizedBox(
                                height: 16,
                              ),
                              TextFormField(
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
                              const SizedBox(
                                height: 16,
                              ),
                              TextFormField(
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
                                    labelText:
                                        'Email (This does NOT change your username. It will still be your old email.)',
                                    errorText: _errorText,
                                    suffixIcon: IconButton(
                                        onPressed: null,
                                        icon: Icon(
                                          _emailValid
                                              ? Icons.check_circle
                                              : null,
                                          color: Colors.green,
                                        ))),
                              ),
                              const SizedBox(
                                height: 16,
                              ),
                              TextFormField(
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
                                            _numVaild
                                                ? Icons.check_circle
                                                : null,
                                            color: Colors.green,
                                          ))),
                                  inputFormatters: <TextInputFormatter>[
                                    FilteringTextInputFormatter.digitsOnly,
                                    LengthLimitingTextInputFormatter(8)
                                  ],
                                  keyboardType: TextInputType.number),
                              const SizedBox(
                                height: 16,
                              ),
                              DropdownButtonFormField<String>(
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
                                    .map<DropdownMenuItem<String>>(
                                        (String value) {
                                  return DropdownMenuItem<String>(
                                    value: value,
                                    child: Text(value),
                                  );
                                }).toList(),
                              ),
                              const SizedBox(
                                height: 16,
                              ),
                              DropdownButtonFormField<String>(
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
                                    .map<DropdownMenuItem<String>>(
                                        (String value) {
                                  return DropdownMenuItem<String>(
                                    value: value,
                                    child: Text(value),
                                  );
                                }).toList(),
                              ),
                              const SizedBox(
                                height: 16,
                              ),
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  elevation: 3,
                                  minimumSize: Size(
                                      MediaQuery.of(context).size.width,
                                      MediaQuery.of(context).size.height *
                                          0.05),
                                ),
                                onPressed: () async {
                                  // Validate returns true if the form is valid, or false otherwise.
                                  if (_formKey.currentState!.validate()) {
                                    var result = await _updateProfile();
                                    if (result) {
                                      UiUtils.showAlertDialog("Success",
                                          "Your profile has been updated!");
                                      _isInitialized = false;
                                      FocusManager.instance.primaryFocus
                                          ?.unfocus();
                                      setState(() {});
                                    } else {
                                      UiUtils.showAlertDialog("Failed",
                                          "Your profile has NOT been updated!");
                                    }
                                  }
                                },
                                child: const Padding(
                                  padding: EdgeInsets.all(16),
                                  child: Text('Update',
                                      style: TextStyle(fontSize: 16)),
                                ),
                              ),
                              const SizedBox(
                                height: 16,
                              ),
                              Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    const Text("Last updated: ",
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold)),
                                    Text(DateFormat("dd MMM yyyy hh:mm a")
                                        .format(
                                            DateTime.fromMillisecondsSinceEpoch(
                                                _profile.updatedDt))),
                                  ]),
                              const SizedBox(
                                height: 16,
                              ),
                              Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    const Text("Created: ",
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold)),
                                    Text(DateFormat("dd MMM yyyy hh:mm a")
                                        .format(
                                            DateTime.fromMillisecondsSinceEpoch(
                                                _profile.createdDt))),
                                  ]),
                              const SizedBox(
                                height: 16,
                              ),
                              Row(
                                children: [
                                  Switch(
                                    value: _profile.is2FA.v!,
                                    activeColor: Colors.green,
                                    onChanged: (bool value) async {
                                      // This is called when the user toggles the switch.
                                      setState(() {
                                        _profile.is2FA.v = value;
                                        _profile.updatedDt = DateTime.now()
                                            .millisecondsSinceEpoch;
                                      });
                                      await userProfileProvider
                                          .saveProfile(_profile);
                                    },
                                  ),
                                  _profile.is2FA.v!
                                      ? const Text("Turn off 2FA")
                                      : const Text("Turn on 2FA"),
                                ],
                              ),
                              Visibility(
                                  visible: _profile.is2FA.v!,
                                  child: Column(
                                    children: [
                                      const SizedBox(
                                        height: 16,
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
                                        direction:
                                            MediaQuery.of(context).size.width >=
                                                    768
                                                ? Axis.horizontal
                                                : Axis.vertical,
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceEvenly,
                                        children: [
                                          Column(
                                            children: [
                                              QrImageView(
                                                data: Constants
                                                    .authenticatorAppleStoreUrl,
                                                version: QrVersions.auto,
                                                size: 200.0,
                                              ),
                                              const Text("Apple Store"),
                                            ],
                                          ),
                                          Column(
                                            children: [
                                              QrImageView(
                                                data: Constants
                                                    .authenticatorGoogleStoreUrl,
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
                                            data: OtpUtils.generateQrData(
                                                Constants.company,
                                                _profile.username.v!),
                                            version: QrVersions.auto,
                                            size: 200.0,
                                          ),
                                          const Text(
                                              "Scan QR using Google Authenticator"),
                                        ],
                                      ),
                                    ],
                                  ))
                            ],
                          )))),
            );
          } else {
            return const CircularProgressIndicator();
          }
        });
  }

  void _initFormFields() {
    _numController.text = _profile.handphoneNumber.v!;
    _numController.selection = _numController.selection.copyWith(
        baseOffset: _profile.handphoneNumber.v!.length,
        extentOffset: _profile.handphoneNumber.v!.length);
    _firstNameController.text = _profile.firstName.v!;
    _firstNameController.selection = _firstNameController.selection.copyWith(
        baseOffset: _profile.firstName.v!.length,
        extentOffset: _profile.firstName.v!.length);
    _lastNameController.text = _profile.lastName.v!;
    _lastNameController.selection = _lastNameController.selection.copyWith(
        baseOffset: _profile.lastName.v!.length,
        extentOffset: _profile.lastName.v!.length);
    _emailController.text = _profile.email.v!;
    _emailController.selection = _emailController.selection.copyWith(
        baseOffset: _profile.email.v!.length,
        extentOffset: _profile.email.v!.length);
    for (var item in TestData.serviceList) {
      if (item.toUpperCase().compareTo(_profile.service.v!.toUpperCase()) ==
          0) {
        _serviceDropdownValue = item;
        break;
      }
    }
    if (_serviceDropdownValue.trim().isEmpty) {
      UiUtils.showAlertDialog("Error",
          "Unable to find service within database. Please contact the administrator for help.");
      _serviceDropdownValue = TestData.serviceList.last;
    }
    for (var item in TestData.cellList) {
      if (item.toUpperCase().compareTo(_profile.cell.v!.toUpperCase()) == 0) {
        _cellDropdownValue = item;
        break;
      }
    }
    if (_cellDropdownValue.trim().isEmpty) {
      UiUtils.showAlertDialog("Error",
          "Unable to find cell within database. Please contact the administrator for help.");
      _cellDropdownValue = TestData.cellList.last;
    }
  }

  Future<bool> _updateProfile() async {
    UiUtils.loadingSpinner();
    bool result = false;
    try {
      _profile.firstName.v = _firstNameController.text.trim().toUpperCase();
      _profile.lastName.v = _lastNameController.text.trim().toUpperCase();
      _profile.email.v = _emailController.text.trim();
      _profile.handphoneNumber.v = _numController.text;
      _profile.service.v = _serviceDropdownValue.trim().toUpperCase();
      _profile.cell.v = _cellDropdownValue.trim().toUpperCase();
      _profile.updatedDt = DateTime.now().millisecondsSinceEpoch;
      await userProfileProvider.saveProfile(_profile);
      result = true;
    } on Exception catch (e, s) {
      // ignore: use_build_context_synchronously
      UiUtils.showAlertDialog("Exception", s.toString());
    }
    Navigator.of(NavigationService.navigatorKey.currentContext!).pop();
    return result;
  }
}
