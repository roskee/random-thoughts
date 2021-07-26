import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:random_thoughts/database.dart';
import 'package:random_thoughts/updateprofile.dart';
import 'package:random_thoughts/user.dart';

class Profile extends StatefulWidget {
  final String _user;
  final Database _database;
  Profile(this._user, this._database);
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  Map<String, dynamic> user;
  TextEditingController checkPasswordForDeletionController =
      TextEditingController();
  bool isLoggedin = false;
  bool ignorePointer = false;
  void initState() {
    super.initState();
    if (widget._user ==
        UserInstance.getInstance(FirebaseAuth.instance).username)
      isLoggedin = true;
    widget._database.getCurrentUser(widget._user).then((value) => setState(() {
          user = value;
        }));
  }

  String parsePopularity(double popularity) {
    return (popularity == 0.01)
        ? 'Celebrity'
        : (popularity == 0.1)
            ? 'Famous'
            : (popularity == 0.3)
                ? 'Well Known'
                : (popularity == 0.5)
                    ? 'Casual'
                    : (popularity == 0.9)
                        ? 'Observer'
                        : 'Sleepy';
  }

  Widget build(BuildContext context) => AbsorbPointer(
      absorbing: ignorePointer,
      child: Material(
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
                              widget._user,
                              style: TextStyle(fontSize: 20),
                            )
                          : Text(
                              '${widget._user} (${user['firstname']} ${user['lastname']})',
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
                      (user == null)
                          ? LinearProgressIndicator()
                          : ListTile(
                              title: Text('Popularity'),
                              subtitle: LinearProgressIndicator(
                                  value: 1 - user['popularity']),
                              trailing:
                                  Text(parsePopularity(user['popularity'])),
                            ),
                    ])),
                Visibility(
                    visible: isLoggedin,
                    child: Card(
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
                              Navigator.of(context).push(MaterialPageRoute(
                                  builder: (context) => UpdateProfile(
                                      widget._database,
                                      widget._user,
                                      (value) => setState(() {
                                            user = value;
                                          }))));
                            },
                          ),
                          ListTile(
                            title: Text(
                              'Delete Account',
                              style: TextStyle(color: Colors.red),
                            ),
                            onTap: () {
                              showModalBottomSheet<bool>(
                                  isScrollControlled: true,
                                  context: context,
                                  builder: (context) => Card(
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Text(
                                              'Are you sure you want to delete your account with all your activity history?',
                                              style:
                                                  TextStyle(color: Colors.red),
                                            ),
                                            TextField(
                                              obscureText: true,
                                              maxLines: 1,
                                              controller:
                                                  checkPasswordForDeletionController,
                                              decoration: InputDecoration(
                                                  hintText: 'Input password'),
                                            ),
                                            ButtonBar(
                                              children: [
                                                TextButton(
                                                    onPressed: () {
                                                      Navigator.of(context)
                                                          .pop(true);
                                                    },
                                                    child: Text(
                                                      'Yes',
                                                      style: TextStyle(
                                                          color: Colors.red),
                                                    )),
                                                TextButton(
                                                    onPressed: () {
                                                      Navigator.of(context)
                                                          .pop(false);
                                                    },
                                                    child: Text('Cancel'))
                                              ],
                                            )
                                          ],
                                        ),
                                      )).then((value) {
                                if (value != null) if (value) {
                                  setState(() {
                                    ignorePointer = true;
                                  });
                                  widget._database
                                      .deleteAccount(
                                          widget._user,
                                          checkPasswordForDeletionController
                                              .value.text)
                                      .then((value) {
                                    if (value == null) {
                                      UserInstance.signout(
                                          FirebaseAuth.instance, () {
                                        Navigator.of(context)
                                            .popUntil((route) => route.isFirst);
                                        Navigator.of(context).setState(() {});
                                      });
                                    } else {
                                      setState(() {
                                        ignorePointer = false;
                                      });
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                              SnackBar(content: Text(value)));
                                    }
                                  });
                                }
                              });
                            },
                          )
                        ],
                      ),
                    ))
              ],
            )),
      ));
}
