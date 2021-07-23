import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:random_thoughts/user.dart';

import 'database.dart';

class CommentCard extends StatefulWidget {
  final Database _database;
  final UserInstance _user;
  final DocumentSnapshot parent;
  final DocumentSnapshot doc;
  final DocumentSnapshot ancestor;
  final bool last;
  CommentCard(this._database, this._user, this.parent, this.doc,
      {this.last = false, this.ancestor});
  _CommentCardState createState() => _CommentCardState();
}

class _CommentCardState extends State<CommentCard> {
  TextEditingController replyController;
  bool commentLike = false;
  bool commentLikeLoading = false;
  bool replyLike = false;
  bool replyLikeLoading = false;
  void initState() {
    super.initState();
    replyController = TextEditingController();
    if (widget.last) {
      if (widget.doc.get('likers').contains(widget._user.username))
        setState(() {
          replyLike = true;
        });
    } else {
      if (widget.doc.get('likers').contains(widget._user.username))
        setState(() {
          commentLike = true;
        });
    }
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
                          setState(() {
                            replyLike = !replyLike;
                            replyLikeLoading = true;
                          });
                          widget._database
                              .likeComment(
                                  FirebaseFirestore.instance
                                      .collection('Thoughts')
                                      .doc(widget.ancestor.id)
                                      .collection('Comments')
                                      .doc(widget.parent.id)
                                      .collection('Comments')
                                      .doc(widget.doc.id),
                                  widget._user.username)
                              .then((value) {
                            replyLike = value;
                            replyLikeLoading = false;
                          });
                        },
                        child: Stack(alignment: Alignment.center, children: [
                          Icon(
                            Icons.thumb_up,
                            color: (replyLike) ? Colors.green : Colors.black,
                          ),
                          Visibility(
                              visible: replyLikeLoading,
                              child: SizedBox(
                                width: 20,
                                child: LinearProgressIndicator(),
                              ))
                        ])),
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
                                    setState(() {
                                      commentLike = !commentLike;
                                      commentLikeLoading = true;
                                    });
                                    widget._database
                                        .likeComment(
                                            FirebaseFirestore.instance
                                                .collection('Thoughts')
                                                .doc(widget.parent.id)
                                                .collection('Comments')
                                                .doc(widget.doc.id),
                                            widget._user.username)
                                        .then((value) {
                                      setState(() {
                                        commentLike = value;
                                        commentLikeLoading = false;
                                      });
                                    });
                                  },
                                  child: Stack(
                                      alignment: Alignment.center,
                                      children: [
                                        Icon(
                                          Icons.thumb_up,
                                          color: (commentLike)
                                              ? Colors.green
                                              : Colors.black,
                                        ),
                                        Visibility(
                                            visible: commentLikeLoading,
                                            child: SizedBox(
                                                width: 20,
                                                child:
                                                    LinearProgressIndicator()))
                                      ])),
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
                                                    widget._database
                                                        .postElement(
                                                            FirebaseFirestore
                                                                .instance
                                                                .collection(
                                                                    'Thoughts')
                                                                .doc(widget
                                                                    .parent.id)
                                                                .collection(
                                                                    'Comments')
                                                                .doc(widget
                                                                    .doc.id)
                                                                .collection(
                                                                    'Comments')
                                                                .doc(),
                                                            content,
                                                            widget
                                                                ._user.username,
                                                            false);

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
                                        widget._database,
                                        widget._user,
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
