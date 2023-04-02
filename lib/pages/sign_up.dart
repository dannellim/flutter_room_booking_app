import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:room_booking_app/test_data.dart';
import 'package:room_booking_app/utilities/utils.dart';
import 'package:room_booking_app/utilities/text_formatters.dart';

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
  // Create a global key that uniquely identifies the Form widget
  // and allows validation of the form.
  //
  // Note: This is a `GlobalKey<FormState>`,
  // not a GlobalKey<MyCustomFormState>.
  final _formKey = GlobalKey<FormState>();
  late bool _emailVaild;
  late bool _numVaild;
  late bool _passwordVisible;
  final passwordController = TextEditingController();
  final emailController = TextEditingController();
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

  final numController = TextEditingController();
  String? get _numErrorText {
    // // at any time, we can get the text from _controller.value.text
    final text = numController.value.text;
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

  @override
  void dispose() {
    emailController.dispose();
    numController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _passwordVisible = false;
    _emailVaild = false;
    _numVaild = false;
  }

  static const List<String> serviceList = TestData.serviceList;
  String serviceDropdownValue = serviceList.first;

  static const List<String> cellList = TestData.cellList;
  String cellDropdownValue = cellList.first;

  bool _is8Character = false;
  bool _is1Upper = false;
  bool _is1Lower = false;
  bool _is1Digit = false;
  bool _is1Special = false;

  String? get _pwdErrorText {
    // // at any time, we can get the text from _controller.value.text
    final text = passwordController.value.text;
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
                  controller: emailController,
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
                    controller: numController,
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
                  value: serviceDropdownValue,
                  icon: const Icon(Icons.arrow_drop_down),
                  onChanged: (String? value) {
                    // This is called when the user selects an item.
                    setState(() {
                      serviceDropdownValue = value!;
                    });
                  },
                  items:
                      serviceList.map<DropdownMenuItem<String>>((String value) {
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
                  value: cellDropdownValue,
                  icon: const Icon(Icons.arrow_drop_down),
                  onChanged: (String? value) {
                    // This is called when the user selects an item.
                    setState(() {
                      cellDropdownValue = value!;
                    });
                  },
                  items: cellList.map<DropdownMenuItem<String>>((String value) {
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
                  controller: emailController,
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
                  controller: passwordController,
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
                    onPressed: () {
                      // Validate returns true if the form is valid, or false otherwise.
                      if (_formKey.currentState!.validate()) {
                        Navigator.of(context)
                            .popUntil((route) => route.isFirst);
                        // If the form is valid, display a snackbar. In the real world,
                        // you'd often call a server or save the information in a database.
                        //_scaffoldBar('Logging in...');
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
}
