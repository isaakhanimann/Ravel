import 'package:flutter/cupertino.dart';
import 'package:geolocator/geolocator.dart';

class GeocodingService {
  final geoLocator = Geolocator();

  Future<String> getCity(
      {@required double latitude, @required double longitude}) async {
    List<Placemark> placemark =
        await geoLocator.placemarkFromCoordinates(52.2165157, 6.9437819);

    return 'cityname';
  }
}
