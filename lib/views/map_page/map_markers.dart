import 'dart:math';

import 'package:fitist/providers/map_state.dart';
import 'package:fitist/views/map_page/MapPinPainter.dart';
import 'package:fitist/views/widgets/user_avatar.dart';
import 'package:fitist/controllers/map_data.dart';
import 'package:fitist/providers/map_data.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map/plugin_api.dart';
import 'package:flutter_map_marker_cluster/flutter_map_marker_cluster.dart';
import 'package:geoflutterfire/geoflutterfire.dart';
import 'package:provider/provider.dart';
import 'package:fitist/utils/location_conversion.dart';

@immutable
class AvatarClusterLayerWidget extends StatelessWidget {
  const AvatarClusterLayerWidget({Key key}) : super(key: key);
  static const size = Size(100, 120);

  @override
  Widget build(BuildContext context) {
    final mapState = MapState.of(context);

    final mapData = context.read<MapDataProvider>();
    return StreamBuilder<List<WorkoutSessionModel>>(
      initialData: mapData.sessions,
      stream: mapData.sessionsStream,
      builder: (context, snapshot) {
        List<Marker> markers = [];
        List<WorkoutSessionModel> sessions = [];
        if (snapshot.connectionState == ConnectionState.active ||
            snapshot.hasData) {
          sessions = snapshot.data;
          markers = sessions.map(_buildMarker).toList(growable: false);
        }
        final options = MarkerClusterLayerOptions(
          maxClusterRadius: 120,
          spiderfyCircleRadius: 70,
          disableClusteringAtZoom: 20,
          size: size,
          anchor: AnchorPos.align(AnchorAlign.top),
          fitBoundsOptions: const FitBoundsOptions(
            padding: const EdgeInsets.all(50),
          ),
          markers: markers,
          builder: (context, markers) =>
              _buildClusterMarker(context, markers, sessions),
        );
        return MarkerClusterLayer(options, mapState, mapState.onMoved);
      },
    );
  }

  Marker _buildMarker(WorkoutSessionModel sess) {
    return Marker(
      point: sess.position.asLatLng(),
      anchorPos: AnchorPos.align(AnchorAlign.top),
      width: size.width,
      height: size.height,
      builder: (context) {
        return PhysicalModel(
          key: Key(sess.uid),
          color: Colors.transparent,
          shape: BoxShape.circle,
          elevation: 40,
          child: GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTap: () => context.read<MapStateProvider>().setUIDs([sess.uid]),
            child: CustomPaint(
              willChange: false,
              painter: const MapPinPainter(),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(13, 13, 13, 33),
                child: UserAvatar(
                  key: Key(sess.uid),
                  uid: sess.uid,
                  srcImgSize: 64,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildClusterMarker(BuildContext context, List<Marker> markers,
      List<WorkoutSessionModel> sessions) {
    double maxDist = 0;
    for (var i = 0; i < markers.length; i++) {
      for (var j = i; j < markers.length; j++) {
        final point1 = markers[i].point.asCoordinates();
        final point2 = markers[j].point.asCoordinates();
        maxDist = max(
          maxDist,
          GeoFirePoint.distanceBetween(to: point1, from: point2),
        );
      }
    }
    print('maxDist = $maxDist');
    final child = Stack(
      children: [
        markers.first.builder(context),
        Align(
          alignment: Alignment.bottomCenter,
          child: Padding(
            padding: const EdgeInsets.only(bottom: 9),
            child: Text(
              '+${markers.length - 1}',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ],
    );
    if (maxDist < 0.1) {
      return GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          final uids = Set<String>();
          for (final marker in markers) {
            for (final sess in sessions) {
              if (marker.point == sess.position.asLatLng()) {
                uids.add(sess.uid);
              }
            }
          }
          context
              .read<MapStateProvider>()
              .setUIDs(uids.toList(growable: false));
        },
        child: IgnorePointer(child: child),
      );
    }
    return IgnorePointer(
      child: child,
    );
  }
}
