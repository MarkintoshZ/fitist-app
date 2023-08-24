import 'package:fitist/page_transitions.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:fitist/fcm.dart';
import 'package:fitist/providers/chat.dart';
import 'package:fitist/providers/friend_requests.dart';
import 'package:fitist/providers/map_data.dart';
import 'package:fitist/providers/my_avatar.dart';
import 'package:fitist/providers/my_user_profile.dart';
import 'package:fitist/routes.dart';
import 'package:fitist/views/chat_page/chat_page.dart';
import 'package:fitist/views/settings_page/set_profile_picture_page.dart';
import 'package:fitist/views/user_profile_page/user_profile_page.dart';
import 'package:fitist/views/main_interface.dart';
import 'package:fitist/views/add_friends_page/add_friends_page.dart';

class Router extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => FriendRequestsProvider()),
        ChangeNotifierProvider(create: (_) => MyUserProfileProvider()),
        ChangeNotifierProvider(create: (_) => ChatNotifier()),
        ChangeNotifierProvider(create: (_) => MapDataProvider()),
        ChangeNotifierProvider(create: (_) => MyAvatarProvider()),
      ],
      child: FCM(
        child: Navigator(
          initialRoute: MAIN_INTERFACE,
          // initialRoute: PROFILE_PAGE,
          onGenerateRoute: (RouteSettings settings) {
            WidgetBuilder builder;
            print('Routing to ${settings.name}');
            switch (settings.name) {
              case MAIN_INTERFACE:
                builder = (_) =>
                    MainInterface(onSignOut: () => _goToLanding(context));
                break;
              case ADD_FRIENDS_PAGE:
                builder = (_) => AddFriendsPage();
                break;
              case CHAT_PAGE:
                builder = (_) => ChatPage(uid: settings.arguments);
                break;
              case SET_PROFILE_PICTURE_PAGE:
                builder = (_) => const SetProfilePicturePage();
                return BottomUpTransitionPageRoute(
                    builder: builder, settings: settings);
                break;
              case PROFILE_PAGE:
                builder = (_) => UserProfilePage(uid: settings.arguments);
                return BottomUpTransitionPageRoute(
                    builder: builder, settings: settings);
                break;
              default:
                builder = (_) =>
                    MainInterface(onSignOut: () => _goToLanding(context));
            }
            return MaterialPageRoute(builder: builder, settings: settings);
          },
          observers: [
            HeroController(),
          ],
        ),
      ),
    );
  }

  void _goToLanding(context) {
    // TODO: fix ugly and unintuitive page transition animation
    Navigator.pushReplacementNamed(context, '/landing');
  }
}
