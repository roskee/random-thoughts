import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class Verification extends StatelessWidget {
  final bool isPhone;
  Verification(this.isPhone);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Card(
        child: Column(
          children: [
            Image.asset('assets/images/random_thoughts_logo3.png'),
            Divider(),
            Divider(),
            Card(
                child: isPhone
                    ? Column(
                        children: [
                          Text(
                              'Insert the code that has been sent to your phone number'),
                          SizedBox(
                            width: 150,
                            child: TextField(
                              onChanged: (value) {
                                // if value is OK then proceed
                              },
                              maxLength: 10,
                              keyboardType: TextInputType.number,
                            ),
                          ),
                          Text('You didn\'t receive any code?',
                              style: TextStyle(color: Colors.red)),
                          TextButton(
                              onPressed: () {
                                // resend code
                              },
                              child: Text('Resend code')),
                          TextButton(
                              onPressed: () {
                                FirebaseAuth.instance.currentUser.reload();
                              },
                              child: Text('Refresh'))
                        ],
                      )
                    : Column(children: [
                        Text(
                            'Click the link sent to your email address. and reopen random thoughts'),
                        Text(
                          'You didn\'t recieve any link?',
                          style: TextStyle(
                            color: Colors.red,
                          ),
                        ),
                        TextButton(
                            onPressed: () {
                              FirebaseAuth.instance.currentUser
                                  .sendEmailVerification();
                            },
                            child: Text('Resend link')),
                        TextButton(
                            onPressed: () {
                              FirebaseAuth.instance.currentUser.reload();
                            },
                            child: Text('Refresh')),
                        TextButton(
                            onPressed: () {
                              FirebaseAuth.instance.signOut();
                            },
                            child: Text('Sign out'))
                      ]))
          ],
        ),
      ),
    );
  }
}
