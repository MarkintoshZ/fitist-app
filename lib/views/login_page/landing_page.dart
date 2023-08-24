import 'package:fitist/views/landing.dart';
import 'package:flutter/material.dart';

class LandingPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Image.asset(
                    "assets/images/welcome_graphic.png",
                  ),
                ),
                Center(
                  child: Text(
                    "FITIST",
                    style: Theme.of(context).textTheme.headline1,
                  ),
                ),
                Center(
                  child: Text(
                    "Find Your Fit @Babson",
                    style: Theme.of(context).textTheme.subtitle1,
                  ),
                ),
                SizedBox(height: MediaQuery.of(context).size.height * 0.05),
                ElevatedButton(
                  child: Text("Sign Up"),
                  onPressed: () => Navigator.pushNamed(context, SIGN_UP_PAGE),
                ),
                SizedBox(height: MediaQuery.of(context).size.height * 0.02),
                OutlinedButton(
                  child: Text("Log In"),
                  onPressed: () => Navigator.pushNamed(context, LOGIN_PAGE),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
