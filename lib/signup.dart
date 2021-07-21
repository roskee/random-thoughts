import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class Signup extends StatefulWidget {
  final FirebaseAuth auth;
  final Function onSignupCallback;
  Signup(this.auth, this.onSignupCallback);
  _SignupState createState() => _SignupState();
}

class _SignupState extends State<Signup> {
  GlobalKey<FormState> _formFieldKey;
  TextEditingController _passwordFieldController;
  void initState() {
    super.initState();
    _formFieldKey = GlobalKey<FormState>();
    _passwordFieldController = TextEditingController();
  }

  Widget build(BuildContext context) {
    return Material(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Register for Random Thoughts',
            style: TextStyle(fontSize: 24),
          ),
          Divider(),
          Container(
              width: 250,
              child: Form(
                  key: _formFieldKey,
                  child: Column(children: [
                    TextFormField(
                      decoration: InputDecoration(hintText: 'First name'),
                      validator: (value) => (value.isEmpty)
                          ? "This field is requied"
                          : (value.contains(' '))
                              ? "No Spaces are allowed"
                              : null,
                    ),
                    TextFormField(
                      decoration: InputDecoration(hintText: 'Last name'),
                      validator: (value) => (value.isEmpty)
                          ? "This field is required"
                          : (value.contains(' '))
                              ? "No Spaces are allowed"
                              : null,
                    ),
                    TextFormField(
                      decoration: InputDecoration(hintText: 'Email'),
                      validator: (value) =>
                          (value.isEmpty) ? "This field is required" : null,
                    ),
                    TextFormField(
                      controller: _passwordFieldController,
                      keyboardType: TextInputType.visiblePassword,
                      obscureText: true,
                      decoration: InputDecoration(hintText: 'Password'),
                      validator: (value) => (value.isEmpty)
                          ? "This field is required"
                          : (value.length < 6)
                              ? "Your password must be 6 digits or more!"
                              : null,
                    ),
                    TextFormField(
                      keyboardType: TextInputType.visiblePassword,
                      obscureText: true,
                      decoration: InputDecoration(hintText: 'Confirm password'),
                      validator: (value) =>
                          (value != _passwordFieldController.value.text)
                              ? "Password doesn\'t match!"
                              : null,
                    ),
                  ]))),
          Divider(),
          ElevatedButton(
              onPressed: () {
                if (_formFieldKey.currentState.validate()) {
                  // auth.signup
                  // call callback
                  // pop screen
                }
              },
              child: Text('Register'))
        ],
      ),
    );
  }
}
