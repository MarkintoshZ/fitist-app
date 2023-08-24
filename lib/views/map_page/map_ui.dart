import 'package:carousel_slider/carousel_slider.dart';
import 'package:fitist/model/user_profile.dart';
import 'package:fitist/providers/map_state.dart';
import 'package:fitist/services/user_profile_service.dart';
import 'package:fitist/views/widgets/user_avatar.dart';
import 'package:fitist/views/widgets/user_profile_clickable.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class MapUI extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final mapState = context.read<MapStateProvider>();
    print('MapState updated: $mapState');
    return StreamBuilder<List<String>>(
      initialData: mapState.uids,
      stream: mapState.uidsStream,
      builder: (context, snapshot) {
        // use ignore pointer with AnimatedOpacity
        var selectedUids = snapshot.data;
        return Stack(
          children: [
            StreamBuilder<bool>(
              initialData: mapState.cameraFollow,
              stream: mapState.cameraFollowStream,
              builder: (context, snapshot) {
                return IgnorePointer(
                  ignoring: snapshot.data || selectedUids.isNotEmpty,
                  child: AnimatedOpacity(
                    opacity: (snapshot.data || selectedUids.isNotEmpty) ? 0 : 1,
                    curve: Curves.ease,
                    duration: Duration(milliseconds: 200),
                    child: Align(
                      alignment: Alignment.bottomCenter,
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 40),
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                            color: Theme.of(context).canvasColor,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.4),
                                offset: const Offset(1, 2),
                                blurRadius: 15,
                              ),
                            ]),
                        child: IconButton(
                          icon: Icon(Icons.my_location),
                          iconSize: 30,
                          onPressed: () => mapState.setCameraFollow(true),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
            IgnorePointer(
              ignoring: selectedUids.isEmpty,
              child: AnimatedOpacity(
                opacity: selectedUids.isEmpty ? 0 : 1,
                curve: Curves.easeInToLinear,
                duration: Duration(milliseconds: 100),
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 20),
                    child: CarouselSlider(
                      options: CarouselOptions(
                        aspectRatio: 3,
                        enlargeCenterPage: true,
                        enlargeStrategy: CenterPageEnlargeStrategy.height,
                        enableInfiniteScroll: false,
                      ),
                      items: selectedUids.isEmpty
                          ? [_buildEmptyCard(context)]
                          : selectedUids
                              .map((uid) => _buildCard(context, uid))
                              .toList(growable: false),
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildCard(context, uid) {
    return Container(
      margin: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.all(Radius.circular(20)),
        color: Theme.of(context).canvasColor,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            offset: const Offset(1, 2),
            blurRadius: 13,
          ),
        ],
      ),
      child: UserProfileClickable(
        uid: uid,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8.0),
                // width: 80,
                child: PhysicalModel(
                  shape: BoxShape.circle,
                  color: Colors.transparent,
                  elevation: 1,
                  child: UserAvatar(
                    srcImgSize: 64,
                    uid: uid,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: IntrinsicHeight(
                  child: Column(
                    children: [
                      FutureBuilder<UserProfileModel>(
                        future: UserProfileService.get(uid),
                        builder: (context, snapshot) {
                          return Text(
                            snapshot.data?.displayName ?? '',
                            style: Theme.of(context).textTheme.headline2,
                            overflow: TextOverflow.fade,
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyCard(context) {
    return Container(
      margin: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.all(Radius.circular(20)),
        color: Theme.of(context).canvasColor,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            offset: const Offset(1, 2),
            blurRadius: 13,
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8.0),
              width: 80,
            ),
          ],
        ),
      ),
    );
  }
}
