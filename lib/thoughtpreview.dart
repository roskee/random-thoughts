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
  bool like = false;
  bool likeLoading = false;
  void initState() {
    super.initState();
    like = false;
    likeLoading = false;
    addCommentController = TextEditingController();
    addCommentFocusNode = FocusNode();
    if (widget.doc.get('likers').contains(widget._user.username)) {
      setState(() {
        like = true;
      });
    }
  }

  Widget build(BuildContext context) {
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
                      flex: 5,
                      child: Text(
                          Database.parseDatetime(widget.doc['date'].toDate())),
                    )
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
                                              ? Colors.blue
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
