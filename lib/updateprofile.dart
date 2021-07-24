import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:random_thoughts/user.dart';

import 'database.dart';

class UpdateProfile extends StatefulWidget {
  final Database _database;
  final UserInstance _user;
  final Function callback;
  UpdateProfile(this._database, this._user, this.callback);
  _UpdateProfileState createState() => _UpdateProfileState();
}

class _UpdateProfileState extends State<UpdateProfile> {
  TextEditingController firstNameController = TextEditingController();
  TextEditingController lastNameController = TextEditingController();
  TextEditingController oldPasswordController = TextEditingController();
  TextEditingController newPasswordController = TextEditingController();
  TextEditingController confirmPasswordController = TextEditingController();
  GlobalKey<FormState> nameForm = GlobalKey<FormState>();
  GlobalKey<FormState> passwordForm = GlobalKey<FormState>();
  bool updateProfileLoading = false;
  Text updateProfileError = Text('');
  bool updatePasswordLoading = false;
  Text updatePasswordError = Text('');
  Widget build(BuildContext context) => Material(
          child: Card(
        elevation: 10,
        shadowColor: Color(0x690FFFF0),
        child: ListView(
          children: [
            Card(
                elevation: 10,
                shadowColor: Color(0x690FFFF0),
                child: Image.asset(
                  'assets/images/random_thoughts_logo3.png',
                  fit: BoxFit.fitWidth,
                )),
            Card(
                elevation: 10,
                shadowColor: Color(0x690FFFF0),
                child: Form(
                    key: nameForm,
                    child: Column(children: [
                      SizedBox(
                          width: 250,
                          child: TextFormField(
                            validator: (value) => value.isEmpty
                                ? 'Your first name is required'
                                : null,
                            maxLines: 1,
                            inputFormatters: [
                              FilteringTextInputFormatter.deny(' ')
                            ],
                            controller: firstNameController,
                            decoration: InputDecoration(hintText: 'First name'),
                          )),
                      SizedBox(
                        width: 250,
                        child: TextFormField(
                          inputFormatters: [
                            FilteringTextInputFormatter.deny(' ')
                          ],
                          validator: (value) => value.isEmpty
                              ? 'Your last name is required'
                              : null,
                          controller: lastNameController,
                          maxLines: 1,
                          decoration: InputDecoration(hintText: 'Last name'),
                        ),
                      ),
                      updateProfileLoading
                          ? LinearProgressIndicator()
                          : updateProfileError,
                      ElevatedButton(
                          onPressed: () {
                            if (nameForm.currentState.validate()) {
                              print('updating');
                              setState(() {
                                updateProfileLoading = true;
                              });
                              widget._database
                                  .updateProfile(
                                      firstNameController.value.text,
                                      lastNameController.value.text,
                                      widget._user.username)
                                  .then((value) {
                                if (value)
                                  setState(() {
                                    updateProfileLoading = false;
                                    updateProfileError = Text(
                                      'Your profile is updated',
                                      style: TextStyle(color: Colors.green),
                                    );
                                  });
                                else
                                  setState(() {
                                    updateProfileLoading = false;
                                    updateProfileError = Text(
                                        'There was a problem while updating your profile',
                                        style: TextStyle(color: Colors.red));
                                  });
                                widget._database
                                    .getCurrentUser(widget._user.username)
                                    .then((value) {
                                  widget.callback(value);
                                });
                              });
                            }
                          },
                          child: Text('Update profile'))
                    ]))),
            Card(
                elevation: 10,
                shadowColor: Color(0x690FFFF0),
                child: Form(
                    key: passwordForm,
                    child: Column(children: [
                      SizedBox(
                        width: 250,
                        child: TextFormField(
                          obscureText: true,
                          controller: oldPasswordController,
                          validator: (value) => value.isEmpty
                              ? 'Your old password is required!'
                              : null,
                          maxLines: 1,
                          decoration: InputDecoration(hintText: 'Old password'),
                        ),
                      ),
                      SizedBox(
                        width: 250,
                        child: TextFormField(
                          obscureText: true,
                          controller: newPasswordController,
                          validator: (value) => value.isEmpty
                              ? 'Please enter your new password'
                              : value.length < 6
                                  ? 'Your password must at least be 6 digits long'
                                  : null,
                          maxLines: 1,
                          decoration: InputDecoration(hintText: 'New password'),
                        ),
                      ),
                      SizedBox(
                        width: 250,
                        child: TextFormField(
                          obscureText: true,
                          controller: confirmPasswordController,
                          validator: (value) => (value.isEmpty)
                              ? 'Please reenter your new password'
                              : (value != newPasswordController.value.text)
                                  ? 'Your password don\'t match'
                                  : null,
                          maxLines: 1,
                          decoration:
                              InputDecoration(hintText: 'Confirm password'),
                        ),
                      ),
                      updatePasswordLoading
                          ? LinearProgressIndicator()
                          : updatePasswordError,
                      ElevatedButton(
                          onPressed: () {
                            if (passwordForm.currentState.validate()) {
                              setState(() {
                                updatePasswordLoading = true;
                              });
                              widget._database
                                  .updatePassword(
                                      newPasswordController.value.text,
                                      oldPasswordController.value.text)
                                  .then((value) {
                                if (value == null) {
                                  setState(() {
                                    updatePasswordLoading = false;
                                    updatePasswordError = Text(
                                      'Your password is updated successfully!',
                                      style: TextStyle(color: Colors.green),
                                    );
                                  });
                                } else
                                  setState(() {
                                    updatePasswordLoading = false;
                                    updatePasswordError = Text(
                                      value,
                                      style: TextStyle(color: Colors.red),
                                    );
                                  });
                              });
                            }
                          },
                          child: Text('Update Password'))
                    ])))
          ],
        ),
      ));
}
