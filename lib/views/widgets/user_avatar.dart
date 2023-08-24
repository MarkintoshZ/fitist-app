import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:fitist/providers/my_avatar.dart';
import 'package:fitist/utils/storage_url.dart';

final auth = FirebaseAuth.instance;

class UserAvatar extends StatelessWidget {
  final String uid;
  final int srcImgSize;
  final File file;
  final double size;
  final bool clickable;
  final bool loading;

  static final defaultImageProvider =
      AssetImage('assets/images/default_profile_picture.jpeg');

  // TODO: make a loading image
  static final loadingImageProvider =
      AssetImage('assets/images/default_profile_picture.jpeg');

  const UserAvatar({
    Key key,
    this.uid,
    this.srcImgSize = 512,
    this.file,
    this.size,
    this.clickable = true,
    this.loading = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Widget image;
    if (file != null) {
      image = _buildImage(FileImage(file));
    } else if (loading) {
      image = _buildImage(loadingImageProvider);
    } else if (uid != null && uid != '') {
      if (uid == auth.currentUser.uid) {
        final imageProvider = context.watch<MyAvatarProvider>().imageProvider;
        if (imageProvider == null) {
          image = Container();
        } else {
          image = _buildImage(imageProvider);
        }
      } else {
        final url = uid2avatarUri(uid, size: srcImgSize);
        image = _buildImage(NetworkImage(url));
      }
    } else {
      image = _buildImage(defaultImageProvider);
    }

    return SizedBox(
      width: size,
      child: AspectRatio(
        aspectRatio: 1,
        child: ClipOval(
          child: image,
        ),
      ),
    );
  }

  Image _buildImage(ImageProvider imageProvider) {
    return Image(
      image: imageProvider,
      fit: BoxFit.cover,
      errorBuilder: (context, url, error) => _buildImage(defaultImageProvider),
      frameBuilder: (BuildContext context, Widget child, int frame,
          bool wasSynchronouslyLoaded) {
        if (wasSynchronouslyLoaded ?? false) {
          return child;
        }
        return AnimatedOpacity(
          child: child,
          opacity: frame == null ? 0 : 1,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeOut,
        );
      },
    );
  }
}
