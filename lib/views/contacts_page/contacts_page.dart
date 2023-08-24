import 'package:fitist/model/user_profile.dart';
import 'package:fitist/providers/chat.dart';
import 'package:fitist/routes.dart';
import 'package:fitist/services/user_profile_service.dart';
import 'package:fitist/views/widgets/user_avatar.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ContactsPage extends StatelessWidget {
  const ContactsPage({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            icon: Icon(
              Icons.add,
              semanticLabel: "Add Friend",
            ),
            onPressed: () {
              Navigator.pushNamed(context, ADD_FRIENDS_PAGE);
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                child: Text(
                  'Messages',
                  style: Theme.of(context).textTheme.headline2,
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 5),
                child: FutureBuilder<List<Message>>(
                  initialData: [],
                  future: context.read<ChatNotifier>().retrieveRecentContacts(),
                  builder: (context, snap) {
                    final messages = snap.data;
                    return ListView.separated(
                      shrinkWrap: true,
                      itemCount: messages.length,
                      separatorBuilder: (_, __) => SizedBox(height: 15),
                      itemBuilder: (context, i) {
                        return FutureBuilder<UserProfileModel>(
                          initialData: UserProfileModel.initData,
                          future: UserProfileService.get(messages[i].uid),
                          builder: (context, snap) {
                            return Container(
                              margin: const EdgeInsets.symmetric(
                                  vertical: 10, horizontal: 10),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20.0),
                                boxShadow: [
                                  BoxShadow(
                                    blurRadius: 15,
                                    color: Theme.of(context).shadowColor,
                                  ),
                                ],
                                color: Colors.white,
                              ),
                              child: ListTile(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20.0),
                                ),
                                leading: SizedBox(
                                  width: 64,
                                  child: Center(
                                    child: UserAvatar(
                                      uid: messages[i].uid,
                                      srcImgSize: 64,
                                    ),
                                  ),
                                ),
                                title: Text(
                                  snap.data?.displayName ?? '',
                                  style: Theme.of(context).textTheme.bodyText1,
                                ),
                                onTap: () {
                                  // go to chat page with argument of friend uid
                                  Navigator.pushNamed(context, CHAT_PAGE,
                                      arguments: messages[i].uid);
                                },
                                contentPadding: const EdgeInsets.symmetric(
                                  vertical: 15,
                                  horizontal: 14,
                                ),
                              ),
                            );
                          },
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
