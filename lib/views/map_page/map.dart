import 'dart:async';

import 'package:fitist/providers/map_state.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart' hide Image;
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map/plugin_api.dart';
import 'package:latlong/latlong.dart';
import 'package:provider/provider.dart';

import 'package:fitist/views/map_page/map_config.dart';
import 'package:fitist/providers/map_data.dart';

import 'map_markers.dart';

class MapWidget extends StatefulWidget {
  const MapWidget({Key key}) : super(key: key);

  @override
  State<MapWidget> createState() => _MapWidgetState();
}

class _MapWidgetState extends State<MapWidget> {
  final _mapController = MapController();
  StreamSubscription _locationStreamSubscription;
  StreamSubscription _cameraFollowStreamSubscription;
  bool cameraFollow = true;

  @override
  void initState() {
    super.initState();
    setupListeners();
  }

  void setupListeners() {
    _locationStreamSubscription = context
        .read<MapDataProvider>()
        .locationStream
        .listen(onDeviceLocationChange);
    _cameraFollowStreamSubscription = context
        .read<MapStateProvider>()
        .cameraFollowStream
        .listen(onCameraFollowChange);
  }

  void onCameraFollowChange(follow) {
    cameraFollow = follow;
    if (follow) {
      final loc = context.read<MapDataProvider>().currentLocation;
      _mapController.move(loc, 15.0);
    }
  }

  @override
  void dispose() {
    _locationStreamSubscription?.cancel();
    _cameraFollowStreamSubscription?.cancel();
    super.dispose();
  }

  void onDeviceLocationChange(loc) {
    if (cameraFollow) {
      _mapController.move(loc, 15.0);
    }
  }

  void onMapLocationChange(MapPosition position, bool changed) {
    if (position.hasGesture) {
      // moved by user, disable camera follow
      final mapState = context.read<MapStateProvider>();
      mapState.setCameraFollow(false);
      mapState.setUIDs([]);
    }
  }

  @override
  Widget build(BuildContext context) {
    final location = context.read<MapDataProvider>().currentLocation;
    return FlutterMap(
      options: MapOptions(
        center: LatLng(location.latitude, location.longitude),
        zoom: 15.0,
        maxZoom: 18,
        interactiveFlags: InteractiveFlag.pinchZoom | InteractiveFlag.drag,
        onPositionChanged: onMapLocationChange,
      ),
      children: [
        TileLayerWidget(
          options: TileLayerOptions(
            urlTemplate: MAP_TEMPLATE_URL,
          ),
        ),
        const AvatarClusterLayerWidget(),
      ],
      mapController: _mapController,
    );
  }
}
