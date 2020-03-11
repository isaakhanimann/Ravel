import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter/cupertino.dart';

class MapScreenLoading extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        GoogleMap(
          initialCameraPosition:
              CameraPosition(target: LatLng(24.142, -110.321), zoom: 4),
        ),
        Center(child: CupertinoActivityIndicator())
      ],
    );
  }
}
