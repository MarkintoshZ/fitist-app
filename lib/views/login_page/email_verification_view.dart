import 'package:fitist/views/landing.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

final auth = FirebaseAuth.instance;

class EmailVerificationPage extends StatefulWidget {
  @override
  _EmailVerificationPageState createState() => _EmailVerificationPageState();
}

class _EmailVerificationPageState extends State<EmailVerificationPage> {
  static const padding = const EdgeInsets.symmetric(vertical: 12);
  bool displayErrorMsg = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(height: MediaQuery.of(context).size.height * 0.25),
              Center(
                child: Text(
                  "Verify Your Email",
                  style: Theme.of(context).textTheme.headline1,
                ),
              ),
              SizedBox(height: MediaQuery.of(context).size.height * 0.01),
              Center(
                child: Text(
                  'A verification email has been sent to',
                  style: Theme.of(context).textTheme.subtitle1,
                ),
              ),
              Center(
                child: Text(
                  auth.currentUser.email,
                  style: Theme.of(context).textTheme.subtitle1,
                ),
              ),
              SizedBox(height: MediaQuery.of(context).size.height * 0.01),
              if (displayErrorMsg)
                Center(
                  child: Text(
                    "Email not verified",
                    style: Theme.of(context)
                        .textTheme
                        .headline3
                        .copyWith(color: Colors.red),
                  ),
                ),
              Padding(
                padding: padding,
                child: ElevatedButton(
                  child: Text(
                    'Continue',
                  ),
                  onPressed: () async {
                    var user = auth.currentUser;
                    if (user != null && user.uid != null) {
                      await user.reload();
                      await user.getIdToken(true);
                      user = auth.currentUser;
                      if (!user.emailVerified) {
                        setState(() {
                          displayErrorMsg = true;
                        });
                        return;
                      }
                    }

                    if (!FirebaseAuth.instance.currentUser.emailVerified) {
                      setState(() {
                        displayErrorMsg = true;
                      });
                    } else {
                      Navigator.pushNamed(context, SET_PROFILE_PICTURE_PAGE);
                    }
                  },
                ),
              ),
              Padding(
                padding: padding,
                child: OutlinedButton(
                  child: Text('Resend Email'),
                  onPressed: () {
                    FirebaseAuth.instance.currentUser.sendEmailVerification();
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text('Email sent. Check your inbox'),
                      duration: Duration(seconds: 2),
                    ));
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
