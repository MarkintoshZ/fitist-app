import 'package:geoflutterfire/geoflutterfire.dart';
import 'package:latlong/latlong.dart';

extension GeoConversion on GeoFirePoint {
  LatLng asLatLng() {
    return LatLng(this.latitude, this.longitude);
  }
}

extension LatLngConversion on LatLng {
  Coordinates asCoordinates() {
    return Coordinates(this.latitude, this.longitude);
  }
}
