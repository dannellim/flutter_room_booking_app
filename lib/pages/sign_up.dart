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

  @override
  void dispose() {
    emailController.dispose();
    numController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _emailVaild = false;
    _numVaild = false;
  }

  static const List<String> serviceList = TestData.serviceList;
  String serviceDropdownValue = serviceList.first;

  static const List<String> cellList = TestData.cellList;
  String cellDropdownValue = cellList.first;

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
                margin: const EdgeInsets.only(
                    top: 64, left: 32, right: 32, bottom: 0),
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
                    top: 16, left: 32, right: 32, bottom: 0),
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
                    top: 16, left: 32, right: 32, bottom: 0),
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
                      labelText: 'Email',
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
                        labelText: 'Contact Number',
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
                    top: 16, left: 32, right: 32, bottom: 0),
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
                    top: 16, left: 32, right: 32, bottom: 0),
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
              Center(
                child: Padding(
                  padding: const EdgeInsets.only(
                      top: 32, left: 32, right: 32, bottom: 16),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      elevation: 3,
                      minimumSize: Size(MediaQuery.of(context).size.width * 0.5,
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
