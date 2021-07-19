import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:random_thoughts/thoughtlistitem.dart';
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
  GlobalKey<ScaffoldState> _scaffoldKey;
  void initState() {
    super.initState();
    _scaffoldKey = GlobalKey<ScaffoldState>();
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
          appBar: AppBar(title: Text('Random Thoughts')),
          floatingActionButton: FloatingActionButton(
            child: Icon(Icons.post_add),
            onPressed: () {
              showModalBottomSheet(
                  context: _scaffoldKey.currentContext,
                  builder: (context) => Card(
                        child: Container(
                            child: Stack(
                                alignment: Alignment.bottomRight,
                                children: [
                              TextField(
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
                                  onPressed: () {})
                            ])),
                      ));
            },
          ),
          drawer: Drawer(
            child: Text('hi'),
          ),
          body: (_database == null)
              ? Center(child: CircularProgressIndicator())
              : StreamBuilder(
                  stream: _database.getCollection('Thoughts'),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData)
                      return Center(child: CircularProgressIndicator());
                    return ListView.builder(
                      itemCount: 6,
                      itemBuilder: (context, index) {
                        return ThoughtView(snapshot.data.docs[index]);
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
                    );
                  },
                ),
        ),
      );
}
