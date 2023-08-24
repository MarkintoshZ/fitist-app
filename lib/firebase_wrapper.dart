import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

class FirebaseWrapper extends StatelessWidget {
  final Widget child;

  FirebaseWrapper({this.child});

  final Future<FirebaseApp> _initialization = Firebase.initializeApp();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _initialization,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          print('Firebase init error');
          // TODO: add error screen if Firebase failed to initialize
          return _buildWaitScreen(context);
        }

        if (snapshot.connectionState == ConnectionState.done) {
          print('Firebase init successful');
          return child;
        }

        print('Firebase init waiting');
        return _buildWaitScreen(context);
      },
    );
  }

  Widget _buildWaitScreen(BuildContext context) {
    return Container(
      child: Center(child: CircularProgressIndicator()),
      color: Theme.of(context).canvasColor,
    );
  }
}
