import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:random_password_generator/random_password_generator.dart';
import 'package:room_booking_app/app.dart';
import 'package:room_booking_app/constants.dart';
import 'package:room_booking_app/models/user_profile.dart';
import 'package:room_booking_app/test_data.dart';
import 'package:room_booking_app/utilities/crypto_utils.dart';
import 'package:room_booking_app/utilities/otp_utils.dart';
import 'package:room_booking_app/utilities/text_formatters.dart';
import 'package:room_booking_app/utilities/ui_utils.dart';
import 'package:room_booking_app/utilities/utils.dart';

class AdminPage extends StatefulWidget {
  const AdminPage({super.key});
  @override
  State<AdminPage> createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {
  final _serviceController = TextEditingController();
  final _cellController = TextEditingController();
  final _roomController = TextEditingController();
  final _reasonController = TextEditingController();
  final _usernameController = TextEditingController();
  String _serviceDropdownValue = TestData.serviceList.first;
  String _cellDropdownValue = TestData.cellList.first;
  String _roomDropdownValue = TestData.roomList.first;
  String _reasonDropdownValue = TestData.reasonList.first;

  @override
  void dispose() {
    _serviceController.dispose();
    _cellController.dispose();
    _roomController.dispose();
    _reasonController.dispose();
    _usernameController.dispose();
    super.dispose();
  }

  List<DbUserProfile> _profiles = List.empty();
  List<DbUserProfile> _toApproveProfiles = List.empty();
  List<DbUserProfile> _toResetProfiles = List.empty();
  DbUserProfile? _toApproveDbUserProfile;
  DbUserProfile? _toResetDbUserProfile;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Administration"),
      ),
      body: StreamBuilder<List<DbUserProfile>>(
          stream: userProfileProvider.onProfiles(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              _profiles = snapshot.data!;
              _toApproveProfiles = _profiles
                  .where((item) => item.isApproved.value == false)
                  .toList();
              _toResetProfiles = _profiles
                  .where((item) => item.isPasswordReset.value == true)
                  .toList();
              if (_toApproveProfiles.isNotEmpty) {
                _toApproveDbUserProfile = _toApproveProfiles.first;
              }
              if (_toResetProfiles.isNotEmpty) {
                _toResetDbUserProfile = _toResetProfiles.first;
              }
            }
            return SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Card(
                        color: Colors.grey[100],
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: _toResetProfiles.isNotEmpty &&
                                  _toResetDbUserProfile != null
                              ? Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    DropdownButtonFormField<DbUserProfile>(
                                      decoration: const InputDecoration(
                                        border: OutlineInputBorder(),
                                        labelText: 'Accounts to be reset',
                                      ),
                                      isExpanded: true,
                                      value: _toResetDbUserProfile,
                                      icon: const Icon(Icons.arrow_drop_down),
                                      onChanged: (DbUserProfile? value) {
                                        // This is called when the user selects an item.
                                        setState(() {
                                          _toResetDbUserProfile = value!;
                                        });
                                      },
                                      items: _toResetProfiles
                                          .map<DropdownMenuItem<DbUserProfile>>(
                                              (DbUserProfile value) {
                                        return DropdownMenuItem<DbUserProfile>(
                                          value: value,
                                          child: Text(value.username.v!),
                                        );
                                      }).toList(),
                                    ),
                                    const SizedBox(
                                      height: 8,
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
                                        final password =
                                            RandomPasswordGenerator();
                                        String newPassword =
                                            password.randomPassword(
                                                letters: true,
                                                uppercase: true,
                                                numbers: true,
                                                specialChar: true);
                                        _toResetDbUserProfile!.password.v =
                                            CryptoUtils.encrypt(
                                                _toResetDbUserProfile!
                                                    .username.v!
                                                    .trim()
                                                    .toLowerCase(),
                                                newPassword);
                                        _toResetDbUserProfile!
                                            .isPasswordReset.v = false;
                                        await userProfileProvider.saveProfile(
                                            _toResetDbUserProfile!);
                                        UiUtils.showCustomAlertDialog(
                                            const Text("Success",
                                                textAlign: TextAlign.center),
                                            RichText(
                                              textAlign: TextAlign.center,
                                              text: TextSpan(
                                                // Note: Styles for TextSpans must be explicitly defined.
                                                // Child text spans will inherit styles from parent
                                                style: const TextStyle(
                                                  fontSize: 16.0,
                                                ),
                                                children: <TextSpan>[
                                                  TextSpan(
                                                      text:
                                                          _toResetDbUserProfile!
                                                              .username.v,
                                                      style: const TextStyle(
                                                          fontWeight:
                                                              FontWeight.bold)),
                                                  const TextSpan(
                                                      text:
                                                          '\n\nhas been reset with a new password\n\n'),
                                                  TextSpan(
                                                      text: newPassword,
                                                      style: const TextStyle(
                                                          fontWeight:
                                                              FontWeight.bold)),
                                                ],
                                              ),
                                              //"Account ${_toResetDbUserProfile!.username.v} has been reset with a new password.\n$newPassword"
                                            ));
                                        setState(() {});
                                      },
                                      child: const Padding(
                                        padding: EdgeInsets.all(16),
                                        child: Text('Reset',
                                            style: TextStyle(fontSize: 16)),
                                      ),
                                    ),
                                    const SizedBox(
                                      height: 8,
                                    ),
                                  ],
                                )
                              : const Text(
                                  'No accounts to reset',
                                  textAlign: TextAlign.left,
                                ),
                        )),
                    const SizedBox(
                      height: 8,
                    ),
                    Card(
                      color: Colors.grey[100],
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: _toApproveProfiles.isNotEmpty &&
                                _toApproveDbUserProfile != null
                            ? Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                    DropdownButtonFormField<DbUserProfile>(
                                      decoration: const InputDecoration(
                                        border: OutlineInputBorder(),
                                        labelText: 'Accounts to be approved',
                                      ),
                                      isExpanded: true,
                                      value: _toApproveDbUserProfile,
                                      icon: const Icon(Icons.arrow_drop_down),
                                      onChanged: (DbUserProfile? value) {
                                        // This is called when the user selects an item.
                                        setState(() {
                                          _toApproveDbUserProfile = value!;
                                        });
                                      },
                                      items: _toApproveProfiles
                                          .map<DropdownMenuItem<DbUserProfile>>(
                                              (DbUserProfile value) {
                                        return DropdownMenuItem<DbUserProfile>(
                                          value: value,
                                          child: Text(value.username.v!),
                                        );
                                      }).toList(),
                                    ),
                                    const SizedBox(
                                      height: 8,
                                    ),
                                    Row(
                                      children: [
                                        Expanded(
                                          child: ElevatedButton(
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: Colors.red,
                                              elevation: 3,
                                              minimumSize: Size(
                                                  MediaQuery.of(context)
                                                      .size
                                                      .width,
                                                  MediaQuery.of(context)
                                                          .size
                                                          .height *
                                                      0.05),
                                            ),
                                            onPressed: () async {
                                              setState(() {
                                                if (_toApproveProfiles
                                                    .isEmpty) {
                                                  UiUtils.showAlertDialog(
                                                      "Error",
                                                      "Nothing to deny!");
                                                  return;
                                                }
                                                if (_toApproveDbUserProfile !=
                                                    null) {
                                                  userProfileProvider
                                                      .deleteProfile(
                                                          _toApproveDbUserProfile
                                                              ?.id);
                                                  UiUtils.showAlertDialog(
                                                      "Success",
                                                      "Account denied!");
                                                } else {
                                                  UiUtils.showAlertDialog(
                                                      "Alert",
                                                      "Please select something!");
                                                }
                                              });
                                            },
                                            child: const Padding(
                                              padding: EdgeInsets.all(16),
                                              child: Text('Deny',
                                                  style:
                                                      TextStyle(fontSize: 16)),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(
                                          width: 8,
                                        ),
                                        Expanded(
                                          child: ElevatedButton(
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: Colors.green,
                                              elevation: 3,
                                              minimumSize: Size(
                                                  MediaQuery.of(context)
                                                      .size
                                                      .width,
                                                  MediaQuery.of(context)
                                                          .size
                                                          .height *
                                                      0.05),
                                            ),
                                            onPressed: () async {
                                              setState(() {
                                                if (_toApproveProfiles
                                                    .isEmpty) {
                                                  UiUtils.showAlertDialog(
                                                      "Error",
                                                      "Nothing to approve!");
                                                  return;
                                                }
                                                if (_toApproveDbUserProfile !=
                                                    null) {
                                                  _toApproveDbUserProfile!
                                                      .isApproved.v = true;
                                                  userProfileProvider.saveProfile(
                                                      _toApproveDbUserProfile!);
                                                  UiUtils.showAlertDialog(
                                                      "Success",
                                                      "Account approved!");
                                                } else {
                                                  UiUtils.showAlertDialog(
                                                      "Alert",
                                                      "Please select something!");
                                                }
                                              });
                                            },
                                            child: const Padding(
                                              padding: EdgeInsets.all(16),
                                              child: Text('Approve',
                                                  style:
                                                      TextStyle(fontSize: 16)),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ])
                            : const Text(
                                'No pending accounts to approve',
                                textAlign: TextAlign.left,
                              ),
                      ),
                    ),
                    const SizedBox(
                      height: 8,
                    ),
                    Card(
                      color: Colors.grey[100],
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              DropdownButtonFormField<String>(
                                decoration: const InputDecoration(
                                  border: OutlineInputBorder(),
                                  labelText: 'List of Services',
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
                                height: 8,
                              ),
                              TextField(
                                decoration: const InputDecoration(
                                    border: OutlineInputBorder(),
                                    labelText: 'Add new service'),
                                inputFormatters: [UpperCaseTextFormatter()],
                                controller: _serviceController,
                              ),
                              const SizedBox(
                                height: 8,
                              ),
                              Row(
                                children: [
                                  Expanded(
                                    child: ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.red,
                                        elevation: 3,
                                        minimumSize: Size(
                                            MediaQuery.of(context).size.width,
                                            MediaQuery.of(context).size.height *
                                                0.05),
                                      ),
                                      onPressed: () async {
                                        setState(() {
                                          if (TestData.serviceList.length ==
                                              1) {
                                            UiUtils.showAlertDialog("Error",
                                                "You cant delete everything!");
                                            return;
                                          }
                                          if (_serviceDropdownValue
                                              .isNotEmpty) {
                                            TestData.serviceList.remove(
                                                _serviceDropdownValue.trim());
                                            _serviceDropdownValue =
                                                TestData.serviceList.first;
                                            UiUtils.showAlertDialog(
                                                "Success", "Service deleted!");
                                          } else {
                                            UiUtils.showAlertDialog("Alert",
                                                "Please select something!");
                                          }
                                          _serviceController.clear();
                                        });
                                      },
                                      child: const Padding(
                                        padding: EdgeInsets.all(16),
                                        child: Text('Delete Service',
                                            style: TextStyle(fontSize: 16)),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(
                                    width: 8,
                                  ),
                                  Expanded(
                                    child: ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.green,
                                        elevation: 3,
                                        minimumSize: Size(
                                            MediaQuery.of(context).size.width,
                                            MediaQuery.of(context).size.height *
                                                0.05),
                                      ),
                                      onPressed: () async {
                                        setState(() {
                                          if (_serviceController.text
                                              .trim()
                                              .isNotEmpty) {
                                            if (Utils.isWithinList(
                                                _serviceController.text.trim(),
                                                TestData.serviceList)) {
                                              UiUtils.showAlertDialog("Alert",
                                                  "List already contains similar item!");
                                              return;
                                            }
                                            TestData.serviceList.add(
                                                _serviceController.text.trim());
                                            _serviceDropdownValue =
                                                TestData.serviceList.last;
                                            UiUtils.showAlertDialog("Success",
                                                "New service added!");
                                          } else {
                                            UiUtils.showAlertDialog("Alert",
                                                "Please fill in something!");
                                          }
                                          _serviceController.clear();
                                        });
                                      },
                                      child: const Padding(
                                        padding: EdgeInsets.all(16),
                                        child: Text('Add Service',
                                            style: TextStyle(fontSize: 16)),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ]),
                      ),
                    ),
                    const SizedBox(
                      height: 8,
                    ),
                    Card(
                      color: Colors.grey[100],
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              DropdownButtonFormField<String>(
                                decoration: const InputDecoration(
                                  border: OutlineInputBorder(),
                                  labelText: 'List of Cells',
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
                                height: 8,
                              ),
                              TextField(
                                decoration: const InputDecoration(
                                    border: OutlineInputBorder(),
                                    labelText: 'Add new cell'),
                                inputFormatters: [UpperCaseTextFormatter()],
                                controller: _cellController,
                              ),
                              const SizedBox(
                                height: 8,
                              ),
                              Row(
                                children: [
                                  Expanded(
                                    child: ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        elevation: 3,
                                        backgroundColor: Colors.red,
                                        minimumSize: Size(
                                            MediaQuery.of(context).size.width,
                                            MediaQuery.of(context).size.height *
                                                0.05),
                                      ),
                                      onPressed: () async {
                                        setState(() {
                                          if (TestData.cellList.length == 1) {
                                            UiUtils.showAlertDialog("Error",
                                                "You cant delete everything!");
                                            return;
                                          }
                                          if (_cellDropdownValue.isNotEmpty) {
                                            TestData.cellList.remove(
                                                _cellDropdownValue.trim());
                                            _cellDropdownValue =
                                                TestData.cellList.first;
                                            UiUtils.showAlertDialog(
                                                "Success", "Cell deleted!");
                                          } else {
                                            UiUtils.showAlertDialog("Alert",
                                                "Please select something!");
                                          }
                                          _cellController.clear();
                                        });
                                      },
                                      child: const Padding(
                                        padding: EdgeInsets.all(16),
                                        child: Text('Delete Cell',
                                            style: TextStyle(fontSize: 16)),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(
                                    width: 8,
                                  ),
                                  Expanded(
                                    child: ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.green,
                                        elevation: 3,
                                        minimumSize: Size(
                                            MediaQuery.of(context).size.width,
                                            MediaQuery.of(context).size.height *
                                                0.05),
                                      ),
                                      onPressed: () async {
                                        setState(() {
                                          if (_cellController.text
                                              .trim()
                                              .isNotEmpty) {
                                            if (Utils.isWithinList(
                                                _cellController.text.trim(),
                                                TestData.cellList)) {
                                              UiUtils.showAlertDialog("Alert",
                                                  "List already contains similar item!");
                                              return;
                                            }
                                            TestData.cellList.add(
                                                _cellController.text.trim());
                                            _cellDropdownValue =
                                                TestData.cellList.last;
                                            UiUtils.showAlertDialog(
                                                "Success", "New cell added!");
                                          } else {
                                            UiUtils.showAlertDialog("Alert",
                                                "Please fill in something!");
                                          }
                                          _cellController.clear();
                                        });
                                      },
                                      child: const Padding(
                                        padding: EdgeInsets.all(16),
                                        child: Text('Add Cell',
                                            style: TextStyle(fontSize: 16)),
                                      ),
                                    ),
                                  )
                                ],
                              ),
                            ]),
                      ),
                    ),
                    const SizedBox(
                      height: 8,
                    ),
                    Card(
                      color: Colors.grey[100],
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              DropdownButtonFormField<String>(
                                decoration: const InputDecoration(
                                  border: OutlineInputBorder(),
                                  labelText: 'List of Rooms',
                                ),
                                value: _roomDropdownValue,
                                isExpanded: true,
                                icon: const Icon(Icons.arrow_drop_down),
                                onChanged: (String? value) {
                                  // This is called when the user selects an item.
                                  setState(() {
                                    _reasonDropdownValue = value!;
                                  });
                                },
                                items: TestData.roomList
                                    .map<DropdownMenuItem<String>>(
                                        (String value) {
                                  return DropdownMenuItem<String>(
                                    value: value,
                                    child: Text(value),
                                  );
                                }).toList(),
                              ),
                              const SizedBox(
                                height: 8,
                              ),
                              TextField(
                                decoration: const InputDecoration(
                                    border: OutlineInputBorder(),
                                    labelText: 'Add new room'),
                                inputFormatters: [UpperCaseTextFormatter()],
                                controller: _roomController,
                              ),
                              const SizedBox(
                                height: 8,
                              ),
                              Row(
                                children: [
                                  Expanded(
                                    child: ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        elevation: 3,
                                        backgroundColor: Colors.red,
                                        minimumSize: Size(
                                            MediaQuery.of(context).size.width,
                                            MediaQuery.of(context).size.height *
                                                0.05),
                                      ),
                                      onPressed: () async {
                                        setState(() {
                                          if (TestData.roomList.length == 1) {
                                            UiUtils.showAlertDialog("Error",
                                                "You cant delete everything!");
                                            return;
                                          }
                                          if (_roomDropdownValue.isNotEmpty) {
                                            TestData.roomList.remove(
                                                _roomDropdownValue.trim());
                                            _roomDropdownValue =
                                                TestData.roomList.first;
                                            UiUtils.showAlertDialog(
                                                "Success", "Room deleted!");
                                          } else {
                                            UiUtils.showAlertDialog("Alert",
                                                "Please select something!");
                                          }
                                          _roomController.clear();
                                        });
                                      },
                                      child: const Padding(
                                        padding: EdgeInsets.all(16),
                                        child: Text('Delete Room',
                                            style: TextStyle(fontSize: 16)),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(
                                    width: 8,
                                  ),
                                  Expanded(
                                    child: ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        elevation: 3,
                                        backgroundColor: Colors.green,
                                        minimumSize: Size(
                                            MediaQuery.of(context).size.width,
                                            MediaQuery.of(context).size.height *
                                                0.05),
                                      ),
                                      onPressed: () async {
                                        setState(() {
                                          if (_roomController.text
                                              .trim()
                                              .isNotEmpty) {
                                            if (Utils.isWithinList(
                                                _roomController.text.trim(),
                                                TestData.roomList)) {
                                              UiUtils.showAlertDialog("Alert",
                                                  "List already contains similar item!");
                                              return;
                                            }
                                            TestData.roomList.add(
                                                _roomController.text.trim());
                                            _roomDropdownValue =
                                                TestData.roomList.last;
                                            UiUtils.showAlertDialog(
                                                "Success", "New room added!");
                                          } else {
                                            UiUtils.showAlertDialog("Alert",
                                                "Please fill in something!");
                                          }
                                          _roomController.clear();
                                        });
                                      },
                                      child: const Padding(
                                        padding: EdgeInsets.all(16),
                                        child: Text('Add Room',
                                            style: TextStyle(fontSize: 16)),
                                      ),
                                    ),
                                  )
                                ],
                              ),
                            ]),
                      ),
                    ),
                    const SizedBox(
                      height: 8,
                    ),
                    Card(
                      color: Colors.grey[100],
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              DropdownButtonFormField<String>(
                                decoration: const InputDecoration(
                                  border: OutlineInputBorder(),
                                  labelText: 'List of Reasons',
                                ),
                                value: _reasonDropdownValue,
                                isExpanded: true,
                                icon: const Icon(Icons.arrow_drop_down),
                                onChanged: (String? value) {
                                  // This is called when the user selects an item.
                                  // This is called when the user selects an item.
                                  setState(() {
                                    _reasonDropdownValue = value!;
                                  });
                                },
                                items: TestData.reasonList
                                    .map<DropdownMenuItem<String>>(
                                        (String value) {
                                  return DropdownMenuItem<String>(
                                    value: value,
                                    child: Text(value),
                                  );
                                }).toList(),
                              ),
                              const SizedBox(
                                height: 8,
                              ),
                              TextField(
                                decoration: const InputDecoration(
                                    border: OutlineInputBorder(),
                                    labelText: 'Add new reason'),
                                inputFormatters: [UpperCaseTextFormatter()],
                                controller: _reasonController,
                              ),
                              const SizedBox(
                                height: 8,
                              ),
                              Row(
                                children: [
                                  Expanded(
                                    child: ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        elevation: 3,
                                        backgroundColor: Colors.red,
                                        minimumSize: Size(
                                            MediaQuery.of(context).size.width,
                                            MediaQuery.of(context).size.height *
                                                0.05),
                                      ),
                                      onPressed: () async {
                                        setState(() {
                                          if (TestData.reasonList.length == 1) {
                                            UiUtils.showAlertDialog("Error",
                                                "You cant delete everything!");
                                            return;
                                          }
                                          if (_reasonDropdownValue.isNotEmpty) {
                                            TestData.reasonList.remove(
                                                _reasonDropdownValue.trim());
                                            _reasonDropdownValue =
                                                TestData.reasonList.first;
                                            UiUtils.showAlertDialog(
                                                "Success", "Reason deleted!");
                                          } else {
                                            UiUtils.showAlertDialog("Alert",
                                                "Please select something!");
                                          }
                                          _roomController.clear();
                                        });
                                      },
                                      child: const Padding(
                                        padding: EdgeInsets.all(16),
                                        child: Text('Delete Reason',
                                            style: TextStyle(fontSize: 16)),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(
                                    width: 8,
                                  ),
                                  Expanded(
                                    child: ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        elevation: 3,
                                        backgroundColor: Colors.green,
                                        minimumSize: Size(
                                            MediaQuery.of(context).size.width,
                                            MediaQuery.of(context).size.height *
                                                0.05),
                                      ),
                                      onPressed: () async {
                                        setState(() {
                                          if (_reasonController.text
                                              .trim()
                                              .isNotEmpty) {
                                            if (Utils.isWithinList(
                                                _reasonController.text.trim(),
                                                TestData.reasonList)) {
                                              UiUtils.showAlertDialog("Alert",
                                                  "List already contains similar item!");
                                              return;
                                            }
                                            TestData.reasonList.add(
                                                _reasonController.text.trim());
                                            _reasonDropdownValue =
                                                TestData.reasonList.last;
                                            UiUtils.showAlertDialog(
                                                "Success", "New reason added!");
                                          } else {
                                            UiUtils.showAlertDialog("Alert",
                                                "Please fill in something!");
                                          }
                                          _reasonController.clear();
                                        });
                                      },
                                      child: const Padding(
                                        padding: EdgeInsets.all(16),
                                        child: Text('Add Reason',
                                            style: TextStyle(fontSize: 16)),
                                      ),
                                    ),
                                  )
                                ],
                              ),
                            ]),
                      ),
                    ),
                    const SizedBox(
                      height: 8,
                    ),
                    Card(
                        color: Colors.grey[100],
                        child: SizedBox(
                          width: MediaQuery.of(context).size.width,
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              children: [
                                const Text(
                                    "Generate Google Authenticator Registration QR Code",
                                    style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold)),
                                const SizedBox(
                                  height: 8,
                                ),
                                TextFormField(
                                  // The validator receives the text that the user has entered.
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Please enter username to generate QR Code for user';
                                    } else {
                                      return null;
                                    }
                                  },
                                  decoration: const InputDecoration(
                                      border: OutlineInputBorder(),
                                      labelText: 'Username'),
                                  inputFormatters: [LowerCaseTextFormatter()],
                                  controller: _usernameController,
                                ),
                                const SizedBox(
                                  height: 8,
                                ),
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    elevation: 3,
                                    minimumSize: Size(
                                        MediaQuery.of(context).size.width,
                                        MediaQuery.of(context).size.height *
                                            0.05),
                                  ),
                                  onPressed: () {
                                    setState(() {});
                                  },
                                  child: const Padding(
                                    padding: EdgeInsets.all(16),
                                    child: Text('Generate',
                                        style: TextStyle(fontSize: 16)),
                                  ),
                                ),
                                const SizedBox(
                                  height: 8,
                                ),
                                Column(
                                  children: [
                                    QrImageView(
                                      data: OtpUtils.generateQrData(
                                          Constants.company,
                                          _usernameController.text),
                                      version: QrVersions.auto,
                                      size: 200.0,
                                    ),
                                    const Text(
                                        "Scan QR using Google Authenticator"),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        )),
                    const SizedBox(
                      height: 32,
                    ),
                  ],
                ),
              ),
            );
          }),
    );
  }
}
