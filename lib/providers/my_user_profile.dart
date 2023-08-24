import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fitist/model/user_profile.dart';
import 'package:flutter/material.dart';

final store = FirebaseFirestore.instance;

class MyUserProfileProvider extends ChangeNotifier {
  UserProfileModel user = UserProfileModel.initData;
  StreamSubscription _streamSubscription;

  MyUserProfileProvider() {
    final uid = FirebaseAuth.instance.currentUser.uid;

    _streamSubscription = store
        .doc('/Users/$uid')
        .snapshots()
        .map((snap) => UserProfileModel.fromJson(snap.data()))
        .listen((user) {
      this.user = user;
      notifyListeners();
    });
  }

  dispose() {
    _streamSubscription?.cancel();
    print('disposed UserProfileProvider $_streamSubscription');
    super.dispose();
  }

  Future update(Map<String, dynamic> data) async {
    final uid = FirebaseAuth.instance.currentUser.uid;
    return store.doc('/Users/$uid').set(data, SetOptions(merge: true));
  }
}
