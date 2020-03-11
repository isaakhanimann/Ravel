import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter/cupertino.dart';
import 'package:ravel/screens/add_book_content_screen.dart';
import 'package:ravel/models/book.dart';
import 'package:provider/provider.dart';
import 'package:ravel/services/firestore_service.dart';

class MapScreen extends StatefulWidget {
  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  BitmapDescriptor customPin;
  Stream<List<Book>> streamOfBooks;
  bool showLoading = true;

  @override
  void initState() {
    super.initState();
    _setCustomPin();
    final firestoreService =
        Provider.of<FirestoreService>(context, listen: false);
    final loggedInUid = Provider.of<String>(context, listen: false);
    streamOfBooks = firestoreService.getStreamOfBooks(uid: loggedInUid);
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: streamOfBooks,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting ||
            snapshot.connectionState == ConnectionState.none) {
          showLoading = true;
        }

        showLoading = false;

        final List<Book> books = snapshot.data;

        Set<Marker> markers = _convertBooksToMarkers(books: books);

        return Stack(
          children: <Widget>[
            GoogleMap(
              onTap: _onTapMap,
              initialCameraPosition:
                  CameraPosition(target: LatLng(24.142, -110.321), zoom: 4),
              markers: markers,
            ),
            if (showLoading) Center(child: CupertinoActivityIndicator())
          ],
        );
      },
    );
  }

  _onTapMap(LatLng position) async {
    _addBook(position: position);
  }

  _addBook({LatLng position}) async {
    String loggedInUid = Provider.of<String>(context, listen: false);
    Book book = Book(
        ownerUid: loggedInUid,
        title: 'Title',
        content: 'Content',
        location: GeoPoint(position.latitude, position.longitude),
        whenCreated: FieldValue.serverTimestamp());
    final firestoreService =
        Provider.of<FirestoreService>(context, listen: false);
    await firestoreService.updateBook(book: book);
  }

  Set<Marker> _convertBooksToMarkers({List<Book> books}) {
    if (books == null) {
      return Set.from([]);
    }
    List<Marker> markersList = books
        .map(
          (book) => Marker(
            markerId: MarkerId(UniqueKey().toString()),
            icon: customPin,
            position: LatLng(book.location.latitude, book.location.longitude),
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
          ),
        )
        .toList();
    return Set.from(markersList);
  }

  _setCustomPin() async {
    if (customPin == null) {
      BitmapDescriptor icon = await BitmapDescriptor.fromAssetImage(
          ImageConfiguration(devicePixelRatio: 10), 'assets/book.png');
      customPin = icon;
    }
  }
}
