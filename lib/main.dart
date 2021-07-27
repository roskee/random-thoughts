import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:random_thoughts/profile.dart';
import 'package:random_thoughts/thoughtpreview.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:random_thoughts/verification.dart';

import 'about.dart';
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
  bool wallpaperFetched = false;
  Widget wallpaper;
  bool notLoggedin;
  bool ready = false;
  bool isVerified = false;
  String sortBy = 'date';
  void initState() {
    super.initState();
    init().then((value) {
      setState(() {
        ready = true;
      });
    });
    // auth = FirebaseAuth.instance;
    //notLoggedin = true;
    // auth.userChanges().listen((event) {
    //   if (event == null) {
    //     setState(() {
    //       notLoggedin = true;
    //     });
    //   } else {
    //     setState(() {
    //       notLoggedin = false;
    //       _user = UserInstance.getInstance(FirebaseAuth.instance);
    //       isVerified = _user.isVerified;
    //       print(isVerified);
    //     });
    //   }
    // });
    // if (auth.currentUser != null)
    //   auth.currentUser.reload().then((value) => {
    //         if (auth.currentUser == null)
    //           _user.signout(auth, () {
    //             setState(() {
    //               notLoggedin = true;
    //             });
    //           })
    //         else
    //           setState(() {
    //             notLoggedin = false;
    //             _user = UserInstance.getInstance(FirebaseAuth.instance);
    //           })
    //       });
    _scaffoldKey = GlobalKey<ScaffoldState>();
    addThoughtController = TextEditingController();
    //_user = UserInstance.getInstance(auth);
    //isVerified = _user.isVerified;
    // Database.getInstance().then((value) => setState(() {
    //       _database = value;
    //     }));
    wallpaper = Image.asset(
      'assets/images/random_thoughts_logo3.png',
      fit: BoxFit.fill,
    );
  }

  Future<void> init() async {
    _database = await Database.getInstance();
    auth = FirebaseAuth.instance;
    _user = UserInstance.fromUser(FirebaseAuth.instance.currentUser);
    notLoggedin = _user.notLoggedin;
    auth.userChanges().listen((event) {
      if (event == null) {
        setState(() {
          notLoggedin = true;
        });
        UserInstance.signout(auth, () {
          setState(() {});
        });
      } else {
        setState(() {
          _user = UserInstance.fromUser(event);  //UserInstance.fromAuth(auth);
          notLoggedin = _user.notLoggedin;
          isVerified = _user.isVerified;
        });
      }
    });
  }

  String parseDateTime(DateTime dateTime) {
    return 'Today - 12:30PM';
  }

  Widget build(BuildContext context) => MaterialApp(
        title: 'Random Thoughts',
        theme: ThemeData(primarySwatch: Colors.green),
        home: !ready
            ? Center(
                child: CircularProgressIndicator(),
              )
            : (notLoggedin)
                ? Login(auth, () {
                    setState(() {
                      _user.reload(auth, () {
                        setState(() {
                          notLoggedin = false;
                        });
                      });
                    });
                  })
                : !isVerified
                    ? Verification(false)
                    : Scaffold(
                        key: _scaffoldKey,
                        floatingActionButton: FloatingActionButton(
                          mini: false,
                          child: Icon(Icons.post_add),
                          onPressed: () {
                            showModalBottomSheet(
                                context: _scaffoldKey.currentContext,
                                backgroundColor: Colors.transparent,
                                builder: (context) => Card(
                                      shadowColor: Color(0x690FFFF0),
                                      child: Container(
                                          color: Colors.transparent,
                                          child: Stack(
                                              alignment: Alignment.bottomRight,
                                              children: [
                                                TextField(
                                                  textInputAction:
                                                      TextInputAction.done,
                                                  onEditingComplete: () {
                                                    if (addThoughtController
                                                        .value
                                                        .text
                                                        .isEmpty) return;
                                                    _database
                                                        .postElement(
                                                            FirebaseFirestore
                                                                .instance
                                                                .collection(
                                                                    'Thoughts')
                                                                .doc(),
                                                            addThoughtController
                                                                .value.text,
                                                            _user.username,
                                                            true)
                                                        .then((value) {
                                                      addThoughtController
                                                          .clear();
                                                      Navigator.of(context)
                                                          .pop();
                                                      setState(() {});
                                                    });
                                                  },
                                                  controller:
                                                      addThoughtController,
                                                  decoration: InputDecoration(
                                                    hintText:
                                                        'What are you thinking ${_user.username}?',
                                                  ),
                                                  maxLines: 6,
                                                  maxLength: 150,
                                                ),
                                                IconButton(
                                                    padding:
                                                        EdgeInsetsDirectional
                                                            .only(bottom: 20),
                                                    icon: Icon(
                                                      Icons.send,
                                                    ),
                                                    onPressed: () {
                                                      // add a new post
                                                      if (addThoughtController
                                                          .value
                                                          .text
                                                          .isEmpty) return;
                                                      _database
                                                          .postElement(
                                                              FirebaseFirestore
                                                                  .instance
                                                                  .collection(
                                                                      'Thoughts')
                                                                  .doc(),
                                                              addThoughtController
                                                                  .value.text,
                                                              _user.username,
                                                              true)
                                                          .then((value) {
                                                        addThoughtController
                                                            .clear();
                                                        Navigator.of(context)
                                                            .pop();
                                                        setState(() {});
                                                      });
                                                    })
                                              ])),
                                    ));
                          },
                        ),
                        body: (_database == null)
                            ? Center(child: CircularProgressIndicator())
                            : StreamBuilder(
                                stream:
                                    _database.getCollection('Thoughts', sortBy),
                                builder: (context, snapshot) {
                                  if (!snapshot.hasData)
                                    return Center(
                                        child: CircularProgressIndicator());
                                  return CustomScrollView(
                                    slivers: [
                                      SliverAppBar(
                                        actions: [
                                          Card(
                                              elevation: 10,
                                              color: Color(0x690FFFF0),
                                              child: Row(children: [
                                                // Visibility(
                                                //   visible: !isVerified,
                                                //   child:Center(
                                                //     child: IconButton(
                                                //         onPressed: () {
                                                //           // verify email
                                                //           FirebaseAuth.instance.currentUser.sendEmailVerification().onError((error, stackTrace) {
                                                //             print(stackTrace);
                                                //           });
                                                //         },

                                                //         icon: Icon(Icons
                                                //             .notification_important))),),
                                                Center(
                                                    child: Container(
                                                        padding:
                                                            EdgeInsets.only(
                                                                left: 10),
                                                        child: Text(
                                                          _user.username,
                                                          style: TextStyle(
                                                              fontSize: 18,
                                                              color:
                                                                  Colors.white),
                                                        ))),
                                                PopupMenuButton(
                                                    onSelected: (value) {
                                                      switch (value) {
                                                        case 'settings':
                                                          Navigator.of(context).push(
                                                              MaterialPageRoute(
                                                                  builder: (context) =>
                                                                      Profile(
                                                                          _user
                                                                              .username,
                                                                          _database)));
                                                          break;
                                                        case 'signout':
                                                          auth
                                                              .signOut()
                                                              .then((value) => {
                                                                    setState(
                                                                        () {
                                                                      notLoggedin =
                                                                          true;
                                                                      UserInstance
                                                                          .signout(
                                                                              auth,
                                                                              () {
                                                                        notLoggedin =
                                                                            true;
                                                                      });
                                                                    })
                                                                  });
                                                          break;
                                                        case 'about':
                                                          Navigator.of(context).push(
                                                              MaterialPageRoute(
                                                                  builder:
                                                                      (context) =>
                                                                          About()));
                                                          break;
                                                      }
                                                    },
                                                    icon: Icon(Icons.face),
                                                    itemBuilder: (context) => [
                                                          PopupMenuItem(
                                                            value: 'settings',
                                                            child: Text(
                                                                'Settings'),
                                                          ),
                                                          PopupMenuItem(
                                                              value: 'signout',
                                                              child: Text(
                                                                  'Sign out')),
                                                          PopupMenuItem(
                                                              value: 'about',
                                                              child:
                                                                  Text('About'))
                                                        ])
                                              ]))
                                        ],
                                        stretch: false,
                                        centerTitle: false,
                                        bottom: AppBar(
                                          elevation: 10,
                                          backgroundColor: Color(0x6909FFF0),
                                          title: ListTile(
                                            title: Row(
                                              children: [
                                                Text('Sort By'),
                                                VerticalDivider(),
                                                DropdownButton(
                                                    onChanged: (value) {
                                                      setState(() {
                                                        sortBy = value;
                                                      });
                                                    },
                                                    value: sortBy,
                                                    items: [
                                                      DropdownMenuItem(
                                                          value: 'date',
                                                          child:
                                                              Text('Recent')),
                                                      DropdownMenuItem(
                                                          value: 'likes',
                                                          child:
                                                              Text('Popular'))
                                                    ])
                                              ],
                                            ),
                                          ),
                                        ),
                                        pinned: true,
                                        floating: true,
                                        expandedHeight: 150,
                                        flexibleSpace: FlexibleSpaceBar(
                                          background: wallpaper,
                                        ),
                                      ),
                                      (snapshot.data.docs.length == 0)
                                          ? SliverFillRemaining(
                                              child: Center(
                                                  child: Text(
                                                'No posts yet',
                                                style: TextStyle(fontSize: 20),
                                              )),
                                            )
                                          : SliverList(
                                              delegate:
                                                  SliverChildBuilderDelegate(
                                              (context, index) => ThoughtView(
                                                  _database,
                                                  _user,
                                                  snapshot.data.docs[index]),
                                              childCount:
                                                  snapshot.data.docs.length,
                                            ))
                                    ],
                                  );
                                },
                              )),
      );
}
