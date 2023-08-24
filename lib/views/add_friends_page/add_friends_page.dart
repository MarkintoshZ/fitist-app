import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fitist/providers/my_user_profile.dart';
import 'package:fitist/routes.dart';
import 'package:fitist/utils/ref_data_pair.dart';
import 'package:fitist/views/widgets/user_profile_clickable.dart';
import 'package:provider/provider.dart';

import 'package:fitist/model/user_profile.dart';
import 'package:fitist/providers/friend_requests.dart';
import 'package:fitist/services/user_profile_service.dart';
import 'package:fitist/views/widgets/user_avatar.dart';
import 'package:flutter/material.dart';

final store = FirebaseFirestore.instance;

class AddFriendsPage extends StatelessWidget {
  final _textController = TextEditingController();
  final userProfileCache = Map<String, Future<UserProfileModel>>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add new friends'),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 15,
          vertical: 6,
        ),
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: TextField(
                  controller: _textController,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: const BorderRadius.all(
                        Radius.circular(10),
                      ),
                    ),
                    contentPadding: EdgeInsets.zero,
                    hintText: 'Add from username',
                    prefixIcon: Icon(Icons.search),
                  ),
                  autocorrect: false,
                ),
              ),
              Expanded(
                child: ValueListenableBuilder(
                  valueListenable: _textController,
                  builder: (context, TextEditingValue value, child) {
                    if (value.text.isEmpty) {
                      return buildFriendRequests(context);
                    } else {
                      return _buildSearchResults(context, value.text);
                    }
                  },
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget buildFriendRequests(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: StreamBuilder<List<RefDataPair<FriendRequestModel>>>(
        initialData: [],
        stream: Provider.of<FriendRequestsProvider>(context).stream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting)
            return Center(
              child: CircularProgressIndicator(),
            );
          final requests = snapshot.data;
          return ListView.separated(
            shrinkWrap: true,
            itemCount: requests.length,
            separatorBuilder: (_, i) => Divider(),
            itemBuilder: (context, index) {
              final docRef = requests[index].ref;
              final data = requests[index].data;
              final uidFrom = data.uidFrom;
              return FutureBuilder<UserProfileModel>(
                future: userProfileCache.putIfAbsent(
                  uidFrom,
                  () => UserProfileService.get(uidFrom),
                ),
                builder: (context, userSnapshot) {
                  if (userSnapshot.connectionState == ConnectionState.waiting)
                    return Container();
                  return ListTile(
                    leading: UserProfileClickable(
                      uid: data.uidFrom,
                      child: UserAvatar(
                        uid: data.uidFrom,
                        srcImgSize: 64,
                      ),
                    ),
                    title: Text(
                      userSnapshot.data.displayName,
                    ),
                    trailing: Builder(
                      builder: (context) {
                        final textStyle = Theme.of(context).textTheme.bodyText1;
                        // When two users send each other friend request before
                        // one add the other, one request will still be visible
                        // with waiting status after friend relationship is
                        // established. Showing those with status Accepted here
                        final friends =
                            context.read<MyUserProfileProvider>().user.friends;
                        switch (friends.contains(data.uidFrom)
                            ? FriendRequestStatus.Accepted
                            : data.status) {
                          case FriendRequestStatus.Accepted:
                            return _buildStatusText(context, 'Accepted');
                          case FriendRequestStatus.Expired:
                            return _buildStatusText(context, 'Expired');
                          case FriendRequestStatus.Rejected:
                            return _buildStatusText(context, 'Denied');
                          case FriendRequestStatus.Waiting:
                            return ElevatedButton(
                              onPressed: () =>
                                  Provider.of<FriendRequestsProvider>(context,
                                          listen: false)
                                      .accept(docRef),
                              child: Text(
                                'Accept',
                                style: textStyle.copyWith(
                                    color: Theme.of(context).canvasColor),
                              ),
                            );
                          default:
                            return null;
                        }
                      },
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildSearchResults(BuildContext context, String search) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 10),
      child: ListView(
        children: [
          ElevatedButton(
            child: Text('Search with username'),
            onPressed: () async {
              final snap = await store
                  .collection('/Users')
                  .where('username', isEqualTo: search)
                  .get();
              if (snap.docs.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Cannot find user with username $search'),
                  ),
                );
              } else {
                final uid = snap.docs[0].id;
                Navigator.pushNamed(context, PROFILE_PAGE, arguments: uid);
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildStatusText(BuildContext context, String status) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      child: Text(
        status,
        style: Theme.of(context).textTheme.bodyText1,
      ),
    );
  }
}
