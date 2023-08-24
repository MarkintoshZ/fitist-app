import 'package:fitist/routes.dart';
import 'package:flutter/material.dart';

class UserProfileClickable extends StatelessWidget {
  final String uid;
  final Widget child;

  const UserProfileClickable(
      {Key key, @required this.uid, @required this.child})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => Navigator.pushNamed(context, PROFILE_PAGE, arguments: uid),
      child: child,
    );
  }
}
