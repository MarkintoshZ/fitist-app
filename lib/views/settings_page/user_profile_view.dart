import 'package:firebase_auth/firebase_auth.dart';
import 'package:fitist/providers/my_user_profile.dart';
import 'package:fitist/routes.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fitist/views/widgets/user_avatar.dart';
import 'package:flutter/rendering.dart';
import 'package:provider/provider.dart';

class UserProfileView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      flexibleSpace: FlexibleSpaceBar(
        background: Consumer<MyUserProfileProvider>(
          builder: (context, userModel, _) {
            final user = userModel.user;
            return Column(
              children: <Widget>[
                GestureDetector(
                  onTap: () {
                    return Navigator.pushNamed(
                        context, SET_PROFILE_PICTURE_PAGE);
                  },
                  child: Hero(
                    tag: 'profile_picture',
                    child: UserAvatar(
                      uid: FirebaseAuth.instance.currentUser.uid,
                      srcImgSize: 512,
                      size: MediaQuery.of(context).size.width * 0.5,
                      loading: user == null,
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(
                    top: MediaQuery.of(context).size.height * 0.01,
                    bottom: MediaQuery.of(context).size.height * 0.03,
                  ),
                  child: TextButton(
                    onPressed: () {
                      // TODO: change display name pop out route
                    },
                    child: Text(
                      user?.displayName ?? '',
                      style: Theme.of(context)
                          .textTheme
                          .headline1
                          .copyWith(fontWeight: FontWeight.w500),
                    ),
                  ),
                ),
              ],
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.end,
            );
          },
        ),
      ),
      expandedHeight: MediaQuery.of(context).size.width / 1.2,
      backgroundColor: Theme.of(context).canvasColor,
      elevation: 0.4,
      forceElevated: true,
    );
  }
}
