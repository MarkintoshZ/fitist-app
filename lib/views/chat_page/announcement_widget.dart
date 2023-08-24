import 'package:flutter/material.dart';
import 'package:fitist/providers/chat.dart';

class AnnouncementWidget extends StatelessWidget {
  final Message message;

  const AnnouncementWidget({@required Key key, @required this.message})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Text(
          message.content,
          style: Theme.of(context).textTheme.caption,
        ),
      ),
    );
  }
}
