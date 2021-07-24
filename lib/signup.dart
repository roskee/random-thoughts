import 'package:cloud_firestore/cloud_firestore.dart';
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
  TextEditingController _usernameController;
  TextEditingController _firstNameController;
  TextEditingController _lastNameController;
  TextEditingController _emailController;
  TextEditingController _passwordFieldController;
  bool signupError;
  Widget signupErrorMessage;
  Widget usernameChecked;
  void initState() {
    super.initState();
    _formFieldKey = GlobalKey<FormState>();
    _passwordFieldController = TextEditingController();
    _usernameController = TextEditingController();
    _firstNameController = TextEditingController();
    _lastNameController = TextEditingController();
    _emailController = TextEditingController();
    signupError = false;
    usernameChecked = Text('');
    signupErrorMessage = Text('');
  }

  Widget build(BuildContext context) {
    return Material(
      child: ListView(
       // mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Card(
                elevation: 10,
                shadowColor: Color(0x690FFFF0),
                child: Image.asset('assets/images/random_thoughts_logo3.png'),
              ),
          Card(
            elevation: 10,
            shadowColor: Color(0x690FFFF0),
            child:SizedBox(
              height: 50,
              child:Center(child:Text(
            'Create New Account',
            style: TextStyle(fontSize: 24),)
          ))),
          Card(
            elevation: 10,
            shadowColor: Color(0x690FFFF0),
              child: Form(
                  key: _formFieldKey,
                  child: Column(children: [
                    Stack(alignment: Alignment.centerRight, children: [
                      SizedBox(
                        width: 250,
                        child:TextFormField(
                          maxLength: 10,
                          onChanged: (value) {
                            if (value.isEmpty) {
                              setState(() {
                                usernameChecked = Text('');
                              });
                              return;
                            }
                            checkUsername(value).then((check) {
                              if (check) {
                                setState(() {
                                  usernameChecked = Text(
                                    '$value is available',
                                    style: TextStyle(color: Colors.green),
                                  );
                                });
                              } else
                                setState(() {
                                  usernameChecked = Text(
                                    '$value is taken',
                                    style: TextStyle(color: Colors.red),
                                  );
                                });
                            });
                          },
                          controller: _usernameController,
                          decoration: InputDecoration(hintText: 'Username'),
                          validator: (value) => (value.isEmpty)
                              ? "This field is required"
                              : (value.contains(' '))
                                  ? "No spaces are allowed"
                                  : null)),
                        usernameChecked
                    ]),
                    SizedBox(
                      width:250,
                      child:TextFormField(
                      controller: _firstNameController,
                      decoration: InputDecoration(hintText: 'First name'),
                      validator: (value) => (value.isEmpty)
                          ? "This field is required"
                          : (value.contains(' '))
                              ? "No Spaces are allowed"
                              : null,
                    )),
                    SizedBox(
                      width:250,
                      child:TextFormField(
                      controller: _lastNameController,
                      decoration: InputDecoration(hintText: 'Last name'),
                      validator: (value) => (value.isEmpty)
                          ? "This field is required"
                          : (value.contains(' '))
                              ? "No Spaces are allowed"
                              : null,
                    )),
                    SizedBox(
                      width:250,
                      child:TextFormField(
                      controller: _emailController,
                      decoration: InputDecoration(hintText: 'Email'),
                      validator: (value) =>
                          (value.isEmpty) ? "This field is required" : null,
                    )),
                    SizedBox(
                      width: 250,
                      child:TextFormField(
                      controller: _passwordFieldController,
                      keyboardType: TextInputType.visiblePassword,
                      obscureText: true,
                      decoration: InputDecoration(hintText: 'Password'),
                      validator: (value) => (value.isEmpty)
                          ? "This field is required"
                          : (value.length < 6)
                              ? "Your password must be 6 digits or more!"
                              : null,
                    )),
                    SizedBox(
                      width:250,
                      child:TextFormField(
                      keyboardType: TextInputType.visiblePassword,
                      obscureText: true,
                      decoration: InputDecoration(hintText: 'Confirm password'),
                      validator: (value) =>
                          (value != _passwordFieldController.value.text)
                              ? "Password doesn\'t match!"
                              : null,
                    )),
                    Divider(),
                     //Visibility(visible: signupError, child: 
                     signupError?signupErrorMessage:Text(''),
          ElevatedButton(
              onPressed: () {
                if (signupErrorMessage is LinearProgressIndicator) return;
                if (_formFieldKey.currentState.validate()) {
                  setState(() {
                    signupError = true;
                    signupErrorMessage = LinearProgressIndicator();
                  });
                  checkUsername(_usernameController.value.text).then((value) {
                    if (value)
                      signup();
                    else
                      setState(() {
                        signupError = true;
                        signupErrorMessage = Text(
                          'This username is taken!',
                          style: TextStyle(color: Colors.red),
                        );
                      });
                  });
                }
              },
              child: Text('Register'))
                  ]))),
         
         
        ],
      ),
    );
  }

  Future<bool> checkUsername(String username) async {
    var x = await FirebaseFirestore.instance.collection('Users').get();
    for (int i = 0; i < x.docs.length; i++) {
      if (x.docs[i].data()['username'] == username) return false;
    }
    return true;
  }

  Future<void> signup() async {
    try {
      await widget.auth
          .createUserWithEmailAndPassword(
              email: _emailController.value.text,
              password: _passwordFieldController.value.text)
          .then((value) {
        value.user.updateDisplayName('${_usernameController.value.text}');
        FirebaseFirestore.instance.runTransaction((transaction) async {
          transaction
              .set(FirebaseFirestore.instance.collection('Users').doc(_usernameController.value.text), {
            'username': _usernameController.value.text,
            'firstname': _firstNameController.value.text,
            'lastname': _lastNameController.value.text,
            'postcount': 0,
            'likecount': 0
          });
        });
      });
      Navigator.pop(context);
      widget.onSignupCallback();
    } catch (e) {
      String error;
      switch (e.code) {
        case 'email-already-in-use':
          error = "This email is already registered";
          break;
        case 'invalid-email':
          error = "You have entered an invalid email";
          break;
        case 'operation-not-allowed':
          error = "This operation is not allowed";
          break;
        case 'weak-password':
          error =
              "Your password is very weak! try adding capitals,symbols and letters";
          break;
        default:
          error = 'Unknown error has occured';
      }
      setState(() {
        signupError = true;
        signupErrorMessage = Text(
          error,
          style: TextStyle(color: Colors.red),
        );
      });
    }
  }
}
