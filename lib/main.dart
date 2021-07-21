import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:random_thoughts/thoughtpreview.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'database.dart';
import 'login.dart';
import 'user.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(Home());
}

class Home extends StatefulWidget {
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  Database _database;
  UserInstance _user;
  FirebaseAuth auth;
  TextEditingController addThoughtController;
  GlobalKey<ScaffoldState> _scaffoldKey;
  bool notLoggedin;
  void initState() {
    super.initState();
    auth = FirebaseAuth.instance;
    notLoggedin = true;
    auth.userChanges().listen((event) {
      if (event == null) {
        setState(() {
          notLoggedin = true;
        });
      } else
        setState(() {
          notLoggedin = false;
        });
    });
    if (auth.currentUser != null)
      auth.currentUser.reload().then((value) => {
            if (auth.currentUser == null)
              _user.signout(auth, () {
                setState(() {
                  notLoggedin = true;
                });
              })
            else
              setState(() {
                notLoggedin = false;
              })
          });
    _scaffoldKey = GlobalKey<ScaffoldState>();
    addThoughtController = TextEditingController();
    _user = UserInstance.getInstance(auth);
    Database.getInstance().then((value) => setState(() {
          _database = value;
        }));
  }

  String parseDateTime(DateTime dateTime) {
    return 'Today - 12:30PM';
  }

  Widget build(BuildContext context) => MaterialApp(
        title: 'Random Thoughts',
        home: (notLoggedin)
            ? Login(auth, () {
                setState(() {
                  _user.reload(auth, () {
                    setState(() {
                      notLoggedin = false;
                    });
                  });
                });
              })
            : Scaffold(
                key: _scaffoldKey,
                floatingActionButton: FloatingActionButton(
                  mini: true,
                  child: Icon(Icons.post_add),
                  onPressed: () {
                    showModalBottomSheet(
                        context: _scaffoldKey.currentContext,
                        backgroundColor: Colors.transparent,
                        builder: (context) => Card(
                              child: Container(
                                  color: Colors.transparent,
                                  child: Stack(
                                      alignment: Alignment.bottomRight,
                                      children: [
                                        TextField(
                                          controller: addThoughtController,
                                          decoration: InputDecoration(
                                            hintText: 'What are you thinking ${_user.username}?',
                                          ),
                                          maxLines: 6,
                                          maxLength: 150,
                                        ),
                                        IconButton(
                                            padding: EdgeInsetsDirectional.only(
                                                bottom: 20),
                                            icon: Icon(
                                              Icons.send,
                                            ),
                                            onPressed: () {
                                              if (addThoughtController
                                                  .value.text.isEmpty) return;
                                              FirebaseFirestore.instance
                                                  .runTransaction(
                                                      (transaction) async {
                                                transaction.set(
                                                    FirebaseFirestore.instance
                                                        .collection('Thoughts')
                                                        .doc(),
                                                    {
                                                      'Author': _user.username,
                                                      'content':
                                                          addThoughtController
                                                              .value.text,
                                                      'date': Timestamp.now(),
                                                      'likes': 0
                                                    });
                                                Navigator.of(context).pop();
                                              });
                                            })
                                      ])),
                            ));
                  },
                ),
                body: (_database == null)
                    ? Center(child: CircularProgressIndicator())
                    : StreamBuilder(
                        stream: _database.getCollection('Thoughts'),
                        builder: (context, snapshot) {
                          if (!snapshot.hasData)
                            return Center(child: CircularProgressIndicator());
                          return CustomScrollView(
                            slivers: [
                              SliverAppBar(
                                actions: [
                                  Center(child:Text(_user.username)),
                                  PopupMenuButton(
                                    onSelected: (value){
                                      switch(value){
                                        case 'settings':
                                        break;
                                        case 'signout':
                                        auth.signOut().then((value) =>{
                                          setState((){
                                            notLoggedin = true;
                                            _user.signout(auth, (){

                                            });
                                          })
                                        });
                                        break;
                                        case 'about':
                                        break;
                                      }
                                    },
                                      icon: Icon(Icons.face),
                                      itemBuilder: (context) => [
                                            PopupMenuItem(
                                              value: 'settings',
                                                child: Text('Settings'),
                                                ),
                                            PopupMenuItem(
                                              value: 'signout',
                                                child: Text('Sign out')),
                                            PopupMenuItem(
                                              value: 'about',
                                              child: Text('About'))
                                          ])
                                ],
                                stretch: false,
                                expandedHeight: 150,
                                flexibleSpace: FlexibleSpaceBar(
                                  title: Text('Random Thoughts'),
                                ),
                              ),
                              SliverList(
                                  delegate: SliverChildBuilderDelegate(
                                (context, index) => ThoughtView(
                                    _database,_user, snapshot.data.docs[index]),
                                childCount: snapshot.data.docs.length,
                              ))
                            ],
                          );
                        },
                      )),
      );
}
