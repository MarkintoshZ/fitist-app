import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fitist/utils/ref_data_pair.dart';
import 'package:flutter/material.dart';
import 'package:geoflutterfire/geoflutterfire.dart';

final geo = Geoflutterfire();
final store = FirebaseFirestore.instance;

class WorkoutSessionModel {
  DateTime startTime;
  DateTime endTime;
  String uid;
  String displayName;
  GeoFirePoint position;

  WorkoutSessionModel({
    @required this.startTime,
    @required this.endTime,
    @required this.uid,
    @required this.displayName,
    @required this.position,
  });

  WorkoutSessionModel.fromMap(Map<String, dynamic> map) {
    this.startTime = (map['startTime'] as Timestamp).toDate();
    this.endTime = (map['endTime'] as Timestamp).toDate();
    this.uid = map['uid'];
    this.displayName = map['username'];
    final geopoint = map['position']['geopoint'];
    this.position = GeoFirePoint(geopoint.latitude, geopoint.longitude);
  }

  Map<String, dynamic> toMap({forFirebase = false}) => {
        'startTime': startTime,
        'endTime': endTime,
        'uid': uid,
        'username': displayName,
        'position': position.data,
        'done': false
        // FIXME: potential bug (*done* might supposed to be true when to map is called)
      };

  @override
  String toString() => toMap().toString();

  bool get isFinished => endTime.isBefore(DateTime.now());
}

class MapDataController {
  static Stream<List<RefDataPair<WorkoutSessionModel>>> query(
      double latitude, double longitude) {
    final center = GeoFirePoint(latitude, longitude);
    print(center);
    final query = store.collection('/Sessions').where('done', isEqualTo: false);
    return geo
        .collection(collectionRef: query)
        .within(center: center, radius: 5, field: 'position')
        .map((docs) {
      return docs
          .map((doc) => RefDataPair<WorkoutSessionModel>(
                doc.reference,
                WorkoutSessionModel.fromMap(doc.data()),
              ))
          .toList();
    });
  }

  static Future<void> createSession(String uid, String displayName,
      Duration duration, double latitude, double longitude) {
    final session = WorkoutSessionModel(
      startTime: DateTime.now(),
      endTime: DateTime.now().add(duration),
      uid: uid,
      displayName: displayName,
      position: GeoFirePoint(latitude, longitude),
    );
    final docRef = store.collection('/Sessions').doc();
    return docRef.set(session.toMap());
  }

// static Future<void> addDuration(DocumentReference ref, Duration duration) {
//   _currentSession.endTime = _currentSession.endTime.add(duration);
//   return _documentReference.set(
//       _currentSession.toMap(), SetOptions(merge: true));
// }
}

