import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'commentcard.dart';
import 'database.dart';

class ThoughtView extends StatefulWidget {
  final Database database;
  final DocumentSnapshot doc;
  ThoughtView(this.database, this.doc);
  _ThoughtViewState createState() => _ThoughtViewState();
}

class _ThoughtViewState extends State<ThoughtView> {
  TextEditingController addCommentController;
  FocusNode addCommentFocusNode;
  void initState() {
    super.initState();
    addCommentController = TextEditingController();
    addCommentFocusNode = FocusNode();
    //FirebaseFirestore.instance.collection('Thoughts').doc(widget.doc.id).collection('Comments').get().then((value) => docs = value);
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
                    child: 
                        Column(children: [
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
                                  builder: (context, snapshot) => (snapshot
                                          .hasData)
                                      ? (snapshot.data.docs.length==0)?Text('No comments yet!')
                                      :ListView.builder(
                                          itemCount: snapshot.data.docs.length,
                                          itemBuilder: (context, index) =>
                                              CommentCard(
                                                widget.doc,
                                                snapshot.data.docs[index],
                                                last: true,
                                              ))
                                      : Center(
                                          child: CircularProgressIndicator(),
                                        ))),
    
                        Stack(
                          alignment: Alignment.bottomLeft,
                          children:[
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
                                IconButton(icon: Icon(Icons.send), onPressed: () {
                          // add comment
                          FirebaseFirestore.instance.runTransaction((transaction) async {
                            transaction.set(FirebaseFirestore.instance.collection('Thoughts').doc(widget.doc.id).collection('Comments').doc(), {
                              'Author': 'roskee',
                              'date':Timestamp.now(),
                              'content':addCommentController.value.text,
                              'likes':0

                            });
                          }).then((value) 
                          {
                             addCommentController.clear();
                          });
                         
                          addCommentFocusNode.unfocus();
                        })
                          ]
                        )
                      ],
                    ),
                  ));
        },
        child: Card(
            elevation: 5,
            child: Container(
                margin: EdgeInsets.all(5),
                padding: EdgeInsets.all(10),
                // decoration: BoxDecoration(
                //     border: Border.all(
                //         color: Colors.grey, style: BorderStyle.solid, width: 2),
                //     borderRadius: BorderRadius.all(Radius.circular(10))),
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
                                  widget.database.updateDoc(
                                      widget.doc,
                                      (snapshot) =>
                                          {'likes': snapshot['likes'] + 1});
                                },
                                child: Icon(Icons.thumb_up)),
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
