import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'database.dart';

class CommentCard extends StatelessWidget {
  final DocumentSnapshot parent;
  final DocumentSnapshot doc;
  final bool last;
  CommentCard(this.parent, this.doc, {this.last = false});
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
              : ExpansionTile(
                  childrenPadding: EdgeInsets.all(5),
                  title: Row(
                    children: [
                      InkWell(
                          highlightColor: Colors.transparent,
                          onTap: () {
                            Database.updateDocument(
                                doc,
                                (freshSnapshot) => {
                                      {'likes': freshSnapshot['likes'] + 1}
                                    });
                          },
                          child: Icon(Icons.thumb_up)),
                      Text('${doc['likes']}'),
                      VerticalDivider(),
                      Icon(Icons.comment),
                      Text('10'), // stream builder needed
                    ],
                  ),
                  children: [
                    CommentCard(
                      doc,
                      null,
                      last: true,
                    )
                  ],
                )
        ])),
      );
}
