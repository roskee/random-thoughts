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
  void initState() {
    super.initState();
    //FirebaseFirestore.instance.collection('Thoughts').doc(widget.doc.id).collection('Comments').get().then((value) => docs = value);
  }

  String parseDatetime(DateTime dateTime) {
    DateTime now = DateTime.now();
    String time = '';
    if (now.year == dateTime.year) {
      if (now.month == dateTime.month) {
        if (now.day == dateTime.day)
          time = 'Today - ';
        else if (now.day == dateTime.day + 1)
          time = 'Yesterday - ';
        else if (dateTime.day > now.day - 7)
          time = '${_parseDay(dateTime.weekday)} - ';
        else
          time = '${dateTime.day}-${_parseMonth(dateTime.month)} - ';
      } else
        time = '${dateTime.day}-${_parseMonth(dateTime.month)} - ';
    } else
      time =
          '${dateTime.day}-${_parseMonth(dateTime.month)}-${dateTime.year} - ';
    String min =
        (dateTime.minute < 10) ? '0${dateTime.minute}' : '${dateTime.minute}';
    time = time +
        '${(dateTime.hour == 0) ? '12:${min}AM' : (dateTime.hour < 10) ? '0${dateTime.hour}:${min}AM' : (dateTime.hour < 12) ? '${dateTime.hour}:${min}AM' : '${dateTime.hour - 12}:${min}PM'}';
    return time;
  }

  String _parseMonth(int month) {
    switch (month) {
      case 1:
        return 'January';
        break;
      case 2:
        return 'February';
        break;
      case 3:
        return 'March';
        break;
      case 4:
        return 'April';
        break;
      case 5:
        return 'May';
        break;
      case 6:
        return 'June';
        break;
      case 7:
        return 'July';
        break;
      case 8:
        return 'August';
        break;
      case 9:
        return 'September';
        break;
      case 10:
        return 'October';
        break;
      case 11:
        return 'November';
        break;
      case 12:
        return 'December';
        break;
      default:
        return 'NaN';
    }
  }

  String _parseDay(int day) {
    switch (day) {
      case 1:
        return 'Monday';
        break;
      case 2:
        return 'Tuesday';
        break;
      case 3:
        return 'Wednesday';
        break;
      case 4:
        return 'Thursday';
        break;
      case 5:
        return 'Friday';
        break;
      case 6:
        return 'Saturday';
        break;
      case 7:
        return 'Sunday';
        break;
      default:
        return 'Nan';
    }
  }

  Widget build(BuildContext context) {
    return InkWell(
        onTap: () {
          // show modal sheet
          showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              backgroundColor: Colors.transparent,
              barrierColor: Colors.transparent,
              builder: (context) => Container(
                    color: Colors.transparent,
                    child: Stack(
                      alignment: Alignment.bottomRight,
                      children: [
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
                              child: ListView.builder(
                                  itemCount: 10,
                                  itemBuilder: (context, index) =>
                                      CommentCard())),
                        ]),
                        Card(
                            elevation: 10,
                            child: Container(
                                color: Colors.transparent,
                                child: TextField(
                                  decoration: InputDecoration(
                                      hintText: 'Type your commet'),
                                  maxLines: 3,
                                  maxLength: 150,
                                ))),
                        IconButton(icon: Icon(Icons.send), onPressed: () {})
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
                      child: Text(parseDatetime(widget.doc['date'].toDate())),
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
