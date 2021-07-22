import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class About extends StatelessWidget {
  Widget build(BuildContext context) => Material(
        child: Card(
          child: ListView(
            children: [
              Image.asset(
                'assets/images/random_thoughts_logo.jpg',
                fit: BoxFit.fitWidth,
              ),
              Card(
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                    Text(
                        'This app was made by roskee for random users to post random things. For customer feedback or commercial requests you can use the following contact information.'),
                    Divider(),
                    Text(
                      'Email: randomthoughts@gmail.com',
                    ),
                    Divider(),
                    Text(
                      'By using this application you agree to the privacy policies described below.',
                      textAlign: TextAlign.center,
                    ),
                    Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                      TextButton(
                          onPressed: () {}, child: Text('Privacy Policy')),
                      TextButton(
                        onPressed: () {},
                        child: Text('Licenses and Terms'),
                      )
                    ]),
                  ]))
            ],
          ),
        ),
      );
}
