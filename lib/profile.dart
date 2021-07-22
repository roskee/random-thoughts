import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:random_thoughts/database.dart';
import 'package:random_thoughts/user.dart';

class Profile extends StatefulWidget{
  final UserInstance _user;
  final Database _database;
  Profile(this._user,this._database){
  }
  _ProfileState createState()=>_ProfileState();
}
class _ProfileState extends State<Profile>{
  Map<String,dynamic> user;
  void initState(){
    super.initState();
    widget._database.getCurrentUser(widget._user.username).then((value) => setState((){user=value;}));
  }
  Widget build(BuildContext context)=>Material(
    child: Card(
      elevation: 10,
      child:Column(
      children: [
        Image.asset('assets/images/random_thoughts_logo.jpg',fit: BoxFit.fitWidth,), // user image instead
        Divider(),
        Card(
          elevation: 10,
          child:Column(
            children:[
        (user==null)?Text(widget._user.username,style: TextStyle(fontSize: 20),):
        Text('${widget._user.username} (${user['firstname']} ${user['lastname']})',style: TextStyle(fontSize: 20),),
        ListTile(title: Text('Total likes '),trailing: (user==null)?SizedBox(width: 30,child: LinearProgressIndicator()):Text('${user['likecount']}'),),
        ListTile(title: Text('Total Posts'),trailing: (user==null)?SizedBox(width: 30,child: LinearProgressIndicator()):Text('${user['postcount']}'),)
            ])),
            Card(
              elevation: 10,
              child: Column(
                children: [
                  Text('Account options',style: TextStyle(fontSize: 20),),
                  ListTile(title: Text('Update Profile'),onTap: (){},),
                  ListTile(title: Text('Delete Account',style: TextStyle(color: Colors.red),),onTap: (){},)
                ],
              ),
            )
      ],
    )),
  );
}