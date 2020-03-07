import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

void main() async {
  // This app is designed only to work vertically, so we limit
  // orientations to portrait up and down.
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations(
      [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
  runApp(Ravel());
}

class Ravel extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return CupertinoApp(
      debugShowCheckedModeBanner: false,
      theme: CupertinoThemeData(
        brightness: Brightness.light,
        barBackgroundColor: CupertinoColors.white,
        scaffoldBackgroundColor: CupertinoColors.white,
      ),
      home: CupertinoPageScaffold(child: FireMap()),
    );
  }
}

class FireMap extends StatefulWidget {
  @override
  _FireMapState createState() => _FireMapState();
}

class _FireMapState extends State<FireMap> {
  GoogleMapController mapController;

  Set<Marker> markers;
  BitmapDescriptor customIcon;

  @override
  void initState() {
    super.initState();
    markers = Set.from([]);
  }

  _createMarker(context) async {
    if (customIcon == null) {
      ImageConfiguration configuration = createLocalImageConfiguration(context);
      BitmapDescriptor icon = await BitmapDescriptor.fromAssetImage(
          configuration, 'assets/book_icon.png');
      setState(() {
        customIcon = icon;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    _createMarker(context);
    return Stack(
      children: <Widget>[
        GoogleMap(
          onTap: (pos) {
            print(pos);
            Marker marker = Marker(
                markerId: MarkerId('1'), icon: customIcon, position: pos);
            setState(() {
              markers.add(marker);
            });
          },
          initialCameraPosition:
              CameraPosition(target: LatLng(24.142, -110.321), zoom: 10),
          onMapCreated: (GoogleMapController controller) {},
          markers: markers,
          myLocationEnabled: true,
          compassEnabled: true,
        ),
        Positioned(
          bottom: 50,
          right: 10,
          child: FlatButton(
            onPressed: () {},
            color: Colors.green,
            child: Icon(
              Icons.pin_drop,
              color: Colors.white,
            ),
          ),
        )
      ],
    );
  }
}
