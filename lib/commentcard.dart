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
  bool ownComment = false;
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
    if (widget.doc.get('Author') == widget._user.username) {
      setState(() {
        ownComment = true;
      });
    } else
      setState(() {
        ownComment = false;
      });
  }

  Widget build(BuildContext context) {
    if (widget.doc.get('Author') == widget._user.username) {
      setState(() {
        ownComment = true;
      });
    } else
      setState(() {
        ownComment = false;
      });
    return Card(
      elevation: 10,
      shadowColor: Color(0x690FFFF0),
      child: Container(
          child: Column(children: [
        Divider(),
        Row(
          children: [
            Expanded(flex: 1, child: Icon(Icons.face)),
            VerticalDivider(),
            Expanded(
                flex: 5,
                child: InkWell(
                    highlightColor: Colors.transparent,
                    onTap: () {},
                    child: Text(widget.doc['Author']))),
            VerticalDivider(),
            Expanded(
                flex: 10,
                child:
                    Text(Database.parseDatetime(widget.doc['date'].toDate()))),
            PopupMenuButton(
                onSelected: (value) {
                  switch (value) {
                    case 'delete':
                      showModalBottomSheet<bool>(
                          context: context,
                          builder: (context) => Card(
                                  child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                    Text(
                                        'Are you sure you want to delete this post'),
                                    ButtonBar(children: [
                                      TextButton(
                                          onPressed: () {
                                            Navigator.of(context).pop(true);
                                          },
                                          child: Text('Yes')),
                                      TextButton(
                                          onPressed: () {
                                            Navigator.of(context).pop(false);
                                          },
                                          child: Text('Cancel'))
                                    ])
                                  ]))).then((value) {
                        if (value != null) if (value) {
                          widget._database
                              .deletePost(widget.doc.reference)
                              .then((value) {
                            if (value)
                              ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                      backgroundColor: Color(0x690FFFF0),
                                      content:
                                          Text('Your comment is deleted')));
                            else
                              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                  backgroundColor: Color(0x690FFFF0),
                                  content: Text(
                                      'There was an error while deleting your comment')));
                          });
                        }
                      });
                      break;
                    default:
                  }
                },
                itemBuilder: (context) => [
                      // PopupMenuItem(
                      //   child: Text('Report comment'),
                      // ),

                      PopupMenuItem(
                          value: 'delete',
                          enabled: ownComment,
                          child: Text(
                            'Delete comment',
                            style: TextStyle(
                                color: ownComment ? Colors.red : Colors.grey),
                          ))
                    ])
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
                                              child: LinearProgressIndicator()))
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
                                        shadowColor: Color(0x690FFFF0),
                                        child: Stack(
                                            alignment: Alignment.bottomRight,
                                            children: [
                                              TextField(
                                                controller: replyController,
                                                maxLines: 5,
                                                maxLength: 150,
                                              ),
                                              IconButton(
                                                padding:
                                                    EdgeInsetsDirectional.only(
                                                        bottom: 20),
                                                icon: Icon(Icons.send),
                                                onPressed: () {
                                                  String content =
                                                      replyController
                                                          .value.text;
                                                  widget._database.postElement(
                                                      FirebaseFirestore.instance
                                                          .collection(
                                                              'Thoughts')
                                                          .doc(widget.parent.id)
                                                          .collection(
                                                              'Comments')
                                                          .doc(widget.doc.id)
                                                          .collection(
                                                              'Comments')
                                                          .doc(),
                                                      content,
                                                      widget._user.username,
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
}
