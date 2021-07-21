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
  Widget loginErrorMessage;
  void initState() {
    super.initState();
    _loginForm = GlobalKey<FormState>();
    emailController = TextEditingController();
    passwordController = TextEditingController();
    loginError = false;
    loginErrorMessage = Text('');
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
                        controller: emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: InputDecoration(
                          hintText: 'Email',
                        ),
                        validator: (value) => (value.isEmpty)
                            ? "Please provide your email!"
                            : null,
                      ),
                      TextFormField(
                        controller: passwordController,
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
          Visibility(visible: loginError, child: loginErrorMessage),
          ElevatedButton(
              onPressed: () async {
                if (_loginForm.currentState.validate()) {
                  try {
                    setState(() {
                      loginErrorMessage = LinearProgressIndicator();
                    });
                    await widget.auth.signInWithEmailAndPassword(
                        email: emailController.value.text,
                        password: passwordController.value.text);
                  } catch (e) {
                    String errorMessage;
                    switch (e.code) {
                      case 'user-not-found':
                        errorMessage = 'There is no account with this email';
                        break;
                      case 'invalid-email':
                        errorMessage = 'You have entered an invalid email';
                        break;
                      case 'user-disabled':
                        errorMessage =
                            'The account you tried to login to is currently disabled. contact administrators';
                        break;
                      case 'wrong-password':
                        errorMessage = "The password is incorrect";
                        break;
                      default:
                        errorMessage = 'Unknown Error has occured';
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
                    builder: (context) => Signup(widget.auth, () {})));
              },
              child: Text('I don\'t have an account'))
        ],
      ));
}