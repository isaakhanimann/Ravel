import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter/cupertino.dart';
import 'package:ravel/constants.dart';
import 'package:ravel/screens/add_book_content_screen.dart';
import 'package:ravel/models/book.dart';
import 'package:provider/provider.dart';
import 'package:ravel/services/firestore_service.dart';
import 'package:flutter/material.dart';

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
    showGeneralDialog(
        barrierColor: Colors.white.withOpacity(0.3),
        transitionBuilder: (context, a1, a2, widget) {
          return Transform.scale(
            scale: a1.value,
            child: Opacity(
              opacity: a1.value,
              child: DayPickerDialog(
                addBook: () {
                  _addBook(position: position);
                },
              ),
            ),
          );
        },
        transitionDuration: Duration(milliseconds: 200),
        barrierDismissible: true,
        barrierLabel: '',
        context: context,
        pageBuilder: (context, animation1, animation2) {});
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

class DayPickerDialog extends StatefulWidget {
  Function addBook;

  DayPickerDialog({@required this.addBook});

  @override
  _DayPickerDialogState createState() => _DayPickerDialogState();
}

class _DayPickerDialogState extends State<DayPickerDialog> {
  final List<Text> items = [];
  int selectedNumber = 1;

  @override
  void initState() {
    super.initState();
    for (int i = 1; i < 21; i++) {
      items.add(Text(i.toString()));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text(
              'How many days do you want to spend there?',
              style: TextStyle(fontSize: 25),
              textAlign: TextAlign.center,
            ),
            SizedBox(
              height: 120,
              child: CupertinoPicker(
                  backgroundColor: kYellow,
                  itemExtent: 30,
                  onSelectedItemChanged: _onSelectedItemChanged,
                  children: items),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: <Widget>[
                CupertinoButton(
                  child: Text(
                    'Cancel',
                    style: TextStyle(
                      fontSize: 20,
                      color: kDarkBlue,
                    ),
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
                CupertinoButton(
                  child: Text(
                    'Add',
                    style: TextStyle(
                      fontSize: 20,
                      color: kDarkBlue,
                    ),
                  ),
                  onPressed: () async {
                    await widget.addBook();
                    Navigator.pop(context);
                  },
                ),
              ],
            )
          ],
        ),
      ),
      backgroundColor: kYellow,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(20))),
    );
  }

  _onSelectedItemChanged(int indexOfItem) {
    selectedNumber = indexOfItem + 1;
  }
}
