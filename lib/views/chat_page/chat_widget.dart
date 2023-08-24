import 'package:firebase_auth/firebase_auth.dart';
import 'package:fitist/providers/chat.dart';
import 'package:fitist/views/widgets/user_avatar.dart';
import 'package:fitist/views/widgets/user_profile_clickable.dart';
import 'package:flutter/material.dart';

class ChatWidget extends StatelessWidget {
  final Message message;

  const ChatWidget(
      {@required Key key, @required this.message})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isInbound = message.status == ChatStatus.Received;
    final alignment =
        isInbound ? MainAxisAlignment.start : MainAxisAlignment.end;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 6),
      child: Row(
        children: [
          Container(
            child: isInbound
                ? UserProfileClickable(
                    uid: message.uid,
                    child: UserAvatar(uid: message.uid, srcImgSize: 64))
                : null,
            width: 40,
            height: 40,
          ),
          _buildTextBubble(context, isInbound),
          Container(
            child: !isInbound
                ? UserAvatar(
                    uid: FirebaseAuth.instance.currentUser.uid, srcImgSize: 64)
                : null,
            width: 40,
            height: 40,
          ),
        ],
        mainAxisAlignment: alignment, // no idea why this works
        crossAxisAlignment: CrossAxisAlignment.start,
      ),
    );
  }

  Widget _buildTextBubble(context, isInbound) {
    final radius = isInbound
        ? BorderRadius.only(
            topLeft: Radius.circular(5.0),
            bottomLeft: Radius.circular(10.0),
            bottomRight: Radius.circular(5.0),
          )
        : BorderRadius.only(
            topRight: Radius.circular(5.0),
            bottomLeft: Radius.circular(5.0),
            bottomRight: Radius.circular(10.0),
          );
    final color = isInbound ? Color(0xff231f20) : Color(0XffE7E7E7);
    final textColor = isInbound ? Color(0xffffffff) : Color(0xff231F20);
    return Flexible(
      child: Container(
        decoration: BoxDecoration(
          borderRadius: radius,
          color: color,
        ),
        padding: EdgeInsets.all(10),
        margin: EdgeInsets.symmetric(horizontal: 10),
        child: Text(
          message.content,
          style: Theme.of(context).textTheme.headline4.copyWith(
                color: textColor,
                fontWeight: FontWeight.normal,
              ),
          softWrap: true,
        ),
      ),
    );
  }
}
