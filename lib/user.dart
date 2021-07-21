import 'package:firebase_auth/firebase_auth.dart';

class UserInstance {
  bool notLoggedin;
  String firstName;
  String lastName;
  String email;
  String photoUri;
  bool isVerified;
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
    } else
      notLoggedin = false;
    firstName = auth.currentUser.displayName
        .substring(0, auth.currentUser.displayName.indexOf(' '));
    lastName = auth.currentUser.displayName
        .substring(auth.currentUser.displayName.indexOf(' ') + 1);
    email = auth.currentUser.email;
    photoUri = auth.currentUser.photoURL;
    isVerified = auth.currentUser.emailVerified;
  }

  void reload(FirebaseAuth auth) {
    auth.currentUser.reload().then((value) => {_initUser(auth)});
  }
}
