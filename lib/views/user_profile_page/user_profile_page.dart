import 'package:firebase_auth/firebase_auth.dart';
import 'package:fitist/model/user_profile.dart';
import 'package:fitist/providers/my_user_profile.dart';
import 'package:fitist/routes.dart';
import 'package:fitist/services/firestore.dart';
import 'package:fitist/services/user_profile_service.dart';
import 'package:fitist/views/widgets/user_avatar.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class UserProfilePage extends StatefulWidget {
  final String uid;

  const UserProfilePage({Key key, @required this.uid}) : super(key: key);

  @override
  _UserProfilePageState createState() => _UserProfilePageState();
}

class _UserProfilePageState extends State<UserProfilePage> {
  bool friendRequestSent = false;

  @override
  Widget build(BuildContext context) {
    final bool isMe = widget.uid == FirebaseAuth.instance.currentUser.uid;
    final bool isMyFriend = context
        .watch<MyUserProfileProvider>()
        .user
        ?.friends
        ?.contains(widget.uid);
    final screenSize = MediaQuery
        .of(context)
        .size;
    return Scaffold(
      appBar: AppBar(),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: EdgeInsets.only(
                  top: screenSize.height / 15,
                  bottom: screenSize.height / 20,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    UserAvatar(
                      srcImgSize: 256,
                      size: screenSize.width / 3,
                      uid: widget.uid,
                    ),
                    SizedBox(
                      height: screenSize.width / 36,
                    ),
                    FutureBuilder<UserProfileModel>(
                      initialData: UserProfileModel.initData,
                      future: UserProfileService.get(widget.uid),
                      builder: (context, snapshot) {
                        return Text(
                          snapshot.data.displayName,
                          style: Theme
                              .of(context)
                              .textTheme
                              .headline2,
                        );
                      },
                    ),
                  ],
                ),
              ),
              // add friend/chat button
              if (isMyFriend)
                ElevatedButton(
                  onPressed: () =>
                      Navigator.of(context)
                          .popAndPushNamed(CHAT_PAGE, arguments: widget.uid),
                  child: Text('Chat'),
                )
              else
                if (!isMe)
                  ElevatedButton(
                    onPressed: friendRequestSent ? null : addFriend,
                    child: Text(friendRequestSent
                        ? 'Friend Request Send'
                        : 'Add Friend'),
                  ),
            ],
          ),
        ),
      ),
    );
  }

  void addFriend() async {
    final myUid = FirebaseAuth.instance.currentUser.uid;
    try {
      await createFriendRequest(
          uidFrom: myUid, uidTo: widget.uid);
      setState(() {
        friendRequestSent = true;
      });
    } catch (error) {
      print('Error sending friend request: $error');
    }
  }
}
