import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class CommentCard extends StatelessWidget {
  final bool last;
  CommentCard({this.last = false});
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
                  child: Text('Martha Jhonson')),
              VerticalDivider(),
              Text('Today - 06:12AM')
            ],
          ),
          Divider(),
          Container(
            padding: EdgeInsets.all(8),
            child: Text(
              'How did you come up with such a dramatic concept, dear?',
            ),
          ),
          (last)
              ? Row(
                  children: [
                    VerticalDivider(),
                    InkWell(
                        highlightColor: Colors.transparent,
                        onTap: () {},
                        child: Icon(Icons.thumb_up)),
                    Text('10'),
                    VerticalDivider(),
                  ],
                )
              : ExpansionTile(
                  childrenPadding: EdgeInsets.all(5),
                  title: Row(
                    children: [
                      InkWell(
                          highlightColor: Colors.transparent,
                          onTap: () {},
                          child: Icon(Icons.thumb_up)),
                      Text('10'),
                      VerticalDivider(),
                      Icon(Icons.comment),
                      Text('10'),
                    ],
                  ),
                  children: [
                    CommentCard(
                      last: true,
                    )
                  ],
                )
        ])),
      );
}
