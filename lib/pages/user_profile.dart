import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:room_booking_app/app.dart';
import 'package:room_booking_app/models/user_profile.dart';
import 'package:room_booking_app/utilities/ui_utils.dart';

class ProfilePage extends StatefulWidget {
  final int profileId;
  const ProfilePage({super.key, required this.profileId});
  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final _numController = TextEditingController();
  late DbUserProfile _profile;
  late bool _numVaild;
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

  @override
  void initState() {
    super.initState();
    _numVaild = false;
  }

  @override
  void dispose() {
    _numController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DbUserProfile?>(
        stream: userProfileProvider.onProfile(widget.profileId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const CircularProgressIndicator();
          } else if (snapshot.connectionState == ConnectionState.active ||
              snapshot.connectionState == ConnectionState.done) {
            if (snapshot.hasError) {
              return const Text('Error');
            } else if (snapshot.hasData) {
              if (snapshot.hasData) {
                _profile = snapshot.data!;
                _numController.text = _profile.handphoneNumber.v!;
                _numController.selection = _numController.selection.copyWith(
                    baseOffset: _profile.handphoneNumber.v!.length,
                    extentOffset: _profile.handphoneNumber.v!.length);
              }
              return Scaffold(
                appBar: AppBar(
                  title: const Text("User Profile"),
                ),
                body: Form(
                    key: _formKey,
                    child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
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
                                          _numVaild ? Icons.check_circle : null,
                                          color: Colors.green,
                                        ))),
                                inputFormatters: <TextInputFormatter>[
                                  FilteringTextInputFormatter.digitsOnly,
                                  LengthLimitingTextInputFormatter(8)
                                ],
                                keyboardType: TextInputType.number),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                elevation: 3,
                                minimumSize: Size(
                                    MediaQuery.of(context).size.width,
                                    MediaQuery.of(context).size.height * 0.05),
                              ),
                              onPressed: () async {
                                // Validate returns true if the form is valid, or false otherwise.
                                if (_formKey.currentState!.validate()) {
                                  UiUtils.showAlertDialog("Success",
                                      "Your profile has been updated!");
                                }
                              },
                              child: const Padding(
                                padding: EdgeInsets.all(16),
                                child: Text('Update',
                                    style: TextStyle(fontSize: 16)),
                              ),
                            )
                          ],
                        ))),
              );
            } else {
              return const Text('Empty data');
            }
          } else {
            return Text('State: ${snapshot.connectionState}');
          }
        });
  }
}
