import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'database.dart';

class CommentCard extends StatelessWidget {
  final DocumentSnapshot parent;
  final DocumentSnapshot doc;
  final DocumentSnapshot ancestor;
  final bool last;
  CommentCard(this.parent, this.doc, {this.last = false,this.ancestor});
  Widget build(BuildContext context) => Card(
        elevation: 10,
        child: Container(
            child: Column(children: [
          Divider(),
          Row(
            children: [
              Icon(Icons.face),
              VerticalDivider(),
              InkWell(
                  highlightColor: Colors.transparent,
                  onTap: () {},
                  child: Text(doc['Author'])),
              VerticalDivider(),
              Text(Database.parseDatetime(doc['date'].toDate()))
            ],
          ),
          Divider(),
          Container(
            padding: EdgeInsets.all(8),
            alignment: Alignment.centerLeft,
            child: Text(
              doc['content'],
              textAlign: TextAlign.left,
            ),
          ),
          Divider(),
          (last)
              ? Row(
                  children: [
                    VerticalDivider(),
                    InkWell(
                        highlightColor: Colors.transparent,
                        onTap: () {
                          FirebaseFirestore.instance
                              .runTransaction((transaction) async {
                            DocumentSnapshot freshSnapshot =
                                await transaction.get(FirebaseFirestore.instance
                                    .collection('Thoughts')
                                    .doc(ancestor.id).
                                    collection('Comments')
                                    .doc(parent.id)
                                    .collection('Comments')
                                    .doc(doc.id));
                            transaction.update(freshSnapshot.reference,
                                {'likes': freshSnapshot['likes'] + 1});
                          });
                        },
                        child: Icon(Icons.thumb_up)),
                    VerticalDivider(),
                    Text('${doc['likes']}'),
                    VerticalDivider(),
                  ],
                )
              : 
              StreamBuilder(
                stream: FirebaseFirestore.instance
                                    .collection('Thoughts')
                                    .doc(parent.id)
                                    .collection('Comments')
                                    .doc(doc.id)
                                    .collection('Comments')
                                    .snapshots(),
                builder: (context,snapshot)=>
                (snapshot.hasData)?
                ExpansionTile(
                  childrenPadding: EdgeInsets.all(5),
                  title: Row(
                    children: [
                      InkWell(
                          highlightColor: Colors.transparent,
                          onTap: () {
                            FirebaseFirestore.instance
                              .runTransaction((transaction) async {
                            DocumentSnapshot freshSnapshot =
                                await transaction.get(FirebaseFirestore.instance
                                    .collection('Thoughts')
                                    .doc(parent.id)
                                    .collection('Comments')
                                    .doc(doc.id));
                            transaction.update(freshSnapshot.reference,
                                {'likes': freshSnapshot['likes'] + 1});
                          });
                          },
                          child: Icon(Icons.thumb_up)),
                      Text('${doc['likes']}'),
                      VerticalDivider(),
                      Icon(Icons.comment),
                      Text('${snapshot.data.docs.length}'), // stream builder needed
                    ],
                  ),
                  children: 
                  (snapshot.data.docs.length==0)?
                  []:List.generate(snapshot.data.docs.length, (index) => CommentCard(doc,snapshot.data.docs[index],last:true,ancestor: parent,))
                ):Center(child: CircularProgressIndicator(),)
              )
        ])),
      );
}
