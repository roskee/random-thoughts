import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ThoughtListItem extends StatefulWidget{
  final dynamic doc;
  final IconButton iconButton;
  final Function onTap;
  ThoughtListItem(this.doc,this.iconButton,this.onTap);
  _ThoughtListItemState createState() => _ThoughtListItemState();
}
class _ThoughtListItemState extends State<ThoughtListItem>{
  String parseDateTime(DateTime dateTime){
    return 'DateTime';
  }
  Widget build(BuildContext context){
    return Card(
                      child: ListTile(
                    isThreeLine: true,
                    title: Row(
                      children:[Text(
                      widget.doc['Author'],
                      style: TextStyle(
                        fontWeight: FontWeight.w600
                      ),
                    ),
                    VerticalDivider(),
                    Text(parseDateTime(widget.doc['date'].toDate()),style: TextStyle(
                      fontSize: 12,
                      letterSpacing: 2,
                      fontWeight: FontWeight.w400,
                      fontStyle: FontStyle.italic
                    ),)
                      ]),
                    subtitle: Text(
                      widget.doc['content'],
                      overflow: TextOverflow.fade,
                      softWrap: true,
                      maxLines: 3,
                    ), //snapshot.data.docs[index]['content'],
                    trailing: Stack(alignment: Alignment.center, children: [
                      widget.iconButton,
                      Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Text('${widget.doc['likes']}')
                          ])
                    ]),
                    onTap: widget.onTap,
                  ));
  }
}