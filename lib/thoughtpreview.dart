import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:random_thoughts/user.dart';

import 'commentcard.dart';
import 'database.dart';

class ThoughtView extends StatefulWidget {
  final Database database;
  final UserInstance _user;
  final DocumentSnapshot doc;
  ThoughtView(this.database, this._user, this.doc);
  _ThoughtViewState createState() => _ThoughtViewState();
}

class _ThoughtViewState extends State<ThoughtView> {
  TextEditingController addCommentController;
  FocusNode addCommentFocusNode;
  bool ownPost = false;
  bool like = false;
  bool likeLoading = false;
  void initState() {
    super.initState();
    addCommentController = TextEditingController();
    addCommentFocusNode = FocusNode();
    if (widget.doc.get('likers').contains(widget._user.username)) {
      setState(() {
        like = true;
      });
    } else
      setState(() {
        like = false;
      });
    if (widget.doc.get('Author') == widget._user.username) {
      setState(() {
        ownPost = true;
      });
    } else
      setState(() {
        ownPost = false;
      });
  }

  Widget build(BuildContext context) {
    if (widget.doc.get('likers').contains(widget._user.username)) {
      setState(() {
        like = true;
      });
    } else
      setState(() {
        like = false;
      });
    if (widget.doc.get('Author') == widget._user.username) {
      setState(() {
        ownPost = true;
      });
    } else
      setState(() {
        ownPost = false;
      });
    return InkWell(
        onTap: () {
          // show modal sheet
          showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              //backgroundColor: Colors.transparent,
              builder: (context) => Container(
                    color: Colors.transparent,
                    child: Column(
                      children: [
                        Expanded(
                            flex: 2,
                            child: Card(
                                shadowColor: Color(0x690FFFF0),
                                child: Align(
                                  alignment: Alignment.center,
                                  child: Text(
                                    'Comments',
                                    textAlign: TextAlign.center,
                                  ),
                                ))),
                        Expanded(
                            flex: 15,
                            child: StreamBuilder(
                                stream: FirebaseFirestore.instance
                                    .collection('Thoughts')
                                    .doc(widget.doc.id)
                                    .collection('Comments')
                                    .snapshots(),
                                builder: (context, snapshot) =>
                                    (snapshot.hasData)
                                        ? (snapshot.data.docs.length == 0)
                                            ? Text('No comments yet!')
                                            : ListView.builder(
                                                itemCount:
                                                    snapshot.data.docs.length,
                                                itemBuilder: (context, index) =>
                                                    CommentCard(
                                                      widget.database,
                                                      widget._user,
                                                      widget.doc,
                                                      snapshot.data.docs[index],
                                                      last: false,
                                                    ))
                                        : Center(
                                            child: CircularProgressIndicator(),
                                          ))),
                        Stack(alignment: Alignment.bottomRight, children: [
                          Card(
                              elevation: 10,
                              shadowColor: Color(0x690FFFF0),
                              child: Container(
                                  color: Colors.transparent,
                                  child: TextField(
                                    controller: addCommentController,
                                    focusNode: addCommentFocusNode,
                                    decoration: InputDecoration(
                                        hintText: 'Type your comment'),
                                    maxLines: 3,
                                    maxLength: 150,
                                  ))),
                          IconButton(
                              padding: EdgeInsetsDirectional.only(bottom: 25),
                              icon: Icon(Icons.send),
                              onPressed: () {
                                // add comment
                                String content =
                                    addCommentController.value.text;

                                widget.database
                                    .postElement(
                                        FirebaseFirestore.instance
                                            .collection('Thoughts')
                                            .doc(widget.doc.id)
                                            .collection('Comments')
                                            .doc(),
                                        content,
                                        widget._user.username,
                                        false)
                                    .then((value) {
                                  addCommentController.clear();
                                });
                                addCommentFocusNode.unfocus();
                              })
                        ])
                      ],
                    ),
                  ));
        },
        child: Card(
            elevation: 5,
            shadowColor: Color(0x690FFFF0),
            child: Container(
                margin: EdgeInsets.all(5),
                padding: EdgeInsets.all(10),
                alignment: Alignment.center,
                child: Column(children: [
                  Row(children: [
                    Expanded(
                      flex: 1,
                      child: Icon(Icons.face),
                    ),
                    VerticalDivider(),
                    Expanded(
                        flex: 5,
                        child: InkWell(
                          highlightColor: Colors.transparent,
                          onTap: () {},
                          child: Text(widget.doc['Author']),
                        )),
                    VerticalDivider(),
                    Expanded(
                      flex: 10,
                      child: Text(
                          Database.parseDatetime(widget.doc['date'].toDate())),
                    ),
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
                                                    Navigator.of(context)
                                                        .pop(true);
                                                  },
                                                  child: Text('Yes')),
                                              TextButton(
                                                  onPressed: () {
                                                    Navigator.of(context)
                                                        .pop(false);
                                                  },
                                                  child: Text('Cancel'))
                                            ])
                                          ]))).then((value) {
                                if (value != null) if (value) {
                                  widget.database
                                      .deletePost(widget.doc.reference)
                                      .then((value) {
                                    if (value)
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(SnackBar(
                                              backgroundColor:
                                                  Color(0x690FFFF0),
                                              content: Text(
                                                  'Your post is deleted')));
                                    else
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(SnackBar(
                                              backgroundColor:
                                                  Color(0x690FFFF0),
                                              content: Text(
                                                  'There was an error while deleting your post')));
                                  });
                                }
                              });

                              break;
                            default:
                          }
                        },
                        itemBuilder: (context) => [
                              // PopupMenuItem(
                              //   child: Text('Report post'),
                              // ),
                              PopupMenuItem(
                                value: 'delete',
                                enabled: ownPost,
                                child: Text(
                                  'Delete post',
                                  style: TextStyle(
                                      color:
                                          ownPost ? Colors.red : Colors.grey),
                                ),
                              )
                            ])
                  ]),
                  Divider(),
                  Container(
                      padding: EdgeInsets.all(10),
                      decoration: BoxDecoration(),
                      child: Text(
                        widget.doc['content'],
                        textAlign: TextAlign.center,
                      )),
                  Divider(
                    thickness: 2,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Expanded(
                        flex: 4,
                        child: VerticalDivider(),
                      ),
                      Expanded(
                        flex: 2,
                        child: Row(
                          children: [
                            InkWell(
                                highlightColor: Colors.transparent,
                                onTap: () {
                                  setState(() {
                                    like = !like;
                                    likeLoading = true;
                                  });
                                  widget.database
                                      .likePost(widget.doc.reference,
                                          widget._user.username)
                                      .then((value) => {
                                            setState(() {
                                              like = value;
                                              likeLoading = false;
                                            })
                                          });
                                },
                                child: Stack(
                                    alignment: Alignment.center,
                                    children: [
                                      Icon(Icons.thumb_up,
                                          color: (like)
                                              ? Colors.green
                                              : Colors.black),
                                      Visibility(
                                          visible: likeLoading,
                                          child: SizedBox(
                                              width: 20,
                                              child: LinearProgressIndicator()))
                                    ])),
                            VerticalDivider(),
                            Text('${widget.doc['likes']}'),
                          ],
                        ),
                      ),
                      StreamBuilder(
                          stream: FirebaseFirestore.instance
                              .collection('Thoughts')
                              .doc(widget.doc.id)
                              .collection('Comments')
                              .snapshots(),
                          builder: (context, snapshot) => Expanded(
                              flex: 2,
                              child: Row(
                                children: [
                                  Icon(Icons.comment),
                                  VerticalDivider(),
                                  (snapshot.hasData)
                                      ? Text('${snapshot.data.docs.length}')
                                      : Text('...'),
                                ],
                              )))
                    ],
                  ),
                ]))));
  }
}
