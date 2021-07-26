import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Database {
  static Database _database;
  static Future<Database> getInstance() async {
    if (_database == null) {
      _database = Database._();
    }
    return _database;
  }

  Database._();

  dynamic getCollection(String name, String sortBy) {
    if (!isConnected()) return false;
    return FirebaseFirestore.instance
        .collection(name)
        .orderBy(sortBy, descending: true)
        .snapshots();
  }

  dynamic getFieldOf(dynamic doc, int index, String fieldName) {
    return doc.data.docs[index][fieldName];
  }

  Future<Map<String, dynamic>> getCurrentUser(String username) async {
    DocumentSnapshot user = await FirebaseFirestore.instance
        .collection('Users')
        .doc(username)
        .get();
    double popularity = await _getPopulariy(username);
    return {
      'firstname': user['firstname'],
      'lastname': user['lastname'],
      'postcount': user['postcount'],
      'likecount': user['likecount'],
      'username': user['username'],
      'popularity': popularity
    };
  }

  Future<bool> deletePost(String username, DocumentReference doc,
      {ispost = false}) async {
    // delete likecount from user
    if (ispost) {
      await FirebaseFirestore.instance.runTransaction((transaction) async {
        DocumentSnapshot user = await transaction
            .get(FirebaseFirestore.instance.collection('Users').doc(username));
        DocumentSnapshot post = await transaction.get(doc);
        transaction.update(user.reference, {
          'postcount': user.get('postcount') - 1,
          'likecount': user.get('likecount') - post.get('likes')
        });
      });
    }
    bool returnbool = false;
    try {
      await doc.delete();
      returnbool = true;
    } catch (e) {
      returnbool = false;
    }
    return returnbool;
  }

  Future<String> deleteAccount(String username, String password) async {
    String error;
    try {
      await FirebaseAuth.instance.currentUser
          .reauthenticateWithCredential(EmailAuthProvider.credential(
              email: FirebaseAuth.instance.currentUser.email,
              password: password))
          .then((value) async {
        try {
          if (!await _deleteDataOf(username)) {
            error = 'Couldn\'t delete account data';
            return;
          }
          await FirebaseAuth.instance.currentUser.delete();
        } on FirebaseAuthException {
          error = 'Please sign in again to delete your account!';
        }
      });
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'user-mismatch':
        case 'user-not-found':
        case 'invalid-credential':
        case 'invalid-email':
          error = 'Error while requesting for user credentials';
          break;
        case 'wrong-password':
          error = 'The password is incorrect';
          break;
        default:
          error = 'Unknown Error has occured!';
      }
    }
    return error;
  }

  Future<bool> _deleteDataOf(String username) async {
    bool returnbool = false;
    // delete all posts by $username
    try {
      QuerySnapshot posts =
          await FirebaseFirestore.instance.collection('Thoughts').get();
      posts.docs.forEach((thought) async {
        if (thought.get('Author') == username)
          await thought.reference.delete();
        else {
          // delete comments in this post
          QuerySnapshot comments = await FirebaseFirestore.instance
              .collection('Thoughts')
              .doc(thought.id)
              .collection('Comments')
              .get();
          comments.docs.forEach((comment) async {
            if (comment.get('Author') == username)
              comment.reference.delete();
            else {
              // delete replies in this comment
              QuerySnapshot replies = await FirebaseFirestore.instance
                  .collection('Thoughts')
                  .doc(thought.id)
                  .collection('Comments')
                  .doc(comment.id)
                  .collection('Comments')
                  .get();
              replies.docs.forEach((reply) {
                if (reply.get('Author') == username) reply.reference.delete();
              });
            }
          });
        }
      });
      // delete user document of $username

      await FirebaseFirestore.instance
          .collection('Users')
          .doc(username)
          .delete();
      returnbool = true;
    } catch (e) {
      return false;
    }
    return returnbool;
  }

  Future<String> updatePassword(String newPassword, String oldPassword) async {
    String error;
    try {
      await FirebaseAuth.instance.currentUser
          .reauthenticateWithCredential(EmailAuthProvider.credential(
              email: FirebaseAuth.instance.currentUser.email,
              password: oldPassword))
          .then((value) {
        try {
          FirebaseAuth.instance.currentUser.updatePassword(newPassword);
        } on FirebaseAuthException catch (e) {
          switch (e.code) {
            case 'weak-password':
              error = 'Your password is very weak!';
              break;
            default:
              error = 'Please sign in again to update your password';
          }
        }
      });
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'user-mismatch':
        case 'user-not-found':
        case 'invalid-credential':
        case 'invalid-email':
          error = 'Error while requesting for user credentials';
          break;
        case 'wrong-password':
          error = 'Old password is incorrect';
          break;
        default:
          error = 'Unknown Error has occured!';
      }
    }
    return error;
  }

  Future<bool> updateProfile(
      String firstName, String lastName, String userName) async {
    bool returnbool = false;
    await FirebaseFirestore.instance.runTransaction((transaction) async {
      try {
        transaction.update(
            FirebaseFirestore.instance.collection('Users').doc(userName),
            {'firstname': firstName, 'lastname': lastName});
        returnbool = true;
      } catch (e) {
        returnbool = false;
      }
    });
    return returnbool;
  }

  // static updateDocument(DocumentSnapshot doc,Function updater){
  //   FirebaseFirestore.instance.runTransaction((transaction) async {
  //     DocumentSnapshot freshSnapshot = await transaction.get(doc.reference);
  //     transaction.update(freshSnapshot.reference, updater(freshSnapshot));
  //   });
  // }
  Future<double> _getPopulariy(String username) async {
    QuerySnapshot users =
        await FirebaseFirestore.instance.collection('Users').get();
    DocumentSnapshot user = await FirebaseFirestore.instance
        .collection('Users')
        .doc(username)
        .get();
    double usersCount = users.docs.length + 1.0;
    double rank = 1;
    users.docs.forEach((element) {
      if (element.id != user.id) if (element.get('likecount') >
          user.get('likecount')) rank++;
    });

    if (rank < usersCount / 100 * 1)
      return 0.01;
    else if (rank / usersCount <= usersCount / 100 * 10)
      return 0.1;
    else if (rank / usersCount <= usersCount / 100 * 30)
      return 0.3;
    else if (rank / usersCount <= usersCount / 100 * 50)
      return 0.5;
    else if (rank / usersCount <= usersCount / 100 * 90)
      return 0.9;
    else
      return 1;
  }

  Future<bool> likeComment(DocumentReference doc, String username) async {
    bool returnbool = false;
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
        'date': Timestamp.fromDate(DateTime.now().toLocal()),
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
