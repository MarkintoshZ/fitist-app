import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fitist/controllers/map_data.dart';
import 'package:fitist/utils/ref_data_pair.dart';
import 'package:flutter/material.dart';
import 'package:geoflutterfire/geoflutterfire.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong/latlong.dart';

class MapDataProvider extends ChangeNotifier {
  StreamController _selfSessionStreamController;

  DocumentReference ref;
  WorkoutSessionModel selfSession;

  Stream<WorkoutSessionModel> get selfSessionStream =>
      _selfSessionStreamController.stream;

  List<WorkoutSessionModel> sessions;
  Stream<List<WorkoutSessionModel>> sessionsStream;

  LatLng currentLocation;
  Stream<LatLng> locationStream;

  List<StreamSubscription> _streamSubscriptions = [];

  Future<void> init() async {
    print('init location provider');
    if (locationStream != null) {
      print('Location provider is already instantiated');
      return;
    }

    _selfSessionStreamController =
        StreamController<WorkoutSessionModel>.broadcast(
            onListen: () => _selfSessionStreamController.sink.add(selfSession));

    print('init location stream');
    locationStream = Geolocator.getPositionStream(distanceFilter: 1)
        .map((location) => LatLng(location.latitude, location.longitude));
    _streamSubscriptions.add(locationStream.listen(_onLocationChange));

    // TODO: update query parameter when location changed over threshold
    final loc = await Geolocator.getCurrentPosition();
    currentLocation = LatLng(loc.latitude, loc.longitude);
    sessionsStream = MapDataController.query(
            currentLocation.latitude, currentLocation.longitude)
        .map((List<RefDataPair<WorkoutSessionModel>> list) {
      // filter out finished sessions (firebase query is not accurate)
      list.removeWhere((v) => v.data.isFinished);

      // set ref and self session if they are included in the snapshot
      final uid = FirebaseAuth.instance.currentUser.uid;
      final pair = list.firstWhere((element) => element.data.uid == uid,
          orElse: () => null);
      if (pair != null) {
        ref = pair.ref;
        final data = pair.data;
        if (selfSession != data) {
          // data (timestamp) is changed
          selfSession = data;
          if (!_selfSessionStreamController.isClosed)
            _selfSessionStreamController.sink.add(selfSession);

          _checkSessionEnd();
        }
      } else if (ref != null) {
        // selfSession is finished
        ref = null;
        selfSession = null;
        if (!_selfSessionStreamController.isClosed)
          _selfSessionStreamController.sink.add(null);
      }
      sessions = list.map((v) => v.data).toList(growable: false);
      return sessions;
    }).asBroadcastStream();

    if (!_selfSessionStreamController.isClosed)
      _selfSessionStreamController.sink.add(selfSession);

    print(currentLocation);
  }

  void _onLocationChange(latLng) {
    currentLocation = latLng;

    // update firestore location when distance moved exceed a threshold
    if (currentLocation != null &&
        sessions != null &&
        selfSession != null &&
        !selfSession.isFinished) {
      var distance = selfSession.position.haversineDistance(
          lat: currentLocation.latitude, lng: currentLocation.longitude);
      print('distance: $distance');
      if (distance > 0.10) {
        selfSession.position =
            GeoFirePoint(currentLocation.latitude, currentLocation.longitude);
        debugPrint('update firestore');
        ref.set(selfSession.toMap());
      }
    }
  }

  Future<void> createSession(String uid, String displayName, Duration duration,
      double latitude, double longitude) async {
    await MapDataController.createSession(
        uid, displayName, duration, latitude, longitude);
    // set callback to notify ui of selfSession end
    Future.delayed(duration, _checkSessionEnd);
  }

  /// callback for checking if selfSession has ended and emit event to
  /// selfSessionStream
  void _checkSessionEnd() {
    if (!_selfSessionStreamController.isClosed && selfSession != null) {
      if (selfSession.isFinished) {
        ref = null;
        selfSession = null;
        _selfSessionStreamController.sink.add(null);
      } else {
        Future.delayed(
            selfSession.endTime.difference(DateTime.now()), _checkSessionEnd);
      }
    }
  }

  @override
  void dispose() {
    _selfSessionStreamController.close();
    _streamSubscriptions.forEach((element) => element.cancel());
    locationStream = null;
    sessionsStream = null;
    print('Disposing map data provider');
    super.dispose();
  }

  @override
  String toString() {
    return toMap().toString();
  }

  Map<String, dynamic> toMap() {
    return {
      'ref': ref,
      'selfSession': selfSession,
      'sessions': sessions,
      'sessionStream': sessionsStream,
      'currentLocation': currentLocation,
      'locationStream': locationStream,
    };
  }
}
