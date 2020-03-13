import 'package:flutter/cupertino.dart';
import 'package:geolocator/geolocator.dart';

class GeocodingService {
  final geoLocator = Geolocator();

  Future<String> getCity(
      {@required double latitude, @required double longitude}) async {
    List<Placemark> placemarks =
        await geoLocator.placemarkFromCoordinates(latitude, longitude);
    return placemarks[0]?.locality;
  }
}
