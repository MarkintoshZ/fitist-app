import 'dart:async';

import 'package:flutter/material.dart';

class MapStateProvider extends ChangeNotifier {
  bool _cameraFollow = true;
  final _cameraFollowStreamController = StreamController<bool>.broadcast();
  List<String> _uids = [];
  final _uidsStreamController = StreamController<List<String>>.broadcast();

  bool get cameraFollow => _cameraFollow;
  Stream<bool> get cameraFollowStream => _cameraFollowStreamController.stream;

  List<String> get uids => _uids;
  Stream<List<String>> get uidsStream => _uidsStreamController.stream;

  void setCameraFollow(bool v) {
    this._cameraFollow = v;
    _cameraFollowStreamController.sink.add(v);
  }

  void setUIDs(List<String> uids) {
    _uids = uids;
    _uidsStreamController.sink.add(uids);
  }

  @override
  String toString() {
    return "MapStateProvider(cameraFollow: $_cameraFollow, uids: $_uids)";
  }
}
