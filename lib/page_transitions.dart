import 'package:flutter/material.dart';

class BottomUpTransitionPageRoute extends PageRouteBuilder {
  BottomUpTransitionPageRoute({
    @required Widget Function(BuildContext) builder,
    RouteSettings settings,
  }) : super(
          pageBuilder: (context, animation, secondaryAnimation) =>
              builder(context),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            var begin = Offset(0.0, 1.0);
            var end = Offset.zero;
            var curve = Curves.ease;

            var tween =
                Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

            return SlideTransition(
              position: animation.drive(tween),
              child: child,
            );
          },
          settings: settings,
        );
}
