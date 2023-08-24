import 'package:firebase_auth/firebase_auth.dart';
import 'package:fitist/services/firestore.dart';
import 'package:flutter/material.dart';

final auth = FirebaseAuth.instance;

class LogoutTest extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Logged in"),
      ),
      body: Center(
        child: Column(
          children: [
            MaterialButton(
              onPressed: () {
                auth.signOut();
              },
              child: Text("Logout"),
            ),
            MaterialButton(
              onPressed: () {
                deleteUser(auth.currentUser.uid);
                auth.currentUser.delete();
              },
              child: Text("Delete User"),
              // auth.signOut();
            ),
          ],
        ),
      ),
    );
  }

}