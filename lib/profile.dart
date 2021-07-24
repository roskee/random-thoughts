import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:random_thoughts/database.dart';
import 'package:random_thoughts/updateprofile.dart';
import 'package:random_thoughts/user.dart';

class Profile extends StatefulWidget {
  final UserInstance _user;
  final Database _database;
  Profile(this._user, this._database);
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  Map<String, dynamic> user;

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
                        onTap: () {},
                      )
                    ],
                  ),
                )
              ],
            )),
      );
}
