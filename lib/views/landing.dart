import 'package:fitist/views/login_page/email_verification_view.dart';
import 'package:fitist/views/login_page/log_in_view.dart';
import 'package:fitist/views/login_page/set_profile_pic_view.dart';
import 'package:fitist/views/login_page/sign_up_view.dart';
import 'package:fitist/views/login_page/landing_page.dart';
import 'package:flutter/material.dart';

const LANDING_PAGE = 'landing';
const SIGN_UP_PAGE = 'sign_up';
const LOGIN_PAGE = 'login';
const EMAIL_VERIFICATION_PAGE = 'verify-email';
const SET_PROFILE_PICTURE_PAGE = 'profile';

class Landing extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Navigator(
      initialRoute: LANDING_PAGE,
      onGenerateRoute: (settings) {
        Widget page;
        switch (settings.name) {
          case LANDING_PAGE:
            page = LandingPage();
            break;
          case SIGN_UP_PAGE:
            page = SignUpView();
            break;
          case LOGIN_PAGE:
            page = LogInView(goToHome: () => _goToHome(context));
            break;
          case EMAIL_VERIFICATION_PAGE:
            page = EmailVerificationPage();
            break;
          case SET_PROFILE_PICTURE_PAGE:
            page = SetProfilePic(goToHome: () => _goToHome(context));
            break;
          default:
            throw Exception('Invalid route name ${settings.name}');
        }
        return MaterialPageRoute(builder: (_) => page);
      },
    );
  }

  void _goToHome(context) {
    Navigator.pushReplacementNamed(context, '/home');
  }
}
