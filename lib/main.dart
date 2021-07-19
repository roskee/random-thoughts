import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:random_thoughts/thoughtpreview.dart';

import 'database.dart';

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
  TextEditingController addThoughtController;
  GlobalKey<ScaffoldState> _scaffoldKey;
  void initState() {
    super.initState();
    _scaffoldKey = GlobalKey<ScaffoldState>();
    addThoughtController = TextEditingController();
    Database.getInstance().then((value) => setState(() {
          _database = value;
        }));
  }

  String parseDateTime(DateTime dateTime) {
    return 'Today - 12:30PM';
  }

  Widget build(BuildContext context) => MaterialApp(
        title: 'Random Thoughts',
        home: Scaffold(
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
                                        hintText: 'What are you thinking?',
                                      ),
                                      maxLines: 6,
                                      maxLength: 150,
                                    ),
                                    IconButton(
                                        icon: Icon(
                                          Icons.send,
                                        ),
                                        onPressed: () {
                                          FirebaseFirestore.instance
                                              .runTransaction(
                                                  (transaction) async {
                                            transaction.set(
                                                FirebaseFirestore.instance
                                                    .collection('Thoughts')
                                                    .doc(),
                                                {
                                                  'Author': 'roskee',
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
                              PopupMenuButton(
                                  icon: Icon(Icons.face),
                                  itemBuilder: (context) => [
                                        PopupMenuItem(child: Text('Settings')),
                                        PopupMenuItem(child: Text('About'))
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
                                _database, snapshot.data.docs[index]),
                            childCount: snapshot.data.docs.length,
                          ))
                        ],
                      );
                      // ListView.builder(
                      //   itemCount: 6,
                      //   itemBuilder: (context, index) {
                      //     return ThoughtView(snapshot.data.docs[index]);
                      // ThoughtListItem(
                      //   snapshot.data.docs[index],
                      //   IconButton(
                      //       icon: Icon(Icons.thumb_up),
                      //       onPressed: () {
                      //         // update likes count
                      //        _database.updateDoc(snapshot.data.docs[index],
                      //        (freshSnapshot)=> {'likes': freshSnapshot['likes'] + 1});
                      //       }
                      //     ),
                      //     (){
                      //       // details about post
                      //       Navigator.of(context).push(MaterialPageRoute(builder: (context) => ThoughtView(snapshot.data.docs[index])));
                      //     }
                      // );
                    },
                  )),
      );
}
