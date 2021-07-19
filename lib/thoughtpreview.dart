import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'commentcard.dart';

class ThoughtView extends StatefulWidget {
  final dynamic doc;
  ThoughtView(this.doc);
  _ThoughtViewState createState() => _ThoughtViewState();
}

class _ThoughtViewState extends State<ThoughtView> {
  Widget build(BuildContext context) {
    return InkWell(
        onTap: () {
          // show modal sheet
          showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              backgroundColor: Colors.transparent,
              barrierColor: Colors.transparent,
              builder: (context) => Card(
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
                            child: ListView.builder(
                                itemCount: 10,
                                itemBuilder: (context, index) => CommentCard()))
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
                        flex: 7,
                        child: InkWell(
                          highlightColor: Colors.transparent,
                          onTap: () {},
                          child: Text('Martha Jhonson'),
                        )),
                    VerticalDivider(),
                    Expanded(
                      flex: 5,
                      child: Text('Today - 12:30PM'),
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
                                onTap: () {},
                                child: Icon(Icons.thumb_up)),
                            VerticalDivider(),
                            Text('10'),
                          ],
                        ),
                      ),
                      Expanded(
                          flex: 2,
                          child: Row(
                            children: [
                              Icon(Icons.comment),
                              VerticalDivider(),
                              Text('100'),
                            ],
                          ))
                    ],
                  ),
                ]))));
  }
}
