import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:fitist/firebase_wrapper.dart';
import 'package:fitist/router.dart' as router;
import 'package:fitist/theme.dart';
import 'package:fitist/views/landing.dart';

void main() => runApp(App());

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: FirebaseWrapper(
        child: MaterialApp(
          title: 'Fitist',
          theme: themeData,
          routes: {
            '/': (_) => _isAuthenticated() ? router.Router() : Landing(),
            '/landing': (_) => Landing(),
            '/home': (_) => router.Router(),
          },
        ),
      ),
      onTap: () => FocusScope.of(context).requestFocus(new FocusNode()),
    );
  }

  bool _isAuthenticated() {
    final user = FirebaseAuth.instance.currentUser;
    return (user != null && user.emailVerified);
  }
}
