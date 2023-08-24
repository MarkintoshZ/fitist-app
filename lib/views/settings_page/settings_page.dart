import 'package:fitist/providers/chat.dart';
import 'package:fitist/views/widgets/menu_tile.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fitist/views/settings_page/user_profile_view.dart';

final divider = Divider(
  color: Colors.black,
  height: 1,
);

class SettingsPage extends StatelessWidget {
  final onSignOut;
  SettingsPage({Key key, @required this.onSignOut}) : super(key: key);

  void logoutButtonCallback(context) async {
    final data = await showCupertinoModalPopup(
        context: context,
        builder: (context) {
          return CupertinoActionSheet(
            title: Text('Logout'),
            message: Text('Are you sure you want to logout?'),
            actions: <Widget>[
              CupertinoActionSheetAction(
                child: Text(
                  'Logout',
                  style: TextStyle(
                    color: Colors.red,
                  ),
                ),
                onPressed: () {
                  auth.signOut();
                  Navigator.pop(context);
                  onSignOut();
                },
              )
            ],
            cancelButton: CupertinoActionSheetAction(
              child: Text('Cancel'),
              isDefaultAction: true,
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          );
        });
    if (data == 'logout') {
      print('logout');
      // AuthPage.of(context).logoutCallback();
    }
  }

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: <Widget>[
        UserProfileView(),
        SliverList(
          delegate: SliverChildListDelegate([
            // settings button
            MenuTile(
              leading: const Icon(Icons.settings),
              title: const Text('Settings'),
              // onTap: () => Navigator.pushNamed(context, 'settings_page'),
            ),
            divider,
            // clear cache
            MenuTile(
              leading: const Icon(Icons.delete),
              title: const Text('Clear Cache'),
              onTap: () => PaintingBinding.instance.imageCache.clear(),
            ),
            // clear chat db
            MenuTile(
              leading: const Icon(Icons.chat_bubble_outline),
              title: const Text('Clear chat'),
              onTap: () => ChatHistoryDB.empty(),
            ),
            divider,
            // logout button
            MenuTile(
              leading: const Icon(
                Icons.exit_to_app,
                color: Colors.red,
              ),
              title: const Text(
                'Logout',
                style: TextStyle(color: Colors.red),
              ),
              onTap: () => logoutButtonCallback(context),
            )
          ]),
        )
      ],
    );
  }
}
