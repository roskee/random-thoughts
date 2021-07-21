import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'database.dart';

class CommentCard extends StatefulWidget {
  final DocumentSnapshot parent;
  final DocumentSnapshot doc;
  final DocumentSnapshot ancestor;
  final bool last;
  CommentCard(this.parent, this.doc, {this.last = false, this.ancestor});
  _CommentCardState createState() => _CommentCardState();
}

class _CommentCardState extends State<CommentCard> {
  TextEditingController replyController;
  void initState() {
    super.initState();
    replyController = TextEditingController();
  }

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
                  child: Text(widget.doc['Author'])),
              VerticalDivider(),
              Text(Database.parseDatetime(widget.doc['date'].toDate()))
            ],
          ),
          Divider(),
          Container(
            padding: EdgeInsets.all(8),
            alignment: Alignment.centerLeft,
            child: Text(
              widget.doc['content'],
              textAlign: TextAlign.left,
            ),
          ),
          Divider(),
          (widget.last)
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
                                    .doc(widget.ancestor.id)
                                    .collection('Comments')
                                    .doc(widget.parent.id)
                                    .collection('Comments')
                                    .doc(widget.doc.id));
                            transaction.update(freshSnapshot.reference,
                                {'likes': freshSnapshot['likes'] + 1});
                          });
                        },
                        child: Icon(Icons.thumb_up)),
                    VerticalDivider(),
                    Text('${widget.doc['likes']}'),
                    VerticalDivider(),
                  ],
                )
              : StreamBuilder(
                  stream: FirebaseFirestore.instance
                      .collection('Thoughts')
                      .doc(widget.parent.id) // post
                      .collection('Comments')
                      .doc(widget.doc.id) // comment
                      .collection('Comments')
                      .snapshots(), // replies
                  builder: (context, snapshot) => (snapshot.hasData)
                      ? ExpansionTile(
                          childrenPadding: EdgeInsets.all(5),
                          title: Row(
                            children: [
                              InkWell(
                                  highlightColor: Colors.transparent,
                                  onTap: () {
                                    FirebaseFirestore.instance
                                        .runTransaction((transaction) async {
                                      DocumentSnapshot freshSnapshot =
                                          await transaction.get(
                                              FirebaseFirestore.instance
                                                  .collection('Thoughts')
                                                  .doc(widget.parent.id) // post
                                                  .collection('Comments')
                                                  .doc(widget
                                                      .doc.id)); // comment
                                      transaction.update(
                                          freshSnapshot.reference, {
                                        'likes': freshSnapshot['likes'] + 1
                                      });
                                    });
                                  },
                                  child: Icon(Icons.thumb_up)),
                              Text('${widget.doc['likes']}'),
                              VerticalDivider(),
                              Icon(Icons.reply),
                              Text(
                                  '${snapshot.data.docs.length}'), // no of comments
                              VerticalDivider(),
                              InkWell(
                                child: Text('Reply'),
                                onTap: () {
                                  showModalBottomSheet(
                                      context: context,
                                      builder: (context) => Card(
                                              child: Stack(
                                                  alignment:
                                                      Alignment.bottomRight,
                                                  children: [
                                                TextField(
                                                  controller: replyController,
                                                  maxLines: 5,
                                                  maxLength: 150,
                                                ),
                                                IconButton(
                                                  padding: EdgeInsetsDirectional
                                                      .only(bottom: 20),
                                                  icon: Icon(Icons.send),
                                                  onPressed: () {
                                                    String content =
                                                        replyController
                                                            .value.text;
                                                    FirebaseFirestore.instance
                                                        .runTransaction(
                                                            (transaction) async {
                                                      DocumentSnapshot
                                                          freshSnapshot =
                                                          await transaction.get(
                                                              FirebaseFirestore
                                                                  .instance
                                                                  .collection(
                                                                      'Thoughts')
                                                                  .doc(widget
                                                                      .parent
                                                                      .id)
                                                                  . // post
                                                                  collection(
                                                                      'Comments')
                                                                  .doc(widget
                                                                      .doc
                                                                      .id) // comment
                                                                  .collection(
                                                                      'Comments')
                                                                  .doc()); // reply
                                                      transaction.set(
                                                          freshSnapshot
                                                              .reference,
                                                          {
                                                            'Author': 'Alemu',
                                                            'content': content,
                                                            'date':
                                                                Timestamp.now(),
                                                            'likes': 0
                                                          });
                                                    });
                                                    Navigator.of(context).pop();
                                                    replyController.clear();
                                                  },
                                                )
                                              ])));
                                },
                              )
                            ],
                          ),
                          children: (snapshot.data.docs.length == 0)
                              ? []
                              : List.generate(
                                  snapshot.data.docs.length,
                                  (index) => CommentCard(
                                        widget.doc,
                                        snapshot.data.docs[index],
                                        last: true,
                                        ancestor: widget.parent,
                                      )))
                      : Center(
                          child: LinearProgressIndicator(),
                        ))
        ])),
      );
}
