import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(Home());
}

class Home extends StatefulWidget {
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  void initState() {
    super.initState();
    Firebase.initializeApp();
  }
  String parseDateTime(DateTime dateTime){
    return 'Today - 12:30PM';
  }
  Widget build(BuildContext context) => MaterialApp(
        title: 'Random Thoughts',
        home: Scaffold(
          appBar: AppBar(title: Text('Random Thoughts')),
          body: StreamBuilder(
            stream:
                FirebaseFirestore.instance.collection('Thoughts').snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData)
                return Center(child: CircularProgressIndicator());
              return ListView.builder(
                itemCount: snapshot.data.docs.length,
                itemBuilder: (context, index) {
                  return Card(
                      child: ListTile(
                    isThreeLine: true,
                    title: Row(
                      children:[Text(
                      snapshot.data.docs[index]['Author'],
                      style: TextStyle(
                        fontWeight: FontWeight.w600
                      ),
                    ),
                    VerticalDivider(),
                    Text(parseDateTime(snapshot.data.docs[index]['date'].toDate()),style: TextStyle(
                      fontSize: 12,
                      letterSpacing: 2,
                      fontWeight: FontWeight.w400,
                      fontStyle: FontStyle.italic
                    ),)
                      ]),
                    subtitle: Text(
                      snapshot.data.docs[index]['content'],
                      overflow: TextOverflow.fade,
                      softWrap: true,
                      maxLines: 3,
                    ), //snapshot.data.docs[index]['content'],
                    trailing: Stack(alignment: Alignment.center, children: [
                      IconButton(
                        icon: Icon(Icons.thumb_up),
                        onPressed: () {
                          // update likes count
                          FirebaseFirestore.instance
                              .runTransaction((transaction) async {
                            DocumentSnapshot freshSnapshot = await transaction
                                .get(snapshot.data.docs[index].reference);
                            transaction.update(freshSnapshot.reference,
                                {'likes': freshSnapshot['likes'] + 1});
                          });
                        },
                      ),
                      Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Text('${snapshot.data.docs[index]['likes']}')
                          ])
                    ]),
                    onTap: () {
                      // view details about post
                    },
                  ));
                },
              );
            },
          ),
        ),
      );
}
