import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:random_thoughts/thoughtlist.dart';

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
  void initState() {
    super.initState();
    Database.getInstance().then((value) => setState((){
      _database = value;
    }));
  }
  String parseDateTime(DateTime dateTime){
    return 'Today - 12:30PM';
  }
  Widget build(BuildContext context) => MaterialApp(
        title: 'Random Thoughts',
        home: Scaffold(
          appBar: AppBar(title: Text('Random Thoughts')),
          body: (_database == null)?Center(child:CircularProgressIndicator())
         :StreamBuilder(
            stream: _database.getCollection('Thoughts'),
            builder: (context, snapshot) {
              if (!snapshot.hasData)
                return Center(child: CircularProgressIndicator());
              return ListView.builder(
                itemCount: 6,
                itemBuilder: (context, index) {
                  return ThoughtListItem(
                    snapshot.data.docs[index],
                    IconButton(
                        icon: Icon(Icons.thumb_up),
                        onPressed: () {
                          // update likes count
                         _database.updateDoc(snapshot.data.docs[index],
                         (freshSnapshot)=> {'likes': freshSnapshot['likes'] + 1});
                        }
                      ),
                      (){
                        // details about post
                      }
                  );
                },
              );
            },
          ),
        ),
      );
}
