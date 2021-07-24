import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:random_thoughts/database.dart';
import 'package:random_thoughts/user.dart';

class Profile extends StatefulWidget {
  final UserInstance _user;
  final Database _database;
  Profile(this._user, this._database);
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  Map<String, dynamic> user;
  TextEditingController firstNameController = TextEditingController();
  TextEditingController lastNameController = TextEditingController();
  TextEditingController oldPasswordController = TextEditingController();
  TextEditingController newPasswordController = TextEditingController();
  TextEditingController confirmPasswordController = TextEditingController();
  GlobalKey<FormState> nameForm=GlobalKey<FormState>();
  GlobalKey<FormState> passwordForm=GlobalKey<FormState>();
  
  void initState() {
    super.initState();
    widget._database
        .getCurrentUser(widget._user.username)
        .then((value) => setState(() {
              user = value;
            }));
  }

  Widget build(BuildContext context) => Material(
        child: Card(
            elevation: 10,
            shadowColor: Color(0x690FFFF0),
            child: ListView(
              children: [
                Image.asset(
                  'assets/images/random_thoughts_logo3.png',
                  fit: BoxFit.fitWidth,
                ), // user image instead
                Divider(),
                Card(
                    shadowColor: Color(0x690FFFF0),
                    elevation: 10,
                    child: Column(children: [
                      (user == null)
                          ? Text(
                              widget._user.username,
                              style: TextStyle(fontSize: 20),
                            )
                          : Text(
                              '${widget._user.username} (${user['firstname']} ${user['lastname']})',
                              style: TextStyle(fontSize: 20),
                            ),
                      ListTile(
                        title: Text('Total likes '),
                        trailing: (user == null)
                            ? SizedBox(
                                width: 30, child: LinearProgressIndicator())
                            : Text('${user['likecount']}'),
                      ),
                      ListTile(
                        title: Text('Total Posts'),
                        trailing: (user == null)
                            ? SizedBox(
                                width: 30, child: LinearProgressIndicator())
                            : Text('${user['postcount']}'),
                      ),
                      ListTile(
                        title: Text('Popularity'),
                        subtitle: LinearProgressIndicator(
                          value: 0.2,
                        ),
                        trailing: Text('20%'),
                      ),
                    ])),
                Card(
                  shadowColor: Color(0x690FFFF0),
                  elevation: 10,
                  child: Column(
                    children: [
                      Text(
                        'Account options',
                        style: TextStyle(fontSize: 20),
                      ),
                      ListTile(
                        title: Text('Update Profile'),
                        onTap: () {
                          showModalBottomSheet(
                            isScrollControlled: true,
                              context: context,
                              builder: (context) => Card(
                                    child: Column(
                                      children: [
                                        Form(
                                          key: nameForm,
                                          child:Column(
                                            children:[
                                        Divider(),
                                        SizedBox(
                                            width: 250,
                                            child: TextFormField(
                                              validator: (value)=>value.isEmpty?'Your first name is required':null,
                                              maxLines: 1,
                                              controller: firstNameController,
                                              decoration: InputDecoration(
                                                  hintText: 'First name'),
                                            )),
                                        SizedBox(
                                          width: 250,
                                          child: TextFormField(
                                            validator: (value)=>value.isEmpty?'Your last name is required':null,
                                            controller: lastNameController,
                                            maxLines: 1,
                                            decoration: InputDecoration(
                                                hintText: 'Last name'),
                                          ),
                                        ),
                                        Divider(),
                                        ElevatedButton(
                                            onPressed: () {
                                              if(nameForm.currentState.validate())
                                              widget._database
                                                  .updateProfile(
                                                      firstNameController
                                                          .value.text,
                                                      lastNameController
                                                          .value.text,
                                                      widget._user.username)
                                                  .then((value) {
                                                if (value)
                                                  ScaffoldMessenger.of(context)
                                                      .showSnackBar(
                                                    SnackBar(
                                                        content: Text(
                                                            'Your account is updated successfully')),
                                                  );
                                                else
                                                  ScaffoldMessenger.of(context)
                                                      .showSnackBar(SnackBar(
                                                          content: Text(
                                                              'There was a problem while updating your account')));
                                                Navigator.of(context).pop();
                                                widget._database
                                                    .getCurrentUser(
                                                        widget._user.username)
                                                    .then(
                                                        (value) => setState(() {
                                                              user = value;
                                                            }));
                                              });
                                            },
                                            child: Text('Update profile'))
                                            ])),
                                            Divider(thickness: 3,),
                                            Form(
                                              key:passwordForm,
                                              child:Column(
                                                children:[                                            SizedBox(
                                              width: 250,
                                              child: TextFormField(
                                                controller: oldPasswordController,
                                                validator: (value)=>value.isEmpty?'Your old password is required!':null,
                                                maxLines: 1,
                                                decoration: InputDecoration(
                                                  hintText: 'Old password'
                                                ),
                                              ),
                                            ),
                                            SizedBox(
                                              width: 250,
                                              child: TextFormField(
                                                controller: newPasswordController,
                                                validator: (value)=>value.isEmpty?'Please enter your new password':null,
                                                maxLines: 1,
                                                decoration: InputDecoration(
                                                  hintText: 'New password'
                                                ),
                                              ),
                                            ),
                                            SizedBox(
                                              width: 250,
                                              child: TextFormField(
                                                controller: confirmPasswordController,
                                                validator: (value)=>(value.isEmpty)?'Please reenter your new password':(value!=newPasswordController.value.text)?'Your password don\'t match':null,
                                                maxLines: 1,
                                                decoration: InputDecoration(
                                                  hintText: 'Confirm password'
                                                ),
                                              ),
                                            ),
                                            ElevatedButton(onPressed: (){
                                              if(passwordForm.currentState.validate()){
                                                // update password
                                              }
                                            }, child: Text('Update Password'))
                                                ]))
                                      ],
                                    ),
                                  ));
                        },
                      ),
                      ListTile(
                        title: Text(
                          'Delete Account',
                          style: TextStyle(color: Colors.red),
                        ),
                        onTap: () {},
                      )
                    ],
                  ),
                )
              ],
            )),
      );
}
