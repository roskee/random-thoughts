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
  TextEditingController emailController;
  TextEditingController passwordController;
  bool loginError;
  bool onSignupComplete;
  Widget loginErrorMessage;
  void initState() {
    super.initState();
    _loginForm = GlobalKey<FormState>();
    emailController = TextEditingController();
    passwordController = TextEditingController();
    loginError = false;
    onSignupComplete = false;
    loginErrorMessage = Text('');
  }

  Widget build(BuildContext context) => (onSignupComplete)
      ? Card(
          elevation: 10,
          shadowColor: Color(0x690FFFF0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('You are succussfully registered!'),
              TextButton(
                  onPressed: () {
                    widget.onLoginCallback();
                  },
                  child: Text('Continue'))
            ],
          ))
      : Card(
          elevation: 10,
          shadowColor: Color(0x690FFFF0),
          child: ListView(
            //mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Card(
                elevation: 10,
                shadowColor: Color(0x690FFFF0),
                child: Image.asset('assets/images/random_thoughts_logo3.png'),
              ),
              Card(
                  elevation: 10,
                  shadowColor: Color(0x690FFFF0),
                  child: Form(
                      key: _loginForm,
                      child: Column(
                        children: [
                          SizedBox(
                              width: 250,
                              child: TextFormField(
                                controller: emailController,
                                keyboardType: TextInputType.emailAddress,
                                decoration: InputDecoration(
                                  hintText: 'Email',
                                ),
                                validator: (value) => (value.isEmpty)
                                    ? "Please provide your email!"
                                    : null,
                              )),
                          SizedBox(
                              width: 250,
                              child: TextFormField(
                                controller: passwordController,
                                obscureText: true,
                                decoration:
                                    InputDecoration(hintText: 'Password'),
                                validator: (value) => (value.isEmpty)
                                    ? "Please provide your password"
                                    : (value.length < 6)
                                        ? "Your password is 6 digits or more!"
                                        : null,
                              )),
                          Divider(),
                          Visibility(
                              visible: loginError, child: loginErrorMessage),
                          ElevatedButton(
                              onPressed: () async {
                                if (_loginForm.currentState.validate()) {
                                  if (loginErrorMessage
                                      is LinearProgressIndicator) return;
                                  try {
                                    setState(() {
                                      loginErrorMessage =
                                          LinearProgressIndicator();
                                      loginError = true;
                                    });
                                    await widget.auth
                                        .signInWithEmailAndPassword(
                                            email: emailController.value.text,
                                            password:
                                                passwordController.value.text);
                                    widget.onLoginCallback();
                                  } catch (e) {
                                    String errorMessage;
                                    switch (e.code) {
                                      case 'user-not-found':
                                        errorMessage =
                                            'There is no account with this email';
                                        break;
                                      case 'invalid-email':
                                        errorMessage =
                                            'You have entered an invalid email';
                                        break;
                                      case 'user-disabled':
                                        errorMessage =
                                            'The account you tried to login to is currently disabled. contact administrators';
                                        break;
                                      case 'wrong-password':
                                        errorMessage =
                                            "The password is incorrect";
                                        break;
                                      default:
                                        errorMessage =
                                            'Unknown Error has occured';
                                    }
                                    setState(() {
                                      loginError = true;
                                      loginErrorMessage = Text(
                                        errorMessage,
                                        style: TextStyle(color: Colors.red),
                                      );
                                    });
                                  }
                                  // auth.signIn
                                  // call callback
                                }
                              },
                              child: Text('Log in')),
                          ElevatedButton(
                              onPressed: () {
                                Navigator.of(context).push(MaterialPageRoute(
                                    builder: (context) =>
                                        Signup(widget.auth, () {
                                          widget.onLoginCallback();
                                        })));
                              },
                              child: Text('I don\'t have an account'))
                        ],
                      ))),
            ],
          ));
}
