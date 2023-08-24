import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fitist/utils/ref_data_pair.dart';
import 'package:flutter/material.dart';

final store = FirebaseFirestore.instance;

enum FriendRequestStatus {
  Waiting,
  Accepted,
  Rejected,
  Expired,
}

class FriendRequestModel {
  final String uidFrom;
  final String uidTo;
  final Timestamp createdTime;
  final FriendRequestStatus status;

  FriendRequestModel(this.uidFrom, this.uidTo, this.createdTime, this.status);

  FriendRequestModel.fromMap(Map<String, dynamic> map)
      : this.uidFrom = map['uidFrom'],
        this.uidTo = map['uidTo'],
        this.createdTime = map['createdTime'],
        this.status = FriendRequestStatus.values[[
          'WAITING',
          'ACCEPTED',
          'REJECTED',
          'EXPIRED'
        ].indexOf(map['status'])];
}

class FriendRequestsProvider extends ChangeNotifier {
  Stream<List<RefDataPair<FriendRequestModel>>> stream;

  FriendRequestsProvider() {
    final uid = FirebaseAuth.instance.currentUser.uid;

    // TODO: remove old requests
    this.stream = store
        .collection(
            '/Users/${FirebaseAuth.instance.currentUser.uid}/FriendRequests')
        .orderBy('createdTime')
        .snapshots()
        .map((event) {
      // filter out the request sent out by the current user
      final requests = event.docs
          .map((doc) => RefDataPair(
                doc.reference,
                FriendRequestModel.fromMap(doc.data()),
              ))
          .where((doc) => doc.data.uidFrom != uid)
          .toList(growable: false);
      // only take the last request from each user
      final existingUids = Set();
      return requests.where((req) {
        if (!existingUids.contains(req.data.uidFrom)) {
          existingUids.add(req.data.uidFrom);
          return true;
        }
        return false;
      }).toList(growable: false).reversed.toList(growable: false);
    });
  }

  Future accept(DocumentReference doc) {
    return doc.set({
      'status': 'ACCEPTED',
    }, SetOptions(merge: true));
  }

  Future reject(DocumentReference doc) {
    return doc.set({
      'status': 'REJECTED',
    }, SetOptions(merge: true));
  }
}
