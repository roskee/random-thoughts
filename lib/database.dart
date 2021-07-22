import 'package:cloud_firestore/cloud_firestore.dart';

class Database {
  static Database _database;
  static Future<Database> getInstance() async {
    if (_database == null) {
      _database = Database._();
    }
    return _database;
  }

  Database._();

  dynamic getCollection(String name) {
    if (!isConnected()) return false;
    return FirebaseFirestore.instance.collection(name).snapshots();
  }

  dynamic getFieldOf(dynamic doc, int index, String fieldName) {
    return doc.data.docs[index][fieldName];
  }
  Future<Map<String,dynamic>> getCurrentUser(String username) async{
    DocumentSnapshot user = await FirebaseFirestore.instance.collection('Users').doc(username).get();
    return {
      'firstname': user['firstname'],
      'lastname':user['lastname'],
      'postcount':user['postcount'],
      'likecount':user['likecount'],
      'username':user['username']
    };
  }
  // static updateDocument(DocumentSnapshot doc,Function updater){
  //   FirebaseFirestore.instance.runTransaction((transaction) async {
  //     DocumentSnapshot freshSnapshot = await transaction.get(doc.reference);
  //     transaction.update(freshSnapshot.reference, updater(freshSnapshot));
  //   });
  // }
  Future<bool> likeComment(DocumentReference doc, String username) async{
    bool returnbool=false;
    await FirebaseFirestore.instance.runTransaction((transaction) async {
      DocumentSnapshot snapshot = await transaction.get(doc);
      if (snapshot['likers'].contains(username)) {
        // unlike
        List likers = snapshot['likers'];
        likers.remove(username);
        transaction.update(snapshot.reference, {
          'likes': snapshot['likes'] - 1,
          'likers': likers // remove username
        });
        returnbool = false;
      } else {
        List likers = snapshot['likers'];
        likers.add(username);
        transaction.update(snapshot.reference, {
          'likes': snapshot['likes'] + 1,
          'likers': likers // add username
        });
        returnbool = true;
      }
    });
    return returnbool;
  }

  Future<bool> likePost(DocumentReference doc, String username) async {
    bool returnbool = false;
    await FirebaseFirestore.instance.runTransaction((transaction) async {
      DocumentSnapshot snapshot =
          await transaction.get(doc); // document to be liked
      DocumentSnapshot usersnapshot = await transaction.get(FirebaseFirestore
          .instance
          .collection('Users')
          .doc(snapshot['Author'])); // the user to accept the like
      if (snapshot['likers'].contains(username)) {
        // unlike
        List likers = snapshot['likers'];
        likers.remove(username);
        transaction.update(snapshot.reference,
            {'likes': snapshot['likes'] - 1, 'likers': likers});
        transaction.update(usersnapshot.reference,
            {'likecount': usersnapshot['likecount'] - 1});
        returnbool = false;
      } else {
        List likers = snapshot['likers'];
        likers.add(username);
        transaction.update(snapshot.reference, {
          'likes': snapshot['likes'] + 1,
          'likers': likers // add username
        });
        transaction.update(usersnapshot.reference,
            {'likecount': usersnapshot['likecount'] + 1});
        returnbool = true;
      }
    });
    return returnbool;
  }

  Future<bool> postElement(
      DocumentReference doc, String comment, String author, bool count) async {
    FirebaseFirestore.instance.runTransaction((transaction) async {
      DocumentSnapshot snapshot = await transaction.get(doc);
      if (count) {
        DocumentSnapshot usersnapshot = await transaction
            .get(FirebaseFirestore.instance.collection('Users').doc(author));
        transaction.update(usersnapshot.reference,
            {'postcount': usersnapshot['postcount'] + 1});
      }
      transaction.set(snapshot.reference, {
        'Author': author,
        'content': comment,
        'date': Timestamp.now(),
        'likes': 0,
        'likers': []
      });
    });
    return true;
  }

  static String parseDatetime(DateTime dateTime) {
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

  static String _parseMonth(int month) {
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

  static String _parseDay(int day) {
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

  bool isConnected() {
    return true;
  }
}
