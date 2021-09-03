import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sns_login/home.dart';

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: Firebase.initializeApp(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(
            child: Text("Firebase load fail."),
          );
        }
        if (snapshot.connectionState == ConnectionState.done) {
          print("Firebase load.");
          return Home();
        }
        return CircularProgressIndicator();
      },
    );
  }
}
