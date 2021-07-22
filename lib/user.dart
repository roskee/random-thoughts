import 'package:firebase_auth/firebase_auth.dart';

class UserInstance {
  bool notLoggedin = true;
  String username = '';
  String firstName = '';
  String lastName = '';
  String email = '';
  String photoUri = '';
  bool isVerified = false;
  static UserInstance _user;
  static UserInstance getInstance(FirebaseAuth auth) {
    if (_user == null) _user = UserInstance._fromAuth(auth);
    return _user;
  }

  UserInstance._fromAuth(FirebaseAuth auth) {
    _initUser(auth);
  }
  void _initUser(FirebaseAuth auth) {
    if (auth.currentUser == null) {
      notLoggedin = true;
      return;
    }
    notLoggedin = false;
    // firstName = auth.currentUser.displayName
    //     .substring(0, auth.currentUser.displayName.indexOf(' '));
    // lastName = auth.currentUser.displayName
    //     .substring(auth.currentUser.displayName.indexOf(' ') + 1);
    username = auth.currentUser.displayName;
    email = auth.currentUser.email;
    photoUri = auth.currentUser.photoURL;
    isVerified = auth.currentUser.emailVerified;
  }

  void reload(FirebaseAuth auth, Function callback) async {
    if (auth.currentUser != null)
      await auth.currentUser.reload().then((value) {
        _initUser(auth);
        callback();
      });
  }

  void signout(FirebaseAuth auth, Function callback) {
    if (_user == null) return;
    _user.notLoggedin = true;
    callback();
  }
}
