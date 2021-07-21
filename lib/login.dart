import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:random_thoughts/signup.dart';

class Login extends StatefulWidget {
  final FirebaseAuth auth;
  final Function onLoginCallback;
  Login(this.auth, this.onLoginCallback);
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  GlobalKey<FormState> _loginForm;
  void initState() {
    _loginForm = GlobalKey<FormState>();
  }

  Widget build(BuildContext context) => Card(
          child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
              width: 300,
              height: 200,
              child: Center(
                  child:
                      Image.asset('assets/images/random_thoughts_logo.jpg'))),
          Divider(),
          Container(
              width: 250,
              child: Form(
                  key: _loginForm,
                  child: Column(
                    children: [
                      TextFormField(
                        keyboardType: TextInputType.emailAddress,
                        decoration: InputDecoration(
                          hintText: 'Email',
                        ),
                        validator: (value) => (value.isEmpty)
                            ? "Please provide your email!"
                            : null,
                      ),
                      TextFormField(
                        obscureText: true,
                        decoration: InputDecoration(hintText: 'Password'),
                        validator: (value) => (value.isEmpty)
                            ? "Please provide your password"
                            : (value.length < 6)
                                ? "Your password is 6 digits or more!"
                                : null,
                      )
                    ],
                  ))),
          Divider(),
          ElevatedButton(
              onPressed: () {
                if (_loginForm.currentState.validate()) {
                  // auth.signIn
                  // call callback
                }
              },
              child: Text('Log in')),
          ElevatedButton(
              onPressed: () {
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => Signup(widget.auth, () {})));
              },
              child: Text('I don\'t have an account'))
        ],
      ));
}
