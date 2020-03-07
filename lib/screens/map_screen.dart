import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter/cupertino.dart';
import 'package:ravel/screens/add_book_content_screen.dart';
import 'package:geoflutterfire/geoflutterfire.dart';
im
class MapScreen extends StatefulWidget {
  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  GoogleMapController mapController;

  Set<Marker> markers;
  BitmapDescriptor customIcon;

  @override
  void initState() {
    super.initState();
    _setCustomMapPin();
    markers = Set.from([]);
  }

  @override
  Widget build(BuildContext context) {
    return GoogleMap(
      onTap: (pos) {
        Marker marker = Marker(
          markerId: MarkerId('1'),
          icon: customIcon,
          position: pos,
          infoWindow: InfoWindow(
              title: 'Description of Marker',
              snippet: 'Click to Edit',
              onTap: () {
                Navigator.of(context).push(
                  CupertinoPageRoute<void>(
                    builder: (context) {
                      return AddBookContentScreen();
                    },
                  ),
                );
              }),
        );
        setState(() {
          markers.add(marker);
        });
      },
      initialCameraPosition:
          CameraPosition(target: LatLng(24.142, -110.321), zoom: 5),
      onMapCreated: (GoogleMapController controller) {},
      markers: markers,
      myLocationEnabled: true,
      compassEnabled: true,
    );
  }

  _setCustomMapPin() async {
    if (customIcon == null) {
      BitmapDescriptor icon = await BitmapDescriptor.fromAssetImage(
          ImageConfiguration(devicePixelRatio: 10), 'assets/book.png');
      customIcon = icon;
    }
  }
}
